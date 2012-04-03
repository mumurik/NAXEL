;;; -*- Mode: Lisp; Package: BROWSEREX -*-
;;; browserex.l --- browser.dll 使用のためのサンプル

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 10:33:18 +0900>

;;; Commentary:

;; Description:
;;
;;  satoshi oowada さんの公開されている browser.dll, browser.l は
;;  様々な用途に使用できる大変素晴らしいものです。
;;
;;  browser.l は browser.dll の使用方法のサンプルファイルであり、
;;  それを参考にして browser.dll の操作を各自が記述するためのものなので、
;;  その記述だけでは browser.dll を思うように扱えないこともあります。
;;
;;  browserex.l は browser.dll を主に HTML ファイルのプレビューアとして
;;  利用する際に便利と思える機能を browser.l, browser.txt, browser.cpp を
;;  参考にして記述した、もう一つのサンプル Lisp ファイルです。
;;
;;  いまいたけをさんの公開されている browser.dll 拡張版の機能も用いることが
;;  できるようにしました。
;;  山本泰三さんの公開されている browser.dll Gecko 編にも仮対応しています。
;;

;; 出来ること:
;;
;;      ・入力された URL の内容の表示
;;      ・表示内容の再描画
;;      ・開いているかどうかの判定
;;      ・閉じる
;;      ・表示開始時（開くとき）のみ有効な表示位置（上下左右、高さ or 幅）指定
;;      ・xyzzy 上の表示位置（上下左右）の変更とその位置の自動保存
;;      ・カレントバッファのファイル内容表示
;;      ・ファイル名を持たないカレントバッファの内容を
;;        文字コード・改行コードを保ったままテンポラリファイルに出力し、
;;        HTML ファイルとして表示
;;      ・カレントバッファのファイルのディレクトリ表示
;;      ・（ディレクトリ表示時のスタイルの指定）
;;      ・ツールバーからの操作
;;      ・マウスで指定した URL、ローカルファイルパスの内容の表示
;;      ・スクロール
;;      ・（進む、戻る、ホームへ移動、開いている URI の表示）
;;

