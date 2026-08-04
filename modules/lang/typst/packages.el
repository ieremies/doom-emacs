;; -*- no-byte-compile: t; -*-
;;; lang/typst/packages.el

(package! typst-ts-mode :recipe (:host codeberg :repo "meow_king/typst-ts-mode"))

(when (modulep! +preview)
  (package! websocket)
  (package! typst-preview
    :recipe (:host github :repo "havarddj/typst-preview.el")))

(when (modulep! +org)
  (package! ox-typst
    :recipe (:host github :repo "jmpunkt/ox-typst"))
  (package! org-typst-preview
    :recipe (:host github :repo "remimimimimi/org-typst-preview.el")))
