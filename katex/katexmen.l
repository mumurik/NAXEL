;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX menu functions.
;;; katexmen.l, v 1.67.1.10
;;; (c ) 2000-2001 Maeda Manabu
;;; Last fixed  "Thu Jul 22 2004 22:22:17 +0900"

(provide "katexmen")

(in-package "elisp")

(defvar *KaTeX-menu-tag* 'KaTeX)
(defvar *KaTeX-menu-name* "KaTeX(&K)")

(defvar *KaTeX-menu-default* nil)
(defvar *KaTeX-menu-list* nil)

(defvar *section-menu-long-name* nil)

(defun KaTeX-menu-update (&optional force)
  (use-local-menu (KaTeX-add-menu)))

(defun KaTeX-add-menu (&optional force)
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'ed::help)
;		       (or
;			(KaTeX-menu-for-selected-buffer force)
			(KaTeX-about-menu) *KaTeX-menu-name*)
;    )
    menu))

(defun KaTeX-about-menu ()
  (or *KaTeX-menu-default*
      (setq *KaTeX-menu-default*
	    (KaTeX-menu-map (create-popup-menu nil)))))

(defun KaTeX-menu-list-init ()
  (unless *KaTeX-menu-list*
    (push (list KaTeX-typeset-buffer nil 'KaTeX-typeset-menu) *KaTeX-menu-list*)
    (push (list KaTeX-math-menu-buffer nil 'KaTeX-mat-menu) *KaTeX-menu-list*)
    (push (list KaTeX-label-buffer nil 'KaTeX-label-menu) *KaTeX-menu-list*)
    (push (list *KaTeX-buffer-group* nil 'KaTeX-group-menu) *KaTeX-menu-list*)
    (push (list *KaTeX-buffer-grep* nil 'KaTeX-grep-menu) *KaTeX-menu-list*)
    (push (list *KaTeX-buffer-send* nil 'KaTeX-send-menu) *KaTeX-menu-list*)
    (push (list *KaTeX-buffer-header* nil 'KaTeX-header-menu) *KaTeX-menu-list*)
    (push (list nil nil 'KaTeX-about-menu) *KaTeX-menu-list*)
  ))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro KaTeX-menu-menu (menu)
    `(cadr ,menu))

  (defmacro KaTeX-menu-func (menu)
    `(caddr ,menu))

  (defmacro KaTeX-buffer-menu (buffer)
    `(assoc ,buffer *KaTeX-menu-list* :test #'equal))
)

(defun KaTeX-menu-for-selected-buffer (&optional force)
  (let ((buffer (buffer-name (selected-buffer)))
	menu-list
	menu)
    (unless (setq menu-list (KaTeX-buffer-menu buffer))
      (setq buffer nil)
      (unless (setq menu-list (KaTeX-buffer-menu buffer))
	(error "No menu")))
    (if (and (not force)
	     (setq menu (KaTeX-menu-menu menu-list)))
	menu
      (if (setq menu (funcall (KaTeX-menu-func menu-list)))
	  (progn
	    (setf (KaTeX-menu-menu (KaTeX-buffer-menu buffer)) menu)
	    menu)
	(error "No menu")))))

(defvar KaTeX-mode-menu-map-env (create-popup-menu 'env))
(defvar KaTeX-mode-menu-map-envr (create-popup-menu 'envr))

(let ((sorted-env
       (sort
	(mapcar (function (lambda (s) (car s)))
		(append env-table user-env-table))
	'string<)))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-env
   (mapcar
    (function (lambda (envname)
		(cons (intern envname)
		      (cons envname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-insert-begin-end
					envname nil))))))
    sorted-env))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-envr
   (mapcar 
    (function (lambda (envname)
		(cons (intern envname)
		      (cons envname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-insert-begin-end
					envname t))))))
    sorted-env)))

(defvar KaTeX-mode-menu-map-section (create-popup-menu 'section))
(defvar KaTeX-mode-menu-map-sectionr (create-popup-menu 'sectionr))

(let ((sorted-section
       (sort
	(delq nil
	      (mapcar (function (lambda (s)
							  (if *section-menu-long-name*
								  (if (> (length (car s)) 5)
									  (car s))
								(car s))))
		      (append section-table user-section-table)))
	'string<)))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-section
   (mapcar
    (function (lambda (secname)
		(cons (intern secname)
		      (cons secname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-make-section
					nil nil nil
					secname))))))
    sorted-section))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-sectionr
   (mapcar 
    (function (lambda (secname)
		(cons (intern secname)
		      (cons secname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-make-section
					nil
					(list 'region-beginning)
					(list 'region-end)
					secname))))))
    sorted-section)))

(defvar KaTeX-mode-menu-map-fontsize (create-popup-menu 'fontsize))
(defvar KaTeX-mode-menu-map-fontsizer (create-popup-menu 'fontsizer))

(let ((sorted-fontsize
	   (sort
		(delq nil
			  (mapcar (function (lambda (s) (car s)))
					  (append fontsize-table user-fontsize-table)))
		'string<)))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-fontsize
   (mapcar
    (function (lambda (fsname)
		(cons (intern fsname)
		      (cons fsname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-make-fontsize
					nil fsname))))))
    sorted-fontsize))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-fontsizer
   (mapcar 
    (function (lambda (fsname)
		(cons (intern fsname)
		      (cons fsname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-make-fontsize
					t fsname))))))
    sorted-fontsize)))

(defvar KaTeX-mode-menu-map-singlecmd (create-popup-menu 'singlecmd))

(let ((sorted-singlecmd
	   (sort
		(delq nil
			  (mapcar (function (lambda (s) (car s)))
					  (append singlecmd-table user-singlecmd-table)))
		'string<)))
  (KaTeX-define-menu
   KaTeX-mode-menu-map-singlecmd
   (mapcar
    (function (lambda (cmdname)
		(cons (intern cmdname)
		      (cons cmdname
			    (list 'lambda ()
				  (list 'interactive)
				  (list 'KaTeX-make-singlecmd
					cmdname))))))
    sorted-singlecmd)))

(defvar KaTeX-mode-menu-map-jump (create-popup-menu 'jump))

(KaTeX-define-menu
 KaTeX-mode-menu-map-jump
 '((corres     "Goto corresponding position" . KaTeX-goto-corresponding-*)
   (main      "Visit main source"
	      . (lambda () (interactive) (KaTeX-visit-main)))
   (main-other "Visit main source other window"
	       . KaTeX-visit-main-other-window)))

(defvar KaTeX-mode-menu-map-percent (create-popup-menu 'percent))

(KaTeX-define-menu
 KaTeX-mode-menu-map-percent
  '((!		"Change LaTeX typesetter(%#!)"
		. (lambda () (interactive) (KaTeX-%-menu nil nil #\!)))
    (begend	"Set %#BEGIN-%#END on region"
		. (lambda () (interactive) (KaTeX-%-menu nil nil #\b)))
    (lpr 	"Change LPR format"
		. (lambda () (interactive) (KaTeX-%-menu nil nil #\l)))))

(defvar KaTeX-mode-menu-map-modes (create-popup-menu 'mode))

(KaTeX-define-menu
 KaTeX-mode-menu-map-modes
 (delq nil
	(list
	 (if KaTeX-auto-math-mode nil
	   (cons 'math (cons "Toggle math-mode"
			     '(lambda () (interactive)
				(KaTeX-switch-mode-menu nil #\t)))))
	 (cons 'mod (cons "Toggle Modify Mode"
			  '(lambda () (interactive)
			     (KaTeX-switch-mode-menu nil #\m)))))))

(defvar KaTeX-mode-menu-map-process (create-popup-menu 'process))

(KaTeX-define-menu
 KaTeX-mode-menu-map-process
  '((buffer "LaTeX" . (lambda () (interactive) (KaTeX-typeset-menu nil #\j)))
	(bibtex "BibTeX" . (lambda () (interactive) (KaTeX-typeset-menu nil #\b)))
	(mindex "makeindex" . (lambda () (interactive) (KaTeX-typeset-menu nil #\i)))
	(preview "Preview" . (lambda () (interactive) (KaTeX-typeset-menu nil #\p)))
   ))

(defun KaTeX-menu-map (menu)
  (add-popup-menu menu KaTeX-mode-menu-map-env "Environment")
  (add-popup-menu menu KaTeX-mode-menu-map-envr "Environment region")
  (add-menu-item menu 'end "Insert end environment" 'KaTeX-end-environment)
  (add-popup-menu menu KaTeX-mode-menu-map-section "Section type")
  (add-popup-menu menu KaTeX-mode-menu-map-sectionr "Section type region")
  (add-popup-menu menu KaTeX-mode-menu-map-fontsize "Fontsize type")
  (add-popup-menu menu KaTeX-mode-menu-map-fontsizer "Fontsize type region")
  (add-popup-menu menu KaTeX-mode-menu-map-singlecmd "Single command")
  (add-menu-item menu 'acc "Accent" 'KaTeX-make-accent)
  (add-menu-item menu 'chg "Change macros" 'KaTeX-change-*)
  (add-menu-item menu 'kill "Kill macros" 'KaTeX-kill-*)
  (add-menu-item menu 'fill "Fill \\item" 'KaTeX-fill-item)
  (add-menu-item menu 'nl "Newline" 'KaTeX-intelligent-newline)
  (add-menu-separator menu nil)
  (add-menu-item menu 'comment "Comment region or environment" 'KaTeX-comment-region)
  (add-menu-item menu 'uncomment "Uncomment region or environment" 'KaTeX-uncomment-region)
  (add-menu-item menu 'commentp "Comment paragraph" 'KaTeX-comment-paragraph)
  (add-menu-item menu 'uncommentp "Uncomment paragraph" 'KaTeX-uncomment-paragraph)
  (add-menu-separator menu nil)
  (add-popup-menu menu KaTeX-mode-menu-map-jump "Jump Cursor")
  (add-menu-item menu 'hier "Display Document hierarchy" 'KaTeX-display-hierarchy)
  (add-menu-item menu 'col "What column in tabular" 'KaTeX-what-column)
  (add-popup-menu menu KaTeX-mode-menu-map-percent "Edit %# notation")
  (add-popup-menu menu KaTeX-mode-menu-map-modes "Switching KaTeX's modes")
  (add-menu-separator menu nil)
  (add-menu-item menu 'ap "Apropos on LaTeX commands" 'KaTeX-apropos)
  (add-menu-item menu 'help "Help on LaTeX commands" 'KaTeX-help)
  (add-popup-menu menu KaTeX-mode-menu-map-process "Process menu")
  menu)
