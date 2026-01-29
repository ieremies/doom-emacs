;;; vertico-move-aside.el -*- lexical-binding: t; -*-

(require 'vertico)
(require 'posframe)
(require 'vertico-posframe)

(defface vertico-posframe-dim-face
  '((t (:foreground "gray40")))
  "Face for whole window background when posframe is active.")

(setq vertico-posframe-aside-rules
      '("find-file"
        "consult-line"
        "consult-imenu"
        "consult-eglot-symbols"
        "project-find-regexp"
        "consult-yank"
        "xref"))

(defun vertico-posframe--rules-match-p (rules)
  "Tests whether current command or buffer matches one of the RULES."
  (cl-some
   (lambda (rule)
     (cond ((functionp rule)
            (funcall rule))
           ((and rule
                 (stringp rule)
                 (symbolp this-command))
            (string-match-p rule (symbol-name this-command)))
           ((symbolp rule)
            (symbol-value rule))
           (t nil)))
   rules))

(setq vertico-posframe--overlays-back nil)

(defun vertico-posframe--add-overlays ()
  "Create a dim background overlay for each window on WND-LIST."
  (let* ((wnd (minibuffer-selected-window))
         (windows (window-list (window-frame wnd) 0))
         (windows-to-dim
          (if (vertico-posframe--rules-match-p vertico-posframe-aside-rules)
              (--select (not (eq it wnd)) windows)
            windows)))
    (setq vertico-posframe--overlays-back
          (append
           vertico-posframe--overlays-back
           (mapcar (lambda (w)
                     (let ((ol (make-overlay
                                (window-start w)
                                (window-end w)
                                (window-buffer w))))
                       (overlay-put ol 'face 'aw-background-face)
                       ol))
                   windows-to-dim)))))

(defun vertico-posframe--remove-overlays ()
  (mapc #'delete-overlay vertico-posframe--overlays-back)
  (setq vertico-posframe--overlays-back nil))

(advice-add 'vertico-posframe--setup :after #'vertico-posframe--add-overlays)
(advice-add 'vertico-posframe--minibuffer-exit-hook :after #'vertico-posframe--remove-overlays)

(defun lazy/posframe-poshandler-besides-selected-window (info)
  (let* ((window-left (plist-get info :parent-window-left))
         (window-width (plist-get info :parent-window-width))
         (window-right (+ window-left window-width))
         (frame-width (plist-get info :parent-frame-width))
         (frame-height (plist-get info :parent-frame-height))
         (posframe-width (plist-get info :posframe-width))
         (posframe-height (plist-get info :posframe-height))
         (space-left window-left)
         (space-right (- frame-width window-right))
         (space-inside (- window-width posframe-width))
         (wanted-top (/ (- frame-height posframe-height) 2)))
    (cond
     ((>= space-right posframe-width)
      (cons window-right wanted-top))
     ((>= space-left posframe-width)
      (cons (- window-left posframe-width) wanted-top))
     ((>= space-inside posframe-width)
      (cons (- window-right posframe-width) wanted-top))
     (t
      (posframe-poshandler-frame-center info)))))
(setq vertico-posframe-poshandler #'lazy/posframe-poshandler-besides-selected-window)
(defun lazy/vertico-posframe-get-size ()
  "The default functon used by `vertico-posframe-size-function'."
  (let ((width (- (round (* (frame-width) 0.5)) 2))
        (height (or vertico-posframe-min-height
                    (let ((height1 (+ vertico-count 1)))
                      (min height1 (or vertico-posframe-height height1))))))
    (list
     :height height
     :width width
     :min-height height
     :min-width width
     :max-height height
     :max-width width)))
(setq vertico-posframe-size-function #'lazy/vertico-posframe-get-size)
