; -*- mode: lisp; package: editor; encoding: shift_jis -*-

;;; guidgen/editor/menu.l
;;
;; Copyright (c) 2006,2008,2011 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "guidgen/guidgen")
  (require "guidgen/editor/command")
  (require "guidgen/editor/about"))

(in-package :editor)

(export '(guidgen-track-popup-menu
          guidgen-setup-app-menu
          guidgen-setup-app-popup-menu
          guidgen-remove-app-menu
          guidgen-remove-app-popup-menu
          ))

(defvar *guidgen-menu-name* "GUID生成(&U)")

(defparameter *guidgen-popup-menu* nil)
(defun guidgen-popup-menu ()
  (unless *guidgen-popup-menu*
    (setf *guidgen-popup-menu*
          (define-popup-menu 'guidgen
            (:item nil "&1. IMPLEMENT_OLECREATE(...)"
             'guidgen-insert-implement-olecreate)
            (:item nil "&2. DEFINE_GUID(...)"
             'guidgen-insert-define-guid)
            (:item nil "&3. static const GUID = {...}"
             'guidgen-insert-static-const-guid)
            (:item nil "&4. レジストリ (ie. {xxxx...})"
             'guidgen-insert-registry)
            (:item nil "&5. urn:uuid (ie. urn:uuid:xxxx...)"
             'guidgen-insert-urn)
            (:item nil "&6. 無変換 (ie. xxxx...)"
             'guidgen-insert)
            :sep
            (:popup nil "GUID 一括更新 (&B)"
             (:item nil "全バッファ (&A)"
              'guidgen-replace-all-buffer)
             (:item nil "バッファ (&B)"
              'guidgen-replace-buffer)
             (:item nil "リージョン (&R)"
              'guidgen-replace-region)
             (:item nil "セレクション (&S)"
              'guidgen-replace-selection))
            (:item nil "カーソル下の GUID を更新 (&R)"
             'guidgen-replace)
            (:item nil "GUID 更新履歴の参照 (&S)"
             'guidgen-replace-history-show)
            (:item nil "GUID 更新履歴のクリア (&D)"
             'guidgen-replace-history-clear)
            :sep
            (:item nil "GUID をクリップボードにコピー (&C)"
             'guidgen-copy-to-clipboard)
            (:item nil "GUID を kill ring にコピー (&Y)"
             'guidgen-copy-to-kill-ring)
            :sep
            (:item nil "直前の GUID を繰り返す (&F)"
             'guidgen-toggle-use-last-guid
             #'(lambda ()
                 (if (guidgen-use-last-guid-p) :check)))
            (:item nil "小文字で GUID を生成 (&L)"
             'guidgen-toggle-use-downcase
             #'(lambda ()
                 (if (guidgen-use-downcase-p) :check)))
            :sep
            (:item nil (concat "guidgen &version " *guidgen-version*)
             'guidgen-about-message)
            )))
  *guidgen-popup-menu*)


(defun guidgen-track-popup-menu ()
  (interactive)
  (track-popup-menu (guidgen-popup-menu)))

(defun guidgen-setup-app-menu ()
  (interactive)
  (guidgen-setup-menu '*app-menu* '(ed::tools :above-insert-date) 1))

(defun guidgen-setup-app-popup-menu ()
  (interactive)
  (guidgen-setup-menu '*app-popup-menu* nil 1))

(defun guidgen-remove-app-menu ()
  (interactive)
  (guidgen-remove-menu '*app-menu* '(ed::tools :above-insert-date)))

(defun guidgen-remove-app-popup-menu ()
  (interactive)
  (guidgen-remove-menu '*app-popup-menu* nil))



(defun guidgen-setup-menu (root-menu &optional path offset)
  (guidgen-with-menu root-menu
                     #'(lambda ()
                         (guidgen-setup-menu0 root-menu path offset))))

(defun guidgen-remove-menu (root-menu &optional path)
  (guidgen-with-menu root-menu
                     #'(lambda ()
                         (guidgen-remove-menu0 root-menu path))))

(defun guidgen-with-menu (root-menu fn)
  (if (symbol-value root-menu)
      (funcall fn)
    (add-hook '*init-app-menus-hook* fn)))

(defun guidgen-setup-menu0 (root-menu &optional path offset)
  (guidgen-remove-menu0 root-menu path)
  (multiple-value-bind (pos menu)
      (guidgen-find-menu (symbol-value root-menu) path)
    (when (and menu (menup menu))
      (if (and pos (numberp pos))
          (insert-popup-menu menu (+ pos offset)
                             (guidgen-popup-menu)
                             *guidgen-menu-name*)
        (add-popup-menu menu
                        (guidgen-popup-menu)
                        *guidgen-menu-name*)))))

(defun guidgen-remove-menu0 (root-menu &optional path)
  (multiple-value-bind (pos menu)
      (guidgen-find-menu (symbol-value root-menu) path)
    (when (and menu (menup menu))
      (while (delete-menu menu 'guidgen)))))

(defun guidgen-find-menu (menu path)
  (cond ((endp path)
         (values nil menu))
        ((= (length path) 1)
         (if (numberp (car path))
             (values (car path) menu)
           (get-menu-position menu (car path))))
        (t
         (guidgen-find-menu
          (get-menu menu (car path) (numberp (car path)))
          (cdr path)))))


(provide "guidgen/editor/menu")

;; End
