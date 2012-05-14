= layered-window - ウィンドウを半透明化・透過色の設定

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/layered-window.html>))
* Version: 1.0.1


== NAME

layered-window - ウィンドウを半透明化・透過色の設定


== SYNOPSIS

* UI

    M-x layered-window-set-opacity
    M-x layered-window-set-alpha
    M-x layered-window-set-transparency-color
    M-x layered-window-set-transparency-color-bgr
    M-x layered-window-set-opaque
    M-x toggle-layered-window

* API

    (in-package :your-application)

    (require "layered-window/api")
    (use-package :layered-window.api)

    (set-layered-window-attributes/alpha hwnd 200)


== DESCRIPTION

layered-window は以下の機能を提供します。

* 任意のウィンドウの半透明化
* 任意のウィンドウの透過色設定

また、xyzzy のウィンドウの半透明化・透過色設定に特化した インターフェイス
(API、メニュー、コマンド) を提供します。

xyzzy 以外のウィンドウの半透明化・透過色設定をしたい場合は layered-window.api パッケージ内の関数を利用してください。


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) でインストールした場合は 4 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 5 以降で OK です。

(1) api.l が必要なのでインストールします (NetInstaller でもインストールできます)。

    ((<URL:http://xyzzy.s53.xrea.com/wiki/index.php?%B3%C8%C4%A5lisp%2Fwinapi>))

(2) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/layered-window.zip>))

(3) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(4) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; layered-window
        (require "layered-window")

(5) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(6) ウィンドウメニュー→透明化 で半透明にできます。


== MODULE

=== PACKAGE

layered-window は以下のパッケージを定義しています。

* layered-window.api

  任意のウィンドウの半透明化・透過色設定をおこなうライブラリ。

* layered-window.editor

  xyzzy のウィンドウに特化したコマンド、メニュー、フックの定義。

  user, editor パッケージから use-package するようにしています。

* layered-window.ffi

  winapi 定義。


=== EXPORT

layered-window は以下の関数を export しています
(layered-window.ffi は内部パッケージなので省略)。

