;;; -*- Mode: Lisp -*-
;;  move:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       move is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

; key map
(defun anything-move-selection(unit direct arg)
  (with-anything-window
   (get-category (point))
   (if *anything-attribute-buffer*
       (case unit
         (line (case direct (next (forward-line arg))
                 (previous (backward-line arg)))))
     (case unit
       (line (case direct
               (next (forward-line arg)
                     (and (looking-at "^$")
                          (forward-line  2)))
               (previous (and (< 2 (current-line-number))
                              (backward-line arg))
                         (and (looking-for (get-category-contents 0))
                              (backward-line 2)))))
       (page (case direct
               (next (next-page))
               (previous (previous-page)))
             )
       (source (case direct
                 (next (goto-char
                        (car (move-category-point (point) arg 'down)))
                       (forward-line)
                       (recenter 1))
                 (previous (goto-char
                            (car (move-category-point (point) arg 'up)))
                           (forward-line)
                           (recenter 1)))
               )
       ))
   (unless *anything-attribute-buffer*
     (or (get-category (1+(point)))(forward-line)(get-category (point)))
     (sources-history (get-category-contents 0)))
   (if (eobp)(backward-line 2)) ;last line
   (case unit
     ((line page)
      (anything-moved-action))
     (source
      (anything-default-exhibit (anything-check-minibuffer-input))))
   ))

;; nomal input , C-h or BS , C-a->C-k
(defun anything-exhibit ()
  (unless *anything-attribute-buffer*
    (case *this-command*
      ((self-insert-command
        anything-backward-char
        kill-region)
       (anything-default-exhibit
                (anything-check-minibuffer-input)))
      ((anything)
       (while(not(read-char-no-hang))
         (anything-next-line)
         (refresh-screen)
         (sit-for .1)))
      (t  (message "~A" *this-command*))
      ))
  )
;; TAB or RET  ;;; rescurve not file nil
(defun anything-get-action(key)
  (anything-name-search)
  (if *anything-attribute-buffer*
      (anything-attribute-get-action)
    (let((type-or-act (anything-type-or-action)))
      (case key
        (ret
         (case (car type-or-act)
           (type (setq *anything-execute-select-action*
                       (list (anything-attribute-default-action
                              (cdr type-or-act))
                             (car *anything-selection*))))
           (action (setq *anything-execute-select-action*
                         (list (cdr type-or-act)
                               (car *anything-selection*)))
                   )))
        (tab
         (case (car type-or-act)
           (type (anything-type-exhibit (cdr type-or-act)))
           (action (setq *anything-execute-select-action*
                         (list (cdr type-or-act)
                               (car *anything-selection*))))))
        )
      (or(eql 'user::file (cdr type-or-act))
         (setq *anything-recursive* nil))
      )))

;; C-SPC , C-@
(defun anything-set-marker()
  (anything-name-search)
  (let((type-or-act (anything-type-or-action))
       (path (merge-pathnames (car *anything-selection*) (default-directory)))
       (mk))
    (and(member (cdr type-or-act) *anything-maker-type*)
        (setq mk (case (car type-or-act)
                   (type (list (anything-attribute-default-action
                                (cdr type-or-act)) path))
                   (action (list (cdr type-or-act) path))))
        (if(member mk *anything-execute-action-list* :test 'equal)
            (setq *anything-execute-action-list*
                  (remove mk *anything-execute-action-list* :test 'equal))
          (pushnew mk *anything-execute-action-list* :test 'equal))
        (anything-maker-list-popup)
        (anything-next-line)
        ))
  )

(defun anything-maker-list-popup()
  (with-anything-window
   (and *anything-execute-action-list*
        (popup-string
         (format nil "~{~A~^~%~}"
                 (mapcar #'cadr *anything-execute-action-list*))
         (point)
         3))))

(provide :anything/api/move)
;;end
