import { spawn } from "node:child_process"
import { existsSync, realpathSync } from "node:fs"
import { rm } from "node:fs/promises"
import { basename, resolve } from "node:path"
import { Plugin, Worktree } from "@opencode/plugin"

/**
 * Worktree strategy backed by `jj workspace`.
 *
 * OpenCode uses Git worktrees by default. In a jj repository (especially a
 * colocated one) that leaves the new directory outside jj's workspace
 * inventory, so work done there is invisible to `jj` and the colocated Git
 * metadata can get out of sync.
 *
 * This strategy registers itself only when the project's canonical checkout is
 * a jj repository. `jj workspace add` creates a proper jj workspace, and
 * `--colocate` additionally creates the matching Git worktree when the source
 * checkout is colocated.
 */

type RunOptions = {
  cwd: string
  signal: AbortSignal
}

type Workspace = {
  name: string
  root: string
}

type WorktreeEntry = {
  directory: string
  type: "root" | "worktree"
}

function run(command: string, args: readonly string[], options: RunOptions) {
  return new Promise<{ stdout: string; stderr: string }>((resolvePromise, reject) => {
    const aborted = () =>
      options.signal.reason instanceof Error ? options.signal.reason : new Error("Aborted")

    if (options.signal.aborted) {
      reject(aborted())
      return
    }

    const child = spawn(command, [...args], {
      cwd: options.cwd,
      stdio: ["ignore", "pipe", "pipe"],
    })

    let stdout = ""
    let stderr = ""

    child.stdout.setEncoding("utf8")
    child.stderr.setEncoding("utf8")
    child.stdout.on("data", (chunk: string) => (stdout += chunk))
    child.stderr.on("data", (chunk: string) => (stderr += chunk))

    const onAbort = () => child.kill("SIGTERM")
    const cleanup = () => options.signal.removeEventListener("abort", onAbort)
    options.signal.addEventListener("abort", onAbort, { once: true })

    child.on("error", (error) => {
      cleanup()
      reject(error)
    })

    child.on("close", (code) => {
      cleanup()

      if (options.signal.aborted) {
        reject(aborted())
      } else if (code === 0) {
        resolvePromise({ stdout, stderr })
      } else {
        const detail = stderr.trim() || stdout.trim()
        reject(
          new Error(
            `${command} ${args.join(" ")} exited with ${code}${detail ? `: ${detail}` : ""}`,
          ),
        )
      }
    })
  })
}

function jj(cwd: string, args: readonly string[], signal: AbortSignal) {
  return run("jj", args, { cwd, signal })
}

function samePath(a: string, b: string) {
  try {
    return realpathSync(a) === realpathSync(b)
  } catch {
    return resolve(a) === resolve(b)
  }
}

async function repoRoot(directory: string, signal: AbortSignal) {
  const { stdout } = await jj(directory, ["root"], signal)
  return stdout.trim()
}

async function listWorkspaces(directory: string, signal: AbortSignal): Promise<Workspace[]> {
  const { stdout } = await jj(
    directory,
    ["workspace", "list", "-T", 'name ++ "\\t" ++ root ++ "\\n"'],
    signal,
  )

  return stdout
    .split("\n")
    .filter((line) => line.includes("\t"))
    .map((line) => {
      const separator = line.indexOf("\t")
      return {
        name: line.slice(0, separator),
        root: line.slice(separator + 1).trimEnd(),
      }
    })
}

/**
 * The destination's basename is the natural workspace name, matching jj's own
 * default. Names must be unique, so append a counter when another workspace
 * already uses it.
 */
function workspaceName(directory: string, existing: readonly Workspace[]) {
  const candidate = basename(resolve(directory))
  const base =
    candidate.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^[-.]+|[-.]+$/g, "") || "worktree"
  const names = new Set(existing.map((workspace) => workspace.name))

  if (!names.has(base)) return base

  let suffix = 2
  while (names.has(`${base}-${suffix}`)) suffix += 1
  return `${base}-${suffix}`
}

async function hasChanges(directory: string, signal: AbortSignal) {
  try {
    const [diff, conflict] = await Promise.all([
      jj(directory, ["diff", "--summary"], signal),
      jj(directory, ["log", "-r", "@", "--no-graph", "-T", "conflict"], signal),
    ])

    return diff.stdout.trim().length > 0 || conflict.stdout.trim() === "true"
  } catch (error) {
    // A workspace directory can disappear before OpenCode removes it. Let
    // `workspace forget` clean up the remaining metadata in that case.
    if (!existsSync(directory)) return false
    throw error
  }
}

const strategy = (canonical: string) => ({
  id: "jj",

  async create(
    input: { sourceDirectory: string; directory: string; branch?: string },
    { signal }: { signal: AbortSignal },
  ) {
    const source = resolve(input.sourceDirectory)
    const directory = resolve(input.directory)
    const existing = await listWorkspaces(source, signal)
    const name = workspaceName(directory, existing)
    const root = await repoRoot(source, signal)

    const args = ["workspace", "add", directory, "--name", name]
    if (input.branch) args.push("--revision", input.branch)
    if (existsSync(resolve(root, ".git"))) args.push("--colocate")

    await jj(source, args, signal)

    if (!existsSync(directory)) {
      throw new Error(`jj workspace add did not create ${directory}`)
    }

    return { directory }
  },

  async remove(
    input: { directory: string; force: boolean },
    { signal }: { signal: AbortSignal },
  ) {
    const directory = resolve(input.directory)
    const existing = await listWorkspaces(canonical, signal)
    const workspace = existing.find((entry) => samePath(entry.root, directory))

    if (!workspace) {
      if (!existsSync(directory)) return
      throw new Error(`No jj workspace is recorded for ${directory}`)
    }

    if (samePath(workspace.root, canonical)) {
      throw new Error("Refusing to remove the root jj workspace")
    }

    if (!input.force && existsSync(directory) && (await hasChanges(directory, signal))) {
      throw new Worktree.OperationError({
        message: `jj workspace ${workspace.name} has uncommitted changes`,
        forceRequired: true,
      })
    }

    await jj(canonical, ["workspace", "forget", workspace.name], signal)
    await rm(directory, { recursive: true, force: true })
  },

  async list(sourceDirectory: string, { signal }: { signal: AbortSignal }): Promise<WorktreeEntry[]> {
    const existing = await listWorkspaces(sourceDirectory, signal)

    return existing.map((workspace) => ({
      directory: workspace.root,
      type: samePath(workspace.root, canonical) ? "root" : "worktree",
    }))
  },
})

export default Plugin.define({
  id: "jj-worktree",

  async setup(ctx) {
    const canonical = ctx.location.project.canonical

    // Leave OpenCode's built-in Git strategy in place for non-jj projects.
    if (!existsSync(resolve(canonical, ".jj"))) return

    const registration = await ctx.worktree.transform((editor) => {
      editor.add(strategy(canonical))
    })

    return async () => {
      await registration.dispose()
    }
  },
})
