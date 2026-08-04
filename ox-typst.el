;;; ox-typst.el --- Typst Back-End for Org Export Engine -*- lexical-binding: t; -*-

;;; Code:

(require 'ox)
(require 'org-element)

;; Variables

(defcustom org-typst-default-header nil
  "Specify the default Typst content before any other content."
  :type 'string
  :group 'org-export-typst)

;; Export
;; ((:filter-body . org-export-filter-body-functions)
;;  (:filter-bold . org-export-filter-bold-functions)
;;  (:filter-babel-call . org-export-filter-babel-call-functions)
;;  (:filter-center-block . org-export-filter-center-block-functions)
;;  (:filter-clock . org-export-filter-clock-functions)
;;  (:filter-code . org-export-filter-code-functions)
;;  (:filter-diary-sexp . org-export-filter-diary-sexp-functions)
;;  (:filter-drawer . org-export-filter-drawer-functions)
;;  (:filter-dynamic-block . org-export-filter-dynamic-block-functions)
;;  (:filter-entity . org-export-filter-entity-functions)
;;  (:filter-example-block . org-export-filter-example-block-functions)
;;  (:filter-export-block . org-export-filter-export-block-functions)
;;  (:filter-export-snippet . org-export-filter-export-snippet-functions)
;;  (:filter-final-output . org-export-filter-final-output-functions)
;;  (:filter-fixed-width . org-export-filter-fixed-width-functions)
;;  (:filter-footnote-definition . org-export-filter-footnote-definition-functions)
;;  (:filter-footnote-reference . org-export-filter-footnote-reference-functions)
;;  (:filter-headline . org-export-filter-headline-functions)
;;  (:filter-horizontal-rule . org-export-filter-horizontal-rule-functions)
;;  (:filter-inline-babel-call . org-export-filter-inline-babel-call-functions)
;;  (:filter-inline-src-block . org-export-filter-inline-src-block-functions)
;;  (:filter-inlinetask . org-export-filter-inlinetask-functions)
;;  (:filter-italic . org-export-filter-italic-functions)
;;  (:filter-item . org-export-filter-item-functions)
;;  (:filter-keyword . org-export-filter-keyword-functions)
;;  (:filter-latex-environment . org-export-filter-latex-environment-functions)
;;  (:filter-latex-fragment . org-export-filter-latex-fragment-functions)
;;  (:filter-line-break . org-export-filter-line-break-functions)
;;  (:filter-link . org-export-filter-link-functions)
;;  (:filter-node-property . org-export-filter-node-property-functions)
;;  (:filter-options . org-export-filter-options-functions)
;;  (:filter-paragraph . org-export-filter-paragraph-functions)
;;  (:filter-parse-tree . org-export-filter-parse-tree-functions)
;;  (:filter-plain-list . org-export-filter-plain-list-functions)
;;  (:filter-plain-text . org-export-filter-plain-text-functions)
;;  (:filter-planning . org-export-filter-planning-functions)
;;  (:filter-property-drawer . org-export-filter-property-drawer-functions)
;;  (:filter-quote-block . org-export-filter-quote-block-functions)
;;  (:filter-radio-target . org-export-filter-radio-target-functions)
;;  (:filter-section . org-export-filter-section-functions)
;;  (:filter-special-block . org-export-filter-special-block-functions)
;;  (:filter-src-block . org-export-filter-src-block-functions)
;;  (:filter-statistics-cookie . org-export-filter-statistics-cookie-functions)
;;  (:filter-strike-through . org-export-filter-strike-through-functions)
;;  (:filter-subscript . org-export-filter-subscript-functions)
;;  (:filter-superscript . org-export-filter-superscript-functions)
;;  (:filter-table . org-export-filter-table-functions)
;;  (:filter-table-cell . org-export-filter-table-cell-functions)
;;  (:filter-table-row . org-export-filter-table-row-functions)
;;  (:filter-target . org-export-filter-target-functions)
;;  (:filter-timestamp . org-export-filter-timestamp-functions)
;;  (:filter-underline . org-export-filter-underline-functions)
;;  (:filter-verbatim . org-export-filter-verbatim-functions)
;;  (:filter-verse-block . org-export-filter-verse-block-functions))
(org-export-define-backend 'typst
  '(
    (bold . org-typst-bold)
    (code . org-typst-code)
    (footnote-definition . org-typst-footnote-definition)
    (footnote-reference . org-typst-footnote-reference)
    (headline . org-typst-headline)
    (inline-src-block . org-typst-inline-src-block)
    (italic . org-typst-italic)
    (item . org-typst-item)
    (keyword . org-typst-keyword)
    (latex-environment . org-typst-latex-environment)
    (latex-fragment . org-typst-latex-fragment)
    (link . org-typst-link)
    (paragraph . org-typst-paragraph)
    (plain-list . org-typst-plain-list)
    (plain-text . org-typst-plain-text)
    (quote-block . org-typst-quote-block)
    (radio-target . org-typst-radio-target)
    (section . org-typst-section)
    (special-block . org-typst-special-block)
    (src-block . org-typst-src-block)
    (strike-through . org-typst-strike-through)
    (subscript . org-typst-subscript)
    (superscript . org-typst-superscript)
    (target . org-typst-target)
    (template . org-typst-template)
    (verbatim . org-typst-verbatim)
    (verse-block . org-typst-verse-block)
    )
  :menu-entry
  '(?y "Export to Typst"
    ((?F "As Typst buffer" org-typst-export-as-typst)
     (?f "As Typst file" org-typst-export-to-typst)
     (?p "As PDF file" org-typst-export-to-pdf)
     (?o "As PDF file and open"
	 (lambda (a s v b)
	   (if a (org-typst-export-to-pdf t s v b)
	     (org-open-file (org-typst-export-to-pdf nil s v b))))))))

;; Transpile
(defun org-typst-bold (_bold contents _info)
  (format "*%s*" contents))

(defun org-typst-code (code _contents info)
  (when-let* ((code-text (org-element-property :value code)))
    (org-typst--raw code-text code info)))

(defun org-typst-footnote-definition (footnote-definition contents _info)
  (format "#hide[#footnote[%s] #label(%s)]"
          (org-trim contents)
          (org-typst--as-string
           (org-element-property :label footnote-definition))))

(defun org-typst-footnote-reference (footnote-reference contents _info)
  (let ((label (org-element-property :label footnote-reference)))
    (pcase (org-element-property :type footnote-reference)
      ('standard (format "#footnote(label(%s))" (org-typst--as-string label)))
      ('inline (if label
                   (format "#footnote[%s] #label(%s)"
                           contents
                           (org-typst--as-string label))
                 (format "#footnote[%s]" contents)))
      (_ nil))))

(defun org-typst-headline (headline contents info)
  (when-let* ((level (org-export-get-relative-level headline info))
              (title (org-export-data (org-element-property :title headline)
                                      info))
              (label (org-typst--label nil headline info)))
    (concat
     (format "%s %s" (make-string level ?=) title)
     label
     "\n"
     contents)))

(defun org-typst-horizontal-rule (_horizontal-rule _contents _info)
  "#line(length: 100%)")

(defun org-typst-inline-src-block (inline-src-block _contents info)
  (when-let* ((code (org-element-property :value inline-src-block))
              (lang (org-element-property :language inline-src-block)))
    (org-typst--raw code inline-src-block info lang)))

(defun org-typst-italic (_italic contents _info)
  (format "_%s_" contents))

(defun org-typst-item (item contents info)
  (when-let* ((parent (org-export-get-parent item))
              (trimmed (org-trim (if (stringp contents) contents ""))))
    (pcase (org-element-property :type parent)
      ;; NOTE: unordered list items are all represented as single lists
      ('unordered trimmed)
      ('ordered (when-let* ((bullet-raw (org-element-property :bullet item)))
                  (when (string-match "\\([0-9]+\\)\." bullet-raw)
                    (format "enum.item(%s)[%s],"
                            (match-string 1 bullet-raw)
                            trimmed))))
      ('descriptive (when-let* ((raw-tag (org-element-property :tag item))
                                (tag (and raw-tag
                                          (org-export-data raw-tag info))))
                      (format "terms.item[%s][%s]," tag trimmed)))
      (_ nil))))

