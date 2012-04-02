;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX math-mode-specific functions.
;;; katexmth.l, v 1.67.1.3
;;; fixed by Maeda Manabu
;;; Last fixed  "Sun Jun 29 2003 17:59:50 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX math-mode-specific functions.
;;; yatexmth.el
;;; (c ) 1993-1999 by HIROSE Yuuji [yuuji@gentei.org]
;;; Last modified Thu Apr 29 17:39:10 1999 on firestorm
;;; $Old-Id: yatexmth.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $

;;; [Customization guide]
;;;
;;;	  By default,  you can use two  completion  groups in KaTeX math
;;;	mode, `;' for mathematical signs and `:' for greek letters.  But
;;;	you  can add other completion groups   by defining the  alist of
;;;	`prefix  key'    vs   `completion   list'    into  the  variable
;;;	KaTeX-math-key-list-private.  If  you wish  to    accomplish the
;;;	completion as follows(prefix key is `,'):
;;;
;;;		KEY		COMPLETION
;;;		s		\sin
;;;		S		\arcsin
;;;		c		\cos
;;;		C		\arccos
;;;			:
;;;		T		\arctan
;;;		l		\log
;;;		hs		\sinh
;;;
;;;	Typing `s' after `,' makes `\sin', `hs' after `,' makes `\sinh'
;;;	and so on.  First, you have to define list of key-completion
;;;	pairs.  Variable name(KaTeX-math-funcs-list) is arbitrary.
;;;
;;;		(setq KaTeX-math-funcs-list
;;;		      '(("s"	"sin")
;;;			("S"	"arcsin")
;;;				:
;;;			("hs"	"sinh")))
;;;
;;;	Next, define the list of prefix-key vs completion list(defined
;;;	above) into the variable KaTeX-math-key-list-private.
;;;
;;;		(setq KaTeX-math-key-list-private
;;;		      '(("," . KaTeX-math-funcs-list)
;;;			("'" . Other-List-if-any)))
;;;
;;;	  Put these expressions into your ~/.emacs, and you can use this
;;;	completion in the math-mode.
;;;
;;;	  And you can add your favorite completion sequences to the
;;;	default completion list invoked with `;', by defining those lists
;;;	into variable KaTeX-math-sign-alist-private.

;;; ÅyÉCÉÅÅ[ÉWï‚äÆÇÃí«â¡ï˚ñ@Åz
;;;
;;;	  ïWèÄÇÃÉCÉÅÅ[ÉWï‚äÆÇ≈ÇÕÅAÅu;ÅvÇ≈énÇ‹ÇÈêîéÆãLçÜï‚äÆÇ∆ÅAÅu:ÅvÇ≈én
;;;	Ç‹ÇÈÉMÉäÉVÉÉï∂éöï‚äÆÇ™égópâ¬î\Ç≈Ç∑Ç™ÅAÇ±ÇÍà»äOÇÃï∂éöÇ≈énÇ‹ÇÈï‚äÆ
;;;	ÉVÉäÅ[ÉYÇ‡íËã`Ç∑ÇÈÇ±Ç∆Ç™Ç≈Ç´Ç‹Ç∑ÅBó·Ç¶ÇŒÅAÅu,ÅvÇ≈énÇ‹ÇÈéüÇÃÇÊÇ§
;;;	Ç»ï‚äÆÉVÉäÅ[ÉYÇíËã`Ç∑ÇÈèÍçáÇçlÇ¶ÇƒÇ›Ç‹Ç∑ÅB
;;;
;;;		ï‚äÆÉLÅ[	ï‚äÆåãâ 
;;;		s		\sin
;;;		S		\arcsin
;;;		c		\cos
;;;		C		\arccos
;;;			:
;;;		T		\arctan
;;;		l		\log
;;;		hs		\sinh
;;;
;;;	Åu,ÅvÇÃÇ†Ç∆Ç… s ÇâüÇ∑Ç∆ \sin Ç™ÅAhs ÇâüÇ∑Ç∆ \sinh Ç™ì¸óÕÇ≥ÇÍÇ‹
;;;	Ç∑ÅBÇ±ÇÃÇÊÇ§Ç»ï‚äÆÉäÉXÉgÇÃìoò^ÇÕà»â∫ÇÃÇÊÇ§Ç…ÇµÇ‹Ç∑(ïœêîñºÇÕîCà”)ÅB
;;;
;;;		(setq KaTeX-math-funcs-list
;;;		      '(("s"	"sin")
;;;			("S"	"arcsin")
;;;				:
;;;			("hs"	"sinh")))
;;;
;;;	Ç≥ÇÁÇ…ÅAÅu,ÅvÇâüÇµÇΩéûÇ…ÉCÉÅÅ[ÉWï‚äÆÇ™énÇ‹ÇÈÇÊÇ§éüÇÃïœêîÇ…ÅAãNìÆÉLÅ[
;;;	Ç∆è„Ç≈íËã`ÇµÇΩï‚äÆópïœêîÇÃìoò^ÇçsÇ»Ç¢Ç‹Ç∑ÅB
;;;
;;;		(setq KaTeX-math-key-list-private
;;;		      '(("," . KaTeX-math-funcs-list)
;;;			("'" . ÇŸÇ©Ç…íËã`ÇµÇΩÇ¢ÉVÉäÅ[ÉYÇ™Ç†ÇÍÇŒÅc)))
;;;
;;;	Ç±ÇÍÇÁÇ ~/.emacs Ç…èëÇ¢ÇƒÇ®ÇØÇŒÅAmath-mode Ç≈é©ï™êÍópÇÃÉCÉÅÅ[ÉW
;;;	ï‚äÆÇ™óòópÇ≈Ç´Ç‹Ç∑ÅB

(provide "katexmth")

(in-package "elisp")

(defvar KaTeX-jisold
  (and (boundp 'dos-machine-type)
       (eq dos-machine-type 'pc98)))

(defmacro KaTeX-setq-math-sym (sym old new)
  (list 'setq sym (list 'if 'KaTeX-jisold old new)))

(KaTeX-setq-math-sym KaTeX-image-in		"E"    		"Å∏")
(KaTeX-setq-math-sym KaTeX-image-ni		"Éà"		"Åπ")
(KaTeX-setq-math-sym KaTeX-image-subset		" _\n(\n ~"	"Åº")
(KaTeX-setq-math-sym KaTeX-image-subseteq	" _\n(_\n ~"	"Å∫")
(KaTeX-setq-math-sym KaTeX-image-supset		"_\n )\n~"	"ÅΩ")
(KaTeX-setq-math-sym KaTeX-image-supseteq	"_\n_)\n~" 	"Åª")
(KaTeX-setq-math-sym KaTeX-image-nabla		"___\n\\\\/"	"Åﬁ")
(KaTeX-setq-math-sym KaTeX-image-partial	" -+\n+-+\n+-+" "Å›")
(KaTeX-setq-math-sym KaTeX-image-dagger		"+\n|"		"Åı")
(KaTeX-setq-math-sym KaTeX-image-ddagger	"+\n+\n|"	"Åˆ")
(KaTeX-setq-math-sym KaTeX-image-equiv		"ÅÅ\nÅP"	"Åﬂ")
(KaTeX-setq-math-sym KaTeX-image-int		" /\\\n \\\n\\/" "ÅÁ")
(KaTeX-setq-math-sym KaTeX-image-oint           "/\\\n(\\)\n\\/" "áì") ; k.k
(KaTeX-setq-math-sym KaTeX-image-bot		"Åb\nÅP"	"Å€")
(KaTeX-setq-math-sym KaTeX-image-neg		"Ü≤"		"Å ")
(KaTeX-setq-math-sym KaTeX-image-flat		"ÇÇ"		"ÅÛ")
(KaTeX-setq-math-sym KaTeX-image-sqrt		"áï"		"Å„")

(defvar
 KaTeX-math-sign-alist-default
 '(
   ;frequently used
   ("||"	"|"		("||"		"Åa"))
   ("sum"	"sum"		("\\-+\n >\n/-+" "É∞"))
   ("sigma"	"sum"		("\\-+\n >\n/-+" "É∞"))
   ("integral"	"int"		(" /\\\n \\\n\\/" KaTeX-image-int))
   ("ointegral"	"oint"		(" /\\\n(\\)\n\\/" KaTeX-image-oint)) ; k.k
   ("sqrt"	"sqrt"		("  __\n,/" KaTeX-image-sqrt))
   ("root"	"sqrt"		("  __\n,/" KaTeX-image-sqrt))
   ("A"		"forall"	"|_|\nV")
   ("E"		"exists"	"-+\n-+\n-+")
   ("!"		"neg"		("--+\n  |" KaTeX-image-neg))
   ("oo"	"infty"		("oo"		"Åá"))
   ("\\"	"backslash"	("\\"		"Å_"))
   ("..."	"cdots"		("..."		"Åc"))

   ;;binary operators
   ("+-"	"pm"		("+\n-" "Å}"))
   ("-+"	"mp"		"-\n+")
   ("x"		"times"		("x" "Å~"))
   ("/"		"div"		(",\n-\n'" "ÅÄ"))
   ("f"		"frac"		"xxx\n---\nyyy" "ÅÄ")
   ("*"		"ast"		"*")
   ("#"		"star"		("_/\\_\n\\  /\n//\\\\" "Åö"))
   ("o"		"circ"		"o")
   ("o*"	"bullet"	" _\n(*)\n ~")
   ("."		"cdot"		".")
   ("cap"	"cap"		"/-\\\n| |")
   ("cup"	"cup"		"| |\n\\-/")
   ("u+"	"uplus"		"|+|\n\\-/")
   ("|~|"	"sqcap"		"|~|")
   ("|_|"	"sqcup"		"|_|")
   ("v"		"vee"		"v")
   ("^"		"wedge"		"^")
   ("\\\\"	"setminus"	"\\")
   (")("	"wr"		" )\n(")
   ("<>"	"diamond"	"<>")
   ("/\-"	"bigtriangleup"	("/\\\n~~" "Å¢"))
   ("-\\/"	"bigtriangledown" ("__\n\\/" "Å§"))
   ("<|"	"triangleleft"	"<|")
   ("|>"	"triangleright"	"|>")
   ("<||"	"lhd"		"/|\n\\|")
   ("||>"	"rhd"		"|\\\n|/")
   ("<|-"	"unlhd"		"<|\n~~")
   ("|>-"	"unrhd"		"|>\n~~")
   ("o+"	"oplus"		" _\n(+)\n ~")
   ("o-"	"ominus"	" _\n(-)\n ~")
   ("ox"	"otimes"	" _\n(x)\n ~")
   ("o/"	"oslash"	" _\n(/)\n ~")
   ("o."	"odot"		"(.)")
   ("O"		"bigcirc"	"O")
   ("t"		"dagger"	("+\n|" KaTeX-image-dagger))
   ("tt"	"ddagger"	("+\n+\n|" KaTeX-image-ddagger))
   ("II"	"amalg"		"II")
   ;	:
   ;;relational operators
   ("<"		"leq"		("<\n-"		"ÅÖ"))
   (">"		"geq"		(">\n-"		"ÅÜ"))
   ("-="	"equiv"		("=\n-"		KaTeX-image-equiv))
   ("=-"	"equiv"		("=\n-"		KaTeX-image-equiv))
   ("---"	"equiv"		("=\n-"		KaTeX-image-equiv))
   ("("		"subset"	(" _\n(\n ~"	KaTeX-image-subset))
   ("(-"	"subseteq"	(" _\n(_\n ~"	KaTeX-image-subseteq))
   (")"		"supset"	("_\n )\n~"	KaTeX-image-supset))
   (")-"	"supseteq"	("_\n_)\n~"	KaTeX-image-supseteq))
   ("["		"sqsubset"	"[")
   ("[-"	"sqsubseteq"	"[\n~")
   ("]"		"sqsupset"	"]")
   ("]-"	"sqsupseteq"	"]\n~")
   ("{"		"in"		("(-" KaTeX-image-in))
   ("}"		"ni"		("-)" KaTeX-image-ni))
   ("|-"	"vdash"		"|-")
   ("-|"	"dashv"		"-|")
   ("~"		"sim"		"~(tild)")
   ("~-"	"simeq"		"~\n-")
   ("asymp"	"asymp"		"v\n^")
   ("~~"	"approx"	"~\n~")
   ("~="	"cong"		"~\n=")
   ("=/"	"neq"		("=/="		"ÅÇ"))
   (".="	"doteq"		".\n=")
   ("o<"	"propto"	"o<")
   ("|="	"models"	"|=")
   ("_|_"	"perp"		"_|_")
   ("|"		"mid"		"|")
   ("||"	"parallel"	"||")
   ("bowtie"	"bowtie"	"|><|(wide)")
   ("|><|"	"join"		"|><|")
   ("\\_/"	"smile"		"\\_/")
   ("/~\\"	"frown"		"/~~\\")
   ("-<"	"prec"		("-<"		"Ç≠"))
   ("-<="	"preceq"	("-<\n-"	"Ç≠\n="))
   ("<<"	"ll"		("<<"		"Ås"))
   ;	:
   ;;arrows
   ("<-"	"leftarrow"	("<-"		"Å©"))
   (""	"leftarrow"	("<-"		"Å©"))
   ("<--"	"longleftarrow"	("<--"		"Å©--"))
   ("<="	"Leftarrow"	"<=")
   ("<=="	"Longleftarrow"	"<==")
   ("->"	"rightarrow"	("->"		"Å®"))
   (""	"rightarrow"	("->"		"Å®"))
   ("-->"	"longrightarrow" ("-->"		"--Å®"))
   ("=>"	"Rightarrow"	"=>")
   ("==>"	"Longrightarrow" "==>")
   ("<->"	"leftrightarrow" ("<->"		"Å©Å®"))
   ("<-->"	"longleftrightarrow" ("<---->"	"Å©--Å®"))
   ("<=>"	"Leftrightarrow" "<=>")
   ("<==>"	"Longleftrightarrow" "<==>")
   ("^|"	"uparrow"	("^\n|" "Å™"))
   (""	"uparrow"	("^\n|" "Å™"))
   ("^||"	"Uparrow"	"/\\\n||")
   (""	"downarrow"	("|\nv" "Å´"))
   ("v|"	"downarrow"	("|\nv" "Å´"))
   ("v||"	"Downarrow"	"||\n\\/")
   ("|->"	"mapsto"	("|->"		"|Å®"))
   ("<-)"	"hookleftarrow"	("   ,\n<--+"	"   ÅR\n<--/"))
   ("(->"	"hookrightarrow" ("`\n+-->"	"Å^\nÅ_-->"))
   ("/-"	"leftharpoonup"	"/\n~~~")
   ("\\-"	"leftharpoondown" "__\n\\")
   ("-/"	"rightharpoondown"  "__\n/")
   ("-\\"	"rightharpoonup" "~~\n\\")
   ;;left and right
   ("left"	"left"		"(leftmark)")
   ("right"	"right"		"(rightmark)")
   ;;accent marks
   ("tilde"	"tilde"		"~\n?")
   ("T"		"tilde"		"~\n?")
   ("wtilde"	"widetilde"	"~\n?")
   ("hat"	"hat"		"^\n?")
   ("what"	"widehat"	"/\\\n??")
   ("w^"	"widehat"	"/\\\n?")
   ("check"	"check"		"v\n?")
   ("bar"	"bar"		"_\n?")
   ("overline"	"overline"	"_\n?")
   ("wbar"	"overline"	"--\n??")
   ("dot"	"dot"		".\n?")
   ("ddot"	"ddot"		"..\n??")
   ("vec"	"vec"		("->\n??" "Å®\n??"))
   ("~>"	"overrightarrow" ("-->\nAB" "Å®\nAB"))
   ("VEC"	"overrightarrow" ("-->\nAB" "Å®\nAB"))
   ;;rage-aware stuffs
   ("prod"	"prod"		("-+--+-\n |  |" "ÉÆ"))
   ("CUP"	"bigcup"	"|~~|\n|  |\n|  |")
   ("union"	"bigcup"	"|~~|\n|  |\n|  |")
   ("CAP"	"bigcap"	"|  |\n|  |\n|__|")
   ("isc"	"bigcap"	"|  |\n|  |\n|__|")
   ("O+"	"bigoplus"	"/~~~\\\n| + |\n\\___/")
   ("Ox"	"bigotimes"	"/~~~\\\n| X |\n\\___/")
   ;;other marks
   ("Z"		"aleph"		"|\\|")
   ("|\\|"	"aleph"		"|\\|")
   ("h-"	"hbar"		"_\nh")
 ;  ("i"		"imath"		"i") ;These chars are appeared only
 ;  ("j"		"jmath"		"j") ;as section-type arguments
   ("l"		"ell"		"l")
   ("wp"	"wp"		"???")
   ("R"		"Re"		")R")
   ("Im"	"Im"		"???")
   ("mho"	"mho"		"~|_|~")
   ("'"		"prime"		"'")
   ("0"		"emptyset"	"0")
   ("nabla"	"nabla"		("___\n\\\\/" KaTeX-image-nabla))
   ("\\/"	"surd"		"-\\/")
   ("surd"	"surd"		"-\\/")
   ("top"	"top"		"T")
   ("bot"	"bot"		("_|_"		KaTeX-image-bot))
   ("b"		"flat"		("b"		KaTeX-image-flat))
   ("LT"	"natural"	"|\nLT\n |")
   ("6"		"partial"	(" -+\n+-+\n+-+" KaTeX-image-partial))
   ("partial"	"partial"	(" -+\n+-+\n+-+" KaTeX-image-partial))
   ("round"	"partial"	(" -+\n+-+\n+-+" KaTeX-image-partial))
   ("[]"	"Box"		"[]")
   ("Diamond"	"Diamond"	"/\\\n\\/")
   ("3"		"triangle"	"/\\\n~~")
   ("C"		"clubsuit"	" o\no+o\n |")
   ("D"		"diamondsuit"	"/\\\n\\/")
   ("H"		"heartsuit"	"<^^>\n \\/")
   ("S"		"spadesuit"	" /\\\n<++>\n /\\")
   )
 "Default LaTeX-math-command alist.")

(defvar KaTeX-math-sign-alist-private nil
  "*User definable key vs LaTeX-math-command alist.")

(defvar KaTeX-math-quit-with-strict-match nil
  "*T for quitting completion as soon as strict-match is found.")
(defvar KaTeX-math-sign-alist
      (append KaTeX-math-sign-alist-private KaTeX-math-sign-alist-default))

;;(defun KaTeX-math-alist2array (alist array)
;;  (set array
;;       (let ((array (make-vector (length alist) "")) (list alist) (i 0))
;;	 (while list
;;	   (aset array i (car (car list)))
;;	   (setq i (1+ i) list (cdr list)))
;;	 array))
;;)

(defvar KaTeX-greek-key-alist-default
  '(
    ("a"	"alpha"		("a" "Éø"))
    ("b"	"beta"		("|>\n|>\n|" "É¿"))
    ("g"	"gamma"		("~r" "É¡"))
    ("G"	"Gamma"		("|~" "É°"))
    ("d"	"delta"		("<~\n<>" "É¬"))
    ("D"	"Delta"		("/\\\n~~" "É¢"))
    ("e"	"epsilon"	"<\n<~")
    ("e-"	"varepsilon"	("(\n(~" "É√"))
    ("z"	"zeta"		("(~\n >" "Éƒ"))
    ("et"	"eta"		("n\n/" "É≈"))
    ("th"	"theta"		("8" "É∆"))
    ("Th"	"Theta"		("(8)" "É¶"))
    ("th-"	"vartheta"	("-8" "-É∆"))
    ("i"	"iota"		("i\n\\_/" "É«"))
    ("k"	"kappa"		("k" "É»"))
    ("l"	"lambda"	("\\n/\\" "É…"))
    ("L"	"Lambda"	("/\\" "É©"))
    ("m"	"mu"		(" u_\n/" "É "))
    ("n"	"nu"		("|/" "ÉÀ"))
    ("x"	"xi"		("E\n >" "ÉÃ"))
    ("X"	"Xi"		("---\n -\n---" "É¨"))
    ("p"	"pi"		("__\n)(" "ÉŒ"))
    ("P"	"Pi"		("__\n||" "ÉÆ"))
    ("p-"	"varpi"		("_\nw" "__\nÉ÷"))
    ("r"	"rho"		("/O" "Éœ"))
    ("r-"	"varrho"	("/O\n~~" "Éœ\n~~"))
    ("s"	"sigma"		("o~" "É–"))
    ("S"	"Sigma"		("\\-+\n >\n/-+" "É∞"))
    ("s-"	"varsigma"	"(~~ \n>")
    ("t"	"tau"		("__\n(" "É—"))
    ("u"	"upsilon"	("~v" "É“"))
    ("y"	"upsilon"	("~v" "É“"))
    ("U"	"Upsilon"	("~Y~" "É≤"))
    ("Y"	"Upsilon"	("~Y~" "É≤"))
    ("ph"	"phi"		("  /\n(/)\n/" "É”"))
    ("Ph"	"Phi"		(" _\n(|)\n ~" "É≥"))
    ("ph-"	"varphi"	"\\O\n|")
    ("c"	"chi"		("x" "É‘"))
    ("ps"	"psi"		("\\|/\\n |" "É’"))
    ("Ps"	"Psi"		(" ~\n\\|/\\n |" "Éµ"))
    ("o"	"omega"		("w" "É÷"))
    ("w"	"omega"		("w" "É÷"))
    ("O"	"Omega"		("(~)\n~ ~" "É∂"))
    ("W"	"Omega"		("(~)\n~ ~" "É∂"))
    ("f" "foo")
    )
  "Default LaTeX-math-command alist.")

(defvar KaTeX-greek-key-alist-private nil
  "*User definable key vs LaTeX-math-command alist.")

(defvar KaTeX-greek-key-alist
      (append KaTeX-greek-key-alist-private KaTeX-greek-key-alist-default))

;;(mapcar (function (lambda (x) (KaTeX-math-alist2array x)))
;;	KaTeX-math-key-list)

;(defvar KaTeX-math-indicator "KEY\tLaTeX sequence\t\tsign") ;m.m

(defvar KaTeX-math-need-image nil
  "*T for displaying pseudo image momentarily.")
(defvar KaTeX-math-max-key 8)
(defvar KaTeX-math-max-seq
  (* 8 (1+ (/ (length "\\longleftrightarrow") 8)))) ;27
(defvar KaTeX-math-max-sign 5)
(defvar KaTeX-math-sign-width
  (+ KaTeX-math-max-key KaTeX-math-max-seq KaTeX-math-max-sign)) ;40
(defvar KaTeX-math-display-width
  (* 8 (1+ (/ KaTeX-math-sign-width 8)))) ;48

(defvar KaTeX-math-indicator ;m.m ->
  (format nil (format nil "~~{~~~D@A~~~D@A~~@A~~}"
		      KaTeX-math-max-key (1- KaTeX-math-max-seq))
	  '("KEY" "LaTeX sequence" "sign"))) ;m.m <-

(defvar KaTeX-math-menu-map nil
  "Keymap used in KaTeX mathematical sign menu mode."
)
(if KaTeX-math-menu-map nil
  (progn
    (setq KaTeX-math-menu-map (make-sparse-keymap))
    (define-key KaTeX-math-menu-map #\n	'next-line)
    (define-key KaTeX-math-menu-map #\p	'previous-line)
    (define-key KaTeX-math-menu-map #\f	'KaTeX-math-forward)
    (define-key KaTeX-math-menu-map #\b	'KaTeX-math-backward)
    (define-key KaTeX-math-menu-map #\v	'scroll-up)
    (define-key KaTeX-math-menu-map #\SPC	'scroll-up)
    (define-key KaTeX-math-menu-map #\c	'scroll-up)
    (define-key KaTeX-math-menu-map #\V	'scroll-down)
    (define-key KaTeX-math-menu-map #\r	'scroll-down)
    (define-key KaTeX-math-menu-map #\C-h	'scroll-down)
    (define-key KaTeX-math-menu-map #\<	'beginning-of-buffer)
    (define-key KaTeX-math-menu-map #\>	'end-of-buffer)
    (define-key KaTeX-math-menu-map #\RET	'exit-recursive-edit)
    (define-key KaTeX-math-menu-map #\q	'abort-recursive-edit)))

(defvar KaTeX-math-exit-key "\\e"
  "*Key sequence after prefix key of KaTeX-math-mode to exit from math-mode."
)

(defmacro KaTeX-math-japanese-sign (lst)
  (list 'nth 1 lst))

(defvar KaTeX-math-cmd-regexp (concat (regexp-quote KaTeX-ec) "[A-z|]"))
(defvar KaTeX-math-verbatim-environments
  '("alltt")
  "*List of environments in which LaTeX math mode is disabled.
This value is appended with KaTeX-verbatim-environments.")

;;;
;;KaTeX math-mode functions
;;;
;;;###autoload from katex.el
(defun KaTeX-toggle-math-mode (&optional arg)
  (interactive "P")
#|  (or (memq 'KaTeX-math-mode mode-line-format) nil
      (setq mode-line-format
	    (append (list "" 'KaTeX-math-mode) mode-line-format))) |#
  (if KaTeX-auto-math-mode nil		;Only effective on manual mode.
    (progn
      (if (or arg (null KaTeX-math-mode))
	  (let (keys)
	    (setq KaTeX-math-mode "math:")
	    (message "Turn on math mode. Prefix keys are ~A"
		     (mapconcat 'car KaTeX-math-key-list " "))
	    (sit-for 3)
	    (message
	     (concat "To exit from math-mode, type `ESC' after prefix, "
		     "or type `"
		     (key-description
		      (car
		       (where-is-internal
			'KaTeX-switch-mode-menu *KaTeX-mode-map*)))
		     " $'")))
	(progn
	  (setq KaTeX-math-mode nil)
	  (message "Exit from math mode.")))
      (set-buffer-modified-p (buffer-modified-p))))
)

(defun KaTeX-math-forward (arg)
  (interactive "p")
  (re-search-forward KaTeX-math-cmd-regexp nil t arg))

(defun KaTeX-math-backward (arg)
  (interactive "p")
  (re-search-backward KaTeX-math-cmd-regexp nil t arg))

(defun KaTeX-math-gets (sign)
  (cond
   ((null sign) nil)
   ((listp sign)
    (setq sign
	  (cond
	   (KaTeX-japan (KaTeX-math-japanese-sign sign))
	   (t (car sign))))
    (KaTeX-math-gets sign))
   ((symbolp sign)
    (KaTeX-math-gets (symbol-value sign)))
   (t sign))
)

(defun KaTeX-math-get-sign (list)
  (KaTeX-math-gets (car (cdr-safe (cdr-safe list))))
)

(defun KaTeX-in-math-mode-p ()
  "If current position is supposed to be in LaTeX-math-mode, return t."
  (or (KaTeX-quick-in-environment-p
       (append
	'("math" "eqnarray" "equation" "eqnarray*" "displaymath");LaTeX
	(if KaTeX-use-AMS-LaTeX
	    ;; And math modes of AMS-LaTeX
	  '("align" "align*" "split" "multline" "multline*" "gather"
	    "gather*" "aligned*" "gathered" "gathered*" "alignat"
	    "equation*" "cases"
	    "alignat*" "xalignat" "xalignat*" "xxalignat" "xxalignat*"))))
      (let*((p (point)) (nest 0) me0
	    (delim (concat KaTeX-sectioning-regexp "\\|^$\\|^\C-l"))
	    (boundary
	     (save-excursion
	       (if (looking-at delim)
		   (goto-char (max (point-min) (1- (point)))))
	       (re-search-backward delim nil 1)
	       (point))))
	(save-excursion
	  (cond
	   ((catch 'open
	      (save-excursion
		(while (and (>= nest 0)
			    (re-search-backward
			     (concat KaTeX-ec-regexp
				     "\\([()]\\|[][]\\)") boundary t))
		  (setq me0 (match-end 0))
		  (if (or (KaTeX-on-comment-p)
			  (KaTeX-literal-p))
		      nil
		    (progn
		      (if (or (= (char-after (1- me0)) #\))
			      (= (char-after (1- me0)) #\]))
			  (setq nest (1+ nest))
			(if (= (preceding-char) #\\ ) nil;;\\[5pt]
			  (setq nest (1- nest)))))))
		(if (< nest 0) (throw 'open t))))
	    t)
	   (t (catch 'dollar
		(while ;(search-backward "$" boundary t);little bit fast.
		  (KaTeX-re-search-active-backward ;;;;;; Too slow???
		    "\\$" (concat "[^\\\\]" KaTeX-comment-prefix) boundary t)
		  (cond
		   ((equal (char-after (1- (point))) #\$) ; $$ equation $$
		    (backward-char 1)
		    (setq nest (1+ nest)))
		   ((progn
		      (setq KaTeX-verbatim-environments
			    (append KaTeX-math-verbatim-environments
				    KaTeX-verbatim-environments))
		      (KaTeX-literal-p))
		    nil)
		   ((and (equal (char-after (1- (point))) #\\ )
			 (not (equal (char-after (- (point) 3)) #\\ )))
		    nil)		;\$
		   (t (setq nest (1+ nest))))
		)
		(if (= (% nest 2) 1) (throw 'dollar t))))))))
)

(defun KaTeX-math-display-list (list cols)
  (goto-char (point-max))
  (if (= cols 0) (if (not (eolp)) (newline 1))
    (progn
      (forward-line -1)
      (while (looking-at "[ \t\n]") (forward-line -1))))
  (end-of-line)
  (let ((indent (* KaTeX-math-display-width cols)) sign str to)
    (indent-to indent)
    (insert (car list))
    (indent-to (setq indent (+ indent KaTeX-math-max-key)))
    (insert "\\" (car (cdr list)))
    (setq indent (+ indent KaTeX-math-max-seq -1))
    (setq sign (KaTeX-math-get-sign list))
    (while (and sign (not (string= "" sign)))
      (setq to (string-match "\n" sign)
	    str (if to (substring sign 0 to) sign))
      (end-of-line)
      (indent-to indent)
      (insert str)
      (cond ((eobp) (newline 1))
	    ((> cols 0) (forward-line 1)))
      (setq sign (if to (substring sign (1+ to)) "")))))

(defvar KaTeX-math-menu-buffer "*math-mode-signs*")

(defun KaTeX-math-show-menu (match-str &optional alist)
  (save-window-excursion
    (KaTeX-showup-buffer KaTeX-math-menu-buffer nil t)
    (let ((maxcols (max 1 (/ (KaTeX-screen-width) KaTeX-math-sign-width)))
	  (cols 0) (list alist) command)
      (setq *case-fold-search* nil)
      (erase-buffer)
      (insert
       "Candidates of sign. [n:next p:prev f:forw b:back q:quit RET:select]\n")
      ;(insert KaTeX-math-indicator "\t") ;m.m ->
      ;(insert KaTeX-math-indicator)
      (dotimes (i maxcols)
	(indent-to (* i KaTeX-math-display-width))
	(insert KaTeX-math-indicator))    ;m.m <-
      (newline 1)
      (insert-char #\- (1- (KaTeX-screen-width)))
      (newline 1)
      (while list
	(if (string-match match-str (car (car list)))
	    (progn (KaTeX-math-display-list (car list) cols)
	      (setq cols (% (1+ cols) maxcols))))
	(setq list (cdr list)))
      (goto-line 4)
      (use-local-map KaTeX-math-menu-map)
      (setq buffer-read-only t)
      (set-buffer-modified-p nil)
      (unwind-protect
	  (recursive-edit)
	(skip-chars-backward "^ \t\n")
	(setq command
	      (if (re-search-forward KaTeX-math-cmd-regexp nil t)
		  (buffer-substring
		   (match-beginning 0)
		   (prog2 (skip-chars-forward "^ \t\n") (point)))
		nil))
	(kill-buffer KaTeX-math-menu-buffer)
	(clear-message)
      )
      command)))

(defun KaTeX-math-show-image (image &optional exit-char)
  "Momentarily display IMAGE at the beginning of the next line;
erase it on the next keystroke.  The window is recentered if necessary
to make the whole string visible.  If the window isn't large enough,
at least you get to read the beginning."
  (if (and image (not (string= image "")))
      (let ((modified (buffer-modified-p))
	    (name (get-buffer-file-name))
	    insert-start
	    insert-end)
	(setq buffer-read-only nil)
	(unwind-protect
	    (progn
	      (save-excursion
		;; defeat file locking... don't try this at home, kids!
		(setq buffer-file-name nil)
		(forward-line 1)
		(setq insert-start (point))
		(if (eobp) (newline))
		(insert image)
		(setq insert-end (point)))
	      ; make sure the whole string is visible
	      (if (not (pos-visible-in-window-p insert-end))
		  (recenter (max 0
				 (- (window-height)
				    (count-lines insert-start insert-end)
				    2))))
	      (refresh-screen) ;m.m
	      (let ((char (read-char)))
		(or (eq char exit-char)
		    (unread-char char) ;k.k
		    ;(setq unread-command-char char) ;m.m
		)))
	  (if insert-end
	      (save-excursion
		(delete-region insert-start insert-end)))
	  (setq buffer-file-name name)
	  (set-buffer-modified-p modified)))))

(defun KaTeX-math-insert-sequence (&optional force initial)
  "Insert math-mode sequence with image completion."
  (interactive "P")
  (let*((key (or initial "")) regkey str  last-char list i
	(case-fold-search nil) match sign
	(this-key *last-command-char*)
	(alistsym (cdr (assoc this-key KaTeX-math-key-list)))
	(alistname (symbol-name alistsym))
	(alist (symbol-value alistsym))
	(n (length alist)) (beg (point)) result)
    (if initial (insert KaTeX-ec (car (cdr (assoc initial alist)))))
    (if (string-match "^KaTeX-" alistname)
	(setq alistname (substring alistname (length "KaTeX-"))))
    (setq alistname (substring alistname 0 (string-match "-" alistname)))
    (setq result
	  (catch 'complete
	    (if (and (not force)
		     (if KaTeX-auto-math-mode
			 (not (KaTeX-in-math-mode-p))
		       (not KaTeX-math-mode)))
		(throw 'complete 'escape));this tag should be exit, but...
	    (while t
	      (message "~Asequence~A: ~A"
		       (if KaTeX-simple-messages "" (concat alistname " "))
		       (if KaTeX-simple-messages "" "(TAB for menu)") key)
	      (setq last-char (read-char)
		    key (concat key (char-to-string last-char))
		    i 0)

	      (cond
	       ((string= key this-key)	                ;;invoke key itself
		(throw 'complete 'escape))
	       ((string= key KaTeX-math-exit-key)	;;exit from math-mode
		(throw 'complete 'exit))
	       ((string-match "\r" key)			;;RET = kakutei
		(throw 'complete 'select))
	       ((string-match "[]" key)		;;C-g = abort
		(throw 'complete 'abort))
	       ((string-match "[\t\n]" key)		;;TAB, LFD = menu
		(throw 'complete 'menu))
	       ((string-match "[]" key)		;;BS, DEL = BS
		(if (< (length key) 2) (throw 'complete 'abort))
		(setq key (substring key 0 -2))
	       ))
	      (setq regkey (concat "^" (regexp-quote key)))
	      (message "Sequence~A: ~A"
		       (if KaTeX-simple-messages "" "(TAB for menu)") key)
	      (if
		  (catch 'found
		    ;;(1)input string strictly matches with alist
		    (setq match (assoc key alist))
		    ;;remember previous match

		    ;;(2)search partial match into alist
		    (setq list alist)
		    (while (< i n)
		      (if (string-match
			   regkey
			   ;;(aref array i)
			   ;;(car (nth i alist))
			   (car (car list)))
			  (progn
			    (or match
				;;(setq match (nth i alist))
				(setq match (car list)))
			    (throw 'found t)))
		      (setq i (1+ i) list (cdr list))))	;catch 'found
		nil ;;if any match, continue reading
		;;else reading of sequence has been done.
		(progn
		  (message "complete.")
		  (throw 'complete t)))

	      (if match
		  (progn (delete-region beg (point))
		    (setq single-command (car (cdr match)))
		    (insert KaTeX-ec single-command)
		    (if (and KaTeX-math-need-image
			     (setq sign (KaTeX-math-get-sign match)))
			(KaTeX-math-show-image (concat sign "\n")))
		  )
		nil)
	    )))
    (delete-region beg (point))
    (cond
     ((memq result '(t select))
      (if (eq result t)
	  (unread-char last-char) ;k.k
	(message "Done."))
      (if (assoc single-command section-table)
	  (KaTeX-make-section nil nil nil single-command)
	(progn
	  (setq KaTeX-current-completion-type 'maketitle)
	  (KaTeX-make-singlecmd single-command))))
     ((eq result 'abort)
      (message "Abort."))
     ((eq result 'escape)
      (call-interactively (global-key-binding this-key)))
     ((eq result 'exit)
      (KaTeX-toggle-math-mode))
     ((eq result 'menu)
      (setq key (concat "^" (regexp-quote (substring key 0 -1))))
      (insert (KaTeX-math-show-menu key alist))))))

;; ----- Change image completion types -----
(defun KaTeX-math-member-p (item)
  "Check if ITEM is a member of image completion.
If so return the cons of its invocation key and image-string."
  (let ((lists KaTeX-math-key-list) list)
    (catch 'found
      (while lists
	(setq list (symbol-value (cdr (car lists))))
	(while list
	  (if (string= item (nth 1 (car list)))
	      (throw 'found (cons (car (car lists)) (nth 0 (car list)))))
	  (setq list (cdr list)))
	(setq lists (cdr lists))))))

;;; ----- for AMS LaTeX (by matsu@math.s.chiba-u.ac.jp) -----
(defvar KaTeX-ams-paren-modifier
  '(("Biggl" . "Biggr") ("biggl" . "biggr")
    ("Bigl" . "Bigr") ("bigl" . "bigr")
    ("left" . "right") ("" . ""))
  "Alist of modifier of parentheses.")

(defvar KaTeX-left-paren "(\\|\\[\\|\\\\{")
(defvar KaTeX-right-paren ")\\|\\]\\|\\\\}")
(defvar KaTeX-paren
  (concat KaTeX-left-paren "\\|" KaTeX-right-paren))

(defun KaTeX-on-parenthesis-p ()
  "If cursor is on an (AMS-LaTeX) parenthesis, return the parenthesis."
  (interactive)
  (let* ((list KaTeX-ams-paren-modifier)
	 (longest 0) ;; the longest length of parenthesis command strings
	 (flag t) ;; flag for whether on braces not following \
	 (point (point))
	 (move 0)
	 (paren))
    (while list
      (setq longest
	    (max longest (length (car (car list))) (length (cdr (car list)))))
      (setq list (cdr list)))
    (save-excursion
      ;; search {} and, if it does not follow `\', set flag nil.
      ;; if it is right after `\', set flag t and move to the position of \.
      ;; mmmmm.
      (if (looking-at "{\\|}")
	  (if (not (equal (char-after (1- (point))) 92))
	      (setq flag nil)
	    (forward-char -1)))
      ;; if flag is nil, do nothing.
      (if (and flag (re-search-forward KaTeX-paren
				       (+ (point) 3 longest) t))
	  (progn
	    (setq move (- (point) point))
	    (setq paren (match-string 0))
	    (setq list KaTeX-ams-paren-modifier)
	    ;; criterion for whether on [] () \{\} or not.
	    (if (string-match KaTeX-left-paren paren)
		(while (and list flag)
		  (let* ((mod (car (car list)))
			 (mod-length 0) ;; length of modifier
			 paren-regexp ;; regexp of paren.
			 mod-regexp) ;; regexp of modifier.
		    (if (> (length mod) 0)
			(setq mod-regexp (concat "\\\\" mod)
			      mod-length (1+ (length mod))))
		    (cond ((string= paren "\\{")
			   (setq paren-regexp (concat "\\" paren)))
			  ((string= paren "[")
			   (setq paren-regexp "\\["))
			  (t (setq paren-regexp paren)))
		    (save-excursion
		      (if (and (>= (- (point) (point-min))
				   (+ mod-length (length paren)))
			       (not (forward-char
				     (- 0 mod-length (length paren))))
			       (looking-at (concat "\\(" mod-regexp "\\)\\("
						   paren-regexp "\\)")))
			  (setq flag nil)))
		    (setq list (cdr list))))
	      (while (and list flag)
		(let* ((mod (cdr (car list)))
		       (mod-length 0)
		       paren-regexp
		       mod-regexp)
		  (if (> (length mod) 0)
		      (setq mod-regexp (concat "\\\\" mod)
			    mod-length (1+ (length mod))))
		  (cond ((string= paren "\\}")
			 (setq paren-regexp (concat "\\" paren)))
			((string= paren "]")
			 (setq paren-regexp "\\]"))
			(t (setq paren-regexp paren)))
		  (save-excursion
		    (if (and (>= (- (point) (point-min))
				 (+ mod-length (length paren)))
			     (not (forward-char
				   (- 0 mod-length (length paren))))
			     (looking-at (concat "\\(" mod-regexp "\\)\\("
						 paren-regexp "\\)")))
			(setq flag nil)))
		  (setq list (cdr list)))))
	    (if (<= move (length (match-string 0)))
		(match-string 0)))))))

(defun KaTeX-goto-open-paren ()
  "Jump to the exact position of open parenthesis"
  (interactive)
  (let ((paren)
	(backslash-syntax (char-to-string (char-syntax #\\))))
    (if (setq paren (KaTeX-on-parenthesis-p))
	(if (string-match "(\\|{\\|\\[" paren (1- (length paren)))
	    (progn
	      (re-search-forward "(\\|{\\|\\[" (+ (point) (length paren)) t)
	      (backward-char))
	  (progn
	    (re-search-forward ")\\|}\\|\\]" (+ (point) (length paren)) t)
	    (unwind-protect
	        (progn
		  (modify-syntax-entry #\\ " ")
		  (backward-list))
	      (modify-syntax-entry #\\ backslash-syntax)))))))

(defun KaTeX-change-parentheses ()
  "Change the size of parentheses, braces, and brackets of AMS-LaTeX."
  (interactive)
  (if (not (and KaTeX-use-AMS-LaTeX (KaTeX-on-parenthesis-p)))
      nil
    (let* ((mod (match-string 1)) ;; modifier
	   (paren (if mod (match-string 2) (match-string 0))) ;; paren
	   (mod-length (if (or (string= mod "\\left") (string= mod "\\right"))
			   5            ;; 5 in case left or right
			 (length mod))) ;; length of modifier
	   (paren-length (length paren)) ;; length of paren
	   (length (+ mod-length paren-length)) ;; length of whole string
	   (big-p t) ;; flag whether new modifier is "[Bb]ig+" or not.
	   size ;; left, big, Big etc.
	   lr   ;; "l" or "r".
	   char newsize newsize-length
	   (backslash-syntax (char-to-string (char-syntax #\\)))
	   (case-fold-search))
      ;; decide lr and size from mod and paren.
      (cond ((string-match "\\(\\\\[Bb]ig+\\)[lr]" mod)
	     (setq size (substring mod 1 (match-end 1))
		   lr (substring mod (match-end 1) (match-end 0))))
	    ((string-match "\\\\left" mod)
	     (setq size "left-right" lr "l"))
	    ((string-match "\\\\right" mod)
	     (setq size "left-right" lr "r"))
	    ((string-match "(\\|\\[\\|\\\\{" paren)
	     (setq size "null" lr "l"))
	    ((string-match ")\\|\\]\\|\\\\}" paren)
	     (setq size "null" lr "r"))
	    (t
	     (setq size nil lr nil)))
      (while (not newsize)
	(message (format nil (concat "Change from ~A: "
				 "l(big) L(Big) h(bigg) H(Bigg) "
				 "r(left-right) n(NONE) ") size))
	(setq char (read-char)
	      newsize (cond ((char-equal char #\l) "\\big")
			    ((char-equal char #\L) "\\Big")
			    ((char-equal char #\h) "\\bigg")
			    ((char-equal char #\H) "\\Bigg")
			    ((char-equal char #\r)
			     (setq big-p nil) "\\left")
			    ((char-equal char #\n)
			     (setq big-p nil) "")
			    (t nil))
	      newsize-length (length newsize)))
      (KaTeX-goto-open-paren)
      (forward-char)
      (delete-region (- (point) length) (- (point) paren-length))
      (backward-char paren-length)
      (insert-string newsize)
      (if big-p (insert #\l))
      (forward-char (1- paren-length))
      (unwind-protect
	  (progn
	    (modify-syntax-entry #\\ " ")
	    (forward-list)
	    (if (string= size "left-right") (setq length (1+ length)))
	    (if (eq char #\r) (setq newsize "\\right"))
	    (delete-region (- (point) length) (- (point) paren-length))
	    (backward-char paren-length)
	    (insert-string newsize)
	    (if big-p (insert #\r))
	    (forward-char paren-length)
	    (if (string= lr "l") (backward-list)))
	(modify-syntax-entry #\\ backslash-syntax))
      t)))

(defun KaTeX-insert-amsparens-region (beg end char)
  (interactive "r\ncWhich one ? l(big) L(Big) h(bigg) H(Bigg): ")
  (let* ((case-fold-search)
	 (st (cond ((char-equal char #\l) "big")
		   ((char-equal char #\L) "Big")
		   ((char-equal char #\h) "bigg")
		   ((char-equal char #\H) "Bigg")))
	 tmp)
    (when (> beg end)
      (setq tmp beg)
      (setq beg end)
      (setq end tmp))
    (if st
	(KaTeX-insert-braces-region
	 beg end (concat "\\" st "l(") (concat "\\" st "r)"))
      (KaTeX-insert-braces-region beg end "(" ")"))))

(defun KaTeX-insert-amsbraces-region (beg end char)
  (interactive "r\ncWhich one ? l(big) L(Big) h(bigg) H(Bigg): ")
  (let* ((case-fold-search)
	 (st (cond ((char-equal char #\l) "big")
		   ((char-equal char #\L) "Big")
		   ((char-equal char #\h) "bigg")
		   ((char-equal char #\H) "Bigg")))
	 tmp)
    (when (> beg end)
      (setq tmp beg)
      (setq beg end)
      (setq end tmp))
    (if st
	(KaTeX-insert-braces-region
	 beg end (concat "\\" st "l\\{") (concat "\\" st "r\\}"))
      (KaTeX-insert-braces-region beg end "\\{" "\\}"))))

(defun KaTeX-insert-amsbrackets-region (beg end char)
  (interactive "r\ncWhich one ? l(big) L(Big) h(bigg) H(Bigg): ")
  (let* ((case-fold-search)
	 (st (cond ((char-equal char #\l) "big")
		   ((char-equal char #\L) "Big")
		   ((char-equal char #\h) "bigg")
		   ((char-equal char #\H) "Bigg")))
	 tmp)
    (when (> beg end)
      (setq tmp beg)
      (setq beg end)
      (setq end tmp))
    (if st
	(KaTeX-insert-braces-region
	 beg end (concat "\\" st "l[") (concat "\\" st "r]"))
      (KaTeX-insert-braces-region beg end "[" "]"))))


;;

; Local variables: 
; fill-prefix: ";;;	" 
; paragraph-start: "^$\\|\\|;;;$" 
; paragraph-separate: "^$\\|\\|;;;$" 
; End: 