==== layered-window.api パッケージ

  * ((<"set-layered-window-attributes/alpha"|URL:#label-24 >))
  * ((<"set-layered-window-attributes/color"|URL:#label-25 >))

  * ((<"get-layered-window-attributes/alpha"|URL:#label-26 >))
  * ((<"get-layered-window-attributes/color"|URL:#label-27 >))

  * ((< set-window-ex-layered >))
  * ((< window-ex-layered-p >))

  * ((< alpha->opacity >))
  * ((< opacity->alpha >))
  * ((< color->rgb >))
  * ((< rgb->color >))
  * ((< coerce-to-color >))

  * ((< layered-window-api-version >))


==== layered-window.editor パッケージ

  * ((< *layered-window-default-opacity* >))
  * ((< *layered-window-hook* >))

  * ((< layered-window-set-alpha >))
  * ((< layered-window-set-opacity >))
  * ((< layered-window-set-transparency-color >))
  * ((< layered-window-set-transparency-color-bgr >))
  * ((< layered-window-set-opaque >))

  * ((< layered-window-get-alpha >))
  * ((< layered-window-get-opacity >))
  * ((< layered-window-get-transparency-color >))

  * ((< toggle-layered-window >))
  * ((< layered-window-p >))

  * ((< layered-window-version >))


=== VARIABLE

==== layered-window.editor パッケージ

--- *layered-window-default-opacity*
    toggle-layered-window ウィンドウの透明・不透明を
    切り替えるときの不透明度を指定します。

    0 から 100 までの値が指定可能です。
    0 は完全な透明、100 は完全な不透明を意味します。

    デフォルトは 80 % です。

      ;; デフォルトの不透明度を 95% に設定
      (setf *layered-window-default-opacity* 95)

--- *layered-window-hook*

    xyzzy のウィンドウの透明度、透過色設定を変更するたびに実行されるフックです。
    フックの引数は xyzzy のウィンドウハンドルです。

    デフォルトでは画面の再描画関数 (layered-window-refresh) が登録されています。

        (add-hook '*layered-window-hook* #'(lambda (hwnd)
                                             (msgbox "hello layered-window")))


=== COMMAND

==== layered-window.editor パッケージ

--- layered-window-set-opacity

    call-seq:
      (layered-window-set-opacity opacity) => nil

    不透明度を指定しウィンドウを透過します。

    引数には不透明度をパーセンテージで指定します。
    0 から 100 までの値が指定可能であり、
    0 は完全な透明、100 は完全な不透明を意味します。

    ex)
        ;; 70% のアルファ値で透明化
        (layered-window-set-opacity 70)

--- layered-window-set-alpha

    call-seq:
      (layered-window-set-alpha alpha) => nil

    アルファ値を指定しウィンドウを透過します。

    引数にはアルファ値をしています。
    0 から 255 までの値が指定可能であり、
    0 は完全な透明、255 は完全な不透明を意味します。

    ex)
        ;; 50％ ぐらいで透明化
        (layered-window-set-alpha 127)

--- layered-window-set-transparency-color

    call-seq:
      (layered-window-set-transparency-color r g b) => nil

    指定された色を透過色に設定します。

    色は 0 から 255 の RGB 値のリストで指定します。
    透過色の解除は (layered-window-set-opaque) を実行します。

    ex)
        ;; 白を透過色に設定
        (layered-window-set-transparency-color 255 255 255)

--- layered-window-set-transparency-color-bgr

    call-seq:
      (layered-window-set-transparency-color-bgr bgr) => nil

    指定された色を透過色に設定します。

    色は文字列 (BGR) で指定します。
    先行する 0 は省略でき、文字列の先頭の "#" や "#x" 無視されます。

    → xyzzy.ini の backColor をそのまま指定できます。

    ex)
        ;; 赤を透過色に設定 "FF" -> "0000FF"
        (layered-window-set-transparency-color "FF")
        ;; 青を透過色に設定 (# などは無視される)
        (layered-window-set-transparency-color "#FF0000")

--- layered-window-set-opaque

    call-seq:
      (layered-window-set-opaque) => nil

    xyzzy のウィンドウを完全に不透明にします。

    完全に不透明にした場合、再度透明化するときに画面がちらつきます。
    これを避けるには代わりに (layered-window-set-opacity 100) を利用してください。

--- toggle-layered-window

    call-seq:
      (toggle-layered-window) => nil

    xyzzy ウィンドウの透明・不透明を切り替えます。


=== FUNCTION

==== layered-window.api

--- set-layered-window-attributes/alpha

    call-seq:
      (set-layered-window-attributes/alpha hwnd alpha) => nil

    hwnd で指定された window を指定されたα値で半透明に設定します。

--- set-layered-window-attributes/color

    call-seq:
      (set-layered-window-attributes/alpha hwnd '(r g b)) => nil

    hwnd で指定された window の指定された色を透過色に設定します。

--- get-layered-window-attributes/alpha

    call-seq:
      (get-layered-window-attributes/alpha hwnd) => α値 or nil

    hwnd で指定された window のα値を返します。

    半透明化されていない場合は nil を返します。

--- get-layered-window-attributes/color

    call-seq:
      (get-layered-window-attributes/color hwnd) => (r g b) or nil

    hwnd で指定された window の透過色を RGB のリストで返します。

    半透明化されていない場合は nil を返します。

--- set-window-ex-layered

    call-seq:
      (set-window-ex-layered hwnd flag) => nil

    hwnd で指定された window の WS_EX_LAYERED フラグを設定します。

    * flag が non-nil なら window を layered window に設定します。
    * flag が nil なら layered window を解除します。

--- window-ex-layered-p

    call-seq:
      (window-ex-layered-p hwnd) => t or nil

    hwnd で指定された window が layered window なら t を返します。


--- alpha->opacity

    call-seq:
      (alpha->opacity alpha) => opacity

    指定されたα値 (0-255) を不透明度 (0-100) に変換します。

--- opacity->alpha

    call-seq:
      (opacity->alpha opacity) => alpha

    指定された不透明度 (0-100) をα値 (0-255) に変換します。

--- color->rgb

    call-seq:
      (color->rgb '(r g b)) => rgb (DWORD)

    指定された RGB のリストを RGB 値 (DWORD) に変換します。
    RGB のリストの各値は 0-255 でしていしてください。

--- rgb->color

    call-seq:
      (rgb->color rgb) => (r g b)

    指定された RGB 値 (DWORD) を RGB のリストに変換します。

--- coerce-to-color

    call-seq:
      (coerce-to-color rgb-or-list) => rgb

    指定された値を RGB 値 (DWORD) に変換します。

    * RGB のリストなら RGB 値 (DWORD) に変換します。
    * integer ならそのまま返します。
    * それ以外なら type-error をスローします。

--- layered-window-api-version

    call-seq:
      (layered-window-api-version) => 1

    layered-window.api パッケージのバージョンを返します。

    バージョンは単純な数値です。

    layered-window.api パッケージで定義している API に追加・変更があった場合に
    インクリメントします。


==== layered-window.editor

--- layered-window-get-opacity
    ウィンドウの不透明度を取得します。

    0 は完全な透明、100 は完全な不透明を意味します。
    透過設定していない場合は nil を返します。

--- layered-window-get-alpha
    ウィンドウのアルファ値を取得します。

    0 は完全な透明、255 は完全な不透明を意味します。
    透過設定していない場合は nil を返します。

--- layered-window-get-transparency-color
    設定されている透過色を取得します。

    透過色は 0 から 255 の RGB 値のリストです '(R G B)。

--- layered-window-p
    ウィンドウが透明化されているなら ((|non-nil|)) を返します。
    不透明度 100% で透過している場合も ((|t|)) を返します。

--- layered-window-version

    call-seq:
      (layered-window-version) => 1.0.1

    本パッケージのバージョンを返します。

    バージョンは major.minor.teeny という形式です。
    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます
    (Ruby と同じです :-)。

        (if (string<= "1.1.0" (layered-window-version))
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))


== SAMPLE

キーの設定例とサンプルスクリプトです。

    ;; Ctrl+F12 で透明化を切り替え
    (global-set-key #\C-F12 'toggle-layered-window)

    ;; xyzzy 終了時にフェードアウトする
    (add-hook '*kill-xyzzy-hook*
              #'(lambda ()
                  (do ((n 100 (- n 10)))
                      ((< n 0))
                    (layered-window-set-opacity n)
                    (sit-for 0.05))))

    ;; 非アクティブなときは半透明にする
    (add-hook '*deactivate-hook*
              #'(lambda ()
                  (layered-window-set-opacity 50)))
    (add-hook '*activate-hook*
              #'(lambda ()
                  (layered-window-set-opaque)))

    ;; 何もしないとどんどん透明になっていく・・・ (重いかも)
    (let ((alpha 255))
      (add-hook '*post-command-hook*
                #'(lambda (&optional ignore)
                    (setf alpha 255)))
      (start-timer 1
                   #'(lambda ()
                       (decf alpha)
                       (if (< 10 alpha) ; 少しぐらい残そう
                           (layered-window-set-alpha alpha)))))

    ;; libini を使って背景色を取得して透過する
    (require "libini/libini")
    (defun set-transparency-bgcolor ()
      (let ((ini (libini:ini-to-list (merge-pathnames "xyzzy.ini" (user-config-path)))))
        (layered-window-set-transparency-color-bgr
         (cdr (assoc "backColor" (libini:get-section ini "Colors") :test 'string=)))))

    ;; 色選択ダイアログを使って透過色を設定する
    (require "winapi/commdlg")
    (defun choose-transparency-color ()
      (layered-window-set-transparency-color-bgr
       (win-user::choose-color-dialog)))


== TODO

* ツール→共通設定のところに何かを作る。


== KNOWN BUGS

* toggle-layered-window は前回の透明度などを無視し、常に ((< *layered-window-default-opacity* >)) の設定を利用する
* layered-window.api のドキュメントがない


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

: api.l
    ((<URL:http://xyzzy.s53.xrea.com/wiki/index.php?%B3%C8%C4%A5lisp%2Fwinapi>))

: レイヤード ウィンドウ - Windows アプリケーションで半透明と透明効果を使用する新しい手段
    ((<URL:http://www.microsoft.com/japan/msdn/windows/windows2000/layerwin.asp>))

: SetLayeredWindowAttributes
    ((<URL:http://msdn.microsoft.com/library/ja/jpwinui/html/_Win32_SetLayeredWindowAttributes.asp>))

: SetWindowLong
    ((<URL:http://msdn.microsoft.com/library/ja/default.asp?url=/library/ja/jpwinui/html/_win32_setwindowlong.asp>))


== COPYRIGHT

layered-window は MIT/X ライセンスにしたがって利用可能です。

See cairo/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
