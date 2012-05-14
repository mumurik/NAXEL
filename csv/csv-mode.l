;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; csv-mode.l --- Comma Separated Value file editing mode for xyzzy

;; Copyright (C) 2001-2006 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.3.0
;; Time-stamp: <2006/10/21 19:39:23 +0900>

;;; Commentary:

;; Description:
;;
;;  CSV/TSVファイル編集用メジャーモードです。
;;

;; Installation:
;;
;;      1. アーカイブを展開して csv-mode.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/csv-mode.l
;;
;;      3. *.csv/*.tsv を読みこんだときに自動的に csv-mode に
;;         するために、以下のコードを追加します。
;;
;;        ■ ~/.xyzzy に追加する場合
;;              (export '(ed::csv-mode  ed::tsv-mode) "ed")
;;              (autoload 'csv-mode "csv-mode" t)
;;              (autoload 'tsv-mode "csv-mode" t)
;;              (pushnew '("\\.csv$" . csv-mode) *auto-mode-alist* :test 'equal)
;;              (pushnew '("\\.tsv$" . tsv-mode) *auto-mode-alist* :test 'equal)
;;
;;        ■ $XYZZY/site-lisp/siteinit.l に追加する場合
;;              (in-package "editor")
;;              (export '(csv-mode tsv-mode))
;;              (autoload 'csv-mode "csv-mode" t)
;;              (autoload 'tsv-mode "csv-mode" t)
;;              (pushnew '("\\.csv$" . csv-mode) *auto-mode-alist* :test 'equal)
;;              (pushnew '("\\.tsv$" . csv-mode) *auto-mode-alist* :test 'equal)
;;              (in-package "user")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. csv-mode.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x csv-mode
;;      M-x tsv-mode
;;

;; Key bind:
;;
;;      ESC TAB     他行同列からの補完入力
;;      C-c C-e     編集ダイアログ
;;      C-c M-C-e   選択編集ダイアログ
;;      C-u C-c C-e 同上
;;      C-c C-v     現在行内容を popup 表示
;;      C-c C-w     現在行内容を window 表示
;;      C-c C-s     列と方法を選択してソート
;;
;;      C-c C-i     列の挿入／追加
;;      C-c C-d     列の削除
;;      C-c C-c     列の入換
;;
;;      C-c C-o     列幅を最小に
;;      C-c C-a     列幅を揃える
;;
;;      C-c C-x     行と列の入換
;;
;;      C-c C-b     罫線囲みに変換
;;      C-c C-h     HTML 書式に変換
;;
;;      C-c C-t     一行目をヘッダとするかどうかのトグル
;;      C-c C-,     セパレータの変更
;;      C-c C-;     改行表示文字の変更
;;
;;      C-n         次行に移動。行表示用ウィンドウに内容を表示。
;;      C-p         前行に移動。行表示用ウィンドウに内容を表示。
;;      M-n         次行の同じ列に移動
;;      C-Down      同上
;;      M-p         前行の同じ列に移動
;;      C-Up        同上
;;      TAB         次の列に移動
;;      M-f         同上
;;      C-Right     同上
;;      M-b         前の列に移動
;;      C-Left      同上
;;

;; Customize:
;;
;;      基本設定
;;          (require "csv-mode")
;;          (setq-default csv-header-flag t)                 ; t, nil
;;          (setq-default csv-max-column-number-strict nil)  ; t, nil
;;          (setq-default csv-separator-char #\,)            ; <character>
;;          (setq-default csv-encode-string :except-integer) ; t, nil, :except-integer
;;          (setq *csv-edit-dialog-width* 256)                 ; <integer>
;;          (setq *csv-edit-dialog-header-width* 50)           ; <integer>
;;          (setq-default csv-edit-dialog-move :next)        ; :next, :previous, nil
;;          (setq *csv-line-number* t)         ; t, nil, <OTHER (:remain)>
;;          (setq *csv-cursor-line* t)         ; t, nil, <OTHER (:remain)>
;;          (setq *csv-buffer-fold-width* nil) ; t, nil, <integer>, <OTHER (:remain)>
;;
;;      popup-list を使わずミニバッファから列番号を入力
;;          (require "csv-mode")
;;          (define-key *csv-mode-map* '(#\C-c #\C-i) 'csv-insert-column)
;;          (define-key *csv-mode-map* '(#\C-c #\C-d) 'csv-delete-column)
;;          (define-key *csv-mode-map* '(#\C-c #\C-c) 'csv-change-column)
;;

;; Changes:
;;
;;      [Version 0.0.3.0]
;;      Thu, 24 Aug 2006 00:05:37 +0900
;;        ・通貨記号 \ $ が含まれていてもマッチするように
;;           *csv-number-regexp* を更新。
;;
;;      Mon, 31 Jul 2006 00:25:30 +0900
;;        ・各種関数の修正。副作用を避けるために nconc を append に一部変更。
;;
;;      Sun, 16 Jul 2006 21:32:53 +0900
;;        ・csv-record-next-record, csv-record-previous-record 追加
;;
;;      Tue, 11 Jul 2006 00:39:10 +0900
;;        ・csv-record-edit 関数を追加。
;;        ・csv-position-box を csv-box-position に変更
;;        ・csv-lcenter-box を csv-box-lcenter に変更
;;        ・csv-rcenter-box を csv-box-rcenter に変更
;;        ・csv-center-box を csv-box-center に変更
;;        ・csv-left-box を csv-box-left に変更
;;        ・csv-right-box を csv-box-right に変更
;;
;;      Sat, 08 Jul 2006 20:59:56 +0900
;;        ・csv-change-record-newline を csv-record-change-newline に変更。
;;        ・csv-view-line-on-record-window を csv-record-view-line に変更。
;;        ・csv-set-record-buffer を csv-record-set-buffer に変更。
;;        ・csv-view-record-buffer を csv-record-view-buffer に変更。
;;
;;      Sun, 02 Jul 2006 01:34:14 +0900
;;        ・関数 csv-change-newline を csv-change-record-newline に変更。
;;        ・変数 csv-newline-char を csv-record-newline-char に変更。
;;
;;      Mon, 26 Jun 2006 00:32:04 +0900
;;        ・csv-get-column-list 関数拡張。
;;          引数を (decode max-column-number to) に。付随する各種変更。
;;        ・csv-max-column-number 関数で、全行を調べた際の値のキャッシュを
;;          持つように更新。
;;          バッファローカル変数
;;            csv-max-column-number-strict-cache
;;          関数
;;            csv-max-column-number-strict-cache-set
;;            csv-max-column-number-strict-cache-get
;;            csv-max-column-number-strict-cache-valid-p
;;          を追加。
;;
;;      Wed, 21 Jun 2006 00:30:39 +0900
;;        ・ナローイング時にも正常動作するように csv-sort を更新。
;;        ・ナローイング時にも正常動作するように csv-convert-to-box を更新。
;;        ・全行が同じ列数でないと csv-convert-to-box がエラーを返していた
;;          のを修正。
;;        ・ナローイング時にも正常動作するように csv-convert-to-html を更新。
;;
;;      Tue, 20 Jun 2006 00:50:02 +0900
;;        ・csv-get-column-list の引数の順序を変更(to decode)→(decode to)。
;;          付随して、各種関数定義を変更。
;;        ・csv-header-line-p 関数定義。
;;        ・csv-get-header-column-list 関数定義。
;;
;;      Mon, 19 Jun 2006 00:07:29 +0900
;;        ・csv-change-row-column 修正。
;;          元バッファの csv-separator-char ではなく、一時バッファ
;;          の csv-separator-char で出力していたのを修正。
;;        ・csv-edit-dialog 更新。
;;          - next-line-add-newlines の考慮をやめ、必要ならば常に新規行を
;;            追加するように。
;;          - 一行編集することに、undo 境界を設定するように。
;;
;;      Fri, 16 Jun 2006 00:01:27 +0900
;;        ・csv-change-row-column 追加。
;;        ・csv-max-line-number 修正。
;;
;;      Mon, 05 Jun 2006 00:52:05 +0900
;;        ・DOCSTRING 追加。
;;        ・csv-next-line-keep-column の定義変更。
;;          行移動不可の場合は桁移動しないように。
;;        ・csv-get-column-list 定義見直し。
;;        ・csv-view-line 更新。
;;        ・csv-do-completion 定義変更。
;;        ・csv-select-insert-column, csv-select-delete-column,
;;          csv-select-change-column, csv-select-sort 更新。
;;          popup-list 表示での 0 パディング。
;;
;;      Fri, 26 May 2006 00:39:41 +0900
;;        ・*csv-mode-local-map* を csv-mode-local-map に変更。
;;        ・csv-view-record-burrer を csv-view-record-buffer に修正。
;;        ・csv-next-line の定義変更。
;;        ・csv-forward-column, csv-backward-column の定義変更。
;;
;;      Wed, 11 Jan 2006 00:56:45 +0900
;;        ・csv-convert-to-box 修正。
;;          - 対象バッファに文字列が何もない場合エラーとなるのを修正。
;;            (ただしまだ無限ループになるよう)
;;
;;      Thu, 24 Nov 2005 00:32:51 +0900
;;        ・csv-max-line-number 修正。
;;
;;      Sat, 08 Oct 2005 13:57:09 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Sat, 08 Jan 2005 06:52:29 +0900
;;        ・コメント修正。
;;        ・defvar-local で定義する変数のシンボル名を *xxx* から xxx に変更。
;;          - *csv-header-flag*              -> csv-header-flag
;;          - *csv-max-column-number-strict* -> csv-max-column-number-strict
;;          - *csv-separator-char*           -> csv-separator-char
;;          - *csv-encode-string*            -> csv-encode-string
;;          - *csv-newline-char*             -> csv-newline-char
;;          - *csv-edit-dialog-move*         -> csv-edit-dialog-move
;;        ・xyzzy 0.2.2.234 対応
;;          - "ＭＳ Ｐゴシック" ⇒ "MS UI Gothic"
;;          - 半角カナを全角カナに変更。
;;
;;      Tue, 12 Oct 2004 18:44:36 +0900
;;        ・csv-convert-to-box では、カラム内の値が数値と見なせる場合は、
;;          各セル毎に右寄せにするように変更。
;;          csv-convert-to-html は既存のまま据え置き。
;;        ・csv-join-string-list の str-list に nil が渡された場合、
;;          エラーが発生するのを修正。
;;
;;      Tue, 06 Apr 2004 15:03:32 +0900
;;        ・csv-change-row-column 追加中。
;;        ・*csv-buffer-temp* 追加。
;;
;;      Sun, 09 Nov 2003 04:36:50 +0900
;;        ・csv-view-line-on-window -> csv-view-line-on-record-window に。
;;
;;      Sat, 08 Nov 2003 13:50:46 +0900
;;        ・csv-view-mode -> csv-record-mode に名称変更
;;
;;      Thu, 06 Nov 2003 11:30:48 +0900
;;        ・csv-adjust-column の際、数のみのカラムは右寄せするように。
;;
;;      Wed, 05 Nov 2003 01:16:28 +0900
;;        ・csv-lcenter-box, csv-rcenter-box 追加。
;;        ・整数ソートの際、"," が含まれてもよいように変更。
;;
;;      Wed, 29 Oct 2003 10:22:05 +0900
;;        ・csv-convert-to-box, csv-convert-to-html の際、数のみのカラムは
;;          右寄せにするように。
;;          csv-convert-to-box, csv-convert-to-html 修正、
;;          csv-column-numberp-list, csv-curretn-line-column-numberp-list,
;;          *csv-number-regexp* 追加。
;;        ・罫線囲み表示時のモード csv-box-mode 作成。
;;          罫線囲みセルのセンタリング、左揃え、右揃え 追加。
;;          csv-center-box, csv-left-box, csv-right-box
;;
;;      Tue, 16 Sep 2003 19:02:57 +0900
;;        ・csv-view-mode 関連更新。
;;
;;      Thu, 22 May 2003 13:13:20 +0900
;;        ・menu 周りのコードを修正。
;;
;;      [Version 0.0.2.1]
;;      Mon, 19 May 2003 00:33:59 +0900
;;        ・menu 周りのコードを修正。
;;          M-x csv-mode を行うたびにメニューが増加するのを修正。
;;
;;      [Version 0.0.2.0]
;;      Sun, 27 Apr 2003 23:20:56 +0900
;;        ・nconc の副作用を都合よく期待したコードだったのを修正。
;;        ・csv-next-line, csv-previous-line の名称を
;;          csv-next-line-keep-column, csv-previous-line-keep-column に変更。
;;        ・xyzzy Part8 704 さんのアイデアをいただき
;;          csv-view-line-on-window, csv-change-newline,
;;          csv-next-line, csv-previous-line を新たに追加。
;;        ・NetInstaller 対応
;;        ・その他。
;;
;;      Sat, 08 Mar 2003 23:50:22 +0900
;;        ・*csv-buffer-convert* を "*CSV: Convert*" に。
;;
;;      [Version 0.0.0.13]
;;      Fri, 07 Mar 2003 02:03:01 +0900
;;        ・menu の tag の間違いを修正。
;;        ・csv-toggle-local-line-number, csv-toggle-local-cursor-line 追加。
;;
;;      Tue, 04 Mar 2003 00:31:37 +0900
;;        ・*csv-line-number*, *csv-cursor-line*,
;;          *csv-buffer-fold-width* 指定追加。
;;
;;      [Version 0.0.0.12]
;;      Mon, 03 Mar 2003 00:42:48 +0900
;;        ・csv-menu-update 更新。
;;          menu 非表示状態を考慮するように。
;;
;;      [Version 0.0.0.11]
;;      Thu, 15 Aug 2002 16:13:48 +0900
;;        ・tdict ファイル編集のために tsv-mode 追加。
;;          伴い、*csv-tsv-separator-char* 廃止
;;
;;      [Version 0.0.0.10]
;;      Mon, 27 May 2002 01:23:05 +0900
;;        ・共通設定の「終了時の状態を保存する」にチェックをいれていると
;;          buffer-local メニューが生成されない点を修正。(thanks YMTZ さん)
;;        ・*csv-mode-hook* で *csv-mode-map* を変更しても反映されない点を
;;          とりあえず修正。
;;          csv-set-separator を csv-update-keymap に名称変更。
;;          それに伴う名称変更。
;;          *csv-mode-map* を変更した後は csv-update-keymap を呼ぶ必要が
;;          あります。
;;
;;      Mon, 18 Feb 2002 01:01:26 +0900
;;        ・csv-edit-dialog の移動処理を修正。
;;
;;      [Version 0.0.0.9]
;;      Mon, 14 Jan 2002 05:20:05 +0900
;;        ・csv-edit-dialog, csv-selection-edit-dialog
;;        ・*csv-header-flag-default* *csv-max-column-number-strict-default*
;;          *csv-separator-char-default* 廃止。
;;          *csv-header-flag* *csv-max-column-number-strict*
;;          *csv-separator-char* を buffer local な変数に。
;;        ・*csv-max-column-number-strict* 仕様変更
;;           nil : 先頭行と現在行のうち大きい列数を最大列数とみなす
;;           t   : 全行を調べ正確な最大列数を出す
;;        ・csv-next-line, csv-previous-line,
;;          csv-forward-column, csv-backward-column,
;;          csv-insert-column, csv-delete-column, csv-change-column 修正。
;;        ・next-line-add-newlines を考慮するように。
;;        ・その他。
;;
;;      [Version 0.0.0.8]
;;      Mon, 14 Jan 2002 05:20:05 +0900
;;        ・メニューをつけた。
;;        ・C-[letter] のキーバインドを使用していたのを他に変更。
;;        ・補完入力後の動作を修正。
;;        ・csv-convert-to-box 修正。
;;        ・convert 結果出力バッファの表示を修正。
;;        ・その他。
;;
;;      Thu, 01 Nov 2001 18:29:36 +0900
;;        ・csv-convert-to-html で & < > 等を変換するように。
;;
;;      Thu, 01 Nov 2001 02:26:20 +0900
;;        ・convert 結果出力バッファの表示を折り返さないように。
;;        ・文字列中に ~ がある場合、(csv-convert-to-box) で
;;          「不正なフォーマット指示子」となるバグを修正。
;;        ・手抜き csv-convert-to-html
;;
;;      [Version 0.0.0.7]
;;      Wed, 31 Oct 2001 17:25:42 +0900
;;        ・ファイル名のないバッファで csv-mode にできなかったバグを修正。
;;
;;      [Version 0.0.0.6]
;;      Mon, 22 Oct 2001 23:23:48 +0900
;;        ・csv-convert-to-box
;;          macro で内容が展開されることでつまづく。
;;
;;      Sun, 21 Oct 2001 07:49:46 +0900
;;        ・変数名の変更
;;          *csv-max-column-strict-default* を
;;          *csv-max-column-number-strict-default* に
;;        ・read-only ファイルへの対処。
;;
;;      [Version 0.0.0.5]
;;      Fri, 19 Oct 2001 20:38:34 +0900
;;        ・ソートの修正／速度の改善
;;
;;      [Version 0.0.0.4]
;;      Fri, 19 Oct 2001 12:59:18 +0900
;;        ・*csv-header-flag* を *csv-header-flag-default* に変更。
;;        ・*csv-separator-char* を *csv-separator-char-default* に変更。
;;        ・*csv-tsv-separator-char*
;;          拡張子が tsv の場合の separator character。
;;          character が指定してある場合 separator をその character に。
;;        ・*csv-max-column-number-strict-default*
;;          t           : 全行を調べ正確な値を出す
;;          nil         : 現在の行の列数を最大列数とみなす
;;          t, nil 以外 : 一行目をヘッダとみなしている場合、現在行と一行目の大きい列数
;;                        そうでない場合は現在の行の列数を最大列数とみなす
;;        ・処理があまりに重いので、(long-operation) をそこかしこにいれる。
;;
;;      Thu, 18 Oct 2001 05:46:56 +0900
;;        ・ソート方法を追加しやすいように修正。
;;
;;      [Version 0.0.0.3]
;;      Thu, 18 Oct 2001 01:38:25 +0900
;;        ・デフォルトで一行目をヘッダと認識するように変更。
;;        ・ヘッダありの場合は補完入力にヘッダを含まないように。
;;        ・ソートを修正。
;;
;;      [Version 0.0.0.2]
;;      Wed, 17 Oct 2001 23:09:23 +0900
;;        ・列の挿入／追加・削除・入換。
;;        ・ソート。
;;        ・一行目をヘッダとしているかどうかをmode-lineに表示。
;;
;;      [Version 0.0.0.1]
;;      Wed, 17 Oct 2001 04:06:17 +0900
;;        ・初版作成。
;;

;; Todo:
;;
;;      ・HTML 変換に関して
;;        ・空白セルに全角スペースを入れるかどうか。
;;        ・タグを大文字にするかどうか。
;;        ・URL をリンクする。
;;        ・タイトルなどを含んだ完全な HTML 文書に変換して出力
;;      ・セパレータの置換。（置換後のファイルに不都合がでないかの判断も）
;;      ・ダブルクォートの付加・除去。
;;      ・整数のカンマの付加・除去。
;;      ・列幅を揃える際の右寄せ。
;;

;; Specification:
;;
;;      ・ヘッダ行：
;;          - csv-header-flag が nil の場合はヘッダ行なし。
;;          - csv-header-flag が non-nil の場合 (point-min) ポイントの
;;            属する物理行
;;      ・最大行：
;;          - (point-max) ポイントの属する物理行。
;;            ただし、(point-max) ポイントでの (bolp) が t の場合
;;            (物理行頭の場合)は、「(point-max) ポイントの属する物理行 - 1」。
;;
;;      ・列番号、行番号ともに 1 オリジン。
;;
;;      ・左右にスペースを含みたい場合は文字列を `"' で挟む。
;;      ・ダブルクォート `"' を文字列中に含める場合は両端を `"' で挟んだ上で、
;;        `""' とする。
;;
;;

;; Licence:
;;
;;    csv-mode は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2006, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "csv-mode")

(in-package "editor")

(export '(*csv-mode-hook*
          *csv-mode-update-keymap-hook*
          *csv-mode-map*
          *csv-mode-syntax-table*
          *csv-sort-method-list*
          *csv-keyword-file*
          *csv-regexp-keyword-list*
          *csv-line-number*
          *csv-cursor-line*
          *csv-buffer-fold-width*
          csv-max-column-number-strict
          csv-header-flag
          csv-separator-char
          csv-encode-string
          *csv-edit-dialog-width*
          *csv-edit-dialog-header-width*
          csv-edit-dialog-move
          *csv-record-mode-hook*
          *csv-record-mode-map*
          *csv-record-mode-syntax-table*
          csv-record-newline-char
          *csv-menu-name*
          *csv-menu-position*
          *csv-menu*))

(export '(csv-mode
          tsv-mode
          csv-change-separator
          csv-toggle-header-flag
          csv-view-line
          csv-edit-dialog
          csv-selection-edit-dialog
          csv-forward-column
          csv-backward-column
          csv-next-line
          csv-previous-line
          csv-next-line-keep-column
          csv-previous-line-keep-column
          csv-do-completion
          csv-optimize-column
          csv-adjust-column
          csv-change-row-column
          csv-convert-to-html
          csv-convert-to-box
          csv-select-insert-column
          csv-select-delete-column
          csv-select-change-column
          csv-insert-column
          csv-delete-column
          csv-change-column
          csv-select-sort
          csv-toggle-local-line-number
          csv-toggle-local-cursor-line
          csv-record-change-newline
          csv-record-view-line
          csv-record-toggle-view-line
          csv-record-edit
          csv-record-next-record
          csv-record-previous-record))

(defconstant *csv-version* "0.0.3.0"
  "csv-mode: バージョン")

(defvar *csv-line-number* t
  "csv-mode: 行番号表示指定 (t, nil, <OTHER (:remain)>)")
(defvar *csv-cursor-line* t
  "csv-mode: 行カーソル表示指定 (t, nil, <OTHER (:remain)>)")
(defvar *csv-buffer-fold-width* nil
  "csv-mode: テキスト折り返し指定 (t, nil, <integer>, <OTHER (:remain)>)")

(defvar-local csv-max-column-number-strict nil
  "csv-mode: 最大列数をどの程度正確に求めるか
t   : 全行を調べ正確な最大列数を出す
nil : 一行目と現在行のうち大きい列数を最大列数とみなす")
(defvar-local csv-header-flag t
  "csv-mode: 一行目をヘッダとみなすか (t, nil)")
(defvar-local csv-separator-char #\,
  "csv-mode: 列の区切り文字")
(defvar-local csv-encode-string :except-integer
  "csv-mode: 文字列の「\"」での括り方
t               : 全て「\"」で括る
:except-integer : 整数値以外を「\"」で括る
nil             : 必須の場合のみ「\"」で括る")
(defvar-local csv-record-newline-char #\;
  "csv-mode: csv-record-view-line 時に改行表示する文字")

(defvar *csv-edit-dialog-width* 245
  "csv-mode: ダイアログの幅")
(defvar *csv-edit-dialog-header-width* 48
  "csv-mode: ダイアログでのヘッダの幅")
(defvar-local csv-edit-dialog-move :next
  "csv-mode: ダイアログ編集の方向
:next     : 次行に移動
:previous : 前行に移動
その他    : 移動しない")

(defvar *csv-sort-method-list*
  (list
   (list "文字列 昇順 ([Aa]→[Zz])"
         #'(lambda (str-a str-b)
             (cond
              ((string-lessp str-a str-b) -1)
              ((string-equal str-a str-b)  0)
              (t 1))))
   (list "文字列 昇順 (A→Za→z)"
         #'(lambda (str-a str-b)
             (cond
              ((string< str-a str-b) -1)
              ((string= str-a str-b)  0)
              (t 1))))
   (list "文字列 降順 ([Zz]→[Aa])"
         #'(lambda (str-a str-b)
             (cond
              ((string-greaterp str-a str-b) -1)
              ((string-equal str-a str-b)  0)
              (t 1))))
   (list "文字列 降順 (z→aZ→A)"
         #'(lambda (str-a str-b)
             (cond
              ((string> str-a str-b) -1)
              ((string= str-a str-b)  0)
              (t 1))))
   (list "整数 昇順 (小→大)"
         #'(lambda (str-a str-b)
             (setq str-a (substitute-string str-a "," ""))
             (setq str-b (substitute-string str-b "," ""))
             (let (int-a int-b)
               (if (string-match "^-?[1-9][0-9]*$" str-a)
                   (setq int-a (parse-integer (match-string 0))))
               (if (string-match "^-?[1-9][0-9]*$" str-b)
                   (setq int-b (parse-integer (match-string 0))))
               (cond
                ((and int-a int-b)
                 (cond
                  ((< int-a int-b) -1)
                  ((= int-a int-b)  0)
                  (t 1)))
                (int-a -1)
                (int-b  1)
                (t 0)))))
   (list "整数 降順 (大→小)"
         #'(lambda (str-a str-b)
             (setq str-a (substitute-string str-a "," ""))
             (setq str-b (substitute-string str-b "," ""))
             (let (int-a int-b)
               (if (string-match "^-?[1-9][0-9]*$" str-a)
                   (setq int-a (parse-integer (match-string 0))))
               (if (string-match "^-?[1-9][0-9]*$" str-b)
                   (setq int-b (parse-integer (match-string 0))))
               (cond
                ((and int-a int-b)
                 (cond
                  ((> int-a int-b) -1)
                  ((= int-a int-b)  0)
                  (t 1)))
                (int-a -1)
                (int-b  1)
                (t 0)))))
   (list "空欄を末尾に"
         #'(lambda (str-a str-b)
             (cond
              ((and (string= str-a "") (string= str-b "")) 0)
              ((string= str-b "") -1)
              ((string= str-a "")  1)
              (t 0))))
   (list "空欄を先頭に"
         #'(lambda (str-a str-b)
             (cond
              ((and (string= str-a "") (string= str-b "")) 0)
              ((string= str-a "") -1)
              ((string= str-b "")  1)
              (t 0))))
   (list "◎○●△▲×"
         #'(lambda (str-a str-b)
             (let ((char-a (if (string= str-a "") #\SPC (char str-a 0)))
                   (char-b (if (string= str-b "") #\SPC (char str-b 0))))
               (cond
                ((char= char-a #\◎)
                 (case char-b ((#\◎) 0) (t -1)))
                ((char= char-a #\○)
                 (case char-b ((#\◎) 1) ((#\○) 0) (t -1)))
                ((char= char-a #\●)
                 (case char-b ((#\◎ #\○) 1) ((#\●) 0) (t -1)))
                ((char= char-a #\△)
                 (case char-b ((#\◎ #\○ #\●) 1) ((#\△) 0) (t -1)))
                ((char= char-a #\▲)
                 (case char-b ((#\◎ #\○ #\● #\△) 1) ((#\▲) 0) (t -1)))
                ((char= char-a #\×)
                 (case char-b ((#\◎ #\○ #\● #\△ #\▲) 1) ((#\×) 0) (t -1)))
                (t
                 (case char-b ((#\◎ #\○ #\● #\△ #\▲ #\×) 1) (t 0)))))))
   )
  "csv-mode: ソート方法のリスト")

(defvar *csv-www-special-chars-alist* '(("&amp;" . "&")
                                        ("&nbsp;" . " ")
                                        ("&lt;" . "<")
                                        ("&gt;" . ">")
                                        ("&quot;" . "\""))
  "csv-mode: csv-convert-to-html 時に変換する特殊文字の対応")

(defvar *csv-buffer-convert* "*CSV: Convert*"
  "csv-mode: 書式変換出力バッファ名")
(defvar *csv-buffer-record* "*CSV: Record*"
  "csv-mode: レコード用バッファ名")
(defvar *csv-buffer-temp* " *CSV: Temp*"
  "csv-mode: テンポラリバッファ名")

(defvar *csv-mode-hook* nil
  "csv-mode: モードフック")
(defvar *csv-mode-update-keymap-hook* nil
  "csv-mode: キーマップ更新反映時フック")

(defvar *csv-keyword-file* "CSV"
  "csv-mode: キーワードファイル")
(defvar *csv-keyword-hash-table* nil
  "csv-mode: キーワードハッシュテーブル")
(defvar *csv-regexp-keyword-list* nil
  "csv-mode: 正規表現キーワードリスト")

(defvar *csv-mode-map* nil
  "csv-mode: Local keymap")
(unless *csv-mode-map*
  (setq *csv-mode-map* (make-sparse-keymap))
  (define-key *csv-mode-map* #\M-TAB 'csv-do-completion)
  (define-key *csv-mode-map* #\TAB 'csv-forward-column)
  (define-key *csv-mode-map* #\C-n 'csv-next-line)
  (define-key *csv-mode-map* #\C-p 'csv-previous-line)
  (define-key *csv-mode-map* #\Down 'csv-next-line)
  (define-key *csv-mode-map* #\Up 'csv-previous-line)
  (define-key *csv-mode-map* #\M-n 'csv-next-line-keep-column)
  (define-key *csv-mode-map* #\M-p 'csv-previous-line-keep-column)
  (define-key *csv-mode-map* #\M-f 'csv-forward-column)
  (define-key *csv-mode-map* #\M-b 'csv-backward-column)
  (define-key *csv-mode-map* #\C-Down 'csv-next-line-keep-column)
  (define-key *csv-mode-map* #\C-Up   'csv-previous-line-keep-column)
  (define-key *csv-mode-map* #\C-Right'csv-forward-column)
  (define-key *csv-mode-map* #\C-Left 'csv-backward-column)
  (define-key *csv-mode-map* '(#\C-c #\C-w) 'csv-record-view-line)
  (define-key *csv-mode-map* '(#\C-c #\C-\,) 'csv-change-separator)
  (define-key *csv-mode-map* '(#\C-c #\C-\;) 'csv-record-change-newline)
  (define-key *csv-mode-map* '(#\C-c #\C-v) 'csv-view-line)
  (define-key *csv-mode-map* '(#\C-c #\C-t) 'csv-toggle-header-flag)
  (define-key *csv-mode-map* '(#\C-c #\C-o) 'csv-optimize-column)
  (define-key *csv-mode-map* '(#\C-c #\C-a) 'csv-adjust-column)
  (define-key *csv-mode-map* '(#\C-c #\C-x) 'csv-change-row-column)
  (define-key *csv-mode-map* '(#\C-c #\C-b) 'csv-convert-to-box)
  (define-key *csv-mode-map* '(#\C-c #\C-h) 'csv-convert-to-html)
  (define-key *csv-mode-map* '(#\C-c #\C-i) 'csv-select-insert-column)
  (define-key *csv-mode-map* '(#\C-c #\C-d) 'csv-select-delete-column)
  (define-key *csv-mode-map* '(#\C-c #\C-c) 'csv-select-change-column)
  (define-key *csv-mode-map* '(#\C-c #\C-s) 'csv-select-sort)
  (define-key *csv-mode-map* '(#\C-c #\C-e) 'csv-edit-dialog)
  (define-key *csv-mode-map* '(#\C-c #\M-C-e) 'csv-selection-edit-dialog))

(defvar *csv-mode-syntax-table* nil
  "csv-mode: Syntax table")
(unless *csv-mode-syntax-table*
  (setq *csv-mode-syntax-table* (make-syntax-table))
  (set-syntax-string *csv-mode-syntax-table* #\"))

;;;###autoload
(defun csv-mode (&optional separator-char)
  "Major mode for editing CSV file."
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'csv-mode)
  (use-syntax-table *csv-mode-syntax-table*)
  (and *csv-keyword-file*
       (null *csv-keyword-hash-table*)
       (setq *csv-keyword-hash-table*
             (load-keyword-file *csv-keyword-file* t)))
  (when *csv-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *csv-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *csv-regexp-keyword-list*)
  (case *csv-line-number*
    ((t)
     (set-local-window-flags (selected-buffer)
                             *window-flag-line-number* t))
    ((nil)
     (set-local-window-flags (selected-buffer)
                             *window-flag-line-number* nil)))
  (case *csv-cursor-line*
    ((t)
     (set-local-window-flags (selected-buffer)
                             *window-flag-cursor-line* t))
    ((nil)
     (set-local-window-flags (selected-buffer)
                             *window-flag-cursor-line* nil)))
  (if (or (eq *csv-buffer-fold-width* t)
          (eq *csv-buffer-fold-width* nil)
          (integerp *csv-buffer-fold-width*))
      (set-buffer-fold-width *csv-buffer-fold-width*))
  (when separator-char
    (setq csv-separator-char separator-char))
  (make-local-variable 'csv-mode-local-map)
  (csv-set-mode-name)
  (insert-csv-menu)
  (run-hooks '*csv-mode-hook*)
  (csv-update-keymap))

;;;###autoload
(defun tsv-mode ()
  "Major mode for editing TSV file."
  (interactive)
  (csv-mode #\TAB))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; header 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-toggle-header-flag ()
  "csv-mode: 一行目をヘッダとみなすかどうかをトグル"
  (interactive)
  (setq csv-header-flag (not csv-header-flag))
  (csv-set-mode-name))

(defun csv-set-mode-name ()
  "csv-mode: 一行目をヘッダとみなしているかどうかをモードラインに反映"
  (if csv-header-flag
      (setq mode-name "CSV[H]")
    (setq mode-name "CSV"))
  (refresh-screen))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; separator 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; separator の入力（と付随する処理）
(defun csv-insert-separator ()
  "csv-mode: セパレータ文字の入力"
  (interactive "*")
  (if overwrite-mode
      (overwrite-char csv-separator-char)
    (insert csv-separator-char)))

;; separator の変更
(defun csv-change-separator ()
  "csv-mode: セパレータと認識する文字の変更"
  (interactive)
  (let (input)
    (setq input (read-string (format nil "Separator Character (~S): " csv-separator-char)))
    (when (plusp (length input))
      (setq csv-separator-char (char input 0))
      (csv-update-keymap))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 移動 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-next-line (&optional (n 1))
  "csv-mode: 次の行に移動。行表示用ウィンドウに内容を表示。
引数：
  n  移動する行数
戻り値：移動した場合   t
        移動しない場合 nil"
  (interactive "p")
  (let ((goal-column (goal-column)))
    (when (next-line n)
      (if (and (find-buffer *csv-buffer-record*)
               (get-buffer-window *csv-buffer-record*))
          (csv-record-view-line))
      (set-goal-column goal-column)
      t)))

(defun csv-previous-line (&optional (n 1))
  "csv-mode: 前の行に移動。行表示用ウィンドウに内容を表示。
引数：
  n  移動する行数
戻り値：移動した場合   t
        移動しない場合 nil"
  (interactive "p")
  (csv-next-line (- n)))

(defun csv-forward-line ()
  (goto-eol)
  (forward-char))

(defun csv-forward-column (&optional (n 1))
  "csv-mode: 次の列(の開始ポイント)に移動
引数：
  n  移動する列数
戻り値：
  多値で、移動後の桁位置、列の開始ポイント、終了ポイント"
  (interactive "p")
  (when (minusp n)
    (return-from csv-forward-column (csv-backward-column (- n))))
  (let ((csv-current-column-number (csv-current-column-number))
        (csv-line-max-column-number (csv-line-max-column-number)))
    ;; 行単位の移動
    (while (> (+ csv-current-column-number n) csv-line-max-column-number)
      (decf n (1+ (- csv-line-max-column-number csv-current-column-number)))
      (if (forward-line)
          (progn
            (setq csv-current-column-number 1)
            (setq csv-line-max-column-number (csv-line-max-column-number)))
        (return-from csv-forward-column (csv-goto-column csv-line-max-column-number))))
    ;; 行単位移動後、行内での列移動
    (csv-goto-column (+ n csv-current-column-number))))

(defun csv-backward-column (&optional (n 1))
  "csv-mode: 前の列(の開始ポイント)に移動
引数：
  n  移動する列数
戻り値：
  多値で、移動後の桁位置、列の開始ポイント、終了ポイント"
  (interactive "p")
  (when (minusp n)
    (return-from csv-backward-column (csv-forward-column (- n))))
  (let ((csv-current-column-number (csv-current-column-number)))
    ;; 行単位の移動
    (while (>= n csv-current-column-number)
      (decf n csv-current-column-number)
      (if (backward-line)
          (progn
            (goto-eol)
            (setq csv-current-column-number (csv-line-max-column-number)))
        (return-from csv-backward-column (csv-goto-column 1))))
    ;; 行単位移動後、行内での列移動
    (csv-goto-column (- csv-current-column-number n))))

(defun csv-next-line-keep-column (&optional (n 1))
  "csv-mode: 列を維持したまま次の行に移動
列の先頭ポイントへ移動する。行を移動できない場合は、桁も移動しない。
引数：
  n  移動する行数
戻り値：行を移動した場合
           多値で、移動後の桁位置、列の開始ポイント、終了ポイント
        行を移動しない場合
           nil"
  (interactive "p")
  (let ((column-number (csv-current-column-number)))
    (unless (or (eq *last-command* 'csv-next-line-keep-column)
                (eq *last-command* 'csv-previous-line-keep-column))
      (csv-set-goal-column column-number))
    (when (csv-next-line n)
      (csv-goto-column (max column-number (csv-goal-column))))))

(defun csv-previous-line-keep-column (&optional (n 1))
  "csv-mode: 列を維持したまま前の行に移動
列の先頭ポイントへ移動する。行を移動できない場合は、桁も移動しない。
引数：
  n  移動する行数
戻り値：行を移動した場合
           多値で、移動後の桁位置、列の開始ポイント、終了ポイント
        行を移動しない場合
           nil"
  (interactive "p")
  (csv-next-line-keep-column (- n)))

(defvar-local csv-goal-column nil)
(defun csv-goal-column ()
  "csv-mode: CSVファイルのゴール列を取得する
戻り値：CSVファイルのゴール列"
  csv-goal-column)
(defun csv-set-goal-column (csv-column)
  "csv-mode: CSVファイルのゴール列を設定する
引数：
  csv-column  CSVファイルのゴール列"
  (setq csv-goal-column csv-column))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 表示 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-view-line (&optional (decode t))
  "csv-mode: 現在の行の内容を表示"
  (interactive)
  (let* ((max-column-number (csv-max-column-number))
         (column-list (csv-get-column-list decode max-column-number))
         header-list digit)
    ;; 各行の見出し作成
    (if csv-header-flag
        (setq header-list (csv-get-header-column-list decode max-column-number))
      (progn
        (setq digit (length (format nil "~D" max-column-number)))
        (dotimes (i max-column-number)
          (push (format nil "~V,'0D" digit (1+ i)) header-list))
        (setq header-list (nreverse header-list))))
    ;; 見出しと値の連結
    (dotimes (i max-column-number)
      (setf (nth i column-list)
            (concat (nth i header-list) ": " (nth i column-list))))
    ;; 表示
    (popup-string (format nil "行: ~D  列： ~D~%~A~A"
                          (csv-current-line-number) (csv-current-column-number)
                          "----------------\n"
                          (csv-join-string-list "\n" column-list))
                  (point))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 入力 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-do-completion ()
  "csv-mode: 他行同列からの補完入力"
  (interactive "*")
  (let ((opoint (point))
        (column-number (csv-current-column-number))
        (line-number (csv-current-line-number))
        line-list column-list str
        prefix len from to)
    (long-operation
      (save-excursion
        (multiple-value-bind (current-column column-from column-to)
            (csv-goto-column column-number :tail nil)
          (setq from column-from)
          (setq to column-to)
          (setq prefix (buffer-substring column-from opoint))
          (setq len (length prefix))
          (goto-char (point-min))
          (when csv-header-flag
            (csv-forward-line))
          (while (not (eobp))
            (do-events)
            (when (/= line-number (csv-current-line-number))
              (setq column-list (csv-get-column-list))
              (when (>= (length column-list) column-number)
                (setq str (nth (1- column-number) column-list))
                (if (and (string/= str "")
                         (>= (length str) len)
                         (string-equal prefix (substring str 0 len)))
                    (pushnew str line-list :test 'string=))))
            (csv-forward-line)))))
    (popup-list (stable-sort line-list #'string<)
                #'(lambda (str)
                    (if (string/= (buffer-substring from to) str)
                        (progn
                          (delete-region from to)
                          (insert str))
                      (goto-char to))
                    (if (= column-number (csv-max-column-number))
                        (csv-forward-column)
                      (cond
                       ((eolp)
                        (insert csv-separator-char))
                       ((char= csv-separator-char (char-after (point)))
                        (forward-char))))
                    (refresh-screen))
                from)))

(defun csv-selection-edit-dialog ()
  "csv-mode: 現在の行の内容をダイアログで選択編集"
  (interactive)
  (csv-edit-dialog t))

(defun csv-edit-dialog (&optional selection)
  "csv-mode: 現在の行の内容をダイアログで編集"
  (interactive "p")
  (let ((max-column-number (csv-max-column-number))
        (column-number (csv-current-column-number))
        column-list header-list control-list column-symbol-list
        (column-choices-list (list '()))
        column-list-initializers column-index-initializers
        combobox)
    ;; 各列の全文字列リストの取得
    (when selection
      (long-operation
        (save-excursion
          (goto-char (point-min))
          (when csv-header-flag
            (csv-forward-line))
          (while (not (eobp))
            (do-events)
            (setq column-list (csv-get-column-list t))
            ;; ここまでのカラム選択肢登録スロットが、現在行のカラム数より少ない場合
            ;; カラム選択肢登録スロットを広げる
            (dotimes (i (- (length column-list) (length column-choices-list)))
              (setq column-choices-list (nconc column-choices-list (list '()))))
            ;; カラム選択肢登録スロットに、現在行の各カラムの値を追加
            (dotimes (i (length column-list))
              (if (string/= "" (elt column-list i))
                  (pushnew (elt column-list i) (elt column-choices-list i) :test 'string=)))
            (csv-forward-line))
          (setq column-choices-list
                (mapcar #'(lambda (lst) (stable-sort lst #'string<)) column-choices-list))
          ;; ヘッダが最大カラム数の場合、ヘッダ行に合わせてカラム選択肢スロットを広げる
          (setq max-column-number (max max-column-number (length column-choices-list)))
          (dotimes (i (- max-column-number (length column-choices-list)))
            (setq column-choices-list (nconc column-choices-list (list '())))))))
    ;; column 用 symbol の生成
    (dotimes (i max-column-number)
      (push (make-symbol (concat "column" (format nil "~D" i))) column-symbol-list))
    ;; column-list-initializers
    (when selection
      (dotimes (i max-column-number)
        (push (cons (elt column-symbol-list i) (elt column-choices-list i))
              column-list-initializers))
      (setq column-list-initializers (nreverse column-list-initializers)))
    
    ;; 見だし文字列の取得
    (if csv-header-flag
        (setq header-list (csv-get-header-column-list t))
      (let ((digit (length (format nil "~D" max-column-number))))
        (dotimes (i max-column-number)
          (push (format nil "~V,'0D" digit (1+ i)) header-list))
        (setq header-list (nreverse header-list))))

    ;; 各行毎の処理
    (loop
      (if (or (not selection) (csv-header-line-p))
          (setq combobox nil)
        (setq combobox t))
      
      ;; 現在行から decode した値の取得
      (setq column-list (csv-get-column-list t))

      ;; column-index-initializers
      (when combobox
        (setq column-index-initializers nil)
        (let (pos)
          (dotimes (i (length column-list))
            (setq pos (position (elt column-list i) (elt column-choices-list i) :test 'string=))
            (when pos
              (push (cons (elt column-symbol-list i) pos) column-index-initializers)))))

      ;; dialog 用 control の準備
      (setq control-list nil)
      ;; 現在の列から入力させる。
      (let (j)
        (dotimes (i (- max-column-number (1- column-number)))
          (setq j (+ i (1- column-number)))
          (push `(:static nil ,(nth j header-list) #x50020000
                  1 ,(+ (* j 15) 3) ,*csv-edit-dialog-header-width* 8)
                control-list)
          (push (if combobox
                    `(:combobox ,(elt column-symbol-list j)
                      ,(nth j column-list) #x50210842
                      ,(+ 1 *csv-edit-dialog-header-width* 1) ,(+ (* j 15) 1)
                      ,(- *csv-edit-dialog-width* 1 *csv-edit-dialog-header-width* 1 1) 72)
                  `(:edit ,(elt column-symbol-list j)
                    ,(nth j column-list) #x50810080
                    ,(+ 1 *csv-edit-dialog-header-width* 1) ,(+ (* j 15) 1)
                    ,(- *csv-edit-dialog-width* 1 *csv-edit-dialog-header-width* 1 1) 14))
                control-list)))
      ;;
      (push `(:button nil "" #x50000007
              ,(- *csv-edit-dialog-width* 2 (* (+ 26 1) 4) 26 2 (* (+ 2 50) 2) 2)
              ,(- (* max-column-number 15) 2)
              ,(+ 2 (* (+ 26 1) 4) 26 2) 22) control-list)
      (push `(:button move-nil "定(&F)" #x50000009
              ,(- *csv-edit-dialog-width* (* (+ 26 1) 4) 26 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 6)
              26 10) control-list)
      (push `(:button move-next "次(&N)" #x50000009
              ,(- *csv-edit-dialog-width* (* (+ 26 1) 3) 26 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 6)
              26 10) control-list)
      (push `(:button move-previous "前(&P)" #x50000009
              ,(- *csv-edit-dialog-width* (* (+ 26 1) 2) 26 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 6)
              26 10) control-list)
      (push `(:button move-jump "跳(&J)" #x50000009
              ,(- *csv-edit-dialog-width* (* (+ 26 1) 1) 26 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 6)
              26 10) control-list)
      (push `(:edit move-jump-line nil #x50810086
              ,(- *csv-edit-dialog-width* 26 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 4)
              26 14) control-list)
      (push `(:spin move-jump-line-spin nil #x500000b6
              ,(- *csv-edit-dialog-width* 16 2 (* (+ 2 50) 2) 2)
              ,(+ (* max-column-number 15) 4)
              10 14) control-list)
      ;;
      (push `(:button IDOK "OK" #x50010001
              ,(- *csv-edit-dialog-width* 50 2 50 2) ,(+ (* max-column-number 15) 4)
              50 14) control-list)
      (push `(:button IDCANCEL "キャンセル" #x50010000
              ,(- *csv-edit-dialog-width* 50 2) ,(+ (* max-column-number 15) 4)
              50 14) control-list)
      ;;
      (dotimes (i (1- column-number))
        (push `(:static nil ,(nth i header-list) #x50020000
                1 ,(+ (* i 15) 3) ,*csv-edit-dialog-header-width* 8)
              control-list)
        (push (if combobox
                  `(:combobox ,(elt column-symbol-list i)
                    ,(nth i column-list) #x50210842
                    ,(+ 1 *csv-edit-dialog-header-width* 1) ,(+ (* i 15) 1)
                    ,(- *csv-edit-dialog-width* 1 *csv-edit-dialog-header-width* 1 1) 72)
                `(:edit ,(elt column-symbol-list i)
                  ,(nth i column-list) #x50810080
                  ,(+ 1 *csv-edit-dialog-header-width* 1) ,(+ (* i 15) 1)
                  ,(- *csv-edit-dialog-width* 1 *csv-edit-dialog-header-width* 1 1) 14))
              control-list))
      (setq control-list (nreverse control-list))
      (multiple-value-bind (result data)
          (dialog-box
           `(dialog 0 0 ,*csv-edit-dialog-width* ,(+ (* max-column-number 15) 2 19)
                    (:caption ,(concat (cond
                                        ((csv-header-line-p) "ヘッダ編集")
                                        (combobox            "選択編集")
                                        (t                   "編集"))
                                       (if (> (csv-current-line-number) (csv-max-line-number))
                                           (format nil " (新規:~D)" (csv-current-line-number))
                                         (format nil " (~D/~D: ~D)"
                                                 (csv-current-line-number)
                                                 (csv-max-line-number)
                                                 (csv-current-column-number)))))
                    (:font 9 "MS UI Gothic")
                    (:control
                     ,@control-list
                     ))
           (if combobox
               `(,(cons (case csv-edit-dialog-move
                          (:next 'move-next)
                          (:previous 'move-previous)
                          (t 'move-nil))
                        t)
                 ,(cons 'move-jump-line (format nil "~D" (csv-current-line-number)))
                 ,@column-list-initializers
                 ,@column-index-initializers)
             `(,(cons (case csv-edit-dialog-move
                        (:next 'move-next)
                        (:previous 'move-previous)
                        (t 'move-nil))
                      t)
               ,(cons 'move-jump-line (format nil "~D" (csv-current-line-number)))
               ))
           `((move-jump-line-spin :min 1 :max ,(1+ (csv-max-line-number)))
             (move-jump-line :min 1 :max ,(1+ (csv-max-line-number))
                             :range-error ,(format nil "1 以上 ~D 以下を指定してください" (1+ (csv-max-line-number)))
                             :type integer :type-error "数値を入力してください")
             (move-nil :disable (move-jump-line move-jump-line-spin))
             (move-next :disable (move-jump-line move-jump-line-spin))
             (move-previous :disable (move-jump-line move-jump-line-spin))
             (move-jump :enable (move-jump-line move-jump-line-spin))))
        ;; キーボードからの入力を全て捨てる。
        (while (read-char-no-hang *keyboard* nil nil nil))
        (when (eq result 'IDOK)
          ;; 移動フラグの更新
          (cond
           ((cdr (assoc 'move-nil data))
            (setq csv-edit-dialog-move nil))
           ((cdr (assoc 'move-next data))
            (setq csv-edit-dialog-move :next))
           ((cdr (assoc 'move-previous data))
            (setq csv-edit-dialog-move :previous)))
          ;; 編集
          (let ((column-list (csv-get-column-list nil max-column-number)) str modify)
            (dotimes (i max-column-number)
              (setq str (cdr (assoc (elt column-symbol-list i) data)))
              (setq str (string-trim " " str))
              (if (csv-need-encode-p str)
                  (setq str (csv-encode-string str)))
              (unless (csv-string-equal (elt column-list i) str)
                (setq modify t)
                (unless (csv-encoded-string-p str)
                  (setq str (csv-encode-string str)))
                (setf (elt column-list i) str)
                ;; column-choices-list 更新
                (when combobox
                  (setq str (csv-decode-string str))
                  (unless (position str (elt column-choices-list i) :test 'string=)
                    (setf (elt column-choices-list i)
                          (merge 'list (elt column-choices-list i) (list str) #'string<))
                    (setf (elt column-list-initializers i)
                          (cons (elt column-symbol-list i) (elt column-choices-list i)))))))
            (when modify
              (csv-goto-column
               (prog1
                   (csv-current-column-number)
                 (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
                 (insert (csv-join-string-list csv-separator-char column-list)))))))
        ;; 移動先の行に移動
        (if (eq result 'IDOK)
            (cond
             ((cdr (assoc 'move-jump data))
              (goto-line (cdr (assoc 'move-jump-line data)))
              (when (> (csv-current-line-number) (csv-max-line-number))
                (goto-eol)
                (insert "\n")))
             (csv-edit-dialog-move
              (case csv-edit-dialog-move
                (:next
                 (unless (csv-next-line-keep-column)
                   (goto-eol)
                   (insert "\n")))
                (:previous
                 (unless (csv-previous-line-keep-column)
                   (return)))))
             (t (return)))
          (return))
        (refresh-screen))
      (undo-boundary))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 列操作 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-select-insert-column ()
  "csv-mode: 列の挿入／追加 (popup-list)"
  (interactive "*")
  (let* ((max-column-number (csv-max-column-number))
         (digit (length (format nil "~D" max-column-number)))
         column-list)
    (save-excursion
      (if csv-header-flag
          (goto-char (point-min)))
      (setq column-list (csv-get-column-list t max-column-number)))
    (dotimes (i (length column-list))
      (setf (nth i column-list)
            (format nil "~V,'0D: ~A" digit (1+ i) (nth i column-list))))
    (setq column-list
          (nconc column-list (list (format nil "~V,'0D: [末尾に追加]" digit 0))))
    (message "挿入する列の位置を選択して下さい")
    (popup-list column-list #'(lambda (str)
                                (let (column-number)
                                  (string-match "[0-9]+" str)
                                  (setq column-number (parse-integer (match-string 0)))
                                  (csv-insert-column column-number max-column-number)
                                  (refresh-screen)))
                (point))))

(defun csv-insert-column (column-number &optional max-column-number)
  "csv-mode: 列の挿入／追加 (minibuffer)"
  (interactive "*nInsert Column: ")
  (if (plusp column-number)
      (message "列 ~D に挿入します" column-number)
    (message "列を追加します"))
  (long-operation
    (let ((ocolumn-number (csv-current-column-number))
          column-list modify)
      (unless max-column-number
        (setq max-column-number (csv-max-column-number)))
      (if (and (plusp column-number)
               (>= ocolumn-number column-number))
          (incf ocolumn-number))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (setq modify nil)
          (setq column-list (csv-get-column-list))
          (if (zerop column-number)
              (when (= (length column-list) max-column-number)
                (setq column-list (append column-list '("")))
                (setq modify t))
            (when (>= (length column-list) column-number)
              (setq column-list (append (subseq column-list 0 (1- column-number))
                                        '("")
                                        (subseq column-list (1- column-number))))
              (setq modify t)))
          (when modify
            (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
            (insert (csv-join-string-list csv-separator-char column-list)))
          (csv-forward-line)))
      (csv-goto-column ocolumn-number))))

(defun csv-select-delete-column ()
  "csv-mode: 列の削除 (popup-list)"
  (interactive "*")
  (let* ((max-column-number (csv-max-column-number))
         (digit (length (format nil "~D" max-column-number)))
         column-list)
    (save-excursion
      (if csv-header-flag
          (goto-char (point-min)))
      (setq column-list (csv-get-column-list t max-column-number)))
    (dotimes (i (length column-list))
      (setf (nth i column-list)
            (format nil "~V,'0D: ~A" digit (1+ i) (nth i column-list))))
    (message "削除する列を選択して下さい")
    (popup-list column-list #'(lambda (str)
                                (let (column-number)
                                  (string-match "[0-9]+" str)
                                  (setq column-number (parse-integer (match-string 0)))
                                  (csv-delete-column column-number)
                                  (refresh-screen)))
                (point))))

(defun csv-delete-column (column-number)
  "csv-mode: 列の削除 (minibuffer)"
  (interactive "*nDelete Column: ")
  (message "列 ~D を削除します" column-number)
  (long-operation
    (let ((ocolumn-number (csv-current-column-number))
          column-list)
      (if (> ocolumn-number column-number)
          (decf ocolumn-number))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (setq column-list (csv-get-column-list))
          (when (>= (length column-list) column-number)
            (setq column-list (append (subseq column-list 0 (1- column-number))
                                      (subseq column-list column-number)))
            (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
            (insert (csv-join-string-list csv-separator-char column-list)))
          (csv-forward-line)))
      (csv-goto-column ocolumn-number))))

(defun csv-select-change-column ()
  "csv-mode: 列の入換 (popup-list)"
  (interactive "*")
  (let* ((max-column-number (csv-max-column-number))
         (digit (length (format nil "~D" max-column-number)))
         column-list)
    (save-excursion
      (if csv-header-flag
          (goto-char (point-min)))
      (setq column-list (csv-get-column-list t max-column-number)))
    (dotimes (i (length column-list))
      (setf (nth i column-list)
            (format nil "~V,'0D: ~A" digit (1+ i) (nth i column-list))))
    (message "入れ換える１つ目の列を選択して下さい")
    (popup-list column-list
                #'(lambda (str)
                    (let (column-number-A)
                      (string-match "[0-9]+" str)
                      (setq column-number-A (parse-integer (match-string 0)))
                      (message "列 ~D と入れ換える列を選択して下さい" column-number-A)
                      (popup-list (append (subseq column-list 0 (1- column-number-A))
                                          (subseq column-list column-number-A))
                                  #'(lambda (str)
                                      (let (column-number-B)
                                        (string-match "[0-9]+" str)
                                        (setq column-number-B (parse-integer (match-string 0)))
                                        (csv-change-column column-number-A column-number-B)
                                        (refresh-screen)))
                                  (point))))
                (point))))

(defun csv-change-column (column-number-A column-number-B)
  "csv-mode: 列の入換 (minibuffer)"
  (interactive "*nChange Column A: \nnfor Column B: ")
  (message "列 ~D と列 ~D を入れ換えます" column-number-A column-number-B)
  (long-operation
    (let ((ocolumn-number (csv-current-column-number))
          column-list col-A col-B)
      (if (< column-number-A column-number-B)
          (setq col-A column-number-A col-B column-number-B)
        (setq col-A column-number-B col-B column-number-A))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (setq column-list (csv-get-column-list))
          (when (>= (length column-list) col-A)
            (dotimes (i (- col-B (length column-list)))
              (setq column-list (nconc column-list '(""))))
            (setq column-list (append (subseq column-list 0 (1- col-A))
                                      (subseq column-list (1- col-B) col-B)
                                      (subseq column-list col-A (1- col-B))
                                      (subseq column-list (1- col-A) col-A)
                                      (subseq column-list col-B)))
            (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
            (insert (csv-join-string-list csv-separator-char column-list)))
          (csv-forward-line)))
      (csv-goto-column ocolumn-number))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 行操作 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-select-sort ()
  "csv-mode: 指定列を基準に指定方法でソート (popup-list)"
  (interactive "*")
  (let* ((max-column-number (csv-max-column-number))
         (digit (length (format nil "~D" max-column-number)))
         column-list)
    (save-excursion
      (if csv-header-flag
          (goto-char (point-min)))
      (setq column-list (csv-get-column-list t max-column-number)))
    (dotimes (i (length column-list))
      (setf (nth i column-list)
            (format nil "~V,'0D: ~A" digit (1+ i) (nth i column-list))))
    (message "ソートの基準とする列を選択して下さい")
    (popup-list column-list
                #'(lambda (str)
                    (let (column-number
                          (sort-method-string-list (make-list (length *csv-sort-method-list*)))
                          (digit (length (format nil "~D" (length *csv-sort-method-list*)))))
                      (dotimes (i (length *csv-sort-method-list*))
                        (setf (nth i sort-method-string-list)
                              (format nil "~V,'0D: ~A" digit (1+ i) (car (nth i *csv-sort-method-list*)))))
                      (string-match "[0-9]+" str)
                      (setq column-number (parse-integer (match-string 0)))
                      (message "列 ~D のソートの方法を選択して下さい" column-number)
                      (popup-list sort-method-string-list
                                  #'(lambda (str)
                                      (let (num)
                                        (string-match "[0-9]+" str)
                                        (setq num (parse-integer (match-string 0)))
                                        (message "列 ~D を基準に [~A] でソートします"
                                                 column-number (car (nth (1- num) *csv-sort-method-list*)))
                                        (long-operation
                                          (csv-sort column-number (cadr (nth (1- num) *csv-sort-method-list*))))))
                                  (point))
                      (refresh-screen)))
                (point))))

(defun csv-sort (column-number predicate)
  "csv-mode: ソートの内部関数"
  (let ((temp-buffer (create-new-buffer *csv-buffer-temp*))
        (ocolumn-number (csv-current-column-number))
        (oline-number (csv-current-line-number))
        (max-line-number (csv-max-line-number))
        line-number-and-string-list line-number-list
        (line-number-offset 0) base-line-number)
    ;; ソートのキーとなる列を元にしたリストを作成
    (goto-char (point-min))
    (setq base-line-number (csv-current-line-number))
    (while (not (eobp))
      (push (cons (+ base-line-number line-number-offset)
                  (or (nth (1- column-number) (csv-get-column-list t)) ""))
            line-number-and-string-list)
      (csv-forward-line)
      (incf line-number-offset))
    (setq line-number-and-string-list (nreverse line-number-and-string-list))
    ;; ソート用比較関数の定義
    (flet ((stable-predicate (num-str-A num-str-B)
             (let ((num-A (car num-str-A)) (num-B (car num-str-B))
                   (str-A (cdr num-str-A)) (str-B (cdr num-str-B)))
               (case (funcall predicate str-A str-B)
                 ( 1 nil)
                 (-1 t)
                 ( 0 (< num-A num-B))
                 (t nil)))))
      (if csv-header-flag
          (setq line-number-and-string-list
                (append (subseq line-number-and-string-list 0 1)
                        (stable-sort (subseq line-number-and-string-list 1) #'stable-predicate)))
        (setq line-number-and-string-list
              (stable-sort line-number-and-string-list #'stable-predicate))))
    ;; 新規行でなかったならば、ソート後に移動すべき行番号を更新
    (setq line-number-list (mapcar #'car line-number-and-string-list))
    (if (<= oline-number max-line-number)
        (setq oline-number (+ base-line-number (position oline-number line-number-list))))
    ;; 一時バッファにソート済み文字列を出力
    (with-output-to-buffer (temp-buffer)
      (dolist (line-number line-number-list)
        (goto-line line-number)
        (format t "~A~%"
                (buffer-substring (progn (goto-bol) (point)) (progn (goto-eol) (point))))))
    ;; バッファ末尾の改行文字を適切に
    (when (progn (goto-char (point-max)) (not (bolp)))
      (save-excursion
        (set-buffer temp-buffer)
        (goto-char (point-max))
        (delete-backward-char)))
    ;; 現在のバッファに反映
    (delete-region (point-min) (point-max))
    (insert-buffer temp-buffer)
    (delete-buffer temp-buffer)
    (goto-line oline-number)
    (csv-goto-column ocolumn-number))
  (refresh-screen))

(defun csv-get-cell-string (line-number column-number &optional decode)
  "csv-mode: 指定行の指定列の文字列を返す"
  (let (column-list)
    (save-excursion
      (goto-line line-number)
      (setq column-list (csv-get-column-list))
      (if (< (length column-list) column-number)
          ""
        (let ((cell-string (nth (1- column-number) column-list)))
          (if decode
              (csv-decode-string cell-string)
            cell-string))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 書式変換 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-set-buffer-convert ()
  "csv-mode: 書式変換出力用バッファの準備"
  (save-excursion
    (get-buffer-create *csv-buffer-convert*)
    (erase-buffer *csv-buffer-convert*)
    (set-buffer *csv-buffer-convert*)
    (set-local-window-flags (selected-buffer) *window-flag-cursor-line* t)
    (set-buffer-fold-width nil)
    (make-local-variable 'need-not-save)
    (setq need-not-save t)))

(defun csv-optimize-column ()
  "csv-mode: 全行各列の左右の半角空白を削除"
  (interactive "*")
  (let ((column-number (csv-current-column-number))
        column-list (max-column-number 0))
    (long-operation
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (setq column-list (csv-get-column-list))
          (when (> (length column-list) max-column-number)
            (setq max-column-number (length column-list)))
          (dotimes (i (length column-list))
            (setf (nth i column-list) (string-trim " " (nth i column-list))))
          (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
          (insert (csv-join-string-list csv-separator-char column-list))
          (csv-forward-line))))
    (csv-max-column-number-strict-cache-set max-column-number)
    (csv-goto-column column-number)))

(defun csv-adjust-column ()
  "csv-mode: 全行の列の幅を揃える"
  (interactive "*")
  (let ((column-number (csv-current-column-number))
        (column-numberp-list (csv-column-numberp-list))
        column-list column-width-list column-width
        from to (max-column-number 0))
    (long-operation
      (save-excursion
        ;; column-width-list の作成
        (goto-char (point-min))
        (while (not (eobp))
          (do-events)
          (setq column-list (csv-get-column-list))
          (setq from (point))
          (dotimes (i (length column-list))
            (setq to (+ from (length (nth i column-list))))
            (setq column-width (- (progn (goto-char to) (current-column))
                                  (progn (goto-char from) (current-column))))
            (setq from (1+ to))
            (cond
             ((<= (length column-width-list) i)
              (setq column-width-list (nconc column-width-list (list column-width))))
             ((< (nth i column-width-list) column-width)
              (setf (nth i column-width-list) column-width))))
          (csv-forward-line))
        ;; 一行ずつ変換
        (goto-char (point-min))
        (while (not (eobp))
          (do-events)
          (setq column-list (csv-get-column-list))
          (when (> (length column-list) max-column-number)
            (setq max-column-number (length column-list)))
          (delete-region (progn (goto-bol) (point)) (progn (goto-eol) (point)))
          (dotimes (i (length column-list))
            (setf (nth i column-list)
                  (format nil (if (nth i column-numberp-list) "~VA" "~V@A")
                          (nth i column-width-list) (nth i column-list))))
          (insert (csv-join-string-list csv-separator-char column-list))
          (csv-forward-line))))
    (csv-max-column-number-strict-cache-set max-column-number)
    (csv-goto-column column-number)))

(defun csv-change-row-column ()
  "csv-mode: 行と列の入換"
  (interactive "*")
  (let ((temp-buffer (create-new-buffer *csv-buffer-temp*))
        (max-column-number (csv-max-column-number t))
        (separator-char csv-separator-char)
        current-column-number column-number column-list line-number
        (next-max-column-number 0))
    (long-operation
      (save-excursion
        (set-buffer temp-buffer)
        (goto-char (point-min))
        (insert "\n" max-column-number))
      (goto-char (point-min))
      (while (not (eobp))
        (incf next-max-column-number)
        (setq column-list (csv-get-column-list nil max-column-number))
        (save-excursion
          (set-buffer temp-buffer)
          (goto-char (point-min))
          (dolist (str column-list)
            (goto-eol)
            (insert separator-char str)
            (forward-line)))
        (csv-forward-line))
      (save-excursion
        (set-buffer temp-buffer)
        (goto-char (point-min))
        (while (not (eobp))
          (delete-char)
          (csv-forward-line)))
      (delete-region (point-min) (point-max))
      (insert-buffer temp-buffer)
      (delete-buffer temp-buffer)
      (csv-max-column-number-strict-cache-set (max next-max-column-number 1))
      (goto-char (point-min)))))

(defun csv-convert-to-html ()
  "csv-mode: HTML に書式変換し別バッファに出力"
  (interactive)
  (long-operation
    (let ((max-column-number (csv-max-column-number t))
          (column-numberp-list (csv-column-numberp-list)))
      (save-excursion
        (flet ((csv-convert-to-html-string ()
                 (with-output-to-string (so)
                   (let (column-str)
                     (format so "<tr>")
                     (do ((column (csv-get-column-list t) (cdr column))
                          (rest-column-number max-column-number (1- rest-column-number))
                          (column-numberp column-numberp-list (cdr column-numberp)))
                         ((zerop rest-column-number))
                       (setq column-str (car column))
                       (if (and (stringp column-str) (not (string-equal "" column-str)))
                           (format so "<td~A>~A</td>"
                                   (if (car column-numberp) " align=\"right\"" "")
                                   (csv-www-convert-special-chars column-str))
                         (format so "<td>　</td>")))
                     (format so "</tr>")))))
          (csv-set-buffer-convert)
          (goto-char (point-min))
          (with-output-to-buffer (*csv-buffer-convert*)
            (format t "<table border>~%")
            (while (not (eobp))
              (format t "~A~%" (csv-convert-to-html-string))
              (csv-forward-line))
            (format t "</table>~%"))))
      (unless (get-buffer-window *csv-buffer-convert*)
        (split-window)
        (set-buffer *csv-buffer-convert*)))))

(defun csv-www-convert-special-chars (str)
  "csv-mode: csv-convert-to-html で特殊文字を変換"
  (let (from to)
    (dolist (y *csv-www-special-chars-alist*)
      (setq from (cdr y))
      (setq to (car y))
      (setq str (substitute-string str from to))))
  str)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CSV BOX 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-convert-to-box (&optional (decode t))
  "csv-mode: 罫線付き列幅固定に書式変換し別バッファに出力"
  (interactive)
  (long-operation
    (let ((max-column-width-list (csv-max-column-width-list decode))
;          (column-numberp-list (csv-column-numberp-list))
          line-head-string line-tail-string line-separator-string)
      (save-excursion
        ;; 最大列幅の値を偶数に切り上げる
        (setq max-column-width-list
              (mapcar #'(lambda (num) (if (evenp num) num (1+ num)))
                      max-column-width-list))
        ;; 仕切り文字列の作成
        (setq line-head-string
              (with-output-to-string (so)
                (if max-column-width-list
                    (progn
                      (format so "┌")
                      (do ((width-list max-column-width-list (cdr width-list)))
                          ((null (cdr width-list))
                           (format so "~V@{~A~:*~}" (/ (car width-list) 2) "─")
                           (format so "┐~%"))
                        (format so "~V@{~A~:*~}" (/ (car width-list) 2) "─")
                        (format so "┬")))
                  (format so "┌┐~%"))))
        (setq line-separator-string
              (substitute-string
               (substitute-string
                (substitute-string line-head-string "┌" "├") "┐" "┤") "┬" "┼"))
        (setq line-tail-string
              (substitute-string
               (substitute-string
                (substitute-string line-head-string "┌" "└") "┐" "┘") "┬" "┴"))
        ;;
        (flet ((csv-convert-to-box-string ()
                 (with-output-to-string (so)
                   (format so "│")
                   (do ((column (csv-get-column-list decode) (cdr column))
                        (column-width (csv-column-width-list decode) (cdr column-width))
                        (max-column-width max-column-width-list (cdr max-column-width))
;                        (column-numberp column-numberp-list (cdr column-numberp))
                        )
                       ((null max-column-width))
                     (format so (if ;(car column-numberp)
                                    (string-match *csv-number-regexp* (or (car column) "")) "~VA│" "~V@A│")
                             (car max-column-width) (or (car column) ""))))))
          ;; 書式変換出力用バッファの準備
          (csv-set-buffer-convert)
          (save-excursion
            (set-buffer *csv-buffer-convert*)
            (csv-box-mode))
          ;; 変換出力
          (goto-char (point-min))
          (with-output-to-buffer (*csv-buffer-convert*)
            (format t "~A" line-head-string)
            (while (not (eobp))
              (format t "~A~%" (csv-convert-to-box-string))
              (goto-eol)
              (if (and (forward-char) (not (eobp)))
                  (format t "~A" line-separator-string)))
            (format t "~A" line-tail-string))))
      (unless (get-buffer-window *csv-buffer-convert*)
        (split-window)
        (set-buffer *csv-buffer-convert*)))))

(defun csv-box-position (left right center)
  (let ((ocolumn (current-column))
        from to str spaces left-spaces right-spaces)
    (save-excursion
      (when (and (or left right center)
                 (prog1 (scan-buffer "│" :reverse t) (setq from (1+ (point))))
                 (prog1 (scan-buffer "│" :no-dup t) (setq to (point))))
        (setq str (buffer-substring from to))
        (string-match "^\\( *\\)\\(.*?\\)\\( *\\)$" str)
        (setq str (match-string 2))
        (setq spaces (+ (length (match-string 1)) (length (match-string 3))))
        (cond
         (center
          (setq left-spaces
                (if (not right) (floor spaces 2) (ceiling spaces 2)))
          (setq right-spaces (- spaces left-spaces)))
         (right
          (setq left-spaces spaces)
          (setq right-spaces 0))
         (left
          (setq left-spaces 0)
          (setq right-spaces spaces)))
        (goto-char from)
        (delete-region from to)
        (insert (format nil "~VA~A~VA" left-spaces "" str right-spaces ""))))
    (goto-column ocolumn)))
(defun csv-box-lcenter ()
  "csv-mode: 罫線の間で左寄りセンタリング"
  (interactive)
  (csv-box-position t nil t))
(defun csv-box-rcenter ()
  "csv-mode: 罫線の間で右寄りセンタリング"
  (interactive)
  (csv-box-position nil t t))
(defun csv-box-center ()
  "csv-mode: 罫線の間でセンタリング"
  (interactive)
  (csv-box-position nil nil t))
(defun csv-box-left ()
  "csv-mode: 罫線の間で左揃え"
  (interactive)
  (csv-box-position t nil nil))
(defun csv-box-right ()
  "csv-mode: 罫線の間で右揃え"
  (interactive)
  (csv-box-position nil t nil))

(defvar *csv-box-mode-hook* nil)

(defvar *csv-box-mode-map* nil)
(unless *csv-box-mode-map*
  (setq *csv-box-mode-map* (make-sparse-keymap))
  (define-key *csv-box-mode-map* #\C-Up 'csv-box-rcenter)
  (define-key *csv-box-mode-map* #\C-Down 'csv-box-lcenter)
  (define-key *csv-box-mode-map* #\C-Left 'csv-box-left)
  (define-key *csv-box-mode-map* #\C-Right 'csv-box-right))

(defvar *csv-box-mode-syntax-table* nil)
(unless *csv-box-mode-syntax-table*
  (setq *csv-box-mode-syntax-table* (make-syntax-table)))

(defun csv-box-mode ()
  (interactive)
;  (kill-all-local-variables)
  (setq buffer-mode 'csv-box-mode)
  (setq mode-name "CSV Box")
  (use-keymap *csv-box-mode-map*)
  (use-syntax-table *csv-box-mode-syntax-table*)
  (run-hooks '*csv-box-mode-hook*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 文字列変換 (エンコード, デコード) 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-decode-string (str)
  "文字列をデコードする(手抜き)
文字列前後の連続する半角空白を取り除き、ダブルクォートを外す"
  (if (null str)
      ""
    (let* ((str (string-trim " " str))
           (len (length str))
           return-str)
      (if (< len 2)
          str
        (progn
          (if (and (eql (schar str 0) #\")
                   (eql (schar str (1- len)) #\"))
              (setq return-str (substring str 1 (1- len)))
            (setq return-str str))
          (substitute-string return-str "\"\"" "\""))))))

;; エンコード
(defun csv-encode-string (str)
  "バッファローカル変数 csv-encode-string の値に従い str をエンコード"
  (unless (stringp str)
    (return-from csv-encode-string nil))
  (setq str (string-trim " " str))
  (if (or (eq csv-encode-string t)
          (csv-need-encode-p str)
          (and (eq csv-encode-string :except-integer)
               (not (string-match "^-?[0-9]+$" str))))
      (concat "\"" (substitute-string str "\"" "\"\"") "\"")
    str))

(defun csv-need-encode-p (str)
  "encode が必須かどうか"
  (if (and (stringp str)
           (or (find csv-separator-char str) (find #\" str)))
      t nil))

(defun csv-encoded-string-p (str)
  (setq str (string-trim " " str))
  (let ((len (length str))
        quote-flag)
    (unless (and (string str) (plusp len))
      (return-from csv-encoded-string-p nil))
    (if (char= (char str 0) #\")
        (setq str (substring str 1))
      (return-from csv-encoded-string-p nil))
    (decf len)
    (if (and (plusp len) (char= (char str (1- len)) #\"))
        (setq str (substring str 0 (1- len)))
      (return-from csv-encoded-string-p nil))
    (decf len)
    (dotimes (i len)
      (cond
       ((char= (char str i) #\")
        (setq quote-flag (not quote-flag)))
       (t
        (if quote-flag
            (return-from csv-encoded-string-p nil)))))
    t))

;;
(defun csv-string-equal (string1 string2)
  (if (null string1) (setq string1 ""))
  (if (null string2) (setq string2 ""))
  (setq string1 (string-trim " " string1))
  (setq string2 (string-trim " " string2))
  (if (csv-encoded-string-p string1)
      (setq string1 (csv-decode-string string1)))
  (if (csv-encoded-string-p string2)
      (setq string2 (csv-decode-string string2)))
  (string-equal string1 string2))

;; keymap の更新
(defun csv-update-keymap ()
  (setq csv-mode-local-map (copy-keymap *csv-mode-map*))
  (use-keymap csv-mode-local-map)
  (define-key csv-mode-local-map csv-separator-char
              'csv-insert-separator)
  (run-hooks '*csv-mode-update-keymap-hook*))

;; 現在の列
(defun csv-current-column-number ()
  (length (csv-get-column-list nil nil (point))))

;; 現在の行
(defun csv-current-line-number ()
  (current-line-number))

(defun csv-header-line-p ()
  "csv-mode: ヘッダ行か判定"
  (and csv-header-flag
       (save-excursion
         (goto-bol)
         (= (point) (point-min)))))

;; 行数
(defun csv-max-line-number ()
  "csv-mode: 最大行を返す
バッファ末尾行が改行文字のみ場合は、その行はカウントしない"
  (save-excursion
    (goto-char (point-max))
    (if (bolp)
        (1- (current-line-number))
      (current-line-number))))

;; 現在の行の列数
(defun csv-line-max-column-number ()
  (save-excursion
    (goto-eol)
    (csv-current-column-number)))

;; 最大の列数
;; csv-max-column-number-strict の値で最大列数の正確さは異なる
(defvar-local csv-max-column-number-strict-cache nil)
(defun csv-max-column-number-strict-cache-set (max-column-number)
  (setq csv-max-column-number-strict-cache
        (list max-column-number (buffer-modified-count) (point-min) (point-max))))
(defun csv-max-column-number-strict-cache-get ()
  (nth 0 csv-max-column-number-strict-cache))
(defun csv-max-column-number-strict-cache-valid-p ()
  (and (eql (nth 1 csv-max-column-number-strict-cache) (buffer-modified-count))
       (eql (nth 2 csv-max-column-number-strict-cache) (point-min))
       (eql (nth 3 csv-max-column-number-strict-cache) (point-max))))
(defun csv-max-column-number (&optional strict)
  "csv-mode: 最大の列数を返す"
  (let ((max-column-number 0) column-number)
    (save-excursion
      (cond
       ;; キャッシュが有効な場合
       ((csv-max-column-number-strict-cache-valid-p)
        (setq max-column-number (csv-max-column-number-strict-cache-get)))
       ;; キャッシュが無効で、正確な「最大の列数」を調べる場合
       ((or csv-max-column-number-strict strict)
        (long-operation
          (goto-char (point-min))
          (while (not (eobp))
            (setq column-number (csv-line-max-column-number))
            (if (< max-column-number column-number)
                (setq max-column-number column-number))
            (csv-forward-line))
          (csv-max-column-number-strict-cache-set max-column-number)))
       ;; キャッシュが無効で、現在行と先頭行のみから「最大の列数」を調べる場合
       (t
        (setq max-column-number (csv-line-max-column-number))
        (goto-char (point-min))
        (setq column-number (csv-line-max-column-number))
        (if (< max-column-number column-number)
            (setq max-column-number column-number)))))
    max-column-number))

;; 列に移動
(defun csv-goto-column (csv-column-number &key tail)
  "指定された列に移動する。
移動が不可能な値が csv-column-number に指定された場合は、移動可能な範囲で
移動する。
引数：
  csv-column-number 移動先CSV列
  tail              non-nil の場合、CSV列の先頭でなく末尾に移動
戻り値：
  多値で、移動後の桁位置、列の開始ポイント、終了ポイント"
  (let (column-list
        (line-max-column-number (csv-line-max-column-number))
        (csv-col csv-column-number) (offset 0)
        from to)
    (goto-bol)
    (unless (plusp csv-col)
      (setq csv-col 1))
    (if (< line-max-column-number csv-col)
      (setq csv-col line-max-column-number))
    (setq column-list (csv-get-column-list))
    (dotimes (i (1- csv-col))
      (incf offset (1+ (length (pop column-list)))))
    (setq from (+ (point) offset))
    (incf offset (length (pop column-list)))
    (setq to (+ (point) offset))
    (if tail
        (goto-char to)
      (goto-char from))
    (values (current-column) from to)))

(defun csv-get-column-list (&optional decode max-column-number to)
  "現在行を分割し、各列の文字列を返す
引数：
  decode           : 
  max-column-number: 
  to               : (csv-current-column-number) でのみ使用。
                     処理対象とする末尾のポイント
                     指定がない場合は、行末のポイント
戻り値：
  各列の文字列のリスト"
  (save-excursion
    (let (columns line len c quote-p (start 0))
      (unless to
        (goto-eol)
        (setq to (point)))
      (goto-bol)
      (setq line (buffer-substring (point) to))
      (setq len (length line))
      (dotimes (index len)
        (setq c (schar line index))
        (if (eql c #\")
            (setq quote-p (not quote-p))
          (when (and (eql c csv-separator-char)
                     (not quote-p))
            (if decode
                (push (csv-decode-string (substring line start index)) columns)
              (push (substring line start index) columns))
            (setq start (1+ index)))))
      (if decode
          (push (csv-decode-string (substring line start)) columns)
        (push (substring line start) columns))
      (if max-column-number
          (append (reverse columns) (make-list (- max-column-number (length columns))
                                               :initial-element ""))
        (nreverse columns)))))

(defun csv-get-header-column-list (&optional (decode t) max-column-number)
  "ヘッダ行を分割し、各列の文字列を返す
引数：
  decode: 
  max-column-number: 
戻り値：
  各列の文字列のリスト"
  (save-excursion
    (goto-char (point-min))
    (csv-get-column-list decode max-column-number)))

(defun csv-column-width-list (&optional decode)
  "csv-mode: 現在行の各列の幅"
  (mapcar 'count-column (csv-get-column-list decode)))

(defun csv-max-column-width-list (&optional decode)
  "csv-mode: 各列の最大の幅"
  (let (max-column-width-list column-width-list cmax-column-width-list)
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (do-events)
        (setq column-width-list (csv-column-width-list decode))
        (if (> (length column-width-list) (length max-column-width-list))
            (setq max-column-width-list
                  (append max-column-width-list
                          (make-list (- (length column-width-list) (length max-column-width-list))
                                     :initial-element 0))))
        (do ((width-list column-width-list (cdr width-list))
             (max-width-list max-column-width-list (cdr max-width-list)))
            ((null width-list))
          (if (< (car max-width-list) (car width-list))
              (rplaca max-width-list (car width-list))))
        (csv-forward-line))
      max-column-width-list)))

;; 現在行の各列が数か
(defvar *csv-number-regexp*
  (compile-regexp "^\\(\\|#N/A\\|[\\$]?[-+]?[0-9,]*\\(\\.[0-9]*\\)?\\(E[-+]?[0-9]+\\)?\\)$")
  "数と判定する正規表現")
(defun csv-column-numberp-list ()
  (let (numberp-list current-line-column-numberp-list diff-length)
    (save-excursion
      (goto-char (point-min))
      (when csv-header-flag
        (csv-forward-line))
      (while (not (eobp))
        (do-events)
        (setq current-line-column-numberp-list
              (mapcar #'(lambda (str)
                          (string-match *csv-number-regexp* str))
                      (csv-get-column-list t)))
        (setq diff-length (- (length numberp-list) (length current-line-column-numberp-list)))
        (if (plusp diff-length)
            (setq current-line-column-numberp-list
                  (nconc current-line-column-numberp-list
                         (make-list diff-length :initial-element t)))
          (setq numberp-list
                (nconc numberp-list
                       (make-list (- diff-length) :initial-element t))))
        (setq numberp-list
              (mapcar #'(lambda (x y) (if (and x y) t nil))
                      numberp-list current-line-column-numberp-list))
        (csv-forward-line))
      numberp-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CSV RECORD 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *csv-record-header-tag* 'csv-record-header
  "csv-record-mode: ヘッダタグ")
(defvar *csv-record-header-attribute* '(:bold t :foreground 1)
  "csv-record-mode: ヘッダ表示属性")

(defvar *csv-record-mode-syntax-table* nil
  "csv-record-mode: Syntax table")
(unless *csv-record-mode-syntax-table*
  (setq *csv-record-mode-syntax-table* (make-syntax-table))
  (set-syntax-string *csv-record-mode-syntax-table* #\"))

(defvar *csv-record-mode-hook* nil)

(defvar *csv-record-mode-map* nil
  "csv-record-mode: Local keymap")
(unless *csv-record-mode-map*
  (setq *csv-record-mode-map* (make-sparse-keymap))
  (define-key *csv-record-mode-map* #\RET 'csv-record-edit)
  (define-key *csv-record-mode-map* #\n 'csv-record-next-record)
  (define-key *csv-record-mode-map* #\p 'csv-record-previous-record))

(defun csv-record-mode ()
  "csv-record-mode: レコード表示・編集モード"
  (kill-all-local-variables)
  (setq buffer-mode 'csv-record-mode)
  (setq mode-name "CSV Record")
  (use-syntax-table *csv-record-mode-syntax-table*)
  (set-buffer-fold-width nil)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'csv-record-source-buffer)
  (make-local-variable 'csv-record-source-buffer-modified-count)
  (make-local-variable 'csv-record-source-buffer-line-number)
  (use-keymap *csv-record-mode-map*)
  (toggle-read-only t)
  (run-hooks '*csv-record-mode-hook*))

(defun csv-record-change-newline ()
  "csv-mode: 改行表示文字と認識する文字の変更"
  (interactive)
  (let (input)
    (setq input (read-string (format nil "Newline Character (~S): " csv-record-newline-char)))
    (when (plusp (length input))
      (setq csv-record-newline-char (char input 0))
      (when (and (boundp 'csv-record-source-buffer)
                 (bufferp csv-record-source-buffer)
                 (not (deleted-buffer-p csv-record-source-buffer)))
        (save-excursion
          (set-buffer csv-record-source-buffer)
          (setq csv-record-newline-char (char input 0))))
      csv-record-newline-char)))

(defun csv-record-set-buffer (&optional (decode t))
  "csv-mode: レコードバッファを準備し、値をセット"
  (save-excursion
    (let* ((max-column-number (csv-max-column-number))
           (column-list (csv-get-column-list decode max-column-number))
           header-list max-header-width
           (obuffer (selected-buffer))
           (obuffer-modified-count (buffer-modified-count))
           (oline-number (current-line-number)))
      ;; header-list 作成
      (if csv-header-flag
          (progn
            (setq header-list (csv-get-header-column-list decode max-column-number))
            (setq max-header-width (length (format nil "~D" max-column-number)))
            (dotimes (i max-column-number)
              (setf (nth i header-list)
                    (format nil "~V,'0D ~A" max-header-width (1+ i) (nth i header-list))))
            (setq max-header-width (apply #'max (mapcar #'count-column header-list))))
        (progn
          (setq max-header-width (length (format nil "~D" max-column-number)))
          (dotimes (i max-column-number)
            (push (format nil "~V,'0D" max-header-width (1+ i)) header-list))
          (setq header-list (nreverse header-list))))

      ;; buffer 準備
      (get-buffer-create *csv-buffer-record*)
      (erase-buffer *csv-buffer-record*)
      (save-excursion
        (set-buffer *csv-buffer-record*)
        (csv-record-mode)
        (setq csv-record-source-buffer obuffer)
        (setq csv-record-source-buffer-modified-count obuffer-modified-count)
        (setq csv-record-source-buffer-line-number oline-number)
        (setq mode-line-format (concat "--%*- %b (%M)"
                                       (format nil "  Source: ~A:(~D)  "
                                               (buffer-name csv-record-source-buffer)
                                               csv-record-source-buffer-line-number)
                                       "[%k:%l] %P %f"))
        ;; csv-record-source-buffer のバッファローカル変数をコピー
        (setq csv-header-flag
              (buffer-local-value csv-record-source-buffer 'csv-header-flag))
        (setq csv-max-column-number-strict
              (buffer-local-value csv-record-source-buffer 'csv-max-column-number-strict))
        (setq csv-separator-char
              (buffer-local-value csv-record-source-buffer 'csv-separator-char))
        (setq csv-encode-string
              (buffer-local-value csv-record-source-buffer 'csv-encode-string))
        (setq csv-record-newline-char
              (buffer-local-value csv-record-source-buffer 'csv-record-newline-char))

        ;; 出力
        (toggle-read-only nil)
        (let ((header-list header-list)
              (kept-undo-information nil))
          (declare (special kept-undo-information))
          (dotimes (i max-column-number)
            (dolist (x (or (and csv-record-newline-char
                                (split-string (nth i column-list) csv-record-newline-char))
                           '("")))
              (apply #'set-text-attribute
                     (append
                      (list
                       (point)
                       (progn
                         (if (stringp (nth i header-list))
                             (insert (format nil "~V@A : " max-header-width (nth i header-list)))
                           (insert (format nil "~V@A * " max-header-width  "")))
                         (point))
                       *csv-record-header-tag*)
                      *csv-record-header-attribute*))
              (insert (format nil "~A~%" x))
              (setf (nth i header-list) nil))))
        (set-buffer-modified-p nil *csv-buffer-record*)
        (undo-boundary)
        (toggle-read-only t)
        (goto-char (point-min))))))

(defun csv-record-view-buffer ()
  "csv-mode: レコード用バッファの表示"
  (let (org-window)
    (unless (get-buffer-window *csv-buffer-record*)
      (split-window)
      (setq org-window (selected-window))
      (other-window)
      (set-buffer *csv-buffer-record*)
      (set-window org-window))))

(defun csv-record-view-line (&optional (decode t))
  "csv-mode: 現在の行の内容をレコード用ウィンドウに表示"
  (interactive)
  (csv-record-set-buffer decode)
  (csv-record-view-buffer))

(defun csv-record-toggle-view-line (&optional (decode t))
  "csv-mode: レコード用ウィンドウの表示をトグル"
  (interactive)
  (unless (eq buffer-mode 'csv-mode)
    (return-from csv-record-toggle-view-line))
  (let ((owindow (selected-window)))
    (if (and (find-buffer *csv-buffer-record*)
             (get-buffer-window *csv-buffer-record*))
        (progn
          (set-window (get-buffer-window *csv-buffer-record*))
          (delete-window)
          (set-window owindow))
      (csv-record-view-line))))

(defun csv-record-get-column-list ()
  "csv-record-mode: レコード用バッファからカラム値のリストを取得"
  (let (column-list value
        (record-newline-char-str (string csv-record-newline-char)))
    (unless (and (bufferp csv-record-source-buffer)
                 (not (deleted-buffer-p csv-record-source-buffer)))
      (return-from csv-record-get-column-list nil))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (multiple-value-bind (from to tag)
            (find-text-attribute *csv-record-header-tag* :start (point))
          (unless from
            (return))
          (setq value (buffer-substring to (progn (goto-eol) (point))))
          (if (char= #\: (char-after (- to 2)))
              (push value column-list)
            (setf (car column-list)
                  (concat (car column-list) record-newline-char-str value)))
          (forward-char)))
      (reverse column-list))))

(defun csv-record-edit ()
  "csv-record-mode: レコードを編集"
  (interactive)
  (flet ((csv-record-source-buffer-valid-p-or-return ()
           (unless (and (boundp 'csv-record-source-buffer)
                        (bufferp csv-record-source-buffer)
                        (not (deleted-buffer-p csv-record-source-buffer)))
             (message "元バッファが存在しないため、このバッファで編集できません。")
             (return-from csv-record-edit nil))
           (when (buffer-local-value csv-record-source-buffer 'buffer-read-only)
             (message "元バッファが編集不可のため、このバッファで編集できません。")
             (return-from csv-record-edit nil))
           (unless (eql csv-record-source-buffer-modified-count
                        (buffer-modified-count csv-record-source-buffer))
             (message "元バッファが編集されているため、このバッファでは編集できません。")
             (return-from csv-record-edit nil))))
    (let (value column header
          column-from column-to max-header-width
          column-list)
      ;; 元バッファチェック
      (csv-record-source-buffer-valid-p-or-return)

      (save-excursion
        ;; カラム開始行に移動
        (goto-bol)
        (while (not (looking-at "[0-9]"))
          (unless (previous-line)
            (return)))
        (setq column-from (point))
        ;; ヘッダを取得
        (multiple-value-bind (from to tag)
            (find-text-attribute *csv-record-header-tag* :start (point))
          (unless from
            (message "バッファの情報が不正です。")
            (return-from csv-record-edit nil))
          (setq header (string-right-trim " " (buffer-substring from (- to 3))))
          ;; ヘッダ長を取得
          (goto-char (- to 3))
          (setq max-header-width (current-column))
          (goto-char column-from))
        ;; カラムの値を取得
        (loop
          (multiple-value-bind (from to tag)
              (find-text-attribute *csv-record-header-tag* :start (point))
            (unless from
              (return))
            (setq value (buffer-substring to (progn (goto-eol) (point))))

            (if (char= #\: (char-after (- to 2)))
                (setq column value)
              (setq column (concat column (string csv-record-newline-char) value))))
          (unless (forward-char)
            (return))
          (when (or (looking-at "[0-9]") (eobp))
            (return)))
        (setq column-to (point)))

      ;; 新しい値をユーザから取得
      (setq value (read-string (concat header ": ") :default column))
      (setq value (substitute-string value "\n" (string csv-record-newline-char)))

      ;; 元バッファチェック
      (csv-record-source-buffer-valid-p-or-return)

      ;; record バッファ更新
      (toggle-read-only nil)
      (delete-region column-from column-to)
      (goto-char column-from)
      (dolist (x (or (and csv-record-newline-char
                          (split-string value csv-record-newline-char))
                     '("")))
        (apply #'set-text-attribute
               (append
                (list
                 (point)
                 (progn
                   (if (stringp header)
                       (insert (format nil "~V@A : " max-header-width header))
                     (insert (format nil "~V@A * " max-header-width  "")))
                   (point))
                 *csv-record-header-tag*)
                *csv-record-header-attribute*))
        (set-text-attribute (point)
                            (progn (insert (format nil "~A~%" x)) (point))
                            nil)
        (setq header nil))
      (toggle-read-only t)
      (goto-char column-from)

      ;; ソースバッファ更新
      (setq column-list (csv-record-get-column-list))
      (save-excursion
        (set-buffer csv-record-source-buffer)
        (goto-line (buffer-local-value *csv-buffer-record* 'csv-record-source-buffer-line-number))
        (delete-region (point) (progn (goto-eol) (point)))
        (setq column-list (mapcar 'csv-encode-string column-list))
        (insert (csv-join-string-list csv-separator-char column-list))
        (when (eobp)
          (insert "\n")
          (backward-line))
        (goto-bol))

      ;; csv-record-source-buffer-modified-count 更新
      (setq csv-record-source-buffer-modified-count
            (buffer-modified-count csv-record-source-buffer)))))

(defun csv-record-next-record (&optional (n 1))
  "csv-record-mode: 次のレコードを表示"
  (interactive)
  (unless (eq (selected-buffer) (find-buffer *csv-buffer-record*))
    (return-from csv-record-next-record nil))
  (let ((window-conf (current-window-configuration))
        (source-buffer-line-number csv-record-source-buffer-line-number)
        column-str source-buffer-point org-window)
    (save-excursion
      ;; カラム開始行に移動
      (goto-bol)
      (while (not (looking-at "[0-9]+"))
        (unless (previous-line)
          (return)))
      (setq column-str (match-string 0)))
    (goto-line csv-record-source-buffer-line-number)
    (if (get-buffer-window csv-record-source-buffer)
        (set-window (get-buffer-window csv-record-source-buffer))
      (set-buffer csv-record-source-buffer))
    (goto-line source-buffer-line-number)
    (csv-next-line n)
    (setq source-buffer-point (point))
    (csv-record-view-line)
    (set-window-configuration window-conf)
    (when (get-buffer-window csv-record-source-buffer)
      (setq org-window (selected-window))
      (set-window (get-buffer-window csv-record-source-buffer))
      (goto-char source-buffer-point)
      (set-window org-window))
    (scan-buffer (format nil "^~A " column-str) :regexp t)))

(defun csv-record-previous-record (&optional (n 1))
  "csv-record-mode: 前のレコードを表示"
  (interactive)
  (csv-record-next-record (- n)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 汎用関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun csv-join-string-list (join str-list)
  (if (characterp join)
      (setq join (string join)))
  (if (and (stringp join) str-list)
      (let (corrected-join)
        (setq corrected-join (substitute-string join "~" "~~"))
        (substring (format nil (concat "~{" corrected-join "~A~}") str-list)
                   (length join)))
    ""))

(defun csv-window-flag-valid-p (flag)
  (let (valid local)
    (multiple-value-bind (on off)
        (get-local-window-flags (selected-buffer))
      (cond
       ((plusp (logand off flag))
        (setq valid nil)
        (setq local t))
       ((plusp (logand on flag))
        (setq valid t)
        (setq local t))
       ((plusp (logand (get-window-flags) flag))
        (setq valid t)
        (setq local nil))
       (t
        (setq valid nil)
        (setq local nil))))
    (values valid local)))

(defun csv-toggle-local-window-flag (flag &optional (arg nil sv))
  (set-local-window-flags (selected-buffer)
                          flag
                          (if sv
                              arg
                            (not (csv-window-flag-valid-p flag)))))

(defun csv-toggle-local-line-number (&optional (arg nil sv))
  (interactive)
  (if sv
      (csv-toggle-local-window-flag *window-flag-line-number* arg)
    (csv-toggle-local-window-flag *window-flag-line-number*)))

(defun csv-toggle-local-cursor-line (&optional (arg nil sv))
  (interactive)
  (if sv
      (csv-toggle-local-window-flag *window-flag-cursor-line* arg)
    (csv-toggle-local-window-flag *window-flag-cursor-line*)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; メニュー
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *csv-menu-name*  "CSV(&C)"
  "csv-mode: メニュー文字列")
(defvar *csv-menu-position* 'ed::help
  "csv-mode: メニュー位置")
(defvar *csv-menu* nil
  "csv-mode: メニュー")
(defun init-csv-menu ()
  (setq *csv-menu*
        (let ((menu (create-popup-menu 'csv)))
          (add-menu-item menu nil "他行同列からの補完入力(& )..."
                         'csv-do-completion)
          (add-menu-item menu nil "編集ダイアログ(&E)..."
                         'csv-edit-dialog)
          (add-menu-item menu nil "選択編集ダイアログ(&F)..."
                         'csv-selection-edit-dialog)
          (add-menu-item menu nil "現在行内容表示(&V)"
                         'csv-view-line)
          (add-menu-item menu nil "現在行内容ウィンドウ表示(&W)"
                         'csv-record-view-line)
          (add-menu-item menu nil "ソート(&S)..."
                         'csv-select-sort)
          (add-menu-separator menu)
          (add-menu-item menu nil "列の挿入/追加(&I)..."
                         'csv-select-insert-column)
          (add-menu-item menu nil "列の削除(&D)..."
                         'csv-select-delete-column)
          (add-menu-item menu nil "列の入換(&C)..."
                         'csv-select-change-column)
          (add-menu-separator menu)
          (add-menu-item menu nil "列幅の最適化(&O)"
                         'csv-optimize-column)
          (add-menu-item menu nil "列幅を揃える(&A)"
                         'csv-adjust-column)
          (add-menu-separator menu)
          (add-menu-item menu nil "行・列の入換(&X)"
                         'csv-change-row-column)
          (add-menu-separator menu)
          (add-menu-item menu nil "罫線囲みに変換(&B)"
                         'csv-convert-to-box)
          (add-menu-item menu nil "HTML 書式に変換(&H)"
                         'csv-convert-to-html)
          (add-menu-separator menu)
          (add-menu-item menu nil "先頭行ヘッダ(&T)"
                         'csv-toggle-header-flag
                         #'(lambda ()
                             (and csv-header-flag :check)))
          (add-menu-item menu nil "セパレータ認識文字変更(&,)..."
                         'csv-change-separator)
          (add-menu-item menu nil "改行表示認識文字変更(&;)..."
                         'csv-record-change-newline)
          (add-menu-separator menu)
          (add-menu-item menu nil "全て「\"」で括る (&1)"
                         #'(lambda ()
                             (interactive)
                             (setq csv-encode-string t))
                         #'(lambda ()
                             (and (eq csv-encode-string t) :check)))
          (add-menu-item menu nil "整数以外を「\"」で括る (&2)"
                         #'(lambda ()
                             (interactive)
                             (setq csv-encode-string :except-integer))
                         #'(lambda ()
                             (and (eq csv-encode-string :except-integer) :check)))
          (add-menu-item menu nil "必須の場合のみ「\"」で括る (&3)"
                         #'(lambda ()
                             (interactive)
                             (setq csv-encode-string nil))
                         #'(lambda ()
                             (and (not (eq csv-encode-string t))
                                  (not (eq csv-encode-string :except-integer)) :check)))
          (add-menu-separator menu)
          (add-menu-item menu nil "全行調べ正確に最大列数を求める(&1)"
                         #'(lambda ()
                             (interactive)
                             (setq csv-max-column-number-strict t))
                         #'(lambda ()
                             (and csv-max-column-number-strict :check)))
          (add-menu-item menu nil "現在行と先頭行を調べる(&2)"
                         #'(lambda ()
                             (interactive)
                             (setq csv-max-column-number-strict nil))
                         #'(lambda ()
                             (and (not csv-max-column-number-strict) :check)))
          (add-menu-separator menu)
          (add-menu-item menu 'cursor-line "行カーソル(&+)"
                         'csv-toggle-local-cursor-line
                         #'(lambda ()
                             (and (csv-window-flag-valid-p *window-flag-cursor-line*)
                                  :check)))
          (add-menu-item menu 'line-number "行番号(&#)"
                         'csv-toggle-local-line-number
                         #'(lambda ()
                             (and (csv-window-flag-valid-p *window-flag-line-number*)
                                  :check)))
          menu)))

(init-csv-menu)

(defun insert-csv-menu (&key (menu (current-menu))
                             (position *csv-menu-position*)
                             (menu-name *csv-menu-name*))
  "csv-mode: CSVメニューを追加したローカルメニューの設定"
  (when (menup menu)
    (setq menu (copy-menu-items menu (create-menu)))
    (delete-csv-menu menu)
    (cond
     ((and (numberp position) (integerp position))
      (insert-popup-menu menu position *csv-menu* menu-name))
     ((and (symbolp position) (get-menu-position menu position))
      (insert-popup-menu menu (get-menu-position menu position)
                         *csv-menu* menu-name))
     (t
      (add-popup-menu menu *csv-menu* menu-name)))
    (use-local-menu menu)))
(defun delete-csv-menu (&optional (menu (current-menu)))
  "csv-mode: メニューを削除"
  (let (ret)
    (if (menup menu)
        (while (delete-menu menu 'ed::csv)
          (setq ret t)))
    ret))
(defun insert-csv-menu-all-buffers ()
  "csv-mode: 起動時のローカルメニューの設定"
  (save-excursion
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (when (eq buffer-mode 'csv-mode)
        (insert-csv-menu)))))

;; 「終了時の状態を保存する」設定時に対処
(unless *app-menu*
  ;; local-menu は他のメニューが全て生成された後に変更すべきなので
  ;; *init-app-menus-hook* でなく *post-startup-hook* にしてみた。
  (add-hook '*post-startup-hook* 'insert-csv-menu-all-buffers))

;;; csv-mode.l ends here
