;; Packages
(use-package typst-ts-mode
  :mode "\\.typ\\'"
  :custom
  (typst-ts-watch-options "--open")
  (typst-ts-mode-enable-raw-blocks-highlight t)

  :config
  (keymap-set typst-ts-mode-map "C-c C-c" #'typst-ts-tmenu)

  ;; HACK this shouldn't be here!
  (set-face-attribute 'typst-ts-markup-label-face nil
                      :foreground "#4aaab2")
  (set-face-attribute 'typst-ts-markup-reference-face nil
                      :foreground "#4aaab2"))

;; Faces that does not makes sense to spellcheck
(after! jinx
  (add-to-list
   'jinx-exclude-faces
   '(typst-ts-mode
     ;; not included font lock faces
     ;; `font-lock-comment-face', `font-lock-string-face', `font-lock-doc-face'
     ;; `font-lock-doc-markup-face'
     font-lock-warning-face font-lock-function-name-face font-lock-function-call-face
     font-lock-variable-name-face font-lock-variable-use-face font-lock-keyword-face
     font-lock-comment-delimiter-face font-lock-type-face font-lock-constant-face
     font-lock-builtin-face font-lock-preprocessor-face
     font-lock-negation-char-face font-lock-escape-face font-lock-number-face
     font-lock-operator-face font-lock-property-use-face font-lock-punctuation-face
     font-lock-bracket-face font-lock-delimiter-face font-lock-misc-punctuation-face
     ;; typst-ts-mode created faces
     typst-ts-markup-item-indicator-face typst-ts-markup-term-indicator-face
     typst-ts-markup-rawspan-indicator-face typst-ts-markup-rawspan-blob-face
     typst-ts-markup-rawblock-indicator-face typst-ts-markup-rawblock-lang-face
     typst-ts-markup-rawblock-blob-face
     typst-ts-error-face typst-ts-shorthand-face typst-ts-markup-linebreak-face
     typst-ts-markup-quote-face typst-ts-markup-url-face typst-ts-math-indicator-face)))

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

;; Consult integration
;; (after! consult
;;   (setq
;;    consult-imenu-config
;;    (append consult-imenu-config
;;            '((typst-ts-mode :topLevel "Headings" :types
;;               ((?h "Headings" typst-ts-markup-header-face)
;;                (?f "Functions" font-lock-function-name-face)))))))

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
    (after! eglot
      (set-eglot-client! 'typst-ts-mode '("tinymist"))
      ;; TODO check https://myriad-dreamin.github.io/tinymist/config/neovim.html
      (setq-default eglot-workspace-configuration
                    '(:tinymist (:exportPdf "onSave")))
      (add-hook 'typst-ts-mode-hook #'lsp! 'append))))


;;   (when (modulep! +lsp)
;;    (add-hook (intern (format "%s-local-vars-hook" mode)) #'lsp! 'append)))


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

;; (use-package! tip)
