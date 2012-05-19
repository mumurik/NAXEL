;;; -*- Mode: Lisp; Package: editor -*-

;;; info2.l --- Info Mode.
;;
;; Created: [2006/02/20]
;; Last updated: [2007/06/20]

;;; Commentary:
;;
;; Info ドキュメントを読むためのモード。
;;
;; 以下未対応
;;
;; ・info-help
;; ・info-summary
;; ・圧縮した Info ファイルの閲覧
;;
;;
;; 導入:
;;
;;   ".xyzzy" か "siteinit.l" に以下を記述。
;;
;;   (in-package "editor")
;;   (export '(info2 info2-mode) "editor")
;;   (autoload 'info2 "info2" t)
;;   (autoload 'info2-mode "info2" t)
;;   (in-package "user")
;;
;;
;; 設定:
;;
;;   (setf
;;    ;; スムースにページスクロール
;;    *info2-smooth-scroll-p* t
;;    ;; 履歴の最大長
;;    *info2-max-history-length* 10
;;    ;; ウィンドウ表示領域を N 等分する Search、Bookmark バッファの幅
;;    *info2-window-width* 4
;;    ;; ブックマークファイルのパス
;;    *info2-bookmark-file* (merge-pathnames "infobmk" (user-config-path))
;;
;;    ;; Info Mode のバッファで非表示にするフラグ。
;;    *info2-buffer-flags* (+
;;                         ;;   改行
;;                         *window-flag-newline*
;;                         ;;   全角 Space
;;                         *window-flag-full-width-space*
;;                         ;;   EOF
;;                         *window-flag-eof*
;;                         ;;   半角 Space
;;                         *window-flag-half-width-space*
;;                         )
;;    ;; Search モードのバッファで非表示にするフラグ
;;    *info2-search-buffer-flags* (+
;;                                ;;   行番号
;;                                *window-flag-line-number*
;;                                ;;   改行
;;                                *window-flag-newline*
;;                                ;;   全角 Space
;;                                *window-flag-full-width-space*
;;                                ;;   垂直スクロールバー
;;                                *window-flag-vscroll-bar*
;;                                ;;   EOF
;;                                *window-flag-eof*
;;                                ;;   半角 Space
;;                                *window-flag-half-width-space*
;;                                )
;;    ;; Bookmark Mode のバッファで非表示にするフラグ
;;    *info2-bookmark-buffer-flags* (+
;;                                  ;;   行番号
;;                                  *window-flag-line-number*
;;                                  ;;   改行
;;                                  *window-flag-newline*
;;                                  ;;   全角 Space
;;                                  *window-flag-full-width-space*
;;                                  ;;   垂直スクロールバー
;;                                  *window-flag-vscroll-bar*
;;                                  ;;   EOF
;;                                  *window-flag-eof*
;;                                  ;;   半角 Space
;;                                  *window-flag-half-width-space*
;;                                  )
;;
;;    ;; Info ファイルのパスと使用するキーワードファイルのパスの連想リスト
;;    ;;
;;    ;;  (list (cons "~/info/language/lisp/reference/reference.info"
;;    ;;             "~/etc/lisp"
;;    ;;             )
;;    ;;       (cons "~/info/software/gnu/gnu_manuals/elisp-manual/elisp"
;;    ;;             "~/etc/lisp"
;;    ;;             )
;;    ;;       )
;;    ;; とか
;;    ;;
;;    *info2-keyword-file-alist* nil
;;
;;    ;; 色付けを行うか
;;    *info2-fontify-p* t
;;    ;; 見出し、メニューエントリで色付けを行う最大数
;;    *info2-fontify-max-num* 100
;;
;;    ;; Node Line 文字色
;;    *info2-node-line-fgcolor* 0
;;    ;; Node Line 背景色
;;    *info2-node-line-bgcolor* 0
;;    ;; Node Line 太字
;;    *info2-node-line-bold-p* t
;;
;;    ;; Node Line File 文字色
;;    *info2-node-line-file-fgcolor* 2
;;    ;; Node Line File 背景色
;;    *info2-node-line-file-bgcolor* 0
;;    ;; Node Line File 太字
;;    *info2-node-line-file-bold-p* nil
;;
;;    ;; Node Line Node 文字色
;;    *info2-node-line-node-fgcolor* 1
;;    ;; Node Line Node 背景色
;;    *info2-node-line-node-bgcolor* 0
;;    ;; Node Line Node 太字
;;    *info2-node-line-node-bold-p* nil
;;
;;    ;; Node Pointer 文字色
;;    *info2-node-pointer-fgcolor* 3
;;    ;; Node Pointer 背景色
;;    *info2-node-pointer-bgcolor* 0
;;    ;; Node Pointer 太字
;;    *info2-node-pointer-bold-p* nil
;;
;;    ;; 見出し文字色
;;    *info2-heading-fgcolor* 1
;;    ;; 見出し背景色
;;    *info2-heading-bgcolor* 0
;;    ;; 見出し太字
;;    *info2-heading-bold-p* t
;;
;;    ;; 見出しを表わす記号 文字色
;;    *info2-heading-decoration-fgcolor* 0
;;    ;; 見出しを表わす記号 背景色
;;    *info2-heading-decoration-bgcolor* 0
;;    ;; 見出しを表わす記号 太字
;;    *info2-heading-decoration-bold-p* t
;;
;;    ;; メニュー見出し文字色
;;    *info2-menu-heading-fgcolor* 0
;;    ;; メニュー見出し背景色
;;    *info2-menu-heading-bgcolor* 0
;;    ;; メニュー見出し太字
;;    *info2-menu-heading-bold-p* t
;;
;;    ;; 相互参照 文字色
;;    *info2-cross-reference-fgcolor* 1
;;    ;; 相互参照 背景色
;;    *info2-cross-reference-bgcolor* 0
;;    ;; 相互参照 太字
;;    *info2-cross-reference-bold-p* nil
;;
;;    ;; 検索文字列 文字色
;;    *info2-search-fgcolor* 0
;;    ;; 検索文字列 背景色
;;    *info2-search-bgcolor* 2
;;    ;; 検索文字列 太字
;;    *info2-search-bold-p* nil
;;    )
;;
;;
;; キーバインド:
;;
;;   [Info モード]
;;
;;     TAB : 次の相互参照 or メニューに移動
;;     RET : 現在行の相互参照 or メニューが指すノードへ移動
;;     SPC : 上にページスクロール or 次のノードへ
;;     .   : Info バッファ先頭へ
;;
;;     0 ～ 9 : N 番目のメニューエントリ先に移動
;;
;;     [ : 前のノードへ移動
;;     ] : 次のノードへ移動
;;     a : 現在位置を Bookmark に追加
;;     b : Info バッファ先頭へ
;;     B : Bookmark ウィンドウを開く
;;     d : DIR に移動
;;     e : 閲覧中のノード内容を編集
;;     f : 指定した相互参照先へ移動
;;     g : 指定ノードへ移動
;;     i : Index 検索
;;     I : Index or Search ウィンドウを開く
;;
;;     M-i : Index ノードに移動
;;
;;     k : キーワード色付けトグル
;;     l : ノード履歴 戻る
;;     L : ノード履歴 進む
;;     m : 指定したメニュー先へ移動
;;     n : Next Node へ移動
;;     p : Prev Node へ移動
;;     q : Info Mode 終了
;;     s : 指定語句を現在のノード以下から検索
;;     S : Index or Search ウィンドウを開く
;;     t : Top Node へ移動
;;     u : Up Node へ移動
;;     v : 下へページスクロール
;;     z : 上へページスクロール
;;
;;     F13 : 前の相互参照 or Menu に移動
;;           (set-extended-key-translate-table exkey-S-tab #\F13)
;;           とかして S-Tab に設定するとか
;;
;;     F15 : 上にページスクロール or 次のノードへ
;;           (set-extended-key-translate-table exkey-S-space #\F15)
;;           とかして S-Spc に設定するとか
;;
;;     Double Click : 現在行の相互参照 or メニューが指すノードへ移動
;;     Triple Click : ノード履歴 戻る
;;
;;
;;   [Search モード]
;;
;;     TAB : 現在行のノードを Info ウィンドウに表示
;;     RET : 現在行のノードに移動し Search ウィンドウを閉じる
;;     SPC : 現在行のノードを表示し Info ウィンドウに移動
;;
;;     n : 次の行へ移動しその行のノードを Info バッファに表示
;;     p : 前の行へ移動しその行のノードを Info バッファに表示
;;     q : Search ウィンドウを閉じる
;;     v : 下へページスクロール
;;     z : 上へページスクロール
;;
;;     Double Click : 現在行のノードを表示し Info ウィンドウに移動
;;
;;
;;   [Bookmark モード]
;;
;;     TAB : 現在行のノードを Info ウィンドウに表示
;;     RET : 現在行のノードに移動し Bookmark ウィンドウを閉じる
;;     SPC : 現在行のノードを表示し Info ウィンドウに移動
;;
;;     d : カーソル位置のブックマークを削除
;;     i : カーソル位置に文字列を挿入
;;     n : 次の行へ移動
;;     N : 現在行のブックマークを下に移動
;;     o : カーソル位置に空行を挿入
;;     p : 前の行へ移動
;;     P : 現在行のブックマークを上に移動
;;     q : Bookmark バッファを閉じる
;;     r : ブックマークのタイトル変更
;;     v : 下へページスクロール
;;     w : カーソル行のブックマークを切り取り
;;     y : カーソル行に切り取ったブックマークを貼り付け
;;     z : 上へページスクロール
;;
;;     Double Click : 現在行のノードを表示し Info ウィンドウに移動
;;
;;
;;   [Edit モード]
;;
;;     C-c C-c : 編集内容を保存し編集モードを終了
;;     C-x C-k : 変更を取り消し編集モードを終了
;;
;;     あとは Text モードと同じ。
;;

;;; Change Log:
;;
;; 2007-06-20
;;
;;     * みんなが自由に使えるよう修正 BSD ライセンスを適用。
;;
;;     * Info 文書を加筆 & 修正。
;;
;;     * Info 文書をテキストで出力しそれも添付。
;;
;; 2007-05-11
;;
;;     * info2-scroll-up、info2-forward-node がバグってたのを修正とか。
;;
;;     * Info 文書添付。
;;
;; 2007-05-07
;;
;;     * 自分勝手に info2-scroll-down を F14 から F15 に変更。
;;
;; 2007-04-27
;;
;;     * 関数 info2-mode の引数として存在しないファイルパスが指定された
;;       ときを考慮。
;;
;;     * 関数 info2-mode で Info モードに入ったときキーワード色付けがで
;;       きていなかったのを修正。
;;
;;     * キーワードがクリアされたとき、またはキーワードファイルが取得で
;;       きなかったときそれぞれにメッセージを表示するようにした。
;;
;; 2007-04-15
;;
;;     * inof-edit 追加。
;;     * ちゃんと export。
;;     * Commentary にもっとヘルプ書いた。
;;     * Debug しやすいように。
;;     * その他こまかな修正。
;;
;; 2007-04-11
;;
;;     * 初版公開。
;;

;;; License:
;;
;; Copyright (c) 2007, Masanori Miyajima. All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;;     * Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;     * Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    * The names of itscontributors may be used to endorse or promote 
;;      products derived from this software without specific prior written 
;;      permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;; IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "info2")
(in-package "editor")

(export '(
          info2
          info2-mode

          info2-next-reference
          info2-nearest-reference
          info2-scroll-up
          info2-nth-menu-item
          info2-backward-node
          info2-forward-node
          info2-bookmark-add
          info2-bookmark
          info2-directory
          info2-edit
          info2-follow-reference
          info2-goto-node
          info2-index
          info2-index-window
          info2-view-index
          info2-toggle-keyword
          info2-last
          info2-history-forward
          info2-menu
          info2-next
          info2-previous
          info2-exit
          info2-search
          info2-index-window
          info2-top
          info2-up
          info2-next-page
          info2-previous-page
          info2-previous-reference
          info2-scroll-down
          info2-mouse-left-press

          info2-search-view-node-static
          info2-search-view-node-and-quit
          info2-search-view-node-dynamic
          info2-search-next-line-and-view
          info2-search-previous-line-and-view
          info2-search-quit
          info2-next-page
          info2-previous-page
          info2-search-mouse-left-press

          info2-bookmark-view-node-static
          info2-bookmark-view-node-and-quit
          info2-bookmark-view-node-dynamic
          info2-bookmark-del
          info2-bookmark-insert-string
          info2-bookmark-next-line
          info2-bookmark-transpose-lines-down
          info2-bookmark-open-line
          info2-bookmark-previous-line
          info2-bookmark-transpose-lines-up
          info2-bookmark-quit
          info2-bookmark-rename-title
          info2-next-page
          info2-bookmark-cut
          info2-bookmark-paste
          info2-previous-page
          info2-bookmark-mouse-left-press

          info2-edit-save-and-quit
          info2-edit-undo-and-quit

          *info2-mode-map*
          *info2-mode-hook*
          *info2-dir*
          *info2-default-buffer-name*
          *info2-default-tag-table-buffer-name*
          *info2-default-indirect-buffer-name*
          *info2-buffer-flags*
          *info2-max-history-length*
          *info2-smooth-scroll-p*
          *info2-fontify-p*
          *info2-fontify-max-num*
          *info2-node-line-fgcolor*
          *info2-node-line-bgcolor*
          *info2-node-line-bold-p*
          *info2-node-line-file-fgcolor*
          *info2-node-line-file-bgcolor*
          *info2-node-line-file-bold-p*
          *info2-node-line-node-fgcolor*
          *info2-node-line-node-bgcolor*
          *info2-node-line-node-bold-p*
          *info2-node-pointer-fgcolor*
          *info2-node-pointer-bgcolor*
          *info2-node-pointer-bold-p*
          *info2-heading-fgcolor*
          *info2-heading-bgcolor*
          *info2-heading-bold-p*
          *info2-menu-heading-fgcolor*
          *info2-menu-heading-bgcolor*
          *info2-menu-heading-bold-p*
          *info2-cross-reference-fgcolor*
          *info2-cross-reference-bgcolor*
          *info2-cross-reference-bold-p*

          *info2-search-mode-map*
          *info2-search-mode-hook*
          *info2-window-width*
          *info2-search-buffer-flags*

          *info2-bookmark-file*
          *info2-bookmark-mode-map*
          *info2-bookmark-mode-hook*
          *info2-bookmark-buffer-flags*

          *info2-edit-mode-map*
          *info2-edit-mode-hook*
          )
        "editor"
        )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defvar

;; Debug
(defvar *info2-debug* nil)


(defvar *info2-mode-map* nil
    "Info Mode キーマップ。"
    )

(defvar *info2-mode-hook* nil
    "Info Mode フック変数。"
    )

(defvar *info2-dir* "~/info/"
    "DIR ファイルがあるディレクトリ。"
    )

(defvar *info2-default-buffer-name* "*info2*"
    "デフォルト Info Mode バッファ名。"
    )

(defvar *info2-default-tag-table-buffer-name* (if *info2-debug*
                                                      "*info2-tag-table*"
                                                  " *info2-tag-table*"
                                                  )
    "デフォルト Tag Table バッファ名。"
    )

(defvar *info2-default-indirect-buffer-name* (if *info2-debug*
                                                     "*info2-indirect*"
                                                 " *info2-indirect*"
                                                 )
    "デフォルト Indirect バッファ名。"
    )

(defvar *info2-buffer-flags* (+
                              ;; 改行
                              *window-flag-newline*
                              ;; 全角 Space
                              *window-flag-full-width-space*
                              ;; EOF
                              *window-flag-eof*
                              ;; 半角 Space
                              *window-flag-half-width-space*
                              )
    "Info Mode のバッファで非表示にするフラグ。"
    )

(defvar *info2-max-history-length* 10
    "履歴の最大長。"
    )

(defvar *info2-smooth-scroll-p* t
    "スムースにページスクロール。"
    )

(defvar *info2-keyword-file-alist* nil
    "\
Info ファイルのパスと使用するキーワードファイルのパスの連想リスト。

・設定例

(setf *info2-keyword-file-alist* (list (cons \"~/info/language/lisp/reference/reference.info\"
                                             \"~/etc/lisp\"
                                             )
                                       (cons \"~/info/software/gnu/gnu_manuals/elisp-manual/elisp\"
                                             \"~/etc/lisp\"
                                             )
                                       )
      )
"
)


;;====================================
;; Color

(defvar *info2-fontify-p* t
    "色付けを行うか。"
    )

(defvar *info2-fontify-max-num* 100
    "見出し、メニューエントリで色付けを行う最大数。"
    )

(defvar *info2-node-line-fgcolor* 0
    "Node Line 文字色。"
    )
(defvar *info2-node-line-bgcolor* 0
    "Node Line 背景色。"
    )
(defvar *info2-node-line-bold-p* t
    "Node Line 太字。"
    )

(defvar *info2-node-line-file-fgcolor* 2
    "Node Line File 文字色。"
    )
(defvar *info2-node-line-file-bgcolor* 0
    "Node Line File 背景色。"
    )
(defvar *info2-node-line-file-bold-p* nil
    "Node Line File 太字。"
    )

(defvar *info2-node-line-node-fgcolor* 1
    "Node Line Node 文字色。"
    )
(defvar *info2-node-line-node-bgcolor* 0
    "Node Line Node 背景色。"
    )
(defvar *info2-node-line-node-bold-p* nil
    "Node Line Node 太字。"
    )

(defvar *info2-node-pointer-fgcolor* 3
    "Node Pointer 文字色。"
    )
(defvar *info2-node-pointer-bgcolor* 0
    "Node Pointer 背景色。"
    )
(defvar *info2-node-pointer-bold-p* nil
    "Node Pointer 太字。"
    )

(defvar *info2-heading-fgcolor* 1
    "見出し文字色。"
    )
(defvar *info2-heading-bgcolor* 0
    "見出し背景色。"
    )
(defvar *info2-heading-bold-p* t
    "見出し太字。"
    )

(defvar *info2-heading-decoration-fgcolor* 0
    "見出しを表わす記号 文字色。"
    )
(defvar *info2-heading-decoration-bgcolor* 0
    "見出しを表わす記号 背景色。"
    )
(defvar *info2-heading-decoration-bold-p* t
    "見出しを表わす記号 太字。"
    )

(defvar *info2-menu-heading-fgcolor* 0
    "メニュー見出し文字色。"
    )
(defvar *info2-menu-heading-bgcolor* 0
    "メニュー見出し背景色。"
    )
(defvar *info2-menu-heading-bold-p* t
    "メニュー見出し太字。"
    )

(defvar *info2-cross-reference-fgcolor* 1
    "相互参照 文字色。"
    )
(defvar *info2-cross-reference-bgcolor* 0
    "相互参照 背景色。"
    )
(defvar *info2-cross-reference-bold-p* nil
    "相互参照 太字。"
    )

(defvar *info2-search-fgcolor* 0
    "検索文字列 文字色。"
    )
(defvar *info2-search-bgcolor* 2
    "検索文字列 背景色。"
    )
(defvar *info2-search-bold-p* nil
    "検索文字列 太字。"
    )

;; Color
;;====================================


;;====================================
;; Search モード

(defvar *info2-search-mode-map* nil
    "Search モードキーマップ。"
    )

(defvar *info2-search-mode-hook* nil
    "Search モードフック変数。"
    )

(defvar *info2-default-search-buffer-name* " *info2-search*"
    "デフォルトの Search バッファ名。"
    )

(defvar *info2-window-width* 4
    "ウィンドウ表示領域を N 等分する Search、Bookmark バッファの幅。"
    )

(defvar *info2-search-buffer-flags* (+
                                     ;; 行番号
                                     *window-flag-line-number*
                                     ;; 改行
                                     *window-flag-newline*
                                     ;; 全角 Space
                                     *window-flag-full-width-space*
                                     ;; 垂直スクロールバー
                                     *window-flag-vscroll-bar*
                                     ;; EOF
                                     *window-flag-eof*
                                     ;; 半角 Space
                                     *window-flag-half-width-space*
                                     )
    "Search モードのバッファで非表示にするフラグ。"
    )

;; Search モード
;;====================================


;;====================================
;; Bookmark モード

(defvar *info2-bookmark-file* (merge-pathnames "infobmk" (user-config-path))
    "ブックマークファイルのパス。"
    )


(defvar *info2-bookmark-mode-map* nil
    "Bookmark モードキーマップ。"
    )


(defvar *info2-bookmark-mode-hook* nil
    "Bookmark モードフック変数。"
    )


(defvar *info2-bookmark-buffer-name* " *info2-bookmark*"
    "Bookmark バッファ名。"
    )


(defvar *info2-bookmark-buffer-flags* (+
                                       ;; 行番号
                                       *window-flag-line-number*
                                       ;; 改行
                                       *window-flag-newline*
                                       ;; 全角 Space
                                       *window-flag-full-width-space*
                                       ;; 垂直スクロールバー
                                       *window-flag-vscroll-bar*
                                       ;; EOF
                                       *window-flag-eof*
                                       ;; 半角 Space
                                       *window-flag-half-width-space*
                                       )
    "Bookmark Mode のバッファで非表示にするフラグ。"
    )


(defvar *info2-bookmark-current-position* 11
    "Bookmark の現在位置。"
    )


(defvar *info2-bookmark-clipboard* nil
    "切り取ったブックマークを格納"
    )

;; Bookmark モード
;;====================================


;;====================================
;; Edit モード

(defvar *info2-edit-mode-map* nil
    "編集モード用キーマップ。"
    )


(defvar *info2-edit-mode-hook* nil
    "編集モードのフック変数。"
    )

;; Edit モード
;;====================================


;;====================================
;; 検索文字列
;; とりあえず変数にいれとく

(defvar *info2-index-marker-string* " [index ]"
    "インデクスノードを示す文字列。"
    )


;;------------------------------------
;; Regexp

(defvar *info2-regexp-node-line*
    (compile-regexp "^file:[ \t]*\\([^,\n]+\\),[ \t]*node:[ \t]*\\([^,\n]+\\)[, \t]*\\(next:[ \t]*\\([^,\n]+\\),[ ]*\\)?\\(prev:[ \t]*\\([^,\n]+\\),[ ]*\\)?\\(up:[ \t]*\\(.+\\)\\)?"
                    t)
    "\
ノードライン用正規表現。

1: ファイル名。
2: ノード名。
3: next: 次のノード名
4: 次のノード名。
5: prev: 前のノード名
6: 前のノード名。
7: up: 上位ノード名
8: 上位ノード名。

File: dir,  Node: 1,  Next: 2,  Prev: Top,  Up: Top
"
    )


(defvar *info2-regexp-next*
    (compile-regexp "next:[ \t]*\\([^,]+\\),"
                    t)
    "\
ノードライン Next 用の正規表現。

1: Next ノード。
"
    )


(defvar *info2-regexp-prev*
    (compile-regexp "prev:[ \t]*\\([^,]+\\),"
                    t)
    "\
ノードライン Prev 用の正規表現。

1: Prev ノード。
"
    )


(defvar *info2-regexp-up*
    (compile-regexp "up:[ \t]*\\(.+\\)$"
                    t)
    "\
ノードライン Up 用の正規表現。

1: Up ノード。
"
    )


(defvar *info2-regexp-node-line-part*
    (compile-regexp ",[ \t]*\\([^ :\n]+\\):[ \t]*\\([^,\n]+\\)[,\n]"
                    t)
    "\
ノードライン Next、Prev、Up 用の正規表現。

1: Next or Prev or Up.
2: ノード名。

,  Next: 2,  Prev: 1,  Up: Top
"
    )


(defvar *info2-regexp-menu*
    (compile-regexp "\n\\(\\* \\(menu\\):\\)\n"
                    t
                    )
    "\
メニュー見出し \(* Menu:\) 用の正規表現。

1: * Menu:
2: Menu

* Menu:
"
    )


(defvar *info2-regexp-cross-reference*
    (compile-regexp
     "\\(^*\\|\\*note\\)[ \t]*\\(.*[^:]\\)\\(\\(: \\)\\|\\(::[ \n\\.]\\)\\)[ \t]*\\([^,\n]*\\)"
     t
     )
    "\
相互参照とメニューエントリ用の正規表現。

1: \"*\" or \"*note\".
2: NODE-NAME or CROSS-REFERENCE-NAME.
3: \"::\" or \": \".
6: NODE-NAME.

\(match-string 3\) が \"::\" か \":\" かでノード名判断。

6 の NODE-NAME \(コロン 1 つのとき\) は string-right-trim で \".\" を取
り除く必要あり。
\(string-right-trim \".\" \(string-right-trim \"\)\" \(match-string 4\)\)\)

xyzzy Lisp Reference で \"si:*paste-hook*\" とか \"ed::toggle-mode\" 等
\":\" 付きのノード名があるので、とりあえずそれにも対応。

*Note NODE-NAME::, DETAILS.
*Note NODE-NAME::.
\(*Note NODE-NAME::\)

*Note CROSS-REFERENCE-NAME: NODE-NAME, DETAILS.
*Note CROSS-REFERENCE-NAME: NODE-NAME.
\(*Note CROSS-REFERENCE-NAME: NODE-NAME\)

*Note CROSS-REFERENCE-NAME: \(INFO-FILE-NAME\)NODE-NAME, DETAILS.
*Note CROSS-REFERENCE-NAME: \(INFO-FILE-NAME\)NODE-NAME.
\(*Note CROSS-REFERENCE-NAME: \(INFO-FILE-NAME\)NODE-NAME\)
"
    )


(defvar *info2-regexp-index-entry*
    (compile-regexp "^* .+:[ \t]+\\(.+\\)\\.[ \t]*\n?[ \t]*(line[ ]+\\(.+\\))$"
                    t)
    "\
Index 用の正規表現。

1: ノード。
2: 行番号。

xyzzy Lisp Reference で \"si:*paste-hook*\" とか \"ed::toggle-mode\" 等
\":\" 付きのノード名があるので、とりあえずそれにも対応。

* index:  Node.  (line  3)
"
    )


(defvar *info2-regexp-node*
    (compile-regexp "^(\\([^)]+\\))\\(.*\\)"
                    t)
    "\
ノード分離用の正規表現。

\(パス\)ノード名

1: パス部分。
2: ノード名部分。
"
    )


(defvar *info2-regexp-heading*
    (compile-regexp "^\n\\(.+\\)\n\\([-=\\.\\*]+\\)\n"
                    t)
    "\
見出し \(@chapter、@unnumbered、@appendix、@heading\) 用の正規表現。

1: 見出し。
2: 見出しの下行に付加される記号。

見出し
******
"
    )

;; Regexp
;;------------------------------------

;; 検索文字列
;;====================================


;;====================================
;; Defvar Local

(defvar-local *INFO2-FILE-PATH* nil
              "表示している Info ファイルのフルパス。"
              )

(defvar-local *INFO2-BUFFER-NAME* nil
              "Info バッファ名。"
              )

(defvar-local *INFO2-CURRENT-NODE* nil
              "カレントノード。"
              )

(defvar-local *INFO2-TAG-TABLE-BUFFER-NAME* nil
              "Tag Table バッファ名。"
              )

(defvar-local *INFO2-INDIRECT-BUFFER-NAME* nil
              "Indirect バッファ名。"
              )

(defvar-local *INFO2-INDIRECT-FILE-LIST* nil
              "Indirect ファイルフルパスのリスト。"
              )

(defvar-local *INFO2-INDIRECT-POS-LIST* nil
              "Indirect Positon のリスト。"
              )

(defvar-local *INFO2-INDEX-NODE-LIST* nil
              "Index ノード名のリスト。"
              )

(defvar-local *INFO2-HISTORY-BACK-LIST* nil
              "\
表示ノード履歴リスト \(Back\)。

\(InfoFilePath NodeName Point\)
"
              )

(defvar-local *INFO2-HISTORY-FORWARD-LIST* nil
              "\
表示ノード履歴リスト \(Forward\)。

\(InfoFilePath NodeName Point\)
"
              )

(defvar-local *INFO2-SEARCH-BUFFER-NAME* nil
              "Search バッファ名。"
              )

;; Defvar Local
;;====================================

;;; Defvar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defun

(defun info2-close-all-buffer ()
    "カレントバッファに関連する全ての Info バッファを閉じる。"
    (let (
          ;; Bookmark ウィンドウ
          let-bookmark-win
          ;; Search バッファ名
          (let-search-buffer-name *INFO2-SEARCH-BUFFER-NAME*)
          ;; Search ウィンドウ
          let-search-win
          ;; Indirect バッファ名
          (let-indirect-buffer-name *INFO2-INDIRECT-BUFFER-NAME*)
          ;; Tag Table バッファ名
          (let-tag-table-buffer-name *INFO2-TAG-TABLE-BUFFER-NAME*)
          ;; Info バッファ名
          (let-info-buffer-name *INFO2-BUFFER-NAME*)
          )

        ;; Bookmark バッファ
        (when (find-buffer *info2-bookmark-buffer-name*)
            (when (setf let-bookmark-win (get-buffer-window (find-buffer *info2-bookmark-buffer-name*)))
                ;; ウィンドウがあれば削除
                (set-window let-bookmark-win)
                (delete-window)
                )
            (delete-buffer (find-buffer *info2-bookmark-buffer-name*))
            )

        ;; Search バッファ
        (when (and let-search-buffer-name
                   (find-buffer let-search-buffer-name)
                   )
            (when (setf let-search-win (get-buffer-window (find-buffer let-search-buffer-name)))
                ;; ウィンドウがあれば削除
                (set-window let-search-win)
                (delete-window)
                )
            ;; バッファ削除
            (delete-buffer (find-buffer let-search-buffer-name))
            )

        ;; Indirect バッファ
        (if (and let-indirect-buffer-name
                 (find-buffer let-indirect-buffer-name)
                 )
                (delete-buffer (find-buffer let-indirect-buffer-name))
            )

        ;; Tag Table バッファ
        (if (and let-tag-table-buffer-name
                 (find-buffer let-tag-table-buffer-name)
                 )
                (delete-buffer let-tag-table-buffer-name)
            )

        ;; Info バッファ
        (if (and let-info-buffer-name
                 (find-buffer let-info-buffer-name)
                 )
                (delete-buffer (find-buffer let-info-buffer-name))
            )

        t
        )
    )


(defun info2-fontify ()
    "カレントバッファを色付け。"
    (let (
          ;; Count 用変数
          let-count
          )
        (save-excursion
            (goto-char (point-min))

            (when (scan-buffer *info2-regexp-node-line*
                               :case-fold t
                               :regexp t
                               )
                ;; Node Line
                (set-text-attribute (match-beginning 0)
                                    (match-end 0)
                                    'node-line
                                    :bold *info2-node-line-bold-p*
                                    :foreground *info2-node-line-fgcolor*
                                    :background *info2-node-line-bgcolor*
                                    )
                ;; Node Line File
                (set-text-attribute (match-beginning 1)
                                    (match-end 1)
                                    'file
                                    :bold *info2-node-line-file-bold-p*
                                    :foreground *info2-node-line-file-fgcolor*
                                    :background *info2-node-line-file-bgcolor*
                                    )
                ;; Node Line Node
                (set-text-attribute (match-beginning 2)
                                    (match-end 2)
                                    'node
                                    :bold *info2-node-line-node-bold-p*
                                    :foreground *info2-node-line-node-fgcolor*
                                    :background *info2-node-line-node-bgcolor*
                                    )
                ;; Node Line Next
                (if (match-string 4)
                        (set-text-attribute (match-beginning 4)
                                            (match-end 4)
                                            'next
                                            :bold *info2-node-pointer-bold-p*
                                            :foreground *info2-node-pointer-fgcolor*
                                            :background *info2-node-pointer-bgcolor*
                                            )
                    )
                ;; Node Line Prev
                (if (match-string 6)
                        (set-text-attribute (match-beginning 6)
                                            (match-end 6)
                                            'prev
                                            :bold *info2-node-pointer-bold-p*
                                            :foreground *info2-node-pointer-fgcolor*
                                            :background *info2-node-pointer-bgcolor*
                                            )
                    )
                ;; Node Line Up
                (if (match-string 8)
                        (set-text-attribute (match-beginning 8)
                                            (match-end 8)
                                            'up
                                            :bold *info2-node-pointer-bold-p*
                                            :foreground *info2-node-pointer-fgcolor*
                                            :background *info2-node-pointer-bgcolor*
                                            )
                    )
                )

            ;; 見出し
            ;; *info2-fontify-max-num* 以上は色付けしない
            (setf let-count 0)
            (while (and (scan-buffer *info2-regexp-heading* :no-dup t :regexp t)
                        (> *info2-fontify-max-num* let-count)
                        )
                ;; 見出し文字列
                (set-text-attribute (match-beginning 1)
                                    (match-end 1)
                                    'heading
                                    :bold *info2-heading-bold-p*
                                    :foreground *info2-heading-fgcolor*
                                    :background *info2-heading-bgcolor*
                                    )
                ;; 見出しを表わす記号
                (set-text-attribute (match-beginning 2)
                                    (match-end 2)
                                    'heading-decoration
                                    :bold *info2-heading-decoration-bold-p*
                                    :foreground *info2-heading-decoration-fgcolor*
                                    :background *info2-heading-decoration-bgcolor*
                                    )
                (incf let-count)
                )

            ;; メニュー見出し
            (when (scan-buffer *info2-regexp-menu* :case-fold t :regexp t :tail t)
                (set-text-attribute (match-beginning 1)
                                    (match-end 1)
                                    'menu-heading
                                    :bold *info2-menu-heading-bold-p*
                                    :foreground *info2-menu-heading-fgcolor*
                                    :background *info2-menu-heading-bgcolor*
                                    )
                )

            ;; 相互参照、メニューエントリ
            (setf let-count 1)
            ;; *info2-fontify-max-num* 以上は色付けしない
            (while (and (scan-buffer *info2-regexp-cross-reference* :case-fold t :no-dup t :regexp t)
                        (>= *info2-fontify-max-num* let-count)
                        )
                (when (string-equal (match-string 1) "*")
                    ;; 先頭の "*"
                    (if (= (mod let-count 10) 0)
                            (set-text-attribute (match-beginning 1)
                                                (match-end 1)
                                                'menu-entry-mark
                                                :bold t
                                                :underline t
                                                )
                        (if (= (mod let-count 5) 0)
                                (set-text-attribute (match-beginning 1)
                                                    (match-end 1)
                                                    'menu-entry-mark
                                                    :underline t
                                                    )
                            )
                        )
                    )

                (set-text-attribute (match-beginning 2)
                                    (match-end 2)
                                    'menu-entry
                                    :bold *info2-cross-reference-bold-p*
                                    :foreground *info2-cross-reference-fgcolor*
                                    :background *info2-cross-reference-bgcolor*
                                    )
                (incf let-count)
                )
            )

        t
        )
    )


(defun info2-set-local-value (
                              info-file-path
                              info-buffer-name
                              current-node
                              tag-table-buffer-name
                              indirect-buffer-name
                              indirect-file-list
                              indirect-pos-list
                              index-node-list
                              history-back-list
                              history-forward-list
                              search-buffer-name
                              )
    "\
カレントバッファの Buffer Local 変数を設定。

INFO-FILE-PATH          : 表示する Info ファイル名、Work Directory。
INFO-BUFFER-NAME        : Info バッファ名。
CURRENT-NODE            : カレントノード。
TAG-TABLE-BUFFER-NAME   : Tag Table バッファ名。
INDIRECT-BUFFER-NAME    : Indirect バッファ名。
INDIRECT-FILE-LIST      : Indirect ファイル名のリスト。
INDIRECT-POS-LIST       : Indirect Positon のリスト。
INDEX-NODE-LIST         : Index ノード名のリスト。
HISTORY-BACK-LIST       : 表示ノード履歴リスト (Back)。
HISTORY-FORWARD-LIST    : 表示ノード履歴リスト (Forward)。
SEARCH-BUFFER-NAME      : Search バッファ名。
"
    ;; 作業ディレクトリを Info がある所に
    (set-default-directory (directory-namestring info-file-path))

    (setf
     ;; 表示している Info ファイルのパス
     *INFO2-FILE-PATH* info-file-path
     ;; Info バッファ名
     *INFO2-BUFFER-NAME* info-buffer-name
     ;; カレントノード
     *INFO2-CURRENT-NODE* current-node
     ;; Tag Table バッファ名
     *INFO2-TAG-TABLE-BUFFER-NAME* tag-table-buffer-name
     ;; Indirect バッファ名
     *INFO2-INDIRECT-BUFFER-NAME* indirect-buffer-name
     ;; Indirect ファイル名のリスト
     *INFO2-INDIRECT-FILE-LIST* indirect-file-list
     ;; Indirect Positon のリスト
     *INFO2-INDIRECT-POS-LIST* indirect-pos-list
     ;; Index ノード名のリスト
     *INFO2-INDEX-NODE-LIST* index-node-list
     ;; 表示ノード履歴リスト (Back)
     *INFO2-HISTORY-BACK-LIST* history-back-list
     ;; 表示ノード履歴リスト (Forward)
     *INFO2-HISTORY-FORWARD-LIST* history-forward-list
     ;; Search バッファ名
     *INFO2-SEARCH-BUFFER-NAME* search-buffer-name
     )

    t
    )


(defun info2-set-local-value-all-buffer (
                                         info-file-path
                                         info-buffer-name
                                         current-node
                                         tag-table-buffer-name
                                         indirect-buffer-name
                                         indirect-file-list
                                         indirect-pos-list
                                         index-node-list
                                         history-back-list
                                         history-forward-list
                                         search-buffer-name
                                         )
    "Info、Tag Table、Indirect バッファそれぞれにローカル変数をセット。"

    ;; Bookmark バッファ
    (when (find-buffer *info2-bookmark-buffer-name*)
        (set-buffer (find-buffer *info2-bookmark-buffer-name*))
        (info2-set-local-value info-file-path
                               info-buffer-name
                               current-node
                               tag-table-buffer-name
                               indirect-buffer-name
                               indirect-file-list
                               indirect-pos-list
                               index-node-list
                               history-back-list
                               history-forward-list
                               search-buffer-name
                               )
        )

    ;; Search バッファ
    (when (and search-buffer-name
               (find-buffer search-buffer-name)
               )
        (set-buffer (find-buffer search-buffer-name))
        (info2-set-local-value info-file-path
                               info-buffer-name
                               current-node
                               tag-table-buffer-name
                               indirect-buffer-name
                               indirect-file-list
                               indirect-pos-list
                               index-node-list
                               history-back-list
                               history-forward-list
                               search-buffer-name
                               )
        )

    ;; Indirect バッファ
    (when (and indirect-buffer-name
               (find-buffer indirect-buffer-name)
               )
        (set-buffer (find-buffer indirect-buffer-name))
        (info2-set-local-value info-file-path
                               info-buffer-name
                               current-node
                               tag-table-buffer-name
                               indirect-buffer-name
                               indirect-file-list
                               indirect-pos-list
                               index-node-list
                               history-back-list
                               history-forward-list
                               search-buffer-name
                               )
        )

    ;; Tag Table バッファ
    (when (find-buffer tag-table-buffer-name)
        (set-buffer (find-buffer tag-table-buffer-name))
        (info2-set-local-value info-file-path
                               info-buffer-name
                               current-node
                               tag-table-buffer-name
                               indirect-buffer-name
                               indirect-file-list
                               indirect-pos-list
                               index-node-list
                               history-back-list
                               history-forward-list
                               search-buffer-name
                               )
        )

    ;; Info バッファ
    (set-buffer (find-buffer info-buffer-name))
    (info2-set-local-value info-file-path
                           info-buffer-name
                           current-node
                           tag-table-buffer-name
                           indirect-buffer-name
                           indirect-file-list
                           indirect-pos-list
                           index-node-list
                           history-back-list
                           history-forward-list
                           search-buffer-name
                           )
    t
    )


(defun info2-history-add (
                          list-arg
                          info-file-path
                          node
                          pos
                          )
    "\
履歴追加。

LIST-ARG:
1 - 戻る履歴 (*INFO2-HISTORY-BACK-LIST*)。
2 - 進む履歴 (*INFO2-HISTORY-FORWARD-LIST*)。

INFO-FILE-PATH : Info ファイルのパス。
NODE           : 表示ノード。
POS            : 位置。
"
    (case list-arg
        ;; Back
        (1 (push (list info-file-path node pos) *INFO2-HISTORY-BACK-LIST*)
           ;; *info2-max-history-length* より長ければ古いのを消す
           (if (> (list-length *INFO2-HISTORY-BACK-LIST*) *info2-max-history-length*)
                   (nbutlast *INFO2-HISTORY-BACK-LIST*)
               )
           )
        ;; Forward
        (2 (push (list info-file-path node pos) *INFO2-HISTORY-FORWARD-LIST*)
           ;; *info2-max-history-length* より長ければ古いのを消す
           (if (> (list-length *INFO2-HISTORY-FORWARD-LIST*) *info2-max-history-length*)
                   (nbutlast *INFO2-HISTORY-FORWARD-LIST*))
           )
        (t (plain-error "引数がおかしい"))
        )

    ;; Buffer Local 変数設定
    (info2-set-local-value-all-buffer *INFO2-FILE-PATH*
                                      *INFO2-BUFFER-NAME*
                                      *INFO2-CURRENT-NODE*
                                      *INFO2-TAG-TABLE-BUFFER-NAME*
                                      *INFO2-INDIRECT-BUFFER-NAME*
                                      *INFO2-INDIRECT-FILE-LIST*
                                      *INFO2-INDIRECT-POS-LIST*
                                      *INFO2-INDEX-NODE-LIST*
                                      *INFO2-HISTORY-BACK-LIST*
                                      *INFO2-HISTORY-FORWARD-LIST*
                                      *INFO2-SEARCH-BUFFER-NAME*
                                      )

    t
    )


(defun info2-get-index-node-list ()
    "全ての Index ノードを検索しローカル変数をセット。"

    ;; 全てのIndex ノードを検索
    (if *INFO2-INDIRECT-FILE-LIST*
            ;; Indirect ファイルがあるとき
            (progn
                ;; Indirect バッファに移動
                (set-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))

                ;; Indirect ファイル内を順次検索
                (dolist (list-file-path *INFO2-INDIRECT-FILE-LIST*)
                    ;; Indirect ファイルを上書き挿入
                    (erase-buffer (selected-buffer))
                    (insert-file-contents list-file-path t)

                    ;; Index ノード検索
                    (while (scan-buffer *info2-index-marker-string* :case-fold t :no-dup t)
                        (save-excursion
                            (scan-buffer *info2-regexp-node-line* :case-fold t :regexp t :reverse t)
                            ;; Index Node のリスト (後でひっくり返す)
                            (push (match-string 2) *INFO2-INDEX-NODE-LIST*)
                            )
                        )
                    )
                )

        ;; Indirect ファイルがないとき
        (progn
            ;; Tag Table バッファ先頭へ
            (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
            (goto-char (point-min))

            ;; Index ノード検索
            (while (scan-buffer *info2-index-marker-string* :case-fold t :no-dup t)
                (save-excursion
                    (scan-buffer *info2-regexp-node-line* :case-fold t :regexp t :reverse t)
                    ;; Index Node のリスト (後でひっくり返す)
                    (push (match-string 2) *INFO2-INDEX-NODE-LIST*)
                    )
                )
            )
        )

    ;; ローカル変数セット
    (if *INFO2-INDEX-NODE-LIST*
            ;; Index が存在すれば設定
            (progn
                ;; Index ノードリスト
                (setf *INFO2-INDEX-NODE-LIST* (reverse *INFO2-INDEX-NODE-LIST*))

                ;; 各バッファにローカル変数セット
                (info2-set-local-value-all-buffer *INFO2-FILE-PATH*
                                                  *INFO2-BUFFER-NAME*
                                                  *INFO2-CURRENT-NODE*
                                                  *INFO2-TAG-TABLE-BUFFER-NAME*
                                                  *INFO2-INDIRECT-BUFFER-NAME*
                                                  *INFO2-INDIRECT-FILE-LIST*
                                                  *INFO2-INDIRECT-POS-LIST*
                                                  *INFO2-INDEX-NODE-LIST*
                                                  *INFO2-HISTORY-BACK-LIST*
                                                  *INFO2-HISTORY-FORWARD-LIST*
                                                  *INFO2-SEARCH-BUFFER-NAME*
                                                  )
                )

        ;; Index がないとき
        nil
        )
    )


(defun info2-get-indirect (
                           info-file-directory
                           tag-table-buffer-name
                           )
    "\
Indirect ファイルが存在すれば `*INFO2-INDIRECT-FILE-LIST*`、
`*INFO2-INDIRECT-POS-LIST*` を返す。

INFO-FILE-DIRECTORY   : Info ファイルのあるディレクトリ。
TAG-TABLE-BUFFER-NAME : Tag Table バッファ名.
"
    (let (
          ;; 検索リミット
          let-limit-pos
          ;; Indirect ファイル名と位置の検索用正規表現  (file.info-1: 123)
          (let-regexp (compile-regexp "^\\([^:\n]+\\): \\([0-9]+\\)$" t))
          ;; *INFO2-INDIRECT-FILE-LIST*
          let-indirect-file-list
          ;; *INFO2-INDIRECT-POS-LIST*
          let-indirect-pos-list
          )

        ;; Tag Table バッファ先頭へ
        (set-buffer (find-buffer tag-table-buffer-name))
        (goto-char (point-min))

        (if (scan-buffer "\37\nindirect:\n" :case-fold t :tail t)
                ;; Indirect ファイルが存在するとき
                (progn
                    (setf let-limit-pos (point))
                    ;; \37 = ""
                    (scan-buffer "\37")

                    ;; 全ての Indirect ファイル名と Position をそれぞれリストに格納
                    (while (scan-buffer let-regexp
                                        :limit let-limit-pos
                                        :no-dup t
                                        :regexp t
                                        :reverse t
                                        )
                        (push (merge-pathnames (match-string 1) info-file-directory)
                              let-indirect-file-list
                              )
                        (push (parse-integer (match-string 2))
                              let-indirect-pos-list
                              )
                        )
                    )

            ;; Indirect ファイルが存在しないとき
            (setf let-indirect-file-list nil
                  let-indirect-pos-list nil
                  )
            )

        ;; 返却値
        (values let-indirect-file-list
                let-indirect-pos-list
                )
        )
    )


(defun info2-set-indirect-buffer (
                                  info-file-path
                                  tag-table-buffer-name
                                  )
    "\
Indirect ファイルがあればバッファをセットし、そのバッファ名と設定した
`*INFO2-INDIRECT-FILE-LIST*`、`*INFO2-INDIRECT-POS-LIST*` を返す。

INFO-FILE-PATH        : Info ファイルのパス。
TAG-TABLE-BUFFER-NAME : Tag Table バッファ名。
"
    (let (
          ;; Indirect バッファ名
          let-indirect-buffer-name
          ;; *INFO2-INDIRECT-FILE-LIST*
          let-indirect-file-list
          ;; *INFO2-INDIRECT-POS-LIST*
          let-indirect-pos-list
          )
        (multiple-value-bind (var-indirect-file-list var-indirect-pos-list)
                ;; *INFO2-INDIRECT-FILE-LIST*、*INFO2-INDIRECT-POS-LIST* 取得
                (info2-get-indirect (directory-namestring info-file-path) tag-table-buffer-name)

            (if var-indirect-file-list
                    ;; Indirect ファイルが存在するとき
                    (progn
                        ;; Indirect バッファ作成
                        (set-buffer (create-new-buffer *info2-default-indirect-buffer-name*))
                        (kill-all-local-variables)
                        (make-local-variable 'auto-save)
                        (make-local-variable 'make-backup-files)
                        (make-local-variable 'kept-undo-information)
                        (setf
                         make-backup-files nil
                         auto-save nil
                         kept-undo-information nil
                         ;; Indirect バッファ名
                         let-indirect-buffer-name (buffer-name (selected-buffer))
                         ;; *INFO2-INDIRECT-FILE-LIST*
                         let-indirect-file-list var-indirect-file-list
                         ;; *INFO2-INDIRECT-POS-LIST*
                         let-indirect-pos-list var-indirect-pos-list
                         )

                        ;; Tag Table バッファへ
                        (set-buffer (find-buffer tag-table-buffer-name))
                        )

                ;; Indirect ファイルがないとき
                (setf let-indirect-buffer-name nil
                      let-indirect-file-list nil
                      let-indirect-pos-list nil
                      )
                )
            )

        ;; 返却値
        (values let-indirect-buffer-name
                let-indirect-file-list
                let-indirect-pos-list
                )
        )
    )


(defun info2-set-tag-buffer (
                             info-file-path
                             info-buffer-name
                             )
    "\
Tag Table バッファをセットし、そのバッファ名と
`*INFO2-INDIRECT-BUFFER-NAME*`、`*INFO2-INDIRECT-FILE-LIST*`、
`*INFO2-INDIRECT-POS-LIST*` を返す。

INFO-FILE-PATH   : Info ファイルのパス。
INFO-BUFFER-NAME : Info バッファ名。
"
    (let (
          ;; Tag Table バッファ名
          let-tag-table-buffer-name
          ;; *INFO2-INDIRECT-BUFFER-NAME*
          let-indirect-buffer-name
          ;; *INFO2-INDIRECT-FILE-LIST*
          let-indirect-file-list
          ;; *INFO2-INDIRECT-POS-LIST*
          let-indirect-pos-list
          )

        (if (and *INFO2-TAG-TABLE-BUFFER-NAME*
                 (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*)
                 )
                ;; Tag Table バッファが既に存在するとき
                (progn
                    (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
                    (setf let-tag-table-buffer-name *INFO2-TAG-TABLE-BUFFER-NAME*)

                    ;; 表示している Info ファイルが異なれば設定しなおす
                    (if (string-not-equal info-file-path *INFO2-FILE-PATH*)
                            (progn
                                (erase-buffer (selected-buffer))
                                (insert-file-contents info-file-path t)

                                (multiple-value-bind (
                                                      var-indirect-buffer-name
                                                      var-indirect-file-list
                                                      var-indirect-pos-list
                                                      )
                                        ;; Indirect バッファをセット
                                        (info2-set-indirect-buffer info-file-path
                                                                   let-tag-table-buffer-name
                                                                   )
                                    (setf let-indirect-buffer-name var-indirect-buffer-name
                                          let-indirect-file-list var-indirect-file-list
                                          let-indirect-pos-list var-indirect-pos-list
                                          )
                                    )
                                )
                        ;; 同じであればそのまま
                        (setf let-indirect-buffer-name *INFO2-INDIRECT-BUFFER-NAME*
                              let-indirect-file-list *INFO2-INDIRECT-FILE-LIST*
                              let-indirect-pos-list *INFO2-INDIRECT-POS-LIST*
                              )
                        )
                    )

            ;; Tag Table バッファが存在しないとき
            (progn
                (set-buffer (create-new-buffer *info2-default-tag-table-buffer-name*))
                (setf let-tag-table-buffer-name (buffer-name (selected-buffer)))

                (kill-all-local-variables)
                (make-local-variable 'auto-save)
                (make-local-variable 'make-backup-files)
                (make-local-variable 'kept-undo-information)
                (setf make-backup-files nil
                      auto-save nil
                      kept-undo-information nil
                      )
                (insert-file-contents info-file-path t)

                (multiple-value-bind (
                                      var-indirect-buffer-name
                                      var-indirect-file-list
                                      var-indirect-pos-list
                                      )
                        ;; Indirect バッファをセット
                        (info2-set-indirect-buffer info-file-path
                                                   let-tag-table-buffer-name
                                                   )

                    (setf let-indirect-buffer-name var-indirect-buffer-name
                          let-indirect-file-list var-indirect-file-list
                          let-indirect-pos-list var-indirect-pos-list
                          )
                    )
                )
            )

        ;; 返却値
        (values let-tag-table-buffer-name
                let-indirect-buffer-name
                let-indirect-file-list
                let-indirect-pos-list
                )
        )
    )


(defun info2-load-keyword-file (
                                info-file-path
                                &optional keyword-file-path
                                )
    "\
キーワードファイルをロード。

INFO-FILE-PATH    : Info ファイルのパス。
KEYWORD-FILE-PATH : キーワードファイルのパス。
"
    ;; Info バッファへ
    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))

    (unless keyword-file-path
        ;; キーワードファイルが指定されていなければ設定した連想リストから
        (setf keyword-file-path (cdr (assoc info-file-path
                                            *info2-keyword-file-alist*
                                            :test 'path-equal
                                            )
                                     )
              )
        )

    ;; キーワードファイル設定
    (if (and keyword-file-path
             (file-readable-p keyword-file-path)
             )
            ;; キーワードファイルが指定されているとき
            (progn
                (make-local-variable 'keyword-hash-table)
                (setf keyword-hash-table (load-keyword-file keyword-file-path))
                (message "Load Keyword File \"~A\"" keyword-file-path)
                t
                )

        ;; 指定されていなけいとき
        (progn
            (if keyword-hash-table
                    (progn
                        ;; 色付けされていればクリア
                        (make-local-variable 'keyword-hash-table)
                        (setf keyword-hash-table nil)
                        (message "Clear Keyword")
                        t
                        )
                nil
                )
            )
        )
    )


(defun info2-change-file (
                          info-file-path
                          node
                          )
    "\
指定された Info ファイルを開き、バッファ & ローカル変数をセット。

INFO-FILE-PATH : 開く Info ファイルのパス。
NODE           : 表示するノード。
"
    ;; とりあえず Indirect バッファは削除
    (if (and *INFO2-INDIRECT-BUFFER-NAME*
             (find-buffer *INFO2-INDIRECT-BUFFER-NAME*)
             )
            (delete-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))
        )

    ;; Search バッファもあれば削除
    (when (and *INFO2-SEARCH-BUFFER-NAME*
               (find-buffer *INFO2-SEARCH-BUFFER-NAME*)
               )
        ;; ウィンドウがあれば消す
        (when (get-buffer-window (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
            (set-window (get-buffer-window (find-buffer *INFO2-SEARCH-BUFFER-NAME*)))
            (delete-window)
            )
        (delete-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
        )

    (multiple-value-bind (
                          var-tag-table-buffer-name
                          var-indirect-buffer-name
                          var-indirect-file-list
                          var-indirect-pos-list
                          )
            ;; 各バッファをセット
            (info2-set-tag-buffer info-file-path
                                  *INFO2-BUFFER-NAME*
                                  )

        ;; Buffer Local 変数設定
        (info2-set-local-value-all-buffer info-file-path
                                          *INFO2-BUFFER-NAME*
                                          node
                                          var-tag-table-buffer-name
                                          var-indirect-buffer-name
                                          var-indirect-file-list
                                          var-indirect-pos-list
                                          ;; *INFO2-INDEX-NODE-LIST* は nil に
                                          nil
                                          *INFO2-HISTORY-BACK-LIST*
                                          *INFO2-HISTORY-FORWARD-LIST*
                                          ;; Search バッファは削除
                                          nil
                                          )

        ;; キーワードファイル設定
        (info2-load-keyword-file info-file-path)
        )

    t
    )


(defun info2-change-full-path (path)
    "\
相対パスをフルパスに変換。

PATH : 変換するパス。\"dir\" となるとき DIR ファイルへのフルパスを返す。

\"./～\" や \"../～\" は表示している Info ファイルからの位置、\"foo/～\"、
\"bar\" 等は Info ディレクトリからの位置とする。
"
    (let (let-full-path)
        (if (string-equal path "dir")
                ;; DIR ファイルへのパス
                (setf let-full-path (merge-pathnames "dir" *info2-dir*))

            (if (string-match "^\\.\\.?/" path)
                    ;; 相対パス ( "./～", "../～") のとき
                    ;; 現在表示している Info ファイルからの相対位置とする
                    (setf let-full-path (merge-pathnames path (default-directory)))

                ;; そうでなければ 指定された Info ディレクトリからの位置
                (setf let-full-path (merge-pathnames path *info2-dir*))
                )
            )

        let-full-path
        )
    )


(defun info2-divide-node (node)
    "\
ノードをパス部分と名称部分にわける。

NODE : わけるノード。
"
    (let (
          ;; パス部分
          let-path
          ;; 名称部分
          let-node-name
          ;; Match Index
          let-match-index
          )

        (if (string-match *info2-regexp-node* node)
                ;; "(パス)ノード名" みたいなとき
                (setf
                 ;; ノード名がないときは Top へ
                 let-node-name (if (or (not (match-string 2))
                                       (string-equal (match-string 2) "")
                                       )
                                       "top"
                                   (match-string 2)
                                   )
                 ;; フルパスにして格納
                 let-path (info2-change-full-path (match-string 1))
                 )

            ;; ノード名のみのとき
            (setf let-path nil
                  let-node-name node
                  )
            )

        (values let-path
                let-node-name
                )
        )
    )


(defun info2-view-node (
                        node
                        history
                        &optional (his-pos 0)
                        )
    "\
ノード表示。

NODE    : 表示するノード。
HISTORY : 履歴に追加するか。
HIS-POS : 履歴に追加するポイント位置。
"
    (let (
          ;; 表示するノード
          let-node

          ;; 指定 Node の全内容を格納
          let-node-contents
          ;; Node 位置を格納
          let-node-pos
          ;; 表示する Indirect ファイルリスト番号
          (let-num -1)
          ;; 関数実行前の表示していた Info ファイルのパス
          (let-file-path *INFO2-FILE-PATH*)
          ;; 関数実行前のカレントノード
          (let-current-node *INFO2-CURRENT-NODE*)
          )

        (if history
                ;; 戻る履歴に追加
                (info2-history-add 1
                                   *INFO2-FILE-PATH*
                                   *INFO2-CURRENT-NODE*
                                   his-pos
                                   )
            )

        (multiple-value-bind (var-path var-node-name)
                ;; ノードをパス部分と名称部分にわける
                (info2-divide-node node)

            (if (and var-path
                     (string-not-equal var-path *INFO2-FILE-PATH*)
                     )
                    ;; 別ファイルとなるとき
                    (if (and (file-exist-p var-path)
                             (file-readable-p var-path)
                             )
                            ;; ファイルが見つかれば、バッファ & ローカル変数をセット
                            (info2-change-file var-path var-node-name)

                        ;; ファイルが見つからないとき
                        (progn
                            ;; Buffer Local 変数設定
                            (info2-set-local-value-all-buffer let-file-path
                                                              *INFO2-BUFFER-NAME*
                                                              let-current-node
                                                              *INFO2-TAG-TABLE-BUFFER-NAME*
                                                              *INFO2-INDIRECT-BUFFER-NAME*
                                                              *INFO2-INDIRECT-FILE-LIST*
                                                              *INFO2-INDIRECT-POS-LIST*
                                                              *INFO2-INDEX-NODE-LIST*
                                                              (if history
                                                                      ;; 追加した履歴を取り除く
                                                                      (cdr *INFO2-HISTORY-BACK-LIST*)
                                                                  *INFO2-HISTORY-BACK-LIST*
                                                                  )
                                                              *INFO2-HISTORY-FORWARD-LIST*
                                                              *INFO2-SEARCH-BUFFER-NAME*
                                                              )
                            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                            (plain-error "ファイルが見つかりません \"~A\"" var-path)
                            )
                        )

                ;; 同じファイルまたはノード名のみのとき
                (info2-set-local-value-all-buffer *INFO2-FILE-PATH*
                                                  *INFO2-BUFFER-NAME*
                                                  var-node-name
                                                  *INFO2-TAG-TABLE-BUFFER-NAME*
                                                  *INFO2-INDIRECT-BUFFER-NAME*
                                                  *INFO2-INDIRECT-FILE-LIST*
                                                  *INFO2-INDIRECT-POS-LIST*
                                                  *INFO2-INDEX-NODE-LIST*
                                                  *INFO2-HISTORY-BACK-LIST*
                                                  *INFO2-HISTORY-FORWARD-LIST*
                                                  *INFO2-SEARCH-BUFFER-NAME*
                                                  )
                )

            ;; Tag Table バッファ先頭へ
            (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
            (goto-char (point-min))

            (setf let-node (substitute-string (substitute-string var-node-name
                                                                 "\\*"
                                                                 "\\\\*"
                                                                 )
                                              "\\+"
                                              "\\\\+"
                                              )
                  )

            (scan-buffer "\37\ntag table:\n" :case-fold t :tail t)

            (if (scan-buffer (concat "node: "
                                     let-node
                                     "\177\\([0-9]+\\)$"
                                     ) ; \177 = ""
                             :case-fold t
                             :regexp t
                             )
                    ;; Node 位置を格納
                    (setf let-node-pos (parse-integer (match-string 1)))

                ;; 指定された Node が見つからないとき
                (progn
                    ;; Buffer Local 変数設定
                    (info2-set-local-value-all-buffer let-file-path
                                                      *INFO2-BUFFER-NAME*
                                                      let-current-node
                                                      *INFO2-TAG-TABLE-BUFFER-NAME*
                                                      *INFO2-INDIRECT-BUFFER-NAME*
                                                      *INFO2-INDIRECT-FILE-LIST*
                                                      *INFO2-INDIRECT-POS-LIST*
                                                      *INFO2-INDEX-NODE-LIST*
                                                      (if history
                                                              ;; 追加した履歴を取り除く
                                                              (cdr *INFO2-HISTORY-BACK-LIST*)
                                                          *INFO2-HISTORY-BACK-LIST*
                                                          )
                                                      *INFO2-HISTORY-FORWARD-LIST*
                                                      *INFO2-SEARCH-BUFFER-NAME*
                                                      )

                    ;; キーワードファイル設定
                    (info2-load-keyword-file let-file-path)

                    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                    (plain-error "ノードが見つかりません \"~A\"" node)
                    )
                )

            ;; 指定 Node の全内容を取得
            (if *INFO2-INDIRECT-FILE-LIST*
                    ;; Indirect File があるとき
                    (progn
                        ;; Indirect ファイルリスト番号を算出
                        (dolist (list-indirect-pos *INFO2-INDIRECT-POS-LIST*)
                            (if (>= let-node-pos list-indirect-pos)
                                    (incf let-num)
                                )
                            )

                        ;; Indirect ファイルが読み取れないとき
                        (unless (and (file-exist-p (nth let-num *INFO2-INDIRECT-FILE-LIST*))
                                     (file-readable-p (nth let-num *INFO2-INDIRECT-FILE-LIST*))
                                     )
                            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                            (plain-error "Indirect ファイルが見つかりません \"~A\""
                                         (nth let-num *INFO2-INDIRECT-FILE-LIST*)
                                         )
                            )

                        ;; Indirect バッファ
                        (set-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))

                        (erase-buffer (selected-buffer))
                        (insert-file-contents (nth let-num *INFO2-INDIRECT-FILE-LIST*) t)

                        (setf let-node-contents (buffer-substring (progn
                                                                      (scan-buffer (concat "\37\n\\(file:[ ]+"
                                                                                           (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                                                                           ",[ ]+node:[ ]+"
                                                                                           let-node
                                                                                           "[\n,]\\)"
                                                                                           )
                                                                                   :case-fold t
                                                                                   :regexp t
                                                                                   )
                                                                      (match-beginning 1)
                                                                      )
                                                                  (progn
                                                                      (scan-buffer "\37\\|\\'" :no-dup t :regexp t)
                                                                      (point)
                                                                      )
                                                                  )
                              )
                        )

                ;; Indirect File がないとき
                (progn
                    ;; Tag Table バッファ先頭へ
                    (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
                    (goto-char (point-min))

                    (setf let-node-contents (buffer-substring (progn
                                                                  (scan-buffer (concat "\37\n\\(file:[ ]+"
                                                                                       (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                                                                       ",[ ]+node:[ ]+"
                                                                                       let-node
                                                                                       "[\n,]\\)"
                                                                                       )
                                                                               :case-fold t
                                                                               :regexp t
                                                                               )
                                                                  (match-beginning 1)
                                                                  )
                                                              (progn
                                                                  (scan-buffer "\37" :no-dup t)
                                                                  (point)
                                                                  )
                                                              )
                          )
                    )
                )
            )

        (if let-node-contents
                ;; ノード内容表示
                (progn
                    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                    (setf buffer-read-only nil)
                    (erase-buffer (selected-buffer))
                    (insert let-node-contents)
                    (goto-char (point-min))
                    (set-buffer-modified-p nil)
                    (setf buffer-read-only t)

                    ;; Mode Line 設定
                    (make-local-variable 'mode-line-format)
                    (setf mode-line-format (buffer-substring (point)
                                                             (save-excursion
                                                                 (goto-eol)
                                                                 (point)
                                                                 )
                                                             )
                          )

                    ;; 色付け
                    (if *info2-fontify-p*
                            (info2-fontify)
                        )

                    t
                    )

            ;; ノード内容が見つからないとき
            (progn
                ;; Buffer Local 変数設定
                (info2-set-local-value-all-buffer let-file-path
                                                  *INFO2-BUFFER-NAME*
                                                  let-current-node
                                                  *INFO2-TAG-TABLE-BUFFER-NAME*
                                                  *INFO2-INDIRECT-BUFFER-NAME*
                                                  *INFO2-INDIRECT-FILE-LIST*
                                                  *INFO2-INDIRECT-POS-LIST*
                                                  *INFO2-INDEX-NODE-LIST*
                                                  (if history
                                                          ;; 追加した履歴を取り除く
                                                          (cdr *INFO2-HISTORY-BACK-LIST*)
                                                      *INFO2-HISTORY-BACK-LIST*
                                                      )
                                                  *INFO2-HISTORY-FORWARD-LIST*
                                                  *INFO2-SEARCH-BUFFER-NAME*
                                                  )

                ;; キーワードファイル設定
                (info2-load-keyword-file let-file-path)

                (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                (plain-error "ノード内容が見つかりません \"~A\"" node)
                )
            )
        )
    )


(defun info2-get-nearest-reference ()
    "\
カーソル近くの相互参照 or Menu が指すノードと、Index であればその行位置
を取得し返す。
"
    (let (
          ;; 検索リミット
          (let-lim (save-excursion
                       (goto-bol)
                       (point)
                       )
                   )
          ;; ノード
          let-node
          ;; Index が示す行位置
          let-line
          )

        (save-excursion
            (cond
             ;; ノードラインのとき
             (
              (= (current-line-number) 1)
              (scan-buffer *info2-regexp-node-line-part* :no-dup t :regexp t :reverse t)

              (if (find (match-string 1) '("next" "prev" "up") :test 'string-equal)
                      ;; Next or Prev or Up ノード格納
                      (setf let-node (match-string 2))
                  )
              )

             ;; Index
             (
              (scan-buffer *info2-regexp-index-entry*
                           :case-fold t
                           :limit let-lim
                           :regexp t
                           :reverse t
                           )
              ;; ノードと行位置を格納
              (setf let-node (match-string 1)
                    let-line (parse-integer (match-string 2))
                    )
              )

             ;; 相互参照 or Menu
             (
              (scan-buffer *info2-regexp-cross-reference*
                           :case-fold t
                           :limit let-lim
                           :regexp t
                           :reverse t
                           )
              (if (string-equal (match-string 3) ": ")
                      ;; ":" のみのとき
                      (setf let-node (string-right-trim "."
                                                        (string-right-trim ")" (match-string 6))
                                                        )
                            )
                  ;; "::" が付くとき
                  (setf let-node (match-string 2))
                  )
              )
             )
            )

        (values let-node
                let-line
                )
        )
    )


(defun info2-view-nearest-reference ()
    "現在行の相互参照 or Menu が指すノードへ移動。"

    (multiple-value-bind (var-node var-line)
            ;; ノードと行位置を取得
            (info2-get-nearest-reference)
        (if var-node
                ;; ノードが取得できれば表示
                (progn
                    (info2-view-node var-node t (point))

                    (if var-line
                            (goto-line var-line)
                        )
                    t
                    )

            ;; ノードが見つからないとき
            nil
            )
        )
    )


(defun info2-get-node-line-node (pointer)
    "\
Next or Prev or Up ノードを取得し返す。

POINTER:
1 - Next
2 - Prev
3 - Up
"
    ;; Info バッファへ
    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
    (save-excursion
        (goto-char (point-min))
        (goto-eol)

        (case pointer
            ;; Next
            (1 (scan-buffer *info2-regexp-next*
                            :case-fold t
                            :regexp t
                            :reverse t
                            )
               )
            ;; Prev
            (2 (scan-buffer *info2-regexp-prev*
                            :case-fold t
                            :regexp t
                            :reverse t
                            )
               )
            ;; Up
            (3 (scan-buffer *info2-regexp-up*
                            :case-fold t
                            :regexp t
                            :reverse t
                            )
               )
            ;; その他エラー
            (t (plain-error "引数がおかしい"))
            )
        )

    ;; ノードを返却
    (if (and (match-string 1)
             (string-not-equal (string-trim " \t" (match-string 1))
                               ""
                               )
             )
            (match-string 1)
        nil
        )
    )


(defun info2-view-node-line-node (
                                  pointer
                                  history
                                  &optional (pos 0)
                                  )
    "\
Next or Prev or Up Node へ移動。

POINTER : 1: Next 2: Prev 3: Up.
HISTORY : nil であれば履歴に追加しない。
POS     : 履歴に追加するポイント位置。
"
    (let (
          ;; 移動する Node
          let-node
          ;; Node パス部分
          let-path
          ;; Node ノード名部分 or 単なるノード名
          let-node-name
          )

        (if (setf let-node (info2-get-node-line-node pointer))
                ;; Node が見つかれば移動
                (info2-view-node let-node history pos)
            ;; 見つからないとき
            nil
            )
        )
    )


(defun info2-move-history (
                           his-arg
                           history
                           &optional (his-pos 0)
                           )
    "\
ノード履歴移動。

HIS-ARG :
1 - 進む。
2 - 戻る。

HISTORY : nil でなければ逆の履歴に追加。
HIS-POS : 履歴に追加するポイント位置。
"
    (let (
          ;; Back or Forward History List
          (let-history-list (case his-arg
                                ;; Forward
                                (1 (pop *INFO2-HISTORY-FORWARD-LIST*))
                                ;; Back
                                (2 (pop *INFO2-HISTORY-BACK-LIST*))
                                )
                            )
          ;; 履歴ファイル
          let-file
          ;; 履歴ノード
          let-node
          ;; 履歴位置
          let-pos
          )

        (if let-history-list
                (progn
                    (setf let-file (nth 0 let-history-list)
                          let-node (nth 1 let-history-list)
                          let-pos (nth 2 let-history-list)
                          )

                    (if history
                            ;; Forward or Back History に追加
                            (info2-history-add his-arg
                                               *INFO2-FILE-PATH*
                                               *INFO2-CURRENT-NODE*
                                               his-pos
                                               )
                        )

                    (info2-view-node (if let-file
                                             (concat "("
                                                     let-file
                                                     ")"
                                                     let-node
                                                     )
                                         let-node
                                         )
                                     nil
                                     )
                    (goto-char let-pos)
                    (recenter)
                    )

            ;; 履歴リストが空のとき
            nil
            )
        )
    )


(defun info2-scroll-page (arg)
    "\
ページスクロール。

ARG :
1  - 下へ
-1 - 上へ。
"
    (let (
          ;; スクロールする行数
          (let-nlines (max (truncate (* (window-height) 4/5)) 1))
          )
        (if (and (= arg 1)
                 (> (+ (window-lines) (get-window-start-line))
                    (buffer-lines)
                    )
                 )
                ;; 下へページスクロールするとき、バッファ末尾が見えてい
                ;; るときはそこへ移動
                (if (= (point) (point-max))
                        ;; 既にバッファ末尾なら nil を返す
                        nil
                    (goto-line (buffer-lines))
                    )

            (if (and (= arg -1)
                     (= (get-window-start-line) 1)
                     )
                    ;; 上へページスクロールするとき、バッファ先頭が見え
                    ;; ているときはそこへ移動
                    (if (= (point) (point-min))
                            ;; 既にバッファ先頭であれば nil を返す
                            nil
                        (goto-char (point-min))
                        )

                (if *info2-smooth-scroll-p*
                        ;; ずるずるスクロール
                        (dotimes (count-nlines let-nlines t)
                            (scroll-window arg)
                            (refresh-screen)
                            )
                    (next-page arg)
                    )
                )
            )
        )
    )


(defun info2-move-reference (rev)
    "\
次 or 前の相互参照位置に移動。

REV : t のとき前の相互参照位置に移動。
"
    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
    (if (scan-buffer *info2-regexp-cross-reference*
                     :no-dup t
                     :case-fold t
                     :reverse rev
                     :regexp t
                     )
            t
        nil
        )
    )


(defun info2-view-backward-node ()
    "前のノードへ移動。"
    (let (
          ;; 実行前ポイント
          (let-pos (point))
          )

        ;; Info バッファ先頭行末に移動
        (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (goto-char (point-min))
        (goto-eol)

        ;; 1. Prev 2. Up
        (cond
         ;; Prev
         (
          (and (save-excursion (scan-buffer *info2-regexp-prev* :case-fold t :regexp t :reverse t))
               (string-not-equal (match-string 1) "(dir)")
               )
          (info2-view-node-line-node 2 t let-pos)
          )

         ;; Up
         (
          (and (save-excursion (scan-buffer *info2-regexp-up* :case-fold t :regexp t :reverse t))
               (string-not-equal (match-string 1) "(dir)")
               )
          (info2-view-node-line-node 3 t let-pos)
          )

         ;; 元の位置へ
         (
          t
          (goto-char let-pos)
          nil
          )
         )
        )
    )


(defun info2-view-forward-node ()
    "次のノードへ移動。"
    (let (
          ;; 実行前ポイント
          (let-pos (point))
          ;; 移動するノード
          let-node
          )

        ;; Info バッファ先頭行末に移動
        (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (goto-char (point-min))
        (goto-eol)

        ;; 1. メニュー (Index はダメ、"\n* menu:" で判断)
        ;; 2. Next
        ;; 3. Up して Next
        (cond
         ;; メニューがあるか
         (
          (and (not (scan-buffer *info2-index-marker-string* :case-fold t))
               (scan-buffer *info2-regexp-menu* :case-fold t :regexp t)
               (scan-buffer *info2-regexp-cross-reference* :case-fold t :regexp t)
               )

          ;; ノード格納
          (if (string-equal (match-string 3) ": ")
                  ; ":" のとき
                  (setf let-node (string-right-trim "."
                                                    (string-right-trim ")" (match-string 6)))
                        )
              ;; "::" が付くとき
              (setf let-node (match-string 2))
              )

          (info2-view-node let-node t let-pos)
          )

         ;; Next
         (
          (scan-buffer *info2-regexp-next* :case-fold t :regexp t :reverse t)
          ;; Next ノードへ
          (info2-view-node-line-node 1 t let-pos)
          )

         ;; Up → Next
         (
          (and (scan-buffer *info2-regexp-up* :case-fold t :regexp t :reverse t)
               (string-not-equal "top"
                                 (setf let-node (match-string 1))
                                 )
               )
          ;; Up ノードへ
          (info2-view-node-line-node 3 t let-pos)
          (unless (info2-view-node-line-node 1 nil)
              ;; Next ノードがなければ戻す
              (info2-move-history 2 nil)
              nil
              )
          )

         ;; 元の位置へ
         (
          t
          (goto-char let-pos)
          nil
          )
         )
        )
    )


;;====================================
;; Search モード

(defun info2-search-get-string ()
    "Search バッファが [Search] であれば検索文字列を返す。"

    (if (find-buffer *INFO2-SEARCH-BUFFER-NAME*)
            (progn
                (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
                (save-excursion
                    (goto-char (point-min))
                    (scan-buffer "\\[\\(.+\\)\\] \\(.*\\)$"
                                 :case-fold t
                                 :regexp t
                                 )
                    )

                (if (string-equal (match-string 1)
                                  "Search"
                                  )
                        ;; [Search] なら検索文字列を色付け
                        (match-string 2)
                    nil
                    )
                )
        ;; Search バッファが見つからなかったとき
        nil
        )
    )


(defun info2-search-view-node (
                               info-win
                               ret-sch-win
                               close-sch-win
                               search-string
                               )
    "\
Search ウィンドウにおいて現在行のノードを Info バッファに表示。

INFO-WIN :
nil のときカレントウィンドウに Info バッファをセット。t のとき Info ウィ
ンドウがなければ他のウィンドウを消して作成。

RET-SCH-WIN   : t のとき Search ウィンドウに戻る。

CLOSE-SCH-WIN : t のとき Search ウィンドウを閉じる。

SEARCH-STRING :
指定された文字列で色付け。nil であれば行全体を色付け。
"
    (let (
          let-win
          (let-info-buf (find-buffer *INFO2-BUFFER-NAME*))
          )

        (if let-info-buf
                ;; Info バッファがあれば
                (progn
                    ;; Search バッファへ
                    (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))

                    (multiple-value-bind (var-node var-line)
                            ;; カーソル位置のノード名と Line を取得
                            (info2-get-nearest-reference)
                        (if var-node
                                ;; ノードが取得できれば表示
                                (progn
                                    (if close-sch-win
                                            ;; Search ウィンドウを閉じる
                                            (delete-window)
                                        )

                                    (if (setf let-win (get-buffer-window let-info-buf))
                                            ;; Info ウィンドウがあれば移動
                                            (set-window let-win)
                                        ;; Info ウィンドウがないとき
                                        (if info-win
                                                ;; 他のウィンドウを消して作成
                                                (progn
                                                    (delete-other-windows)
                                                    (split-window (floor (/ (window-columns)
                                                                            *info2-window-width*)
                                                                         )
                                                                  t
                                                                  )
                                                    (other-window)
                                                    ;; Info バッファセット
                                                    (set-buffer let-info-buf)
                                                    )
                                            ;; カレントウィンドウにバッファセット
                                            (set-buffer let-info-buf)
                                            )
                                        )

                                    (info2-view-node var-node nil)

                                    (if var-line
                                            (goto-line var-line)
                                        )

                                    (if *info2-fontify-p*
                                            (if search-string
                                                    ;; 検索文字列 色付け
                                                    (if (save-excursion (scan-buffer (concat "\\("
                                                                                             search-string
                                                                                             "\\)"
                                                                                             )
                                                                                     :case-fold t
                                                                                     :regexp t
                                                                                     )
                                                            )
                                                            (set-text-attribute (match-beginning 1)
                                                                                (match-end 1)
                                                                                'search-string
                                                                                :bold *info2-search-bold-p*
                                                                                :foreground *info2-search-fgcolor*
                                                                                :background *info2-search-bgcolor*
                                                                                )
                                                        )

                                                ;; 行全体を色付け
                                                (set-text-attribute (save-excursion
                                                                        (goto-bol)
                                                                        (point)
                                                                        )
                                                                    (save-excursion
                                                                        (goto-eol)
                                                                        (point)
                                                                        )
                                                                    'search-string
                                                                    :bold *info2-search-bold-p*
                                                                    :foreground *info2-search-fgcolor*
                                                                    :background *info2-search-bgcolor*
                                                                    )
                                                )
                                        )

                                    (when ret-sch-win
                                        ;; Search ウィンドウへ
                                        (set-window (get-buffer-window *INFO2-SEARCH-BUFFER-NAME*))
                                        ;; メッセージ表示
                                        (message "~A"
                                                 (buffer-substring (save-excursion
                                                                       (goto-bol)
                                                                       (point)
                                                                       )
                                                                   (save-excursion
                                                                       (goto-eol)
                                                                       (point)
                                                                       )
                                                                   )
                                                 )
                                        )
                                    t
                                    )

                            ;; ノードが取得できないとき
                            nil
                            )
                        )
                    )

            ;; Info バッファが見つからなければ終了させる
            (progn
                (info2-close-all-buffer)
                (plain-error "Info バッファが見つかりませんでした。")
                )
            )
        )
    )


(defun info2-search-mode (
                          info-file-path
                          info-buffer-name
                          current-node
                          tag-table-buffer-name
                          indirect-buffer-name
                          indirect-file-list
                          indirect-pos-list
                          index-node-list
                          history-back-list
                          history-forward-list
                          )
    "Search バッファ生成。"

    ;; 既に同名バッファが存在すれば <1>, <2> と番号を付けたバッファを生成
    (set-buffer (create-new-buffer *info2-default-search-buffer-name*))

    (kill-all-local-variables)

    (make-local-variable 'auto-save)
    (make-local-variable 'make-backup-files)
    (make-local-variable 'kept-undo-information)

    (setf auto-save nil
          make-backup-files nil
          kept-undo-information nil

          mode-name "info2-search"
          buffer-mode 'info2-search-mode
          )

    (use-keymap *info2-search-mode-map*)
    (use-syntax-table *text-mode-syntax-table*)

    ;; 非表示 Window Flag 設定
    (set-local-window-flags (selected-buffer) *info2-search-buffer-flags* nil)

    (set-buffer-fold-width nil)
    (setf buffer-read-only t)

    ;; Buffer Local 変数設定
    (info2-set-local-value-all-buffer info-file-path
                                      info-buffer-name
                                      current-node
                                      tag-table-buffer-name
                                      indirect-buffer-name
                                      indirect-file-list
                                      indirect-pos-list
                                      index-node-list
                                      history-back-list
                                      history-forward-list
                                      ;; 生成した Search バッファ名
                                      (buffer-name (selected-buffer))
                                      )

    (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
    (run-hooks '*info2-search-mode-hook*)
    )

;; Search モード
;;====================================


;;====================================
;; Bookmark モード

(defun info2-bookmark-mode ()
    "Bookmark モード。"
    (set-buffer (get-buffer-create *info2-bookmark-buffer-name*))

    (kill-all-local-variables)

    (make-local-variable 'auto-save)
    (make-local-variable 'make-backup-files)
    (make-local-variable 'kept-undo-information)
    (make-local-variable 'mode-line-format)

    (setf auto-save nil
          make-backup-files nil
          kept-undo-information nil
          mode-line-format "Bookmark"

          mode-name "info2-bookmark"
          buffer-mode 'info2-bookmark-mode
          )

    (use-keymap *info2-bookmark-mode-map*)
    (use-syntax-table *text-mode-syntax-table*)

    ;; 非表示 Window Flag 設定
    (set-local-window-flags (selected-buffer) *info2-bookmark-buffer-flags* nil)

    (set-buffer-fold-width nil)
    (setf buffer-read-only t)

    (run-hooks '*info2-bookmark-mode-hook*)
    )


(defun info2-bookmark-view-node (
                                 info-win
                                 ret-bmk-win
                                 close-bmk-win
                                 )
    "\
Bookmark ウィンドウにおいて現在行のノードを Info バッファに表示。

INFO-WIN:
nil のときカレントウィンドウに Info バッファをセット。t のとき Info ウィ
ンドウがなければ他のウィンドウを消して作成。

RET-BMK-WIN  : t のとき Bookmark ウィンドウに戻る。
CLOSE-BMK-WIN: t のとき Bookmark ウィンドウを閉じる。
"
    (let (
          let-win
          (let-info-buf (find-buffer *INFO2-BUFFER-NAME*))
          )

        (if let-info-buf
                ;; Info バッファがあれば
                (progn
                    ;; Bookmark バッファへ
                    (set-buffer (find-buffer *info2-bookmark-buffer-name*))

                    (multiple-value-bind (var-node var-line)
                            ;; カーソル位置のノード名と Line を取得
                            (info2-get-nearest-reference)
                        (if var-node
                                ;; ノードが取得できていれば表示
                                (progn
                                    (if close-bmk-win
                                            ;; Bookmark ウィンドウを閉じる
                                            (delete-window)
                                        )

                                    (if (setf let-win (get-buffer-window let-info-buf))
                                            ;; Info ウィンドウがあれば移動
                                            (set-window let-win)
                                        ;; Info ウィンドウがないとき
                                        (if info-win
                                                ;; 他のウィンドウを消して作成
                                                (progn
                                                    (delete-other-windows)
                                                    (split-window (floor (/ (window-columns)
                                                                            *info2-window-width*)
                                                                         )
                                                                  t
                                                                  )
                                                    (other-window)
                                                    ;; Info バッファセット
                                                    (set-buffer let-info-buf)
                                                    )
                                            ;; カレントウィンドウにバッファセット
                                            (set-buffer let-info-buf)
                                            )
                                        )

                                    (info2-view-node var-node t (point))

                                    (if var-line
                                            (goto-line var-line)
                                        )

                                    (when ret-bmk-win
                                        ;; Bookmark ウィンドウへ
                                        (set-window (get-buffer-window *info2-bookmark-buffer-name*))
                                        ;; メッセージ表示
                                        (message "~A"
                                                 (buffer-substring (save-excursion
                                                                       (goto-bol)
                                                                       (point)
                                                                       )
                                                                   (save-excursion
                                                                       (goto-eol)
                                                                       (point)
                                                                       )
                                                                   )
                                                 )
                                        )
                                    t
                                    )

                            ;; ノードが取得できないとき
                            nil
                            )
                        )
                    )

            ;; Info バッファが見つからなければ終了させる
            (progn
                (info2-close-all-buffer)
                (plain-error "Info バッファが見つかりませんでした。")
                )
            )
        )
    )


(defun info2-bookmark-output ()
    "Bookmark ファイルに現在の内容を書き込み。"
    (with-open-file (
                     s
                     *info2-bookmark-file*
                     :direction :output
                     :if-exists :overwrite
                     :if-does-not-exist :create
                     )
        (format s
                (buffer-substring (save-excursion
                                      (goto-line 2)
                                      (point)
                                      )
                                  (save-excursion
                                      (goto-char (point-max))
                                      (point)
                                      )
                                  )
                )
        )
    t
    )


(defun info2-transpose-lines (arg)
    "\
現在行全体を上下に移動。

ARG:
1  - 下に移動。
-1 - 上に移動。
"
    (let (
          (let-beg (save-excursion
                       (goto-bol)
                       (point)
                       )
                   )
          (let-end (save-excursion
                       (goto-eol)
                       (point)
                       )
                   )
          (let-col (current-column))
          )

        (setf buffer-read-only nil)
        (insert (prog1
                        (buffer-substring let-beg let-end)
                    (delete-region let-beg let-end)
                    (case arg
                        ;; 下に移動
                        (1
                         (delete-char)
                         (goto-eol)
                         (insert "\n")
                         )
                        ;; 上に移動
                        (-1
                         (delete-char -1)
                         (goto-bol)
                         (open-line)
                         )
                        )
                    )
                )
        (goto-column let-col)
        (set-buffer-modified-p nil)
        (setf buffer-read-only t)

        ;; 色付け
        (info2-fontify)

        ;; 現在行の内容を表示
        (message "~A"
                 (buffer-substring (save-excursion
                                       (goto-bol)
                                       (point)
                                       )
                                   (save-excursion
                                       (goto-eol)
                                       (point)
                                       )
                                   )
                 )

        t
        )
    )

;; Bookmark モード
;;====================================


;;====================================
;; Interactive

(defun info2-next-reference ()
    "次の相互参照 or メニューに移動。"
    (interactive)
    (info2-move-reference nil)
    )


(defun info2-nearest-reference ()
    "現在行の相互参照 or Menu が指すノードへ移動。"
    (interactive)
    (info2-view-nearest-reference)
    )


(defun info2-scroll-up ()
    "上にページスクロール or 次のノードへ"
    (interactive)
    (if (info2-scroll-page 1)
            t
        (info2-view-forward-node)
        )
    )


(defun info2-nth-menu-item ()
    "\
N 番目のメニューエントリ先に移動。

キー \"0\" が押されたとき、プロンプトで N を指定可能。
"
    (interactive)
    (let (
          ;; 押されたキーから数値取得
          (let-key (parse-integer (string *last-command-char*)))
          ;; 関数実行前の位置
          (let-pos (point))
          ;; カウント用
          (let-count 0)
          )

        (when (= let-key 0)
            ;; "0" が押されたとき
            (setf let-key (read-integer "Num: "))

            (if (< let-key 1)
                    (plain-error "それはダメ")
                (unless (or (< let-key *info2-fontify-max-num*)
                            (no-or-yes-p "時間かかるかもよ？")
                            )
                    (plain-error "中止しました")
                    )
                )
            )

        (goto-char (point-min))
        (if (scan-buffer *info2-regexp-menu* :case-fold t :regexp t)
                ;; Menu が存在するとき
                (progn
                    ;; N 番目まで移動
                    (while (and (/= let-count let-key)
                                (scan-buffer *info2-regexp-cross-reference* :case-fold t :no-dup t :regexp t)
                                )
                        (incf let-count)
                        )

                    (if (= let-count let-key)
                            ;; 押されたキー位置のメニューエントリが存在するとき
                            (info2-view-nearest-reference)

                        ;; 押されたキー位置のメニューエントリがなければ元の位置へ
                        (progn
                            (goto-char let-pos)
                            (message "そんなにないよ")
                            nil
                            )
                        )
                    )
            ;; メニューがなければ元の位置へ
            (progn
                (goto-char let-pos)
                nil
                )
            )
        )
    )


(defun info2-backward-node ()
    "前のノードへ移動。"
    (interactive)
    (info2-view-backward-node)
    )


(defun info2-forward-node ()
    "次のノードへ移動。"
    (interactive)
    (info2-view-forward-node)
    )


(defun info2-bookmark-add ()
    "現在位置を Bookmark に追加。"
    (interactive)
    ;; Bookmark ファイルに書き込み
    (with-open-file (
                     s
                     *info2-bookmark-file*
                     :direction :output
                     :if-exists :append
                     :if-does-not-exist :create
                     )
        (format s
                "* ~A: (~A)~A. (line ~D)~%"
                (format-date-string "%m/%d %H-%M-%S")
                ;; パス変換
                (substitute-string *INFO2-FILE-PATH*
                                   (concat (truename *info2-dir*)
                                           "/"
                                           )
                                   ""
                                   )
                *INFO2-CURRENT-NODE*
                (current-line-number)
                )
        )
    (message "Bookmark に追加しました。")
    t
    )


(defun info2-bookmark ()
    "Bookmark ウィンドウを開く。"
    (interactive)
    (let (
          ;; Bookmark ウィンドウ
          let-bmk-win
          ;; ローカル変数
          (let-info-file-path *INFO2-FILE-PATH*)
          (let-info-buffer-name *INFO2-BUFFER-NAME*)
          (let-current-node *INFO2-CURRENT-NODE*)
          (let-tag-table-buffer-name *INFO2-TAG-TABLE-BUFFER-NAME*)
          (let-indirect-buffer-name *INFO2-INDIRECT-BUFFER-NAME*)
          (let-indirect-file-list *INFO2-INDIRECT-FILE-LIST*)
          (let-indirect-pos-list *INFO2-INDIRECT-POS-LIST*)
          (let-index-node-list *INFO2-INDEX-NODE-LIST*)
          (let-history-back-list *INFO2-HISTORY-BACK-LIST*)
          (let-history-forward-list *INFO2-HISTORY-FORWARD-LIST*)
          (let-search-buffer-name *INFO2-SEARCH-BUFFER-NAME*)
          )

        ;; Bookmark ウィンドウをセット
        (if (find-buffer *info2-bookmark-buffer-name*)
                ;; Bookmark バッファが既に存在するとき
                (if (setf let-bmk-win (get-buffer-window (find-buffer *info2-bookmark-buffer-name*)))
                        ;; ウィンドウが既にあるとき
                        (set-window let-bmk-win)

                    ;; ウィンドウがないとき
                    (progn
                        (split-window (floor (/ (window-columns)
                                                *info2-window-width*))
                                      t)
                        (set-buffer (find-buffer *info2-bookmark-buffer-name*))
                        )
                    )

            ;; Bookmark バッファがなければ生成
            (progn
                (split-window (floor (/ (window-columns)
                                        *info2-window-width*)
                                     )
                              t
                              )
                (info2-bookmark-mode)
                )
            )

        (setf buffer-read-only nil)
        (erase-buffer (selected-buffer))
        (insert "[Bookmark]\n")
        (if (file-readable-p *info2-bookmark-file*)
                ;; Bookmark 挿入
                (insert-file-contents *info2-bookmark-file* t)
            ;; Bookmark ファイルがなければ作成
            (if (valid-path-p *info2-bookmark-file*)
                    (with-open-file (
                                     s
                                     *info2-bookmark-file*
                                     :direction :output
                                     :if-does-not-exist :create
                                     )
                        (message "Bookmark ファイルを作成しました ~A"
                                 *info2-bookmark-file*
                                 )
                        )
                ;; Bookmark ファイルパスがおかしいとき
                (plain-error "Bookmark ファイルパスがおかしい ~A"
                             *info2-bookmark-file*
                             )
                )
            )
        (setf buffer-read-only t)

        ;; バッファローカル変数を設定
        (info2-set-local-value let-info-file-path
                               let-info-buffer-name
                               let-current-node
                               let-tag-table-buffer-name
                               let-indirect-buffer-name
                               let-indirect-file-list
                               let-indirect-pos-list
                               let-index-node-list
                               let-history-back-list
                               let-history-forward-list
                               let-search-buffer-name
                               )

        ;; 色付け
        (info2-fontify)
        ;; ポイント移動
        (goto-char *info2-bookmark-current-position*)

        ;; 現在行の内容を表示
        (message "~A"
                 (buffer-substring (save-excursion
                                       (goto-bol)
                                       (point)
                                       )
                                   (save-excursion
                                       (goto-eol)
                                       (point)
                                       )
                                   )
                 )

        t
        )
    )


(defun info2-directory ()
    "DIR に移動。"
    (interactive)
    (if (and (string-equal *INFO2-FILE-PATH* (merge-pathnames "dir" *info2-dir*))
             (string-equal *INFO2-CURRENT-NODE* "top")
             )
            ;; 現在 DIR の Top ノードのとき
            nil
        ;; そうでなければ移動
        (info2-view-node "(dir)" t (point))
        )
    )


(defun info2-edit ()
    "閲覧中のノード内容を編集。"
    (interactive)
    (make-local-variable 'kept-undo-information)
    (setf kept-undo-information *save-history*
          mode-name "info2-edit"
          buffer-mode 'info2-edit-mode
          buffer-read-only nil
          )
    (use-keymap *info2-edit-mode-map*)
    (run-hooks '*info2-edit-mode-hook*)
    )


(defun info2-follow-reference (&optional ref)
    "\
指定した相互参照先へ移動。

REF : 移動先の相互参照名。
"
    (interactive)
    (let (
          ;; 関数実行前の位置
          (let-pos (point))
          ;; 補完リスト
          let-comp-list
          )
        (set-buffer (find-buffer *INFO2-BUFFER-NAME*))

        ;; `REF' を取得中に中止しても元の位置の戻るよう save-excursion
        (save-excursion
            (goto-char (point-min))
            ;; 補完リスト作成
            (while (scan-buffer "\\*note \\(.+\\):[: ]"
                                :case-fold t
                                :no-dup t
                                :regexp t
                                )
                (push (match-string 1) let-comp-list)
                )
            )

        (if let-comp-list
                (progn
                    (unless ref
                        ;; 移動先の相互参照名を取得
                        (setf ref (completing-read "Reference: "
                                                   let-comp-list
                                                   :case-fold t
                                                   :must-match t
                                                   )
                              )
                        )

                    (goto-char (point-min))
                    (scan-buffer (concat "\\*note "
                                         ref
                                         ":[: ]"
                                         )
                                 :case-fold t
                                 :regexp t
                                 )

                    (multiple-value-bind (var-node var-line)
                            ;; ノードと行位置を取得
                            (info2-get-nearest-reference)
                        (if var-node
                                (info2-view-node var-node t let-pos)
                            ;; ノードが取得できなかったとき
                            (progn
                                (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                                (goto-char let-pos)
                                (message "ノードが取得できませんでした")
                                nil
                                )
                            )
                        )
                    )
            ;; 相互参照 (*Note ～) が存在しないとき
            (progn
                (message "移動する相互参照が見つかりせん")
                nil
                )
            )
        )
    )


(defun info2-goto-node (node)
    "指定ノードへ移動"
    (interactive "sNode: " :history0 'search)
    (info2-view-node node t (point))
    )


(defun info2-index (topic)
    "\
Index 検索。

数引数付きで実行すると正規表現検索が有効に。
"
    (interactive "sTopic: " :history0 'search)
    (let (
          ;; 関数実行前のノード
          (let-node *INFO2-CURRENT-NODE*)
          ;; 関数実行前の位置
          (let-pos (point))
          ;; TOPIC で Index から 検索されたノード名と Line のリスト
          let-index
          ;; 検索リミット
          let-limit
          ;; ノード Position
          let-node-pos
          ;; 表示する Indirect ファイルリスト番号
          let-nth
          ;; Search ウィンドウ
          let-sch-win
          )

        ;; Index Node が未検索なら設定
        (unless (or *INFO2-INDEX-NODE-LIST*
                    (info2-get-index-node-list)
                    )
            ;; Index がないとき元の位置へ
            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
            (plain-error "Index はありません")
            )

        ;; TOPIC でヒットするものを各 Index から検索
        (dolist (list-index-node *INFO2-INDEX-NODE-LIST*)

            ;; Tag Table バッファ先頭へ
            (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
            (goto-char (point-min))

            ;; Indirect File があればセットし Indirect バッファへ
            (when *INFO2-INDIRECT-FILE-LIST*
                (scan-buffer "\37\ntag table:\n" :case-fold t :tail t)

                (scan-buffer (concat "node: "
                                     (regexp-quote list-index-node)
                                     "\177\\([0-9]+\\)$"
                                     ) ; \177 = ""
                             :case-fold t
                             :regexp t
                             :tail t
                             )

                ;; ノード Position
                (setf let-node-pos (parse-integer (match-string 1)))

                ;; Indirect ファイルリスト番号を算出
                (setf let-nth -1)
                (dolist (tmp-pos *INFO2-INDIRECT-POS-LIST*)
                    (if (>= let-node-pos tmp-pos)
                            (incf let-nth)
                        )
                    )

                ;; Indirect バッファセット
                (set-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))
                (erase-buffer (selected-buffer))
                (insert-file-contents (nth let-nth *INFO2-INDIRECT-FILE-LIST*) t)
                )

            (when (and
                   ;; Index 位置に移動
                   (scan-buffer (concat "\37\nfile:[ ]*"
                                        (file-namestring *INFO2-FILE-PATH*)
                                        ",[ ]*node:[ ]*"
                                        (regexp-quote list-index-node)
                                        "[\n,]"
                                        )
                                :case-fold t
                                :regexp t
                                )
                   ;; 検索リミット
                   (setf let-limit (point))
                   ;; Index ノード末尾
                   (scan-buffer "\37" :no-dup t)
                   )

                ;; TOPIC でヒットするものをメニューエントリから検索
                ;; "TOPIC <1>" などにもヒットさせる
                (while (scan-buffer (concat "^* \\("
                                            (if *prefix-args*
                                                    ;; 正規表現検索 (@ 括弧がはいったらマズイ？)
                                                    topic
                                                ;; 通常検索
                                                (regexp-quote topic)
                                                )
                                            "\\( <[0-9]+>\\)?\\):[ \t]+\\(.+\\)\\.[ \t]*\n?[ \t]*(line[ ]+\\(.+\\))$"
                                            )
                                    :case-fold t
                                    :limit let-limit
                                    :no-dup t
                                    :regexp t
                                    :reverse t
                                    )
                    ;; 1: 相互参照名 3: ノード名 4: Line
                    (push (list (match-string 1) (match-string 3) (match-string 4)) let-index)
                    )
                )
            )

        (if let-index
                ;; TOPIC でヒットするものがあったとき
                (progn
                    ;; Info バッファへ
                    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))

                    (if (= (list-length let-index) 1)
                            ;; 検索結果が 1 つのとき
                            (progn
                                (info2-view-node (cadar let-index) t let-pos)
                                (goto-line (parse-integer (caddar let-index)))
                                )

                        ;; 検索結果が複数のとき
                        (progn
                            ;; 戻る履歴に追加
                            (info2-history-add 1
                                               *INFO2-FILE-PATH*
                                               *INFO2-CURRENT-NODE*
                                               let-pos
                                               )

                            ;; Search バッファをセット
                            (if (and *INFO2-SEARCH-BUFFER-NAME*
                                     (find-buffer *INFO2-SEARCH-BUFFER-NAME*)
                                     )
                                    ;; Search バッファが既に存在するとき
                                    (if (setf let-sch-win (get-buffer-window (find-buffer *INFO2-SEARCH-BUFFER-NAME*)))
                                            ;; ウィンドウが既にあるとき
                                            (set-window let-sch-win)

                                        ;; ウィンドウがないとき
                                        (progn
                                            (split-window (floor (/ (window-columns)
                                                                    *info2-window-width*)
                                                                 )
                                                          t)
                                            (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
                                            )
                                        )

                                ;; Search バッファがなければ生成
                                (progn
                                    (split-window (floor (/ (window-columns)
                                                            *info2-window-width*)
                                                         )
                                                  t
                                                  )
                                    (info2-search-mode *INFO2-FILE-PATH*
                                                       *INFO2-BUFFER-NAME*
                                                       *INFO2-CURRENT-NODE*
                                                       *INFO2-TAG-TABLE-BUFFER-NAME*
                                                       *INFO2-INDIRECT-BUFFER-NAME*
                                                       *INFO2-INDIRECT-FILE-LIST*
                                                       *INFO2-INDIRECT-POS-LIST*
                                                       *INFO2-INDEX-NODE-LIST*
                                                       *INFO2-HISTORY-BACK-LIST*
                                                       *INFO2-HISTORY-FORWARD-LIST*
                                                       )
                                    )
                                )

                            ;; Mode Line 設定
                            (make-local-variable 'mode-line-format)
                            (setf mode-line-format (concat "[Index] "
                                                           topic
                                                           )
                                  )
                            ;; 検索結果挿入
                            (setf buffer-read-only nil)
                            (erase-buffer (selected-buffer))

                            (insert (concat "[Index] "
                                            topic
                                            "\n"
                                            )
                                    )

                            (dolist (tmp-index
                                     ;; ～、～<1>、～<2> の順に
                                     (adjoin (car (last let-index))
                                             (butlast let-index)
                                             )
                                     )
                                (insert (format nil
                                                "* ~A: ~A. (line ~A)~%"
                                                (car tmp-index)
                                                (cadr tmp-index)
                                                (caddr tmp-index)
                                                )
                                        )
                                )
                            (delete-backward-char)
                            (set-buffer-modified-p nil)
                            (setf buffer-read-only t)
                            (info2-fontify)
                            (goto-line 2)

                            ;; 先頭の検索結果を表示
                            (info2-search-view-node t t nil nil)
                            )
                        )
                    )

            ;; TOPIC でヒットするものがなかったとき
            (progn
                (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                (message "見つかりません \"~A\"" topic)
                nil
                )
            )
        )
    )


(defun info2-index-window ()
    "Index or Search ウィンドウを開く。"
    (interactive)
    (let (
          let-sch-win
          )
        (if *INFO2-SEARCH-BUFFER-NAME*
                ;; Search バッファがあれば開く
                (if (setf let-sch-win (get-buffer-window (find-buffer *INFO2-SEARCH-BUFFER-NAME*)))
                        ;; ウィンドウが既にあるとき
                        (set-window let-sch-win)

                    ;; ウィンドウがないとき
                    (progn
                        (split-window (floor (/ (window-columns)
                                                *info2-window-width*
                                                )
                                             )
                                      t
                                      )
                        (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
                        )
                    )
            ;; Search バッファがないとき
            nil
            )
        )
    )


(defun info2-view-index ()
    "\
Index ノードへ移動。

Index が複数あれば順に表示。
"
    (interactive)
    (let (
          ;; Index ノードリストの長さ
          let-list-length
          ;; Index リストの位置
          let-list-index
          )

        ;; Index ノードが未検索なら設定
        (if (or *INFO2-INDEX-NODE-LIST*
                (info2-get-index-node-list)
                )
                ;; Index ノードがあるとき
                (progn
                    ;; Info バッファへ移動
                    (set-buffer (find-buffer *INFO2-BUFFER-NAME*))

                    (if (= (setf let-list-length (list-length *INFO2-INDEX-NODE-LIST*))
                           1
                           )
                            ;; Index が 1 つのとき
                            (info2-view-node (car *INFO2-INDEX-NODE-LIST*) t (point))

                        ;; Index が複数のとき
                        (progn
                            ;; 関数実行前のノードが Index であればその位置を設定
                            (setf let-list-index (position *INFO2-CURRENT-NODE*
                                                           *INFO2-INDEX-NODE-LIST*
                                                           :test 'string-equal
                                                           )
                                  )
                            ;; Index ノード表示
                            (info2-view-node (nth (if (or (not let-list-index)
                                                          (= (1+ let-list-index)
                                                             let-list-length
                                                             )
                                                          )
                                                          ;; 関数実行前のノードが Index でない
                                                          ;; またはノードが最終 Index であったとき
                                                          0

                                                      ;; ノードが最終 Index 以外であったとき
                                                      (1+ let-list-index)
                                                      )
                                                  *INFO2-INDEX-NODE-LIST*
                                                  )
                                             (if let-list-index
                                                     nil
                                                 ;; 初回のときだけ履歴追加
                                                 (values t (point))
                                                 )
                                             )

                            (message "Index まだあるよ ~D/~D"
                                     (if (or (not let-list-index)
                                             (= (1+ let-list-index)
                                                let-list-length
                                                )
                                             )
                                             1
                                         (+ let-list-index 2)
                                         )
                                     let-list-length
                                     )
                            )
                        )
                    )

            ;; Index がないとき
            (progn
                (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
                (message "Index はありません")
                nil
                )
            )
        )
    )


(defun info2-toggle-keyword (&optional keyword-file-path)
    "\
キーワード色付けトグル。

数引数を付け実行すば読み込むキーワードファイルを指定できる。

KEYWORD-FILE-PATH : 読み込むキーワードファイル。
"
    (interactive (if *prefix-args*
                         (list (read-string "Keyword File Path: ")
                               )
                     )
        )

    (if keyword-hash-table
            ;; 色付けクリア
            (progn
                (make-local-variable 'keyword-hash-table)
                (setf keyword-hash-table nil)
                (message "Clear Keyword")
                t
                )
        ;; 色付け
        (if (info2-load-keyword-file *INFO2-FILE-PATH* keyword-file-path)
                t
            ;; キーワードファイルが見つからないとき
            (progn
                (message "キーワードファイルが見つかりません。")
                nil
                )
            )
        )
    )


(defun info2-last ()
    "ノード履歴 戻る。"
    (interactive)
    (info2-move-history 2 t (point))
    )


(defun info2-history-forward ()
    "ノード履歴 進む。"
    (interactive)
    (info2-move-history 1 t (point))
    )


(defun info2-menu (&optional menu)
    "指定したメニュー先へ移動"
    (interactive)
    (let (
          ;; 関数実行前の位置
          (let-pos (point))
          )

        (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (if (save-excursion
                (goto-char (point-min))
                (scan-buffer *info2-regexp-menu* :case-fold t :regexp t :tail t)
                )
                ;; メニューがあれば
                (progn
                    (unless menu
                        (setf menu (read-string "Menu: "))
                        )
                    (goto-char (point-min))

                    (if (scan-buffer (concat "^* "
                                             (regexp-quote menu)
                                             "[ \t]*:[: ]"
                                             )
                                     :case-fold t
                                     :regexp t
                                     )
                            ;; 指定したメニューエントリが見つかったとき
                            (multiple-value-bind (var-node var-line)
                                    ;; ノードと行位置を取得
                                    (info2-get-nearest-reference)
                                (if var-node
                                        (progn
                                            (info2-view-node var-node t let-pos)

                                            (if var-line
                                                    (goto-line var-line)
                                                )
                                            )
                                    ;; ノードが取得できなかったとき
                                    (progn
                                        (goto-char let-pos)
                                        (message "ノードが取得できませんでした")
                                        nil
                                        )
                                    )
                                )

                        ;; 指定したメニューエントリが見つからないとき
                        (progn
                            (goto-char let-pos)
                            (message "見つかりません \"~A\"" menu)
                            nil
                            )
                        )
                    )

            ;; メニューがないとき
            (progn
                (goto-char let-pos)
                (message "メニューが見つかりません")
                nil
                )
            )
        )
    )


(defun info2-next ()
    "Next ノードへ移動。"
    (interactive)
    (info2-view-node-line-node 1 t (point))
    )


(defun info2-previous ()
    "Prev Node へ移動。"
    (interactive)
    (info2-view-node-line-node 2 t (point))
    )


(defun info2-exit ()
    "Info Mode 終了。"
    (interactive)
    (info2-close-all-buffer)
    )


(defun info2-search (search-string)
    "\
指定語句を現在のノード以下から検索。

SEARCH-STRING : 検索文字列。

数引数付きで実行すると正規表現検索が有効に。
"
    (interactive "sSearch String: " :history0 'search)
    (let (
          ;; 関数実行前の位置
          (let-pos (point))
          ;; ヒットした位置 (ノードと行位置のリスト)
          let-result-list
          ;; ノードライン行位置
          let-node-line-num
          ;; Search ウィンドウ
          let-sch-win
          ;; 検索件数
          (let-sch-cnt 0)
          ;; Node の位置を格納
          let-node-pos
          ;; Indirect ファイルリスト番号
          (let-index -1)
          )

        ;; Tag Table バッファ先頭に移動
        (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
        (goto-char (point-min))

        (if *INFO2-INDIRECT-FILE-LIST*
                ;; Indirect ファイルがあるとき
                (progn
                    (scan-buffer "\37\ntag table:\n" :case-fold t :tail t)
                    (scan-buffer (concat "node: "
                                         (regexp-quote *INFO2-CURRENT-NODE*)
                                         "\177\\([0-9]+\\)$"
                                         ) ; \177 = ""
                                 :case-fold t
                                 :regexp t
                                 :tail t
                                 )
                    (setf let-node-pos (parse-integer (match-string 1)))

                    ;; Indirect ファイルリスト番号を算出
                    (dolist (list-indirect-pos *INFO2-INDIRECT-POS-LIST*)
                        (if (>= let-node-pos list-indirect-pos)
                                (incf let-index)
                            )
                        )

                    ;; Indirect バッファ
                    (set-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))

                    (dolist (list-indirect-file (nthcdr let-index *INFO2-INDIRECT-FILE-LIST*))
                        (erase-buffer (selected-buffer))
                        (insert-file-contents list-indirect-file t)
                        ;; 現在のノード位置へ
                        (scan-buffer (concat "\37\n\\(file:[ ]+"
                                             (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                             ",[ ]+node:[ ]+"
                                             (regexp-quote *INFO2-CURRENT-NODE*)
                                             "[\n,]\\)"
                                             )
                                     :case-fold t
                                     :regexp t
                                     )

                        ;; ノードと行位置をリストに Push
                        (while (scan-buffer search-string
                                            :case-fold t
                                            :no-dup t
                                            :regexp *prefix-args*
                                            )
                            (push (list (save-excursion
                                            (scan-buffer (concat "\37\nfile: "
                                                                 (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                                                 ",[ ]+node:[ ]+\\([^\n,]+\\)[\n,]"
                                                                 )
                                                         :case-fold t
                                                         :regexp t
                                                         :reverse t
                                                         )
                                            (setf let-node-line-num (current-line-number))
                                            (match-string 1)
                                            )
                                        ;; ノードラインからの行位置
                                        (- (current-line-number) let-node-line-num)
                                        )
                                  let-result-list
                                  )
                            ;; 同じ行のはリストアップしない
                            (next-line)
                            )
                        )
                    )

            ;; Indirect ファイルがないとき
            (progn
                ;; 現在のノード位置へ
                (scan-buffer (concat "\37\n\\(file:[ ]+"
                                     (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                     ",[ ]+node:[ ]+"
                                     (regexp-quote *INFO2-CURRENT-NODE*)
                                     "[\n,]\\)"
                                     )
                             :case-fold t
                             :regexp t
                             )

                ;; ノードと行位置をリストに Push
                (while (scan-buffer search-string
                                    :case-fold t
                                    :no-dup t
                                    :regexp *prefix-args*
                                    )
                    (push (list (save-excursion
                                    (scan-buffer (concat "\37\nfile: "
                                                         (regexp-quote (file-namestring *INFO2-FILE-PATH*))
                                                         ",[ ]+node:[ ]+\\([^\n,]+\\)[\n,]"
                                                         )
                                                 :case-fold t
                                                 :regexp t
                                                 :reverse t
                                                 )
                                    (setf let-node-line-num (current-line-number))
                                    (match-string 1)
                                    )
                                ;; ノードラインからの行位置
                                (- (current-line-number) let-node-line-num)
                                )
                          let-result-list
                          )
                    ;; 同じ行のはリストアップしない
                    (next-line)
                    )
                )
            )

        (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (if let-result-list
                ;; ヒットしたものがあるとき
                (if (= (list-length let-result-list) 1)
                        ;; 検索結果が 1 つのとき
                        (progn
                            (info2-view-node (caar let-result-list) t let-pos)
                            (goto-line (cadar let-result-list))
                            )
                    ;; 検索結果が複数のとき
                    (progn
                        ;; 戻る履歴に追加
                        (info2-history-add 1
                                           *INFO2-FILE-PATH*
                                           *INFO2-CURRENT-NODE*
                                           let-pos
                                           )
                        ;; Search バッファセット
                        (if *INFO2-SEARCH-BUFFER-NAME*
                                ;; Search バッファが既に存在するとき
                                (if (setf let-sch-win (get-buffer-window (find-buffer *INFO2-SEARCH-BUFFER-NAME*)))
                                        ;; ウィンドウが既にあるとき
                                        (set-window let-sch-win)

                                    ;; ウィンドウがないとき
                                    (progn
                                        (split-window (floor (/ (window-columns)
                                                                *info2-window-width*
                                                                )
                                                             )
                                                      t
                                                      )
                                        (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
                                        )
                                    )

                            ;; Search バッファがなければ生成
                            (progn
                                (split-window (floor (/ (window-columns)
                                                        *info2-window-width*)
                                                     )
                                              t
                                              )
                                (info2-search-mode *INFO2-FILE-PATH*
                                                   *INFO2-BUFFER-NAME*
                                                   *INFO2-CURRENT-NODE*
                                                   *INFO2-TAG-TABLE-BUFFER-NAME*
                                                   *INFO2-INDIRECT-BUFFER-NAME*
                                                   *INFO2-INDIRECT-FILE-LIST*
                                                   *INFO2-INDIRECT-POS-LIST*
                                                   *INFO2-INDEX-NODE-LIST*
                                                   *INFO2-HISTORY-BACK-LIST*
                                                   *INFO2-HISTORY-FORWARD-LIST*
                                                   )
                                )
                            )

                        ;; Mode Line 設定
                        (make-local-variable 'mode-line-format)
                        (setf mode-line-format (concat "[Search] "
                                                       search-string
                                                       )
                              )
                        ;; 検索結果挿入
                        (setf buffer-read-only nil)
                        (erase-buffer (selected-buffer))

                        (insert (concat "[Search] "
                                        search-string
                                        "\n"
                                        )
                                )

                        ;; ノードと行位置のリストはひっくり返す
                        (dolist (list-result-list (reverse let-result-list))
                            (incf let-sch-cnt)
                            (insert (format nil
                                            "* ~D: ~A. (line ~D)~%"
                                            let-sch-cnt
                                            (car list-result-list)
                                            (cadr list-result-list)
                                            )
                                    )
                            )
                        (delete-backward-char)
                        (set-buffer-modified-p nil)
                        (setf buffer-read-only t)
                        (info2-fontify)
                        (goto-line 2)

                        ;; 先頭の検索結果を表示
                        (info2-search-view-node t
                                                t
                                                nil
                                                (if *prefix-args*
                                                        search-string
                                                    (regexp-quote search-string)
                                                    )
                                                )
                        )
                    )

            ;; 見つからないとき
            (progn
                (message "見つかりません")
                nil
                )
            )
        )
    )


(defun info2-top ()
    "Top Node へ移動。"
    (interactive)
    ;; 現在 Top ノードでなければ実行
    (if (string-equal *INFO2-CURRENT-NODE* "top")
            nil
        (info2-view-node "top" t (point))
        )
    )


(defun info2-up ()
    "Up Node へ移動。"
    (interactive)
    (info2-view-node-line-node 3 t (point))
    )


(defun info2-next-page (&optional (arg 1))
    "下へページスクロール。"
    (interactive)
    (info2-scroll-page 1)
    )


(defun info2-previous-page ()
    "上へページスクロール。"
    (interactive)
    (info2-scroll-page -1)
    )


(defun info2-previous-reference ()
    "前の相互参照 or メニューへ移動。"
    (interactive)
    (info2-move-reference t)
    )


(defun info2-scroll-down ()
    "下にページスクロール or 前のノードへ"
    (interactive)
    (if (info2-scroll-page -1)
            t
        (info2-backward-node)
        )
    )


(defun info2-mouse-left-press ()
    "\
Double Click: 現在行の相互参照 or メニューが指すノードへ移動。
Triple Click: ノード履歴 戻る。
"
    (interactive)
    (let (
          (let-click (mod *last-mouse-click-count* 6))
          )
        (case let-click
            (1 (mouse-left-press))
            (2
             (unless (info2-view-nearest-reference)
                 ;; 移動するノードがないとき
                 (mouse-left-press)
                 )
             )
            ;; ノード履歴 戻る
            (3 (info2-move-history 2 t(point)))
            )
        )
    )


(defun info2-mode (&optional info-file-path
                             info-buffer-name
                             node
                             )
    "\
Info Mode.

Interactive に呼び出されると、カレントバッファを Info-mode で表示。

INFO-FILE-PATH:
non-nil のとき、指定された Info ファイル を Info Mode で表示する。nil で
あればCurrent Buffer を Info-mode で表示。

INFO-BUFFER-NAME:

non-nil のとき、バッファ名をその名で生成。nil であれば
`*info2-base-buffer-name*' で指定された名で生成。

`*info2-base-buffer-name*' でバッファが生成されるときは、既にその名のバ
ッファが存在しても、末尾に <1>, <2> と番号が付いたバッファが生成されるが、
バッファ名を指定したとき、既にその名のバッファが存在し、そのバッファのモ
ードが Info Mode であればそのバッファは上書きされる。Info Mode でなけれ
ば上書きするか確認がはいる。

NODE:
non-nil のとき、指定されたそのノードを表示。nil のとき、または指定ノード
が存在しないときは Top Node を表示する。
"
    (interactive)
    (let (
          ;; 表示する Info ファイル
          ;; 引数 INFO-FILE-PATH をフルパスに変換
          let-mod-info-file-path
          ;; Info バッファ名
          ;; 実際に生成したバッファ名。"<1>" やらがついてるかも
          let-mod-info-buffer-name
          )

        ;; ファイルパス格納
        (if info-file-path
                ;; 表示する File が指定されたとき
                ;; `~/' とか `../' 等をフルパスに変換して格納
                (setf let-mod-info-file-path (merge-pathnames (file-namestring info-file-path)
                                                              (directory-namestring info-file-path))
                      )

            ;; カレントバッファのファイルパスを格納
            (setf let-mod-info-file-path (get-buffer-file-name))
            )

        (unless (and let-mod-info-file-path
                     (file-readable-p let-mod-info-file-path)
                     )
            (plain-error "ファイルが見つかりません \"~A\"" let-mod-info-file-path)
            )

        ;; Info バッファ生成
        (if info-buffer-name
                ;; バッファ名が指定されたとき
                (progn
                    ;; 既に同名の Info Mode ではないバッファがあれば確認後に削除
                    (if (and (find-buffer info-buffer-name)
                             (set-buffer (find-buffer info-buffer-name))
                             (string-not-equal mode-name "info2")
                             (not (no-or-yes-p "このバッファ削除しちゃうよ？"))
                             )
                            (plain-error "中止しました。")
                        )

                    (set-buffer (get-buffer-create info-buffer-name))
                    (erase-buffer (selected-buffer))

                    ;; 生成した Info Buffer 名
                    (setf let-mod-info-buffer-name (buffer-name (selected-buffer)))

                    ;; Tag Table, Indirect Buffer があれば削除
                    (if (and *INFO2-TAG-TABLE-BUFFER-NAME*
                             (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*)
                             )
                            (delete-buffer *INFO2-TAG-TABLE-BUFFER-NAME*)
                        )
                    (if (and *INFO2-INDIRECT-BUFFER-NAME*
                             (find-buffer *INFO2-INDIRECT-BUFFER-NAME*)
                             )
                            (delete-buffer *INFO2-INDIRECT-BUFFER-NAME*)
                        )
                    )

            (progn
                ;; 既に同名バッファが存在すれば <1>, <2> と番号を付けたバッファを生成
                (set-buffer (create-new-buffer *info2-default-buffer-name*))
                ;; 生成した Info Buffer 名
                (setf let-mod-info-buffer-name (buffer-name (selected-buffer)))
                )
            )

        (kill-all-local-variables)

        (make-local-variable 'auto-save)
        (make-local-variable 'kept-undo-information)
        (make-local-variable 'make-backup-files)

        (setf auto-save nil
              kept-undo-information nil
              make-backup-files nil

              mode-name "info2"
              buffer-mode 'info2-mode
              )

        (use-keymap *info2-mode-map*)
        (use-syntax-table *text-mode-syntax-table*)

        ;; 非表示 Window Flag 設定
        (set-local-window-flags (selected-buffer) *info2-buffer-flags* nil)

        ;; Node 表示
        (if node
                ;; 表示する Node が指定されたとき
                (multiple-value-bind (
                                      var-tag-table-buffer-name
                                      var-indirect-buffer-name
                                      var-indirect-file-list
                                      var-indirect-pos-list
                                      )
                        ;; Tag Table バッファをセットしローカル変数を取得
                        (info2-set-tag-buffer let-mod-info-file-path
                                              let-mod-info-buffer-name
                                              )

                    (set-buffer (find-buffer let-mod-info-buffer-name))
                    ;; Buffer Local 変数設定
                    (info2-set-local-value-all-buffer let-mod-info-file-path
                                                      let-mod-info-buffer-name
                                                      node
                                                      var-tag-table-buffer-name
                                                      var-indirect-buffer-name
                                                      var-indirect-file-list
                                                      var-indirect-pos-list
                                                      *INFO2-INDEX-NODE-LIST*
                                                      *INFO2-HISTORY-BACK-LIST*
                                                      *INFO2-HISTORY-FORWARD-LIST*
                                                      *INFO2-SEARCH-BUFFER-NAME*
                                                      )
                    ;; ノード表示
                    (info2-view-node node nil)
                    )

            ;; Top Node を表示
            (multiple-value-bind (
                                  var-tag-table-buffer-name
                                  var-indirect-buffer-name
                                  var-indirect-file-list
                                  var-indirect-pos-list
                                  )
                    ;; Tag Table バッファをセットしローカル変数を取得
                    (info2-set-tag-buffer let-mod-info-file-path
                                          let-mod-info-buffer-name
                                          )

                (set-buffer (find-buffer let-mod-info-buffer-name))

                ;; Buffer Local 変数設定
                (info2-set-local-value-all-buffer let-mod-info-file-path
                                                  let-mod-info-buffer-name
                                                  "top"
                                                  var-tag-table-buffer-name
                                                  var-indirect-buffer-name
                                                  var-indirect-file-list
                                                  var-indirect-pos-list
                                                  *INFO2-INDEX-NODE-LIST*
                                                  *INFO2-HISTORY-BACK-LIST*
                                                  *INFO2-HISTORY-FORWARD-LIST*
                                                  *INFO2-SEARCH-BUFFER-NAME*
                                                  )

                ;; ノード表示
                (info2-view-node "top" nil)
                )
            )

        ;; キーワードファイル設定
        (info2-load-keyword-file let-mod-info-file-path)

        (run-hooks '*info2-mode-hook*)
        )
    )


(defun info2 (&optional info-file-path)
    "\
Info 起動。

数引数を付け実行すると、開くファイルをミニバッファで指定可能。

INFO-FILE-PATH:
ファイルパスを指定。指定するとその File を Info Mode で開く。指定さ
れなければ DIR ファイルを開く。
"
    (interactive (if *prefix-args*
                         ;; 数引数付きで呼び出されたとき
                         (list (read-exist-file-name "Info File Name: "))
                     )
        )

    (if info-file-path
            ;; 表示する Info File が指定されたとき

            ;; Internal に呼び出されたときのためファイルが存在するかチェック
            (if (file-exist-p info-file-path)
                    (info2-mode info-file-path)
                (progn
                    (message "\"~A\" が見つかりません。" info-file-path)
                    nil
                    )
                )
        ;; DIR を表示
        (let (
              ;; DIR ファイルのパス
              (let-dir-file-path (merge-pathnames "dir" *info2-dir*))
              )
            (if (file-exist-p let-dir-file-path)
                    (info2-mode let-dir-file-path)
                (progn
                    (message "\"~A\" が見つかりません。" info-file-path)
                    nil
                    )
                )
            )
        )
    )


;;------------------------------------
;; Search モード

(defun info2-search-view-node-static ()
    "現在行のノードを Info ウィンドウに表示。"
    (interactive)
    (info2-search-view-node t t nil (info2-search-get-string))
    )


(defun info2-search-view-node-and-quit ()
    "現在行のノードに移動し Search ウィンドウを閉じる。"
    (interactive)
    (info2-search-view-node nil nil t (info2-search-get-string))
    )


(defun info2-search-view-node-dynamic ()
    "現在行のノードを表示し Info ウィンドウに移動。"
    (interactive)
    (info2-search-view-node t nil nil (info2-search-get-string))
    )


(defun info2-search-next-line-and-view ()
    "次の行へ移動しその行のノードを Info バッファに表示。"
    (interactive)

    (unless (next-line)
        ;; 末尾なら先頭へ
        (goto-line 2)
        )
    (info2-search-view-node t t nil (info2-search-get-string))
    )


(defun info2-search-previous-line-and-view ()
    "前の行へ移動しその行のノードを Info バッファに表示。"
    (interactive)

    (unless (and (previous-line)
                 (/= (current-line-number) 1)
                 )
        ;; 行頭なら末尾へ
        (goto-line (buffer-lines))
        )
    (info2-search-view-node t t nil (info2-search-get-string))
    )


(defun info2-search-quit ()
    "Search ウィンドウを閉じる。"
    (interactive)
    (if (= (count-windows) 1)
            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (delete-window)
        )
    )


(defun info2-search-mouse-left-press ()
    "Double Click で 現在行のノードを表示し Info ウィンドウに移動。"
    (interactive)
    (let (
          (let-click (mod *last-mouse-click-count* 6))
          )
        (case let-click
            (1 (mouse-left-press))
            (2
             (unless (info2-search-view-node t nil nil (info2-search-get-string))
                 ;; 移動するノードがないとき
                 (mouse-left-press)
                 )
             )
            )
        )
    )

;; Search モード
;;------------------------------------


;;------------------------------------
;; Bookmark モード

(defun info2-bookmark-view-node-static ()
    "現在行のノードを Info ウィンドウに表示。"
    (interactive)
    (info2-bookmark-view-node t t nil)
    )


(defun info2-bookmark-view-node-and-quit ()
    "現在行のノードに移動し Bookmark ウィンドウを閉じる。"
    (interactive)
    ;; 現在位置を格納
    (setf *info2-bookmark-current-position* (point))

    (info2-bookmark-view-node nil nil t)
    )


(defun info2-bookmark-view-node-dynamic ()
    "現在行のノードを表示し Info ウィンドウに移動。"
    (interactive)
    ;; 現在位置を格納
    (setf *info2-bookmark-current-position* (point))

    (info2-bookmark-view-node t nil nil)
    )


(defun info2-bookmark-del ()
    "カーソル行を削除。"
    (interactive)

    (if (or (= (current-line-number) 1)
            (= (current-line-number) (buffer-lines))
            )
            ;; 先頭行 or 最終行のとき
            nil
        (progn
            ;; カーソル行削除
            (setf buffer-read-only nil)
            (delete-region (save-excursion
                               (goto-bol)
                               (point)
                               )
                           (save-excursion
                               (next-line)
                               (goto-bol)
                               (point)
                               )
                           )

            (set-buffer-modified-p nil)
            (setf buffer-read-only t)

            ;; Bookmark ファイルに書き込み
            (info2-bookmark-output)
            )
        )
    )


(defun info2-bookmark-insert-string (str)
    "カーソル位置に文字列を挿入。"
    (interactive "sString: " :history0 'search)
    (if (= (current-line-number) 1)
            ;; 先頭行
            nil
        (progn
            (setf buffer-read-only nil)
            (goto-bol)
            (open-line)
            (insert str)
            (when (= (current-line-number) (buffer-lines))
                ;; 最終行のとき
                (insert "\n")
                (previous-line)
                )
            (goto-bol)
            (set-buffer-modified-p nil)
            (setf buffer-read-only t)

            ;; Bookmark 書き込み
            (info2-bookmark-output)

            ;; 色付け
            (info2-fontify)
            )
        )
    )


(defun info2-bookmark-next-line ()
    "次の行へ移動。"
    (interactive)
    (unless (next-line)
        ;; 末尾なら先頭へ
        (goto-line 2)
        )

    ;; 現在行の内容を表示
    (message "~A"
             (buffer-substring (save-excursion
                                   (goto-bol)
                                   (point)
                                   )
                               (save-excursion
                                   (goto-eol)
                                   (point)
                                   )
                               )
             )
    )


(defun info2-bookmark-transpose-lines-down ()
    "現在行のブックマークを下に移動。"
    (interactive)
    (if (or (= (current-line-number) 1)
            (= (current-line-number) (1- (buffer-lines)))
            (= (current-line-number) (buffer-lines))
            )
            ;; 先頭行 or 最終行 - 1 行目 or 最終行のとき
            nil
        (progn
            ;; 現在行を上に移動
            (info2-transpose-lines 1)
            ;; Bookmark 書き込み
            (info2-bookmark-output)
            )
        )
    )


(defun info2-bookmark-open-line ()
    "カーソル位置に空行を挿入。"
    (interactive)
    (if (or (= (current-line-number) 1)
            (= (current-line-number) (buffer-lines))
            )
            ;; 先頭行 or 最終行のとき
            nil
        (progn
            (setf buffer-read-only nil)
            (save-excursion
                (goto-bol)
                (open-line)
                )
            (set-buffer-modified-p nil)
            (setf buffer-read-only t)

            ;; Bookmark 書き込み
            (info2-bookmark-output)
            )
        )
    )


(defun info2-bookmark-previous-line ()
    "前の行へ移動。"
    (interactive)
    (unless (and (previous-line)
                 (/= (current-line-number) 1)
                 )
        ;; 行頭なら末尾へ
        (goto-line (buffer-lines))
        )

    ;; 現在行の内容を表示
    (message "~A"
             (buffer-substring (save-excursion
                                   (goto-bol)
                                   (point)
                                   )
                               (save-excursion
                                   (goto-eol)
                                   (point)
                                   )
                               )
             )
    )


(defun info2-bookmark-transpose-lines-up ()
    "現在行のブックマークを上に移動。"
    (interactive)
    (if (or (= (current-line-number) 1)
            (= (current-line-number) 2)
            (= (current-line-number) (buffer-lines))
            )
            ;; 先頭行 or 2 行目 or 最終行のとき
            nil
        (progn
            ;; 現在行を上に移動
            (info2-transpose-lines -1)
            ;; Bookmark 書き込み
            (info2-bookmark-output)
            )
        )
    )


(defun info2-bookmark-quit ()
    "Bookmark バッファを閉じる。"
    (interactive)
    ;; 現在位置を格納
    (setf *info2-bookmark-current-position* (point))

    (if (= (count-windows) 1)
            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
        (delete-window)
        )
    )


(defun info2-bookmark-rename-title (&optional title)
    "ブックマークのタイトル変更。"
    (interactive)
    (let (
          (let-lim (progn
                       (goto-eol)
                       (point)
                       )
                   )
          let-string
          )

        (goto-bol)
        (scan-buffer *info2-regexp-cross-reference*
                     :case-fold t
                     :limit let-lim
                     :regexp t
                     )
        (setf let-string (match-string 6))

        (if (or (= (current-line-number) 1)
                (= (current-line-number) (buffer-lines))
                (not let-string)
                (string-not-equal (match-string 3) ": ")
                )
                ;; 先頭行 or 最終行 or ブックマークでないとき
                nil
            (progn
                (unless title
                    (setf title (read-string "Title: "))
                    )
                (setf buffer-read-only nil)
                (delete-region (progn
                                   (goto-bol)
                                   (point)
                                   )
                               (progn
                                   (goto-eol)
                                   (point)
                                   )
                               )
                (insert (concat "* "
                                title
                                ": "
                                let-string
                                )
                        )
                (goto-bol)
                (set-buffer-modified-p nil)
                (setf buffer-read-only t)

                ;; Bookmark 書き込み
                (info2-bookmark-output)

                ;; 色付け
                (info2-fontify)

                ;; 現在行の内容を表示
                (message "~A"
                         (buffer-substring (save-excursion
                                               (goto-bol)
                                               (point)
                                               )
                                           (save-excursion
                                               (goto-eol)
                                               (point)
                                               )
                                           )
                         )
                )
            )
        )
    )


(defun info2-bookmark-cut ()
    "カーソル行のブックマークを切り取り。"
    (interactive)
    (let (
          ;; 切り取り開始位置
          (let-from (save-excursion
                        (goto-bol)
                        (point)
                        )
                    )
          ;; 切り取り終了位置
          (let-to (save-excursion
                      (goto-eol)
                      (point)
                      )
                  )
          )

        (if (or (= (current-line-number) 1)
                (= (current-line-number) (buffer-lines))
                )
                ;; 先頭行 or 最終行のとき
                nil
            (progn
                (setf buffer-read-only nil
                      *info2-bookmark-clipboard* (buffer-substring let-from let-to)
                      )
                ;; カーソル行削除
                (delete-region let-from (1+ let-to))
                (set-buffer-modified-p nil)
                (setf buffer-read-only t)

                ;; Bookmark ファイルに書き込み
                (info2-bookmark-output)
                )
            )
        )
    )


(defun info2-bookmark-paste ()
    "カーソル行に切り取ったブックマークを貼り付け。"
    (interactive)
    (if (or (= (current-line-number) 1)
            (not *info2-bookmark-clipboard*)
            )
            ;; 先頭行 or 切り取ってないとき
            nil
        (progn
            (setf buffer-read-only nil)
            (goto-bol)
            (open-line)
            (insert *info2-bookmark-clipboard*)
            (goto-bol)
            (set-buffer-modified-p nil)
            (setf buffer-read-only t)

            ;; Bookmark 書き込み
            (info2-bookmark-output)
            ;; 色付け
            (info2-fontify)

            ;; 現在行の内容を表示
            (message "~A"
                     (buffer-substring (save-excursion
                                           (goto-bol)
                                           (point)
                                           )
                                       (save-excursion
                                           (goto-eol)
                                           (point)
                                           )
                                       )
                     )
            )
        )
    )


(defun info2-bookmark-mouse-left-press ()
    "Double Click で 現在行のノードを表示し Info ウィンドウに移動。"
    (interactive)
    (let (
          (let-click (mod *last-mouse-click-count* 6))
          (let-pos (point))
          )
        (case let-click
            (1 (mouse-left-press))
            (2
             (if (info2-bookmark-view-node t nil nil)
                     ;; 現在位置を格納
                     (setf *info2-bookmark-current-position* let-pos)
                 ;; 移動するノードがないとき
                 (mouse-left-press)
                 )
             )
            )
        )
    )

;; Bookmark モード
;;------------------------------------


;;------------------------------------
;; Edit モード

(defun info2-edit-save-and-quit ()
    "編集内容を保存し Edit モードを終了。"
    (interactive)
    (let (
          ;; ノード内容を格納
          let-node-contents
          ;; Node 位置を格納
          let-node-pos
          ;; Indirect ファイルリスト番号を格納
          (let-num -1)
          ;; 書き込み先を表示するバッファ
          let-buffer
          ;; Info ファイルパス
          (let-file-path *INFO2-FILE-PATH*)
          ;; Info バッファ名
          (let-info-buffer-name *INFO2-BUFFER-NAME*)
          ;; カレントノード
          (let-current-node *INFO2-CURRENT-NODE*)
          )

        ;; ノード内容格納
        (setf let-node-contents (buffer-substring (point-min)
                                                  (point-max)
                                                  )
              )

        ;; Tag Table バッファ先頭へ
        (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
        (goto-char (point-min))

        (scan-buffer "\37\ntag table:\n" :case-fold t :tail t)

        (scan-buffer (concat "node: "
                             (regexp-quote *INFO2-CURRENT-NODE*)
                             "\177\\([0-9]+\\)$"
                             ) ; \177 = ""
                     :case-fold t
                     :regexp t
                     )

        ;; Node 位置を格納
        (setf let-node-pos (parse-integer (match-string 1)))

        (if *INFO2-INDIRECT-FILE-LIST*
                ;; Indirect File があるとき
                (progn
                    ;; Indirect ファイルリスト番号を算出
                    (dolist (list-indirect-pos *INFO2-INDIRECT-POS-LIST*)
                        (if (>= let-node-pos list-indirect-pos)
                                (incf let-num)
                            )
                        )

                    ;; Indirect ファイルを開く
                    (setf let-buffer (find-file-internal (nth let-num *INFO2-INDIRECT-FILE-LIST*)))
                    )

            ;; Indirect File がないとき
            (progn
                ;; Info ファイルを開く
                (setf let-buffer (find-file-internal *INFO2-FILE-PATH*))
                )
            )

        ;; 書き込むバッファに移動し現在のノード位置に移動
        (set-buffer let-buffer)
        (scan-buffer (concat "\37\n\\(file:[ ]+"
                             (regexp-quote (file-namestring let-file-path))
                             ",[ ]+node:[ ]+"
                             (regexp-quote let-current-node)
                             "[\n,]\\)"
                             )
                     :case-fold t
                     :regexp t
                     )

        ;; 内容書き換え
        (delete-region (match-beginning 1)
                       (progn
                           (scan-buffer "\37\\|\\'" :no-dup t :regexp t)
                           (point)
                           )
                       )
        (insert let-node-contents)
        (save-buffer)
        (delete-buffer (selected-buffer))

        ;; Info バッファへ
        (set-buffer (find-buffer let-info-buffer-name))
        (set-buffer-modified-p nil)

        (make-local-variable 'kept-undo-information)
        (setf kept-undo-information nil
              mode-name "info2"
              buffer-mode 'info2-mode
              buffer-read-only t
              )
        (use-keymap *info2-mode-map*)

        ;; 色付け
        (if *info2-fontify-p*
                (info2-fontify)
            )
        )
    )


(defun info2-edit-undo-and-quit ()
    "変更を取り消し Edit モードを終了。"
    (interactive)
    (let (
          ;; 取り消し時の場所
          (let-pos (point))
          )
        ;; Info モードに
        (make-local-variable 'kept-undo-information)
        (setf kept-undo-information nil
              mode-name "info2"
              buffer-mode 'info2-mode
              buffer-read-only t
              )
        (use-keymap *info2-mode-map*)

        ;; ノード再表示
        (info2-view-node *INFO2-CURRENT-NODE* nil)
        ;; 取り消し時の場所へ
        (goto-char let-pos)
        )
    )

;; Edit モード
;;------------------------------------

;; Interactive
;;====================================

;;; Defun
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Debug

(when *info2-debug*
    (defun debug-info2-regexp (reg match1 &optional match2 match3)
        (interactive)
        (scan-buffer reg :case-fold t :regexp t)
        (msgbox "
[~A]
[~A]
[~A]
"
                (match-string match1)
                (match-string match2)
                (match-string match3)
                )
        )


    (defun debug-info2-show-value (var1 &optional var2 var3 var4 var5 var6)
        (msgbox "\
1 : ~A
2 : ~A
3 : ~A
4 : ~A
5 : ~A
6 : ~A
"
                var1
                var2
                var3
                var4
                var5
                var6
                ))


    (defun debug-info2 ()
        (interactive)
        (let (
              (let-buf (selected-buffer))
              )

            (when *info2-bookmark-buffer-name*
                (set-buffer (find-buffer *info2-bookmark-buffer-name*))
                (msgbox "\
バッファ : ~A
*INFO2-FILE-PATH* : ~A
*INFO2-BUFFER-NAME* : ~A
*INFO2-CURRENT-NODE* : ~A
*INFO2-TAG-TABLE-BUFFER-NAME* : ~A
*INFO2-INDIRECT-BUFFER-NAME* : ~A
*INFO2-INDIRECT-FILE-LIST* : ~A
*INFO2-INDIRECT-POS-LIST* : ~A
*INFO2-INDEX-NODE-LIST* : ~A
*INFO2-HISTORY-BACK-LIST* : ~A
*INFO2-HISTORY-FORWARD-LIST* : ~A
*INFO2-SEARCH-BUFFER-NAME* : ~A
"
                        *info2-bookmark-buffer-name*
                        *INFO2-FILE-PATH*
                        *INFO2-BUFFER-NAME*
                        *INFO2-CURRENT-NODE*
                        *INFO2-TAG-TABLE-BUFFER-NAME*
                        *INFO2-INDIRECT-BUFFER-NAME*
                        *INFO2-INDIRECT-FILE-LIST*
                        *INFO2-INDIRECT-POS-LIST*
                        *INFO2-INDEX-NODE-LIST*
                        *INFO2-HISTORY-BACK-LIST*
                        *INFO2-HISTORY-FORWARD-LIST*
                        *INFO2-SEARCH-BUFFER-NAME*
                        )
                )

            (when *INFO2-SEARCH-BUFFER-NAME*
                (set-buffer (find-buffer *INFO2-SEARCH-BUFFER-NAME*))
                (msgbox "\
バッファ : ~A
*INFO2-FILE-PATH* : ~A
*INFO2-BUFFER-NAME* : ~A
*INFO2-CURRENT-NODE* : ~A
*INFO2-TAG-TABLE-BUFFER-NAME* : ~A
*INFO2-INDIRECT-BUFFER-NAME* : ~A
*INFO2-INDIRECT-FILE-LIST* : ~A
*INFO2-INDIRECT-POS-LIST* : ~A
*INFO2-INDEX-NODE-LIST* : ~A
*INFO2-HISTORY-BACK-LIST* : ~A
*INFO2-HISTORY-FORWARD-LIST* : ~A
*INFO2-SEARCH-BUFFER-NAME* : ~A
"
                        *INFO2-SEARCH-BUFFER-NAME*
                        *INFO2-FILE-PATH*
                        *INFO2-BUFFER-NAME*
                        *INFO2-CURRENT-NODE*
                        *INFO2-TAG-TABLE-BUFFER-NAME*
                        *INFO2-INDIRECT-BUFFER-NAME*
                        *INFO2-INDIRECT-FILE-LIST*
                        *INFO2-INDIRECT-POS-LIST*
                        *INFO2-INDEX-NODE-LIST*
                        *INFO2-HISTORY-BACK-LIST*
                        *INFO2-HISTORY-FORWARD-LIST*
                        *INFO2-SEARCH-BUFFER-NAME*
                        )
                )

            (when *INFO2-INDIRECT-BUFFER-NAME*
                (set-buffer (find-buffer *INFO2-INDIRECT-BUFFER-NAME*))
                (msgbox "\
バッファ : ~A
*INFO2-FILE-PATH* : ~A
*INFO2-BUFFER-NAME* : ~A
*INFO2-CURRENT-NODE* : ~A
*INFO2-TAG-TABLE-BUFFER-NAME* : ~A
*INFO2-INDIRECT-BUFFER-NAME* : ~A
*INFO2-INDIRECT-FILE-LIST* : ~A
*INFO2-INDIRECT-POS-LIST* : ~A
*INFO2-INDEX-NODE-LIST* : ~A
*INFO2-HISTORY-BACK-LIST* : ~A
*INFO2-HISTORY-FORWARD-LIST* : ~A
*INFO2-SEARCH-BUFFER-NAME* : ~A
"
                        *INFO2-INDIRECT-BUFFER-NAME*
                        *INFO2-FILE-PATH*
                        *INFO2-BUFFER-NAME*
                        *INFO2-CURRENT-NODE*
                        *INFO2-TAG-TABLE-BUFFER-NAME*
                        *INFO2-INDIRECT-BUFFER-NAME*
                        *INFO2-INDIRECT-FILE-LIST*
                        *INFO2-INDIRECT-POS-LIST*
                        *INFO2-INDEX-NODE-LIST*
                        *INFO2-HISTORY-BACK-LIST*
                        *INFO2-HISTORY-FORWARD-LIST*
                        *INFO2-SEARCH-BUFFER-NAME*
                        )
                )

            (when *INFO2-TAG-TABLE-BUFFER-NAME*
                (set-buffer (find-buffer *INFO2-TAG-TABLE-BUFFER-NAME*))
                (msgbox "\
バッファ : ~A
*INFO2-FILE-PATH* : ~A
*INFO2-BUFFER-NAME* : ~A
*INFO2-CURRENT-NODE* : ~A
*INFO2-TAG-TABLE-BUFFER-NAME* : ~A
*INFO2-INDIRECT-BUFFER-NAME* : ~A
*INFO2-INDIRECT-FILE-LIST* : ~A
*INFO2-INDIRECT-POS-LIST* : ~A
*INFO2-INDEX-NODE-LIST* : ~A
*INFO2-HISTORY-BACK-LIST* : ~A
*INFO2-HISTORY-FORWARD-LIST* : ~A
*INFO2-SEARCH-BUFFER-NAME* : ~A
"
                        *INFO2-TAG-TABLE-BUFFER-NAME*
                        *INFO2-FILE-PATH*
                        *INFO2-BUFFER-NAME*
                        *INFO2-CURRENT-NODE*
                        *INFO2-TAG-TABLE-BUFFER-NAME*
                        *INFO2-INDIRECT-BUFFER-NAME*
                        *INFO2-INDIRECT-FILE-LIST*
                        *INFO2-INDIRECT-POS-LIST*
                        *INFO2-INDEX-NODE-LIST*
                        *INFO2-HISTORY-BACK-LIST*
                        *INFO2-HISTORY-FORWARD-LIST*
                        *INFO2-SEARCH-BUFFER-NAME*
                        )
                )

            (set-buffer (find-buffer *INFO2-BUFFER-NAME*))
            (msgbox "\
バッファ : ~A
*INFO2-FILE-PATH* : ~A
*INFO2-BUFFER-NAME* : ~A
*INFO2-CURRENT-NODE* : ~A
*INFO2-TAG-TABLE-BUFFER-NAME* : ~A
*INFO2-INDIRECT-BUFFER-NAME* : ~A
*INFO2-INDIRECT-FILE-LIST* : ~A
*INFO2-INDIRECT-POS-LIST* : ~A
*INFO2-INDEX-NODE-LIST* : ~A
*INFO2-HISTORY-BACK-LIST* : ~A
*INFO2-HISTORY-FORWARD-LIST* : ~A
*INFO2-SEARCH-BUFFER-NAME* : ~A
"
                    *INFO2-BUFFER-NAME*
                    *INFO2-FILE-PATH*
                    *INFO2-BUFFER-NAME*
                    *INFO2-CURRENT-NODE*
                    *INFO2-TAG-TABLE-BUFFER-NAME*
                    *INFO2-INDIRECT-BUFFER-NAME*
                    *INFO2-INDIRECT-FILE-LIST*
                    *INFO2-INDIRECT-POS-LIST*
                    *INFO2-INDEX-NODE-LIST*
                    *INFO2-HISTORY-BACK-LIST*
                    *INFO2-HISTORY-FORWARD-LIST*
                    *INFO2-SEARCH-BUFFER-NAME*
                    )

            (set-buffer let-buf)
            )
        )
    )

;;; Debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Keymap

(unless *info2-mode-map*
    (setf *info2-mode-map* (make-sparse-keymap))
    ;; 次の相互参照 or メニューに移動
    (define-key *info2-mode-map* #\TAB 'info2-next-reference)
    ;; 現在行の相互参照 or メニューが指すノードへ移動
    (define-key *info2-mode-map* #\RET 'info2-nearest-reference)
    ;; 上にページスクロール or 次のノードへ
    (define-key *info2-mode-map* #\SPC 'info2-scroll-up)
    ;; Info バッファ先頭へ
    (define-key *info2-mode-map* #\. 'beginning-of-buffer)

    ;;====================================
    ;; N 番目のメニューエントリ先に移動
    (define-key *info2-mode-map* #\0 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\1 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\2 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\3 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\4 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\5 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\6 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\7 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\8 'info2-nth-menu-item)
    (define-key *info2-mode-map* #\9 'info2-nth-menu-item)
    ;; N 番目のメニューエントリ先に移動
    ;;====================================

    ;; 前のノードへ移動
    (define-key *info2-mode-map* #\[ 'info2-backward-node)
    ;; 次のノードへ移動
    (define-key *info2-mode-map* #\] 'info2-forward-node)
    ;; 現在位置を Bookmark に追加
    (define-key *info2-mode-map* #\a 'info2-bookmark-add)
    ;; Info バッファ先頭へ
    (define-key *info2-mode-map* #\b 'beginning-of-buffer)
    ;; Bookmark ウィンドウを開く
    (define-key *info2-mode-map* #\B 'info2-bookmark)
    ;; DIR に移動
    (define-key *info2-mode-map* #\d 'info2-directory)
    ;; 閲覧中のノード内容を編集
    (define-key *info2-mode-map* #\e 'info2-edit)
    ;; 指定した相互参照先へ移動
    (define-key *info2-mode-map* #\f 'info2-follow-reference)
    ;; 指定ノードへ移動
    (define-key *info2-mode-map* #\g 'info2-goto-node)
    ;; Index 検索
    (define-key *info2-mode-map* #\i 'info2-index)
    ;; Index or Search ウィンドウを開く
    (define-key *info2-mode-map* #\I 'info2-index-window)
    ;; Index ノードに移動
    (define-key *info2-mode-map* #\M-i 'info2-view-index)
    ;; キーワード色付けトグル
    (define-key *info2-mode-map* #\k 'info2-toggle-keyword)
    ;; ノード履歴 戻る
    (define-key *info2-mode-map* #\l 'info2-last)
    ;; ノード履歴 進む
    (define-key *info2-mode-map* #\L 'info2-history-forward)
    ;; 指定したメニュー先へ移動
    (define-key *info2-mode-map* #\m 'info2-menu)
    ;; Next Node へ移動
    (define-key *info2-mode-map* #\n 'info2-next)
    ;; Prev Node へ移動
    (define-key *info2-mode-map* #\p 'info2-previous)
    ;; Info Mode 終了
    (define-key *info2-mode-map* #\q 'info2-exit)
    ;; 指定語句を現在のノード以下から検索
    (define-key *info2-mode-map* #\s 'info2-search)
    ;; Index or Search ウィンドウを開く
    (define-key *info2-mode-map* #\S 'info2-index-window)
    ;; Top Node へ移動
    (define-key *info2-mode-map* #\t 'info2-top)
    ;; Up Node へ移動
    (define-key *info2-mode-map* #\u 'info2-up)
    ;; 下へページスクロール
    (define-key *info2-mode-map* #\v 'info2-next-page)
    ;; 上へページスクロール
    (define-key *info2-mode-map* #\z 'info2-previous-page)

    ;; 前の相互参照 or Menu に移動
    ;; (set-extended-key-translate-table exkey-S-tab #\F13)
    ;; とかして S-Tab に設定するとか
    (define-key *info2-mode-map* #\F13 'info2-previous-reference)

    ;; 上にページスクロール or 次のノードへ
    ;; (set-extended-key-translate-table exkey-S-space #\F15)
    ;; とかして S-Spc に設定するとか
    (define-key *info2-mode-map* #\F15 'info2-scroll-down)

    ;; Double Click: 現在行の相互参照 or メニューが指すノードへ移動
    ;; Triple Click: ノード履歴 戻る
    (define-key *info2-mode-map* #\LBtnDown 'info2-mouse-left-press)

    ;; Debug
    (if *info2-debug*
            (define-key *info2-mode-map* '(#\C-c #\d)  'debug-info2)
        )
    )


;;====================================
;; Search モード

(unless *info2-search-mode-map*
    (setf *info2-search-mode-map* (make-sparse-keymap))
    ;; 現在行のノードを Info ウィンドウに表示
    (define-key *info2-search-mode-map* #\TAB 'info2-search-view-node-static)
    ;; 現在行のノードに移動し Search ウィンドウを閉じる
    (define-key *info2-search-mode-map* #\RET 'info2-search-view-node-and-quit)
    ;; 現在行のノードを表示し Info ウィンドウに移動
    (define-key *info2-search-mode-map* #\SPC 'info2-search-view-node-dynamic)
    ;; 次の行へ移動しその行のノードを Info バッファに表示
    (define-key *info2-search-mode-map* #\n 'info2-search-next-line-and-view)
    ;; 前の行へ移動しその行のノードを Info バッファに表示
    (define-key *info2-search-mode-map* #\p 'info2-search-previous-line-and-view)
    ;; Search ウィンドウを閉じる
    (define-key *info2-search-mode-map* #\q 'info2-search-quit)
    ;; 下へページスクロール
    (define-key *info2-search-mode-map* #\v 'info2-next-page)
    ;; 上へページスクロール
    (define-key *info2-search-mode-map* #\z 'info2-previous-page)

    ;; Double Click: 現在行のノードを表示し Info ウィンドウに移動
    (define-key *info2-search-mode-map* #\LBtnDown 'info2-search-mouse-left-press)

    ;; Debug
    (if *info2-debug*
            (define-key *info2-search-mode-map* '(#\C-c #\d)  'debug-info2)
        )
    )

;; Search モード
;;====================================


;;====================================
;; Bookmark モード

(unless *info2-bookmark-mode-map*
    (setf *info2-bookmark-mode-map* (make-sparse-keymap))
    ;; 現在行のノードを Info ウィンドウに表示
    (define-key *info2-bookmark-mode-map* #\TAB 'info2-bookmark-view-node-static)
    ;; 現在行のノードに移動し Bookmark ウィンドウを閉じる
    (define-key *info2-bookmark-mode-map* #\RET 'info2-bookmark-view-node-and-quit)
    ;; 現在行のノードを表示し Info ウィンドウに移動
    (define-key *info2-bookmark-mode-map* #\SPC 'info2-bookmark-view-node-dynamic)
    ;; カーソル位置のブックマークを削除
    (define-key *info2-bookmark-mode-map* #\d 'info2-bookmark-del)
    ;; カーソル位置に文字列を挿入
    (define-key *info2-bookmark-mode-map* #\i 'info2-bookmark-insert-string)
    ;; 次の行へ移動
    (define-key *info2-bookmark-mode-map* #\n 'info2-bookmark-next-line)
    ;; 現在行のブックマークを下に移動
    (define-key *info2-bookmark-mode-map* #\N 'info2-bookmark-transpose-lines-down)
    ;; カーソル位置に空行を挿入
    (define-key *info2-bookmark-mode-map* #\o 'info2-bookmark-open-line)
    ;; 前の行へ移動
    (define-key *info2-bookmark-mode-map* #\p 'info2-bookmark-previous-line)
    ;; 現在行のブックマークを上に移動
    (define-key *info2-bookmark-mode-map* #\P 'info2-bookmark-transpose-lines-up)
    ;; Bookmark バッファを閉じる
    (define-key *info2-bookmark-mode-map* #\q 'info2-bookmark-quit)
    ;; ブックマークのタイトル変更
    (define-key *info2-bookmark-mode-map* #\r 'info2-bookmark-rename-title)
    ;; 下へページスクロール
    (define-key *info2-bookmark-mode-map* #\v 'info2-next-page)
    ;; カーソル行のブックマークを切り取り
    (define-key *info2-bookmark-mode-map* #\w 'info2-bookmark-cut)
    ;; カーソル行に切り取ったブックマークを貼り付け
    (define-key *info2-bookmark-mode-map* #\y 'info2-bookmark-paste)
    ;; 上へページスクロール
    (define-key *info2-bookmark-mode-map* #\z 'info2-previous-page)

    ;; Double Click: 現在行のノードを表示し Info ウィンドウに移動
    (define-key *info2-bookmark-mode-map* #\LBtnDown 'info2-bookmark-mouse-left-press)

    ;; Debug
    (if *info2-debug*
            (define-key *info2-bookmark-mode-map* '(#\C-c #\d)  'debug-info2)
        )
    )

;; Bookmark モード
;;====================================


;;====================================
;; Edit モード

(unless *info2-edit-mode-map*
    ;; Text モードのマップをコピー
    (setf *info2-edit-mode-map* (copy-keymap *text-mode-map*))
    ;; 編集内容を保存し編集モードを終了
    (define-key *info2-edit-mode-map* '(#\C-c #\C-c) 'info2-edit-save-and-quit)
    ;; 変更を取り消し編集モードを終了
    (define-key *info2-edit-mode-map* '(#\C-x #\k) 'info2-edit-undo-and-quit)

    ;; Debug
    (if *info2-debug*
            (define-key *info2-edit-mode-map* '(#\C-c #\d)  'debug-info2)
        )
    )

;; Edit モード
;;====================================

;;; Keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; info2.l ends here
