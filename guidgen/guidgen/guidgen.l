; -*- mode: lisp; package: guidgen; encoding: shift_jis -*-

;;; guidgen/guidgen.l
;;
;; Copyright (c) 2006,2008 MIYAMUKO Katsuyuki.
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
  (require "guidgen/package.l")           ;; ".l" for clisp
  (require "guidgen/guidgen-ffi.l"))

(in-package :guidgen)

(export '(*guidgen-version*
          guidgen
          guidgen-last-guid
          ))


(defconstant *guidgen-version* "1.2.0")

(defconstant *guid-format* (format nil "~{~{~~~D,'0X~}~^-~}"
                                   '((8) (4) (4)
                                     (2 2) (2 2 2 2 2 2))))

(defconstant *guid-regexp-strict*
  (format nil "~{\\([a-zA-Z0-9]\\)\\{~D\\}~^-~}" '(8 4 4 4 12)))

(defconstant *guid-regexp-loose*
  "\\([a-zA-Z0-9][a-zA-Z0-9]\\)+\\(\\(-[a-zA-Z0-9][a-zA-Z0-9]\\)+\\)+")

(defvar *guidgen-last-guid* nil)


(defun guidgen-last-guid (&key (downcase nil))
  (let ((guid *guidgen-last-guid*))
    (values (guid-to-string guid :downcase downcase)
            guid)))

(defun guidgen (&key (downcase nil))
  (let ((guid (create-guid-internal)))
    (setf *guidgen-last-guid* guid)
    (values (guid-to-string guid :downcase downcase)
            guid)))

(defun create-guid-internal ()
  (guid-to-list (co-create-guid)))

(defun co-create-guid ()
  #+:xyzzy
  (let ((guid (make-GUID)))
    (when (SUCCEEDED (CoCreateGuid guid)))
      guid)
  #+:clisp
  (multiple-value-bind (ret guid)
      (CoCreateGuid)
    (when (SUCCEEDED ret)
      guid)))

(defun guid-to-string (guid-list &key (downcase nil))
  (when guid-list
    (let ((guid (apply #'format nil *guid-format* guid-list)))
      (if downcase
          (string-downcase guid)
        (string-upcase guid)))))

(defun guid-to-list (guid-chunk)
  (when guid-chunk
    (append (list (GUID-data1 guid-chunk)
                  (GUID-data2 guid-chunk)
                  (GUID-data3 guid-chunk))
            (mapcar #'(lambda (i)
                        #+:xyzzy
                        (GUID-data4 guid-chunk i)
                        #+:clisp
                        (svref (GUID-data4 guid-chunk) i)
                        )
                    '(0 1 2 3 4 5 6 7)))))


(provide "guidgen/guidgen")

;; End
