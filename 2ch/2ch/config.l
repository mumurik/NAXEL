; $Id: config.l 3 2003-01-25 20:35:51Z torihat $

(in-package "2ch")

;; ハンドル、メールの初期値設定
;(setq *form-name* "名無しさん")
;(setq *form-email* "sage")

;; お気に入り、追っかけスレの表示名
;(setq *favorits-name* "お気に入り")
;(setq *tracking-name* "追っかけスレ")

;; スレ一覧はこれ以上読まない
;(setq *board-max-lines* 100)

;; スレ一覧でスレッドを読んだことがあるかどうかをマーク表示。（表示が遅くなるので注意）
;(setq *thread-read-check* t)
;; スレ一覧で更新時刻を表示。（表示が遅くなるので注意）
;(setq *board-wtime-check* t)	; スレ一覧
;(setq *tracking-wtime-check* t)	; 追っかけスレ一覧
;(setq *search-wtime-check* t)	; 検索一覧
;; スレ一覧で更新されたスレを強調表示
;(add-hook '*board-show-hook* 'board-update-emphasis)

;; gzip転送
;(setq *http-accept-encoding* "gzip")

;; dolib.dllを使う
;(setq *2ch-use-dolib* t)

;(setq *dolib-name* "pikopikopo---n@tora3.net")
;(setq *dolib-pass* "detaramenahito")

;(setq *dolib-proxy* www::*www-proxy-host*)
;(setq *dolib-port* www::*www-proxy-port*)

;; read.cgiのrawmodeを使う鯖リスト
;(setq *read-cgi-hosts* '(
;			 "cheese.2ch.net"
;			 "choco.2ch.net"
;			 "cocoa.2ch.net"
;			 "curry.2ch.net"
;			 "ebi.2ch.net"
;			 "game.2ch.net"
;			 "kaba.2ch.net"
;			 "life.2ch.net"
;			 "mentai.2ch.net"
;			 "natto.2ch.net"
;			 "news.2ch.net"
;			 "okazu.bbspink.com"
;			 "pc.2ch.net"
;			 "piza2.2ch.net"
;			 "saki.2ch.net"
;			 "salad.2ch.net"
;			 "sports.2ch.net"
;			 "teri.2ch.net"
;			 "ton.2ch.net"
;			 "www2.bbspink.com"
;			 "yasai.2ch.net"
;			 ))

;;bbstable2.htmlから板一覧を読む
;(setq *menu-file-name* "bbstable2.html")
;(setf (symbol-function 'menu-parse) #'menu-parse-bbstable2)

;;2channel.brdから板一覧を読む(".2ch/2channel.brd"に置く)
;(setq *menu-file-name* "2channel.brd")
;(setf (symbol-function 'menu-parse) #'menu-parse-2channel-brd)
;(add-hook '*init-variables-hook*
;	  #'(lambda ()
;	      (setq *menu-url* *menu-file*)))

;; 起動時にオンラインモードにする
;(setq *online* t)

;; 起動時にスレ選択タブバーを表示
;(setq *thread-bar-show* t)

; 起動時に前回最後に読んだスレを開く
;(add-hook '*2ch-start-hook* 'history-current-show)

;; 追っかけスレで巡回しないグループのリスト（正規表現可）
;(setq *tracking-round-ignore-list* '("旧.*"
;				     "その他"))

; 追っかけスレ巡回後、更新順に並び替える
;(add-hook '*tracking-update-list-hook* 'tracking-sort-by-update)

; 追っかけスレグループ内巡回後、更新されたスレを勝手に開く
;(add-hook '*tracking-update-all-hook* 'tracking-next-updated)

; 追っかけスレ全巡回後、更新されたスレのリストを表示
;(add-hook '*tracking-update-full-hook* 'tracking-show-updated)
; 追っかけスレ全巡回後、更新されたスレを勝手に開く（↑とどちらかにして）
;(add-hook '*tracking-update-full-hook* 'menu-tracking-uplist-next)

; お気に入り更新時にバックアップ
;(setq *favorits-file-backup* t)

; 追っかけスレ更新時にバックアップ
;(setq *tracking-file-backup* t)
; 追っかけスレグループ削除時に消さずにファイル名を変更
;(setq *tracking-delete-file* nil)
; 追っかけスレグループ削除時にゴミ箱へ移す（xyzzy-0.2.1.190以降のみ）
;(setq *tracking-delete-file-recycle* t)

; スレデータ削除時にゴミ箱へ移す（xyzzy-0.2.1.190以降のみ）
;(setq *thread-delete-dat-recycle* t)
; スレブックマーク削除時にゴミ箱へ移す（xyzzy-0.2.1.190以降のみ）
;(setq *thread-delete-tbk-recycle* t)

;;スレを先に表示しない
;(setq *thread-show-preview* nil)

;; メール欄のネタばれ防止
;(setq *thread-hide-addr* t)

;;スレは一度にこれ以上取得しない
;(setq *thread-max-lines* 100)

;; リンクは常にブラウザで開く
;(setq *thread-open-2ch-url* nil)

