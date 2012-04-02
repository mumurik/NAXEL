;;; -*- Lisp; syntax: Common-Lisp -*-
;;;
;;; Makefile(バイトコンパイル)
;;;
;;; Last fixed  "Mon Aug 18 2003 20:55:12 +0900"
;;;

(provide "makefile")

(in-package "editor")

(export '(*makefile-path* *makefile-file-list* *makefile-overwrite*
	  makefile makefile-clean makefile-with-clean))

(defvar *makefile-path* (merge-pathnames "site-lisp" (si:system-root)))
(defvar *makefile-file-list* nil)
(defvar *makefile-overwrite* nil)

(defun makefile ()
  "指定したファイルをバイトコンパイルする"
  (when *makefile-file-list*
    (dolist (f *makefile-file-list*)
      (let* ((file (merge-pathnames f *makefile-path*))
	     (filec (concat file "c")))
	(if (or *makefile-overwrite*
		(file-newer-than-file-p file filec))
 	    (byte-compile-file file)
	  (message "skipping file: ~A" file))
      ))
  ))

(defun makefile-clean ()
  "指定したファイルのバイトコンパイル済みファイルを削除する"
  (dolist (f *makefile-file-list*)
	(let* ((file (merge-pathnames f *makefile-path*))
	       (filec (concat file "c")))
	  (if (delete-file filec :if-does-not-exist :skip)
		  (message "file deleted: ~A" filec))
	)))

(defun makefile-with-clean ()
  (when *makefile-file-list*
    (makefile-clean)
    (makefile)))
