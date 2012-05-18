;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/outline.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/base")
  (require "xtal-mode/parser")
  )

(in-package :xtal-mode)

(export '(xtal-forward-statement
          xtal-backward-statement
          xtal-forward-statement-in-scope
          xtal-backward-statement-in-scope
          xtal-mark-statement
          xtal-transpose-statement
          xtal-up-statement
          xtal-down-statement
          ))

(defparameter *xtal-outline-regexp*
  (build-regexp :class *xtal-ident-regexp*
                :name *xtal-ident-regexp*
                :kinds '("class" "method" "fun")))

;;; cursor

(defun scan-xtal-syntax (pattern &rest keywords &key syntax)
  (cursor-moved?
    (save-current-point-only-if-fail
      (if (not syntax)
          (apply 'scan-buffer pattern keywords)
        (while (apply 'scan-buffer pattern keywords)
          (let ((data (match-data)))
            (when (eq (xtal-parse-point-syntax (point) :code) syntax)
              (store-match-data data)
              (return t))))))))

(defun scan-eos-forward ()
  (cursor-moved?
    (save-current-point-only-if-fail
      (while (scan-xtal-syntax "[;{}(]" :syntax :code :regexp t :tail t)
        (if (before-char= #\()
            (and (backward-char) (goto-matched-parenthesis))
          (return t))))))

(defun scan-eos-backward ()
  (cursor-moved?
    (save-current-point-only-if-fail
      (while (scan-xtal-syntax "[;{})]" :syntax :code :regexp t :reverse t :tail nil :no-dup t)
        (if (after-char= #\))
            (goto-matched-parenthesis)
          (return t))))))

(defun looking-eos-backward ()
  (looking-regexp-backward "[;{}]"))

(defun looking-eos-forward ()
  (looking-regexp-forward "[;{}]"))

(defmacro skip-for-eos (direction)
  `(xtal-skip-syntax ,direction :comment :block-parameter :white-spaces))

(defun xtal-current-scope-level ()
  (save-excursion
    (let (path)
      (while (scan-xtal-syntax "[{}]" :syntax :code :regexp t :reverse t :no-dup t :tail nil)
        (case (char-after (point))
          (#\} (or (goto-matched-parenthesis) (return)))
          (#\{ (push (point) path))))
      (values (length path) path))))

(defun xtal-forward-statement ()
  (interactive)
  (cursor-moved?
    (let ((opoint (point)))
      (skip-for-eos :backward)
      (when (not (or (bobp) (looking-eos-backward)))
        (scan-eos-forward))
      (loop
        (skip-for-eos :forward)
        (when (and (not (looking-eos-forward))
                   (not (eql opoint (point))))
          (return))
        (or (scan-eos-forward) (return))))))

(defun xtal-backward-statement ()
  (interactive)
  (cursor-moved?
    (skip-for-eos :backward)
    (when (bobp)
      (return-from cursor-moved?))
    (when (looking-eos-backward)
      (backward-char))
    (if (while (scan-eos-backward)
          (when (save-excursion
                  (forward-char)
                  (skip-for-eos :forward)
                  (not (looking-eos-forward)))
            (return t)))
        (forward-char)
      (goto-char (point-min)))
    (skip-for-eos :forward)))

(defun xtal-forward-statement-in-scope ()
  (interactive)
  (xtal-move-statement-in-scope 'xtal-forward-statement))

(defun xtal-backward-statement-in-scope ()
  (interactive)
  (xtal-move-statement-in-scope 'xtal-backward-statement))

(defun xtal-move-statement-in-scope (mover)
  (interactive)
  (cursor-moved?
    (save-current-point-only-if-fail
      (let ((scope (multiple-value-list (xtal-current-scope-level))))
        (while (funcall mover)
          (when (equal scope (multiple-value-list (xtal-current-scope-level)))
            (return t)))))))

(defun xtal-current-statement-points ()
  (save-excursion
    ;; goto start of statement
    (and
      (scan-eos-forward)
      (xtal-backward-statement))
    (let ((start (point)))
      (scan-eos-forward)
      (when (before-char= #\{)
        (backward-char)
        (goto-matched-parenthesis)
        (forward-char))
      (values start (point)))))

(defun xtal-mark-statement ()
  (interactive)
  (multiple-value-bind (start end)
      (xtal-current-statement-points)
    (goto-char end)
    (set-mark-command)
    (goto-char start)))

(defun xtal-transpose-statement ()
  (interactive)
  ;; 行頭・行末なら入れ替えずに移動するだけ
  (cond ((save-excursion (xtal-backward-statement) (bobp))
         (xtal-forward-statement-in-scope))
        ((save-excursion (xtal-forward-statement) (eobp))
         (xtal-backward-statement-in-scope))
        (t
         (xtal-transpose-statement0))))

(defun xtal-transpose-statement0 ()
  (flet ((stmt-points (fn)
           (funcall fn)
           (multiple-value-list (xtal-current-statement-points)))
         (content (points)
           (apply 'buffer-substring points))
         (delete-and-insert (points new-content)
           (apply 'delete-region points)
           (insert new-content)))
    (macrolet ((transpose-if-else-if (curr-content next-content)
                 `(let ((if (and (string-matchp "^if *(" ,curr-content) (match-string 0)))
                        (elseif (and (string-matchp "^else +if *(" ,next-content) (match-string 0))))
                    (when (and if elseif)
                      (setf ,curr-content (substitute-string ,curr-content "^if *(" elseif))
                      (setf ,next-content (substitute-string ,next-content "^else +if *(" if))))))
      (multiple-value-bind (curr next)
          (save-excursion
            (values (stmt-points 'xtal-backward-statement-in-scope)
                    (stmt-points 'xtal-forward-statement-in-scope)))
        (if (< (car curr) (point) (cadr curr))
            ;; 文と文の間ではないならデフォルトの transpose-sexps を呼ぶ
            (transpose-sexps)
          (unless (equal curr next)
            (let ((curr-content (content curr))
                  (next-content (content next)))
              ;; if と else if に関しては特別に入れ替え処理をする
              (transpose-if-else-if curr-content next-content)
              (delete-and-insert next curr-content)
              (delete-and-insert curr next-content)
              (goto-char (cadr next)))))))))

(defun xtal-up-statement ()
  (interactive)
  (multiple-value-bind (level path)
      (xtal-current-scope-level)
    (when path
      (goto-char (car (last path)))
      (xtal-backward-statement))))

(defun xtal-down-statement ()
  (interactive)
  (cursor-moved?
    (save-current-point-only-if-fail
      (multiple-value-bind (curr-level curr-path)
          (xtal-current-scope-level)
        (while (scan-xtal-syntax "[{;]" :syntax :code :regexp t :tail t)
          (multiple-value-bind (level path)
              (xtal-current-scope-level)
            (when (or (< level curr-level)
                      (not (equal curr-path (subseq path 0 curr-level))))
              (return nil))
            (when (< curr-level level)
              (skip-for-eos :forward)
              (return t))))))))


;;; parser

(defmacro outline-class-name (c)
  `(nth 0 ,c))

(defmacro outline-class-line-number (c)
  `(nth 0 (nth 1 ,c)))

(defmacro outline-class-points (c)
  `(nth 1 (nth 1 ,c)))

(defmacro outline-methods (c)
  `(nth 2 ,c))

(defmacro outline-method-name (m)
  `(nth 0 ,m))

(defmacro outline-method-visibility (m)
  `(nth 1 ,m))

(defmacro outline-method-kind (m)
  `(nth 2 ,m))

(defmacro outline-method-line-number (m)
  `(nth 3 ,m))

(defmacro outline-method-points (m)
  `(nth 4 ,m))

(defmacro scan-xtal-outline (&rest keywords)
  `(scan-buffer *xtal-outline-regexp* :regexp t ,@keywords))

(defun parse-xtal-outline (s e)
  (save-excursion
    (save-restriction
      (goto-char s)
      (narrow-to-region s e)
      (let* ((current-class :toplevel)
             (result))
        (while (scan-xtal-outline :tail nil :case-fold t)
          (do-events)
          (let ((visibility (match-string 1))
                (class (match-string 2))
                (name (match-string 3))
                (kind (match-string 4))
                (points `((:whole ,(cons (match-beginning 0) (match-end 0)))
                          (:name ,(cons (match-beginning 3) (match-end 3)))))
                (lineno (current-line-number))
                (end (match-end 0)))
            (if (string= kind "class")
                (progn
                  (setf current-class name)
                  (push (list name (list lineno points) nil) result))
              (progn
                (unless (assoc (or class current-class) result)
                  (push (list (or class current-class) nil nil) result))
                (push (list name
                            (parse-visibility visibility)
                            kind
                            lineno
                            points)
                      (outline-methods (assoc (or class current-class) result)))))
            (goto-char end)))
        (mapcar #'(lambda (e)
                    (list (car e) (cadr e) (reverse (caddr e))))
                (reverse result))))))

#+xtal-mode-debug
(defun user::xtal-parse-outline-debug ()
  (interactive)
  (msgbox "~S" (parse-xtal-outline (point-min) (point-max))))


;;; list-function

(defun xtal-build-summary-of-functions ()
  (let (result)
    (macrolet ((push-result (lineno name)
                 `(push (list ,lineno ,name) result)))
      (dolist (c (parse-xtal-outline (point-min) (point-max)))
        (let* ((class-name (outline-class-name c))
               (toplevel-p (eq class-name :toplevel))
               (pseudo-class-p (or (not (outline-class-points c))
                                   toplevel-p)))
          (unless pseudo-class-p
            (push-result (outline-class-line-number c) (outline-class-name c)))
          (dolist (m (outline-methods c))
            (push-result (outline-method-line-number m)
                         (if toplevel-p
                             (outline-method-name m)
                           (concat class-name "::" (outline-method-name m)))))))
      (unless result
        (error "クラスまたはメソッドがひとつもありません"))
      (sort (nreverse result)
            #'(lambda (a b)
                (< (car a) (car b)))))))

;;; tag

(defun xtal-maketags (file count)
  (macrolet ((gentag (name points)
               `(progn
                  (format t "~A~A~D" ,name file
                          (caadr (assoc :name ,points)))
                  (incf count))))
    (dolist (c (parse-xtal-outline (point-min) (point-max)))
      (when (outline-class-points c)
        (gentag (outline-class-name c) (outline-class-points c)))
      (dolist (m (outline-methods c))
        (gentag (outline-method-name m) (outline-method-points m))))
    count))

(defun tags-find-xtal-point (class name functionp point)
  (goto-char (- point *jump-tag-limit*))
  (and (scan-buffer (build-regexp :name (regexp-quote name)
                                  :class *xtal-ident-regexp*
                                  :kinds '("class" "method" "fun"))
                    :regexp t :limit (+ point ed::*jump-tag-limit*))
       (point)))

(pushnew '(xtal-maketags "*.xtal") *maketags-list* :key #'car)


(defun xtal-mode-setup-outline ()
  ;; forward|backward-paragraph で移動する段落位置
  (set-local-variable paragraph-start "^$\\|\f")
  (set-local-variable paragraph-separate paragraph-start)

  ;; tag
  (set-local-variable tags-find-target #'ed::tags-find-target-simple)
  (set-local-variable tags-find-point 'tags-find-xtal-point)

  ;; list-function
  (set-local-variable ed::build-summary-function 'xtal-build-summary-of-functions))


(provide "xtal-mode/outline")

;;;; End
