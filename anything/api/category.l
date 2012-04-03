;;; -*- Mode: Lisp -*-
;;  category:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       category is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(defvar *category-point-list* nil)
(defvar *contents-list* nil)

(defun b-point()
  (buffer-stream-point *standard-output*))

(defun set-source-name-color(pair-points)
  (apply 'set-text-attribute
         (append pair-points (list 'category) *anything-sources-name-color*)))

(defun get-category(point)
  (when *category-point-list*
    (setq *contents-list* nil)
    (let((c (find-if #'(lambda(e)(<= (cadr e) point (caddr e)))
                     *category-point-list*)))
      (and c
      (setq *contents-list*
            (list
             (buffer-substring (car c) (cadr c))
             (buffer-substring (+ (car c) 2)(- (cadr c) 2))
             c
             ))))))

(defun get-category-contents(n)
  (and *category-point-list* *contents-list* (nth n *contents-list*)))

(defun move-category-point(point n move)
  (let((pos (position-if #'(lambda(e)(<= (cadr e) point (caddr e)))
                         *category-point-list*)))
    (if pos
        (case move
          (up
           (or(and(<= 0 (- pos n))
                      (nth (- pos n) *category-point-list*))
              (car *category-point-list*)))
          (down
           (or (nth (+ pos n) *category-point-list*)
               (car (last *category-point-list*))))
          )
      (first *category-point-list*))))

(provide :anything/api/category)
;;end
