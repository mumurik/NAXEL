;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/config.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/package")
  )

(in-package :xtal-mode)

(export '(*xtal-mode-map*
          *xtal-mode-syntax-table*
          *xtal-keyword-file*
          *xtal-indent-level*
          *xtal-electric-insert-close-parentheses*
          *xtal-electric-insert-close-string*
          *xtal-comment-column*
          *xtal-install-path*
          *xtal-command-xtal*
          *xtal-command-ix*
          *xtal-mode-output-buffer-name*
          *xtal-command-output-window-height*
          *xtal-ix-buffer-name*
          *xtal-ix-window-height*
          *xtal-mode-hook*
          *xtal-create-output-buffer-hook*
          *xtal-before-run-xtal-hook*
          *xtal-run-xtal-hook*
          *xtal-after-run-xtal-hook*
          *xtal-online-reference-url*
          *xtal-home-url*
          ))

(defvar *xtal-mode-map* nil
  "xtal-mode: キーマップ")

(defvar *xtal-mode-syntax-table* nil
  "xtal-mode: シンタックステーブル")

(defvar *xtal-keyword-file* "Xtal"
  "xtal-mode: キーワードファイル名")


(defvar *xtal-indent-level* c-indent-level
  "xtal-mode: インデントレベル")

(defvar *xtal-electric-insert-close-parentheses* t
  "xtal-mode: 自動的に閉じ括弧を挿入するなら t")

(defvar *xtal-electric-insert-close-string* t
  "xtal-mode: 自動的に文字列を閉じるなら t")

(defvar *xtal-comment-column* 60
  "xtal-mode: indent-for-comment で挿入するコメントの開始位置")


(defvar *xtal-install-path* "C:/xtal"
  "xtal-mode: xtal のインストールパス (xtal.exe のあるパス)")

(defvar *xtal-command-xtal* "xtal.exe"
  "xtal-mode: xtal.exe へのパス. 相対パスの場合 *xtal-instal-path* から探します")

(defvar *xtal-command-ix* "ix.exe"
  "xtal-mode: ix.exe へのパス. 相対パスの場合 *xtal-instal-path* から探します")


(defvar *xtal-mode-output-buffer-name* "*Xtal*"
  "xtal-mode: xtal コマンドの実行結果バッファの名前")

(defvar *xtal-command-output-window-height* -10
  "xtal-mode: xtal の実行結果を表示するウィンドウの高さ")

(defvar *xtal-ix-buffer-name* "*ix*"
  "xtal-mode: ix を実行するバッファの名前")

(defvar *xtal-ix-window-height* -20
  "xtal-mode: ix を実行するウィンドウの高さ")


(defvar *xtal-mode-hook* nil
  "xtal-mode: xtal-mode 実行時に呼ばれるフック")

(defvar *xtal-create-output-buffer-hook* nil
  "xtal-mode: xtal コマンドの実行結果バッファ作成時に呼ばれるフック")

(defvar *xtal-before-run-xtal-hook* nil
  "xtal-mode: xtal コマンド実行直前に呼ばれるフック")

(defvar *xtal-run-xtal-hook* nil
  "xtal-mode: xtal コマンド実行開始時に呼ばれるフック。引数は xtal.exe の process")

(defvar *xtal-after-run-xtal-hook* nil
  "xtal-mode: xtal コマンドの実行が終了したときに呼ばれるフック。引数は xtal.exe の process")


(defvar *xtal-online-reference-url* "http://www.h5.dion.ne.jp/~putora/xtal_doc/"
  "xtal-mode: オンラインリファレンスの URL")

(defvar *xtal-home-url* "http://code.google.com/p/xtal-language/"
  "xtal-mode: Home URL")


(provide "xtal-mode/config")

;;;; End
