;;; doom-nano-light-theme.el --- N Λ N O Light theme for Doom -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Inspired by nano-emacs light theme
;;
;;; Commentary:
;;; A minimalist light theme based on nano-emacs colors.
;;; Code:

(require 'doom-themes)

(defgroup doom-nano-light-theme nil
  "Options for the `doom-nano-light' theme."
  :group 'doom-themes)

(def-doom-theme doom-nano-light
  "A minimalist light theme based on nano-emacs."
  :family 'doom-nano
  :background-mode 'light

  ((nano-fg       '("#37474F" "black"   "black"))
   (nano-bg       '("#FFFFFF" "white"   "white"))
   (nano-hl       '("#FAFAFA" "white"   "white"))
   (nano-critical '("#FF6F00" "red"     "red"))
   (nano-salient  '("#673AB7" "magenta" "magenta"))
   (nano-strong   '("#000000" "black"   "black"))
   (nano-popout   '("#FFAB91" "yellow"  "yellow"))
   (nano-subtle   '("#ECEFF1" "white"   "brightwhite"))
   (nano-faded    '("#B0BEC5" "grey"    "brightblack"))

   (bg         nano-bg)
   (fg         nano-fg)
   (bg-alt     nano-hl)
   (fg-alt     nano-faded)

   (base0      nano-bg)
   (base1      nano-hl)
   (base2      nano-subtle)
   (base3      '("#CFD8DC" "grey"      "brightblack"))
   (base4      nano-faded)
   (base5      '("#90A4AE" "grey"      "brightblack"))
   (base6      nano-fg)
   (base7      '("#263238" "black"     "black"))
   (base8      nano-strong)

   (grey       base4)
   (red        nano-critical)
   (orange     nano-popout)
   (green      nano-salient)
   (teal       nano-salient)
   (yellow     nano-popout)
   (blue       nano-salient)
   (dark-blue  nano-salient)
   (magenta    nano-salient)
   (violet     nano-salient)
   (cyan       nano-salient)
   (dark-cyan  nano-salient)

   (highlight      nano-subtle)
   (vertical-bar   base2)
   (selection      nano-subtle)
   (builtin        nano-salient)
   (comments       nano-faded)
   (doc-comments   nano-faded)
   (constants      nano-salient)
   (functions      nano-strong)
   (keywords       nano-salient)
   (methods        nano-strong)
   (operators      nano-fg)
   (type           nano-salient)
   (strings        nano-popout)
   (variables      nano-strong)
   (numbers        nano-salient)
   (region         `(,(car nano-subtle) ,@(cdr base2)))
   (error          nano-critical)
   (warning        nano-popout)
   (success        nano-salient)
   (vc-modified    nano-popout)
   (vc-added       nano-salient)
   (vc-deleted     nano-critical)

   (modeline-fg              nano-fg)
   (modeline-fg-alt          nano-faded)
   (modeline-bg              nano-bg)
   (modeline-bg-alt          nano-bg)
   (modeline-bg-inactive     nano-bg)
   (modeline-bg-alt-inactive nano-bg))

  (((font-lock-comment-face &override) :foreground nano-faded :slant 'italic)
   ((font-lock-string-face &override) :foreground nano-popout)
   ((font-lock-constant-face &override) :foreground nano-salient)
   ((font-lock-warning-face &override) :foreground nano-popout)
   ((font-lock-function-name-face &override) :foreground nano-strong :weight 'bold)
   ((font-lock-variable-name-face &override) :foreground nano-strong :weight 'bold)
   ((font-lock-builtin-face &override) :foreground nano-salient)
   ((font-lock-type-face &override) :foreground nano-salient)
   ((font-lock-keyword-face &override) :foreground nano-salient :weight 'bold)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box nil :overline nil :underline nano-subtle)
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box nil :overline nil :underline nano-subtle)
   (mode-line-emphasis :foreground nano-strong :weight 'bold)

   (hl-line :background nano-hl)
   ((line-number &override) :foreground nano-faded)
   ((line-number-current-line &override) :foreground nano-strong)
   (shadow :foreground nano-faded)
   (tooltip :background nano-subtle :foreground nano-fg))
  ())

;;; doom-nano-light-theme.el ends here