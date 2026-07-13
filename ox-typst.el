;;; ox-typst.el --- Typst Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Author: you
;; Version: 0.2.0
;; Keywords: org, export, typst
;; Package-Requires: ((emacs "28.1") (org "9.6"))

;;; Commentary:
;;
;; Exporter from Org Mode to Typst markup.
;; Covers the basic Typst markup elements:
;;   paragraphs, bold, italic, headings, bullet lists,
;;   numbered lists, term lists, raw/code, links, line-breaks,
;;   horizontal rules, plain text escaping, and math.
;;
;; Math assumption: the math content inside org fragments is already
;; written in Typst-compatible syntax.  The transcoder simply strips
;; the org delimiters ($…$, \(…\), \[…\]) and rewraps them in the
;; appropriate Typst delimiters ($…$ inline, $  …  $ display).
;;
;; Usage:
;;   M-x org-typst-export-to-typst   → write <file>.typ
;;   M-x org-typst-export-as-typst   → show result in a buffer
;;
;; TODO What is missing:
;; - Citations (`[cite:@key]`) → Typst `#cite(<key>)`
;; - Tables → Typst `#table(…)`
;; - Footnotes → Typst `#footnote[…]`
;; - Document metadata (`#+TITLE`, `#+AUTHOR`, `#+DATE`, `#+LANG`) → `#set doc(…)`
;; - Images (`[[file:img.png]]`) → `#image("…")` — currently falls
;;   through the link transcoder as a plain path
;; 
;; Missing from our transcoder alist:
;; - `drawer` — `:PROPERTIES:`, `:LOGBOOK:` etc. (usually suppressed)
;; - `property-drawer` — same family
;; - `clock` — `CLOCK:` lines from org-clock
;; - `planning` — `SCHEDULED:`, `DEADLINE:`, `CLOSED:` lines
;; - `node-property` — individual key/value inside a property drawer
;; - `diary-sexp` — date-based diary entries
;; - `inlinetask` — inline tasks (a niche but real feature)
;; 
;; Inline markup gaps:
;; - `superscript` / `subscript` — `x^2` and `x_i` in org become
;;   `#super[…]` / `#sub[…]` in Typst (and conflict with Typst's own
;;   math `^`/`_`)
;; - `entity` — org named entities like `\alpha`, `\nbsp` etc. need
;;    mapping to Typst equivalents
;; 
;; List nuances:
;; - `checkbox` items (`- [ ]`, `- [X]`) — no transcoder yet
;; 
;; Structural:
;; - `comment` / `comment-block` — should be suppressed or converted
;;   to Typst `//` / `/* */`
;; - `table-row` / `table-cell` — sub-elements of tables, need their
;;   own transcoders
;; - `verse-block` — `#+BEGIN_VERSE` has specific line-break semantics
;; - `center-block` — `#+BEGIN_CENTER` → `#align(center)[…]`
;; 
;; Export infrastructure:
;; - `#+INCLUDE` files — handled by org before the transcoder sees it,
;;   so actually free
;; - Selective export (`:noexport:` tags, `:EXPORT_FILE_NAME:`, etc.) —
;;   handled by ox core, also free
;; - Bibliography / reference list to go with citations
;; - A `:options-alist` entry for Typst-specific options (paper size,
;;   font, margins) that could be set via `#+TYPST_OPTIONS:`


;;; Code:

(require 'ox)
(require 'cl-lib)

;;; ---------------------------------------------------------------
;;; Helper – escape Typst special characters in plain text
;;; ---------------------------------------------------------------

(defconst ox-typst--special-chars
  ;; Characters that need a backslash escape in Typst markup mode.
  ;; Order matters: backslash first so we don't double-escape.
  '(("\\" . "\\\\")
    ("*"  . "\\*")
    ("_"  . "\\_")
    ("`"  . "\\`")
    ("$"  . "\\$")
    ("#"  . "\\#")
    ("@"  . "\\@")
    ("<"  . "\\<")
    (">"  . "\\>")
    ("~"  . "\\~"))
  "Alist of (ORIGINAL . ESCAPED) pairs for Typst plain-text mode.")

(defun ox-typst--escape (text)
  "Escape Typst special characters in TEXT."
  (seq-reduce (lambda (s pair)
                (string-replace (car pair) (cdr pair) s))
              ox-typst--special-chars
              text))


;;; ---------------------------------------------------------------
;;; Transcoders
;;; ---------------------------------------------------------------

;;;; Template

(defun ox-typst-template (contents _info)
  "Wrap exported CONTENTS in a minimal Typst document."
  ;; No special preamble needed for Typst; the file is valid as-is.
  contents)

;;;; Plain text

(defun ox-typst-plain-text (text _info)
  "Escape special Typst characters in plain TEXT."
  (ox-typst--escape text))

;;;; Paragraph

(defun ox-typst-paragraph (_paragraph contents _info)
  "Transcode a PARAGRAPH element into Typst.
CONTENTS holds its transcoded children."
  ;; Typst separates paragraphs with a blank line.
  (concat (string-trim-right contents) "\n"))

;;;; Section  (just pass through contents)

(defun ox-typst-section (_section contents _info)
  "Transcode a SECTION element – return CONTENTS unchanged."
  contents)

;;;; Headline → Typst heading (= H1, == H2, …)

(defun ox-typst-headline (headline contents info)
  "Transcode a HEADLINE element into Typst heading syntax.
CONTENTS holds transcoded body of the section."
  (let* ((level (org-export-get-relative-level headline info))
         (title (org-export-data (org-element-property :title headline) info))
         (prefix (make-string level ?=)))
    (concat prefix " " title "\n"
            (or contents ""))))

;;;; Bold → *strong*

(defun ox-typst-bold (_bold contents _info)
  "Transcode BOLD inline element."
  (concat "*" contents "*"))

;;;; Italic → _emphasis_

(defun ox-typst-italic (_italic contents _info)
  "Transcode ITALIC inline element."
  (concat "_" contents "_"))

;;;; Underline  (Typst has no native underline shorthand; use #underline[…])

(defun ox-typst-underline (_underline contents _info)
  "Transcode UNDERLINE inline element via Typst #underline function."
  (concat "#underline[" contents "]"))

;;;; Strike-through → #strike[…]

(defun ox-typst-strike-through (_strike contents _info)
  "Transcode STRIKE-THROUGH via Typst #strike function."
  (concat "#strike[" contents "]"))

;;;; Verbatim / Code (inline) → `…`

(defun ox-typst-verbatim (verbatim _contents _info)
  "Transcode inline VERBATIM element."
  (concat "`" (org-element-property :value verbatim) "`"))

(defun ox-typst-code (code _contents _info)
  "Transcode inline CODE element."
  (concat "`" (org-element-property :value code) "`"))

;;;; Src-block / Example-block → raw block

(defun ox-typst-src-block (src-block _contents _info)
  "Transcode a SRC-BLOCK element into a Typst raw block."
  (let ((lang  (org-element-property :language src-block))
        (value (org-element-property :value    src-block)))
    (if lang
        (format "```%s\n%s```\n" lang value)
      (format "```\n%s```\n" value))))

(defun ox-typst-example-block (example-block _contents _info)
  "Transcode an EXAMPLE-BLOCK element into a Typst raw block."
  (format "```\n%s```\n"
          (org-element-property :value example-block)))

;;;; Fixed-width (: lines)

(defun ox-typst-fixed-width (fixed-width _contents _info)
  "Transcode FIXED-WIDTH element."
  (format "```\n%s```\n"
          (org-element-property :value fixed-width)))

;;;; Plain list (bullet / numbered / description)

(defun ox-typst-plain-list (_plain-list contents _info)
  "Transcode a PLAIN-LIST element.
Since both `org-mode' and typst have similar requirements for list,
this simply returns CONTENTS."
  contents)

(defun ox-typst-item (item contents info)
  "Transcode an ITEM element into Typst list syntax.
Multi-line bodies and nested lists are indented to align under the
first character after the bullet marker."
  (let* ((list-type (org-element-property
                     :type (org-element-property :parent item)))
         (tag    (org-element-property :tag item))
         (bullet
          (pcase list-type
            ('ordered     "+ ")
            ('descriptive (concat "/ " (org-export-data tag info) ": "))
            (_            "- ")))
         (indent (make-string (length bullet) ?\s))
         (body   (string-trim-right (or contents "")))
         ;; Continuation lines must align under the first content char,
         ;; past the bullet, so Typst does not treat them as new items.
         (indented-body
          (replace-regexp-in-string "\n" (concat "\n" indent) body)))
    (concat bullet indented-body "\n")))

;;;; Link

(defun ox-typst-link (link desc _info)
  "Transcode a LINK element into Typst link syntax."
  (let* ((type (org-element-property :type link))
         (raw  (org-element-property :raw-link link))
         (path (org-element-property :path link))
         (label (if (org-string-nw-p desc) desc nil)))
    (cond
     ;; HTTP(S) links
     ((member type '("http" "https" "ftp"))
      (if label
          (format "#link(\"%s\")[%s]" raw label)
        (format "#link(\"%s\")" raw)))
     ;; Internal org id / custom-id / fuzzy → Typst @ref
     ((member type '("id" "custom-id" "fuzzy"))
      (format "@%s" path))
     ;; File links – just output the path
     ((string= type "file")
      (if label
          (format "#link(\"%s\")[%s]" path label)
        (format "#link(\"%s\")" path)))
     ;; Fallback
     (t (or label raw)))))

;;;; Target / Radio-target (become Typst labels)

(defun ox-typst-target (target _contents _info)
  "Transcode a TARGET element into a Typst label."
  (format "<%s>" (org-element-property :value target)))

;;;; Line-break → Typst \

(defun ox-typst-line-break (_lb _contents _info)
  "Transcode a LINE-BREAK element."
  "\\\n")

;;;; Horizontal rule → #line(length: 100%)

(defun ox-typst-horizontal-rule (_hr _contents _info)
  "Transcode a HORIZONTAL-RULE element."
  "#line(length: 100%)\n")

;;;; Quote-block → #quote[…]

(defun ox-typst-quote-block (_qb contents _info)
  "Transcode a QUOTE-BLOCK into Typst #quote."
  (format "#quote[\n%s]\n" contents))

;;;; Special-block (pass-through raw Typst)

(defun ox-typst-special-block (special-block contents _info)
  "Transcode a SPECIAL-BLOCK into a Typst function call #name[…].
The block type is lowercased to form the function name, so
#+begin_Prop … #+end_Prop becomes #prop[…].
The one exception is a block named \"typst\", whose contents are
inserted verbatim (raw passthrough)."
  (let ((name (downcase (org-element-property :type special-block))))
    (if (string= name "typst")
        (or contents "")
      (format "#%s[\n%s]\n" name contents))))

;;;; Export-block (#+BEGIN_EXPORT typst … #+END_EXPORT)

(defun ox-typst-export-block (export-block _contents _info)
  "Transcode an EXPORT-BLOCK: pass through only if backend is typst."
  (when (string= (upcase (org-element-property :type export-block)) "TYPST")
    (org-element-property :value export-block)))

;;;; Export-snippet (@@typst:…@@)

(defun ox-typst-export-snippet (export-snippet _contents _info)
  "Transcode an inline EXPORT-SNIPPET if it targets the typst backend."
  (when (string= (org-element-property :back-end export-snippet) "typst")
    (org-element-property :value export-snippet)))

;;;; Keyword (pass #+TYPST: lines verbatim)

(defun ox-typst-keyword (keyword _contents _info)
  "Transcode a KEYWORD element: pass #+TYPST: lines verbatim."
  (when (string= (org-element-property :key keyword) "TYPST")
    (org-element-property :value keyword)))

;;;; Math
;;
;; Org represents math in two ways:
;;
;;   Inline  – latex-fragment with value like "$x^2$" or "\(x^2\)"
;;   Display – latex-environment with value like "\[x^2\]" or a full
;;             \begin{equation}…\end{equation} block.
;;
;; Because we assume the inner math is already Typst-compatible we
;; only need to swap the delimiters.

(defun ox-typst--strip-math-delimiters (value)
  "Remove org/LaTeX math delimiters from VALUE, returning bare content.
Handles: $…$  $$…$$  \\(…\\)  \\[…\\]
and \\begin{<env>}…\\end{<env>} (equation, align, etc.)."
  (let ((v (string-trim value)))
    (cond
     ;; \(...\)  — inline
     ((string-match "\\`\\\\(\\(\\(?:.\\|\n\\)*\\)\\\\)\\'" v)
      (string-trim (match-string 1 v)))
     ;; \[...\]  — display
     ((string-match "\\`\\\\\\[\\(\\(?:.\\|\n\\)*\\)\\\\\\]\\'" v)
      (string-trim (match-string 1 v)))
     ;; $$...$$  — display (some org configs)
     ((string-match "\\`\\$\\$\\(\\(?:.\\|\n\\)*\\)\\$\\$\\'" v)
      (string-trim (match-string 1 v)))
     ;; $...$  — inline
     ((string-match "\\`\\$\\(\\(?:.\\|\n\\)*\\)\\$\\'" v)
      (string-trim (match-string 1 v)))
     ;; \begin{env}...\end{env}
     ((string-match
       "\\`\\\\begin{[^}]+}\\(\\(?:.\\|\n\\)*\\)\\\\end{[^}]+}\\'" v)
      (string-trim (match-string 1 v)))
     ;; Already bare (shouldn't normally happen, but be safe)
     (t v))))