;; "www.hogehoge...." みたいなのもリンクにする
;(add-hook '*thread-show-hook* 'thread-convert-link-like)

;; "&#???" みたいなのを変換する。
;(add-hook '*thread-show-pre-hook* 'thread-convert-unicode-chars)
;; "&hearts;" とかを変換する
;(add-hook '*thread-show-pre-hook* 'thread-convert-special-chars)

;; 左クリックはダブルクリックで
;(setq *2ch-mouse-single-click* nil)

;; 板一覧メニュー幅（nilなら分割しない）
;(setq *menu-width* 20)
;; スレ一覧の高さ（nilなら分割しない）
;(setq *board-height* 5)
;; 発言フォームに分割する時にスレ表示に残す高さ（tなら半分に、nilなら分割しない）
;(setq *form-height* 10)

;; スレ一覧のスレタイトルの幅
;(setq *board-title-width* 60)
;; スレ一覧の更新日時表示形式
;(setq *board-date-format* "%Y/%m/%d(%v) %H:%M")

;; メニューの配色
;(setq *menu-fgcolor* 0)
;(setq *category-fgcolor-open* 2)
;(setq *category-fgcolor-close* 10)

;(setq *menu-bgcolor* 0)
;(setq *category-bgcolor-open* 0)
;(setq *category-bgcolor-close* 0)

;; スレ一覧の配色
;(setq *board-fgcolor-number* 1)
;(setq *board-fgcolor-tracking* 5)
;(setq *board-fgcolor-kako* 6)
;(setq *board-fgcolor-mark* 7)
;(setq *board-fgcolor-title* 2)
;(setq *board-fgcolor-num* 4)
;(setq *board-fgcolor-name* 0)
;(setq *board-fgcolor-wtime* 0)
;(setq *board-fgcolor-read* 0)

;(setq *board-bgcolor-number* 0)
;(setq *board-bgcolor-tracking* 0)
;(setq *board-bgcolor-kako* 0)
;(setq *board-bgcolor-mark* 0)
;(setq *board-bgcolor-title* 0)
;(setq *board-bgcolor-num* 0)
;(setq *board-bgcolor-name* 0)
;(setq *board-bgcolor-wtime* 0)
;(setq *board-bgcolor-read* 0)

;; スレ表示の配色
;(setq *thread-fgcolor-number* 1)
;(setq *thread-fgcolor-date* 2)
;(setq *thread-fgcolor-name* 3)
;(setq *thread-fgcolor-addr* 4)
;(setq *thread-fgcolor-body* 0)
;(setq *thread-fgcolor-name-sage* 5)
;(setq *thread-fgcolor-addr-sage* 6)
;(setq *thread-fgcolor-cite* 15)

;; 発言フォームの配色
;(setq *form-color-title* 1)
;(setq *form-color-header* 2)
;(setq *form-color-name* 3)
;(setq *form-color-email* 4)

;; ブックマーク一覧の配色
;(setq *bookmark-fgcolor-category* *board-fgcolor-name*)
;(setq *bookmark-bgcolor-category* *board-bgcolor-name*)
;(setq *bookmark-fgcolor-board* *board-fgcolor-tracking*)
;(setq *bookmark-bgcolor-board* *board-bgcolor-tracking*)
;(setq *bookmark-fgcolor-mark* *board-fgcolor-read*)
;(setq *bookmark-bgcolor-mark* *board-bgcolor-read*)
;(setq *bookmark-fgcolor-title* *board-fgcolor-title*)
;(setq *bookmark-bgcolor-title* *board-bgcolor-title*)
;(setq *bookmark-fgcolor-point* *board-fgcolor-num*)
;(setq *bookmark-bgcolor-point* *board-bgcolor-num*)

;; 板内検索でマッチした文字列の配色
;(setq *grep-match-fgcolor* 1)
;(setq *grep-match-bgcolor* 0)

;; 削除・アーカイブ
; 開かなかった日数（デフォルトは30日）
;(setq *thread-clean-days* 10)
; ブックマークファイルも消す
;(setq *thread-clean-tbk* t)
; 追っかけスレも消す
;(setq *thread-clean-tracking* t)
; 削除する前にアーカイブする
;(setq *thread-clean-archive* t)
; 削除する時にゴミ箱へ移す
;(setq *thread-clean-recycle* t)
; アーカイブファイル名（要対応DLL）
;(setq *thread-archive-file-name* "archive.lzh")
;;(setq *thread-archive-file-name* "archive.zip")

;; 出したり引っ込めたり
;; ~/.xyzzyに↓のようにしておくといいかも
;; (autoload '2ch-toggle "2ch/main" t)
;; (global-set-key #\S-F1 '2ch-toggle)
;(define-key *board-map* #\S-F1 'toggle)
;(define-key *form-map* #\S-F1 'toggle)
;(define-key *thread-map* #\S-F1 'toggle)
;(define-key *menu-map* #\S-F1 'toggle)
;(define-key *tracking-map* #\S-F1 'toggle)

;; xyzzycliから呼ばれないようにする
;(add-hook '*2ch-start-hook* 'stop-xyzzy-server)

