;;; init.el -*- lexical-binding: t; -*-

(doom! :app
       ;; (rss +org)        ; emacs as an RSS reader

       :checkers
       syntax              ; TODO try with +childframe
       ;;(spell +flyspell) ; using Jinx
       ;;grammar           ; never got it to work. Textlint, proselint?

       :completion
       (corfu +orderless +icons +dabbrev)
       (vertico +childframe +icons)


       :editor
       (evil +everywhere)    ; vim-motion
       fold                  ; TODO try jamescherti/outline-indent.el or emacs-tree-sitter/treesit-fold
       (format +onsave) ;
       multiple-cursors      ;
       snippets              ;

       :emacs
       (dired +icons +dirvish) ;
       electric                ; keyword-based indent
       undo                    ; TODO try +tree
       ;; vc                   ; not sure what it does

       :email
       ;;(mu4e +org +gmail) ; TODO try!

       :lang
       (cc +lsp +tree-sitter)              ;
       emacs-lisp                          ; drown in parentheses
       (latex +fold +lsp)                  ; TODO install TexLab
       markdown                            ;
       (org +hugo +dragndrop +roam2)             ;
       (python +lsp +pyright +tree-sitter) ; TODO any uv integration? or ty?
       sh                                  ;
       (yaml +tree-sitter)                 ; JSON, but readable
       (typst +lsp +preview +org)

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS

       :tools
       biblio          ;
       ;; debugger        ; BUG trying to clone dape-mode
       (eval +overlay) ;
       llm             ;
       lookup          ;
       ;; (lsp +lsp +peek)   ; TODO ou um, ou outro!
       (lsp +eglot +booster)
       magit           ;
       tree-sitter     ;

       :ui
       ;;deft                ;
       doom                  ;
       doom-dashboard        ;
       hl-todo               ;
       ;;indent-guides       ;
       ;;ligatures           ;
       ;;modeline            ;
       nav-flash             ;
       ;;neotree             ;
       ophints               ;
       (popup +defaults)     ;
       (smooth-scroll +interpolate)      ;
       ;;tabs                ;
       (treemacs)            ;
       ;;(vc-gutter +pretty) ;
       ;;window-select       ;
       ;;workspaces          ;
       ;;zen                 ;

       :config
       literate
       (default +bindings +smartparens)
       )
