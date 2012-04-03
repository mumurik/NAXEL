(in-package :user)

(defun anything-get-XTAGS-list()
  (let*((obuf (selected-buffer))
        (dir (default-directory))
        (nbuf "*XTAGS*")
        (file (merge-pathnames "XTAGS" dir))
        list)
    (when(file-exist-p file)
      (get-buffer-create nbuf)
      (set-buffer nbuf)
      (insert-file-contents file)
      (setq list (ed::tags-make-completion-list))
      (switch-to-buffer obuf)
      (delete-buffer nbuf)
      list)))

(defvar *anything-xtags-list* nil)
(defvar *anything-xtags-target* nil)

(defun anything-XTAGS-select(&optional type)
  (remove nil
          (mapcar #'(lambda(x)(and(eql (car(last x)) type)(car x)))
                  (if *anything-xtags-list* *anything-xtags-list*
                    (setq *anything-xtags-list* (anything-get-XTAGS-list))))))

(defun anything-tag-target-output(tag)
  (with-output-to-temp-buffer(" *PREVIEW*")
    (setq *anything-xtags-target*
          (find tag *anything-xtags-list* :test 'equal :key 'car))
    (insert-file-contents (cadr *anything-xtags-target*))
    (goto-char(nth 4 *anything-xtags-target*))
    ))

(defun anything-XTAGS-open()
  (delete-buffer " *PREVIEW*")
  (find-file(cadr *anything-xtags-target*))
  (goto-char(nth 4 *anything-xtags-target*))
  )

(add-hook '*anything-open-hook* #'(lambda()(global-mark-add)))
(add-hook '*anything-close-hook* #'(lambda()(setq *anything-xtags-list* nil)))

(another-anything   xtags
  (add-anything-sources
   :name "XTAGS Function"
   :type xtags
   :candidates (lambda()(anything-XTAGS-select 'function))
   :move-action (lambda(tag)(anything-tag-target-output tag))
   )

  (add-anything-sources
   :name "XTAGS Variable"
   :type xtags
   :candidates anything-XTAGS-select
   :move-action (lambda(tag)(anything-tag-target-output tag))
   )
;; attribute jump or insert
  (add-anything-attribute
   :type xtags
   :display "Target Jump"
   :action (lambda(x)(anything-XTAGS-open))
   :default t
   )

  (add-anything-attribute
   :type xtags
   :display "Insert Target"
   :action (lambda (x)(delete-buffer " *PREVIEW*")(insert x))
   )
  )

(provide :anything/xtags)

