;; ox-marimo.el --- Marimo Markdown Backend for Org Export Engine -*- lexical-binding: t; -*-
;; Code:
(org-export-define-derived-backend 'marimo 'md
  :menu-entry
  '(?M "Export to Marimo-Markdown"
    ((?M "To temporary buffer"
         (lambda (a s v b) (org-marimo-export-as-markdown a s v)))
     (?m "To file" (lambda (a s v b) (org-marimo-export-to-markdown a s v)))
     (?o "To file and open"
         (lambda (a s v b)
           (if a (org-marimo-export-to-markdown t s v)
             (org-open-file (org-marimo-export-to-markdown nil s v)))))))
  :translate-alist
  '((template . org-marimo-template)
    (paragraph . org-marimo-paragraph)
    (src-block . org-marimo-code-cell)))

(defun org-marimo-template (contents _info)
  (concat
   "```python {.marimo hide_code=\"true\"}\nimport marimo as mo\n```\n"
   contents))

(defun org-marimo-paragraph (_paragraph contents _info)
  (concat contents "\n<!---->"))

(defun org-marimo-code-cell (src-code contents info)
  (let* ((lang (org-element-property :language src-code))
         (params (org-element-property :parameters src-code))
         (formatted-params (if (and params (string-prefix-p ":" params))
                               (format "{.%s}" (substring params 1))
                             "")))
    (format "```%s %s\n%s```"
            lang
            formatted-params
            (org-remove-indentation
             (org-export-format-code-default src-code info)))))

(defun org-marimo-convert (mdfile)
  (let ((outfile (concat (file-name-sans-extension mdfile) ".py")))
    (org-compile-file mdfile (concat "marimo convert %f -o " outfile) "py")))

;;;###autoload
(defun org-marimo-export-as-markdown (&optional async subtreep visible-only)
  (interactive)
  (org-export-to-buffer 'marimo "*Org MarimoMD Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-marimo-export-to-markdown
    (&optional async subtreep visible-only body-only ext-plits)
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'marimo outfile
      async subtreep visible-only body-only ext-plist
      #'org-marimo-convert)))
