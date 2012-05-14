;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; ggrep.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:22:19 +0900>

;;; Commentary:

;; Description:
;;
;;  Grep 類似の行指向検索を行います。
;;
;;    □検索方法
;;    ・複数検索パターン指定 AND/OR 検索
;;    ・一致/不一致検索
;;    ・バッファ/ファイル単位絞込み検索
;;        - 前回マッチしたバッファ/ファイルが再検索の対象
;;    ・行単位絞込み検索
;;        - 前回マッチした行が再検索の対象
;;        - 検索パターンが複数行に渡ってマッチする場合でも絞込み検索可能
;;    ・エンコード指定検索 (ファイル)
;;    ・シンタックス指定検索 (バッファ)
;;
;;    □検索対象
;;    ・カレントバッファ指定検索
;;    ・全表示バッファ指定検索
;;    ・複数ディレクトリ指定検索
;;    ・複数ファイル指定検索
;;    ・正規表現での複数バッファ指定検索
;;
;;    □出力方法
;;    ・バッファ/ファイル名、行番号なしの出力
;;    ・バッファ/ファイル名のみの出力
;;    ・フルパス名での出力
;;
;;    □検索設定の保存
;;    ・検索条件設定の保存、読込、削除(ダイアログ使用時)
;;
;;    □提供コマンド
;;    ┏━━━━━━━┯━━━━┯━━━━━━━━━┯━━━━━━━━┓
;;    ┃コマンド名    │パターン│対象              │対象(C-u)       ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │説明                                          ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep         │正規表現│バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │AND/OR 検索                                   ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃fggrep        │文字列  │バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │AND/OR 検索                                   ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-and     │正規表現│バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │AND 検索                                      ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃fggrep-and    │文字列  │バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │AND 検索                                      ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-or      │正規表現│バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │OR 検索                                       ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃fggrep-or     │文字列  │バッファリスト    │カレントバッファ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │OR 検索                                       ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-narrow  │正規表現│grep 結果バッファ │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │絞込み検索(バッファからは行番号情報のみ取得)  ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃fggrep-narrow │文字列  │grep 結果バッファ │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │絞込み検索(バッファからは行番号情報のみ取得)  ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃xggrep        │正規表現│ディレクトリ      │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │複数ディレクトリ指定検索                      ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃zggrep        │正規表現│ファイル          │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │複数ファイル指定検索                          ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-contents│正規表現│カレントバッファ  │指定バッファ    ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │絞込み検索(指定バッファ内コンテンツのみで検索)┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-buffer  │正規表現│カレントバッファ  │指定バッファ    ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │ggrep / ggrep-narrow / ggrep-contents         ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-detail  │        │                  │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │minibuffer から全てを指定して検索             ┃
;;    ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
;;    ┃ggrep-dialog  │        │                  │                ┃
;;    ┃              ├────┴─────────┴────────┨
;;    ┃              │dialog から全てを指定して検索                 ┃
;;    ┗━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━┛
;;

;; Installation:
;;
;;      1. アーカイブを展開して ggrep.l を $XYZZY/site-lisp に
;;         コピーします。
;;         toolbar-ggrep.bmp を $XYZZY/etc にコピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/ggrep.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "ggrep")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::ggrep-uninstall) とタイプし、
;;         ggrep.l 関連の情報を xyzzy から削除します。
;;
;;      2. ggrep.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      A: バッファ全体を正規表現で検索
;;        1. M-x ggrep
;;
;;      B: バッファ全体を文字列で検索
;;        1. M-x fggrep
;;
;;      C: 現在のバッファだけを検索
;;        1. C-u M-x ggrep
;;
;;      D: 指定ディレクトリ以下のファイルを検索
;;        1. M-x xggrep
;;
;;      E: 指定ファイルを検索
;;        1. M-x zggrep
;;
;;      F: 絞込み検索 1
;;        1. A～E で検索
;;        2. A～E の検索に検索条件を追加して、新たに検索
;;
;;      G: 絞込み検索 2
;;        1. A～E で検索
;;        2. 1. の結果を元に M-x ggrep-narrow で絞込み検索
;;
;;      H: 絞込み検索 3
;;        1. M-x ggrep-contents でバッファを検索
;;        2. 1. の結果バッファ上で再度 M-x ggrep-contents で検索
;;
;;      I: バッファに合わせた方法で検索
;;        1. M-x ggrep-buffer で検索
;;           - 通常バッファ上ならば C-u M-x ggrep と同様の方法で検索
;;           - ggrep-contents 結果バッファ上ならば、再度
;;             M-x ggrep-contents と同様の方法で検索
;;           - その他 ggrep 結果バッファ上ならば、M-x ggrep-narrow と
;;             同様の方法で検索
;;        2. 1. の結果バッファ上で再度 M-x ggrep-buffer で検索
;;
;;      J: minibuffer から細かく指定して検索
;;        1. M-x ggrep-detail
;;
;;      K: ダイアログから検索
;;        a. ダイアログの表示
;;          - [検索]-[GGrep] を選択
;;          - [表示]-[ツールバー]-[GGrep] でツールバーを表示した上で、
;;             ggrep ツールバー(ボタン) を選択
;;          - M-x ggrep-dialog を実行
;;
;;        b. 検索実行
;;          1. 検索方法をダイアログで設定する
;;          2. 「検索」ボタンを押す
;;
;;        c. 検索設定の保存
;;          1. 「設定」フィールドに設定名を入力する
;;          2. 「保存」ボタンを押す
;;
;;        d. 検索設定の読込
;;          1. 「設定」フィールドで設定名を選択/入力する
;;          2. 「読込」ボタンを押す
;;
;;        e. 検索設定の削除
;;          1. 「設定」フィールドで設定名を選択/入力する
;;          2. 「削除」ボタンを押す
;;

;; Customize:
;;
;;      検索方法指定
;;          *ggrep-narrow-method*    (nil | :and | :or)
;;          *fggrep-narrow-method*   (nil | :and | :or)
;;          *xggrep-method*          (nil | :and | :or)
;;          *zggrep-method*          (nil | :and | :or)
;;          *ggrep-buffer-method*    (nil | :and | :or)
;;          *ggrep-contents-method*  (nil | :and | :or)
;;
;;      フック
;;          *ggrep-hook*
;;          *ggrepd-hook*
;;
;;      強調表示
;;          *ggrep-highlight-match*
;;
;;      メニューの追加位置:
;;          (ggrep-insert-menu-items
;;           :menu     メニュー                   (<menu>)
;;           :pre-tag  追加位置直前メニューのタグ (<symbol>)
;;           :position 位置(:pre-tag が優先)      (<symbol> | <integer>)
;;           :head-sep 前区切り線                 (nil | <non-nil>)
;;           :tail-sep 後区切り線                 (nil | <non-nil>)
;;           )
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 12:17:35 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Sun, 17 Apr 2005 03:48:55 +0900
;;        ・xyzzy 0.2.2.234 対応
;;          - "ＭＳ Ｐゴシック" ⇒ "MS UI Gothic"
;;          - 半角カナを全角カナに変更。
;;            ⇒「ディレクトリ」「検索バッファ」「絞込みバッファ」に
;;              <...> (... は半角カナ) を指定していた場合は、対応する全
;;              角カナの項目を選び直す必要がある。
;;          - ggrep-insert-menu-items 更新。
;;            「GGrep」メニューを追加する位置のデフォルトを「Grep」
;;             の下に。
;;        ・コメント修正。
;;
;;      Tue, 14 Dec 2004 19:05:43 +0900
;;        ・ggrep-scan-buffer の検索効率を syntax 指定時多少安定して検索
;;          できるように。
;;
;;      Mon, 13 Dec 2004 00:06:14 +0900
;;        ・ggrep-dialog の「絞込み」で <カレントバッファ> を選択できるよ
;;          うに。
;;        ・ggrep-dialog の「設定」名が入力されていない状態で「保存」を
;;          した場合、その時点の日時から設定名を決定するように拡張。
;;        ・ggrep-detail での「絞込み(narrow)」検索が動作しないバグを修正。
;;
;;      Wed, 08 Dec 2004 00:27:20 +0900
;;        ・ggrep-scanner コメント追加。コード変更。
;;        ・バッファ検索の場合は、マッチ開始位置の syntax を指定できるよう
;;          に拡張。
;;          - ggrep-scan-buffer 追加。
;;          - ggrep-dialog, ggrep1, ggrep-scanner 拡張。
;;          - ggrep-internal, ggrep-detail 拡張。
;;        ・内部使用関数 ggrep-buffer-list を ggrep-narrow-buffer-list に
;;          名称変更。
;;        ・ggrep-dialog の[ファイル/バッファ/絞込み]を指定する入力フィー
;;          ルドをそれぞれ独立に。
;;        ・コメント typo 修正。
;;        ・その他。
;;
;;      Wed, 28 Jul 2004 00:31:38 +0900
;;        ・method を ed::and ed::or から :and :or に変更。
;;        ・ggrep, fggrep で指定する method を文字列から :and, :or に変更。
;;        ・*last-ggrep-method* の持つ値を method を判別する文字列
;;          ("and", "or") から method シンボル (:and, :or) に変更。
;;        ・ディレクトリ指定 xggrep、ファイル指定 zggrep 追加。
;;        ・ggrep1 の最後の hook を *ggrep-hook* 固定に変更。
;;        ・ggrep-dialog に「クリア」ボタン追加。
;;        ・「コンテンツのみ出力」オプションを追加。
;;        ・" " から始まるバッファ名のバッファでも、明示的に指定された場合は
;;          検索対象とするように変更。(grep とは異なる)
;;        ・一行一レコードの DB を検索する用途に用いることを想定した
;;          ggrep-contents を追加。追加にあたり、ggrep1 修正。
;;        ・対象バッファにより ggrep, ggrep-narrow, ggrep-contents を
;;          切り替える ggrep-buffer を追加。
;;
;;      Tue, 27 Jul 2004 00:11:01 +0900
;;        ・ggrep-dialog で各種操作時に「設定」名を引き継ぐように。
;;          引き継ぐだけで設定保存は「保存」を押下時。
;;
;;      Sun, 11 Jul 2004 23:33:45 +0900
;;        ・行単位絞込み検索追加。
;;        ・ggrep-narrow, fggrep-narrow 追加。
;;
;;      Fri, 21 May 2004 14:25:22 +0900
;;        ・ファイルリスト(フルパス)指定検索追加。
;;        ・バッファリスト(正規表現)指定検索追加。
;;
;;      Tue, 18 May 2004 01:41:10 +0900
;;        ・絞込み検索対象バッファがない場合は選択コンボボックスを
;;          無効に。
;;
;;      Mon, 17 May 2004 00:26:01 +0900
;;        ・AND 検索が 2004/2/17 以降動作していなかったのを修正。
;;        ・絞込み検索追加。
;;        ・ggrep-scan-files-async の typo 修正。
;;
;;      Wed, 03 Mar 2004 22:47:44 +0900
;;        ・ツールバー追加。
;;
;;      Tue, 17 Feb 2004 23:13:52 +0900
;;        ・ggrep-find-error-scanner の追加。
;;        ・OR 検索などの性能を多少改善。(scanner 仕様の拡張)
;;        ・その他。
;;
;;      Thu, 12 Feb 2004 19:00:36 +0900
;;        ・encoding を指定しての検索を可能に。
;;          バッファに読み込み済みの場合は、指定 encoding は意識しない。
;;
;;      Sat, 04 Oct 2003 01:23:47 +0900
;;        ・*ggrep-patterns*, *ggrep-directories* の初期値を修正。
;;
;;      Mon, 04 Aug 2003 12:56:05 +0900
;;        ・存在しない設定名で「読込」した際、設定をクリアするように変更。
;;
;;      Mon, 28 Jul 2003 08:25:31 +0900
;;        ・ggrep-dirs-normalization 修正。
;;
;;      Mon, 28 Jul 2003 00:33:01 +0900
;;        ・初版作成。
;;

;; Restriction:
;;
;;      ・絞込み検索対象指定バッファに、バッファ/ファイルの検索結果が
;;        混在している場合の動作は不定。
;;
;;      ・検索対象としてバッファ/ファイルを混在させた場合の動作は不定。
;;
;;      ・検索対象がバッファの場合非同期検索不可。
;;
;;      ・検索結果として、バッファ/ファイル名のみ出力する場合は、
;;        行単位絞込み検索不可。各バッファ/ファイル全体から検索する。
;;
;;      ・大量のファイルに対しての同期検索で固まることがある
;;        バイトコンパイルすると発生しなくなったが根本原因未調査。
;;

;; Todo:
;;      ・AND, OR だけでなく、COMPLEX 検索の追加。
;;        ex?) (and "abc" "def" (or "ghi" (not "jkl")))
;;
;;      ・エンコード指定検索の結果からの first-error, next-error 時
;;        には、指定エンコードでファイルを開きなおす。
;;
;;      ・first-error, next-error 時の強調表示の修正。
;;        現在は、簡易的に対象行一行全てを強調表示。
;;
;;      ・非同期 ggrep 時の実行開始時の待ちの解消。
;;
;;      ・ダイアログでの <カレントディレクトリ> 表示を
;;        <デフォルトディレクトリ> に変更するか検討。
;;        <バッファディレクトリ> の方が分かりやすいか？
;;

;; Memo:
;;  ・grep では " " から始まるバッファ名のバッファを明示的に指定しても
;;    検索を行わないが ggrep では明示的に指定された場合は検索するように
;;    変更した。
;;
;;  ・hook 用 symbol 名 *ggrep-hook*, *ggrepd-hook* からは、ggrep-dialog
;;    実行後は *ggrepd-hook* が、それ以外の場合は *ggrep-hook* が処理される
;;    ように思えるが、そうではない。
;;    従来は、minibuffer からの grep では検索対象がバッファのみ、grep-dialog
;;    からの検索では検索対象がファイルのみであったため、バッファ検索用
;;    function である grep1 では *grep-hook* が、それ以外では *grepd-hook*
;;    が用いられている。
;;    ggrep 関連の function では minibuffer/dialog の両方からバッファ/ファイル
;;    の検索を行うが、ファイルを検索対象に含む場合には *ggrepd-hook* を、
;;    ファイルを検索対象に含まない場合には *ggrep-hook* を用いることとする。
;;
;;  ・dialog での設定変更をどこまで minibuffer での実行時に反映させるか。
;;    要検討。
;;  ・*find-error-scanner* は goto-error で用いられる。
;;  ・ggrep-scanner で返す function の引数 limit は goto-error
;;    (first-error, next-error) でのみ用いらる。
;;    強調表示のために用いられる。
;;
;;  ・呼び出し順序
;;
;;  grep-dialog (sync)
;;  └ editor::grep-dialog-1
;;     └ editor::scan-files
;;        ├ editor::grep-scanner
;;        └ editor::scan-files-sync
;;           ├ editor::scan-files-setup
;;           └ editor::scan-files-1
;;              └ editor::grep-scan-file
;;                 └ scan-buffer
;;
;;  grep-dialog (async)
;;  └ editor::grep-dialog-1
;;     └ editor::scan-files
;;        ├ editor::grep-scanner
;;        └ editor::scan-files-async
;;           ├ editor::scan-files-setup
;;           ├ editor::async-grep-mode
;;           ├ editor::grep-async-scanner
;;           └ start-timer
;;
;;  xgrep
;;  └ editor::scan-files
;;     ├ editor::grep-scanner
;;     └ editor::scan-files-sync
;;        ├ editor::scan-files-setup
;;        └ editor::scan-files-1
;;           └ editor::grep-scan-file
;;              └ scan-buffer
;;
;;  ggrep-dialog (sync)
;;  ├ editor::ggrep-load-setting
;;  ├ editor::ggrep-make-setting
;;  ├ editor::ggrep-patterns-normalization
;;  └ editor::ggrep-scan-files
;;     ├ editor::ggrep-patterns-normalization
;;     ├ editor::ggrep-dirs-normalization
;;     ├ editor::ggrep-scanner
;;     └ editor::ggrep-scan-files-sync
;;        ├ editor::scan-files-setup
;;        └ editor::ggrep-scan-files-1
;;           └ editor::ggrep-scan-file
;;              └ scan-buffer
;;
;;  ggrep-dialog (async)
;;  ├ editor::ggrep-load-setting
;;  ├ editor::ggrep-make-setting
;;  ├ editor::ggrep-patterns-normalization
;;  └ editor::ggrep-scan-files
;;     ├ editor::ggrep-patterns-normalization
;;     ├ editor::ggrep-dirs-normalization
;;     ├ editor::ggrep-scanner
;;     └ editor::ggrep-scan-files-async
;;        ├ editor::scan-files-setup
;;        ├ editor::async-ggrep-mode
;;        ├ editor::ggrep-async-scanner
;;        └ start-timer
;;

;; Licence:
;;
;;    ggrep は修正BSDライセンスに基づいて利用可能です。
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

(provide "ggrep")

(require "grep")
(require "grepd")
(require "minibuf")
(require "encoding")

(in-package "editor")

(export '(ggrep-dialog ggrep-detail
          ggrep ggrep-and ggrep-or ggrep-narrow
          fggrep fggrep-and fggrep-or fggrep-narrow
          xggrep zggrep ggrep-contents
          ggrep-buffer
          ggrep-insert-menu-items
          ggrep-delete-menu
          *ggrep-narrow-method*
          *fggrep-narrow-method*
          *xggrep-method*
          *zggrep-method*
          *ggrep-contents-method*
          *ggrep-buffer-method*
          *ggrep-hook*
          *ggrepd-hook*))

(defvar *ggrep-narrow-method* nil)
(defvar *fggrep-narrow-method* nil)
(defvar *xggrep-method* nil)
(defvar *zggrep-method* nil)
(defvar *ggrep-buffer-method* nil)
(defvar *ggrep-contents-method* nil)

