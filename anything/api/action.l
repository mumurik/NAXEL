;;; -*- Mode: Lisp -*-
;;  action:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       action is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(defun anything-get-init(init)
  (cond((and(eq 'symbol (type-of init))
            (fboundp init))(funcall init))
       ((functionp init)(funcall init))
       ((and(ignore-errors(consp init))
            (eq 'lambda (car init)))
        (funcall(eval init)))
       ((ignore-errors(consp init))(eval init))
       (t init)
       ))

(defun anything-get-sources()
  (unless *anything-get-sources*
    (flet((psh(st ls v)
            (push (lambda()(cons (anything-name st)
                                 (cond(v (funcall ls v))
                                      (t (funcall ls)))))
                  *anything-get-sources*
                  )))
      (maphash
       #'(lambda(x y)
           (let((init (anything-init y))
                (candidate (anything-candidates y))
                (visible (anything-visible-mode y)))
             (and init (setq init (anything-get-init init)))
             (and(or(eql buffer-mode visible)
                    (and(consp visible)(find buffer-mode visible))
                    (not visible))
                 (start-timer .01 #'(lambda()(psh y candidate init)) t)
                 ; (incf i 0.01)
                 )))
       *anything-sources*))
    (sleep-for .02)
    ))

(defun anything-update-sources(input)
  (setq *anything-update-sources* (make-hash-table :test 'equal))
  (let((query (or(and *anything-migemo-on* (modulep "migemo")
                      (<= *anything-migemo-length* (length input))
                      (compile-regexp (ed::migemo-query input) t))
                 (regexp-quote input))))
    (dolist(x *anything-get-sources*)
      (let((y (funcall x)))     ; lazy
        (setf(gethash (car y) *anything-update-sources*)
             (if (zerop (length input))
                 (cdr y)
               (remove-if-not #'(lambda(str)(string-matchp query str))
                              (cdr y)))))))
  *anything-update-sources*)

(defun anything-exhibit-sources(input)
  (let((p-list)(first))
    (setq *category-point-list* nil)
    (with-selected-window
      (with-output-to-simple-temp-buffer
       (*anything-buffer*
        *anything-buffer-popup*
        *anything-buffer-vert*)
       (turn-read-only
        (maphash (lambda(name source)
                   (when source
                     (let(p l)
                       (push (b-point) p)
                       (princ(concat "[ " name " ]"))
                       (push (b-point) p)
                       (set-source-name-color p)
                       (terpri)
                       ; omit
                       (and(or(not first)
                              (string= (apply 'buffer-substring p)
                                       (gethash *anything-sources* *anything-source-history*))
                              (format t "~{~A~%~}~%"
                                      (subseq source 0
                                              (if (<= (setq l (length source))
                                                      *category-length*)
                                                  l *category-length*))))
                           (format t "~{~A~%~}~%" source))
                       (push (b-point) p)
                       (push (nreverse p) p-list)
                       (setq first t)
                       )))
                 (anything-update-sources input))
        )))
    (setq *category-point-list* (sort p-list #'< :key 'car))
    ))

(defun anything-check-minibuffer-input()
  (set-window (minibuffer-window))
  (buffer-substring (point-min) (point-max)))

;; select line
(defun anything-selection()
  (delete-text-attributes 'any)
  (let((beg (save-excursion(goto-bol)(point)))
       (end (save-excursion(goto-eol)(point))))
    (apply 'set-text-attribute beg end 'any
           *anything-select-color*) ; option
    (buffer-substring beg end)))

(defun anything-moved-action()
  (anything-name-search)
  (let*((src (gethash (cdr *anything-selection*) *anything-sources*))
        (move (and src (anything-move-action src))))
    (through(and move (funcall move (car *anything-selection*)))))
  (refresh-screen))

(defun anything-default-exhibit(input)
  (anything-exhibit-sources input)
  (with-anything-window
   (unless(and *anything-attribute-buffer* *anything-selected-source*)
     (and (gethash *anything-sources* *anything-source-history*)
          (scan-buffer (gethash *anything-sources* *anything-source-history*)
                       :no-dup t)
          (recenter 0))
     (forward-line))
   (anything-moved-action)))

(defun anything-name-search() ;fix
  (with-anything-window
   (if (and *anything-attribute-buffer* (not *anything-selected-source*))
       (setq *anything-selected-source* (car *anything-selection*))
     (get-category (point)))
   (setq *anything-selection* (cons (anything-selection)
                                    (get-category-contents 1)))))

(defun anything-type-or-action()
  (maphash
   #'(lambda(x y)
       (let((action (anything-action y))
            (type (anything-type y)))
         (when (string= (cdr *anything-selection*)(anything-name y))
           (cond(action
                 (return-from anything-type-or-action
                   (if (and(atom action)
                           (fboundp action))
                       (cons 'action action) ; function
                     (cons 'action (eval action))) ;lambda
                   ))
                (type
                 (return-from anything-type-or-action (cons 'type type)))
                )
           )))
   *anything-sources*))

(defun anything-type-exhibit(type)
  (unless *anything-attribute-buffer*
    (setq *anything-attribute-buffer* t)
    (let((attr))
      (maphash #'(lambda(name struct)
                   (if (eq type (anything-attribute-type struct))
                       (push name attr)))
               *anything-type-attributes*)
      (with-selected-window
        (with-output-to-simple-temp-buffer
         (*anything-buffer*
          *anything-buffer-popup*
          *anything-buffer-vert*)
         (turn-read-only
          (format t "~{~A~%~}" (sort attr 'string-greaterp)))
         (anything-selection)
         ))
      )))

(defun anything-attribute-get-action()
  (when(and *anything-attribute-buffer*
            *anything-selected-source*)
    (setq *anything-execute-select-action*
          (list (anything-attribute-action
                 (gethash (car *anything-selection*)
                          *anything-type-attributes*))
                *anything-selected-source*))))

(defun anything-attribute-default-action(type)
  (maphash
   #'(lambda(name attr)
       (and (anything-attribute-default attr)
            (eq type (anything-attribute-type attr))
            (return-from anything-attribute-default-action
              (anything-attribute-action attr))))
   *anything-type-attributes*))

(provide :anything/api/action)
;;end
