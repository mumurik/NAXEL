;;; -*- Mode: Lisp -*-
;;  mode:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       mode is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)
(export '(anything))

(defun anything-setup (buffer history)
  (when *anything-executed*
    (and *anything-use-frame* (anything-create-frame))
    (setq *anything-executed-buffer* (selected-buffer))
    ; view anything
    (anything-get-sources)
    (anything-default-exhibit "")
    ; minibuf
    (save-excursion
      (save-window-excursion
        (set-buffer buffer)
        (anything-mode t)))
    ))

(defun anything-unsetup (buffer contents)
  (when anything-mode
    (anything-mode nil)
    (delete-text-attributes 'any)
    (delete-text-attributes 'category)
    (if(find-buffer *anything-buffer*)
        (delete-buffer *anything-buffer*))
    ))

(defun anything-cleanup()
  (setq *anything-executed* nil
        *anything-get-sources* nil
        *anything-mark* nil
        *anything-selection* nil
        *anything-attribute-buffer* nil
        *anything-execute-select-action* nil
        *anything-selected-source* nil
        *anything-execute-action-list* nil
        *anything-execute-action-list* nil)
  (clrhash *anything-update-sources*)
  )

(defun anything()
  (interactive)
  (unless *anything-executed*
    (setq *anything-executed* t)
    (or *anything-init-directory*
        (setq *anything-init-directory* (default-directory)))
    (run-hooks '*anything-open-hook*)
    (add-hook '*enter-minibuffer-hook* 'anything-setup)
    (add-hook '*exit-minibuffer-hook*  'anything-unsetup)
    (read-string "anything pattern: " :history t)
    (delete-hook '*enter-minibuffer-hook* 'anything-setup)
    (delete-hook '*exit-minibuffer-hook*  'anything-unsetup)
    ;after
    (and *anything-use-frame* (anything-delete-frame));timing
    (unwind-protect
     (if *anything-execute-action-list* ; mark ÇµÇƒÇ¢ÇÈèÍçá
         (dolist(x *anything-execute-action-list*)
           (apply (car x)(cdr x)))
       (and *anything-execute-select-action* ; action ÇÃé¿çsÇÕï|Ç¢
            (apply (car *anything-execute-select-action*)
                   (cdr *anything-execute-select-action*))))
      (anything-cleanup))
    (run-hooks '*anything-close-hook*)
    ))

(defun anything-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode 'anything-mode arg sv)
  (if anything-mode
      (progn
        (make-local-variable '*post-command-hook*)
        (add-hook '*post-command-hook* 'anything-exhibit)
        (set-minor-mode-map *anything-mode-map*))
    (progn
      (unset-minor-mode-map *anything-mode-map*)
      (delete-hook '*post-command-hook* 'anything-exhibit)
      ))
  anything-mode)

(pushnew '(anything-mode . "Anything") *minor-mode-alist* :key #'car)

(provide :anything/api/mode)
;;end

