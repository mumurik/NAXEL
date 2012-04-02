;;; -*- Lisp; syntax: Common-Lisp -*-
;;; installation of KaTeX functions
;;; katexins.l, v 1.67.1.0
;;; fixed by Maeda Manabu
;;; Last fixed  "Mon Aug 18 2003 20:48:24 +0900"
;;;
;;; ■ このファイルの使い方
;;;
;;;     まとめてバイトコンパイルするための関数
;;;        katex-byte-compile             コンパイルだけ
;;;        katex-byte-compile-with-clean  .cl を消してからコンパイル
;;;
;;;     花鳥内で使用しているヒストリ変数を自動で保存できるようにする。
;;;        katex-register-history
;;;
;;;     0. 準備
;;; 	  展開したファイルを site-lisp/katex/ 以下に置いたとします。
;;;       異なる場合は、*makefile-path* を適宜変更してください。
;;;
;;;     1. バイトコンパイルする。
;;;
;;; 	  1.1. M-x load-library[Enter]
;;; 	  1.2. Load library: katex/katexins[Enter]
;;;
;;; 	  1.3. .lc ファイルがない場合
;;;             M-x elisp::katex-byte-compile[Enter]
;;;
;;; 	  1.4. バージョンアップする場合
;;;		M-x elisp::katex-byte-compile-with-clean[Enter]
;;;
;;;     2. xyzzyを終了。
;;;
;;;     3. xyzzyを再起動。
;;;

(provide "katexins")

(in-package "elisp")
(require "emacs")
(load-library "makefile")

(setq *makefile-path* (merge-pathnames "site-lisp/katex" (si:system-root)))

(setq *makefile-file-list* '("elisp.l"
			     "emacs.l"
			     "comment.l"
			     "katexlib.l"
			     "katex.l"
			     "katexadd.l"
			     "katexbar.l"
			     "katexenv.l"
			     "katexgen.l"
			     "katexhie.l"
			     "katexhlp.l"
			     "katexmen.l"
			     "katexmth.l"
			     "katexprc.l"
			     "katexsec.l"))

(defun katex-byte-compile ()
  (interactive)
  (makefile))

(defun katex-byte-compile-with-clean ()
  (interactive)
  (makefile-with-clean))

