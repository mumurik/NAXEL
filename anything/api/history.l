;;; -*- Mode: Lisp -*-
;;  history: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       history is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(defvar *anything-source-history* (make-hash-table :test 'equal))

; omit
(defun sources-history (string)
  (setf (gethash *anything-sources* *anything-source-history*) string))

(provide :anything/api/history)
;;end
