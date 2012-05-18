;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/macros.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/package")
  (require "xtal-mode/utils")
  )

(in-package :xtal-mode)

(defmacro with-gensyms (syms &body body)
  `(let ,(mapcar #'(lambda (sym)
                     `(,sym (gensym)))
                 syms)
     ,@body))
(setf (get 'with-gensyms 'ed:lisp-indent-hook) 'let)

(defmacro timeout (dt &body body)
  (with-gensyms (gdt gstart)
    `(let ((,gstart (get-universal-time))
           (,gdt ,dt))
       (loop
         (when (< ,gdt (- (get-universal-time) ,gstart))
           (return nil))
         ,@body))))
(setf (get 'timeout 'ed:lisp-indent-hook) 1)

(defmacro with-temporary-set-buffer ((buffer) &body body)
  `(save-window-excursion
     (with-set-buffer
       (set-buffer ,buffer)
       ,@body)))
(setf (get 'with-temporary-set-buffer 'ed:lisp-indent-hook) 'progn)

(defmacro set-local-variable (name value &optional buffer)
  `(save-window-excursion
     (with-set-buffer
       (set-buffer ,buffer)
       (make-local-variable ',name)
       (setf ,name ,value))))

(defmacro cursor-moved? (&body body)
  (let ((gpoint (gensym)))
    `(let ((,gpoint (point)))
       (block cursor-moved?
         ,@body)
       (not (eql ,gpoint (point))))))
(setf (get 'cursor-moved? 'ed:lisp-indent-hook) 'progn)

(defmacro save-current-point-only-if-fail (&body body)
  (with-gensyms (gpoint r)
    `(let ((,gpoint (point))
           (,r nil))
       (unwind-protect
           (setf ,r (progn ,@body))
         (unless ,r
           (goto-char ,gpoint))))))
(setf (get 'save-current-point-only-if-fail 'ed:lisp-indent-hook) 'save-excursion)

(defmacro with-current-line-points ((begin end) &body body)
  `(multiple-value-bind (,begin ,end)
       (current-line-point-values)
     ,@body))
(setf (get 'with-current-line-points 'ed:lisp-indent-hook) 'progn)

(defmacro narrow-to-current-line (point)
  (with-gensyms (gpoint)
    `(let ((,gpoint (point)))
       (apply 'narrow-to-region (current-line-points))
       ,(case point
          (:bol '(goto-bol))
          (:eol '(goto-eol))
          (t `(goto-char ,gpoint))))))

(defmacro current-line-eval ((point) &body body)
  `(save-excursion
     (save-restriction
       (narrow-to-current-line ,point)
       ,@body)))
(setf (get 'current-line-eval 'ed:lisp-indent-hook) 'progn)

(defmacro with-narrowing ((begin end &optional (type :point)) &body body)
  `(save-excursion
     (save-restriction
       ,(if (eq type :line)
            `(narrow-to-region (beginning-of-line-point ,begin)
                               (end-of-line-point ,end))
          `(narrow-to-region ,begin ,end))
       ,@body)))
(setf (get 'with-narrowing 'ed:lisp-indent-hook) 'progn)

(defmacro scan-line (point &rest args)
  `(current-line-eval (,point)
     (scan-buffer ,@args)))

(defmacro looking-bol (re &key skip-space)
  `(current-line-eval (:bol)
     (when ,skip-space
       (skip-chars-forward " \t"))
     (looking-at ,re)))

(defmacro current-line-indent ()
  `(current-line-eval (:bol)
     (skip-chars-forward " \t")
     (current-column)))


(defun D(&rest args)
  #+xtal-mode-debug
  (apply 'D0 args)
  (car (last args)))

(defun D0(&rest args)
  (msgbox "~S: [~A~A]: line=~D, col=~D, point=~D"
          args
          (char-before (point))
          (char-after (point))
          (current-line-number) (current-column) (point))
  (car (last args)))


(provide "xtal-mode/macros")

;;;; End
