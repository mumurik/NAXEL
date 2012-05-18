=begin

=== 2008-07-12 / 0.0.5

xtal-mode 0.0.5 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

: その他

    * ライセンスファイルを同梱


=== 2007-09-30 / 0.0.4

xtal-mode 0.0.4 リリース!

: 新規機能

    * なし

: バグ修正

    * c-indent-level が 4 じゃない場合にインデントがおかしくなっていたのを修正。

: 非互換を含む変更点

    * 「{」入力時の閉じ括弧自動挿入後のカーソル位置を変更しました。
       * before
             n.times {
                 ■
             } ← 自動挿入
       * after
             n.times {■
             } ← 自動挿入

    * 「{」入力時に対応する閉じ括弧があり、インデントレベルが同じなら
      閉じ括弧を自動挿入しないようにしました。

: その他

    * なし


=== 2007-09-10 / 0.0.3

xtal-mode 0.0.3 リリース!

: 新規機能

    * Xtal trunk (0.9.7 より後のバージョン) で exe が bin ディレクトリに
      置かれるようになったので対応

    * C-c C-x で Xtal 実行前にファイルを保存するようにした

    * 対応する閉じ括弧を自動的に挿入するようにした

      この機能は ((<*xtal-electric-insert-close-parentheses*>)) に nil
      を設定することで off にできます。

    * 文字列を自動的に挿入するようにした

      この機能は ((<*xtal-electric-insert-close-string*>)) に nil
      を設定することで off にできます。

    * 以下のコマンドを追加
      * ix を xyzzy 内で実行 (C-c 1)
        * Xtal trunk が必要 (0.9.7 では動きません)
        * ((<ix>))
      * ix を外部で実行 (C-c !)
        * ((<ix-console>))
      * ステートメントをマーク (M-SPC)
        * ((<xtal-mark-statement>))
      * 次のステートメント (C-M-n)
        * ((<xtal-forward-statement>))
      * 前のステートメント (C-M-p)
        * ((<xtal-backward-statement>))
      * 同一スコープの次のステートメント (C-M-j)
        * ((<xtal-forward-statement-in-scope>))
      * 同一スコープの前のステートメント (C-M-k)
        * ((<xtal-backward-statement-in-scope>))
      * スコープを上に移動 (C-M-u)
        * ((<xtal-up-statement>))
      * スコープを下に移動 (C-M-d)
        * ((<xtal-down-statement>))
      * 前後のステートメントを入れ替え (C-M-t)
        * ((<xtal-transpose-statement>))
      * Xtal インストールパスをコマンドプロンプトで開く
        * ((<xtal-open-install-path-by-command-prompt>))
      * Xtal インストールパスをエクスプローラで開く
        * ((<xtal-open-install-path-by-explorer>))

: バグ修正

    * Xtal 実行中に C-c C-x でもう一度 Xtal を実行すると、
      前回の Xtal を停止できていなかった問題を修正

    * svn-mode を使っていると xtal-mode のメニューが表示されない場合がある問題を回避

: 非互換を含む変更点

    * なし

: その他

    * なし

=== 2007-08-14 / 0.0.2

xtal-mode 0.0.2 リリース!

: 新規機能

    * Xtal 0.9.7.x で追加されたキーワード、メソッドを定義

    * Xtal メニューに指定されたファイル・URL を開く項目を追加する関数を定義

        (xtal-add-bookmark-menu :chm "Xtal リファレンス (&C)"
                                (merge-pathnames "xtal.chm" *xtal-install-path*))

: 非互換を含む変更点

    * なし

: バグ修正

    * *xtal-mode-map* と *xtal-syntax-table* を require "xtal-mode"
      した時点で定義するようにした

: その他

    * なし

=== 2007-08-13 / 0.0.1

xtal-mode 0.0.1 リリース!

=end