(defun ox-typst-latex-fragment (latex-fragment _contents _info)
  "Transcode an inline LATEX-FRAGMENT into a Typst inline math span.
The inner content is assumed to be Typst-compatible already."
  (let* ((value (org-element-property :value latex-fragment))
         (inner (ox-typst--strip-math-delimiters value)))
    (format "$%s$" inner)))

(defun ox-typst-latex-environment (latex-environment _contents _info)
  "Transcode a LATEX-ENVIRONMENT into a Typst display math block.
The inner content is assumed to be Typst-compatible already."
  (let* ((value (org-element-property :value latex-environment))
         (inner (ox-typst--strip-math-delimiters value)))
    ;; Typst display math: surround with $ … $ on its own lines.
    (format "$\n  %s\n$\n" (string-trim inner))))


;;; ---------------------------------------------------------------
;;; Backend definition
;;; ---------------------------------------------------------------

(org-export-define-backend 'typst
  '((bold                . ox-typst-bold)
    (code                . ox-typst-code)
    (example-block       . ox-typst-example-block)
    (export-block        . ox-typst-export-block)
    (export-snippet      . ox-typst-export-snippet)
    (fixed-width         . ox-typst-fixed-width)
    (headline            . ox-typst-headline)
    (horizontal-rule     . ox-typst-horizontal-rule)
    (inline-src-block    . ox-typst-code)          ; reuse code transcoder
    (italic              . ox-typst-italic)
    (item                . ox-typst-item)
    (keyword             . ox-typst-keyword)
    (latex-environment   . ox-typst-latex-environment)
    (latex-fragment      . ox-typst-latex-fragment)
    (line-break          . ox-typst-line-break)
    (link                . ox-typst-link)
    (paragraph           . ox-typst-paragraph)
    (plain-list          . ox-typst-plain-list)
    (plain-text          . ox-typst-plain-text)
    (quote-block         . ox-typst-quote-block)
    (section             . ox-typst-section)
    (special-block       . ox-typst-special-block)
    (src-block           . ox-typst-src-block)
    (strike-through      . ox-typst-strike-through)
    (target              . ox-typst-target)
    (template            . ox-typst-template)
    (underline           . ox-typst-underline)
    (verbatim            . ox-typst-verbatim))

  :menu-entry
  '(?y "Export to Typst"
    ((?y "As .typ file"   ox-typst-export-to-typst)
     (?Y "As Typst buffer" ox-typst-export-as-typst))))


;;; ---------------------------------------------------------------
;;; Public entry points
;;; ---------------------------------------------------------------

;;;###autoload
(defun ox-typst-export-as-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current Org buffer to a Typst buffer.
Arguments ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY and EXT-PLIST
are as in `org-export-to-buffer'."
  (interactive)
  (org-export-to-buffer 'typst "*Org Typst Export*"
    async subtreep visible-only body-only ext-plist
    (lambda () (when (fboundp 'typst-mode) (typst-mode)))))

;;;###autoload
(defun ox-typst-export-to-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current Org buffer to a Typst file (.typ).
Arguments ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY and EXT-PLIST
are as in `org-export-to-file'."
  (interactive)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
      async subtreep visible-only body-only ext-plist)))

(provide 'ox-typst)
;;; ox-typst.el ends here
