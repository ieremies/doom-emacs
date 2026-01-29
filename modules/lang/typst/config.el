;;; lang/typst/config.el -*- lexical-binding: t; -*-

;;
;; Packages
(use-package typst-ts-mode
  :custom
  (typst-ts-watch-options "--open")
  ;; (typst-ts-mode-grammar-location (expand-file-name "tree-sitter/libtree-sitter-typst.so" user-emacs-directory))
  (typst-ts-mode-enable-raw-blocks-highlight t)
  :config
  ;; Register `.typ' as typst-ts-mode file type
  (add-to-list 'auto-mode-alist '("\\.typ\\'" . typst-ts-mode))

  ;; TODO keymap the typst-ts-tmenu
  (keymap-set typst-ts-mode-map "C-c C-c" #'typst-ts-tmenu)

  ;; HACK this shouldn't be here!
  (set-face-attribute 'typst-ts-markup-label-face nil
                      :foreground "#4aaab2")
  (set-face-attribute 'typst-ts-markup-reference-face nil
                      :foreground "#4aaab2"))

;; Faces that does not makes sense to spellcheck
(after! jinx
  (add-to-list 'jinx-exclude-faces
               '(typst-ts-mode
                 font-lock-function-name-face
                 font-lock-function-call-face
                 font-lock-variable-use-face
                 font-lock-keyword-face
                 font-lock-punctuation-face
                 font-lock-string-face
                 font-lock-constant-face
                 font-lock-name-face
                 font-lock-operator-face
                 font-lock-comment-face
                 typst-ts-code-indicator-face
                 typst-ts-markup-label-face)))

;; "Code" faces in typst
(after! mixed-pitch
  (dolist (face '(font-lock-function-name-face
                  font-lock-function-call-face
                  font-lock-variable-use-face
                  font-lock-keyword-face
                  font-lock-punctuation-face
                  font-lock-string-face
                  font-lock-constant-face
                  font-lock-name-face
                  font-lock-operator-face
                  font-lock-comment-face
                  typst-ts-code-indicator-face
                  typst-ts-markup-label-face))
    (add-to-list 'mixed-pitch-fixed-pitch-faces face)))

;; LSP configuration
(when (modulep! +lsp)

  ;; lsp-mode configuration
  (when (modulep! :tools lsp -eglot)
    (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection '("typst-lsp"))
      :major-modes '(typst-ts-mode)
      :language-id "typst"
      :server-id "typst-lsp")))

  ;; Eglot configuration
  (when (modulep! :tools lsp +eglot)
    (set-eglot-client! 'typst-ts-mode '("tinymist"))))

(use-package! typst-preview
  :when (modulep! +preview)
  :config
  (setq typst-preview-browser "default")
  ;; TODO typst keybind map
  (define-key typst-preview-mode-map (kbd "C-c C-j") 'typst-preview-send-position))

(use-package ox-typst
  :when (modulep! +org)
  :after org
  :config
  (setq org-typst-from-latex-environment #'org-typst-from-latex-with-naive
        org-typst-from-latex-fragment    #'org-typst-from-latex-with-naive))