(defvar *ggrep-highlight-match* *grep-highlight-match*)
(defvar *ggrep-hook* nil)
(defvar *ggrepd-hook* nil)

(defvar *ggrep-method* nil)
(defvar *ggrep-patterns* nil)
(defvar *ggrep-select-target-method* nil "'buffer-list, 'file-list, nil")
(defvar *ggrep-target-type* nil ":file, :buffer, :narrow")
(defvar *ggrep-directories* nil)
(defvar *ggrep-file* "*")
(defvar *ggrep-buffer* "<カレントバッファ>")
(defvar *ggrep-narrow-buffer* nil)
(defvar *ggrep-narrow-unit* nil
  "絞込み検索単位の指定
:buffer : バッファ/ファイル絞込み
:line   : 行絞込み
上記以外: 行絞込み")
(defvar *ggrep-file-list* nil)
(defvar *ggrep-buffer-regexp-list* nil)
(defvar *ggrep-encoding-name* nil)
(defvar *ggrep-encoding-check-file* nil)
(defvar *ggrep-syntax* t)
(defvar *ggrep-case-fold-search* *grep-case-fold-search*)
(defvar *ggrep-word-search* *grep-word-search*)
(defvar *ggrep-regexp-search* *grep-regexp-search*)
(defvar *ggrep-understand-escape-sequences* *grep-understand-escape-sequences*)
(defvar *ggrep-async* *grep-async*)
(defvar *ggrep-contents-only* nil)
(defvar *ggrep-name-only* *grep-name-only*)
(defvar *ggrep-full-name* nil)

(defvar *ggrep-subdir-default* nil)
(defconstant *ggrep-dialog-number-of-pattern-min* 1)
(defconstant *ggrep-dialog-number-of-dir-min* 1)
(defvar *ggrep-dialog-number-of-pattern* 3)
(defvar *ggrep-dialog-number-of-dir* 3)

(defvar *ggrep-method-alist* '(("AND" . :and) ("OR" . :or)))

(defvar *ggrep-contents-only-bufname* "*match contents*")

(define-history-variable *last-ggrep-regexp-list* nil)
(define-history-variable *last-fggrep-pattern-list* nil)
(define-history-variable *last-ggrep-method* nil)
(define-history-variable *last-ggrep-setting* nil)
(define-history-variable *ggrep-setting-history* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ggrep (method regexp-list &optional arg)
  (interactive
      (let (method patterns)
        (multiple-value-setq (patterns method)
          (ggrep-read-patterns :command-name "ggrep"
                               :regexp-search t
                               :nomatch-search-use nil))
        (list method patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method method
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun ggrep-and (regexp-list &optional arg)
  (interactive
      (let (patterns)
        (setq patterns (ggrep-read-patterns :command-name "ggrep-and"
                                            :regexp-search t
                                            :method :and
                                            :nomatch-search-use nil))
        (list patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method :and
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun ggrep-or (regexp-list &optional arg)
  (interactive
      (let (patterns)
        (setq patterns (ggrep-read-patterns :command-name "ggrep-or"
                                            :regexp-search t
                                            :method :or
                                            :nomatch-search-use nil))
        (list patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method :or
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun ggrep-narrow (method regexp-list &optional buffer)
  (interactive
      (let (method patterns buffer args)
        (when (eq *last-command* 'universal-argument)
          (setq buffer (ggrep-read-narrow :command-name "ggrep-narrow"
                                          :narrow-unit :line)))
        (setq args (list :command-name "ggrep-narrow"
                         :regexp-search t
                         :nomatch-search-use nil))
        (when *ggrep-narrow-method*
          (setq args (nconc args (list :method *ggrep-narrow-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (list method patterns buffer)))
  (unless buffer
    (setq buffer (selected-buffer)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :narrow-buffer buffer
                  :narrow-unit :line
                  ;; 検索パターン
                  :method method
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun fggrep (method pattern-list &optional arg)
  (interactive
      (let (method patterns)
        (multiple-value-setq (patterns method)
          (ggrep-read-patterns :command-name "fggrep"
                               :regexp-search nil
                               :nomatch-search-use nil))
        (list method patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-fggrep-pattern-list* pattern-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method method
                  :patterns pattern-list
                  :regexp-search nil
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun fggrep-and (pattern-list &optional arg)
  (interactive
      (let (patterns)
        (setq patterns (ggrep-read-patterns :command-name "fggrep-and"
                                            :regexp-search nil
                                            :method :and
                                            :nomatch-search-use nil))
        (list patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-fggrep-pattern-list* pattern-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method :and
                  :patterns pattern-list
                  :regexp-search nil
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun fggrep-or (pattern-list &optional arg)
  (interactive
      (let (patterns)
        (setq patterns (ggrep-read-patterns :command-name "fggrep-or"
                                            :regexp-search nil
                                            :method :or
                                            :nomatch-search-use nil))
        (list patterns (eq *last-command* 'universal-argument))))
  (when (interactive-p)
    (setq *last-fggrep-pattern-list* pattern-list))
  (ggrep-internal :buffer-list arg
                  ;; 検索パターン
                  :method :or
                  :patterns pattern-list
                  :regexp-search nil
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun fggrep-narrow (method pattern-list &optional buffer)
  (interactive
      (let (method patterns buffer args)
        (when (eq *last-command* 'universal-argument)
          (setq buffer (ggrep-read-narrow :command-name "fggrep-narrow"
                                          :narrow-unit :line)))
        (setq args (list :command-name "fggrep-narrow"
                         :regexp-search nil
                         :nomatch-search-use nil))
        (when *fggrep-narrow-method*
          (setq args (nconc args (list :method *fggrep-narrow-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (list method patterns buffer)))
  (unless buffer
    (setq buffer (selected-buffer)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-fggrep-pattern-list* pattern-list))
  (ggrep-internal :narrow-buffer buffer
                  :narrow-unit :line
                  ;; 検索パターン
                  :method method
                  :patterns pattern-list
                  :regexp-search nil
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun xggrep (method regexp-list dirs files)
  (interactive
      (let (method patterns dirs files args)
        (setq args (list :command-name "xggrep"
                         :regexp-search t
                         :nomatch-search-use nil))
        (when *xggrep-method*
          (setq args (nconc args (list :method *xggrep-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (multiple-value-setq (dirs files)
          (ggrep-read-dirs :command-name "xggrep"
                           :subdir-constant t))
        (list method patterns dirs files)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :dirs dirs
                  :files files
                  ;; 検索パターン
                  :method method
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun zggrep (method regexp-list file-list)
  (interactive
      (let (method patterns file-list args)
        (setq args (list :command-name "zggrep"
                         :regexp-search t
                         :nomatch-search-use nil))
        (when *zggrep-method*
          (setq args (nconc args (list :method *zggrep-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (setq file-list (ggrep-read-file-list :command-name "zggrep"))
        (list method patterns file-list)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :file-list file-list
                  ;; 検索パターン
                  :method method
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only nil
                  :name-only nil
                  :full-name *ggrep-full-name*))

(defun ggrep-contents (method regexp-list &optional buffer)
  (interactive
      (let (method patterns buffer buffer-name-list args)
        (when (eq *last-command* 'universal-argument)
          (dolist (buffer (buffer-list))
            (unless (string-match "^ " (buffer-name buffer))
              (push (buffer-name buffer) buffer-name-list)))
          (setq buffer
                (find-buffer
                 (completing-read "ggrep-contents buffer: "
                                  buffer-name-list
                                  :default (buffer-name (selected-buffer))
                                  :must-match t))))
        (setq args (list :command-name "ggrep-contents"
                         :regexp-search t
                         :nomatch-search-use nil))
        (when *ggrep-contents-method*
          (setq args (nconc args (list :method *ggrep-contents-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (list method patterns buffer)))
  (unless buffer
    (setq buffer (selected-buffer)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (ggrep-internal :buffer-list (if (listp buffer) buffer (list buffer))
                  ;; 検索パターン
                  :method method
                  :patterns regexp-list
                  :regexp-search t
                  :encoding-name nil
                  :syntax t
                  :case-fold *ggrep-case-fold-search*
                  :word-search *ggrep-word-search*
                  :async *ggrep-async*
                  :contents-only t))

(defun ggrep-buffer (method regexp-list &optional buffer)
  (interactive
      (let (method patterns buffer buffer-name-list args)
        (if (eq *last-command* 'universal-argument)
            (progn
              (dolist (buffer (buffer-list))
                (unless (string-match "^ " (buffer-name buffer))
                  (push (buffer-name buffer) buffer-name-list)))
              (setq buffer
                    (find-buffer
                     (completing-read "ggrep-buffer buffer: "
                                      buffer-name-list
                                      :default (buffer-name (selected-buffer))
                                      :must-match t))))
          (setq buffer (selected-buffer)))
        (setq args (list :command-name "ggrep-buffer"
                         :regexp-search t
                         :nomatch-search-use nil))
        (when *ggrep-buffer-method*
          (setq args (nconc args (list :method *ggrep-buffer-method*))))
        (multiple-value-setq (patterns method)
          (apply 'ggrep-read-patterns args))
        (list method patterns buffer)))
  (unless buffer
    (setq buffer (selected-buffer)))
  (when (interactive-p)
    (setq *last-ggrep-method* method)
    (setq *last-ggrep-regexp-list* regexp-list))
  (cond
   ((string= (buffer-name buffer) *ggrep-contents-only-bufname*)
    (ggrep-contents method regexp-list buffer))
   ((member buffer (ggrep-narrow-buffer-list))
    (ggrep-narrow method regexp-list buffer))
   (t
    (ggrep method regexp-list (list buffer)))))

(defun ggrep-detail (&key
                     ;; ---------- 検索パターン ----------
                     (method nil method-sv)
                     (patterns nil patterns-sv)
                     (regexp-search *ggrep-regexp-search* regexp-search-sv)
                     ;; ---------- 検索対象 ----------
                     ; 1. 任意の検索対象指定が可能
                     (target-list nil target-list-sv)
                     ; 2. 絞込み対象バッファ & 絞込み単位
                     (narrow-buffer nil narrow-buffer-sv)
                     (narrow-unit nil narrow-unit-sv)
                     ; 3. バッファ直接指定 (t, nil, buffer-list)
                     (buffer-list nil buffer-list-sv)
                     ; 4. バッファ正規表現指定
                     (buffer-regexp-list nil buffer-regexp-list-sv)
                     ; 5. ファイル直接指定
                     (file-list nil file-list-sv)
                     ; 6. ディレクトリ名 & ファイル名パターン
                     (dirs nil dirs-sv)
                     (files nil files-sv)
                     ;; ----------
                     (encoding-name nil encoding-name-sv)
                     (encoding-check-file nil encoding-check-file-sv)
                     (syntax t syntax-sv)
                     (case-fold *ggrep-case-fold-search* case-fold-sv)
                     (word-search *ggrep-word-search* word-search-sv)
                     (async *ggrep-async* async-sv)
                     (contents-only *ggrep-contents-only* contents-only-sv)
                     (name-only *ggrep-name-only* name-only-sv)
                     (full-name *ggrep-full-name* full-name-sv))
  (interactive
      (let ((command-name "ggrep-detail ")
            target-type args buffer-list buffer-regexp-list
            dirs files file-list
            narrow-buffer narrow-unit
            patterns method regexp-search
            target-list buffer-only-p
            return-args)
        ;; ------------------------------------------------------------
        ;; 検索対象指定
        (setq target-type
              (completing-read
               (format nil "~Atarget-type (buffer/all-buffers/buffer-regexp/dir/file/narrow): "
                       command-name)
               '("buffer" "all-buffers" "buffer-regexp" "dir" "file" "narrow")
               :case-fold t
               :must-match t))

        ;; ------------------------------------------------------------
        ;; 検索対象毎分岐処理
        (cond
         ;; 複数バッファ指定 -> buffer-list
         ((string= target-type "buffer")
          (setq args (list :command-name command-name))
          (setq buffer-list (apply 'ggrep-read-buffer-list args))
          (setq return-args (nconc return-args (list :buffer-list buffer-list))))
         ;; 全バッファ指定 -> buffer-list
         ((string= target-type "all-buffers")
          (setq buffer-list nil)
          (setq return-args (nconc return-args (list :buffer-list buffer-list))))
         ;; バッファ正規表現指定 -> buffer-list
         ((string-equal target-type "buffer-regexp")
          (setq args (list :command-name command-name))
          (multiple-value-setq (buffer-regexp-list buffer-list)
            (apply 'ggrep-read-buffer-regexp-list args))
          (setq return-args
                (nconc return-args (list :buffer-regexp-list buffer-regexp-list))))
         ;; ディレクトリ指定 -> dirs, files
         ((string-equal target-type "dir")
          (setq args (list :command-name command-name))
          (multiple-value-setq (dirs files)
            (apply 'ggrep-read-dirs args))
          (setq return-args
                (nconc return-args (list :dirs dirs :files files))))
         ;; 複数ファイル指定 -> file-list
         ((string-equal target-type "file")
          (setq args (list :command-name command-name))
          (setq file-list (apply 'ggrep-read-file-list args))
          (setq return-args
                (nconc return-args (list :file-list file-list))))
         ;; 絞込み検索 -> target-list
         ((string-equal target-type "narrow")
          (setq args (list :command-name command-name))
          (multiple-value-setq (narrow-buffer narrow-unit)
            (apply 'ggrep-read-narrow args))
          (setq target-list
                (ggrep-get-target-list narrow-buffer narrow-unit))
          (setq return-args
                (nconc return-args (list :narrow-buffer narrow-buffer
                                         :narrow-unit narrow-unit)))))

        ;; ------------------------------------------------------------
        ;; 検索対象が buffer のみであるか否かチェック
        (cond
         ((member target-type '("narrow") :test #'string=)
          (unless (find-if-not #'(lambda (x)
                                   (or (bufferp x)
                                       (and (stringp x) (find-buffer x))))
                               target-list
                               :key #'(lambda (target)
                                        (if (listp target) (car target) target)))
            (setq buffer-only-p t)))
         ((member target-type '("buffer" "all-buffers" "buffer-regexp") :test #'string=)
          (setq buffer-only-p t)))

        ;; ------------------------------------------------------------
        ;; method, pattern 指定
        (setq args (list :command-name command-name))
        (multiple-value-setq (patterns method regexp-search)
          (apply 'ggrep-read-patterns args))
        (setq return-args
              (nconc return-args (list :method method
                                       :patterns patterns
                                       :regexp-search regexp-search)))

        ;; ------------------------------------------------------------
        ;; オプション指定
        ;; encoding-name
        (unless buffer-only-p
          (setq args (list :command-name command-name))
          (multiple-value-setq (encoding-name encoding-check-file)
            (apply 'ggrep-read-encoding-name args))
          (setq return-args
                (nconc return-args (list :encoding-name encoding-name
                                         :encoding-check-file encoding-check-file))))

        ;; syntax
        (when buffer-only-p
          (setq args (list :command-name command-name))
          (setq syntax (apply 'ggrep-read-syntax args))
          (setq return-args
                (nconc return-args (list :syntax syntax))))

        ;; case-fold, word-search, async, contents-only, name-only, full-name
        (setq args (list :command-name command-name
                         :regexp-search regexp-search
                         :buffer-only-p buffer-only-p))
        (multiple-value-setq (case-fold word-search async contents-only name-only full-name)
          (apply 'ggrep-read-others args))
        (setq return-args (nconc return-args (list :case-fold case-fold)))
        (unless regexp-search
          (setq return-args (nconc return-args (list :word-search word-search))))
        (unless buffer-only-p
          (setq return-args (nconc return-args (list :async async))))
        (setq return-args (nconc return-args (list :contents-only contents-only)))
        (unless contents-only
          (setq return-args (nconc return-args (list :name-only name-only
                                                     :full-name full-name))))
        return-args))
  (let (args)
    (when (interactive-p)
      (setq *last-ggrep-method* method)
      (if regexp-search
          (setq *last-ggrep-regexp-list* patterns)
        (setq *last-fggrep-pattern-list* patterns)))
    (when method-sv
      (setq args (nconc args (list :method method))))
    (when patterns-sv
      (setq args (nconc args (list :patterns patterns))))
    (when regexp-search-sv
      (setq args (nconc args (list :regexp-search regexp-search))))
    (when target-list-sv
      (setq args (nconc args (list :target-list target-list))))
    (when narrow-buffer-sv
      (setq args (nconc args (list :narrow-buffer narrow-buffer))))
    (when narrow-unit-sv
      (setq args (nconc args (list :narrow-unit narrow-unit))))
    (when buffer-list-sv
      (setq args (nconc args (list :buffer-list buffer-list))))
    (when buffer-regexp-list-sv
      (setq args (nconc args (list :buffer-regexp-list buffer-regexp-list))))
    (when file-list-sv
      (setq args (nconc args (list :file-list file-list))))
    (when dirs-sv
      (setq args (nconc args (list :dirs dirs))))
    (when files-sv
      (setq args (nconc args (list :files files))))

    ;; ----------
    (when encoding-name-sv
      (setq args (nconc args (list :encoding-name encoding-name))))
    (when encoding-check-file-sv
      (setq args (nconc args (list :encoding-check-file encoding-check-file))))
    (when syntax-sv
      (setq args (nconc args (list :syntax syntax))))
    (when case-fold-sv
      (setq args (nconc args (list :case-fold case-fold))))
    (when word-search-sv
      (setq args (nconc args (list :word-search word-search))))
    (when async-sv
      (setq args (nconc args (list :async async))))
    (when contents-only-sv
      (setq args (nconc args (list :contents-only contents-only))))
    (when name-only-sv
      (setq args (nconc args (list :name-only name-only))))
    (when full-name-sv
      (setq args (nconc args (list :full-name full-name))))

    (apply 'ggrep-internal args)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ggrep-scan-file (file scanner common-path &optional linenum-list)
  (setq file (subseq file (length common-path)))
  (let ((found nil) (linenum-list (or (sort (copy-list linenum-list) #'<) t))
        current-found)
    ;; scanner の初期化 (ggrep の scanner 独自)
    (funcall scanner nil t)
    (loop
      (setq current-found nil)
      (unless (eq linenum-list t)
        (if linenum-list
            (goto-line (car linenum-list))
          (return-from ggrep-scan-file found)))
      (multiple-value-bind (one-time-found match-position-list)
          (funcall scanner nil nil)
        (if one-time-found
            (when (or (eq linenum-list t)
                      (member (current-line-number) linenum-list :test #'=))
              (setq current-found t)
              (setq found t))
          (return-from ggrep-scan-file found))
        (unless (eq linenum-list t)
          (setq linenum-list (member (current-line-number) linenum-list :test #'<)))
        (when current-found
          (let ((beg (progn (goto-bol) (point)))
                (end (progn (goto-eol) (point))))
            (if *ggrep-contents-only*
                (format t "~A~%" (buffer-substring beg end))
              (format t "~A:~D:~A~%" file (current-line-number) (buffer-substring beg end)))
            (when (and *ggrep-highlight-match*
                       (buffer-stream-p *standard-output*))
              (save-excursion
                (set-buffer (buffer-stream-buffer *standard-output*))
                (let ((p (- (buffer-stream-point *standard-output*) end 1)))
                  (dolist (match-position match-position-list)
                    (apply #'set-text-attribute
                           (+ (car match-position) p) (+ (cdr match-position) p)
                           'ggrep *ggrep-highlight-match*)))))))
        (or (progn (goto-eol) (forward-char 1))
            (return))))
    found))

(defun ggrep-scan-files-1 (file patterns buffer scanner common-path &optional linenum-list)
  (let ((file-buffer (get-file-buffer file)))
    (if (and file-buffer (not *ggrep-encoding-check-file*))
        (set-buffer file-buffer)
      (let* ((encoding
              (if (or (not *ggrep-encoding-name*)
                      (not (stringp *ggrep-encoding-name*)))
                  *expected-fileio-encoding*
                (car (member *ggrep-encoding-name* *char-encoding-list*
                             :key 'char-encoding-name
                             :test 'string=))))
             (*expected-fileio-encoding*
              (or encoding
                  (find-file-auto-encoding file)
                  *expected-fileio-encoding*)))
        (declare (special *expected-fileio-encoding*))
        (set-buffer buffer)
        (erase-buffer buffer)
        (ignore-errors (insert-file-contents file))))
    (save-excursion
      (goto-char (point-min))
      (message "scanning (~A)" (subseq file (length common-path)))
      (cond (*ggrep-name-only* ;; linenum-list 無視
             (when (funcall scanner)
               (princ (subseq file (length common-path)))
               (terpri)
               t))
            (t
             (ggrep-scan-file file scanner common-path linenum-list))))))

(defun ggrep-scan-files-sync (patterns buffer temp scanner file dirs target-list)
  (unwind-protect
      (let (files dirlist common-path)
        (setq files
              (mapcar #'(lambda (target)
                          (if (consp target) (car target) target))
                      target-list))
        (if files
            (progn
              (if *ggrep-full-name*
                  (setq common-path "")
                (setq common-path (glob-common-path files))))
          (progn
            (setq dirlist (glob-expand-list
                           (mapcar #'(lambda (d) (ggrep-get-setting-item d "directory"))
                                   dirs)))
            (unless dirlist
              (error "~S~%ディレクトリが見つかりません" dirs))
            (setq dirlist (mapcar 'append-trail-slash dirlist))
            (dolist (dir (prog1 (nreverse dirlist) (setq dirlist nil)))
              (unless (member dir dirlist :test 'string=)
                (if dirlist
                    (push dir dirlist)
                  (setq dirlist (list dir)))))
            (if *ggrep-full-name*
                (setq common-path "")
              (setq common-path (if (= (length dirlist) 1)
                                    (car dirlist)
                                  (glob-common-path dirlist))))))
        (scan-files-setup common-path buffer temp (ggrep-find-error-scanner))
        (refresh-screen)
        (with-output-to-selected-buffer
          (let ((last-tick (get-internal-real-time))
                (found nil) tick filelist linenum-list target f)
            (if target-list
                ;; ターゲットリスト(ファイルリスト)指定の場合
                (dolist (target target-list)
                  (if (consp target)
                      (progn
                        (setq f (car target))
                        (setq linenum-list (cadr target)))
                    (progn
                      (setq f target)
                      (setq linenum-list nil)))
                  (unless (member f filelist :test 'string=)
                    (if filelist
                        (push f filelist)
                      (setq filelist (list f)))
                    (when (ggrep-scan-files-1 f patterns temp scanner common-path linenum-list)
                      (setq found t))
                    (when found
                      (setq tick (get-internal-real-time))
                      (when (> (- tick last-tick) 500)
                        (setq last-tick tick)
                        (set-buffer buffer)
                        (goto-char (buffer-stream-point *standard-output*))
                        (refresh-screen)
                        (setq found nil)))
                    (do-events)))
              ;; ディレクトリリスト+ファイル指定の場合
              (dolist (d dirs)
                (when (ggrep-get-setting-item d "enable")
                  (glob-exec (glob-expand (ggrep-get-setting-item d "directory"))
                             :recursive (ggrep-get-setting-item d "subdir")
                             :file-only t :wild file
                             :absolute t
                             :callback
                             #'(lambda (f)
                                 (unless (member f filelist :test 'string=)
                                   (if filelist
                                       (push f filelist)
                                     (setq filelist (list f)))
                                   (when (ggrep-scan-files-1 f patterns temp scanner common-path)
                                     (setq found t))
                                   (when found
                                     (setq tick (get-internal-real-time))
                                     (when (> (- tick last-tick) 500)
                                       (setq last-tick tick)
                                       (set-buffer buffer)
                                       (goto-char (buffer-stream-point *standard-output*))
                                       (refresh-screen)
                                       (setq found nil)))
                                   (do-events))))))))))
    (delete-buffer temp)
    (set-buffer buffer)
    (goto-char (point-min)))
  (set-buffer-modified-p nil)
  (run-hooks '*ggrepd-hook*)
  (message "done"))

(or (boundp 'async-ggrep-mode)
    (setq-default async-ggrep-mode nil))
(or (boundp 'async-ggrep-status)
    (setq-default async-ggrep-status nil))
(or (boundp 'async-ggrep-timer-callback)
    (setq-default async-ggrep-timer-callback nil))
(pushnew '(async-ggrep-mode . async-ggrep-status)
         *minor-mode-alist* :key #'car)

(defvar *async-ggrep-mode-map* nil)
(unless *async-ggrep-mode-map*
  (setq *async-ggrep-mode-map* (make-sparse-keymap))
  (define-key *async-ggrep-mode-map* #\C-g 'stop-async-ggrep))

(defun async-ggrep-mode ()
  (kill-all-local-variables)
  (setq buffer-mode 'async-ggrep-mode)
  (setq mode-name "GGrep")
  (use-keymap *async-ggrep-mode-map*)
  (make-local-variable 'async-ggrep-timer-callback)
  (setq async-ggrep-timer-callback nil)
  (make-local-variable 'async-ggrep-temp-buffer)
  (setq async-ggrep-temp-buffer nil)
  (make-local-variable 'async-ggrep-last-update)
  (setq async-ggrep-last-update (get-internal-real-time))
  (make-local-variable 'async-ggrep-mode)
  (setq async-ggrep-mode nil)
  (make-local-variable 'async-ggrep-status))

(defun stop-async-ggrep ()
  (interactive)
  (when async-ggrep-timer-callback
    (set-buffer-modified-p nil)
    (setq async-ggrep-status "done")
    (update-mode-line (selected-buffer))
    (stop-timer async-ggrep-timer-callback)
    (setq async-ggrep-timer-callback nil)
    (when async-ggrep-temp-buffer
      (delete-buffer async-ggrep-temp-buffer)
      (setq async-ggrep-temp-buffer nil))
    (run-hooks '*ggrepd-hook*)
    (message "done"))
  t)

(defun ggrep-async-scanner (patterns buffer temp scanner glob common-path)
  #'(lambda ()
      (let ((update (get-buffer-window buffer)))
        (with-set-buffer
          (save-excursion
            (set-buffer buffer)
            (if (null async-ggrep-timer-callback)
                (setq update nil)
              (let ((target (funcall glob))
                    (timer async-ggrep-timer-callback)
                    (last-tick async-ggrep-last-update)
                    file linenum-list)
                (if (consp target)
                    (progn
                      (setq file (car target))
                      (setq linenum-list (cadr target)))
                  (setq file target))
                (cond ((stringp file)
                       (with-output-to-buffer (buffer (point-max))
                         (cond ((not (ggrep-scan-files-1 file patterns temp scanner common-path linenum-list))
                                (setq update nil))
                               (update
                                (let ((tick (get-internal-real-time)))
                                  (cond ((> (- tick last-tick) 500)
                                         (set-buffer buffer)
                                         (setq async-ggrep-last-update tick))
                                        (t
                                         (setq update nil))))))
                         (start-timer 0 timer t)))
                      (file
                       (setq update nil)
                       (start-timer 0 timer t))
                      (t
                       (stop-async-ggrep)))))))
        (and update (refresh-screen)))))

(defun ggrep-scan-files-async (patterns buffer temp scanner file dirs target-list)
  (let (files dirlist common-path)
    (setq files
          (mapcar #'(lambda (target)
                      (if (consp target) (car target) target))
                  target-list))
    (if files
        (progn
          (if *ggrep-full-name*
              (setq common-path "")
            (setq common-path (glob-common-path files))))
      (progn
        (setq dirlist (glob-expand-list
                       (mapcar #'(lambda (d) (ggrep-get-setting-item d "directory"))
                               dirs)))
        (unless dirlist
          (error "~S~%ディレクトリが見つかりません" dirs))
        (setq dirlist (mapcar 'append-trail-slash dirlist))
        (dolist (dir (prog1 (nreverse dirlist) (setq dirlist nil)))
          (unless (member dir dirlist :test 'string=)
            (if dirlist
                (push dir dirlist)
              (setq dirlist (list dir)))))
        (if *ggrep-full-name*
            (setq common-path "")
          (setq common-path (if (= (length dirlist) 1)
                                (car dirlist)
                              (glob-common-path dirlist))))))
    (scan-files-setup common-path buffer temp (ggrep-find-error-scanner))
    (async-ggrep-mode)
    (setq async-ggrep-temp-buffer temp)
    (unless target-list
      (dolist (d dirs)
        (when (ggrep-get-setting-item d "enable")
          (glob-exec (glob-expand (ggrep-get-setting-item d "directory"))
                     :recursive (ggrep-get-setting-item d "subdir")
                     :file-only t :wild file
                     :absolute t
                     :callback
                     #'(lambda (f)
                         (if target-list
                             (pushnew f target-list :test 'string=)
                           (setq target-list (list f)))))))
      (setq target-list (nreverse target-list)))
    (setq async-ggrep-timer-callback
          (ggrep-async-scanner patterns buffer temp scanner
                               #'(lambda () (or (pop target-list) nil))
                               common-path))
    (start-timer 0 async-ggrep-timer-callback t)
    (setq async-ggrep-mode t)
    (setq async-ggrep-status "running")))

(defun ggrep-find-error-scanner ()
  #'(lambda (&optional limit)
      (scan-buffer (compile-regexp ".*") :limit limit)))

(defun ggrep-scanner (patterns method case-fold word-search &key (syntax t))
  (let (match-patterns nomatch-patterns pattern status fix-status)
    ;; match-patterns, nomatch-patterns ::= (pattern . status)
    ;; status: nil       テストの失敗が確定済
    ;;       : t         テストの成功が確定済
    ;;       : 正整数    次に(テストの成否に関わらず)マッチが成功する物理行の行頭の point
    ;;       : 0         未確定
    (dolist (p (reverse patterns))
      (if (ggrep-get-setting-item p "match")
          (push (cons (ggrep-get-setting-item p "pattern") 0) match-patterns)
        (push (cons (ggrep-get-setting-item p "pattern") 0) nomatch-patterns)))
    (setq fix-status 0)
    (cond
     ;; AND 検索
     ((or (eq method :and)
          (and (eq method :or)
               (= 1 (+ (length match-patterns) (length nomatch-patterns))))
          (eq method nil))
      #'(lambda (&optional limit (init :ignore))
          (block ggrep-scanner-instance
            ;; 検索パターン status 初期化
            (when init
              (setq fix-status 0)
              (dolist (pattern-pair match-patterns)
                (rplacd pattern-pair 0))
              (dolist (pattern-pair nomatch-patterns)
                (rplacd pattern-pair 0))
              (if (eq init t)
                  (return-from ggrep-scanner-instance nil)))

            ;; 検索対象がない場合は nil
            (unless (or match-patterns nomatch-patterns)
              (return-from ggrep-scanner-instance (values nil nil)))
            (goto-bol)
            (let ((cpoint (point)) match-position-list)
              (loop
                ;; match pattern 検索
                (when match-patterns
                  (block ggrep-scanner-match
                    (loop
                      (setq match-position-list nil)
                      (dolist (pattern-pair match-patterns)
                        (setq pattern (car pattern-pair))
                        (setq status (cdr pattern-pair))
                        (cond
                         ;; テスト成功(マッチ成功)が確定済 -> ありえない状態
                         ((eq status t)
;                          (plain-error "ggrep (ggrep-scanner)のエラーです。")
                          )
                         ;; テスト失敗(マッチ失敗)が確定済 -> nil を返す
                         ((eq status nil)
                          (return-from ggrep-scanner-instance (values nil nil)))
                         ;; 何らかの行でマッチ
                         ((ggrep-scan-buffer pattern
                                             :case-fold case-fold
                                             :left-bound word-search
                                             :right-bound word-search
                                             :limit limit
                                             :syntax syntax)
                          (push (cons (match-beginning 0) (match-end 0)) match-position-list)
                          (goto-bol))
                         ;; テスト失敗(マッチ失敗) -> テスト失敗確定情報を記録し、nil を返す
                         (t
                          (rplacd pattern-pair nil)
                          (return-from ggrep-scanner-instance (values nil nil)))))
                      (if (= cpoint (point))
                          ;; 全マッチが同一行なら t
                          (progn
                            (setq match-position-list (nreverse match-position-list))
                            (return-from ggrep-scanner-match t))
                        ;; 行を移動していたら現在行で再チェック準備
                        (setq cpoint (point))))))
                ;; no match pattern 検索
                (unless nomatch-patterns
                  (return-from ggrep-scanner-instance (values t match-position-list)))
                (block ggrep-scanner-nomatch
                  (dolist (pattern-pair nomatch-patterns)
                    (setq pattern (car pattern-pair))
                    (setq status (cdr pattern-pair))
                    (cond
                     ;; テスト成功(マッチ失敗)が確定済
                     ((eq status t))
                     ;; 何らかの行でマッチ
                     ((ggrep-scan-buffer pattern
                                         :case-fold case-fold
                                         :left-bound word-search
                                         :right-bound word-search
                                         :limit limit
                                         :syntax syntax)
                      (if (progn (goto-bol) (= cpoint (point)))
                          ;; テスト失敗(対象行でマッチ)
                          (if (progn (goto-eol) (forward-char 1))
                              ;; 次行へ移動できれば次行へ移動し再チェック準備
                              (return-from ggrep-scanner-nomatch nil)
                            ;; 次行へ移動できなければ nil
                            (return-from ggrep-scanner-instance (values nil nil)))
                        ;; テスト成功(対象行以外でマッチ) -> 対象行に戻る
                        (goto-char cpoint)))
                     ;; テスト成功(マッチ失敗) -> テスト成功確定情報を記録
                     (t
                      (rplacd pattern-pair t)))))
                (if (= cpoint (point))
                    (return-from ggrep-scanner-instance (values t match-position-list))
                  (setq cpoint (point))))))))
     ;; OR 検索
     ((eq method :or)
      #'(lambda (&optional limit (init :ignore))
          (block ggrep-scanner-instance
            ;; 検索パターン status 初期化
            (when init
              (setq fix-status 0)
              (dolist (pattern-pair match-patterns)
                (rplacd pattern-pair 0))
              (dolist (pattern-pair nomatch-patterns)
                (rplacd pattern-pair 0))
              (if (eq init t)
                  (return-from ggrep-scanner-instance nil)))

            ;; 検索対象がない場合は nil
            (unless (or match-patterns nomatch-patterns)
              (return-from ggrep-scanner-instance (values nil nil)))
            (goto-bol)
            (let ((cpoint (point)))
              (loop
                ;; match pattern 検索
                (dolist (pattern-pair match-patterns)
                  (setq pattern (car pattern-pair))
                  (setq status (cdr pattern-pair))
                  (cond
                   ;; テスト失敗(マッチ失敗)が確定済 -> 次のパターンのテストへ
                   ((eq status nil))
                   ;; テスト成功(マッチ成功)が確定済 -> ありえない状態
                   ((eq status t)
;                    (plain-error "ggrep (ggrep-scanner)のエラーです。")
                    (return-from ggrep-scanner-instance
                      (values t (list (cons (match-beginning 0) (match-end 0))))))
                   ;; 次のマッチ成功 point に満たない場合 -> nil を返す
                   ((and (integerp status) (< cpoint status)))
                   ;; 何らかの行でマッチ
                   ((ggrep-scan-buffer pattern
                                       :case-fold case-fold
                                       :left-bound word-search
                                       :right-bound word-search
                                       :limit limit
                                       :syntax syntax)
                    (if (progn (goto-bol) (= cpoint (point)))
                        ;; 現在行でマッチ
                        (progn
                          (rplacd pattern-pair 0)
                          (return-from ggrep-scanner-instance
                            (values t (list (cons (match-beginning 0) (match-end 0))))))
                      ;; 現在行以外でマッチ -> マッチポイントを記録
                      (progn
                        (rplacd pattern-pair (point))
                        (goto-char cpoint))))
                   ;; テスト失敗(マッチ失敗) -> テスト失敗確定情報を記録
                   (t
                    (rplacd pattern-pair nil))))
                ;; no match pattern 検索
                (dolist (pattern-pair nomatch-patterns)
                  (setq pattern (car pattern-pair))
                  (setq status (cdr pattern-pair))
                  (cond
                   ;; テスト失敗(マッチ成功)が確定済 -> ありえない状態
                   ((eq status nil))
                   ;; テスト成功(マッチ失敗)が確定済 -> t を返す
                   ((eq status t)
                    (return-from ggrep-scanner-instance t))
                   ;; 次のマッチ成功 point に満たない場合(テスト成功) -> t を返す
                   ((and (integerp status) (< cpoint status))
                    (return-from ggrep-scanner-instance t))
                   ;; 何らかの行でマッチ
                   ((ggrep-scan-buffer pattern
                                       :case-fold case-fold
                                       :left-bound word-search
                                       :right-bound word-search
                                       :limit limit
                                       :syntax syntax)
                    (goto-bol)
                    (if (/= cpoint (point))
                        ;; テスト成功(現在行でマッチ失敗) -> マッチ成功 point 情報を記録し、t を返す
                        (progn
                          (rplacd pattern-pair (point))
                          (goto-char cpoint)
                          (return-from ggrep-scanner-instance t))
                      ;; テスト失敗(現在行でマッチ成功)
                      (progn
                        (rplacd pattern-pair 0)
                        (goto-char cpoint))))
                   ;; テスト成功(マッチ失敗)が確定 -> テスト成功確定情報を記録し、t を返す
                   (t
                    (rplacd pattern-pair t)
                    (return-from ggrep-scanner-instance t))))
                ;; 条件に不一致
                (if (progn (goto-eol) (forward-char 1))
                    (setq cpoint (point))
                  (return-from ggrep-scanner-instance nil)))))))
     )))

(defun ggrep-scan-buffer (pattern &key
                                  case-fold left-bound right-bound limit (syntax t)
                                  regexp
;                                  no-dup reverse tail last-match
                                  )
  (let (current-syntax)
    (when (eq syntax nil)
      (return-from ggrep-scan-buffer nil))
    (loop
      (unless (scan-buffer pattern
                           :case-fold case-fold :left-bound left-bound :right-bound right-bound
                           :limit limit :regexp regexp
;                          :no-dup no-dup  :reverse reverse :tail tail :last-match last-match
                           )
        (return-from ggrep-scan-buffer nil))
      (when (or (eq syntax t)
                (member (setq current-syntax (parse-point-syntax)) syntax))
        (return-from ggrep-scan-buffer t))
      ;; :tag のあるモードでの syntax の変化に注意
      ;; < > の間に :string :comment が出現する
      (cond
       ;; :string の開始まで移動
       ((equal syntax '(:string))
        (skip-syntax-spec-forward "^\"")
        (forward-char 1))
       ;; :string の終了まで移動
       ((eq current-syntax :string)
        (skip-syntax-spec-forward "^\"")
        (forward-char 1))
       ;; その他
       (t
        (forward-char 1))))))

(defun ggrep-patterns-normalization (patterns &key regexp-search understand-escape-sequences)
  (setq patterns (copy-tree patterns))
  (let (tmp-patterns)
    ;; 単純文字列リストの変更 (先頭要素のみの確認で判定)
    (if (stringp (car patterns))
        (setq patterns
              (mapcar #'(lambda (pattern)
                          (list (list (copy-string "enable") t)
                                (list (copy-string "pattern") pattern)
                                (list (copy-string "match") t)))
                      patterns)))
    ;; 不要・適切でないパターンの排除
    (dolist (p (nreverse patterns))
      (if (and (eq (ggrep-get-setting-item p "enable") t)
               (or (regexpp (ggrep-get-setting-item p "pattern"))
                   (and (stringp (ggrep-get-setting-item p "pattern"))
                        (string/= (ggrep-get-setting-item p "pattern") ""))))
          (push p tmp-patterns)))
    (setq patterns tmp-patterns)
    (setq tmp-patterns nil)
    ;; エスケープシーケンス
    (when understand-escape-sequences
      (dolist (p (reverse patterns))
        (push
         (list
          (list (copy-string "enable") (ggrep-get-setting-item p "enable"))
          (list (copy-string "pattern")
                (decode-escape-sequence
                 (ggrep-get-setting-item p "pattern") regexp-search))
          (list (copy-string "match") (ggrep-get-setting-item p "match")))
         tmp-patterns))
      (setq patterns tmp-patterns)
      (setq tmp-patterns nil))
    ;; 正規表現
    (when regexp-search
      (dolist (p (nreverse patterns))
        (push (list (list (copy-string "enable") (ggrep-get-setting-item p "enable"))
                    (list (copy-string "pattern")
                          (if (regexpp (ggrep-get-setting-item p "pattern"))
                              (ggrep-get-setting-item p "pattern")
                            (compile-regexp (ggrep-get-setting-item p "pattern")
                                            *ggrep-case-fold-search*)))
                    (list (copy-string "match") (ggrep-get-setting-item p "match")))
              tmp-patterns))
      (setq patterns tmp-patterns)
      (setq tmp-patterns nil))
    patterns))

(defun ggrep-dirs-normalization (dirs)
  (setq dirs (copy-tree dirs))
  (let (tmp-dirs)
    (if (stringp (car dirs))
        (setq dirs
              (mapcar #'(lambda (dir)
                          (list (list (copy-string "enable") t)
                                (list (copy-string "directory") dir)
                                (list (copy-string "subdir") nil)))
                      dirs)))
    (dolist (d (nreverse dirs))
      (if (and (eq (ggrep-get-setting-item d "enable") t)
               (string/= (ggrep-get-setting-item d "directory") ""))
          (if (string= (ggrep-get-setting-item d "directory") "<カレントディレクトリ>")
              (push (list (assoc "enable" d :test 'string=)
                          (list (copy-string "directory") (default-directory))
                          (assoc "subdir" d :test 'string=)) tmp-dirs)
            (push d tmp-dirs))))
    (setq dirs tmp-dirs)
    (setq tmp-dirs nil))
  dirs)

(defun ggrep-scan-files (patterns method file dirs &optional async target-list)
  (long-operation
    (setq patterns (ggrep-patterns-normalization
                    patterns
                    :regexp-search *ggrep-regexp-search*
                    :understand-escape-sequences nil))
    (setq dirs (ggrep-dirs-normalization dirs))
    (let ((buffer (get-buffer-create
                   (if *ggrep-contents-only*
                       *ggrep-contents-only-bufname*
                     "*ggrep*")))
          tmp-patterns)
      (when (save-excursion
              (set-buffer buffer)
              async-ggrep-timer-callback)
        (if (yes-or-no-p "ggrepはすでに動作中です。死なす?")
            (save-excursion
              (set-buffer buffer)
              (stop-async-ggrep))
          (quit)))
      (let ((temp (create-new-buffer "*ggrep temp*"))
            (scanner (ggrep-scanner patterns method *ggrep-case-fold-search*
                                    *ggrep-word-search*))); file に対しては syntax 指定なし
        (if async
            (ggrep-scan-files-async patterns buffer temp scanner file dirs target-list)
          (ggrep-scan-files-sync patterns buffer temp scanner file dirs target-list))))))

(defun ggrep1 (patterns method arg &key (regexp-search *ggrep-regexp-search*)
                                        (case-fold *ggrep-case-fold-search*)
                                        (word-search *ggrep-word-search*)
                                        (contents-only *ggrep-contents-only*)
                                        (syntax *ggrep-syntax*)
                                        name-only)
  "バッファ対象 ggrep 内部関数
arg: t                   : カレントバッファ
     nil                 : バッファリスト
     [対象バッファ or (list 対象バッファ 行番号リスト)] のリスト"
  (long-operation
    (let (buffer linenum-list work-arg
          contents-only-buffer contents-only-buffer-target-p
          contents-only-work-buffer)
      ;; パターンの標準化
      (setq patterns (ggrep-patterns-normalization
                      patterns
                      :regexp-search regexp-search
                      :understand-escape-sequences nil))
      ;; 検索バッファの標準化
      (cond
       ((eq arg t)
        (setq arg (list (selected-buffer))))
       ((null arg)
        (dolist (buffer (buffer-list))
          (unless (string-match "^ " (buffer-name buffer))
            (push buffer arg)))
        (setq arg (nreverse arg)))
       (t
        (setq work-arg nil)
        (dolist (target arg)
          (cond
           ((bufferp target)
            (push target work-arg))
           ((and (consp target) (bufferp (car target)))
            (push target work-arg))
           ((and (stringp target) (bufferp (setq buffer (find-buffer target))))
            (push buffer work-arg))
           ((and (consp target) (stringp (car target))
                 (bufferp (setq buffer (find-buffer (car target)))))
            (setq linenum-list (cadr target))
            (push (list buffer linenum-list) work-arg))
           (t
            (push target work-arg))))
        (setq arg (nreverse work-arg))))
      (unwind-protect
          (progn
            ;; *ggrep-contents-only-bufname* が検索バッファだった場合の救済措置
            (when (and contents-only
                       (setq contents-only-buffer (find-buffer *ggrep-contents-only-bufname*)))
              ;; 救済必要性の確認
              (dolist (target arg)
                (cond
                 ((bufferp target)
                  (setq buffer target))
                 ((and (consp target) (bufferp (car target)))
                  (setq buffer (car target))))
                (when (eq buffer contents-only-buffer)
                  (setq contents-only-buffer-target-p t)
                  (return)))
              (when contents-only-buffer-target-p
                ;; 代替のバッファの作成
                (setq contents-only-work-buffer (create-new-buffer " *ggrep work*"))
                (setup-temp-buffer contents-only-work-buffer)
                (save-excursion
                  (set-buffer contents-only-buffer)
                  (with-output-to-buffer (contents-only-work-buffer)
                    (format t "~A" (buffer-substring (point-min) (point-max)))))
                ;; 代替バッファへのターゲット変更
                (setq work-arg nil)
                (dolist (target arg)
                  (cond
                   ((bufferp target)
                    (if (eq target contents-only-buffer)
                        (push contents-only-work-buffer work-arg)
                      (push target work-arg)))
                   ((and (consp target) (bufferp (car target)))
                    (setq buffer (car target))
                    (setq linenum-list (cadr target))
                    (if (eq buffer contents-only-buffer)
                        (push (list contents-only-work-buffer linenum-list) work-arg)
                      (push target work-arg)))))
                (setq arg (nreverse work-arg))))

            (with-output-to-temp-buffer ((if contents-only
                                             *ggrep-contents-only-bufname*
                                           "*compilation*"))
              (let ((sbuffer (buffer-stream-buffer *standard-output*))
                    (scanner (ggrep-scanner patterns method case-fold word-search :syntax syntax)))
                (save-excursion
                  (set-buffer sbuffer)
                  (make-local-variable '*find-error-scanner*)
                  (setq *find-error-scanner* (ggrep-find-error-scanner))
                  (set-buffer-fold-width nil sbuffer)
                  (dolist (target arg)
                    (setq buffer nil
                          linenum-list nil)
                    (cond
                     ((bufferp target)
                      (setq buffer target))
                     ((and (consp target) (bufferp (car target)))
                      (setq buffer (car target))
                      (setq linenum-list (cadr target))))
                    (let ((bufname (buffer-name buffer)))
                      (unless (eq buffer sbuffer)
                        (message "Scanning (~A)" bufname)
                        (set-buffer buffer)
                        (save-excursion
                          (goto-char (point-min))
                          (cond (name-only ; linenum-list 無視
                                 (when (funcall scanner)
                                   (format t "<~A>~%" bufname)
                                   t))
                                (t
                                 (ggrep-scan-file (concatenate 'string "<" bufname ">")
                                                  scanner "" linenum-list)))))))))))
        (when contents-only-work-buffer
          (delete-buffer contents-only-work-buffer))))
    (run-hooks '*ggrep-hook*)
    (message "completed.")
    t))

(defun ggrep-narrow-buffer-list (&optional all)
  (let (narrow-buffer-list other-buffer-list)
    (save-excursion
      (dolist (buffer (buffer-list))
        (set-buffer buffer)
        (if (and ed::*find-error-scanner*
                 (string/= (buffer-name buffer) *ggrep-contents-only-bufname*))
            (push buffer narrow-buffer-list)
          (unless (string-match "^ " (buffer-name buffer))
            (push buffer other-buffer-list)))))
    (setq narrow-buffer-list (nreverse narrow-buffer-list))
    (when all
      (setq narrow-buffer-list
            (nconc narrow-buffer-list (nreverse other-buffer-list))))
    narrow-buffer-list))

(defun ggrep-get-buffer-list-by-buffer-regexp-list (buffer-regexp-list)
  (let (buffer-list)
    (dolist (buffer-regexp buffer-regexp-list)
      (when (ggrep-regexp-valid-p buffer-regexp)
        (unless (regexpp buffer-regexp)
          (setq buffer-regexp (compile-regexp buffer-regexp)))
        (dolist (buffer (buffer-list))
          (setq buffer-name (buffer-name buffer))
          (when (and (not (string-match "^ " buffer-name))
                     (string-match buffer-regexp buffer-name))
            (pushnew buffer buffer-list)))))
    (nreverse buffer-list)))

(defun ggrep-get-target-list (buffer &optional narrow-unit)
  "ggrep ターゲットリストを buffer から取得
戻り値: <TARGET-LIST>
  <TARGET-LIST>           ::= (<TARGET>*)
  <TARGET>                ::= <TARGETOBJ>
                            | (<TARGETOBJ> <LINENUM-LIST>)
  <TARGETOBJ>             ::= <BUFFER>
                            | <FILE-PATH>
  <LINENUM-LIST>          ::= (<LINENUM>*)"
  (when (and (bufferp buffer)
             (not (deleted-buffer-p buffer)))
    (let ((regexp (compile-regexp "^\\(.+?\\):\\([1-9][0-9]*\\):" t))
          default-directory target target-list targetstr pre-targetstr
          targetstr targetobj targetstr-and-linenum linenum linenum-list)
      (flet ((get-targetstr-and-linenum ()
               (when (scan-buffer "^." :regexp t)
                 (if (looking-at regexp)
                     (cons (match-string 1) (read-from-string (match-string 2)))
                   (cons (buffer-substring (point) (progn (goto-eol) (point))) nil)))))
        (save-excursion
          (set-buffer buffer)
          (setq default-directory (default-directory))
          (goto-char (point-min))
          ;; 毎行取得
          (while (and (setq targetstr-and-linenum (get-targetstr-and-linenum))
                      (setq targetstr (car targetstr-and-linenum))
                      (string/= targetstr ""))
            (if (not (eq narrow-unit :buffer))
                (setq linenum (cdr targetstr-and-linenum))
              (setq linenum nil))
            (if (string-not-equal targetstr pre-targetstr)
                ;; バッファ/ファイルが切り替わる場合
                (progn
                  ;; 1 行目でない場合
                  (when pre-targetstr
                    (if (string-match "^<\\(.+\\)>$" pre-targetstr)
                        (setq targetobj (find-buffer (match-string 1)))
                      (setq targetobj (merge-pathnames pre-targetstr default-directory)))
                    (when targetobj
                      (if linenum-list
                          (push (list targetobj (nreverse linenum-list)) target-list)
                        (push targetobj target-list))))
                  (setq pre-targetstr targetstr)
                  (setq targetstr nil)
                  (setq targetobj nil)
                  (setq linenum-list nil)
                  (when linenum
                    (push linenum linenum-list)))
              ;; 同一バッファ/ファイルの場合
              (when linenum
                (push linenum linenum-list)))
            (goto-eol)
            (forward-char))
          (when pre-targetstr
            (if (string-match "^<\\(.+\\)>$" pre-targetstr)
                (setq targetobj (find-buffer (match-string 1)))
              (setq targetobj (merge-pathnames pre-targetstr default-directory)))
            (when targetobj
              (if linenum-list
                  (push (list targetobj (nreverse linenum-list)) target-list)
                (push targetobj target-list))))
          (nreverse target-list))))))

(defun ggrep-regexp-valid-p (regexp)
  (cond
   ((regexpp regexp)
    t)
   ((and (stringp regexp)
         (or (string= regexp "")
             (handler-case
                 (compile-regexp regexp)
               (error (c) nil))))
    t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ggrep-read-patterns (&key command-name
                                 (patterns nil patterns-sv)
                                 (method nil method-sv)
                                 (regexp-search nil regexp-search-sv)
                                 (nomatch-search-use nil nomatch-search-use-sv)
                                 (default-pattern-support nil default-pattern-support-sv))
  "nomatch-search-use の値によって、返す patterns のフォーマットが変化する。
nomatch-search-use が nil の場合はシンプルな文字列のリストを返し、
non-nil の場合は \"enable\" \"pattern\" \"match\" の 3 要素からなる
項目のリストを返す。"
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))

  ;; method 指定
  (unless method-sv
    (let ((method-name-list (mapcar #'(lambda (m) (string-downcase (car m)))
                                    *ggrep-method-alist*)))
      (setq method
            (cdr (assoc
                  (completing-read
                   (format nil "~Amethod (~A): "
                           command-name
                           (subseq (format nil "~{ / ~A~}" method-name-list) 3))
                   method-name-list
                   :case-fold t
                   :default (string-downcase
                             (or (car (find *last-ggrep-method* *ggrep-method-alist* :key #'cdr))
                                 (caar *ggrep-method-alist*)))
                   :must-match t)
                  *ggrep-method-alist* :test #'string-equal)))))

  (unless patterns-sv
    (let ((i 1) match)
      ;; 正規表現 or 文字列 検索の選択
      (unless regexp-search-sv
        (setq regexp-search
              (string-equal
               "regexp"
               (completing-read
                (format nil "~Apattern-type (regexp / string): " command-name)
                '("regexp" "string")
                :default (if *ggrep-regexp-search* "regexp" "string")
                :case-fold t
                :must-match t))))
      ;; nomatch 検索を行うか
      (unless nomatch-search-use-sv
        (setq nomatch-search-use
              (string-equal
               "yes"
               (completing-read
                (format nil "~Ause nomatch-search? (yes / no): " command-name)
                '("yes" "no")
                :default "no"
                :case-fold t
                :must-match t))))
      ;; patterns 指定
      (setq match t)
      (loop
        (if nomatch-search-use
            (message "pattern(s)~A:~{ ~A~}"
                     (if method
                         (format nil " [~A]"
                                 (car (find method *ggrep-method-alist* :key #'cdr)))
                       "")
                     (mapcar #'(lambda (x)
                                 (format nil "(~S . ~S)"
                                         (cadr (assoc "pattern" x :test #'string=))
                                         (cadr (assoc "match" x :test #'string=))))
                             (reverse patterns)))
          (message "pattern(s)~A:~{ ~S~}"
                   (if method
                       (format nil " [~A]"
                               (car (find method *ggrep-method-alist* :key #'cdr)))
                     "")
                   (reverse patterns)))
        (setq pattern
              (if regexp-search
                  (read-string
                   (format nil "~A(~D)~A regexp: "
                           command-name i
                           (if method
                               (format nil " [~A]"
                                       (car (find method *ggrep-method-alist* :key #'cdr)))
                             ""))
                   :default (when default-pattern-support
                              (let ((regexp (nth (1- i) *last-ggrep-regexp-list*)))
                                (when (listp regexp)
                                  (setq regexp (cadr (assoc "pattern" regexp :test #'string=))))
                                (cond ((regexpp regexp)
                                       (compiled-regexp-source regexp))
                                      ((stringp regexp)
                                       regexp)
                                      (t
                                       ""))))
                   :history 'search)
                (read-string
                 (format nil "~A(~D)~A string: "
                         command-name i
                         (if method
                             (format nil " [~A]"
                                     (car (find method *ggrep-method-alist* :key #'cdr)))
                           ""))
                 :default (when default-pattern-support
                            (let ((string (nth (1- i) *last-fggrep-pattern-list*)))
                              (when (listp string)
                                (setq string (cadr (assoc "pattern" string :test #'string=))))
                              (if (stringp string)
                                  string "")))
                 :history 'search)))
        (cond
         ((string= pattern "")
          (return))
         ((and regexp-search (not (ggrep-regexp-valid-p pattern)))
          (message "pattern invalid regexp: ~A" pattern)
          (sleep-for 1))
         (t
          (if nomatch-search-use
              (progn
                (setq match
                      (string-equal
                       "match"
                       (completing-read
                        (format nil "~A(~D) [~A] (match / nomatch): "
                                command-name i pattern)
                        '("match" "nomatch")
                        :default (if match "match" "nomatch")
                        :case-fold t
                        :must-match t)))
                (push (list (list "enable" t)
                            (list "pattern" pattern)
                            (list "match" match))
                      patterns))
            (push pattern patterns))
          (incf i))))
      (setq patterns (nreverse patterns))))
  (values patterns method regexp-search nomatch-search-use))

(defun ggrep-read-dirs (&key command-name
                             (dirs nil dirs-sv)
                             (files nil files-sv)
                             (subdir-constant nil subdir-constant-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))

  (let (dir subdir (i 1))
    (unless dirs-sv
      (setq dir (default-directory))
      (setq subdir *ggrep-subdir-default*)
      (loop
        (setq dir
              (read-directory-name
               (format nil "~A(~D) directory: " command-name i)
               :default (append-trail-slash dir)))
        ;; (read-directory-name) では空文字列が入力された場合、
        ;; (default-directory) ? の入力と判断され、空文字列が入力されたことは
        ;; 認識できない。
        (if subdir-constant-sv
            (setq subdir subdir-constant-sv)
          (setq subdir
                (string-equal
                 "yes"
                 (completing-read
                  (format nil "~A(~D) [~A] subdir? (yes / no): "
                          command-name i (append-trail-slash dir))
                  '("yes" "no")
                  :default (if subdir "yes" "no")
                  :case-fold t
                  :must-match t))))
        (push (list (list "enable" t)
                    (list "directory" dir)
                    (list "subdir" subdir))
              dirs)
        (unless (string-equal
                 "yes"
                 (completing-read
                  (format nil "~Adirectory add? (yes / no): " command-name)
                  '("yes" "no")
                  :default "yes"
                  :case-fold t
                  :must-match t))
          (return))
        (incf i))
      (setq dirs (nreverse dirs)))
    (unless files-sv
      (setq files (read-string
                   (format nil "~Afiles: " command-name))))
    (unless files
      (setq files ""))
    (values dirs files)))

(defun ggrep-read-file-list (&key command-name
                                  (file-list nil file-list-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  ;;
  (let ((i 1) (dir (default-directory)) file)
    (unless file-list-sv
      (loop
        (setq file
              (read-file-name
               (format nil "~A(~D) file: " command-name i)
               :default (append-trail-slash dir)))
        (setq dir (directory-namestring file))
        ;; (read-file-name) では空文字列入力不可
        (pushnew file file-list :test #'string-equal)
        (unless (string-equal
                 "yes"
                 (completing-read
                  (format nil "~Afile add? (yes / no): " command-name)
                  '("yes" "no")
                  :default "yes"
                  :case-fold t
                  :must-match t))
          (return))
        (incf i))
      (setq file-list (nreverse file-list)))
    file-list))

(defun ggrep-read-buffer-list (&key command-name
                                    (buffer-list nil buffer-list-sv)
                                    (output-name t output-name-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  ;;
  (let ((i 1) buffer-name buffer-name-list)
    (unless buffer-list-sv
      (dolist (buffer (buffer-list))
        (unless (string-match "^ " (buffer-name buffer))
          (push (buffer-name buffer) buffer-name-list)))
      (while buffer-name-list
        (message "target buffer(s):~{ \"~A\"~}"
                 (mapcar #'buffer-name (reverse buffer-list)))
        (setq buffer-name
              (completing-read
               (format nil "~A(~D) buffer: " command-name i)
               buffer-name-list
               :default (if (member (buffer-name (selected-buffer)) buffer-name-list
                                    :test #'string=)
                            (buffer-name (selected-buffer)) "")))
        (when (string= buffer-name "")
          (return))
        (when (find-buffer buffer-name)
          (push (find-buffer buffer-name) buffer-list))
        (setq buffer-name-list
              (delete buffer-name buffer-name-list :test #'string=))
        (incf i))
      (setq buffer-list (nreverse buffer-list))))
  (when (and output-name (listp buffer-list))
    (setq buffer-list (mapcar #'(lambda (x) (if (bufferp x) (buffer-name x) x))
                              buffer-list)))
  buffer-list)

(defun ggrep-read-narrow (&key command-name
                               (narrow-buffer nil narrow-buffer-sv)
                               (narrow-unit nil narrow-unit-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  ;;
  (unless narrow-buffer-sv
    (setq narrow-buffer
          (completing-read
           (format nil "~Anarrow buffer: " command-name)
           (mapcar #'buffer-name (ggrep-narrow-buffer-list))
           :default (buffer-name (selected-buffer)))))
  (unless narrow-unit-sv
    (setq narrow-unit
          (if (string-equal
               "line"
               (completing-read
                (format nil "~Anarrow unit (line / buffer(file)): " command-name)
                '("line" "buffer")
                :default (if (not (eq *ggrep-narrow-buffer* :buffer))
                             "line" "buffer")
                :must-match t))
              :line nil)))
  (when (stringp narrow-buffer)
    (setq narrow-buffer (find-buffer narrow-buffer)))
  (values narrow-buffer narrow-unit))

(defun ggrep-read-buffer-regexp-list (&key command-name
                                           (buffer-regexp-list nil buffer-regexp-list-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  ;;
  (let ((i 1) buffer-list buffer-regexp buffer-name)
    (if buffer-regexp-list-sv
        (setq buffer-list
              (ggrep-get-buffer-list-by-buffer-regexp-list buffer-regexp-list))
      (progn
        (loop
          (message "target buffer(s):~{ \"~A\"~}"
                   (mapcar #'buffer-name (reverse buffer-list)))
          (setq buffer-regexp
                (read-string
                 (format nil "~A(~D) buffer-regexp: " command-name i)))
          (when (string= buffer-regexp "")
            (return))
          (when (ggrep-regexp-valid-p buffer-regexp)
            (pushnew buffer-regexp buffer-regexp-list :test #'string=)
            (setq buffer-regexp (compile-regexp buffer-regexp))
            (dolist (buffer (buffer-list))
              (setq buffer-name (buffer-name buffer))
              (when (and (not (string-match "^ " buffer-name))
                         (string-match buffer-regexp buffer-name))
                (pushnew buffer buffer-list))))
          (incf i))
        (setq buffer-regexp-list (nreverse buffer-regexp-list))
        (setq buffer-list (nreverse buffer-list))))
    (values buffer-regexp-list buffer-list)))

(defun ggrep-read-encoding-name (&key command-name
                                      (encoding-name nil encoding-name-sv)
                                      (encoding-check-file nil encoding-check-file-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  ;;
  (let ((encoding-name-list (mapcar 'char-encoding-name *char-encoding-list*)))
    (unless encoding-name-sv
      (setq encoding-name
            (completing-read
             (format nil "~Aencoding: " command-name)
             encoding-name-list
             :case-fold nil
             :default (if (char-encoding-p *expected-fileio-encoding*)
                          (char-encoding-name *expected-fileio-encoding*) "")
             :must-match t)))
    (unless (find encoding-name encoding-name-list :test #'string=)
      (setq encoding-name nil))
    ;; encoding-check-file
    (unless encoding-check-file-sv
      (when encoding-name
        (setq encoding-check-file
              (string-equal
               "yes"
               (completing-read
                (format nil "~Ascan files on the disk (not on buffers)? (yes / no): " command-name)
                '("yes" "no")
                :case-fold t
                :default (if *ggrep-encoding-check-file* "yes" "no")
                :must-match t)))))
    (values encoding-name encoding-check-file)))

(defun ggrep-read-syntax (&key command-name
                               (syntax nil syntax-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))
  (let ((syntax-symbol-alist '((:string  . "string")
                               (:comment . "comment")
                               (:tag     . "tag")
                               (nil      . "misc")))
        syntax-name)
    (unless syntax-sv
      (if (string-equal
           "yes"
           (completing-read
            (format nil "~Aall syntax? (yes / no): " command-name)
            '("yes" "no")
            :default "yes"
            :case-fold t
            :must-match t))
          (setq syntax t)
        (dolist (x syntax-symbol-alist)
          (message "syntax(s):~{ \"~A\"~}" (reverse syntax))
          (if (string-equal
               "yes"
               (completing-read
                (format nil "~A~A syntax: " command-name (cdr x))
                '("yes" "no")
                :default "yes"
                :case-fold t
                :must-match t))
              (push (car x) syntax)))))
    syntax))

(defun ggrep-read-others (&key command-name
                               (case-fold *ggrep-case-fold-search* case-fold-sv)
                               (word-search *ggrep-word-search* word-search-sv)
                               (async *ggrep-async* async-sv)
                               (contents-only *ggrep-contents-only* contents-only-sv)
                               (name-only *ggrep-name-only* name-only-sv)
                               (full-name *ggrep-full-name* full-name-sv)
                               ;; --- 判定用変数 ---
                               (regexp-search nil regexp-search-sv)
                               (buffer-only-p nil buffer-only-p-sv))
  ;; command-name
  (if (not (stringp command-name))
      (setq command-name "")
    (unless (string-match " $" command-name)
      (setq command-name (concat command-name " "))))

  ;; case-fold
  (unless case-fold-sv
    (setq case-fold
          (completing-read
           (format nil "~Acase-fold (yes / no / smart): " command-name)
           '("yes" "no" "smart")
           :case-fold t
           :default (cond ((eq *ggrep-case-fold-search* :smart) "smart")
                          (*ggrep-case-fold-search*             "yes")
                          (t                                    "no"))
           :must-match t))
    (cond
     ((string-equal case-fold "yes")
      (setq case-fold t))
     ((string-equal case-fold "no")
      (setq case-fold nil))
     (t
      (setq case-fold :smart))))
  ;; word-search
  (if regexp-search
      (setq word-search nil)
    (unless word-search-sv
      (setq word-search
            (string-equal
             "yes"
             (completing-read
              (format nil "~Aword-search (yes / no): " command-name)
              '("yes" "no")
              :case-fold t
              :default (if *ggrep-word-search* "yes" "no")
              :must-match t)))))
  ;; async
  (unless async-sv
    (unless buffer-only-p
      (setq async
            (string-equal
             "yes"
             (completing-read
              (format nil "~Aasync (yes / no): " command-name)
              '("yes" "no")
              :case-fold t
              :default (if *ggrep-async* "yes" "no")
              :must-match t)))))
  ;; contents-only
  (unless contents-only-sv
    (setq contents-only
          (string-equal
           "yes"
           (completing-read
            (format nil "~Acontents-only (yes / no): " command-name)
            '("yes" "no")
            :case-fold t
            :default (if *ggrep-contents-only* "yes" "no")
            :must-match t))))
  ;; name-only
  (unless contents-only
    (unless name-only-sv
      (setq name-only
            (string-equal
             "yes"
             (completing-read
              (format nil "~Aname-only (yes / no): " command-name)
              '("yes" "no")
              :case-fold t
              :default (if *ggrep-name-only* "yes" "no")
              :must-match t)))))
  ;; full-name
  (unless contents-only
    (unless full-name-sv
      (unless buffer-only-p
        (setq full-name
              (string-equal
               "yes"
               (completing-read
                (format nil "~Afull-name (yes / no): " command-name)
                '("yes" "no")
                :case-fold t
                :default (if *ggrep-full-name* "yes" "no")
                :must-match t))))))
  (values case-fold word-search async contents-only name-only full-name))

(defun ggrep-internal (&key
                       ;; ---------- 検索パターン ----------
                       (method nil method-sv)
                       (patterns nil patterns-sv)
                       (regexp-search *ggrep-regexp-search* regexp-search-sv)
                       ;; ---------- 検索対象 ----------
                       ; 1. 任意の検索対象指定が可能
                       (target-list nil target-list-sv)
                       ; 2. 絞込み対象バッファ & 絞込み単位
                       (narrow-buffer nil narrow-buffer-sv)
                       (narrow-unit nil narrow-unit-sv)
                       ; 3. バッファ直接指定 (t, nil, buffer-list)
                       (buffer-list nil buffer-list-sv)
                       ; 4. バッファ正規表現指定
                       (buffer-regexp-list nil buffer-regexp-list-sv)
                       ; 5. ファイル直接指定
                       (file-list nil file-list-sv)
                       ; 6. ディレクトリ名 & ファイル名パターン
                       (dirs nil dirs-sv)
                       (files nil files-sv)
                       ;; ----------
                       (encoding-name nil encoding-name-sv)
                       (encoding-check-file nil encoding-check-file-sv)
                       (syntax t syntax-sv)
                       (case-fold *ggrep-case-fold-search* case-fold-sv)
                       (word-search *ggrep-word-search* word-search-sv)
                       (async *ggrep-async* async-sv)
                       (contents-only *ggrep-contents-only* contents-only-sv)
                       (name-only *ggrep-name-only* name-only-sv)
                       (full-name *ggrep-full-name* full-name-sv))
  "引数優先順位
target-list   指定時: files, dirs, buffer-list, narrow-buffer, narrow-unit 無効
narrow-buffer 指定時: files, dirs, buffer-list 無効
buffer-list   指定時: files, dirs 無効

history 変数への値保存は行わないため、保存すべき値は呼び出し元で保存する。"
  (let (args target-type buffer-only-p)
    ;; ------------------------------------------------------------
    ;; 検索対象判定
    (cond
     (target-list-sv
      (setq target-type "<target-list>"))
     (narrow-buffer-sv
      (setq target-type "narrow"))
     (buffer-list-sv
      (setq target-type "buffer"))
     (buffer-regexp-list-sv
      (setq target-type "buffer-regexp"))
     (file-list-sv
      (setq target-type "file"))
     (dirs-sv
      (setq target-type "dir")))

    ;; 検索対象指定から具体的な対象の特定
    (cond
     ;; 複数バッファ指定 -> buffer-list
     ((string= target-type "buffer"))
     ;; 全バッファ指定 -> buffer-list
     ((string= target-type "all-buffers"))
     ;; バッファ正規表現指定 -> buffer-list
     ((string-equal target-type "buffer-regexp")
      (setq buffer-list
            (ggrep-get-buffer-list-by-buffer-regexp-list buffer-regexp-list)))
     ;; ディレクトリ指定 -> dirs, files
     ((string-equal target-type "dir"))
     ;; 複数ファイル指定 -> file-list
     ((string-equal target-type "file"))
     ;; 絞込み検索 -> target-list
     ((string-equal target-type "narrow")
      (setq target-list
            (ggrep-get-target-list narrow-buffer narrow-unit))))

    ;; 検索対象が buffer のみであるか否かチェック
    (cond
     ((or target-list-sv target-list)
      (unless (find-if-not #'(lambda (x)
                               (or (bufferp x)
                                   (and (stringp x) (find-buffer x))))
                           target-list
                           :key #'(lambda (target)
                                    (if (listp target) (car target) target)))
        (setq buffer-only-p t)))
     ((or buffer-list-sv buffer-list)
      (setq buffer-only-p t)))

    ;; buffer/file での切り替え
    (let ((*ggrep-regexp-search* regexp-search)
          (*ggrep-case-fold-search* case-fold)
          (*ggrep-word-search* word-search)
          (*ggrep-async* async)
          (*ggrep-contents-only* contents-only)
          (*ggrep-name-only* name-only)
          (*ggrep-full-name* full-name)
          (*ggrep-encoding-name* encoding-name)
          (*ggrep-encoding-check-file* encoding-check-file)
          (*ggrep-syntax* syntax))
      (cond
       ((or target-list-sv target-list)
        (if buffer-only-p
            (ggrep1 patterns method target-list
                    :regexp-search regexp-search
                    :case-fold case-fold
                    :word-search word-search
                    :name-only name-only
                    :contents-only contents-only
                    :syntax syntax)
          (ggrep-scan-files patterns method nil nil async target-list)))
       ((or buffer-list-sv buffer-list)
        (ggrep1 patterns method buffer-list
                :regexp-search regexp-search
                :case-fold case-fold
                :word-search word-search
                :name-only name-only
                :contents-only contents-only
                :syntax syntax))
       ((or file-list-sv file-list)
        (ggrep-scan-files patterns method nil nil async file-list))
       ((or dirs-sv dirs)
        (ggrep-scan-files patterns method
                          (split-string files #\; t " ")
                          dirs async nil))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ggrep-get-setting-item (setting name &optional default)
  (let (lst)
    (if (setq lst (assoc name setting :test 'string=))
        (cadr lst)
      default)))
(defun ggrep-load-setting (setting)
  (setq *ggrep-method* (ggrep-get-setting-item setting "method"))
  (setq *ggrep-patterns* (ggrep-get-setting-item setting "patterns"))
  (setq *ggrep-select-target-method*
        (ggrep-get-setting-item setting "select-target-method"))
  (setq *ggrep-target-type* (ggrep-get-setting-item setting "target-type"))
  (setq *ggrep-directories* (ggrep-get-setting-item setting "directories"))
  (setq *ggrep-file* (ggrep-get-setting-item setting "file" "*"))
  (setq *ggrep-buffer* (ggrep-get-setting-item setting "buffer" "<カレントバッファ>"))
  (setq *ggrep-narrow-buffer* (ggrep-get-setting-item setting "narrow-buffer" ""))
  (setq *ggrep-narrow-unit* (ggrep-get-setting-item setting "narrow-unit"))
  (setq *ggrep-file-list* (ggrep-get-setting-item setting "file-list"))
  (setq *ggrep-buffer-regexp-list* (ggrep-get-setting-item setting "buffer-regexp-list"))
  (setq *ggrep-encoding-name* (ggrep-get-setting-item setting "encoding-name"))
  (setq *ggrep-encoding-check-file*
        (ggrep-get-setting-item setting "encoding-check-file"))
  (setq *ggrep-syntax* (ggrep-get-setting-item setting "syntax" t))
  (setq *ggrep-case-fold-search*
        (ggrep-get-setting-item setting "case-fold-search"))
  (setq *ggrep-word-search* (ggrep-get-setting-item setting "word-search"))
  (setq *ggrep-regexp-search* (ggrep-get-setting-item setting "regexp-search"))
  (setq *ggrep-understand-escape-sequences*
        (ggrep-get-setting-item setting "understand-escape-sequences"))
  (setq *ggrep-async* (ggrep-get-setting-item setting "async"))
  (setq *ggrep-contents-only* (ggrep-get-setting-item setting "contents-only"))
  (setq *ggrep-name-only* (ggrep-get-setting-item setting "name-only"))
  (setq *ggrep-full-name* (ggrep-get-setting-item setting "full-name"))
  (setq *ggrep-dialog-number-of-pattern*
        (ggrep-get-setting-item setting "dialog-number-of-pattern"
                                *ggrep-dialog-number-of-pattern*))
  (setq *ggrep-dialog-number-of-dir*
        (ggrep-get-setting-item setting "dialog-number-of-dir"
                                *ggrep-dialog-number-of-dir*))
  nil)
(defun ggrep-make-setting ()
  (list (list "method" *ggrep-method*)
        (list "patterns" *ggrep-patterns*)
        (list "select-target-method" *ggrep-select-target-method*)
        (list "target-type" *ggrep-target-type*)
        (list "directories" *ggrep-directories*)
        (list "file" *ggrep-file*)
        (list "buffer" *ggrep-buffer*)
        (list "narrow-buffer" *ggrep-narrow-buffer*)
        (list "narrow-unit" *ggrep-narrow-unit*)
        (list "file-list" *ggrep-file-list*)
        (list "buffer-regexp-list" *ggrep-buffer-regexp-list*)
        (list "encoding-name" *ggrep-encoding-name*)
        (list "encoding-check-file" *ggrep-encoding-check-file*)
        (list "syntax" *ggrep-syntax*)
        (list "case-fold-search" *ggrep-case-fold-search*)
        (list "word-search" *ggrep-word-search*)
        (list "regexp-search" *ggrep-regexp-search*)
        (list "understand-escape-sequences" *ggrep-understand-escape-sequences*)
        (list "async" *ggrep-async*)
        (list "contents-only" *ggrep-contents-only*)
        (list "name-only" *ggrep-name-only*)
        (list "full-name" *ggrep-full-name*)
        (list "dialog-number-of-pattern" *ggrep-dialog-number-of-pattern*)
        (list "dialog-number-of-dir" *ggrep-dialog-number-of-dir*)))

; &A : 非同期でggrep
; &B : 検索バッファ
; &C : 大文字小文字を区別する
; &D : ディレクトリ数
; &E : 正規表現
; &F : ファイル名
; &G : 絞込み単位: 行
; &H : 絞込み単位: バッファ/ファイル
; &I : 含む
; &J : 含まない
; &K : 指定切替
; &L : リスト取得
; &M : 検索方法
; &N : 絞込み検索対象バッファ
; &O : ファイル名だけ出力
; &P : パターン数
; &Q : エンコード
; &R : 読み込み済みファイルも指定エンコードで
; &S : 検索
; &T : 設定
; &U : フルパス名で出力
; &V : コンテンツのみ出力
; &W : 単語単位で検索する
; &X : クリア
; &Y : エスケープシーケンスを理解しろ
; &Z : 適用

; &1-&9 : それぞれパターン、ディレクトリへ

; &! : 
; &" :
; &# :
; &$ :
; &% :
; && :
; &' :
; &( :
; &) :
; &* : シンタックス
; &+ :
; &, :
; &- :
; &. :
; &/ :
; &: :
; &; :
; &< : 検索対象：ファイル
; &= : 検索対象：絞込み
; &> : 検索対象：バッファ
; &? :
; &@ :
; &{ :
; &| :
; &} :
; &~ :

; TAB : 移動
; C-g : キャンセル
; ESC : キャンセル

(defun ggrep-dialog (&key (setting nil sv-setting) history-name history-no-load)
  (interactive)
  (let* (dialog-template
         number-of-pattern number-of-dir
         dialog-base-x dialog-x dialog-base-y dialog-y
         controls controls-initializers controls-handlers
         patenable-symbol-list pattern-symbol-list
         match-symbol-list nomatch-symbol-list
         direnable-symbol-list dir-symbol-list refdir-symbol-list
         subdir-symbol-list
         (method-symbol-list (mapcar 'cdr *ggrep-method-alist*))
         (method-display-name-list (mapcar 'car *ggrep-method-alist*))
         (grep-narrow-buffer-list
          (append '("<カレントバッファ>")
                  (mapcar 'buffer-name (ggrep-narrow-buffer-list))))
         (char-encoding-display-name-list
          (append '("共通設定エンコーディング")
                  (mapcar 'char-encoding-display-name *char-encoding-list*)))
         (char-encoding-name-list
          (append '("") (mapcar 'char-encoding-name *char-encoding-list*)))
         history
         (history-name-list (mapcar
                             #'(lambda (h)
                                 (ggrep-get-setting-item h "history-name"))
                             *ggrep-setting-history*)))
    (let (pos)
      (if (and (stringp history-name)
               (setq pos (position history-name *ggrep-setting-history*
                                   :key #'(lambda (h) (ggrep-get-setting-item h "history-name"))
                                   :test 'equal)))
          (if history-no-load
              (setq setting *last-ggrep-setting*)
            (setq setting (ggrep-get-setting-item
                           (nth pos *ggrep-setting-history*) "setting")))
        (progn
          (setq history-name nil)
          (if (and (null setting) (not sv-setting))
              (setq setting *last-ggrep-setting*)))))
    (ggrep-load-setting setting)
    (setq number-of-pattern (max *ggrep-dialog-number-of-pattern-min*
                                 (if (and (numberp *ggrep-dialog-number-of-pattern*)
                                          (integerp *ggrep-dialog-number-of-pattern*)
                                          (plusp *ggrep-dialog-number-of-pattern*))
                                     *ggrep-dialog-number-of-pattern* 0)))
    (setq number-of-dir (max *ggrep-dialog-number-of-dir-min*
                             (if (and (numberp *ggrep-dialog-number-of-dir*)
                                      (integerp *ggrep-dialog-number-of-dir*)
                                      (plusp *ggrep-dialog-number-of-dir*))
                                 *ggrep-dialog-number-of-dir* 0)))

    ;; ------------------------------------------------------------
    ;; dialog-base-x, dialog-base-y はフレームの座標
    ;; ------------------------------------------------------------
    ;; 検索方法 (AND/OR)
    (setq dialog-base-x 2)
    (setq dialog-base-y 0)
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)

    (push `(:button nil "" #x50020007
            ,dialog-x ,dialog-y 92 ,(+ 20 (* 14 number-of-pattern))) controls)
    (incf dialog-y 7)
    (push `(:static nil "検索方法(&M)" #x50020001
            ,(+ dialog-x 4) ,dialog-y 80 8) controls)
    (incf dialog-y 10)
    (push `(:combobox method nil #x50210003
            ,(+ dialog-x 4) ,dialog-y 84 48) controls)
    ;; ------------------------------------------------------------
    ;; 検索パターン
    (setq dialog-base-x 96)
    (setq dialog-base-y 0)
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)
    (push `(:button nil "" #x50020007
            ,dialog-x ,dialog-y 222 ,(+ 20 (* 14 number-of-pattern))) controls)

    (incf dialog-y 7)
    (push `(:static nil "有効"         #x50020001
            ,(+ dialog-x 12) ,dialog-y 16 8) controls)
    (push `(:static nil "パターン"     #x50020001
            ,(+ dialog-x 28) ,dialog-y 140 8) controls)
    (push `(:static nil "含む"         #x50020001
            ,(+ dialog-x 172) ,dialog-y 14 8) controls)
    (push `(:static nil "/"            #x50020001
            ,(+ dialog-x 186) ,dialog-y 4 8) controls)
    (push `(:static nil "含まない"     #x50020001
            ,(+ dialog-x 190) ,dialog-y 26 8) controls)

    (dotimes (i number-of-pattern)
      (push (make-symbol (concat "patenable" (format nil "~D" i))) patenable-symbol-list)
      (push (make-symbol (concat "pattern" (format nil "~D" i))) pattern-symbol-list)
      (push (make-symbol (concat "match" (format nil "~D" i))) match-symbol-list)
      (push (make-symbol (concat "nomatch" (format nil "~D" i))) nomatch-symbol-list))
    (setq patenable-symbol-list (nreverse patenable-symbol-list))
    (setq pattern-symbol-list (nreverse pattern-symbol-list))
    (setq match-symbol-list (nreverse match-symbol-list))
    (setq nomatch-symbol-list (nreverse nomatch-symbol-list))

    (setq dialog-y (+ dialog-base-y 16))
    (dotimes (i number-of-pattern)
      (if (< i 9)
          (push `(:static nil ,(format nil "&~D:" (1+ i)) #x50020002
                  ,(+ dialog-x 5) ,(+ dialog-y 3) 8 8) controls)
        (push `(:static nil ,(multiple-value-bind (dec num)
                                 (floor (1+ i) 10)
                               (format nil "~D&~D:" dec num)) #x50020002
                ,(+ dialog-x 5) ,(+ dialog-y 3) 8 8) controls))

      (push `(:button ,(elt patenable-symbol-list i) nil #x50010003
              ,(+ dialog-x 16) ,dialog-y 8 14) controls)
      (push `(:combobox ,(elt pattern-symbol-list i) nil  #x50210842
              ,(+ dialog-x 28) ,dialog-y 140 96) controls)

      (push `(:button ,(elt match-symbol-list i) "(&I)" #x50000009
              ,(+ dialog-x 175) ,(+ dialog-y 2) 20 12) controls)
      (push `(:button ,(elt nomatch-symbol-list i) "(&J)" #x50000009
              ,(+ dialog-x 196) ,(+ dialog-y 2) 20 12) controls)
      (incf dialog-y 14))

    ;; ------------------------------------------------------------
    ;; 検索対象分類
    (setq dialog-base-x 2)
    (setq dialog-base-y (+ 20 (* 14 number-of-pattern)))
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)
    (push `(:button nil "" #x50020007
            ,dialog-x ,dialog-y 92 ,(+ 38 (* 14 number-of-dir) 24 36)) controls)
    (incf dialog-y 7)
    (push `(:static nil "検索対象" #x50020001
            ,(+ dialog-x 4) ,dialog-y 80 8) controls)
    (incf dialog-y 10)
    (push `(:button grep-target-file "ファイル(&<)"
            ,(if (eq *ggrep-select-target-method* 'buffer-list) #x58000009 #x50000009)
            ,(+ dialog-x 8) ,dialog-y 48 10) controls)
    (incf dialog-y 14)
    (push `(:button grep-target-buffer "バッファ(&>)"
            ,(if (eq *ggrep-select-target-method* 'file-list) #x58000009 #x50000009)
            ,(+ dialog-x 8) ,dialog-y 48 10) controls)
    (incf dialog-y 14)
    (push `(:button grep-target-narrow "絞込み(&=)"
            ,(if (not (member *ggrep-select-target-method* '(file-list buffer-list)))
                 #x50000009 #x58000009)
            ,(+ dialog-x 8) ,dialog-y 48 10) controls)

    (incf dialog-x 4)
    (incf dialog-y 20)
    (push `(:static nil "「ファイル」「絞込み(ファイル)」ではエンコード指定が可能" #x50000000
            ,dialog-x ,dialog-y 86 16) controls)
    (incf dialog-y 26)
    (push `(:static nil "「バッファ」「絞込み(バッファ)」ではシンタックス指定が可能" #x50000000
            ,dialog-x ,dialog-y 86 16) controls)


    ;; ------------------------------------------------------------
    (setq dialog-base-x 96)
;    (setq dialog-base-y (+ 20 (* 14 number-of-pattern)))
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)

    ;; frame
    (if (or (eq *ggrep-select-target-method* 'file-list)
            (eq *ggrep-select-target-method* 'buffer-list))
        (push `(:button target-frame "" #x50020007
                ,dialog-x ,dialog-y 222 ,(+ 38 (* 14 number-of-dir) 24 36)) controls)
      (push `(:button target-frame "" #x50020007
              ,dialog-x ,dialog-y 222 ,(+ 38 (* 14 number-of-dir))) controls))

    (cond
     ;; ---
     ;; ファイルリスト指定
     ((eq *ggrep-select-target-method* 'file-list)
      (incf dialog-y 7)
      (push `(:static nil "ファイルリスト指定 (フルパス)" #x50020001
              ,(+ dialog-x 12) ,dialog-y 156 8) controls)
      (incf dialog-y 9)
      (push `(:edit target-list nil #x50a110c4
              ,(+ dialog-x 8) ,dialog-y 160 ,(+ 16 (* number-of-dir 14) 24 36)) controls)
      (incf dialog-y (* number-of-dir 14))
      (push `(:button get-file-list "リスト取得(&L)" #x50010000
              ,(+ dialog-x 172) ,(- dialog-y 12) 44 13) controls)
      (incf dialog-y 2)
      (push `(:button change-select-target-method "指定切替(&K)" #x50010000
              ,(+ dialog-x 172) ,dialog-y 44 14) controls))
     ;; ---
     ;; バッファリスト指定
     ((eq *ggrep-select-target-method* 'buffer-list)
      (incf dialog-y 7)
      (push `(:static nil "バッファリスト指定 (正規表現)" #x50020001
              ,(+ dialog-x 12) ,dialog-y 156 8) controls)
      (incf dialog-y 9)
      (push `(:edit target-list nil #x50a110c4
              ,(+ dialog-x 8) ,dialog-y 160 ,(+ 16 (* number-of-dir 14) 24 36)) controls)
      (incf dialog-y (* number-of-dir 14))
      (push `(:button get-buffer-list "リスト取得(&L)" #x50010000
              ,(+ dialog-x 172) ,(- dialog-y 12) 44 13) controls)
      (incf dialog-y 2)
      (push `(:button change-select-target-method "指定切替(&K)" #x50010000
              ,(+ dialog-x 172) ,dialog-y 44 14) controls))
     ;; ---
     ;; ディレクトリ指定
     (t
      (dotimes (i number-of-dir)
        (push (make-symbol (concat "direnable" (format nil "~D" i))) direnable-symbol-list)
        (push (make-symbol (concat "dir" (format nil "~D" i))) dir-symbol-list)
        (push (make-symbol (concat "refdir" (format nil "~D" i))) refdir-symbol-list)
        (push (make-symbol (concat "subdir" (format nil "~D" i))) subdir-symbol-list))
      (setq direnable-symbol-list (nreverse direnable-symbol-list))
      (setq dir-symbol-list (nreverse dir-symbol-list))
      (setq refdir-symbol-list (nreverse refdir-symbol-list))
      (setq subdir-symbol-list (nreverse subdir-symbol-list))

      (incf dialog-y 7)
      (push `(:static nil "有効" #x50020001
              ,(+ dialog-x 12) ,dialog-y 16 8) controls)
      (push `(:static nil "ディレクトリ" #x50020001
              ,(+ dialog-x 28) ,dialog-y 140 8) controls)
      (push `(:static nil "サブディレクトリ" #x50020001
              ,(+ dialog-x 178) ,dialog-y 40 8) controls)

      (incf dialog-y 9)
      (dotimes (i number-of-dir)
        (if (< i 9)
            (push `(:static nil ,(format nil "&~D:" (1+ i)) #x50020002
                    ,(+ dialog-x 5) ,(+ dialog-y 3) 8 8) controls)
          (push `(:static nil ,(multiple-value-bind (dec num)
                                   (floor (1+ i) 10)
                                 (format nil "~D&~D:" dec num)) #x50020002
                  ,(+ dialog-x 5) ,(+ dialog-y 3) 8 8) controls))

        (push `(:button ,(elt direnable-symbol-list i) nil #x50010003
                ,(+ dialog-x 16) ,dialog-y 8 14) controls)
        (push `(:combobox ,(elt dir-symbol-list i) nil  #x50210842
                ,(+ dialog-x 28) ,dialog-y 140 96) controls)
        (push `(:button ,(elt refdir-symbol-list i) "参照..." #x50010000
                ,(+ dialog-x 172) ,dialog-y 22 14) controls)
        (push `(:button ,(elt subdir-symbol-list i) nil #x50010003
                ,(+ dialog-x 198) ,dialog-y 8 14) controls)
        (incf dialog-y 14))

      (incf dialog-y 2)
      (push `(:static nil "ファイル名(&F):" #x50020000
              ,(+ dialog-x 7) ,(+ dialog-y 2) 38 8) controls)
      (push `(:combobox file nil  #x50210842
              ,(+ dialog-x 44) ,dialog-y 124 96) controls)
      (push `(:button change-select-target-method "指定切替(&K)" #x50010000
              ,(+ dialog-x 172) ,dialog-y 44 14) controls)))

    ;; ------------------------------------------------------------
    (if (or (eq *ggrep-select-target-method* 'file-list)
            (eq *ggrep-select-target-method* 'buffer-list))
        (progn
          (incf dialog-base-y (+ 38 (* 14 number-of-dir)))
          (incf dialog-base-y 24))
      (progn
        ;; ------------------------------------------------------------
        ;; バッファ検索
        (setq dialog-base-x 96)
        (incf dialog-base-y (+ 38 (* 14 number-of-dir)))
        (setq dialog-x dialog-base-x)
        (setq dialog-y dialog-base-y)
        (push `(:button nil "" #x50020007 ,dialog-x ,dialog-y 222 24) controls)
        (incf dialog-y 7)
        (push `(:static grep-buffer-label "検索バッファ(&B):" #x50020000
                ,(+ dialog-x 7) ,(+ dialog-y 2) 80 8) controls)
        (push `(:combobox grep-target-buffer-list nil #x50210003
                ,(+ dialog-x 56) ,dialog-y 112 96) controls)

        ;; ------------------------------------------------------------
        ;; 絞込み検索
        (setq dialog-base-x 96)
        (incf dialog-base-y 24)
        (setq dialog-x dialog-base-x)
        (setq dialog-y dialog-base-y)
        (push `(:button nil "" #x50020007 ,dialog-x ,dialog-y 222 36) controls)
        (incf dialog-y 7)
        (push `(:static grep-buffer-narrow-list-label "絞込みバッファ(&N):" #x50020000
                ,(+ dialog-x 7) ,(+ dialog-y 2) 80 8) controls)
        (push `(:combobox grep-narrow-buffer-list nil
                ,(if (plusp (length grep-narrow-buffer-list)) #x50210003 #x58210003)
                ,(+ dialog-x 56) ,dialog-y 112 64) controls)
        (incf dialog-y 14)
        (push `(:static grep-buffer-narrow-unit-label "絞込み元:" #x50020000
                ,(+ dialog-x 7) ,(+ dialog-y 2) 60 8) controls)
        (push `(:button grep-narrow-unit-line "マッチ行のみ(&G)" #x50000009
                ,(+ dialog-x 56) ,(+ dialog-y 2) 60 10) controls)
        (push `(:button grep-narrow-unit-buffer "マッチしたバッファ/ファイル全体(&H)" #x50000009
                ,(+ dialog-x 116) ,(+ dialog-y 2) 100 10) controls)))

    ;; ------------------------------------------------------------
    (setq dialog-base-x 96)
    (setq dialog-base-y (+ 20 (* 14 number-of-pattern) ;パターン
                           38 (* 14 number-of-dir)     ;ディレクトリ
                           24                          ;バッファ
                           36))                        ;絞込み
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)
    (push `(:button nil "" #x50020007 ,dialog-x ,dialog-y 222 36) controls)
    (incf dialog-y 7)
    (push `(:static encoding-label "エンコード(&Q):" #x50020000
            ,(+ dialog-x 7) ,(+ dialog-y 2) 38 8) controls)
    (push `(:combobox encoding nil #x50210003
            ,(+ dialog-x 44) ,dialog-y 124 96) controls)
    (push `(:button encoding-check-file "バッファ読み込み済みファイルも指定エンコードでファイルから検索(&R)"
            #x50010003 ,(+ dialog-x 16) ,(+ dialog-y 16) 190 10) controls)

    ;; ------------------------------------------------------------
    (setq dialog-base-x 96)
    (incf dialog-base-y 36)
    (setq dialog-x dialog-base-x)
    (setq dialog-y dialog-base-y)
    (push `(:button nil "" #x50020007 ,dialog-x ,dialog-y 222 22) controls)
    (incf dialog-y 7)
    (push `(:static syntax-label "シンタックス(&*):" #x50020000
            ,(+ dialog-x 7) ,(+ dialog-y 2) 42 8) controls)
    (incf dialog-y 1)
    (push `(:button syntax-all "全て" #x50010003
            ,(+ dialog-x 48) ,dialog-y 34 10) controls)
    (push `(:button syntax-string "文字列" #x50010003
            ,(+ dialog-x 79) ,dialog-y 34 10) controls)
    (push `(:button syntax-comment "コメント" #x50010003
            ,(+ dialog-x 114) ,dialog-y 34 10) controls)
    (push `(:button syntax-tag "タグ" #x50010003
            ,(+ dialog-x 149) ,dialog-y 34 10) controls)
    (push `(:button syntax-nil "未分類" #x50010003
            ,(+ dialog-x 184) ,dialog-y 34 10) controls)

    ;; ------------------------------------------------------------
    (incf dialog-base-y 22)
    (setq dialog-y dialog-base-y)
    (push `(:button case-fold "大文字小文字を区別する(&C)" #x50010006
            31 ,(incf dialog-y 7) 113 10) controls)
    (push `(:button word "単語単位で検索する(&W)" #x50010003
            31 ,(incf dialog-y 13)  97 10) controls)
    (push `(:button regexp "正規表現(&E)" #x50010003
            31 ,(incf dialog-y 13)  62 10) controls)
    (push `(:button escseq "エスケープシーケンスを理解しろ(&Y)" #x50010003
            31 ,(incf dialog-y 13) 113 10) controls)
    (push `(:button async "非同期でggrep(&A)" #x50010003
            31 ,(incf dialog-y 13) 103 10) controls)
    (push `(:button contents-only "コンテンツのみ出力(&V)" #x50010003
            31 ,(incf dialog-y 13)  84 10) controls)
    (push `(:button name "バッファ/ファイル名だけ出力(&O)" #x50010003
            31 ,(incf dialog-y 13)  94 10) controls)
    (push `(:button full-name "フルパス名で出力(&U)" #x50010003
            31 ,(incf dialog-y 13)  84 10) controls)

    (setq dialog-y (+ dialog-base-y 14))
    (push `(:static pat-resize-label "パターン数(&P):"   #x50020000
            146 ,(+ dialog-y 3) 50  8) controls)
    (push `(:edit pat-resize-num nil     #x50812086
            194 ,dialog-y 36 14) controls)
    (push `(:spin pat-resize-numspin nil #x500000b6
            230 ,dialog-y 10 14) controls)
    (incf dialog-y 17)
    (push `(:static dir-resize-label "ディレクトリ数(&D):" #x50020000
            146 ,(+ dialog-y 3) 50  8) controls)
    (push `(:edit dir-resize-num nil     #x50812086
            194 ,dialog-y 36 14) controls)
    (push `(:spin dir-resize-numspin nil #x500000b6
            230 ,dialog-y 10 14) controls)
    (incf dialog-y 16)
    (push `(:static dir-resize-comment "(リスト指定領域高さ)" #x50020000
            172 ,dialog-y 58 8) controls)

    (setq dialog-y dialog-base-y)
    (push `(:button IDOK "検索(&S)"  #x50010001
            246 ,(incf dialog-y 11) 50 14) controls)
    (push `(:button IDCANCEL "キャンセル" #x50010000
            246 ,(incf dialog-y 17) 50 14) controls)
    (push `(:button apply "適用(&Z)" #x50010000
            246 ,(incf dialog-y 17) 50 14) controls)
    (push `(:button clear "クリア(&X)" #x50010000
            246 ,(incf dialog-y 17) 50 14) controls)

    (setq dialog-y (+ dialog-base-y 96))
    (push `(:static history-label "設定(&T):" #x50020001
            120 ,(+ dialog-y 2) 30 8) controls)
    (push `(:combobox history nil #x50210842
            150 ,dialog-y 80 80) controls)
    (push `(:button history-save "保存"  #x50010000
            234 ,dialog-y 24 14) controls)
    (push `(:button history-load "読込"  #x50010000
            260 ,dialog-y 24 14) controls)
    (push `(:button history-del "削除"  #x50010000
            286 ,dialog-y 24 14) controls)

    (setq dialog-base-y (+ dialog-y 18))

    (setq controls (nreverse controls))
    
    ;; controls-initializers の生成
    (push `(method . ,method-display-name-list)
          controls-initializers)
    (push `(method . ,(or (position *ggrep-method* method-symbol-list) 0)) controls-initializers)
    (push `(pat-resize-num . ,(format nil "~D" number-of-pattern))
          controls-initializers)
    (dotimes (i number-of-pattern)
      (push `(,(elt patenable-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-patterns*) "enable" t))
            controls-initializers)
      (push `(,(elt match-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-patterns*) "match" t))
            controls-initializers)
      (push `(,(elt nomatch-symbol-list i) .
              ,(not (ggrep-get-setting-item (nth i *ggrep-patterns*) "match" t)))
            controls-initializers)
      (push `(,(elt pattern-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-patterns*) "pattern" ""))
            controls-initializers)
      (push `(,(elt pattern-symbol-list i) . ,*minibuffer-search-string-history*)
            controls-initializers))

    (cond ((eq *ggrep-select-target-method* 'file-list)
           (push '(grep-target-file . t) controls-initializers)
           (push '(grep-target-buffer . nil) controls-initializers)
           (push '(grep-target-narrow . nil) controls-initializers))
          ((eq *ggrep-select-target-method* 'buffer-list)
           (push '(grep-target-file . nil) controls-initializers)
           (push '(grep-target-buffer . t) controls-initializers)
           (push '(grep-target-narrow . nil) controls-initializers))
          ((eq *ggrep-target-type* :file)
           (push '(grep-target-file . t) controls-initializers)
           (push '(grep-target-buffer . nil) controls-initializers)
           (push '(grep-target-narrow . nil) controls-initializers))
          ((eq *ggrep-target-type* :buffer)
           (push '(grep-target-file . nil) controls-initializers)
           (push '(grep-target-buffer . t) controls-initializers)
           (push '(grep-target-narrow . nil) controls-initializers))
          ((eq *ggrep-target-type* :narrow)
           (push '(grep-target-file . nil) controls-initializers)
           (push '(grep-target-buffer . nil) controls-initializers)
           (push '(grep-target-narrow . t) controls-initializers))
          (t
           (push '(grep-target-file . t) controls-initializers)
           (push '(grep-target-buffer . nil) controls-initializers)
           (push '(grep-target-narrow . nil) controls-initializers)))

    (push `(dir-resize-num . ,(format nil "~D" number-of-dir))
          controls-initializers)
    (dotimes (i number-of-dir)
      (push `(,(elt direnable-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-directories*) "enable" t))
            controls-initializers)
      (push `(,(elt subdir-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-directories*) "subdir"
                                       *ggrep-subdir-default*))
            controls-initializers)
      (push `(,(elt dir-symbol-list i) .
              ,(ggrep-get-setting-item (nth i *ggrep-directories*) "directory" ""))
            controls-initializers)
      (if (= i 0)
          (push `(,(elt dir-symbol-list i) .
                  ,(append (list "<カレントディレクトリ>") *grep-directory-history*)) controls-initializers)
        (push `(,(elt dir-symbol-list i) . ,*grep-directory-history*) controls-initializers)))
    (push `(file . ,*ggrep-file*) controls-initializers)
    (push `(file . ,*grep-file-history*) controls-initializers)

    (let ((buffer-list (append (list "<カレントバッファ>" "<全表示バッファ>")
                               (delete "^ \\*Minibuf[0-9]+\\*$"
                                       (mapcar 'buffer-name (buffer-list))
                                       :test 'string-match))))
      (push `(grep-target-buffer-list . ,buffer-list) controls-initializers)
      (push `(grep-target-buffer-list
              . ,(or (position *ggrep-buffer* buffer-list :test 'string=) 0)) controls-initializers))

    (let ((escape-char-alist
           '(("\n" . "\\\\n") ("\r" . "\\\\r") ("\t" . "\\\\t") ("\f" . "\\\\f"))))
      (flet ((encode-escape-sequence (string)
               (cond
                ((stringp string)
                 (dolist (ec escape-char-alist)
                   (setq string (substitute-string string (car ec) (cdr ec))))
                 string)
                (t nil))))
        (cond
         ((eq *ggrep-select-target-method* 'file-list)
          (push `(target-list . ,(format nil "~{~A\r\n~}"
                                         (mapcar #'encode-escape-sequence *ggrep-file-list*)))
                controls-initializers))
         ((eq *ggrep-select-target-method* 'buffer-list)
          (push `(target-list . ,(format nil "~{~A\r\n~}"
                                         (mapcar #'encode-escape-sequence *ggrep-buffer-regexp-list*)))
                controls-initializers)))))

    (push `(grep-narrow-buffer-list . ,grep-narrow-buffer-list) controls-initializers)
    (push `(grep-narrow-buffer-list . ,(or (position *ggrep-narrow-buffer*
                                              grep-narrow-buffer-list
                                              :test 'string=) 0)) controls-initializers)
    (cond ((eq *ggrep-narrow-unit* :buffer)
           (push '(grep-narrow-unit-buffer . t) controls-initializers)
           (push '(grep-narrow-unit-line . nil) controls-initializers))
          (t
           (push '(grep-narrow-unit-buffer . nil) controls-initializers)
           (push '(grep-narrow-unit-line . t) controls-initializers)))
    (push `(syntax-all . ,(eq *ggrep-syntax* t)) controls-initializers)
    (push `(syntax-string . ,(or (eq *ggrep-syntax* t) (member :string *ggrep-syntax*)))
          controls-initializers)
    (push `(syntax-comment . ,(or (eq *ggrep-syntax* t) (member :comment *ggrep-syntax*)))
          controls-initializers)
    (push `(syntax-tag . ,(or (eq *ggrep-syntax* t) (member :tag *ggrep-syntax*)))
          controls-initializers)
    (push `(syntax-nil . ,(or (eq *ggrep-syntax* t) (member nil *ggrep-syntax*)))
          controls-initializers)
    (push `(encoding . ,char-encoding-display-name-list) controls-initializers)
    (push `(encoding . ,(or (position *ggrep-encoding-name*
                                      char-encoding-name-list
                                      :test 'string=) 0)) controls-initializers)
    (push (cons 'encoding-check-file *ggrep-encoding-check-file*)
          controls-initializers)
    (push (cons 'case-fold (cfs2dialog *ggrep-case-fold-search*))
          controls-initializers)
    (push (cons 'word *ggrep-word-search*) controls-initializers)
    (push (cons 'regexp *ggrep-regexp-search*) controls-initializers)
    (push (cons 'escseq *ggrep-understand-escape-sequences*) controls-initializers)
    (push (cons 'async *ggrep-async*) controls-initializers)
    (push (cons 'contents-only *ggrep-contents-only*) controls-initializers)
    (push (cons 'name *ggrep-name-only*) controls-initializers)
    (push (cons 'full-name *ggrep-full-name*) controls-initializers)

    (push (cons 'history history-name) controls-initializers)
    (push (cons 'history history-name-list) controls-initializers)

    (setq controls-initializers (nreverse controls-initializers))

    ;; controls-handlers の生成
    (push `(method :index t) controls-handlers)
    (dotimes (i number-of-dir)
      (push `(,(elt refdir-symbol-list i) :related ,(elt dir-symbol-list i)
              :directory-name-dialog (:title "参照")) controls-handlers))

    ;; ----------------------------------------
    (let ((target-file-symbols
           (append direnable-symbol-list dir-symbol-list refdir-symbol-list
                   subdir-symbol-list '(file)))
          (target-buffer-symbols '(grep-target-buffer-list))
          (target-narrow-symbols '(grep-narrow-buffer-list grep-narrow-unit-line grep-narrow-unit-buffer)))
      (push `(grep-target-file :enable ,target-file-symbols
                               :disable ,(append target-buffer-symbols target-narrow-symbols))
            controls-handlers)
      (push `(grep-target-buffer :enable ,target-buffer-symbols
                               :disable ,(append target-file-symbols target-narrow-symbols))
            controls-handlers)
      (push `(grep-target-narrow :enable ,target-narrow-symbols
                                 :disable ,(append target-file-symbols target-buffer-symbols))
            controls-handlers))
    ;; ----------------------------------------
    
    (push '(grep-narrow-buffer-list :index t) controls-handlers)
    (push '(syntax-all :disable (syntax-string syntax-comment syntax-tag syntax-nil))
          controls-handlers)
    (push '(encoding :index t) controls-handlers)
    (push `(pat-resize-num :min ,*ggrep-dialog-number-of-pattern-min*
                           :max 99 :range-error
                           ,(format nil "~D 以上 99 以下を指定してください"
                                    *ggrep-dialog-number-of-pattern-min*)
           :type integer :type-error "数値を入力してください") controls-handlers)
    (push `(pat-resize-numspin :min ,*ggrep-dialog-number-of-pattern-min*
                               :max 99) controls-handlers)
    (push `(dir-resize-num :min ,*ggrep-dialog-number-of-dir-min*
                           :max 99 :range-error
                           ,(format nil "~D 以上 99 以下を指定してください"
                                    *ggrep-dialog-number-of-dir-min*)
            :type integer :type-error "数値を入力してください") controls-handlers)
    (push `(dir-resize-numspin :min ,*ggrep-dialog-number-of-dir-min*
                               :max 99) controls-handlers)
    (push '(word :disable (regexp)) controls-handlers)
    (push '(contents-only :disable (name full-name)) controls-handlers)

    (setq controls-handlers (nreverse controls-handlers))

    ;;
    (setq dialog-template
          `(dialog 0 0 320 ,dialog-base-y
                   (:caption ,(if (stringp history-name)
                                  (concat "GGrep - [" history-name "]") "GGrep"))
                   (:font 9 "MS UI Gothic")
                   (:control
                    ,@controls)))
    (multiple-value-bind (result data)
        (dialog-box dialog-template
                    controls-initializers
                    controls-handlers)
      (when result
        (let (patterns)
          (si:*activate-toplevel)
          ;; *ggrep-method* の取得
          (setq *ggrep-method* (nth (or (cdr (assoc 'method data)) 0) method-symbol-list))
;          dialog での設定変更をどこまで minibuffer での実行時に反映させるか。
;          (setq *last-ggrep-method* *ggrep-method*)

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
          ;; ■ダイアログからの情報の取得
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ;; *ggrep-patterns* の取得
          (setq *ggrep-patterns* nil)
          (dotimes (i number-of-pattern)
            (push
             (list (list (copy-string "enable") (cdr (assoc (elt patenable-symbol-list i) data)))
                   (list (copy-string "pattern") (cdr (assoc (elt pattern-symbol-list i) data)))
                   (list (copy-string "match") (cdr (assoc (elt match-symbol-list i) data))))
             *ggrep-patterns*))
          (dolist (p *ggrep-patterns*)
            (if (string/= (ggrep-get-setting-item p "pattern") "")
                (add-history (ggrep-get-setting-item p "pattern")
                             '*minibuffer-search-string-history*)))
          (setq *ggrep-patterns* (nreverse *ggrep-patterns*))

          ;; *ggrep-target-type* の取得
          (unless (or (eq *ggrep-select-target-method* 'file-list)
                      (eq *ggrep-select-target-method* 'buffer-list))
            (cond ((cdr (assoc 'grep-target-file data))
                   (setq *ggrep-target-type* :file))
                  ((cdr (assoc 'grep-target-buffer data))
                   (setq *ggrep-target-type* :buffer))
                  ((cdr (assoc 'grep-target-narrow data))
                   (setq *ggrep-target-type* :narrow))
                  (t
                   (setq *ggrep-target-type* :file))))

          ;; *ggrep-select-target-method* 毎に値を取得
          (cond
           ;; *ggrep-file-list* 取得
           ((eq *ggrep-select-target-method* 'file-list)
            (setq *ggrep-file-list*
                  (mapcar #'(lambda (str)
                              (decode-escape-sequence str nil))
                          (split-string (substitute-string (cdr (assoc 'target-list data))
                                                           "\r\n" "\n") #\LFD))))
           ;; *ggrep-buffer-regexp-list* 取得
           ((eq *ggrep-select-target-method* 'buffer-list)
            (setq *ggrep-buffer-regexp-list*
                  (mapcar #'(lambda (str)
                              (decode-escape-sequence str t))
                          (split-string (substitute-string (cdr (assoc 'target-list data))
                                                           "\r\n" "\n") #\LFD))))
           ;;
           (t
            (cond
             ((eq *ggrep-target-type* :file)
              (setq *ggrep-directories* nil)
              (dotimes (i number-of-dir)
                (push
                 (list (list (copy-string "enable") (cdr (assoc (elt direnable-symbol-list i) data)))
                       (list (copy-string "directory") (cdr (assoc (elt dir-symbol-list i) data)))
                       (list (copy-string "subdir") (cdr (assoc (elt subdir-symbol-list i) data))))
                 *ggrep-directories*))
              (dolist (d *ggrep-directories*)
                (if (and (string/= (ggrep-get-setting-item d "directory") "")
                         (string-match (ggrep-get-setting-item d "directory") "[<>]"))
                    (add-history (ggrep-get-setting-item d "directory")
                                 '*grep-directory-history*)))
              (setq *ggrep-directories* (nreverse *ggrep-directories*))
              (setq *ggrep-file* (cdr (assoc 'file data)))
              (add-history *ggrep-file* '*grep-file-history*))
             ;;
             ((eq *ggrep-target-type* :buffer)
              (setq *ggrep-buffer* (cdr (assoc 'grep-target-buffer-list data))))
             ;; 絞込み指定
             ((eq *ggrep-target-type* :narrow)
              (setq *ggrep-narrow-buffer*
                    (elt grep-narrow-buffer-list (cdr (assoc 'grep-narrow-buffer-list data))))
              (if (cdr (assoc 'grep-narrow-unit-buffer data))
                  (setq *ggrep-narrow-unit* :buffer)
                (setq *ggrep-narrow-unit* :line))))))

          (cond
           ;; ファイルリストの取得
           ((eq result 'get-file-list)
            (let (lst)
              (dolist (x (mapcar 'get-buffer-file-name (buffer-list)))
                (when x
                  (push x lst)))
              (setq *ggrep-file-list* (nreverse lst))))
           ;; バッファリストの取得
           ((eq result 'get-buffer-list)
            (setq *ggrep-buffer-regexp-list*
                  (mapcar #'(lambda (buffer)
                              (concat "^" (regexp-quote (buffer-name buffer)) "$"))
                          (buffer-list))))
           ;; 検索対象指定画面の変更 (標準->ファイルリスト->バッファリスト->標準)
           ((eq result 'change-select-target-method)
            (cond
             ((eq *ggrep-select-target-method* 'file-list)
              (setq *ggrep-select-target-method* 'buffer-list))
             ((eq *ggrep-select-target-method* 'buffer-list)
              (setq *ggrep-select-target-method* nil))
             (t
              (setq *ggrep-select-target-method* 'file-list)))))

          ;; syntax 指定
          (if (cdr (assoc 'syntax-all data))
              (setq *ggrep-syntax* t)
            (progn
              (setq *ggrep-syntax* nil)
              (when (cdr (assoc 'syntax-string data)) (push :string *ggrep-syntax*))
              (when (cdr (assoc 'syntax-comment data)) (push :comment *ggrep-syntax*))
              (when (cdr (assoc 'syntax-tag data)) (push :tag *ggrep-syntax*))
              (when (cdr (assoc 'syntax-nil data)) (push nil *ggrep-syntax*))))

          ;; エンコード指定
          (setq *ggrep-encoding-name* (elt char-encoding-name-list
                                           (cdr (assoc 'encoding data))))
          (if (string= "" *ggrep-encoding-name*)
              (setq *ggrep-encoding-name* nil))
          (setq *ggrep-encoding-check-file* (cdr (assoc 'encoding-check-file data)))

          ;; 各種オプション
          (setq *ggrep-case-fold-search* (dialog2cfs (cdr (assoc 'case-fold data))))
          (setq *ggrep-word-search* (cdr (assoc 'word data)))
          (setq *ggrep-regexp-search* (cdr (assoc 'regexp data)))
          (setq *ggrep-understand-escape-sequences* (cdr (assoc 'escseq data)))
          (setq *ggrep-async* (cdr (assoc 'async data)))
          (setq *ggrep-name-only* (cdr (assoc 'name data)))
          (setq *ggrep-full-name* (cdr (assoc 'full-name data)))
          (setq *ggrep-contents-only* (cdr (assoc 'contents-only data)))

          ;; 入力項目数調整
          (setq *ggrep-dialog-number-of-pattern* (cdr (assoc 'pat-resize-num data)))
          (setq *ggrep-dialog-number-of-dir* (cdr (assoc 'dir-resize-num data)))

          ;; 設定情報の保存
          (setq *last-ggrep-setting* (ggrep-make-setting))

          ;; 設定名関連のボタン押下時のみ history-name を変更
          (when (member result '(history-del history-save history-load))
            (setq history-name (cdr (assoc 'history data))))

          (setq patterns (ggrep-patterns-normalization
                          *ggrep-patterns*
                          :regexp-search *ggrep-regexp-search*
                          :understand-escape-sequences *ggrep-understand-escape-sequences*))

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; ■最終的に押したボタンに対する動作
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          (cond
           ;; クリア
           ((eq result 'clear)
            (ggrep-dialog :setting nil))
           ;; 適用
           ((eq result 'apply)
            (ggrep-dialog :history-name history-name :history-no-load t))
           ;; ファイルリスト切替
           ((eq result 'change-select-target-method)
            (ggrep-dialog :history-name history-name :history-no-load t))
           ;; ファイルリスト取得
           ((eq result 'get-file-list)
            (ggrep-dialog :history-name history-name :history-no-load t))
           ;; バッファリスト取得
           ((eq result 'get-buffer-list)
            (ggrep-dialog :history-name history-name :history-no-load t))
           ;; 検索
           ((eq result 'IDOK)
            (cond
             ;; ファイルリスト指定検索
             ((eq *ggrep-select-target-method* 'file-list)
              (ggrep-scan-files patterns *ggrep-method* nil nil *ggrep-async* *ggrep-file-list*))
             ;; バッファリスト指定検索
             ((eq *ggrep-select-target-method* 'buffer-list)
              (let (buffer-list)
                (dolist (buffer (buffer-list))
                  (dolist (regexp *ggrep-buffer-regexp-list*)
                    (when (string-match regexp (buffer-name buffer))
                      (push buffer buffer-list)
                      (return))))
                (ggrep1 patterns *ggrep-method* (nreverse buffer-list)
                        :case-fold *ggrep-case-fold-search*
                        :word-search *ggrep-word-search*
                        :name-only *ggrep-name-only*
                        :contents-only *ggrep-contents-only*
                        :syntax *ggrep-syntax*)))
             ;; バッファ検索
             ((eq *ggrep-target-type* :buffer)
              (cond
               ;; カレントバッファ検索
               ((string= *ggrep-buffer* "<カレントバッファ>")
                (ggrep1 patterns *ggrep-method* t
                        :case-fold *ggrep-case-fold-search*
                        :word-search *ggrep-word-search*
                        :name-only *ggrep-name-only*
                        :contents-only *ggrep-contents-only*
                        :syntax *ggrep-syntax*))
               ;; 全表示バッファ検索
               ((string= *ggrep-buffer* "<全表示バッファ>")
                (ggrep1 patterns *ggrep-method* nil
                        :case-fold *ggrep-case-fold-search*
                        :word-search *ggrep-word-search*
                        :name-only *ggrep-name-only*
                        :contents-only *ggrep-contents-only*
                        :syntax *ggrep-syntax*))
               (t
                (ggrep1 patterns *ggrep-method* (list *ggrep-buffer*)
                        :case-fold *ggrep-case-fold-search*
                        :word-search *ggrep-word-search*
                        :name-only *ggrep-name-only*
                        :contents-only *ggrep-contents-only*
                        :syntax *ggrep-syntax*))))
             ;; ディレクトリ指定検索
             ((eq *ggrep-target-type* :file)
              (ggrep-scan-files patterns *ggrep-method*
                                (split-string *ggrep-file* #\; t " ")
                                *ggrep-directories* *ggrep-async*))
             ;; 絞込み検索
             ((eq *ggrep-target-type* :narrow)
              (let ((target-list
                     (ggrep-get-target-list (if (string= *ggrep-narrow-buffer* "<カレントバッファ>")
                                                (selected-buffer)
                                              (find-buffer *ggrep-narrow-buffer*))
                                            *ggrep-narrow-unit*)))
                ;; 先頭が buffer ならば全て buffer と判断
                (if (or (bufferp (car target-list))
                        (and (listp (car target-list))
                             (bufferp (caar target-list))))
                    (ggrep1 patterns *ggrep-method* target-list
                            :case-fold *ggrep-case-fold-search*
                            :word-search *ggrep-word-search*
                            :name-only *ggrep-name-only*
                            :contents-only *ggrep-contents-only*
                            :syntax *ggrep-syntax*)
                  (ggrep-scan-files patterns *ggrep-method* nil nil *ggrep-async* target-list))))))
           ;; 削除
           ((eq result 'history-del)
            (let (pos)
              (if (setq pos
                        (position history-name *ggrep-setting-history*
                                  :key #'(lambda (h) (ggrep-get-setting-item h "history-name"))
                                  :test 'equal))
                  (setq *ggrep-setting-history*
                        (append (subseq *ggrep-setting-history* 0 pos)
                                (subseq *ggrep-setting-history* (1+ pos))))))
            (ggrep-dialog))
           ;; 保存
           ((eq result 'history-save)
            (let (pos)
              (when (string-match "^[ \t]*$" history-name)
                (setq history-name (format-date-string "%Y/%m/%d %H:%M:%S")))
              (if (setq pos
                        (position history-name *ggrep-setting-history*
                                  :key #'(lambda (h) (ggrep-get-setting-item h "history-name"))
                                  :test 'equal))
                  (setq *ggrep-setting-history*
                        (append (subseq *ggrep-setting-history* 0 pos)
                                (subseq *ggrep-setting-history* (1+ pos)))))
              (push (list (list "history-name" history-name)
                          (list "setting" *last-ggrep-setting*))
                    *ggrep-setting-history*))
            (ggrep-dialog :history-name history-name))
           ;; 読込
           ((eq result 'history-load)
            (let (pos history)
              (if (setq pos
                        (position history-name *ggrep-setting-history*
                                  :key #'(lambda (h) (ggrep-get-setting-item h "history-name"))
                                  :test 'equal))
                  (progn
                    (setq history (nth pos *ggrep-setting-history*))
                    (setq *last-ggrep-setting* (ggrep-get-setting-item history "setting"))
                    (setq *ggrep-setting-history*
                          (append (subseq *ggrep-setting-history* 0 pos)
                                  (subseq *ggrep-setting-history* (1+ pos))))
                    (push history *ggrep-setting-history*)
                    (ggrep-dialog :history-name history-name))
                (ggrep-dialog :setting nil)))))
          t)))))

;; menu
(defun ggrep-insert-menu-items (&key menu pre-tag position head-sep tail-sep)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::search)))
  (when (menup menu)
    (ggrep-delete-menu menu)
    (unless (or pre-tag position)
      (setq pre-tag 'ed::grep-dialog))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'ggrep-sep))
    (insert-menu-item menu (incf position) 'ggrep-dialog
                      "GGrep(&H)..."
                      'ggrep-dialog)
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'ggrep-sep))))
(defun ggrep-delete-menu (&optional menu)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::search)))
  (when (menup menu)
    (while (delete-menu menu 'ggrep-dialog))
    (while (delete-menu menu 'ggrep-sep))))

;; tool-bar
(defun ggrep-tool-bar ()
  (create-tool-bar
   'ggrep-tool-bar
   (merge-pathnames "toolbar-ggrep.bmp" (etc-path))
   '(("ggrep" 0 ggrep-dialog))))
(define-command-bar 'ggrep-tool-bar "GGrep(&G)")

;; uninstall
(defun ggrep-uninstall ()
  (let ((history-variables
         '(*last-ggrep-regexp-list*
           *last-fggrep-pattern-list*
           *last-ggrep-method*
           *last-ggrep-setting*
           *ggrep-setting-history*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable)))
  (delete-command-bar 'ggrep-tool-bar)
  (ggrep-delete-menu))

(if (menup ed::*app-menu*)
    (ggrep-insert-menu-items)
  (add-hook 'ed::*init-app-menus-hook*
            #'(lambda () (ggrep-insert-menu-items))))

;;; ggrep.l ends here
