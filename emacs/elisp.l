(unless (find-package "elisp")
  (defpackage "elisp" (:use "lisp" "editor")
    (:nicknames "el")))
