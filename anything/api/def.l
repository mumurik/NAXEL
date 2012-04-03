;;; -*- Mode: Lisp -*-
;;  def: anything
;;; Author:        amefura <amefura@gmail.com>
;;; License:       def is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(export '(*anything-buffer*
          *anything-buffer-popup*
          *anything-buffer-vert*
          *anything-select-color*
          *anything-sources-name-color*
          *anything-migemo-on*
          *anything-migemo-length*
          *anything-open-hook*
          *anything-close-hook*
          *anything-use-frame*
          *anything-pseudo-frame-name*
          *anything-action-through-time*
          ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; customize
;; 別フレームに表示する
(defvar *anything-pseudo-frame-name* "anything"
  "Anything Frame Name")

(defvar *anything-use-frame* t
  "Anything Frame use on , off")

(defvar *anything-buffer* "*anything*"
  "Anything Buffer Name")

;; with-output-to-temp-buffer => document
(defvar *anything-buffer-popup* t
  "Anything buffer partition")

(defvar *anything-buffer-vert* nil
  "Anything buffer vertically or horizontally")

(defvar *anything-select-color*
  '(:foreground 0 :background 13 :bold t)
  "selection line color")

(defvar *anything-sources-name-color*
  '(:foreground 0 :background 14 :bold t)
  "category name color")

(defvar *anything-migemo-on* nil)

(defvar *anything-migemo-length* 4)

(defvar *category-length* 5 
  "another category length")

(defvar *anything-open-hook* nil)

(defvar *anything-close-hook* nil)

(defvar *anything-action-through-time* 0.25
  "action が速すぎる動きの場合、スルーする時間 ")

(defvar *anything-recursive-times* 5
  "filer modoki で使う場合 default-deirectory を元に戻す時間 ")

(defvar *anything-recursive* nil
  "flier modoki")

; hazard
(defvar *anything-maker-type* '( user::file )
  "make execute type list")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar-local anything-mode nil)
(defvar *anything-executed-buffer* nil)
(defvar *anything-execute-select-action* nil)
(defvar *anything-selected-source* nil)
(defvar *anything-executed* nil)
(defvar *anything-mode-map* nil
  "Keymap")
(defvar *anything-get-sources* nil
  "visible source list")
(defvar *anything-update-sources* nil
  "visible update source list")
(defvar *anything-cache-sources* nil
  "input history source list")
(defvar *anything-selection* nil
  "selected line . source name")
(defvar *anything-attribute-buffer* nil
  "attribute buffer check")
(defvar *anything-sources* nil
  "source hash")
(defvar *anything-type-attributes* nil
  "attributes hash")
(defvar *anything-execute-action-list* nil
  "set mark action list")
(defvar *anything-init-directory* nil
  "filer modoki init")


(provide :anything/api/def)
;;end
