;;; -*- Mode: Lisp -*-
;;  another:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       another is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(export '(another-anything))

(defvar *another-anything-member* nil)

(defconstant *global-anything-sources* *anything-sources*)
(defconstant *global-anything-type-attributes* *anything-type-attributes*)

(defmacro another-anything (name &body body)
  (let((new-src (gensym))
       (new-type (gensym))
       (g (gensym)))
    (flet((sym(sym-name type)
            (intern(concat (symbol-name sym-name)
                           (if type "-anything-1" "-anything")) :user)))
      `(progn
         (defun ,(sym name t) (on)
           (or(and on (or(and(setq ,g (cdr (find ',(sym name t) *another-anything-member*
                                                 :test 'eql :key 'car)))
                             (setq *anything-sources* (car ,g)
                                   *anything-type-attributes* (cdr ,g)))
                         (progn
                           (setq ,new-src (make-hash-table :test 'equal)
                                 ,new-type (make-hash-table :test 'equal))
                           (pushnew (cons ',(sym name t)(cons ,new-src ,new-type))
                                    *another-anything-member*
                                    :test 'eql :key 'car)
                           (setq *anything-sources* ,new-src
                                 *anything-type-attributes* ,new-type)
                           ,@body)))
              (setq *anything-sources* *global-anything-sources*
                    *anything-type-attributes* *global-anything-type-attributes*)
              ))
         (defun ,(sym name nil)()
           (interactive)
           (,(sym name t) t)
           (anything)
           (,(sym name t) nil))
         )
      )))
(setf (get 'another-anything 'lisp-indent-hook) 1)


(provide :anything/api/another)
;;end
