;;; -*- Mode: Lisp; -*-
;;;
;;; Emacs Lispパッケージ定義
;;;
;;; Last fixed: <Sun May 20 2001 00:09:13 +0900>
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "elisp")
    (defpackage "elisp" (:use "lisp" "editor")
      (:nicknames "el"))))
