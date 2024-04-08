{ pkgs, ... }: {
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
      bazelbuild.vscode-bazel
      stackbuild.bazel-stack-vscode
    ];
  };
}
