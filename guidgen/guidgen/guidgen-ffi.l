; -*- mode: lisp; package: guidgen-ffi; encoding: shift_jis -*-

;;; guidgen/guidgen-ffi.l
;;
;; Copyright (c) 2006 MIYAMUKO Katsuyuki.
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
  #+:xyzzy
  (require "foreign"))

(in-package :guidgen-ffi)

#+:xyzzy
(c:define-c-type c:long HRESULT)

#+:xyzzy
(c:*define-c-macro SUCCEEDED (hr)
  `(<= 0 ,hr))

#+:xyzzy
(c:*define-c-struct GUID
  (c:u_long  data1)
  (c:u_short data2)
  (c:u_short data3)
  (c:u_char  data4 8))

#+:xyzzy
(c:*define-dll-entry HRESULT CoCreateGuid
  ((GUID *) ;; pguid   Pointer to the requested GUID on return.
   )
  "ole32")


;; ---------

#+:clisp
(export '(GUID-data1
          GUID-data2
          GUID-data3
          GUID-data4
          CoCreateGuid
          SUCCEEDED
          ))

#+:clisp
(ffi:def-c-type HRESULT ffi:long)

#+:clisp
(ffi:def-c-struct GUID
  (data1 ffi:ulong)
  (data2 ffi:ushort)
  (data3 ffi:ushort)
  (data4 (ffi:c-array ffi:uchar 8)))

#+:clisp
(ffi:def-call-out CoCreateGuid
  (:name "CoCreateGuid")
  (:return-type HRESULT)
  (:arguments (guid (ffi:c-ptr GUID) :out))
  (:library "ole32")
  (:language :stdc-stdcall))

(defun SUCCEEDED (hr)
  (<= 0 hr))


(provide "guidgen/guidgen-ffi")


#|
(c:*define-dll-entry DWORD UuidCreate ((GUID *))
  "rpcrt4")

(c:*define-dll-entry DWORD UuidToStringA ((GUID *)
                                          (c::char *))
  "rpcrt4")
|#

;; End
