;;; -*- Mode: Lisp -*-
;;  isearch:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       isearch is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)
(require :isearch)

(defmacro is-anything(function)
  `(with-anything-window
    (call-interactively ',function)
    (if(get-category (point))
    (save-excursion
      (anything-selection)
      (let((scan (get-category-contents 0)))
        (while(not(looking-for scan))
          (backward-line)
          (sit-for .02))
        (sit-for 1)
        (sources-history scan)))
      (progn(forward-line)(anything-selection)))))

(defun anything-isearch-forward()
  (interactive)
  (is-anything isearch-forward))

(defun anything-isearch-backward()
  (interactive)
  (is-anything isearch-backward))

(provide :anything/api/isearch)
;;end
