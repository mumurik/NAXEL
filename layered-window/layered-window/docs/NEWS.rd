=begin

=== 2007-06-02 / 1.0.1

layered-window 1.0.1 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * layered-window-version を layered-window.api パッケージに移動しました。

    * パッケージ名の変更

    * ファイル構成を変更

: バグ修正

    * シンボル名が衝突する可能性をなくした。


=== 2007-05-27 / 1.0.0

layered-window 1.0.0 リリース!

: 新規機能

    * layered-window-version
      * layered-window のバージョンを定義。
        リリースのたびに更新されます。

    * layered-window-api-version
      * layered-window.api パッケージで定義されている API に追加・変更があった場合に
        インクリメントされるバージョン番号。

    * 以下の関数名を変更 (layered-window.api パッケージ)

      既存 API も定義していますが新しいほうを利用してください。

      * set-lwa-colorkey      → set-layered-window-attributes/color
      * set-lwa-alpha         → set-layered-window-attributes/alpha
      * set-lwa               → set-layered-window-attributes
      * get-lwa-colorkey      → get-layered-window-attributes/color
      * get-lwa-alpha         → get-layered-window-attributes/alpha
      * get-lwa               → get-layered-window-attributes
      * test-ex-layered-flag  → window-ex-layered-p
      * set-ex-style-flag     → set-window-ex-style-flag
      * test-ex-style-flag    → window-ex-style-flag-p
      * get-ex-style          → get-window-ex-style
      * set-ex-style          → set-window-ex-style
      * set-ex-layered-flag   → set-window-ex-layered
      * unset-ex-layered-flag → set-window-ex-layered

    * 以下の関数を export (layered-window.api パッケージ)。

      * opacity->alpha
      * alpha->opacity
      * rgb->color
      * color->rgb
      * coerce-to-color

: バグ修正

    * なし

: 非互換を含む変更

    * ファイル・パッケージを整理
      * lwapi => layered-window.api
    * layered-window.api パッケージ (元 lwapi) の API を整理。
      * 旧 API も一応使えますが、deprecated なのでなるべく使わないでください。
    * editor パッケージ内に関数を直接定義しないようにした。
    * winapi パッケージ内に〃

: その他

    * ライセンスを修正 BSD ライセンスから MIT/X ライセンスに変更しました。


=== 2005-11-26 / 0.2.1

layered-window 0.2.1 リリース!

* 設定変更後に RedrawWindow するようにしてみた。
* 文字列で透過色を設定できるようにした。
* 透過率を取得する API を追加。
* 透過色を取得する API を追加。
* 設定変更ごとに呼ばれるフックを追加。
* 全体的にリファクタリング


=== 2003-05-29 / 0.0.1

初期リリース!



=end
