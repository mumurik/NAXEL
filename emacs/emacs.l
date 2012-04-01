;; Copyright (c) 2012 mumurik765
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of
;; this software and associated documentation files (the "Software"), to deal in
;; the Software without restriction, including without limitation the rights to
;; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
;; the Software, and to permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all copies
;; or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
;; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
;; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


(provide "emacs")

(require "elisp")
(in-package "elisp")

;; really work recursive mini-buffer?
(defvar *minibuffer-depth* -1)
(add-hook '*enter-minibuffer-hook*
	  (defun iswitchb-countup-minibuffer-depth (buffer history)
	    (interactive)
	    (incf *minibuffer-depth*)))
(add-hook '*exit-minibuffer-hook*
	  (defun iswitchb-countdown-minibuffer-depth (buffer history)
	    (interactive)
	    (decf *minibuffer-depth*)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (shadow '(if get-buffer-window make-local-variable)))

(defun get-buffer-window (buffer &optional start-window)
  (ed::get-buffer-window buffer start-window))

(defun make-local-variable (sym)
  (ed::make-local-variable sym)
  sym)

(defmacro if (test then &rest else)
  `(lisp::if ,test
       ,then
     (progn ,@else)))

(defun delq (ELT LIST)
"Delete by side effect any occurrences of ELT as a member of LIST.
The modified LIST is returned.  Comparison is done with `eq'.
If the first member of LIST is ELT, there is no way to remove it by side effect;
therefore, write `(setq foo (delq element foo))'
to be sure of changing the value of `foo'.
-- copied from ntemacs.
"
  (delete ELT LIST :test #'eq))


(defmacro defcustom (sym val doc &key type
				       options
				       initialize
				       set
				       get
				       require
				       risky
				       safe
				       group
				       link
				       version
				       package
				       tag
				       load
				       set-after
				       )
"Declare SYMBOL as a customizable variable that defaults to VALUE.
DOC is the variable documentation.

Neither SYMBOL nor VALUE need to be quoted.
If SYMBOL is not already bound, initialize it to VALUE.
The remaining arguments should have the form

   [KEYWORD VALUE]...

The following keywords are meaningful:

:type	VALUE should be a widget type for editing the symbol's value.
:options VALUE should be a list of valid members of the widget type.
:initialize
	VALUE should be a function used to initialize the
	variable.  It takes two arguments, the symbol and value
	given in the `defcustom' call.  The default is
	`custom-initialize-reset'.
:set	VALUE should be a function to set the value of the symbol.
	It takes two arguments, the symbol to set and the value to
	give it.  The default choice of function is `set-default'.
:get	VALUE should be a function to extract the value of symbol.
	The function takes one argument, a symbol, and should return
	the current value for that symbol.  The default choice of function
	is `default-value'.
:require
	VALUE should be a feature symbol.  If you save a value
	for this option, then when your `.emacs' file loads the value,
	it does (require VALUE) first.
:risky	Set SYMBOL's `risky-local-variable' property to VALUE.
:safe	Set SYMBOL's `safe-local-variable' property to VALUE.

The following common keywords are also meaningful.

:group  VALUE should be a customization group.
        Add SYMBOL (or FACE with `defface') to that group.
:link LINK-DATA
        Include an external link after the documentation string for this
        item.  This is a sentence containing an active field which
        references some other documentation.

        There are several alternatives you can use for LINK-DATA:

        (custom-manual INFO-NODE)
             Link to an Info node; INFO-NODE is a string which specifies
             the node name, as in \"(emacs)Top\".

        (info-link INFO-NODE)
             Like `custom-manual' except that the link appears in the
             customization buffer with the Info node name.

        (url-link URL)
             Link to a web page; URL is a string which specifies the URL.

        (emacs-commentary-link LIBRARY)
             Link to the commentary section of LIBRARY.

        (emacs-library-link LIBRARY)
             Link to an Emacs Lisp LIBRARY file.

        (file-link FILE)
             Link to FILE.

        (function-link FUNCTION)
             Link to the documentation of FUNCTION.

        (variable-link VARIABLE)
             Link to the documentation of VARIABLE.

        (custom-group-link GROUP)
             Link to another customization GROUP.

        You can specify the text to use in the customization buffer by
        adding `:tag NAME' after the first element of the LINK-DATA; for
        example, (info-link :tag \"foo\" \"(emacs)Top\") makes a link to the
        Emacs manual which appears in the buffer as `foo'.

        An item can have more than one external link; however, most items
        have none at all.
:version
        VALUE should be a string specifying that the variable was
        first introduced, or its default value was changed, in Emacs
        version VERSION.
:package-version
        VALUE should be a list with the form (PACKAGE . VERSION)
        specifying that the variable was first introduced, or its
        default value was changed, in PACKAGE version VERSION.  This
        keyword takes priority over :version.  The PACKAGE and VERSION
        must appear in the alist `customize-package-emacs-version-alist'.
        Since PACKAGE must be unique and the user might see it in an
        error message, a good choice is the official name of the
        package, such as MH-E or Gnus.
:tag LABEL
        Use LABEL, a string, instead of the item's name, to label the item
        in customization menus and buffers.
:load FILE
        Load file FILE (a string) before displaying this customization
        item.  Loading is done with `load', and only if the file is
        not already loaded.
:set-after VARIABLES
	Specifies that SYMBOL should be set after the list of variables
        VARIABLES when both have been customized.

If SYMBOL has a local binding, then this form affects the local
binding.  This is normally not what you want.  Thus, if you need
to load a file defining variables with this form, or with
`defvar' or `defconst', you should always load that file
_outside_ any bindings for these variables.  (`defvar' and
`defconst' behave similarly in this respect.)

See Info node `(elisp) Customization' in the Emacs Lisp manual
for more information.

-- copied from ntemacs
"
  `(defvar ,sym ,val ,doc))


(defun get-buffer (buf-or-name)
"Return the buffer named BUFFER-OR-NAME.
BUFFER-OR-NAME must be either a string or a buffer.  If BUFFER-OR-NAME
is a string and there is no buffer with that name, return nil.  If
BUFFER-OR-NAME is a buffer, return it as given.

-- copied from ntemacs
"
  (if (bufferp buf-or-name)
      buf-or-name
    (find-buffer buf-or-name)))


(defun memq (elt lst)
"Return non-nil if ELT is an element of LIST.  Comparison done with `eq'.
The value is actually the tail of LIST whose car is ELT.
-- copied from ntemacs
"
  (member elt lst))


(defun set-match-data (lst &optional reseat)
"Set internal data on last search match from elements of LIST.
LIST should have been created by calling `match-data' previously.

If optional arg RESEAT is non-nil, make markers on LIST point nowhere.
-- copied from ntemacs
"
  (store-match-data lst))


(defun try-completion (subs alist &optional pred)
"Return common substring of all completions of STRING in COLLECTION.
Test each possible completion specified by COLLECTION
to see if it begins with STRING.  The possible completions may be
strings or symbols.  Symbols are converted to strings before testing,
see `symbol-name'.
All that match STRING are compared together; the longest initial sequence
common to all these matches is the return value.
If there is no match at all, the return value is nil.
For a unique match which is exact, the return value is t.

If COLLECTION is an alist, the keys (cars of elements) are the
possible completions.  If an element is not a cons cell, then the
element itself is the possible completion.
If COLLECTION is a hash-table, all the keys that are strings or symbols
are the possible completions.
If COLLECTION is an obarray, the names of all symbols in the obarray
are the possible completions.

COLLECTION can also be a function to do the completion itself.
It receives three arguments: the values STRING, PREDICATE and nil.
Whatever it returns becomes the value of `try-completion'.

If optional third argument PREDICATE is non-nil,
it is used to test each possible match.
The match is a candidate only if PREDICATE returns non-nil.
The argument given to PREDICATE is the alist element
or the symbol from the obarray.  If COLLECTION is a hash-table,
predicate is called with two arguments: the key and the value.
Additionally to this predicate, `completion-regexp-list'
is used to further constrain the set of candidates.
-- copied from ntemacs
"
  (multiple-value-bind (result list prefix)
      (*do-completion subs :list nil alist)
    (cond ((eq result :solo-match)
	   t)
	  ((null list)
	   nil)
	  ((eq result :not-unique)
	   string)
	  (t result))))

;(join '("a" "b" "c") ",")
;"a,b,c"
(defun join (seq sep)
  (if (not (consp (cdr seq)))
      (car seq)
    (concat (car seq) sep (join (cdr seq) sep))))

(defun mapconcat (fn seq sep)
"Apply FUNCTION to each element of SEQUENCE, and concat the results as strings.
In between each pair of results, stick in SEPARATOR.  Thus, \" \" as
SEPARATOR results in spaces between the values returned by FUNCTION.
SEQUENCE may be a list, a vector, a bool-vector, or a string.
-- copied from ntemacs
"
  (join (mapcar fn seq) sep))


