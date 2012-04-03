;;; -*- Mode: Lisp -*-
;;  frame: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       frame is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;
;; thanks to nanasisann?
;; >>> http://xyzzy.s53.xrea.com/wiki/index.php?tips%2Fanything%A4%CE%C0%DF%C4%EA%CE%E3
;;
;;; Code:
(in-package :anything)

(defun anything-create-frame ()
  (let ((frame *anything-pseudo-frame-name*))
    (if (find-pseudo-frame frame)
    (switch-pseudo-frame frame)
      (new-pseudo-frame frame))))

(defun anything-delete-frame ()
  (let ((frame (find-pseudo-frame *anything-pseudo-frame-name*))
    (buffer (selected-buffer)))
    (when frame
      ;;(refresh-screen)
      (delete-pseudo-frame frame)
      (next-buffer) ; Ç±ÇÍÇì¸ÇÍÇ»Ç¢Ç∆ê‹ÇËï‘ÇµÇ™Ç®Ç©ÇµÇ≠Ç»ÇÈÇ±Ç∆Ç™Ç†ÇÈ
      (set-buffer buffer))))

(provide :anything/api/frame)
;;end
