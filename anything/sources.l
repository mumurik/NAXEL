;;; -*- Mode: Lisp -*-
;;  sources: anything
;;; Author:        amefura <amefura@gmail.com>
;;; Modified by:   mumurik765
;;; License:       sources is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :user)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; source
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-anything-sources :name "Files from Current Directory"
                      :type file
                      :candidates directory
                      :init default-directory
                      )

(add-anything-sources :name "File Name History"
                      :type file
                      :candidates (lambda() *minibuffer-file-name-history*)
                      )

(add-anything-sources :name "Session File History"
                      :candidates (lambda() ed::*session-file-history*)
                      :action load-session
                      )

(add-anything-sources :name "Buffers"
                      :type buffer
                      :candidates (lambda()
                                    (delete-if
                                     #'(lambda(x)(or
                                                  (string-match "^ " x)
                                                  (string-match *anything-buffer* x)))
                                     (mapcar #'buffer-name (buffer-list))))
                      :move-action (lambda(buffer)
                                     (with-selected-window
                                       (other-window)
                                       (and(minibuffer-window-p (selected-window))
                                           (other-window))
                                       (set-buffer buffer)))
                      )

(add-anything-sources :name "Minibuffer Command History"
                      :candidates (lambda() *minibuffer-symbol-name-history*)
                      :action (lambda (c)
                                (call-interactively (read-from-string c))))

(add-anything-sources :name "Minibuffer Lisp Sexp History"
                      :candidates (lambda()
                                    (mapcar
                                     #'(lambda(s)
                                         (string-left-trim
                                          " \t"
                                          (delete #\LFD s)))
                                     *minibuffer-lisp-sexp-history*))
                      :action (lambda (sexp)
                                (eval (read-from-string sexp)))
                      )

(add-anything-sources :name "Execute History"
                      :candidates (lambda() *minibuffer-execute-history*)
                      :action (lambda (exec &optional start end)
                                (filter-region exec start end))
                      )

(add-anything-sources :name "Select Frame"
                      :candidates (lambda()
                                    (let((f (delete *anything-pseudo-frame-name*
                                                    (mapcar #'ed::pseudo-frame-name
							    (ed::get-pseudo-frame-list (selected-frame)))
                                                    :test 'equal)))
                                      (unless (= 1 (length f)) f)))
                      :action (lambda(f)(switch-pseudo-frame f))
                      )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; attribute
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; type file
(add-anything-attribute :type file
                        :display "Find File"
                        :action (lambda(file)
                                  (if(file-directory-p file)
                                      (let((path (merge-pathnames file (default-directory))))
                                        (setq anything::*anything-recursive* t)
                                        (set-default-directory path)
                                        (or (directory path)
                                            (setq anything::*anything-recursive* nil))
                                        )
                                    (progn
                                      (setq anything::*anything-recursive* nil)
                                      (find-file file)
                                      (add-history (merge-pathnames file (default-directory))
                                                   '*minibuffer-file-name-history*))))
                        :default t
                        )

(add-anything-attribute :type file
                        :display "Delete File"
                        :action (lambda (file)
                                  (if (y-or-n-p (format nil "Really delete file? ~A" file))
                                      (delete-file file)))
                        )

;; type buffer
(add-anything-attribute :type buffer
                        :display "Switch to Buffer"
                        :action switch-to-buffer
                        :default t
                        )

(add-anything-attribute :type buffer
                        :display "Pop to Buffer"
                        :action  pop-to-buffer
                        )

(add-anything-attribute :type buffer
                        :display "Display Buffer"
                        :action display-buffer
                        )

(add-anything-attribute :type buffer
                        :display "Kill Buffer"
                        :action kill-buffer
                        )

(provide :anything/sources)
;;end