;; Installation:
;;
;;      1. browser.dll, win-window.l をインストールします。
;;
;;      2. アーカイブを展開して browserex.l を $XYZZY/site-lisp に
;;         コピーします。
;;         toolbar-browserex.bmp を $XYZZY/etc にコピーします。
;;
;;      3. 必要ならばバイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/browserex.l
;;
;;      4. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "browserex")
;;
;;      5. 必要ならばキーバインド設定のコードを追加します。
;;
;;              例：
;;              (global-set-key #\M-F8 'bx:change-browser)
;;              (global-set-key #\M-F9 'bx:navigate-current-buffer)
;;              (global-set-key #\M-F10 'bx:navigate-current-buffer-directory)
;;              (global-set-key #\M-F11 'bx:rotate-browser)
;;              (global-set-key #\M-F12 'bx:close-browser)
;;              (global-set-key #\RBtnUp 'bx:browserex-mouse-menu-popup)
;;              (global-set-key #\Apps 'bx:browserex-apps-popup)
;;              (global-set-key #\M-Up 'bx:browserex-scroll-up)
;;              (global-set-key #\M-Down 'bx:browserex-scroll-down)
;;              (global-set-key #\M-Left 'bx:browserex-scroll-left)
;;              (global-set-key #\M-Right 'bx:browserex-scroll-right)
;;              (global-set-key #\M-PageUp #'(lambda () (interactive) (bx:browserex-scroll-up :unit :page)))
;;              (global-set-key #\M-PageDown #'(lambda () (interactive) (bx:browserex-scroll-down :unit :page)))
;;              (global-set-key #\M-Home #'(lambda () (interactive) (bx:browserex-scroll-up :unit :all)))
;;              (global-set-key #\M-End #'(lambda () (interactive) (bx:browserex-scroll-down :unit :all)))
;;
;;      6. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;
;;      7. 必要ならばメニューの「表示」→「ツールバー」に追加されている
;;         「Browser」をチェックし、ツールバーを表示します。

;; Uninstallation:
;;
;;      1. ESC ESC (browserex::browserex-uninstall) とタイプし、
;;         browserex.l 関連の情報を xyzzy から削除します。
;;
;;      2. browserex.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 10:03:59 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Sat, 16 Apr 2005 22:46:38 +0900
;;        ・browserex-uninstall を interactive でない関数に変更。
;;        ・xyzzy 0.2.2.234 対応
;;          - 半角カナを全角カナに変更。
;;        ・メニュー指定修正。
;;          - *browserex-menu-position* をヒストリ変数でなくした。
;;            ⇒ (bx::browserex-uninstall) を評価後再起動することで
;;               反映されます。
;;          - *browserex-menu-position* の初期値変更。
;;          - *browserex-menu-name* の初期値変更。
;;          - プロパティーシートでの menu 追加位置指定廃止。
;;
;;      Mon, 23 Feb 2004 23:10:39 +0900
;;        ・navigate に対して ~/ で開始する文字列を渡した場合
;;          展開するように。
;;        ・navigate での interactive 入力で補完可能に。
;;        ・*browserex-history* の追加。
;;        ・*browserex-scheme-list* 追加。
;;        ・*browser-start-page* のデフォルト値を nil に。
;;
;;      Tue, 20 Jan 2004 23:43:55 +0900
;;        ・稲原さんに指摘いただいたコメント内 typo 修正。
;;        ・win-window.l がない場合でも一部機能が使用できないだけで
;;          動作するように修正。
;;        ・uninstall-browserex を修正とともに browserex-uninstall に
;;          名称変更。
;;
;;      Wed, 28 May 2003 10:44:17 +0900
;;        ・メニュー関連修正。
;;
;;      Thu, 22 May 2003 13:15:46 +0900
;;        ・メニュー関連コード修正。
;;
;;      Fri, 16 May 2003 19:52:28 +0900
;;        ・insert-browserex-focus-menu-items 拡張。
;;
;;      Mon, 05 May 2003 13:47:04 +0900
;;        ・メニュー関連コード修正。
;;        ・コード整理。
;;
;;      Mon, 05 May 2003 01:00:52 +0900
;;        ・「初期化されていないメニューです」とエラーがでる場合が
;;          あったのを修正。
;;
;;      Fri, 02 May 2003 23:25:56 +0900
;;        ・メニュー追加。設定はプロパティーシートから。
;;        ・uninstall-browserex 修正。
;;        ・NetInstaller 対応。
;;        ・その他。
;;
;;      Sun, 20 Apr 2003 20:59:38 +0900
;;        ・メニューの「ツール＞共通設定」にプロパティシート追加。
;;          伴い、win-window.l が必要に。
;;        ・山本泰三さんの Gecko 版 browser dll に仮対応。
;;          伴い change-browser 追加。
;;
;;      Mon, 17 Feb 2003 00:56:16 +0900
;;        ・browserex-mouse-menu-popup 修正。
;;          複数行選択時に右クリックでメニューが表示されない場合が
;;          多々ありました。
;;
;;      Sat, 19 Oct 2002 12:37:00 +0900
;;        ・ローカルファイル参照時の変換
;;        ・とりあえず決めうちな browser.dll 切替。change-browser
;;          dll のファイル名は browser.dll と browser_gecko.dll に。
;;
;;      Fri, 26 Jul 2002 05:28:32 +0900
;;        ・他の lisp ファイルで winapi パッケージに SetFocus が定義
;;          されており、かつ export されていない場合に byte-compile
;;          できなくなっていた点を修正。
;;        ・Win32API について中途半端に winapi パッケージで定義していた
;;          のを、browserex パッケージで定義するように変更。
;;
;;      Tue, 02 Jul 2002 23:06:00 +0900
;;        ・browserex-set-focus-editor, browser でフォーカスセット。
;;        ・browserex-scroll-up, down, left, right でスクロール。
;;
;;      Tue, 19 Feb 2002 20:52:25 +0900
;;        ・いまいたけをさん改造版 browser.dll に対応。
;;          その他。
;;
;;      Thu, 17 Jan 2002 22:43:33 +0900
;;        ・$XYZZY/etc に browser.dll を置いておき siteinit.l に
;;          browserex.l の記述をしていると browser.dll をロード
;;          できないのを修正。
;;        ・(bx:browser-dll-pathname) でロードしている dll のパスを返す。
;;        ・(bx:browser-dll-define-function dll) で使用する dll を変更。
;;        ・dll をロードしていない場合でも (browser-open-p) が正常動作
;;          するように修正。
;;
;;      Sun, 13 Jan 2002 11:10:14 +0900
;;        ・マウスで指定した URL、ローカルファイルパスの内容の表示。
;;
;;      Tue, 08 Jan 2002 20:26:10 +0900
;;        ・navigate-current-buffer-directory の動作を少し変更。
;;          ファイル名がない場合、"*scratch*" バッファなら
;;          (user-homedir-pathname) を開き、それ以外なら
;;          (default-directory) を開きます。
;;        ・フォルダを開く場合、どうも詳細表示へのスタイル変更は
;;          他にも増して危険なようなので、LVS_REPORT は export しない
;;          ようにしました。
;;          詳細表示のカラム幅が全部 0 になってしまうようなんですが、
;;          一度列幅を直せばそれなりに動いてくれてるような気がします。
;;        ・*browser-syslistview-style-wait*
;;
;;      Mon, 07 Jan 2002 14:13:54 +0900
;;        ・navigate の戻り値を修正。
;;        ・set-browser-syslistview-style の戻り値を修正。
;;        ・rotate-browser を少し修正。
;;        ・navigate-current-buffer-directory を修正。
;;        ・その他。
;;
;;      Sun, 06 Jan 2002 14:57:30 +0900
;;        ・browser.dll の検索パスを増やした。
;;          xyzzy/, xyzzy/etc/, xyzzy/site-lisp/ も調べるように
;;          なりました。
;;
;;      Sun, 06 Jan 2002 01:47:44 +0900
;;        ・かなり無理やりな SysListView32 のスタイル変更。
;;          bx:*browser-syslistview-style* に
;;          bx:LVS_SMALLICON, bx:LVS_LIST, bx:LVS_REPORT, bx:LVS_ICON
;;          のどれかを代入しておいてください。
;;         「大きいアイコン」が標準のようなので bx:LVS_ICON は意味が
;;          ありません。
;;
;;      Mon, 31 Dec 2001 05:05:39 +0900
;;        ・browser-wrap.l を単体で browser.dll の
;;          使用方法サンプルとなるようにし browserex.l に名称変更。
;;

;; Memo:
;;      ・サイズ指定の場合は、close-browser 時にサイズを記録しない
;;      ・サイズ指定通りウィンドウ表示を行えない場合は、対応する幅 or 高さを
;;        記録し、終了時に幅 or 高さを復元する。
;;
;;      ・「サイズ指定通りウィンドウ表示を行えない」とは。
;;            [xyzzyのサイズ]
;;              ⇒常に サイズ指定通りウィンドウ表示を行えているとみなす。
;;            [xyzzyの位置][エディタ部]
;;              ⇒[browser.dll 表示前サイズ + 指定サイズ] と
;;                [browser.dll 表示後サイズ] が一致しない場合

;; Todo:
;;      ・ツールバーの各ボタンの関数を指定できるようにする。

;; Bug:
;;
;;      ・いったんメニューの末尾に browserex のメニューを追加した後に
;;        他の場所にメニューを移動させようとすると、
;;        末尾に browserex メニューが残る。
;;

;; Licence:
;;
;;    browserex は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
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

(provide "browserex")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))

(if (find-load-path "win-window")
  (require "win-window"))

(eval-when (:compile-toplevel)
  (unexport
   '(win-user::wwindow-zoomed-p
     win-user::xyzzy-zoomed-p
     win-user::get-wwindow-rectangle
     win-user::get-wclient-rectangle
     win-user::set-wwindow-rectangle
     win-user::get-wwindow-height
     win-user::get-wwindow-width
     win-user::set-wwindow-height
     win-user::set-wwindow-width
     win-user::enlarge-xyzzy-by-wwindow-size
     win-user::shrink-xyzzy-by-wwindow-size)
   "win-user"))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "browserex")
    (defpackage "browserex"
      (:nicknames "bx")
      (:use "lisp" "editor"))))

(in-package "browserex")

(export '(*browser-dll-load-path*
          *browser-size*
          *browser-width*
          *browser-height*
          *browser-start-page*
          *browser-temp-file*
          *browser-use-refresh*
          *browser-syslistview-style*
          *browser-syslistview-style-wait*
          ;;
          *browser-string-length*
          ;;
          *browserex-history*
          *browserex-scheme-list*
          *browserex-html-pathname-type*
          *browserex-popup-pathname-type*
          *browserex-message-valid-path*
          *browserex-full-path-regexp*))
(export '(browser-dll-define-function
          browser-dll-pathname
          browser-open-p
          navigate
          refresh-browser
          close-browser
          change-browser
          ;;
          go-back-browser
          go-forward-browser
          go-home-browser
          show-location-browser
          ;;
          rotate-browser
          navigate-current-buffer
          navigate-current-buffer-if-open
          navigate-current-buffer-directory
          get-browser-syslistview-handle
          set-browser-syslistview-style
          browserex-set-focus-editor
          browserex-set-focus-browser
          browserex-scroll-up
          browserex-scroll-down
          browserex-scroll-left
          browserex-scroll-right
          browserex-mouse-menu-popup
          browserex-apps-popup
          browser-tool-bar))

;; browser.dll の表示位置
;; xpi.h
(c:*define XPIS_LEFT   0)
(c:*define XPIS_TOP    1)
(c:*define XPIS_RIGHT  2)
(c:*define XPIS_BOTTOM 3)

;; SysListView32 の表示スタイル設定
;; winuser.h
(c:define GWL_WNDPROC     -4)
(c:define GWL_HINSTANCE   -6)
(c:define GWL_HWNDPARENT  -8)
(c:define GWL_STYLE      -16)
(c:define GWL_EXSTYLE    -20)
(c:define GWL_USERDATA   -21)
(c:define GWL_ID         -12)

(c:define-dll-entry winapi:LONG GetWindowLong (winapi:HWND c:int)
  "user32" "GetWindowLongA")
(c:define-dll-entry winapi:LONG SetWindowLong (winapi:HWND c:int winapi:LONG)
  "user32" "SetWindowLongA")

;; commctrl.h
(c:define WC_LISTVIEWA "SysListView32")
(c:define WC_LISTVIEW  WC_LISTVIEWA)

(c:*define LVS_ICON           #x0000)
;(c:*define LVS_REPORT         #x0001)
(c:define LVS_REPORT          #x0001)
(c:*define LVS_SMALLICON      #x0002)
(c:*define LVS_LIST           #x0003)
(c:define LVS_TYPEMASK        #x0003)
(c:define LVS_SINGLESEL       #x0004)
(c:define LVS_SHOWSELALWAYS   #x0008)
(c:define LVS_SORTASCENDING   #x0010)
(c:define LVS_SORTDESCENDING  #x0020)
(c:define LVS_SHAREIMAGELISTS #x0040)
(c:define LVS_NOLABELWRAP     #x0080)
(c:define LVS_AUTOARRANGE     #x0100)
(c:define LVS_EDITLABELS      #x0200)
(c:define LVS_OWNERDATA       #x1000)
(c:define LVS_NOSCROLL        #x2000)

(c:define LVS_TYPESTYLEMASK   #xfc00)

(c:define LVS_ALIGNTOP        #x0000)
(c:define LVS_ALIGNLEFT       #x0800)
(c:define LVS_ALIGNMASK       #x0c00)

(c:define LVS_OWNERDRAWFIXED  #x0400)
(c:define LVS_NOCOLUMNHEADER  #x4000)
(c:define LVS_NOSORTHEADER    #x8000)

(c:define-dll-entry winapi:HWND
  FindWindowEx (winapi:HWND winapi:HWND winapi:LPCSTR winapi:LPCSTR)
  "user32" "FindWindowExA")
(c:define-dll-entry winapi:LRESULT
  SendMessage (winapi:HWND winapi:UINT winapi:WPARAM winapi:LPARAM)
  "user32" "SendMessageA")

(c:define WM_KEYDOWN          #x0100)
(c:define WM_KEYUP            #x0101)

(c:define WM_HSCROLL          #x0114)
(c:define WM_VSCROLL          #x0115)

(c:define VK_PRIOR          #x21)
(c:define VK_NEXT           #x22)
(c:define VK_END            #x23)
(c:define VK_HOME           #x24)
(c:define VK_LEFT           #x25)
(c:define VK_UP             #x26)
(c:define VK_RIGHT          #x27)
(c:define VK_DOWN           #x28)

(c:define SB_LINEUP           0)
(c:define SB_LINELEFT         0)
(c:define SB_LINEDOWN         1)
(c:define SB_LINERIGHT        1)
(c:define SB_PAGEUP           2)
(c:define SB_PAGELEFT         2)
(c:define SB_PAGEDOWN         3)
(c:define SB_PAGERIGHT        3)
(c:define SB_THUMBPOSITION    4)
(c:define SB_THUMBTRACK       5)
(c:define SB_TOP              6)
(c:define SB_LEFT             6)
(c:define SB_BOTTOM           7)
(c:define SB_RIGHT            7)
(c:define SB_ENDSCROLL        8)

(c:define-dll-entry winapi:HWND SetFocus (winapi:HWND) "user32")


;;; ------------------------------------------------------------------------
;;; 定数
(defconstant *browser-size-default* 200)

;;; ダイアログ設定変数
;; DLL
(define-history-variable *browser-dll-IE* ""
  "IE 版 browser dll のパス")
(define-history-variable *browser-dll-Gecko* ""
  "Gecko 版 browser dll のパス")
(define-history-variable *last-valid-browser-dll* ""
  "最後に使用した browser dll のパス")

;; Browser.dll 表示制御
(define-history-variable *browser-width* *browser-size-default*
  "browser.dll のデフォルト表示幅。*browser-size* よりも優先。")
(define-history-variable *browser-height* *browser-size-default*
  "browser.dll のデフォルト表示高さ。*browser-size* よりも優先。")
(define-history-variable *browser-position* XPIS_LEFT
  "browser.dll のデフォルト表示位置")
(define-history-variable *browser-add-window* nil)
(define-history-variable *browser-save-size* nil)

;; メニュー
(define-history-variable *browserex-menu-name* "&BX"
  "browserex メニュー文字列")
(defvar *browserex-menu-position* 'ed::help)
(define-history-variable *browserex-set-menu* t)
(define-history-variable *browserex-set-focus-menu* nil)

;;; 公開用変数
(defvar *browser-start-page* nil
  "navigate のデフォルト URL")
(defvar *browser-temp-file* (map-backslash-to-slash
                             (merge-pathnames "browser-temp.html"
                                              (or (si:getenv "TEMP")
                                                  (si:getenv "TMP")
                                                  (user-homedir-pathname)
                                                  (si:system-root))))
  "navigate-current-buffer で用いるテンポラリファイル")
(defvar *browser-use-refresh* nil
  "navigate-current-buffer で refresh-browser を使うかどうか。
t にすると refresh を用いる(その際にフォーカスが browser 側に移る)。")
(defvar *browser-syslistview-style* nil
  "フォルダ表示の SysListView32 のスタイル
LVS_ICON LVS_SMALLICON LVS_LIST nil のいずれか")
(defvar *browser-syslistview-style-wait* 0.01
  "フォルダ表示で SysListView32 のスタイルを変更させる際の待ち時間")

;; mouse menu 用
(defvar *browserex-html-pathname-type* '("shtml" "html" "htm")
  "HTML ファイルの拡張子のリスト")
(defvar *browserex-popup-pathname-type*
  '("shtml" "html" "htm" "mhtml" "mht" "xml" "txt"
    "png" "jpeg" "jpg" "jpe" "jfif" "gif" "bmp")
  "ポップアップメニューから開くファイルの拡張子のリスト")
(defvar *browserex-message-valid-path* t
  "ポップアップメニューから相対パスで開くファイルのフルパスを表示")

;;; 内部用変数
(defvar *browser-size* *browser-size-default*
  "browser.dll のデフォルト表示幅、または高さ。")
(define-history-variable *browserex-history* nil
  "navigate でのヒストリ")
(defvar *browserex-scheme-list* '("file://" "http://" "ftp://" "https://")
  "ヒストリに必ず含める scheme リスト")
(defvar *browserex-menu* nil
  "browserex メニュー")
(defvar *browserex-property-page-no* nil)
(defvar *browserex-full-path-regexp* (compile-regexp "^[a-z]:[/\\]" t)
  "フルパスと判断する正規表現")
(defvar *browser-specific-size-p* nil
  "サイズ指定で browser.dll ウィンドウを作成したか")
(defvar *browser-xyzzy-original-height* nil
  "browser.dll を表示する前の xyzzy の高さ")
(defvar *browser-xyzzy-original-width* nil
  "browser.dll を表示する前の xyzzy の幅")
(defvar *browser-navigate-url* ""
  "現在表示しているパス")
(defvar *browser-dll-load-path*
  (list
   (user-homedir-pathname)
   (concat (user-homedir-pathname) "etc/")
   (concat (user-homedir-pathname) "site-lisp/")
   (si:system-root)
   (etc-path)
   (concat (si:system-root) "etc/")
   (concat (si:system-root) "site-lisp/")
   "")
  "browser.dll の検索パス")

;; いまい たけを さんバージョン
(defvar *browser-string-length* 255
  "browser.dll が開いている URI を取得する際の最大文字列長")

;;; ------------------------------------------------------------------------
(defun browser-dll-define-function (dll)
  "browser.dll を直接用いる関数の定義"
  (let* ((dll-exist-p (and (stringp dll)
                           (string/= dll "")
                           (file-exist-p dll)
                           (not (file-directory-p dll))))
         (fullpath (if dll-exist-p (namestring dll) "")))
    (if (fboundp 'browser-gethwnd)
        (close-browser))
    (when dll-exist-p
      (c:define-dll-entry winapi:HWND browser-gethwnd () fullpath "_GetHwnd@0")
      (c:define-dll-entry c:int browser-close () fullpath "_close@0")
      (c:define-dll-entry c:int browser-create (winapi:HWND c:void*) fullpath "_create@8")
      (c:define-dll-entry c:int browser-createex (winapi:HWND c:void* c:int winapi:DWORD) fullpath "_createEx@16")
      (c:define-dll-entry c:int browser-navigate (c:char*) fullpath "_navigate@4")
      (c:define-dll-entry c:int browser-refresh () fullpath "_refresh@0")
      ;; いまい たけを さんバージョン
      (c:define-dll-entry c:int browser-go-back () fullpath "_goBack@0")
      (c:define-dll-entry c:int browser-go-forward () fullpath "_goForward@0")
      (c:define-dll-entry c:int browser-go-home () fullpath "_goHome@0")
      (c:define-dll-entry c:int browser-location (c:int (c:char *)) fullpath "_locationURL@8")
      ;; DLL を記録
      (setq *last-valid-browser-dll* fullpath))
    (defun browser-dll-pathname ()
      "使用している dll のパスを返す"
      fullpath)
    (gc)
    dll-exist-p))

(defun browser-open-p ()
  "browser.dll を開いているか"
  (not (handler-case (zerop (browser-gethwnd)) (simple-error (c) t))))

;; history を用いた補完入力
(dolist (scheme (reverse *browserex-scheme-list*))
  (add-history scheme '*browserex-history*))

(setf (get 'browserex 'ed::minibuffer-history-variable)
      '*browserex-history*)
(setf (get '*browserex-history*
           'ed::minibuffer-reject-newline) t)

(defun browserex-minibuffer-complete (&optional word)
  "補完入力"
  (interactive "*p")
  (let (url)
    (setq url (buffer-substring (point-min) (point-max)))
    (cond
     ;; 入力なしの場合はカレントディレクトリ
     ((string-match "^ *$" url)
      (delete-region (point-min) (point-max))
      (insert "file://")
      (do-completion (point) (point-max)
                     :file-name
                     nil
                     word
                     *last-command-char*
                     *minibuffer-popup-completion-list*))
     ;; scheme 入力なしで (バック)スラッシュが出現した場合はディレクトリ
     ((string-match "^[^:]*[/\\]" url)
      (delete-region (point-min) (point-max))
      (insert (append-trail-slash (concat "file://" (namestring url)))))
     ;; file:// の場合
     ((string-matchp "^\\(file://\\)\\(.*\\)" url)
      (do-completion (match-end 1) (point-max)
                     :file-name
                     nil
                     word
                     *last-command-char*
                     *minibuffer-popup-completion-list*))
     ;; 末尾に "../" がある場合
     ((string-match "/[^/]+/\\.\\./$" url)
      (save-excursion
        (goto-bol)
        (scan-buffer "[^/]+/\\.\\./$" :regexp t)
        (delete-region (point) (point-max))))
     ;; その他の場合 (history から補完)
     (t
      (let ((url-length (length url))
            completion-list)
        (setq completion-list
              (remove-if #'(lambda (x)
                             (or (< (length x) url-length)
                                 (string-not-equal x url :start1 0 :end1 url-length)))
                         *browserex-history*))
        (setq completion-list (mapcar #'(lambda (x)
                                          (let ((x-length (length x)))
                                            (substring x url-length)))
                                      completion-list))
        (setq completion-list
              (delete-duplicates
               (remove-if #'(lambda (x) (zerop (length x))) completion-list)
               :test #'equalp))

        (do-completion (point-max) (point-max)
                       :list
                       completion-list
                       word
                       *last-command-char*
                       *minibuffer-popup-completion-list*)
        ))))
  (setq *this-command* 'browserex-minibuffer-complete))

(defun browserex-minibuffer-complete-word ()
  "単語単位補完入力"
  (interactive "*")
  (browserex-minibuffer-complete t))

(defun navigate (url &key position size)
  "指定 URL を browser.dll で表示"
  (interactive
      (let ((minibuffer-local-map (copy-keymap minibuffer-local-map))
            url)
        (define-key minibuffer-local-map #\TAB 'browserex-minibuffer-complete)
        (define-key minibuffer-local-map #\SPC 'browserex-minibuffer-complete-word)
        (setq url
              (read-string "URL: "
                           :default (or *browser-start-page*
                                        (append-trail-slash
                                         (concat "file://" (default-directory))))
                           :history 'browserex))
        (list url)))
  (unless (browser-open-p)
    ;; 明示的なサイズ指定かを記録
    (setq *browser-specific-size-p* (if size t nil))
    ;; browser 表示位置(上下左右)の補正
    (cond
     ((find position (list XPIS_LEFT XPIS_TOP XPIS_RIGHT XPIS_BOTTOM) :test #'eql)
      (setq *browser-position* position))
     ((find *browser-position* (list XPIS_LEFT XPIS_TOP XPIS_RIGHT XPIS_BOTTOM) :test #'eql)
      (setq position *browser-position*))
     (t
      (setq position XPIS_LEFT)
      (setq *browser-position* XPIS_LEFT)))
    ;; browser 表示サイズの補正
    (unless (integerp size)
      (cond
       ((find position (list XPIS_LEFT XPIS_RIGHT) :test #'eql)
        (setq size (or *browser-width* *browser-size*)))
       ((find position (list XPIS_TOP XPIS_BOTTOM) :test #'eql)
        (setq size (or *browser-height* *browser-size*)))
       (t
        (setq size *browser-size*))))
    (unless (and (integerp size) (plusp size))
      (setq size 100))
    ;; 元の xyzzy の高さ、幅を記録
    (when (browserex-win-window-p)
      (cond ((find position (list XPIS_LEFT XPIS_RIGHT) :test #'eql)
             (setq *browser-xyzzy-original-width*
                   (win-user::get-wwindow-width (ed:get-window-handle))))
            ((find position (list XPIS_TOP XPIS_BOTTOM) :test #'eql)
             (setq *browser-xyzzy-original-height*
                   (win-user::get-wwindow-height (ed:get-window-handle))))))
    ;; browser 表示
    (browser-createex (get-window-handle) (si:plugin-arg) size position)
    (when (browserex-win-window-p)
      ;; xyzzy の window サイズ、位置の補正
      (when *browser-add-window*
        (case *browser-add-window*
          (:fix      (win-user::enlarge-xyzzy-by-wwindow-size
                      (browser-gethwnd) *browser-position* nil))
          (:enlarge  (win-user::enlarge-xyzzy-by-wwindow-size
                      (browser-gethwnd) *browser-position* t))))
      ;; 正常に表示できた場合、xyzzy の元のサイズの記録を消す
      (when (or (null *browser-add-window*)
                (and (find position (list XPIS_LEFT XPIS_RIGHT) :test #'eql)
                     (= (win-user::get-wwindow-width (ed:get-window-handle))
                        (+ size *browser-xyzzy-original-width*)))
                (and (find position (list XPIS_TOP XPIS_BOTTOM) :test #'eql)
                     (= (win-user::get-wwindow-height (ed:get-window-handle))
                        (+ size *browser-xyzzy-original-height*))))
        (setq *browser-xyzzy-original-height* nil)
        (setq *browser-xyzzy-original-width* nil)))
    (add-hook '*kill-xyzzy-hook* 'close-browser))
  ;; url 補正
  (when (string-match "^~[/\\]" url)
    (setq url (namestring url)))
  (when (string-matchp "^[a-z]:" url)
    (setq url (concat "file:///" url)))
  (setq *browser-navigate-url* url)
  ;; interactive 実行の場合、read-string 自体での history 登録と
  ;; 2 重になるが、実害 0。
  (add-history *browser-navigate-url* '*browserex-history*)
  ;; navigate
  (browser-navigate (si:make-string-chunk url))
  ;; style 変更
  (when (and (not (zerop (get-browser-syslistview-handle)))
             *browser-syslistview-style*)
    ;; 少し wait しないとスタイルの変更がうまくいかない 
    (sleep-for *browser-syslistview-style-wait*)
    (set-browser-syslistview-style))
  (start-timer 0.1 'browserex-set-focus-editor t)
  url)

(defun refresh-browser ()
  "browser.dll の表示 URL を再描画"
  (interactive)
  (if (browser-open-p)
      (browser-refresh)))

(defun close-browser ()
  "browser.dll を閉じる"
  (interactive)
  (when (browser-open-p)
    ;; browser サイズの保存
    (when (and (browserex-win-window-p)
               *browser-save-size*
               (not *browser-specific-size-p*)
               (or *browser-xyzzy-original-height*
                   *browser-xyzzy-original-width*))
      (cond
       ((find *browser-position* (list XPIS_LEFT XPIS_RIGHT))
        (setq *browser-width* (win-user::get-wwindow-width (browser-gethwnd))))
       ((find *browser-position* (list XPIS_TOP XPIS_BOTTOM))
        (setq *browser-height* (win-user::get-wwindow-height (browser-gethwnd))))))
    ;; xyzzy の window サイズ、位置の補正
    (when (browserex-win-window-p)
      (when *browser-add-window*
        (case *browser-add-window*
          (:fix      (win-user::shrink-xyzzy-by-wwindow-size
                      (browser-gethwnd) *browser-position* nil))
          (:enlarge  (win-user::shrink-xyzzy-by-wwindow-size
                      (browser-gethwnd) *browser-position* t)))))
    ;; 必要なら元の xyzzy の高さ or 幅に戻す
    (when (browserex-win-window-p)
      (if *browser-xyzzy-original-height*
          (win-user::set-wwindow-height (ed:get-window-handle)
                                       *browser-xyzzy-original-height*))
      (if *browser-xyzzy-original-width*
          (win-user::set-wwindow-width (ed:get-window-handle)
                                      *browser-xyzzy-original-width*)))
    (setq *browser-xyzzy-original-height* nil)
    (setq *browser-xyzzy-original-width* nil)
    (browser-close)
    (delete-hook '*kill-xyzzy-hook* 'close-browser)
    nil))

;; いまい たけを さんバージョン
(defun go-back-browser ()
  "browser.dll で戻る"
  (interactive)
  (when (browser-open-p)
    (browser-go-back)
    (start-timer 0.1 'browserex-set-focus-editor t)
;    (setq *browser-navigate-url* (get-location-from-browser))
    ))

(defun go-forward-browser ()
  "browser.dll で進む"
  (interactive)
  (when (browser-open-p)
    (browser-go-forward)
    (start-timer 0.1 'browserex-set-focus-editor t)
;    (setq *browser-navigate-url* (get-location-from-browser))
    ))

(defun go-home-browser ()
  "browser.dll で IE のホームに移動"
  (interactive)
  (unless (browser-open-p)
    (navigate ""))
  (browser-go-home)
  (start-timer 0.1 'browserex-set-focus-editor t)
;  (setq *browser-navigate-url* (get-location-from-browser))
  )

(defun show-location-browser (&optional msgbox)
  (interactive "p")
  (if (browser-open-p)
      (if msgbox
          (msgbox (get-location-from-browser))
        (popup-string (get-location-from-browser) (point)))))

(defun get-location-from-browser ()
  (let ((len (+ *browser-string-length* 1))
        chunk)
    (setq chunk (si:make-chunk nil len))
    (browser-location len chunk)
    (si:unpack-string chunk 0)))
;;

(defun rotate-browser ()
  "browser.dll の表示位置を左上右下の順に変更"
  (interactive)
  (when (browser-open-p)
    (close-browser)
    (cond
     ((eql *browser-position* XPIS_LEFT)
      (setq *browser-position* XPIS_TOP))
     ((eql *browser-position* XPIS_TOP)
      (setq *browser-position* XPIS_RIGHT))
     ((eql *browser-position* XPIS_RIGHT)
      (setq *browser-position* XPIS_BOTTOM))
     ((eql *browser-position* XPIS_BOTTOM)
      (setq *browser-position* XPIS_LEFT))
     (t
      (setq *browser-position* XPIS_LEFT))))
  (if (string/= *browser-navigate-url* "")
      (navigate *browser-navigate-url*)
    (navigate-current-buffer)))

(defun navigate-current-buffer (&key position size temp-file)
  "カレントバッファを browser.dll で表示"
  (interactive)
  (let ((file (get-buffer-file-name)))
    (if file
        (if (and *browser-use-refresh*
                 (browser-open-p)
                 (string/= file *browser-temp-file*)
                 (string= file *browser-navigate-url*))
            (refresh-browser)
          (navigate file :position position :size size))
      (progn
        (unless temp-file
          (setq temp-file *browser-temp-file*))
        (with-open-file (out temp-file
                             :direction :output
                             :if-does-not-exist :create)
          (convert-encoding-from-internal
           (buffer-fileio-encoding)
           (buffer-substring (point-min) (point-max)) out))
        (navigate temp-file :position position :size size)))))

(defun navigate-current-buffer-if-open (&key temp-file)
  "browser.dll を開いていたらカレントバッファを browser.dll で表示"
  (interactive)
  (if (browser-open-p)
      (navigate-current-buffer :temp-file temp-file)))

(defun navigate-current-buffer-directory (&key position size)
  "カレントバッファのディレクトリを browser.dll で表示"
  (interactive)
  (let* ((file (get-buffer-file-name))
         (dir (or (if file (directory-namestring file))
                  (if (string= (buffer-name (selected-buffer)) "*scratch*")
                      (user-homedir-pathname))
                  (default-directory))))
    (if dir
        (navigate dir :position position :size size))))

;;; IE 版 browser.dll でのフォルダ表示の変更
(defun get-browser-syslistview-handle ()
  "browser.dll による SysListView32 の window handle を返す"
  (let (parent-hwnd list-hwnd)
    (setq parent-hwnd
          (FindWindowEx
           (browser-gethwnd) 0 (si:make-string-chunk "Shell Embedding") 0))
    (setq parent-hwnd
          (FindWindowEx
           parent-hwnd 0 (si:make-string-chunk "SHELLDLL_DefView") 0))
    (setq list-hwnd
          (FindWindowEx
           parent-hwnd 0 (si:make-string-chunk "SysListView32") 0))
    (when (zerop list-hwnd)
      (setq parent-hwnd
            (FindWindowEx
             parent-hwnd 0 (si:make-string-chunk "Internet Explorer_Server") 0))
      (setq parent-hwnd
            (FindWindowEx
             parent-hwnd 0 (si:make-string-chunk "ATL Shell Embedding") 0))
      (setq list-hwnd
            (FindWindowEx
             parent-hwnd 0 (si:make-string-chunk "SysListView32") 0)))
    list-hwnd))

(defun set-browser-syslistview-style (&optional (style *browser-syslistview-style*))
  "フォルダ表示の SysListView32 のスタイルを設定
スタイルの値の変更が不完全 (WS_VSCROLL, WS_HSCROLL 値の補正が足りないのかも)"
  (when (or (eql style LVS_ICON)
            (eql style LVS_REPORT)
            (eql style LVS_SMALLICON)
            (eql style LVS_LIST))
    (let ((browser-syslistview-handle (get-browser-syslistview-handle))
          org mask new)
      (setq org (GetWindowLong browser-syslistview-handle GWL_STYLE))
      (setq mask (logand org (lognot LVS_TYPEMASK)))
      (setq new (logior mask style))
      (SetWindowLong browser-syslistview-handle GWL_STYLE new))
    style))

;;;
(defun get-browser-ieserver-handle ()
  (let (parent-hwnd ieserver-hwnd)
    (setq parent-hwnd
          (FindWindowEx
           (browser-gethwnd) 0 (si:make-string-chunk "Shell Embedding") 0))
    (setq parent-hwnd
          (FindWindowEx
           parent-hwnd 0 (si:make-string-chunk "Shell DocObject View") 0))
    (setq ieserver-hwnd
          (FindWindowEx
           parent-hwnd 0 (si:make-string-chunk "Internet Explorer_Server") 0))
    ieserver-hwnd))

;; editor, browser のフォーカスセット
(defun browserex-set-focus-editor ()
  (interactive)
  (SetFocus (get-window-handle)))
(defun browserex-set-focus-browser ()
  (interactive)
  (if (and (browser-open-p)
           (plusp (get-browser-ieserver-handle)))
      (SetFocus (get-browser-ieserver-handle))))

;; スクロール
(defun browserex-scroll-up (&key (unit :line) quick)
  (interactive)
  (let ((hwnd (get-browser-ieserver-handle)))
    (when (or (null hwnd) (zerop hwnd))
      (return-from browserex-scroll-up))
    (case unit
      (:all
       (SendMessage hwnd WM_VSCROLL SB_TOP 0))
      (:page
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_PAGEUP 0)
         (SendMessage hwnd WM_KEYDOWN VK_PRIOR 0)))
      (:line
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_LINEUP 0)
         (SendMessage hwnd WM_KEYDOWN VK_UP 0)))
      (t
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_LINEUP 0)
         (SendMessage hwnd WM_KEYDOWN VK_UP 0))))))
(defun browserex-scroll-down (&key (unit :line) quick)
  (interactive)
  (let ((hwnd (get-browser-ieserver-handle)))
    (when (or (null hwnd) (zerop hwnd))
      (return-from browserex-scroll-down))
    (case unit
      (:all
       (SendMessage hwnd WM_VSCROLL SB_BOTTOM 0))
      (:page
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_PAGEDOWN 0)
         (SendMessage hwnd WM_KEYDOWN VK_NEXT 0)))
      (:line
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_LINEDOWN 0)
         (SendMessage hwnd WM_KEYDOWN VK_DOWN 0)))
      (t
       (if quick
           (SendMessage hwnd WM_VSCROLL SB_LINEDOWN 0)
         (SendMessage hwnd WM_KEYDOWN VK_DOWN 0))))))
(defun browserex-scroll-left (&key (unit :line) quick)
  (interactive)
  (let ((hwnd (get-browser-ieserver-handle)))
    (when (or (null hwnd) (zerop hwnd))
      (return-from browserex-scroll-left))
    (case unit
      (:all
       (SendMessage hwnd WM_HSCROLL SB_LEFT 0))
      (:line
       (if quick
           (SendMessage hwnd WM_HSCROLL SB_LINELEFT 0)
         (SendMessage hwnd WM_KEYDOWN VK_LEFT 0)))
      (t
       (if quick
           (SendMessage hwnd WM_HSCROLL SB_LINELEFT 0)
         (SendMessage hwnd WM_KEYDOWN VK_LEFT 0))))))
(defun browserex-scroll-right (&key (unit :line) quick)
  (interactive)
  (let ((hwnd (get-browser-ieserver-handle)))
    (when (or (null hwnd) (zerop hwnd))
      (return-from browserex-scroll-right))
    (case unit
      (:all
       (SendMessage hwnd WM_HSCROLL SB_RIGHT 0))
      (:line
       (if quick
           (SendMessage hwnd WM_HSCROLL SB_LINERIGHT 0)
         (SendMessage hwnd WM_KEYDOWN VK_RIGHT 0)))
      (t
       (if quick
           (SendMessage hwnd WM_HSCROLL SB_LINERIGHT 0)
         (SendMessage hwnd WM_KEYDOWN VK_RIGHT 0))))))

(defun change-browser ()
  "IE 版 と Gecko 版 の browser dll を切り替える"
  (interactive)
  (unless (and (stringp *browser-dll-IE*)
               (string/= *browser-dll-IE* "")
               (file-exist-p *browser-dll-IE*)
               (stringp *browser-dll-Gecko*)
               (string/= *browser-dll-Gecko* "")
               (file-exist-p *browser-dll-Gecko*))
    (message "IE と Gecko の browser dll が正しく設定されていません。")
    (return-from change-browser nil))
  (let ((open-p (browser-open-p)))
    (when (and (stringp *last-valid-browser-dll*)
               (string/= *last-valid-browser-dll* ""))
      (cond
       ((path-equal *last-valid-browser-dll* *browser-dll-IE*)
        (browser-dll-define-function *browser-dll-Gecko*))
       ((path-equal *last-valid-browser-dll* *browser-dll-Gecko*)
        (browser-dll-define-function *browser-dll-IE*)))
      (when open-p
        (if (string/= *browser-navigate-url* "")
            (navigate *browser-navigate-url*)
          (navigate-current-buffer))))))

(defun browserex-win-window-p ()
  "win-window ライブラリが使用できるか"
  (member "win-window" *modules* :test #'string=))

;;; 共通設定へ追加
(let (position-alist)
  (setq position-alist
        `(("上" . ,XPIS_TOP) ("下" . ,XPIS_BOTTOM)
          ("左" . ,XPIS_LEFT) ("右" . ,XPIS_RIGHT)))
  (add-option-prop-page
   'browserex
   `(dialog 0 0 200 190
     (:caption "Browserex")
     (:control
      ;; win-window 用 dummy-trigger
      (:button dummy-trigger ""                         #x50000009 2000 2000 0 0)

      ;;
      (:static nil         "表示位置(&P):"              #x50020000  6 10 45  8)
      (:combobox pos       nil                          #x50210843 51  7 40 96)
      (:static nil         "表示幅(&W):"                #x50020000  6 24 45  8)
      (:edit width         nil                          #x50812086 51 21 40 14)
      (:spin widthspin     nil                          #x500000b6 91 21  9 14)
      (:static nil         "表示高さ(&H):"              #x50020000  6 38 45  8)
      (:edit height        nil                          #x50812086 51 35 40 14)
      (:spin heightspin    nil                          #x500000b6 91 35  9 14)

      ;;
      (:button view-basis "表示基準"                       #x50020007  98   4  78 48)
      (:button view-basis-xyzzy-size "xyzzyのサイズ(&X)"   #x50000009 102  12  72 12)
      (:button view-basis-xyzzy-position "xyzzyの位置(&V)" #x50000009 102  24  72 12)
      (:button view-basis-editor "エディタ部(&E)"          #x50000009 102  36  72 12)

      (:button save-size  "終了時サイズを保存(&S)"         #x50010003   6  54  80 14)

      (:static win-window-msg "(表示基準/終了時サイズ\n 保存には win-window.l\n が必要です)"
       ,(if (browserex-win-window-p) #x40020000 #x50020000)           180  20  80 24)

      (:button nil "DLLファイル"                           #x50020007   6  70 233 60)
      (:button ie-select "IE(&I):"                         #x50000009  13  82  54 12)
      (:edit ie nil                                        #x50810480  73  80 130 14)
      (:button ieref "参照..."                             #x50010000 207  80  28 14)

      (:button gecko-select "Gecko(&G):"                   #x50000009  13  97  54 12)
      (:edit gecko nil                                     #x50810480  73  95 130 14)
      (:button geckoref "参照..."                          #x50010000 207  95  28 14)

      (:button unknown-select "Unknown(&U):"               #x50000009  13 112  54 12)
      (:edit unknown nil                                   #x50810C80  73 110 130 14)

      (:button nil "メニュー"                              #x50020007   6 134 233 48)
      (:button menu "メニューを追加(&M)"                   #x50010003  13 146  80 14)
      (:static nil "メニュー文字列(&T):"                   #x50020000 100 148  56  8)
      (:edit menu-name nil                                 #x50810480 156 146  54 14)
      (:button focus-menu "「ウィンドウ」メニューにフォーカス用メニューを追加(&F)"
                                                           #x50010003  13 162 170 14)
      ))
   #'(lambda ()
       (let ((position-index (or (position *browser-position* (mapcar 'cdr position-alist))
                                 (position XPIS_LEFT (mapcar 'cdr position-alist))))
             (dll-pathname (browser-dll-pathname)))
         (list
          (cons 'dummy-trigger (not (browserex-win-window-p)))
          
          (cons 'pos (mapcar 'car position-alist))
          (cons 'pos position-index)
          (cons 'width (if (numberp *browser-width*)
                           (format nil "~D" *browser-width*) "200"))
          (cons 'height (if (numberp *browser-height*)
                            (format nil "~D" *browser-height*) "200"))
          (cons 'view-basis-xyzzy-size (null *browser-add-window*))
          (cons 'view-basis-xyzzy-position
                (eq *browser-add-window* :enlarge))
          (cons 'view-basis-editor
                (eq *browser-add-window* :fix))
          (cons 'save-size *browser-save-size*)
          (cons 'ie *browser-dll-IE*)
          (cons 'gecko *browser-dll-Gecko*)
          (when (and (stringp dll-pathname)
                     (string/= dll-pathname "")
                     (not (path-equal dll-pathname *browser-dll-IE*))
                     (not (path-equal dll-pathname *browser-dll-Gecko*)))
            (cons 'unknown dll-pathname))
          (when (and (stringp dll-pathname)
                     (string/= dll-pathname ""))
            (cond ((path-equal dll-pathname *browser-dll-IE*)
                   (cons 'ie-select t))
                  ((path-equal dll-pathname *browser-dll-Gecko*)
                   (cons 'gecko-select t))
                  (t
                   (cons 'unknown-select t))))
          (cons 'menu *browserex-set-menu*)
          (cons 'menu-name (if (and (stringp *browserex-menu-name*)
                                    (string/= *browserex-menu-name* ""))
                               *browserex-menu-name* "&BX"))
          (cons 'focus-menu *browserex-set-focus-menu*)
          )))
   (list
    '(dummy-trigger
      :disable (view-basis view-basis-xyzzy-size view-basis-xyzzy-position
                           view-basis-editor save-size))

    '(width :type integer :min 1 :max 10000 :range-error "1から10000を指定してください")
    '(widthspin :min 1 :max 10000)
    '(height :type integer :min 1 :max 10000 :range-error "1から10000を指定してください")
    '(heightspin :min 1 :max 10000)
    '(ieref :related ie
      :file-name-dialog (:title "参照"
                         :filter (("DLLファイル(*.dll)" . "*.dll")
                                  ("すべてのファイル(*.*)" . "*.*"))
                         :must-exist t))
    '(geckoref :related gecko
      :file-name-dialog (:title "参照"
                         :filter (("DLLファイル(*.dll)" . "*.dll")
                                  ("すべてのファイル(*.*)" . "*.*"))
                         :must-exist t))
    )
   #'(lambda (data)
       (let (position-index (dll-pathname (browser-dll-pathname)))
         (setq position-index
               (position (cdr (assoc 'pos data))
                         (mapcar 'car position-alist) :test 'string=))
         (setq *browser-position*
               (elt (mapcar 'cdr position-alist) position-index))
         (setq *browser-width* (cdr (assoc 'width data)))
         (setq *browser-height* (cdr (assoc 'height data)))
         (cond ((cdr (assoc 'view-basis-xyzzy-size data))
                (setq *browser-add-window* nil))
               ((cdr (assoc 'view-basis-xyzzy-position data))
                (setq *browser-add-window* :enlarge))
               ((cdr (assoc 'view-basis-editor data))
                (setq *browser-add-window* :fix)))
         (setq *browser-save-size* (cdr (assoc 'save-size data)))
         (setq *browser-dll-IE* (cdr (assoc 'ie data)))
         (setq *browser-dll-Gecko* (cdr (assoc 'gecko data)))
         (cond ((cdr (assoc 'ie-select data))
                (unless (path-equal dll-pathname *browser-dll-IE*)
                  (browser-dll-define-function *browser-dll-IE*)))
               ((cdr (assoc 'gecko-select data))
                (unless (path-equal dll-pathname *browser-dll-Gecko*)
                  (browser-dll-define-function *browser-dll-Gecko*))))
         (setq *browserex-set-menu* (cdr (assoc 'menu data)))
         (setq *browserex-menu-name* (cdr (assoc 'menu-name data)))
         (if *browserex-set-menu*
             (insert-browserex-menu)
           (delete-browserex-menu))
         (setq *browserex-set-focus-menu* (cdr (assoc 'focus-menu data)))
         (if *browserex-set-focus-menu*
             (insert-browserex-focus-menu-items)
           (delete-browserex-focus-menu))
         ))))
(setq *browserex-property-page-no* (1- (length ed::*option-prop-page*)))
(defun browserex-show-property ()
  "共通設定の Browserex を開く"
  (interactive)
  (let ((ed::*option-prop-page-no* *browserex-property-page-no*))
    (option-property-sheet)))

;;; browserex menu
(defun init-browserex-menu ()
  "Browserex メニューを作成"
  (unless *browserex-menu*
    (setq *browserex-menu* (create-popup-menu 'bx::browserex))
    (add-menu-item *browserex-menu* nil
                      "編集バッファにフォーカスを移す(&E)"
                      'browserex-set-focus-editor)
    (add-menu-item *browserex-menu* nil
                      "ブラウザにフォーカスを移す(&R)"
                      'browserex-set-focus-browser
                      'tool-bar-update-browser)
    (add-menu-separator *browserex-menu* nil)
    (add-menu-item *browserex-menu* nil
                      "ブラウザで表示(&O)"
                      'navigate-current-buffer)
    (add-menu-item *browserex-menu* nil
                      "ブラウザでフォルダを表示(&F)"
                      'navigate-current-buffer-directory)
    (add-menu-item *browserex-menu* nil
                      "ブラウザの表示位置を変更(&P)"
                      'rotate-browser
                      'tool-bar-update-browser)
    (add-menu-item *browserex-menu* nil
                      "IE <-> Gecko を切替(&A)"
                      'change-browser
                      #'(lambda () (or (and (browser-open-p)
                                            (stringp *browser-dll-IE*)
                                            (string/= *browser-dll-IE* "")
                                            (stringp *browser-dll-Gecko*)
                                            (string/= *browser-dll-Gecko* ""))
                                       :disable)))
    (add-menu-item *browserex-menu* nil
                      "ブラウザを閉じる(&C)"
                      'close-browser
                      'tool-bar-update-browser)
    (add-menu-separator *browserex-menu* nil)
    (add-menu-item *browserex-menu* nil
                      "戻る(&B)" 'go-back-browser
                      'tool-bar-update-browser)
    (add-menu-item *browserex-menu* nil
                      "進む(&F)" 'go-forward-browser
                      'tool-bar-update-browser)
    (add-menu-separator *browserex-menu* nil)
    (add-menu-item *browserex-menu* nil
                      "設定(&Z)..."
                   'browserex-show-property))
  *browserex-menu*)
(defun insert-browserex-menu (&key (menu (current-menu))
                                   (position *browserex-menu-position*)
                                   (menu-name *browserex-menu-name*))
  "browserex メニューを追加"
  (unless (menup *browserex-menu*)
    (init-browserex-menu))
  (when (menup menu)
    (delete-browserex-menu menu)
    (cond
     ((and (numberp position) (integerp position))
      (insert-popup-menu menu position *browserex-menu* menu-name))
     ((and (symbolp position) (get-menu-position menu position))
      (insert-popup-menu menu (get-menu-position menu position)
                         *browserex-menu* menu-name))
     (t
      (add-popup-menu menu *browserex-menu* menu-name)))))
(defun delete-browserex-menu (&optional (menu (current-menu)))
  "browserex メニューを削除"
  (let (ret)
    (if (menup menu)
        (while (delete-menu menu 'bx::browserex)
          (setq ret t)))
    ret))
(defun get-browserex-menu-position (&optional (menu (current-menu)))
  "browserex メニューの位置を取得"
  (if (menup menu)
      (get-menu-position menu 'bx::browserex)))

;;; focus menu
(defun insert-browserex-focus-menu-items (&key menu position head-sep tail-sep)
  "browserex フォーカス用メニューを追加"
  (if (and (not (menup menu)) (menup (current-menu)))
      (setq menu (get-menu (current-menu) 'ed::window)))
  (when (menup menu)
    (delete-browserex-focus-menu menu)
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'bx-focus-separator))
    (insert-menu-item menu (incf position) 'bx-focus-editor
                      "編集バッファにフォーカスを移す(&E)"
                      'browserex-set-focus-editor)
    (insert-menu-item menu (incf position) 'bx-focus-browserex
                      "ブラウザにフォーカスを移す(&R)"
                      'browserex-set-focus-browser
                      #'(lambda () (or (bx::browser-open-p) :disable)))
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'bx-focus-separator))))
(defun delete-browserex-focus-menu (&optional menu)
  "browserex フォーカス用メニューを削除"
  (if (and (not (menup menu)) (menup (current-menu)))
      (setq menu (get-menu (current-menu) 'ed::window)))
  (when (menup menu)
    (while (delete-menu menu 'bx-focus-editor))
    (while (delete-menu menu 'bx-focus-browserex))
    (while (delete-menu menu 'bx-focus-separator))))

;;; mouse menu
(defun browserex-mouse-menu-popup (&optional apps)
  (interactive)
  (delete-menu *app-popup-menu* 'ed::url)
  (delete-menu *app-popup-menu* 'ed::url-sep)
  (delete-menu *app-popup-menu* 'browserex-url)
  (delete-menu *app-popup-menu* 'browserex-url-sep)
  (set-window *last-mouse-window*)
  (continue-pre-selection)
  (let (menu url)
    (cond ((eql (get-selection-type) 3)
           (setq menu *app-rectangle-popup-menu*))
          ((and (eql (get-selection-type) 2)
                (save-excursion
                  (goto-char (min (selection-point)
                                  (selection-mark)))
                  (looking-at ed::*url-scheme-regexp*)))
           (setq url (buffer-substring (selection-point)
                                       (selection-mark)))
           (setq menu *app-popup-menu*))
          (t
           (setq menu *app-popup-menu*)
           (save-excursion
             (goto-last-mouse-point)
             (skip-chars-backward "-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:")
             (when (looking-at ed::*url-scheme-regexp*)
               (setq url (buffer-substring (point)
                                           (progn
                                             (goto-char (match-end 0))
                                             (skip-chars-forward "-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:")
                                             (point))))))))
    (when url
      (add-menu-separator menu 'ed::url-sep)
      (add-menu-item menu 'ed::url
                     (concatenate 'string (abbreviate-display-string url 40 t)
                                  " を開く")
                     #'(lambda ()
                         (interactive)
                         (shell-execute url t)))
      (add-menu-item menu 'browserex-url
                     (concatenate 'string (abbreviate-display-string url 40 t)
                                  " を navigate (&N)")
                     #'(lambda ()
                         (interactive)
                         (navigate url))))
    ;; local file の navigate. <BASE href=""> は考慮しない
    (when (not url)
      (let (relative-path path valid-path
            (buffer-file-name (get-buffer-file-name)))
        (save-excursion
          (goto-last-mouse-point)
          (cond
           ((eql (parse-point-syntax) :string)
            (setq relative-path
                  (buffer-substring
                   (max (save-excursion (skip-syntax-spec-backward "^\"") (point))
                        (save-excursion (goto-bol) (point)))
                   (min (save-excursion (skip-syntax-spec-forward "^\"") (point))
                        (save-excursion (goto-eol) (point))))))
           (t
            (setq relative-path
                  (buffer-substring
                   (progn
                     (skip-chars-backward "-a-zA-Z0-9_/~.#@%&=;+(),'$!:\\")
                     (point))
                   (progn
                     (skip-chars-forward "-a-zA-Z0-9_/~.#@%&=;+(),'$!:\\")
                     (point)))))))
        ;; merge-pathnames で使用可能な最大文字列長は 496 文字のよう
        (if (> (length relative-path) 496)
            (setq relative-path (substring relative-path 0 496)))
        (cond
         ;; フルパス
         ((string-match *browserex-full-path-regexp* relative-path)
          (setq path relative-path))
         ;; ネットワークパスは除外
         ((string-match "\\\\" relative-path)
          (setq path ""))
         (t
          (setq path (merge-pathnames relative-path (default-directory)))))
        (cond
         ((string= path ""))
         ;; ファイルが存在する
         ((file-exist-p path)
          (setq valid-path (map-slash-to-backslash path)))
         ;; リンク先指定で HTML ファイル指定の場合
         ((and
           (string-match
            (concat "^\\(.+\\.\\(?:"
                    (substring
                     (apply 'concat
                            (mapcar #'(lambda (str)
                                        (concat "\\|" (regexp-quote str)))
                                    *browserex-html-pathname-type*)) 2)
                    "\\)\\)\\(#.*\\)")
            path)
           (file-exist-p (match-string 1)))
          (setq valid-path (concat (map-slash-to-backslash (match-string 1))
                                   (match-string 2)))
          (setq path (match-string 1)))
         ;; リンク先指定で、カレントファイルで、ファイル名がある場合
         ((and (string-match "^#" relative-path)
               buffer-file-name
               (member (pathname-type buffer-file-name) *browserex-html-pathname-type*
                       :test 'string-equal))
          (setq valid-path (concat (map-slash-to-backslash buffer-file-name)
                                   relative-path))
          (setq path buffer-file-name)))

        (when (and valid-path
                   (or
;                   (file-directory-p path)
                    (member (pathname-type path) *browserex-popup-pathname-type*
                            :test 'string-equal)))
          (if *browserex-message-valid-path*
              (message (map-slash-to-backslash valid-path)))
          (add-menu-separator menu 'browserex-url-sep)
          (add-menu-item menu 'browserex-url
                         (concat (abbreviate-display-string relative-path 40 t)
                                 " を navigate (&N)")
                         #'(lambda () (interactive) (navigate valid-path))))))
    (track-popup-menu menu (or apps :button2))))

(defun browserex-apps-popup ()
  (interactive)
  (let ((*last-mouse-window* (selected-window))
        (*last-mouse-line* (current-virtual-line-number))
        (*last-mouse-column* (current-virtual-column)))
    (browserex-mouse-menu-popup t)))

;;; tool-bar
(defun tool-bar-update-browser ()
  (or (browser-open-p) :disable))

(defun browser-tool-bar ()
  (create-tool-bar
   'browser-tool-bar
   (merge-pathnames "toolbar-browserex.bmp" (etc-path))
   '(("browser で表示" 0 navigate-current-buffer)
     ("browser でフォルダを表示" 1 navigate-current-buffer-directory)
     ("browser の表示位置を変更" 2 rotate-browser tool-bar-update-browser)
     ("browser を閉じる" 3 close-browser tool-bar-update-browser)
     )))

;; tool-bar 登録
(define-command-bar 'browser-tool-bar "Browser(&R)")

;;; startup 設定
(defun browserex-startup ()
  ;; browser.dll ファンクションの定義
  (cond ((and (stringp *last-valid-browser-dll*)
              (string/= *last-valid-browser-dll* "")
              (file-exist-p *last-valid-browser-dll*))
         (browser-dll-define-function *last-valid-browser-dll*))
        ((and (stringp *browser-dll-IE*)
              (string/= *browser-dll-IE* "")
              (file-exist-p *browser-dll-IE*))
         (browser-dll-define-function *browser-dll-IE*))
        ((and (stringp *browser-dll-Gecko*)
              (string/= *browser-dll-Gecko* "")
              (file-exist-p *browser-dll-Gecko*))
         (browser-dll-define-function *browser-dll-Gecko*))
        (t
         (let (dll (dll-filename "browser.dll"))
           (dolist (dir *browser-dll-load-path*
                        (browser-dll-define-function dll-filename))
             (when (and dir
                        (file-exist-p (setq dll (merge-pathnames dll-filename dir))))
               (browser-dll-define-function dll)
               (return))))))
  ;; browserex メニューの作成
  (init-browserex-menu)
  ;; browserex メニューの設定
  (if *browserex-set-menu*
      (if (menup ed::*app-menu*)
          (insert-browserex-menu)
        (add-hook 'ed::*init-app-menus-hook* 'insert-browserex-menu)))
  ;; browserex フォーカスメニューの作成・設定
  (if *browserex-set-focus-menu*
      (if (menup ed::*app-menu*)
          (insert-browserex-focus-menu-items :head-sep t)
        (add-hook 'ed::*init-app-menus-hook*
                  #'(lambda () (insert-browserex-focus-menu-items :head-sep t))))))

;;; uninstall
(defun browserex-uninstall ()
  "browserex のアンインストール"
  (close-browser)
  (delete-browserex-menu)
  (delete-browserex-focus-menu)
  (delete-command-bar 'browserex::browser-tool-bar)
  (delete 'browserex ed::*option-prop-page* :test #'eq
          :key #'(lambda (x) (if (consp x) (car x) nil)))
  (let ((package (find-package "browserex")))
    (dolist (x (copy-list ed::*history-variable-list*))
      (if (eq (symbol-package x) package)
          (unregister-history-variable x)))))

;;
(if (menup ed::*app-menu*)
    (browserex-startup)
  (add-hook 'ed::*post-startup-hook* 'browserex-startup))

(eval-when (:compile-toplevel)
  (export
   '(win-user::wwindow-zoomed-p
     win-user::xyzzy-zoomed-p
     win-user::get-wwindow-rectangle
     win-user::get-wclient-rectangle
     win-user::set-wwindow-rectangle
     win-user::get-wwindow-height
     win-user::get-wwindow-width
     win-user::set-wwindow-height
     win-user::set-wwindow-width
     win-user::enlarge-xyzzy-by-wwindow-size
     win-user::shrink-xyzzy-by-wwindow-size)
   "win-user"))

;;; browserex.l ends here