(defun org-typst-keyword (keyword _contents info)
  (let ((key (org-element-property :key keyword))
        (value (org-element-property :value keyword)))
    (cond
     ((string-equal key "TYPST") value)
     ((string-equal key "TYP") value)
     ((string-equal key "TOC")
      (cond
       ((string-match-p "\\<headlines\\>" value)
        (let* ((localp (string-match-p "\\<local\\>" value))
               (parent (org-element-lineage keyword 'headline))
               (level (if (not (and localp parent))
                          0
                        (org-export-get-relative-level parent info)))
               (depth
                (and (string-match "\\<[0-9]+\\>" value)
                     (+ (string-to-number (match-string 0 value)) level))))
          (if (and localp parent)
              (format "#context {
  let before = query(
    selector(heading).before(here(), inclusive: true),
  )
  let elm = before.pop()
  let after_elements = query(
    heading.where(outlined: true).after(here(), inclusive: true),
  )
  let next_maybe = after_elements.find(it => it.level <= elm.level)
  let next = if next_maybe == none {
    after_elements.pop()
  } else {
    next_maybe
  }
  outline(
    title: none,
    depth: %s,
    target: heading.where(outlined: true).after(
      elm.location(),
      inclusive: false,
    ).and(
      heading.where(outlined: true).before(
        next.location(),
        inclusive: next_maybe == none,
      ),
    ),
  )
}" (if depth depth "none"))
            (if depth
                (format "#outline(title: none, depth: %s)" depth)
              "#outline(title: none)"))))
       ((string-match-p "\\<figures\\>" value)
        "#outline(title: none, target: figure.where(kind: image))")
       ((string-match-p "\\<tables\\>" value)
        "#outline(title: none, target: figure.where(kind: table))")
       ((string-match-p "\\<listings\\>" value)
        "#outline(title: none, target: figure.where(kind: raw))"))))))

(defun org-typst-line-break (_line-break _contents _info)
  "#linebreak()\n")

(defun org-typst-link (link contents info)
  (let (;; NOTE: Typst is a bit picky about labels inside headlines. If we point
        ;; to an element inside a headline, we need to point to the headline
        ;; instead. Most of the time this is what you want, but it might not be
        ;; correct.
        (resolve-headline-friendly
         (lambda (target)
           (let ((parent (org-element-parent-element target)))
             (if (string= (org-element-type parent) "headline")
                 (org-export-get-reference parent info)
               (org-export-get-reference target info))))))
    (cond
     ((org-export-inline-image-p link org-typst-inline-image-rules)
      (org-typst--figure (format
                          "#image(%s)"
                          (org-typst--as-typst-path
                           (org-element-property
                            :path (org-export-link-localise link))))
                         link
                         info))
     ((equal (org-element-property :type link) "radio")
      (when-let* ((target (org-export-resolve-radio-link link info))
                  (ref (funcall resolve-headline-friendly target)))
        (format "#link(label(%s))[%s]"
                (org-typst--as-string ref)
                (org-trim contents))))
     ((member (org-element-property :type link) '("custom-id" "id" "fuzzy"))
      (let* ((target (org-export-resolve-link link info))
             (link-path (org-typst--as-string
                         (funcall resolve-headline-friendly target))))
        (if contents
            (format "#link(label(%s))[%s]" link-path (org-trim contents))
          (format "#ref(label(%s))" link-path))))
     ;; Other like HTTP (external)
     (t
      (let ((link-typst (org-typst--as-string (org-element-property :raw-link link))))
        (format "#link(%s)%s"
                link-typst
                (if contents
                    (format "[%s] #footnote(link(%s))"
                            (org-trim contents)
                            link-typst)
                  "")))))))

(defun org-typst-node-property (_node-property _contents _info)
  (message "// todo: org-typst-node-property"))

(defun org-typst-paragraph (_paragraph contents _info)
  contents)

(defun org-typst-plain-list (plain-list contents info)
  (pcase (org-element-property :type plain-list)
    ;; NOTE: use a single list with a marker instead of a list with
    ;;       list items
    ('unordered
     (mapconcat
      (lambda (item)
        (when (eq (car item) 'item)
          (let ((marker (cdr (assoc (org-element-property :checkbox item)
                                    org-typst-checkbox-symbols)))
                (item-content (org-trim (org-export-data item info))))
            (if marker
                (format "#list(marker: [%s], list.item[%s])"
                        marker
                        item-content)
              (format "#list(list.item[%s])" item-content)))))
      (cdr plain-list)))
    ('ordered (format "#enum(%s)" contents))
    ('descriptive (format "#terms(%s)" contents))
    (_ nil)))

(defun org-typst-plain-text (contents info)
  (let ((with-smart-quotes (plist-get info :with-smart-quotes))
        (output contents))
    (when with-smart-quotes
      (setq output (org-export-activate-smart-quotes output :typst info contents)))
    (org-typst--escape
     `("#" "$" "*" "/" "@" "<" ">" "_" "`" "+" "-"
       ,@(when (not with-smart-quotes)
           '("\"" "'")))
     output)))

(defun org-typst-planning (_planning _contents _info)
  (message "// todo: org-typst-planning"))

(defun org-typst-property-drawer (property-drawer contents info)
  (and (org-string-nw-p contents)
       (org-typst--raw contents property-drawer info)))

(defun org-typst-quote-block (quote-block contents info)
  (let ((attribution (org-export-read-attribute
                      :attr_typst
                      quote-block
                      :author)))
    (when contents
      (org-typst--figure
       (format "#quote(block: true%s)[%s]"
               (if attribution
                   (format ", attribution: %s"
                           (org-typst--as-string attribution))
                 "")
               contents)
       quote-block
       info))))

(defun org-typst-radio-target (radio-target text info)
  (org-typst--label text radio-target info))

(defun org-typst-section (_section contents _info)
  contents)

(defun org-typst-special-block (_special-block contents _info)
  contents)

(defun org-typst-src-block (src-block _contents info)
  (when-let* ((code (org-element-property :value src-block))
              (lang (org-element-property :language src-block)))
    (when (org-string-nw-p code)
      (org-typst--raw code src-block info lang t))))

(defun org-typst-statistics-cookie (_statistics-cookie _contents _info))

(defun org-typst-strike-through (_strike-through contents _info)
  (format "#strike[%s]" contents))

(defun org-typst-subscript (_subscript contents _info)
  (format "#sub[%s]" contents))

(defun org-typst-superscript (_superscript contents _info)
  (format "#super[%s]" contents))

(defun org-typst-target (target contents info)
  (org-typst--label contents target info))

(defun org-typst-template (contents info)
  (let ((title (plist-get info :title))
        (author (when (plist-get info :with-author)
                  (plist-get info :author)))
        (language (plist-get info :language))
        (email (when (plist-get info :with-email)
                 (plist-get info :email)))
        (toc (plist-get info :with-toc))
        (date (plist-get info :date))
        (typst-header (plist-get info :typst-header)))
    (concat
     (format "#let _ = ```typ
exec %s
⁠```\n" (org-typst--generate-command (plist-get info :input-file) t))
     (when (or (car title) author)
       (concat
        "#set document("
        (format "title: \"%s\"" (or (car title) ""))
        (when date (format ", date: %s" (string-trim-right (string-trim-left (org-typst-timestamp (car date) contents info) "#") ".display()")))
        (when author
          (or (when email
                (format ", author: \"<%s> %s\"" (car author) email))
              (format ", author: \"%s\"" (car author))))
        ")\n"))
     (when language (format "#set text(lang: \"%s\")\n" language))
     (when typst-header (format "%s\n" typst-header))
     (when toc "#outline()\n")
     (format "#set heading(numbering: %s)\n"
             (org-typst--as-string org-typst-heading-numbering))
     contents)))

(defun org-typst-timestamp (timestamp _contents _info)
  (let ((start (org-typst--timestamp timestamp nil))
        (end (org-typst--timestamp timestamp 1)))
    (if (and start end)
        (format "%s -- %s"  start end)
      (or start end))))

(defun org-typst-underline (_underline contents _info)
  (format "#underline[%s]" contents))

(defun org-typst-verbatim (verbatim _contents _info)
  (format "#raw(%s)"
          (org-typst--as-string (org-element-property :value verbatim))))

(defun org-typst-verse-block (verse-block contents info)
  (org-typst--raw contents verse-block info nil t))

(defun org-typst-latex-environment (latex-environment _contents _info)
  (when org-typst-from-latex-environment
    (funcall
     org-typst-from-latex-environment
     (org-element-property :value latex-environment))))

(defun org-typst-latex-fragment (latex-fragment _contents _info)
  (when org-typst-from-latex-fragment
    (funcall
     org-typst-from-latex-fragment
     (org-element-property :value latex-fragment))))


(defun org-typst--raw (content element info &optional raw-language block)
  "Wrap CONTENT in a raw Typst block.

If BLOCK is not nil, then content will additionally wrapped in a figure with the
arguments of ELEMENT and INFO.

RAW-LANGUAGE is the language of the code block and will be used as the
`language' argument in Typst."
  (when content
    (let* ((attributes (org-export-read-attribute :attr_typst element))
           (language (when raw-language (org-typst--language raw-language)))
           ;; TODO: maybe read the tab-size set by the mapped mode in Org?
           (tab-size (org-export-read-attribute :attr_typst element :tab-size))
           (engrave (org-export-read-attribute :attr_typst element :engrave))
           (theme (org-typst--attribute-value :theme attributes))
           (syntax (org-typst--attribute-value :syntaxes attributes))
           (theme-settings (when (and theme (not (equal theme 'none)))
                             (org-typst--xml-theme-global-settings (org-typst--xml-read-plist theme))))
           (raw (format "#raw(block: %s, %s)"
                        (if block "true" "false")
                        (concat
                         (when tab-size (concat "tab_size: " tab-size ", "))
                         (when language (concat "lang: "
                                                (org-typst--as-string language)
                                                ", "))
                         (when theme (concat "theme: " (org-typst--as-typst-path theme) ","))
                         (when syntax (concat "syntaxes: " (org-typst--as-typst-path syntax) ","))
                         (org-typst--as-string content)))))
      (if (and theme-settings org-typst-src-apply-theme-color)
          (let* ((fg (org-typst--xml-dict-get theme-settings "foreground"))
                 (bg (org-typst--xml-dict-get theme-settings "background"))
                 (bg-fmt (when bg (format "#block(fill: %s, inset: 4pt)" (org-typst--as-color (org-typst--xml-as-string bg)))))
                 (fg-fmt (when fg (format "#text(fill: %s)" (org-typst--as-color (org-typst--xml-as-string fg))))))
            (when fg (setq raw (concat fg-fmt "[" raw "]")))
            (when bg (setq raw (concat bg-fmt "[" raw "]")))))
      (let* ((major-mode-of-language (org-src-get-lang-mode language))
             (actual-code (if block
                              (org-typst--figure raw element info)
                            raw)))
        (if engrave
            (if (not major-mode-of-language)
                (error "Language `%s` does not map to any major mode, configure `org-src-lang-modes' accordingly" language)
              (format "#{ %s \n[%s] }" (org-typst--engrave-code content major-mode-of-language) actual-code))
          actual-code)))))

(defun org-typst--attribute-value (key attributes)
  "Return value of KEY in ATTRIBUTES.

If the value is empty, then the string \"none\" is returned.  Otherwise, the
value."
  (when (plist-member attributes key)
    (let ((value (plist-get attributes key)))
      (if (string-empty-p value)
          'none
        value))))

(defun org-typst--as-typst-path (file-path)
  "Convert existing FILE-PATH into Typst placeholder.

File paths are provided through the `--inputs' argument when compiling.  The
returned Typst expression acts as a placeholder and will be resolved by Typst
during compilation.  See `org-typst--common-paths' for the further details."
  (when file-path
    (if (equal file-path 'none)
        "none"
      (let ((idx (length org-typst--file-paths)))
        (push (list (format "file-%s" idx) file-path) org-typst--file-paths)
        (format "sys.inputs.file-%s" idx)))))

(defun org-typst--label (content item info)
  "Wrap ITEM and its CONTENT in a Typst label.

If ITEM is inside a headline or Org has no reference to it, then CONTENT is
returned without being wrapped.  All elements inside the headline are referenced
through the headline.

INFO is required to determine the reference of ITEM."
  (let ((label (or (org-export-get-reference item info)
                   (org-export-get-reference (org-element-parent item) info))))
    (if (and label
             (or (string= (org-element-type item) "headline")
                 (not (string= (org-element-type
                                (org-element-parent-element item))
                               "headline"))))
        (format "%s #label(%s)" (or content "") (org-typst--as-string label))
      content)))

(defun org-typst--figure (content element info)
  "Wrap ELEMENT and its CONTENT in a Typst figure.

Retrieves the caption from the ELEMENT itself or its parent.

INFO is required to determine the reference of ITEM."
  (let* ((raw (or (org-export-get-caption element)
                  (org-export-get-caption (org-element-parent-element
                                           element))))
         (caption (when raw
                    (mapconcat (lambda (e) (if (stringp e)
                                               e
                                             (org-export-data e info)))
                               raw)))
	 (label-element (if (string= (org-element-type element) "link")
			    (org-element-parent-element element)
			  element)))
    (org-typst--label
     (format "#figure([%s]%s)"
             content
             (if caption (format ", caption: [%s]" caption) ""))
     label-element
     info)))

(defun org-typst--escape (chars string)
  "Escape CHARS in STRING with corresponding Unicode.

The resulting string will contain a \\u{XXXX} for every char specified in CHARS."
  (seq-reduce (lambda (str char)
                (let ((code (string-to-char char)))
                  (replace-regexp-in-string (rx-to-string code)
                                            (format "\\\\u{%x}" code)
                                            str)))
              chars
              string))

(defun org-typst--as-string (string &optional no-trim)
  "Construct Typst string with content STRING.

The STRING will escape every occurrence of `\"'.  Normally the STRING is
trimmed, but can be disabled with NO-TRIM.  If STRING is the symbol `none', then
the Typst value for `none' is returned."
  (when string
    (if (equal string 'none)        "none"
      (let* ((actual-string (cond ((stringp string) string)
                                  ((symbolp string) (symbol-name string))
                                  (t (error "Unsupported type %s of %s" (type-of string) string))))
             (escaped (org-typst--escape '("\"") actual-string)))
        (concat "\""
                (if no-trim
                    escaped
                  (org-trim escaped))
                "\"")))))

(defun org-typst--language (language)
  "Map Org LANGUAGE to Typst language for source blocks.

The user can define the mapping `org-typst-language-mapping', to rename the
languages.  If the language is not defined in the mapping, then it is
returned.  Otherwise, the mapped language is returned."
  (or
   (cdr (seq-find (lambda (pl) (string-equal (car pl) language))
                  org-typst-language-mapping))
   language))

(defun org-typst--timestamp (timestamp end)
  "Construct Typst timestamp from TIMESTAMP.

Setting END to non-nil extracts the end range of the timestamp.  Otherwise, the
start range of the timestamp is extracted."
  (when-let* ((year (org-element-property
                     (when end :year-end :year-start)
                     timestamp))
              (month (org-element-property
                      (when end :month-end :month-start)
                      timestamp))
              (day (org-element-property
                    (when end :day-end :day-start)
                    timestamp)))
    (if (org-timestamp-has-time-p timestamp)
        (when-let* ((hour (org-element-property (when end :hour-end :hour-start)
                                                timestamp))
                    (minute (org-element-property (when end
                                                    :minute-end :minute-start)
                                                  timestamp)))
          (format "#datetime(year: %s, month: %s, day: %s, hour: %s, minute: %s, second: 0).display()"
                  year
                  month
                  day
                  hour
                  minute))
      (format "#datetime(year: %s, month: %s, day: %s).display()"
              year
              month
              day))))

(defun org-typst--as-cite-form (style)
  "Convert STYLE from Emacs citation style to Typst form.

Possible types are either strings which are supported by Typst or the `none'
symbol.  See the Typst documentation for the supported values."
  (pcase style
    ("text" "prose")
    ("author" "author")
    ("noauthor" "year")
    ("nocite" 'none)
    (s (warn "Citation style '%s' doesn't have an equivalent in Typst; using 'normal'." s) "normal")))

(defun org-typst--common-paths (dir)
  "Calculate the common prefix of all used files starting from DIR.

The common prefix and a list of all files with relative paths (to the prefix) is
returned.  Files which are used by Org might be located outside of the project
root.  We have to find the longest or common prefix of all use files.  This
prefix will become the new project root allowing all files to be found by Typst."
  (let* ((absolute-paths (seq-map (lambda (tuple)
                                    (seq-let (key path) tuple
                                      (list key (expand-file-name path))))
                                  org-typst--file-paths))
         (longest-prefix (seq-reduce
                          (lambda (prefix tuple)
                            (seq-let (_ path) tuple
                              (fill-common-string-prefix prefix path)))
                          absolute-paths
                          (file-name-as-directory (expand-file-name dir)))))

    (list
     longest-prefix
     (seq-map (lambda (tuple)
                (seq-let (key path) tuple
                  (list key (file-relative-name path longest-prefix))))
              absolute-paths))))

(defun org-typst-from-latex-with-pandoc (latex-fragment)
  "Convert a LATEX-FRAGMENT into a Typst expression using Pandoc."
  (with-temp-buffer
    (insert latex-fragment)
    (call-shell-region
     (point-min)
     (point-max)
     "pandoc -f latex -t typst -"
     t
     (current-buffer))
    (string-trim-right
     (buffer-substring-no-properties (point-min) (point-max)))))

(defun org-typst-from-latex-with-naive (latex-fragment)
  "Convert a LATEX-FRAGMENT into Typst code.

This approach is very naive and assumes that the provided LaTeX fragment has the
same inner syntax as Typst.  For more complex fragments, use a different
converter.

The advantage of this convert is the availability in Emacs without additional
dependencies.  Other converts rely on external dependencies."
  (cond
   ((string-match-p "^[ \t]*\$.*\$[ \t]*$" latex-fragment) latex-fragment)
   ((string-match-p "^[ \t]*\\\\(.*\\\\)[ \t]*$" latex-fragment)
    (replace-regexp-in-string "\\\\)[ \t]*$" "$"
                              (replace-regexp-in-string "^[ \t]*\\\\("
                                                        "$"
                                                        latex-fragment)))
   ((string-match-p "^[ \t]*\\\\\\[.*\\\\\\][ \t]*$" latex-fragment)
    (replace-regexp-in-string
     "\\\\\\][ \t]*$" "$"
     (replace-regexp-in-string "^[ \t]*\\\\\\[" "$" latex-fragment)))))

;; Commands
;;;###autoload
(defun org-typst-export-as-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Typst buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org Typst Export*\", which will be displayed
when `org-export-show-temporary-export-buffer' is non-nil.  The resulting buffer
will use the major mode specified by `org-typst-export-buffer-major-mode'."
  (interactive)
  (setq org-typst--file-paths nil)
  (org-export-to-buffer 'typst org-typst-export-buffer-name
    async subtreep visible-only body-only ext-plist
    (when org-typst-export-buffer-major-mode
      (if (fboundp 'major-mode-remap)
          (major-mode-remap
           org-typst-export-buffer-major-mode)
        org-typst-export-buffer-major-mode))))

;;;###autoload
(defun org-typst-export-to-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export Org-buffer to Typst.

If narrowing is active in the current buffer, only export its narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at point,
extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of hidden
elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external parameters overriding
Org default settings, but still inferior to file-local settings."
  (interactive)
  (setq org-typst--file-paths nil)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
      async subtreep visible-only body-only ext-plist)))

;;;###autoload
(defun org-typst-export-to-pdf
    (&optional async subtreep visible-only body-only ext-plist)
  "Export Org-buffer as PDF using Typst.

If narrowing is active in the current buffer, only export its narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at point,
extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of hidden
elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external parameters overriding
Org default settings, but still inferior to file-local settings.

Return PDF file's name."
  (interactive)
  (setq org-typst--file-paths nil)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
      async subtreep visible-only body-only ext-plist
      #'org-typst-compile)))

(defun org-typst--generate-command (typst-file &optional no-input)
  "Create compile command for TYPST-FILE."
  (let* ((typst-file-absolute (expand-file-name typst-file))
         (typst-file-dir (file-name-parent-directory typst-file-absolute))
         (prefix-files (org-typst--common-paths typst-file-dir))
         (typst-root-new (car prefix-files))
         (relative-position-to-root (file-relative-name
                                     typst-root-new typst-file-dir)))
    (concat (format org-typst-process (if no-input "$0" typst-file-absolute))
            (unless (string-match-p "--root" org-typst-process)
              (format " --root \"%s\""
                      (if no-input
                          (format "$(readlink -f \"$0\" | xargs dirname)/%s"
                                  relative-position-to-root)
                        typst-root-new)))
            (apply #'concat
                   (seq-map
                    (lambda (tuple)
                      (seq-let (key path) tuple
                        (concat " --input "
                                (format "%s=/%s"
                                        (shell-quote-argument key)
                                        (shell-quote-argument path)))))
                    (cadr prefix-files))))))

(defun org-typst-compile (typst-file)
  "Compile TYPST-FILE into PDF.

TYPST-FILE is the name of the file being compiled.  The Typst command for the
compilation is controlled by `org-typst-process'.  Output of the compilation
process is redirected to \"*Org PDF Typst Output*\" buffer.

Return PDF file name or raise an error if it couldn't be produced."
  (let* ((log-buf-name "*Org PDF Typst Output*")
         (log-buf (get-buffer-create log-buf-name))
         (process (org-typst--generate-command typst-file))
         outfile)
    (with-current-buffer log-buf
      (erase-buffer))
    (setq outfile (org-compile-file (expand-file-name typst-file)
                                    (list process)
                                    "pdf"
                                    (format "See %S for details" log-buf-name)
                                    log-buf
                                    nil))
    outfile))

;; Citation Exporter
(defun org-typst-export-bibliography (_keys files style properties _backend _com)
  (let ((title (plist-get properties :title)))
    (format "#bibliography(%s%s(%s))"
            (and style (format "style: \"%s\", " style))
            (if title (format "title: %s, " (org-typst--as-string title)) "")
            (mapconcat (lambda (f) (org-typst--as-typst-path f))
                       files
                       ", "))))

(defun org-typst-export-citation (citation style _ _info)
  (mapconcat (lambda (r)
               (format "#cite(label(%s)%s%s)"
                       (org-typst--as-string (org-element-property :key r))
                       (or (when-let* ((supplement (org-element-property :suffix r)))
                             (format ", supplement: %s"
                                     (org-typst--as-string (car supplement))))
                           "")
                       (or (and (car style)
                                (format ", form: %s"
                                        (org-typst--as-string (org-typst--as-cite-form (car style)))))
                           "")))
             (org-cite-get-references citation)))

;; Register `typst' processor
(org-cite-register-processor 'typst
  :export-bibliography #'org-typst-export-bibliography
  :export-citation #'org-typst-export-citation)

(provide 'ox-typst)
;;; ox-typst.el ends here
