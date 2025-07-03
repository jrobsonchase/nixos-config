;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;

(setq doom-font (font-spec :family "DejaVu Sans Mono" :size 16 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 16)
      doom-symbol-font (font-spec :family "DejaVu Sans Mono" :size 16 :weight 'semi-light))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'monokai)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(use-package! monokai-theme
  :init
  (setq
   monokai-distinct-fringe-background nil
   ;; foreground and background
   monokai-foreground     "#f8f8f2"
   monokai-background     "#272822"
   ;; highlights and comments
   monokai-comments       "#75715e"
   monokai-emphasis       "#f8f8f0"
   monokai-highlight      "#49483e"
   monokai-highlight-alt  "#3e3d31"
   monokai-highlight-line "#3c3d37"
   monokai-line-number    "#8f908a"
   ;; colours
   monokai-blue           "#66d9ef"
   monokai-cyan           "#a1efe4"
   monokai-green          "#a6e22e"
   monokai-gray           "#64645e"
   monokai-violet         "#ae81ff"
   monokai-red            "#f92672"
   monokai-orange         "#fd971f"
   monokai-yellow         "#f4bf75")
  ;; monokai does some funky things with term colors. Make sure they're correct.
  (custom-set-faces!
    '(term-color-black :foreground "#272822")
    '(term-color-red :foreground "#F92672")
    '(term-color-green :foreground "#A6E22E")
    '(term-color-yellow :foreground "#F4BF75")
    '(term-color-blue :foreground "#66D9EF")
    '(term-color-magenta :foreground "#AE81FF")
    '(term-color-cyan :foreground "#A1EFE4")
    '(term-color-white :foreground "#F8F8F2")

    '(term-color-bright-black :foreground "#75715E")
    '(term-color-bright-red :foreground "#F92672")
    '(term-color-bright-green :foreground "#A6E22E")
    '(term-color-bright-yellow :foreground "#F4BF75")
    '(term-color-bright-blue :foreground "#66D9EF")
    '(term-color-bright-magenta :foreground "#AE81FF")
    '(term-color-bright-cyan :foreground "#A1EFE4")
    '(term-color-bright-white :foreground "#F9F8F5")))

(remove-hook 'doom-first-buffer-hook #'global-hl-line-mode)

(use-package! envrc
  :config
  (setq envrc-remote t))

(use-package! tramp
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package! jujutsu
  :config
  (map!
   ("C-c v j" 'jujutsu-status)))

(use-package! undo-tree
  :config
  (map!
   :mode 'undo-tree-visualizer-mode
   ("h" 'meow-left)
   ("l" 'meow-right)))

(use-package! meow
  :init
  (defun +meow-mark-char ()
    (interactive)
    (if (not (region-active-p))
        (thread-first
          (meow--make-selection '(expand . char) (point) (point))
          (meow--select))
      (thread-first
        (meow--make-selection '(expand . char) (mark) (point))
        (meow--select))))
  (defun +meow-region-dwim (region not-region)
    (lambda ()
      (interactive)
      (cond
       ((region-active-p) (funcall region))
       (t (funcall not-region)))))
  (defun +meow-kill-or (f)
    (+meow-region-dwim #'meow-kill f))
  (defun +meow-inverse-join (arg)
    "Select the indentation between this line to the non empty next line.

Will create selection with type (select . join)

Prefix:
with NEGATIVE ARGUMENT, backward search indentation to select.
with UNIVERSAL ARGUMENT, search both side."
    (interactive "P")
    (cond
     ((or (equal '(expand . join) (meow--selection-type))
          (meow--with-universal-argument-p arg))
      (meow--join-both))
     ((meow--with-negative-argument-p arg)
      (meow--join-backward))
     (t
      (meow--join-forward))))
  (defun +meow-hard-join (arg)
    "Kill the empty whitespace beween the end of this line and the next non-empty
line."
    (interactive "P")
    (+meow-inverse-join arg)
    (meow-kill))
  (defun +meow-append-after-char ()
    (interactive)
    (let ((append-right (lambda ()
                          (if (not (eolp))
                              (progn (meow-right)
                                     (meow-append))
                            (meow-append)))))
      (funcall (+meow-region-dwim #'meow-append append-right))))
  (defun +meow-next-word (n)
    (interactive "p")
    (meow-next-thing meow-word-thing 'char n))
  (defun +meow-back-word (n)
    (interactive "p")
    (meow-next-thing meow-word-thing 'char (- n)))
  (defun his-tracing-function (orig-fun &rest args)
    (message "display-buffer called with args %S" args)
    (let ((res (apply orig-fun args)))
      (message "display-buffer returned %S" res)
      res))
  :config
  ;; Start some modes in different states, like emacs mode for shell-like things.
  (mapc (apply-partially 'add-to-list 'meow-mode-state-list)
        '((eshell-mode . emacs)
          (vterm-mode . emacs)
          (circe-server-mode . emacs)
          (circe-channel-mode . emacs)))
  (meow-normal-define-key
   ;; make j search forward by default
   '("m" . +meow-hard-join)
   '("M" . +meow-inverse-join)
   ;; make d call meow-kill if a region is active
   `("d" . ,(+meow-kill-or #'meow-delete))
   `("D" . ,(+meow-kill-or #'meow-backward-delete))
   ;; make a append after the next char with no selection
   '("a" . +meow-append-after-char)
   ;; disable v for search and use / instead
   '("/" . meow-visit)
   '("v" . nil)
   ;; Replace undo-in-selection with redo
   '("U" . undo-tree-redo)
   ;; Find/till expanders
   '("F" . meow-find-expand)
   '("T" . meow-till-expand)
   '("e" . +meow-next-word)
   '("b" . +meow-back-word)
   '("v" . +meow-mark-char))
  (setq meow-use-clipboard t
        +meow-want-meow-open-below-continue-comments t
        ;; Walk back the bar cursor settings from the module
        ;; they make it hard to see where the cursor is when paired
        ;; with highlighted brackets.
        meow-cursor-type-normal 'box
        meow-cursor-type-beacon 'box))

(setq lsp-file-watch-threshold 10000)

(use-package! eglot
  :config
  (setq-default eglot-workspace-configuration
                '((nil (formatting (command . ["nix" "fmt"]))))))

(define-derived-mode helm-mode yaml-mode "helm"
  "Major mode for editing kubernetes helm templates")

(use-package! eglot
  :hook
  (helm-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(helm-mode "helm_ls" "serve")))

(use-package! kubernetes
  :commands (kubernetes-overview)
  :config
  (setq kubernetes-poll-frequency 3600
        kubernetes-redraw-frequency 3600))


(defvar-keymap pairs-map)
(defalias 'pairs pairs-map)

(map!
 (:map global-map
       "M-p" 'pairs
       (:prefix "C-x"
                "C-b" nil)); unmap ibuffer - it's annoying and takes precendence in meow's keypad
 (:map pairs-map
       "[" #'insert-pair
       "{" #'insert-pair
       "(" #'insert-pair
       "<" #'insert-pair
       "\"" #'insert-pair))

(use-package! vterm
  :init
  (defvar opened-from-vterm nil)
  (defun +kill-buffer-previous-window (buffer &optional dont-save)
    "Kill the current buffer and switch to the previous window."
    (interactive
     (list (current-buffer) current-prefix-arg))
    (doom/kill-this-buffer-in-all-windows buffer dont-save)
    (previous-window-any-frame))
  ;; if you omit :defer, :hook, :commands, or :after, then the package is loaded
  ;; immediately. By using :hook here, the `hl-todo` package won't be loaded
  ;; until prog-mode-hook is triggered (by activating a major mode derived from
  ;; it, e.g. python-mode)
  :hook (vterm-mode . goto-address-mode)
  :config
  ;; (add-hook! 'find-file-hook
  ;;   (when (getenv "EXTERNAL")
  ;;     (setq-local opened-from-vterm t)))

  ;; (add-hook! 'kill-buffer-hook
  ;;   (when (and opened-from-vterm
  ;;              (get-buffer-window (current-buffer)))
  ;;     (when-let* ((vterm (doom-buffers-in-mode 'vterm-mode (doom-visible-buffers))))
  ;;       (switch-to-buffer (car vterm))))))
  :bind ("C-x K" . +kill-buffer-previous-window))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(go-mode 4))
  (add-to-list 'copilot-indentation-alist '(rust-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

(setq mouse-autoselect-window t)

(use-package! rustic
  :config
  (setq rustic-indent-offset 2))

;; (use-package! tintin-mode)
;; (add-to-list '+tree-sitter-hl-enabled-modes 'tintin-mode t)

(doom/set-frame-opacity 0.97)

;; (use-package! blamer
;;   :bind (("C-c v i" . blamer-show-commit-info))
;;   :defer 20
;;   :custom
;;   (blamer-idle-time 0.3)
;;   (blamer-min-offset 70)
;;   (blamer-type 'both)
;;   (blamer-show-avater-p 't)
;;   :custom-face
;;   (blamer-face ((t :foreground "#75715e"
;;                    :background nil
;;                    :height 120
;;                    :italic t)))
;;   :config
;;   (global-blamer-mode 1))

(after! circe
  (set-irc-server! "irc.libera.chat"
    `(:tls t
      :port 6697
      :nick "jerc"
      :channels ("#clok"))))
