;;; -*- Mode: Lisp -*-
;;  macro: anything
;;; Author:        amefura <amefura@gmail.com>
;;; License:       macro is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)
(export '(
          add-anything-sources
          add-anything-attribute
          ))

(defstruct anything
  name
  type
  candidates
  action
  init
  move-action
  visible-mode
  )

(setq *anything-sources* (make-hash-table :test 'equal))

(defstruct anything-attribute
  type
  display
  action
  default
  )

(setq *anything-type-attributes* (make-hash-table :test 'equal))

(defmacro add-anything-sources
  (&key (name)
        (type)
        (candidates)
        (action)
        (init)
        (move-action)
        (visible-mode)
        )
  `(setf
    (gethash ,name *anything-sources*)
    ,(make-anything
      :name name
      :type type
      :candidates candidates
      :action action
      :init init
      :move-action move-action
      :visible-mode visible-mode
      )))

(defmacro add-anything-attribute
  (&key (type 'something)
        (display)
        (action)
        (default)
        )
  `(setf
    (gethash ,display *anything-type-attributes*)
    ,(make-anything-attribute
      :type type
      :display display
      :action action
      :default default
      )))


; output buffer
(defmacro with-output-to-simple-temp-buffer
  ((buffer &optional(popup t) vert-p) &body body)
  `(with-output-to-temp-buffer (,buffer ,popup ,vert-p)
       (set-local-window-flags
        (selected-buffer)
        (+ *window-flag-line-number* *window-flag-ruler*
           *window-flag-newline* *window-flag-tab*
           *window-flag-vscroll-bar* *window-flag-mode-line*
           *window-flag-hscroll-bar* *window-flag-eof*
           *window-flag-fold-line* *window-flag-fold-mark*
           *window-flag-cursor-line*) nil)
       (set-buffer-fold-type-none)
       (progn
         ,@body)
       ))

(setf (get 'with-output-to-simple-temp-buffer 'lisp-indent-hook) 1)

(defmacro turn-read-only(&body body)
  `(progn
     (toggle-read-only nil)
     ,@body
     (toggle-read-only t)
     ))

(defmacro with-anything-window (&body body)
  `(with-selected-window
     (set-window(get-buffer-window(find-buffer *anything-buffer*)))
     ,@body))

(defmacro through (&body body)
  `(let*((real internal-time-units-per-second)
         (image (apply #'+
                       (multiple-value-list
                        (round(/ (* real
                                    *anything-action-through-time*)
                                 real))))))
     (and(<=(* image real)
            (let((start(get-internal-real-time)))
              (sit-for image)
              (- (get-internal-real-time) start)))
         (progn ,@body)
         )))

(provide :anything/api/macro)
;;end
