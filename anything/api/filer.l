;;; -*- Mode: Lisp -*-
;;  filer:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       filer is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;
;;; Code:
(in-package :anything)

;; [todo]
;;  timing anything-recursive

(defun anything-recursive ()
  (if *anything-recursive*
      (progn(setq *anything-recursive* nil)(anything))
    (start-timer *anything-recursive-times*
                 #'(lambda()
                     (let((buf (selected-buffer)))
                       (switch-to-buffer *anything-executed-buffer*)
                       (set-default-directory *anything-init-directory*)
                       (setq *anything-init-directory* nil)
                       (switch-to-buffer buf)))
                 t)))

(add-hook '*anything-close-hook* 'anything-recursive)

(defun anything-upper-directory()
  (interactive)
  (anything-name-search)
  (when
      (and(eql 'user::file (cdr (anything-type-or-action)))
          (file-exist-p
           (merge-pathnames (car *anything-selection*)
                            (default-directory))))
    (set-default-directory
     (directory-namestring
      (remove-trail-slash(default-directory)))
     *anything-executed-buffer*)
    (with-anything-window
     (get-category (point))
     (sources-history (get-category-contents 0)))
    (setq *anything-recursive* t)
    (setq *anything-execute-action-list* nil)
    (minibuffer-exit)
    ))

(provide :anything/api/filer)
;;end
