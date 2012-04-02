;;; -*- Mode: Lisp; -*-
;;;
;;; Modified by mumurik765 2012-04-02
;;; Author: Maeda Manabu
;;
;;; Emacs Lisp から xyzzy lisp への変換
;;;
;;;
;;;

; 注意
; 文字(char)と整数。
; defcustom もあやしい。
; kill-emacs の引数は無効です。
; modify-syntax-entry は、set-syntax- で書き換えた方が無難。
; lookup-key は、key を string から list に変更する。
; define-key は、key を string から list に変更する。
; get-lru-window は一番昔に使ったwindowを返しません。
; minibuffer-setup-hook を *enter-minibuffer-hook* に変更する。
; minibuffer-exit-hook を *exit-minibuffer-hook* に変更する。
; enable-recursive-minibuffers を *enable-recursive-minibuffers* に変更する。
; start-process は make-process で書き換えた方がよい。
; intern, intern-soft, mapatoms, unintern の引数は package に変更する。
; substring, concat の引数にベクトルは無理。
; last-command, last-command-char を *last-command*, *last-command-char* に変更する。
; *elisp-use-message-buffer* は t で message バッファを作ってそこにも出力する。

;; TODO
;; major-mode
;; momentary-string-display
;; forward-sexp いまいち動作が違う気がする
;; replace-match
;; buffer-display-time
;; set-mark-command 引数の処置
;; fill 関係 (justify)
;; downcase, upcase の引数が char の場合、整数にすべき?
;; split-string 微妙に動作が違う。

;;; 使用不能
;;; defgroup
;;; minibuffer-complete-and-exit
;;; meta-prefix-char
;;; set-process-buffer
;;; previous-history-elementとか
;;; view-file
;;; hook は hook にかけとく
;;; list-buffers-directory
;;; temp-buffer-show-function
;;; temp-buffer-show-hook
;;; top-level
;;; thing-at-point
;;; start-process-shell-command
;;; process-connection-type
;;; process-tty-name
;;; interprogram-paste-function
;;; interprogram-cut-function
;;; set-frame-position, x-parse-geometry 無理
;;; frame-pixel-height, frame-pixel-width
;;; frame-char-height, frame-char-width
;;; set-frame-size, set-frame-height, set-frame-width
;;; write-file-hooks, local-write-file-hooks
;;; write-contents-hooks, after-save-hook
;;; file-precious-flag, require-final-newline
;;; word-search-forward, word-search-backward
;;; generate-new-buffer-name
;;; get-buffer-window-list
;;; window-start, window-end, set-window-start
;;; backward-delete-char-untabify-method
;;; fill-individual-paragraphs, fill-individual-varying-indent
;;; justify-current-line, default-justification, current-justification
;;; sentence-end-double-space
;;; use-hard-newlines
;;; file-accessible-directory-p, access-file
;;; file-ownership-preserved-p
;;; upcase-initials
;;; string-to-number
;;; file-relative-name, substitute-in-file-name

(provide "emacs")

;;->howm
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))

(in-package "winapi")

(c:*define-c-struct FILETIME
  (DWORD dwLowDateTime)
  (DWORD dwHighDateTime))

(c:*define-c-type (FILETIME *) LPFILETIME)

(unless (fboundp 'GetFileTime)
  (c:*define-dll-entry BOOL GetFileTime
    (HANDLE LPFILETIME LPFILETIME LPFILETIME)
    "kernel32"))

(unless (fboundp 'CreateFile)
  (c:*define-dll-entry HANDLE CreateFile
    (LPCSTR DWORD DWORD (c:void *) DWORD DWORD HANDLE)
    "kernel32" "CreateFileA"))

(unless (fboundp 'CloseHandle)
  (c:*define-dll-entry BOOL CloseHandle
    (HANDLE)
    "kernel32"))
;;<-howm

(require "elisp")
(in-package "elisp")

;;;
;;; 変数
;;;

(setq *recursive-minibuffer-map* (copy-keymap minibuffer-local-map))
(setq *enable-recursive-minibuffers* t)
(global-set-key #\C-M-c 'exit-recursive-edit)

(defvar system-type 'ms-dos)
(defvar emacs-version "20")
(defvar window-system t)

(defvar window-min-height 5)
(defvar window-min-width (* window-min-height 2))
(defvar minibuffer-scroll-window nil)
(defvar other-window-scroll-buffer nil)
(defvar next-screen-context-lines 2)
(defvar scroll-margin *scroll-margin*)
(defvar shell-file-name *shell*)
(defvar minibuffer-completion-table (minibuffer-completion-list))
(defvar minibuffer-completion-predicate nil)
(defvar minibuffer-completion-confirm nil)
(defvar *recursive-depth* 0)
(defvar *minibuffer-depth* -1)
(defvar regexp-search-ring nil)
(defvar doc-directory "etc")
(defvar exec-directory nil)
(defvar exec-path (ignore-errors
                   (let ((pre 0)(post 0)(string nil))
                     (loop
                       (unless (setq post (string-match ";" (si:getenv "PATH") pre))
                         (push (substring (si:getenv "PATH") pre post) string)
                         (return (reverse string)))
                       (push (substring (si:getenv "PATH") pre post) string)
                       (setq pre (1+ post)))
                   )))
(defvar minor-mode-map-alist nil)
(defvar minor-mode-overriding-map-alist nil)
(defvar overriding-local-map nil)
(defvar overriding-terminal-local-map nil)
(defvar overriding-local-map-menu-flag nil)
(defvar special-event-map nil)
(defvar text-mode-hook *text-mode-hook*)
(defvar text-mode-syntax-table *text-mode-syntax-table*)
(defvar c-mode-syntax-table editor::*c-mode-syntax-table*)
(defvar emacs-lisp-mode-syntax-table editor::*lisp-mode-syntax-table*)
(defvar insert-default-directory nil)
(defvar completion-list-column nil)
(defvar completion-related-buffer nil)
(defvar completion-prefix nil)
(defvar completion-line 5)
(defvar completion-last-string "")
(defvar *original-auto-fill-hook nil)
;(defvar *original-auto-fill-hook *auto-fill-hook)

(defvar-local mark-ring nil)
(defvar-local default-directory (default-directory))
(defvar-local global-map *global-keymap*)
(defvar-local major-mode nil)
;(defvar-local major-mode buffer-mode)
(defvar-local standard-input *standard-input*)
(defvar-local standard-output *standard-output*)
(defvar-local mark-ring nil)
(defvar-local mark-ring nil)
(defvar-local buffer-display-time nil)
(defvar-local fill-paragraph-function nil)

;! \" # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @
;A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \\ ] ^ _ `
;a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~
(unless (boundp '?!)
  (let (x)
    (do ((x #x21 (1+ x)))((>= x #x7f))
      (let ((c (code-char x)))
        (when (characterp c)
          (setq c (string c))
          (set (intern (concat "?" c)) (character c))
          (si:*make-constant (intern (concat "?" c))))
      ))))

(defvar *display-completion-list-map* nil)
(unless *display-completion-list-map*
  (setq *display-completion-list-map* (make-sparse-keymap))
  (define-key *display-completion-list-map* #\Left    'display-completion-Left)
  (define-key *display-completion-list-map* #\Right    'display-completion-Right)
  (define-key *display-completion-list-map* #\Up    'display-completion-Up)
  (define-key *display-completion-list-map* #\Down    'display-completion-Down)
  (define-key *display-completion-list-map* #\RET    'display-completion-RET))

(defun display-completion-Left ()
  (interactive)
  (if (< (current-line-number) 5)
      (progn
        (goto-line 5)
        (beginning-of-line))
    (or (and (bolp)
             (backward-line 1)
             (goto-column completion-column))
        (beginning-of-line))))

(defun display-completion-Right ()
  (interactive)
  (if (< (current-line-number) 5)
      (progn
        (goto-line 5)
        (beginning-of-line))
    (or (and (bolp)
             (goto-column completion-column))
        (progn
          (forward-line 1)
          (beginning-of-line)))))

(defun display-completion-Up ()
  (interactive)
  (if (< (current-line-number) 6)
      (progn
        (goto-line 5)
        (beginning-of-line))
    (previous-virtual-line)))

(defun display-completion-Down ()
  (interactive)
  (if (< (current-line-number) 5)
      (progn
        (goto-line 5)
        (beginning-of-line))
    (next-virtual-line)))

(defun display-completion-RET ()
  (interactive)
  (let ((w (when completion-related-buffer
             (get-buffer-window completion-related-buffer)))
        (cb (selected-buffer)))
    (unless w
      (return-from display-completion-RET nil))
    (unless (prog2
                (set-buffer completion-related-buffer)
                (looking-back completion-last-string)
              (set-buffer cb))
      (return-from display-completion-RET nil))
    (if (< (current-line-number) completion-line)
        (progn
          (goto-line completion-line)
          (beginning-of-line))
      (let ((s (nth (if (= completion-list-column 2)
                        (+ (* (- (current-line-number) completion-line) 2)
                           (if (< (current-column) completion-column) 0 1))
                      (- (current-line-number) completion-line))
                    completion-list))
            (flag 'nil))
        (unless (stringp s)
          (plain-error))
        (when (stringp completion-prefix)
          (setq s (concatenate 'string completion-prefix s)))
        (save-excursion
          (set-buffer completion-related-buffer)
          (let (beg (end (point)))
            (save-excursion
              (ignore-errors
               (scan-buffer "[ \t　]+" :reverse t :regexp t :tail t
                            :limit (progn (beginning-of-line) (point))))
              (setq beg (point)))
            (setq flag
                  (ignore-errors
                   (scan-buffer completion-last-string :reverse t :limit beg)))
            (and flag
                 (delete-region (point) end))
          ))
        (delete-buffer (selected-buffer))
        (set-window w)
        (and flag (insert s))
      ))))

;;;
;;; hook
;;;

(defun fill-with-indent ()
  "fillしたついでにindent"
  (interactive)
  (unless mode-specific-indent-command
    (save-excursion
      (beginning-of-line)
      (indent-relative))
    (when (bolp)
      (skip-chars-forward " \t")))
  t )

(add-hook 'auto-fill-hook #'fill-with-indent t)
(add-hook 'fill-region-hook #'fill-with-indent t)

(defun set-default-directory-in-find-file ()
  (interactive)
  (setq default-directory (default-directory)))

(add-hook '*find-file-hooks* #'set-default-directory-in-find-file)

(add-hook '*enter-minibuffer-hook*
      #'(lambda (buffer history) (interactive)
          (setq *minibuffer-depth* (1+ *minibuffer-depth*))))
(add-hook '*exit-minibuffer-hook*
      #'(lambda (buffer history) (interactive)
          (setq *minibuffer-depth* (1- *minibuffer-depth*))))

(unless *original-auto-fill-hook
  (defun turn-do-auto-fill (c)
    "auto-fillを繰り返し実行する"
    (unless (plusp fill-column)
      (return-from turn-do-auto-fill nil))
    (while (and (>= (current-column) fill-column)
		(funcall *original-auto-fill-hook c))
      (refresh-screen))
    )
  (setq *original-auto-fill-hook *auto-fill-hook)
  (setq *auto-fill-hook 'turn-do-auto-fill)
  )

(defvar *elisp-use-message-buffer* nil)
(when *elisp-use-message-buffer*
  (require "message"))

;;;
;;; 関数
;;;

;;; 亀井さんより ->
(lisp:defun fset (name def)
  (or (eq (symbol-package name) (find-package "elisp"))
      (error "conflict fset: ~S" name))
  (si:*fset name def))

(defmacro elisp-shadow (x)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (shadow ,x)))

(elisp-shadow '(defun))
(defmacro defun (name (&rest lambda-list) &body body)
  (or (eq (symbol-package name) (find-package "elisp"))
      (error "conflict defun: ~S" name))
  (let (decl intr)
    (multiple-value-setq (decl body)
      (lisp::find-declaration body))
    (multiple-value-setq (intr body)
      (lisp::find-interactive body))
    `(lisp::defun ,name ,lambda-list
       ,@decl
       ,@(lisp::if (and intr (stringp (cadar intr)))
             `((,@(car intr) :emacs t)) intr)
       ,@body)))
;;; <-
(elisp-shadow '(defmacro))
(si:*fset 'defmacro
          '(macro (name (&rest lambda-list) &body body)
            (or (eq (symbol-package name) (find-package "elisp"))
                (error "conflict defmacro: ~S" name))
            `(si:*fset ',name '(macro ,lambda-list ,@body))))

(defmacro defcustom (option default doc &key ((:type type))
                            ((:options list))
                            ((:version version))
                            ((:set setfunction))
                            ((:get getfunction))
                            ((:initialize function))
                            ((:require require)))
  `(progn
     (si:*make-special ',option)
     (set ',option ,default)
     ,(lisp::if doc
          `(si:*putprop ',option ,doc 'variable-documentation))
     ',option))

(elisp-shadow '(defvar))
(defmacro defvar (name &optional (initial-value nil sv) doc)
  `(progn
     ;(si:*make-special ',name) ; nospecial
     ,(if doc
	  `(si:*putprop ',name ,doc 'variable-documentation))
     ,(if sv
	  `(or (boundp ',name)
	       (set ',name ,initial-value)))
     ',name))

(fset 'fset #'system:*fset)

(fset 'defconst #'defconstant)

(fset 'defsubst #'defun)
(fset 'defalias #'system:*fset)

(elisp-shadow '(if))
(defmacro if (test then &rest else)
  `(lisp::if ,test
       ,then
     (progn ,@else)))

;;->howm
;; modifyed Katsutoshi Yokoi <yokoi@math.nagoya-u.ac.jp>
;; let の変数をスペシャル変数に。
(elisp-shadow '(let))
(defmacro let (vars &body body)
  (lisp::let (dec)
    (dolist (v vars)
      (cond
       ((consp v)
	(push (car v) dec));(push (list 'special (car v)) dec)
       (t
	(push v dec))));(push (list 'special v) dec)
    (when dec
      (setq dec `(declare (special ,@(reverse dec)))) ; modifyed ;k.y
;      (setq dec (append '(special) (reverse dec))) ; modifyed ;k.y
;      (setq dec (append '(declare) dec)) ; modifyed ;k.y
      )
    `(lisp::let ,vars
       ,dec
       ,@body)))
;; let* の変数をスペシャル変数に。
(elisp-shadow '(let*))
(defmacro let* (vars &body body)
  (lisp::let (dec)
    (dolist (v vars)
      (cond
       ((consp v)
	(push (car v) dec));(push (list 'special (car v)) dec)
       (t
	(push v dec))));(push (list 'special v) dec)
    (when dec
      (setq dec `(declare (special ,@(reverse dec)))) ; modifyed ;k.y
;      (setq dec (append '(special) (reverse dec))) ; modifyed ;k.y
;      (setq dec (append '(declare) (reverse dec))) ; modifyed ;k.y
      )
    `(lisp::let* ,vars
       ,dec
       ,@body)))
;;<-howm

(elisp-shadow '(make-local-variable))
(defun make-local-variable (sym)
  (ed::make-local-variable sym)
  sym) ;m.m

(defun kill-emacs (&optional exit-data)
  "exit-dataは使えません"
  (interactive)
  (setq *kill-xyzzy-hook* kill-emacs-hook)
  (kill-xyzzy))

(fset 'set-syntax-table #'use-syntax-table)

;(defun char-syntax (character)
;  (interactive)
;)

(defun modify-syntax-entry (char syntax-descriptor &optional table)
  (interactive "cSet syntax for character:\nsSet syntax to:")
  (cond
   ((string-match "^[ -]" syntax-descriptor)
    (set-syntax-whitespace table (character char)))
   ((string-match "^w" syntax-descriptor)
    (set-syntax-word table (character char)))
   ((string-match "^_" syntax-descriptor)
    (set-syntax-symbol table (character char)))
   ((string-match "^." syntax-descriptor)
    (set-syntax-punctuation table (character char)))
   ((string-match "^(" syntax-descriptor)
    (set-syntax-match table (character char)
		      (character (substring syntax-descriptor 1 2))))
   ((string-match "^)" syntax-descripter)
    (set-syntax-match table (character (substring syntax-descriptor 1 2))
		      (character char)))
   ((string-match "^\"" syntax-descripter)
    (set-syntax-string table (character char)))
   ((string-match "^\\" syntax-descriptor)
    (set-syntax-escape table (character char)))
   ((string-match "/" syntax-descriptor)
    (set-syntax-quote table (character char)))
   ((string-match "^\$" syntax-descriptor)
    (set-syntax-math table (character char)))
   ((string-match "^'" syntax-descriptor)
    (set-syntax-symbol-prefix table (character char)))
   ((string-match "^<" syntax-descriptor)
    (set-syntax-start-comment table (character char)))
   ((string-match "^>" syntax-descriptor)
    (set-syntax-end-comment table (character char)))
   ;((string-match "" syntax-descriptor)
   ; (set-syntax- table (character char)))
   ;((string-match "" syntax-descriptor)
   ; (set-syntax- table (character char)))
   ;((string-match "" syntax-descriptor)
   ; (set-syntax- table (character char)))
   ;((string-match "" syntax-descriptor)
   ; (set-syntax- table (character char)))
   ))

(defun skip-syntax-forward (syntaxes &optional limit)
  (seve-restriction
   (narrow-to-region (point) limit)
   (skip-syntax-spec-forward syntaxes)))

(defun skip-syntax-backward (syntaxes &optional (limit (point-max)))
  (seve-restriction
   (narrow-to-region (point) limit)
   (skip-syntax-spec-backward syntaxes)))

;(defun backward-prefix-chars ()
;   "この関数は、式前置子構文の文字を飛び越えてポイントを後方へ向けて移動
;する。式前置子クラスやフラグ`p'を持つ文字を飛び越す。"
;  (skip-syntax-spec-backward "'"))

(fset 'standard-syntax-table #'editor::make-syntax-table)

(defun current-local-map ()
  (local-keymap))

(defun current-minor-mode-maps ()
  (minor-mode-map))

(defun use-global-map (map)
  (setq *global-keymap* map))

(defun use-local-map (map)
  (use-keymap map))

(defun current-global-map ()
  (interactive)
  *global-keymap*)

(defun marge-keymap (mainmap submap)
  (interactive)
  (let ((map (copy-keymap mainmap)))
    (dolist (i submap)
      (cond
       ((and (or (listp i)
                 (consp i))
             (not (member (car i) (cdr map) :test #'equal :key #'car)))
        (push i (cdr map)))
       ((and (listp i)
             (> (length i) 2)
             (eq (cadr i) 'keymap))
        (let ((mmap (marge-keymap (cdar (member (car i) (cdr map)
                                                :test #'equal :key #'car))
                                  (cdr i)))
              tmap listmap)
          (while (or (not (consp (setq tmap (pop map))))
                     (not (eq (car i) (car tmap))))
            (push tmap listmap))
          (push (car i) mmap)
          (push mmap map)
          (while listmap
            (push (pop listmap) map))))
      ))
    map
  ))

(defun lookup-key (keymap key &optional accept-default)
  (let ((result (lookup-keymap keymap key)))
    (unless result
      (when accept-default
        (setf result (lookup-keymap *global-keymap* key))))
    result))

;(defun key-binding (key &optional accept-default)
;  "マイナーマップもかな？"
;  (lookup-key (local-keymap) key accept-default))

(defun local-key-binding (key &optional accept-default)
  (lookup-key (local-keymap) key accept-default))

(defun global-key-binding (key &optional accept-default)
  (lookup-key *global-keymap* key accept-default))

;(defun minor-mode-key-binding (key &optional accept-default)
;  (lookup-key (minor-mode-map) key accept-default))


(defun suppress-keymap (map &optional nodigits)
  "Make MAP override all normally self-inserting keys to be undefined.
Normally, as an exception, digits and minus-sign are set to make prefix args,
but optional second arg NODIGITS non-nil treats them like other chars."
  (substitute-key-definition 'self-insert-command 'undefined map *global-keymap*)
  (or nodigits
      (progn
        (define-key map #\- #'negative-argument)
        ;; Make plain numbers do numeric args.
        (dotimes (digit 10)
          (define-key map (digit-char digit) #'digit-argument)))))

(defun read-key-sequence (prompt)
  (let (func (string "") c)
    (catch 'anstag
      (while t
        (minibuffer-prompt prompt)
        (refresh-screen)
        (setq c (read-char *keyboard*))
        (setq func (local-key-binding c t))
        (setq string (concat string (string c)))
        (unless (keymapp func)
          (throw 'anstag 'exit))
      ))
    string))

(defun move-to-column (column &optional force)
  (interactive "p")
  (goto-column column))

(defun count-lines (start end)
  (interactive "r")
  (let (startl endl result)
    (save-excursion
      (goto-char start)
      (setq startl (current-line-number))
      (goto-char end)
      (setq endl (current-line-number)))
    (setq result (- endl startl))
    result))

(defun insert-before-markers (string)
  (insert string))

(defun insert-char (char &optional (count 1) inherit)
  (dotimes (i count)
    (insert char)))

;(fset 'select-frame #'select-pseudo-frame)
;(fset 'selected-frame #'selected-pseudo-frame)
(fset 'select-frame #'(lambda(frame) ()))


(fset 'select-window #'set-window)

(fset 'scroll-down #'previous-page)
(fset 'scroll-up #'next-page)

(fset 'redraw-display #'editor::refresh-screen)

(defun get-lru-window ()
  (next-window (selected-window)))

(defun one-window-p (&optional no-mini all-frames)
  (and no-mini
       (setq no-mini 1))
  (= (count-windows no-mini) 1))

(fset 'current-buffer #'selected-buffer)

;(defmacro with-current-buffer (buffer body))

;(defmacro with-temp-buffer (body))

(elisp-shadow '(buffer-name))
(defun buffer-name (&optional (buffer (selected-buffer)))
  (editor:buffer-name buffer))

(elisp-shadow '(rename-buffer))
(defun rename-buffer (newname &optional unique)
  (interactive "sRename buffer (to new name):")
  (editor::rename-buffer newname))

(defun get-buffer (buffer-or-name)
  (when (bufferp buffer-or-name)
    (setq buffer-or-name (buffer-name buffer-or-name)))
  (editor::find-buffer buffer-or-name))

(fset 'basic-save-buffer #'editor::save-buffer)

(elisp-shadow '(make-syntax-table))
(defun make-syntax-table (&optional table)
  (or table
      (editor::make-syntax-table)))

(elisp-shadow '(split-window))
(defun split-window (&optional window size horizontal)
  (interactive)
  (unless window (setq window (selected-window)))
  (let ((sw (selected-window)) newwindow)
    (set-window window)
    (if (minibuffer-window-p window)
        (other-window))
    (setq newwindow (editor::split-window size horizontal))
    (set-window sw)
    newwindow))

(defun prefix-numeric-value (arg)
  (cond
   ((and (symbolp arg)
         (eq arg 'nil))
    (setq arg 1))
   ((and (symbolp arg)
         (eq arg '-))
    (setq arg -1))
   ((listp arg)
    (setq arg (car arg))))
  arg)

(elisp-shadow '(split-window-vertically))
(defun split-window-vertically (&optional arg)
  "Split current window into two windows, ..."
  (interactive "P")
  (split-window nil (and arg (prefix-numeric-value arg))))

(defun split-window-horizontally (&optional arg)
  "Split selected window into two windows, side by side..."
  (interactive "P")
  (split-window nil (and arg (prefix-numeric-value arg)) t))

(defvar *char-width* 8)
(defvar *char-height* 18)
; 1文字*char-width* × *char-height* ピクセルで計算
(defun window-edges (&optional window)
  (unless window (setq window (selected-window)))
  (mapcar #'truncate (editor::window-coordinate window)
          (list *char-width* *char-height* *char-width* *char-height*)))

(elisp-shadow '(+))
(defun + (&rest numbers-or-markers-or-characters)
  (let ((result 0) (char 'nil))
    (dolist (n numbers-or-markers-or-characters)
      (cond
       ((characterp n)
        (setq n (char-code n))
        (setq char 't))
       ((markerp n)
        (setq n (marker-point n))))
      (setq result (lisp::+ result n)))
    (and char (setq result (code-char result)))
    result))

(elisp-shadow '(1+))
(defun 1+ (arg)
  (let ((char 'nil) result)
    (cond
     ((characterp arg)
      (setq arg (char-code arg))
      (setq char 't))
     ((markerp arg)
      (setq arg (marker-point arg))))
    (setq result (lisp::1+ arg))
    (and char (setq result (code-char result)))
    result))

(elisp-shadow '(-))
(defun - (&rest numbers-or-markers-or-characters)
  (let ((result 'nil) (char 'nil))
    (cond
     ((= 0 (length numbers-or-markers-or-characters))
      (setq result 0))
     ((= 1 (length numbers-or-markers-or-characters))
      (setq result (values-list numbers-or-markers-or-characters))
      (cond
       ((characterp result)
        (setq result (char-code result)))
       ((markerp result)
        (setq result (marker-point result))))
      (setq result (lisp::- result)))
     (t
      (dolist (n numbers-or-markers-or-characters)
        (cond
         ((characterp n)
          (setq n (char-code n))
          (setq char 't))
         ((markerp n)
          (setq n (marker-point n))))
        (if result
            (setq result (lisp::- result n))
          (setq result n)))))
    (and char (setq result (code-char result)))
    result))

(elisp-shadow '(1-))
(defun 1- (arg)
  (let ((char 'nil) result)
    (cond
     ((characterp arg)
      (setq arg (char-code arg))
      (setq char 't))
     ((markerp arg)
      (setq arg (marker-point arg))))
    (setq result (lisp::1- arg))
    (and char (setq result (code-char result)))
    result))

(elisp-shadow '(/))
(fset '/ #'lisp::truncate)

(fset '% #'lisp::mod)

(elisp-shadow '(=))
(defun = (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::= arg1 arg2))

(elisp-shadow '(/=))
(defun /= (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::/= arg1 arg2))

(elisp-shadow '(<))
(defun < (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::< arg1 arg2))

(elisp-shadow '(>))
(defun > (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::> arg1 arg2))

(elisp-shadow '(<=))
(defun <= (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::<= arg1 arg2))

(elisp-shadow '(>=))
(defun >= (arg1 arg2)
  (cond
   ((characterp arg1)
    (setq arg1 (char-code arg1)))
   ((markerp arg1)
    (setq arg1 (marker-point arg1))))
  (cond
   ((characterp arg2)
    (setq arg2 (char-code arg2)))
   ((markerp arg2)
    (setq arg2 (marker-point arg2))))
  (lisp::>= arg1 arg2))

(defun try-completion (string collection &optional predicate)
  (let (result list prefix)
    (setq completion-related-buffer (selected-buffer))
    (setq completion-last-string string)
    (multiple-value-bind (result list prefix)
        (*do-completion string :list nil collection)
      (setq completion-prefix prefix)
      (cond ((eq result :solo-match)
             't)
            ((eq list 'nil)
             'nil)
            ((eq result :not-unique)
             string)
            (t
             result)))))

(defun all-completions (string collection &optional predicate nospace)
  (setq completion-last-string string)
  (let (result list prefix (rlist nil) ans)
    (setq rlist (multiple-value-bind (result list prefix)
                    (*do-completion string :list nil collection)
                  (setq completion-prefix prefix)
                  list))
    (when predicate
      (dolist (r list (nreverse rlist))
        (when (setq ans (funcall predicate r))
          (push rlist ans))))
    rlist))

(defun display-completion-list (completions)
  (use-keymap *display-completion-list-map*)
  (setq mode-name "Completion List")
  (setq completions (sort completions #'string<))
  (setq completion-list completions)
  (setq completion-column 40)
  (save-excursion
    (format t "Click mouse-2 on a completion to select it.\n")
    (format t "In this buffer, type RET to select the completion near point.\n\n")
    (cond ((< (apply #'max (mapcar #'length completions)) completion-column)
           (format t "Possible completions are:~%~{~A~^~39T ~A~%~}"
                   completions)
           (setq completion-list-column 2))
          (t
           (format t "Possible completions are:~%~{~A~^~%~}"
                   completions)
           (setq completion-list-column 1)))
    (setq buffer-read-only t)))

(defun minibuffer-completion-help ()
  (editor::with-output-to-temp-buffer ("*Completions*")
    (display-completion-list
     (all-completions (buffer-substring (point-min) (point))
                      (minibuffer-completion-list)
                      minibuffer-completion-predicate))))

(elisp-shadow '(intern))
(defun intern (string &optional (package "elisp"))
  (when (stringp package)
    (setq package (ignore-errors (find-package package))))
  (lisp::intern string package))

(defun intern-soft (string &optional (package "elisp"))
  (when (stringp package)
    (setq package (ignore-errors (find-package package))))
  (find-symbol string package))

(defun mapatoms (function &optional (package *package*))
  (when (stringp package)
    (setq package (ignore-errors (find-package package))))
  (do-symbols (symbol package nil)
    (funcall function symbol)))

(elisp-shadow '(call-process))
(defun call-process (program &optional infile destination display &rest args)
  (let (outfile (error nil) (wait t))
    (unless exec-path
      (setq exec-path (default-directory)))
    (when args
      (dolist (arg args)
        (setq program (concat program " " arg))))
    (when (and (numberp destination)
               (= destination 0))
      (setq destination nil
            wait nil))
    (when (listp destination)
      (setq error (cdr destination))
      (setq destination (car destination)))
    (unwind-protect
        (prog2
            (when destination
              (setq outfile (make-temp-file-name)))
            (editor::call-process program
                                  :input infile
                                  :output outfile
                                  :exec-directory exec-path
                                  :error error
                                  :show
                                  :wait wait)
          (when destination
            (let (new)
              (unless (or (bufferp destination)
                          (eq destination 't))
                (setq destination (or (find-buffer destination)
                                      (progn
                                        (setq new t)
                                        (create-new-buffer destination)))))
              (if (eq destination 't)
                  (setq destination (selected-buffer))
                (erase-buffer destination))
              (update-visited-file-modtime)
              (pop-to-buffer destination t)
              (insert-file-contents outfile)
              (and new
                   (setq need-not-save t))
              (set-buffer-modified-p nil)))
          (when (and outfile
                     (/= 0 (file-length outfile)))
            (delete-file outfile))
          (when display (refresh-screen))))))

(defun call-process-region (start end program &optional delete destination display &rest args)
  (let (infile outfile string (error nil) (wait t) (sb (selected-buffer)))
    (if (/= start end)
        (progn
          (setq string (buffer-substring start end))
          (when delete (delete-region start end))
          (setq infile (make-temp-file-name))
          (set-buffer infile)
          (inseret string)
          (save-buffer))
      (setq infile nil))
    (set-buffer sb)
    (unless exec-path
      (setq exec-path (default-directory)))
    (when args
      (dolist (arg args)
        (setq program (concat program " " arg))))
    (when (and (numberp destination)
               (= destination 0))
      (setq destination nil
            wait nil))
    (when (listp destination)
      (setq error (cdr destination))
      (setq destination (car destination)))
    (unwind-protect
        (prog2
            (when destination
              (setq outfile (make-temp-file-name)))
            (editor::call-process program
                                  :input infile
                                  :output outfile
                                  :exec-directory exec-path
                                  :error error
                                  :show
                                  :wait wait)
          (when destination
            (let (new)
              (unless (or (bufferp destination)
                          (eq destination 't))
                (setq destination (or (find-buffer destination)
                                      (progn
                                        (setq new t)
                                        (create-new-buffer destination)))))
              (if (eq destination 't)
                  (setq destination (selected-buffer))
                (erase-buffer destination))
              (update-visited-file-modtime)
              (pop-to-buffer destination t)
              (insert-file-contents outfile)
              (and new
                   (setq need-not-save t))
              (set-buffer-modified-p nil)))
          (when (and outfile
                     (/= 0 (file-length outfile)))
            (delete-file outfile))
          (when (and infile
                     (/= 0 (file-length infile)))
            (delete-file infile))
          (when display (refresh-screen))))))

;(defun shell-command-on-region
;  (call-process-region start end shell-file-name nil buffer nil "-c" command))

(defun shell-command-to-string (command)
  (editor::with-output-to-temp-buffer ("*temp*")
    (call-process shell-file-name nil t t "/c" command)
    (buffer-substring (point-min) (point-max))))

(defun start-process (name buffer-or-name command &rest args)
  (dolist (y args)
    (setq command (concat command " " y)))
  (make-process command :output buffer-or-name))

(elisp-shadow '(process-status))
(defun process-status (process-name)
  (let ((status (editor::process-status process-name)))
    (cond ((eq status :run)
	   'run)
	  ((eq status :exit)
	   'exit))))

(fset 'delete-process #'editor::kill-process)
(fset 'process-mark #'editor::process-marker)
(fset 'get-buffer-process #'editor::buffer-process)
(fset 'marker-position #'marker-point)

(defun mark-marker ()
  (set-marker (make-marker) (mark t)))

(elisp-shadow '(set-marker))
(defun set-marker (marker position &optional buffer)
  (unless (markerp marker)
    (setq marker (make-marker)))
  (let ((sb (selected-buffer)))
    (when buffer
      (set-buffer buffer))
    (editor::set-marker marker position)
    (when buffer
      (set-bufer sb)))
  marker)

(defun push-mark (&optional (markp (point)) nomsg active)
  (and (mark t)
       (push (mark-marker) mark-ring))
  (set-mark markp)
  (unless nomsg
    (message "Mark set"))
  nil)

(defun pop-mark ()
  (let (cm (car mark-ring))
    (and cm
         (set-mark (mark-point cm))))
  nil)

(defun minibuffer-depth ()
  *minibuffer-depth*)

(fset 'exit-minibuffer #'editor::minibuffer-exit)
(fset 'window-minibuffer-p #'editor::minibuffer-window-p)

(defun read-from-minibuffer (prompt &optional init map read hsym default inherit-input-method)
  (save-window-excursion
    (let ((mlcm (copy-keymap minibuffer-local-map)) result
          (minibuffer-history *minibuffer-default-history*))
      (and hsym
           (setq *minibuffer-default-history* (symbol-value hsym)))
      (setq result
            (or (prog2
                    (when map (setq minibuffer-local-map (copy-keymap map)))
                    (editor::read-string prompt :default init :history hsym)
                  (setq minibuffer-local-map (copy-keymap mlcm)))
                default))
      (and hsym
           (add-history result hsym))
      (setq *minibuffer-default-history* minibuffer-history)
      result)))

(elisp-shadow '(read-string))
(defun read-string (prompt &optional init hist def inherit-input-method)
  (interactive)
  (save-window-excursion
    (let ((mlm (copy-keymap minibuffer-local-map)))
      (prog2
          (setq minibuffer-local-map (marge-keymap minibuffer-local-map
                                                   *recursive-minibuffer-map*))
          (or (editor::read-string prompt :default init :history hist)
              def)
        (setq minibuffer-local-map mlm)))
  ))

(elisp-shadow '(completing-read))
(defun completing-read (prompt collection &optional predicate must-match initial hist default inherit-input-method)
  (save-window-excursion
    (let (return
          (minibuffer-history *minibuffer-default-history*))
      (and hist
           (setq *minibuffer-default-history* (symbol-value hist)))
      (setq return (editor::completing-read prompt collection :case-fold predicate
                                            :default initial :history hist
                                            :must-match must-match))
      (unless return
        (setq return default))
      (and hist
           (add-history return hist))
      (setq *minibuffer-default-history* minibuffer-history)
      return)))

(defun default-scroll-lines ()
  (- (window-lines) *next-screen-context-lines*))

(defun scroll-up (&optional count)
  (interactive "p")
  (setq *scroll-margin* scroll-margin)
  (setq *next-screen-context-lines* next-screen-context-lines)
  (editor::scroll-window (if count count
                           (default-scroll-lines))))

(defun scroll-down (&optional count)
  (interactive "p")
  (setq *scroll-margin* scroll-margin)
  (setq *next-screen-context-lines* next-screen-context-lines)
  (editor::scroll-window (- (if count count
                              (default-scroll-lines)))))

(elisp-shadow '(scroll-other-window))
(defun scroll-other-window (&optional count)
  (interactive "p")
  (setq *scroll-margin* scroll-margin)
  (setq *next-screen-context-lines* next-screen-context-lines)
  (save-window-excursion
    (if (and (minibuffer-window-p)
             minibuffer-scroll-window
             (windowp minibuffer-scroll-window))
        (progn (set-window minibuffer-scroll-window)
          (setq minibuffer-scroll-window nil))
      (other-window 1))
    (when other-window-scroll-buffer
      (set-buffer other-window-scroll-buffer)
      (setq other-window-scroll-buffer nil))
    (scroll-up count)))

(defun find-file-noselect (filename &optional nowarn rawfile)
  (unless (get-file-buffer filename)
    (editor::find-file-internal filename nowarn))
  (get-file-buffer filename))

(fset 'buffer-file-name #'editor::get-buffer-file-name)

(defun set-visited-file-name (filename &optional no-query along-with-file)
  (interactive "sSet-visited-file-name:" :default0 (default-directory))
  (swt-buffer-file-name filename))

(defun turn-on-auto-fill()
  (interactive)
  (auto-fill-mode t))

(defun momentary-string-display (string position &optional (char #\SPC) message)
  (let ((func 'nil))
    (save-excursion
      (goto-char position)
      (insert string)
      (setq end (point))
      (message "~A" (or message
                        (format nil "継続するには文字~Aを打つこと" char)))
      (refresh-screen)
      (setq *last-command-char* (read-char *keyboard*))
      (and (/= char *last-command-char*)
           (or (setq func (lookup-keymap (local-keymap) *last-command-char*))
               (setq func (lookup-keymap *global-keymap* *last-command-char*)))
           (functionp func)
           (call-interactively func)))
    (delete-region position end)))

(elisp-shadow '(with-output-to-temp-buffer))
(defmacro with-output-to-temp-buffer (bufname &rest body)
  `(let ((#1=#:buffer (or (find-buffer ,bufname)
                          (create-new-buffer ,bufname)))
         (#2=#:window (selected-window)))
     (erase-buffer #1#)
     (setup-temp-buffer #1#)
     (pop-to-buffer #1# t)
     (with-output-to-buffer (#1#)
       (prog1
           (progn ,@body)
         (set-buffer-modified-p nil #1#)))
     (set-window #2#)))

(defun recursive-edit ()
  (unwind-protect
      (let (func)
        (setq *recursive-depth* (1+ *recursive-depth*))
        (catch 'anstag
          (while t
            (refresh-screen)
            (setq func (local-keymap))
            (while (keymapp func)
              (setq *last-command-char* (read-char *keyboard*))
              (or (setq func (lookup-keymap func *last-command-char*))
                  (setq func (lookup-keymap *global-keymap* *last-command-char*))
              ))
            (cond
             ((eq func 'exit-recursive-edit)
              (setq *recursive-depth* (1- *recursive-depth*))
              (throw 'anstag 'exit))
             ((eq func 'abort-recursive-edit)
              (setq *recursive-depth* (1- *recursive-depth*))
              (throw 'anstag 'abort))
             (t
              (call-interactively func))
            )))
      )))

(defun recursive-depth ()
  *recursive-depth*)

(fset 'buffer-substring-no-properties #'editor::buffer-substring)

(defun buffer-string ()
  (buffer-substring (point-min) (point-max)))

(fset 'set-match-data #'editor::store-match-data)

(fset 'current-kill #'editor::current-kill)
(fset 'kill-new #'editor::kill-new)
(fset 'kill-append #'editor::kill-append)

(fset 'frame-height #'editor::screen-height)
(fset 'frame-width #'editor::screen-width)

(elisp-shadow '(window-height))
;(fset 'window-height #'editor::window-lines)
(defun window-height (&optional window)
  (refresh-screen)
  (window-lines window))

(elisp-shadow '(window-width))
;(fset 'window-width #'editor::window-columns)
(defun window-width (&optional window)
  (refresh-screen)
  (window-columns window))

(elisp-shadow '(save-buffer))
(defun save-buffer (&optional backup-option)
  (editor::save-buffer))

(elisp-shadow '(save-some-buffers))
(defun save-some-buffers (&optional save-silently-p exiting)
  (long-operation
    (let ((count 0))
      (save-excursion
        (dolist (buffer (buffer-list))
          (when (need-buffer-save-p buffer)
            (set-buffer buffer)
            (if (not (file-visited-p))
                (when exiting
                  (refresh-screen)
                  (if (yes-no-or-cancel-p "~aをセーブしますか?" buffer)
                      (when (call-interactively #'write-file)
                        (setq count (1+ count)))
                    (not-modified)))
              (when (or save-silently-p
                        (progn
                          (refresh-screen)
                          (yes-no-or-cancel-p "~a~%をセーブしますか?"
                                              (get-buffer-file-name))))
                (save-buffer)
                (setq count (1+ count)))))))
      (message "~d個のファイルをセーブしました" count))))

(elisp-shadow '(write-file))
(fset 'write-file #'editor::emacs-write-file)

(elisp-shadow '(indent-relative))
(defun indent-relative (&optional unindented-ok)
  (interactive "*")
  (let ((col (current-column)))
    (save-excursion
      (goto-bol)
      (skip-chars-backward " \t\n")
      (setq col (if (< col (current-column))
                    (progn
                      (goto-column col)
                      (skip-chars-forward " \t")
                      (current-column))
                  (if unindented-ok 0 nil))))
    (if col (indent-to col)
      (tab-to-tab-stop))
  ))

(fset 'indent-relative-maybe
              #'(lambda () (interactive "*") (indent-relative t)))

(defun current-indentation ()
  (save-excursion
    (goto-bol)
    (skip-chars-forward " \t")
    (current-column)))

(elisp-shadow '(indent-to))
(defun indent-to (column &optional minimum)
  (interactive "*")
  (if (and minimum
           (< (- column (current-column)) minimum))
      (insert-char #\SPC minimum)
    (editor::indent-to column)))

(fset 'indent-to-column #'indent-to)

;syntax-math-p parse-point-syntax
(elisp-shadow '(forward-sexp))
(defun forward-sexp (arg)
  (interactive "p")
  (let ((oldsyntax (syntax-table)) (newsyntax (make-syntax-table)))
    (copy-syntax-table oldsyntax newsyntax)
    (set-syntax-match newsyntax #\( #\))
    (use-syntax-table newsyntax)
    (editor::forward-sexp arg t)
    (use-syntax-table oldsyntax)
  ))

(elisp-shadow '(skip-chars-forward))
(defun skip-chars-forward (character-set &optional limit)
  (interactive "p")
  (let ((p (point)))
    (if (integerp limit)
        (save-restriction
          (narrow-to-region (point) limit)
          (editor::skip-chars-forward character-set))
      (editor::skip-chars-forward character-set))
    (- (point) p)))

(elisp-shadow '(skip-chars-backward))
(defun skip-chars-backward (character-set &optional limit)
  (interactive "p")
  (let ((p (point)))
    (if (integerp limit)
        (save-restriction
          (narrow-to-region (point) limit)
          (editor::skip-chars-backward character-set))
      (editor::skip-chars-backward character-set))
    (- p (point))))

(defun elisp-search (string reverse regexp &optional limit noerror repeat)
  (let* ((tail (not reverse))
         (count (if repeat repeat 1))
         (limit (if (numberp limit) limit
                  (if reverse (point-min) (point-max))))
         (noerror (if (eq 't limit) limit noerror))
         (spoint (point)))
    ;(when reverse (backward-char 1)) ;set :no-dup reverse
    (setq *last-search-regexp-p* regexp)
    (if regexp
        (setq *last-search-regexp* string)
      (setq *last-search-string* string))
    (save-restriction
      (while (and (> count 0)
                  spoint)
        (setq spoint
              (if (scan-buffer string
                               :regexp regexp
                               :reverse reverse
                               :tail tail
                               :no-dup reverse
                               :case-fold *case-fold-search*
                               :left-bound *word-search*
                               :right-bound *word-search*
                               :limit limit)
                  (point)
                (cond
                 ((numberp noerror)
                  (goto-char limit)
                  nil)
                 (noerror nil)
                 (t
                  (plain-error "文字列が見つかりまへん")
                  nil))))
        (setq count (1- count))))
    spoint))

(elisp-shadow '(search-forward))
(defun search-forward (string &optional limit noerror repeat)
  (interactive "sSearch forward: "
    :default0 *last-search-string* :history0 'search)
  (elisp-search string nil nil limit noerror repeat))

(elisp-shadow '(search-backward))
(defun search-backward (string &optional limit noerror repeat)
  (interactive "sSearch backward: "
    :default0 *last-search-string* :history0 'search)
  (elisp-search string t nil limit noerror repeat))

(elisp-shadow '(re-search-forward))
(defun re-search-forward (regexp &optional limit noerror repeat)
  (interactive "sRe-Search forward: "
    :default0 *last-search-regexp* :history0 'search)
  (elisp-search regexp nil t limit noerror repeat))

(elisp-shadow '(re-search-backward))
(defun re-search-backward (regexp &optional limit noerror repeat)
  (interactive "sRe-Search backward: "
    :default0 *last-search-regexp* :history0 'search)
  (elisp-search regexp t t limit noerror repeat))

(elisp-shadow '(replace-match))
(defun replace-match (replacement &optional fixedcase literal string subexp)
  (editor::replace-match replacement :literal literal))

(elisp-shadow '(buffer-name))
(defun buffer-name (&optional (buffer (selected-buffer)))
  (editor::buffer-name buffer))

(elisp-shadow '(rename-buffer))
(defun remane-buffer (newname &optional unique)
  (interactive "sNewname : \np")
  (editor::rename-buffer newname))

(defun current-time ()
  (append (multiple-value-list (floor (get-universal-time) 65536)) '(0)))

(defun format-time-string (fmt &optional (time (current-time)) universal)
  (format-date-string fmt (+ (* (car time) 65536)
			     (cadr time))))

(defun current-time-string ()
  (format-date-string "%a %b %d %H:%M:%S %Y" (get-universal-time)))

(defun set-window-buffer (window buffer-or-name)
  (save-window-excursion
    (set-window window)
    (switch-to-buffer buffer-or-name)
    (setq buffer-display-time (current-time)))
  nil)

(elisp-shadow '(window-buffer))
(defun window-buffer (&optional (window (selected-window)))
  (editor::window-buffer window))

(elisp-shadow '(get-buffer-window))
(defun get-buffer-window (buffer-or-name &optional all-frames)
  (ignore-errors
   (editor::get-buffer-window buffer-or-name (selected-window))))

(elisp-shadow '(pos-visible-in-window-p))
(defun pos-visible-in-window-p (&optional (pt (point)) (window (selected-window)))
  (save-window-excursion
    (set-window window)
    (editor::pos-visible-in-window-p pt)))

(elisp-shadow '(erase-buffer))
(defun erase-buffer ()
  (interactive "*")
  (editor::erase-buffer (selected-buffer)))

(elisp-shadow '(delete-char))
(defun delete-char (count &optional killp)
  (interactive "*p")
  (when killp
    (push (buffer-substring (point) (+ (point) count)) *kill-ring*))
  (editor::delete-char count))

(elisp-shadow '(delete-backward-char))
(defun delete-backward-char (count &optional killp)
  (interactive "*p")
  (when killp
    (push (buffer-substring (- (point) count) (point)) *kill-ring*))
  (editor::delete-char (- count)))

(elisp-shadow '(backward-delete-char-untabify))
(defun backward-delete-char-untabify (count &optional killp)
  (interactive "*p")
  (delete-backward-char (save-excursion
                          (dotimes (x arg x)
                            (if (eql (preceding-char) #\TAB)
                                (let ((col (current-column)))
                                  (forward-char -1)
                                  (insert #\SPC (- col (current-column)))
                                  (delete-char 1)))
                            (or (forward-char -1)
                                (return x))))
                        killp))

(elisp-shadow '(read-file-name))
(defun read-file-name (prompt &optional directory default existing initial)
  (let ((def ""))
    (when insert-default-directory
      (setq def (or directory default-directory)))
    (when initial
      (setq def (concat def initial)))
    (setq def (editor::read-file-name prompt :default def))
    (when (or (not def)
              (string= def (or directory default-directory)))
      (setq def default))
    def))

(elisp-shadow '(set-mark-command))
(defun set-mark-command (&optional flag)
  (interactive)
  (editor::set-mark-command))

(elisp-shadow '(fill-paragraph))
(defun fill-paragraph (justify)
  (interactive "*P")
  (or (and fill-paragraph-function
           (let ((function fill-paragraph-function))
             (funcall function justify)))
      (editor::fill-paragraph)))

(elisp-shadow '(fill-region))
(defun fill-region (from end &optional justify nosqueeze to-eop)
  (interactive "*r\nP")
  (editor::fill-region-as-paragraph from end))

(elisp-shadow '(fill-region-as-paragraph))
(defun fill-region-as-paragraph (from end &optional justify nosqueeze squeeze-after)
  (interactive "*r\nP")
  (editor::fill-region-as-paragraph from end))

;(fset 'file-exists-p #'lisp::file-exist-p)
(defun file-exists-p (filename)
  (and filename
       (lisp::file-exist-p filename)))

(defun memq (object list)
  (lisp::member object list :test #'eq))

(defun delq (object list)
  (lisp::delete object list :test #'eq))

(elisp-shadow '(member))
(defun member (object list)
  (lisp::member object list :test #'equal))

(elisp-shadow '(delete))
(defun delete (object list)
  (lisp::delete object list :test #'equal))

(elisp-shadow '(assoc))
(defun assoc (object list)
  (lisp::assoc object list :test #'equal))

(elisp-shadow '(rassoc))
(defun rassoc (object list)
  (lisp::rassoc object list :test #'equal))

(defun assq (key alist)
  (lisp::assoc key alist :test #'eq))

(defun rassq (key alist)
  (lisp::rassoc key alist :test #'eq))

(defun assoc-default (key alist test default)
  (unless test (setq test 'equal))
  (let (result)
    (setq result (lisp::assoc key alist :test #'test))
    (cond
     ((consp result)
      (setq result (cdr result)))
     ((eq result 'nil))
     (t
      (setq result default)))
    result))

(fset 'car-safe #'lisp::safe-car)
(fset 'cdr-safe #'lisp::safe-cdr)
(fset 'safe-length #'lisp::list-length)

(defun mapconcat (function sequence separator)
  (let* ((list (mapcar function sequence))
         (result (car list)))
    (setq list (cdr list))
    (dolist (tmp list result)
      (setq result (concat result separator (string tmp))))
  ))

(defun downcase (string-or-char)
  (cond
   ((stringp string-or-char)
    (string-downcase string-or-char))
   ((characterp string-or-char)
    (char-downcase string-or-char))
   (t
    string-or-char)))

(defun upcase (string-or-char)
  (cond
   ((stringp string-or-char)
    (string-upcase string-or-char))
   ((characterp string-or-char)
    (char-upcase string-or-char))
   (t
    string-or-char)))

(defun capitalize (string-or-char)
  (cond
   ((stringp string-or-char)
    (string-capitalize string-or-char))
   ((characterp string-or-char)
    (char-upcase string-or-char))
   (t
    string-or-char)))

(fset 'char-to-string #'lisp::string)

(defun string-to-char (string)
  (cond
   ((string= string "")
    0)
   ((= #\NUL (character (substring string 0 1)))
    0)
   (t
    (let ((list nil))
      (if (stringp string)
	  (if (< 1 (length string))
	      (progn
		(dotimes (i (length string))
		  (cond
		   ((string-looking-at "\#\\\\" string)
		    (push (read-from-string (substring string 0 5)) list)
		    (setq i (+ i 4)
			  string (substring string 5 nil)))
		   ((string-looking-at "C-" string)
		    (push (read-from-string (concat "#\\" (substring string 0 3))) list)
		    (setq i (+ i 2)
			  string (substring string 3 nil)))
		   (t
		    (push (character (substring string 0 1)) list)
		    (setq string (substring string 1 nil)))
		   ))
		(if (= 1 (length list))
		    (values-list list)
		  (reverse list)))
	    (character string))
	string))
    )))

(defun number-to-string (int)
  (format nil "~A" int))

(defun int-to-string (int)
  (format nil "~D" int))

(defun string-to-int (str)
  (parse-integer str))

(elisp-shadow '(cd))
(defun cd (directory)
  (interactive "DChange default directory:" :default0 (default-directory))
  (set-default-directory directory)
  (setq default-directory directory))

;(fset 'file-name-directory #'lisp::directory-namestring)
;(fset 'file-name-nondirectory #'lisp::file-namestring)
(defun file-name-directory (filename)
  (let ((letter "")
	(dir (substring filename 0 (string-match "[^/]*$" filename))))
    (when (string-match "^[A-Z]:" dir)
      (setq letter (substring dir 0 2))
      (setq dir (substring dir 2)))	;remove drive letter
    (if (string= dir "")
	nil
      (concat letter dir))))

(defun file-name-nondirectory (filename)
  (let ((letter "")
	(file (substring filename (string-match "[^/]*$" filename))))
    (when (string-match "^[A-Z]:" file)
      (setq letter (substring dir 0 2))
      (setq file (substring file 2))) ;remove drive letter
    (if (string= file "")
	nil
      (concat letter file))))

(defun file-name-sans-versions (filename) ; 須田さん
  "Return FILENAME sans backup versions or strings.
This is a separate procedure so your site-init or startup file can
redefine it."
  (substring filename 0
             (or (string-match "\\.~[0-9]+~\\'" filename)
                 (string-match "~\\'" filename)
                 (length filename))))

(defun file-name-sans-extension (filename)
  (let ((name (file-namestring filename)))
    (substring filename 0
               (+ (- (length filename) (length name))
                  (or (string-match "\\.[^\\.]*$" name)
                      (length name))))))

(defun expand-file-name (file &optional dir)
  (let ((cd (default-directory)))
    (if dir
        (prog2
            (set-default-directory dir)
            (namestring file)
          (set-default-directory cd))
      (namestring file))))

(defun setplist (symbol plist)
  (setf (symbol-plist symbol) plist))

(defun put (symbol property value)
  (setf (get symbol property) value))

(elisp-shadow '(autoload))
(defun autoload (function filename &optional docstring interactive type)
  (when (stringp docstring)
    (si:*putprop function docstring 'variable-documentation))
  (cond
   ((macro-function function)
    (setq type 'macro))
   ((keymapp function)
    (setq type 'keymap)))
  (lisp::autoload function filename interactive type))

(defun make-string (count character)
  (if (< count 0)
      (error "Out of range")
    (let ((key "")
          (char (string character)))
      (dotimes (i count)
        (setq key (concat key char)))
      key)))

(elisp-shadow '(string))
(defun string (&rest characters)
  (let ((result ""))
    (dolist (char characters result)
      (setq result (concat result (lisp::string char))))))

(elisp-shadow '(substring))
(defun substring (string start &optional end)
  (let ((length (length string)))
    (when (eq end 'nil)
      (setq end length))
    (when (< start 0)
      (setq start (+ length start)))
    (when (< end 0)
      (setq end (+ length end)))
    (when (> start end)
      (let ((tmp start))
        (setq start end)
        (setq end tmp))))
  (lisp:substring string start end))

(elisp-shadow '(concat))
(defun concat (&rest sequences)
  (let ((result ""))
    (dolist (char sequences result)
      (unless (or (stringp char)
		  (symbolp char))
        (setq char (format nil "~A" char)))
      (setq result (editor::concat result char)))
    result))

(defun put-text-property (start end prop value &optional object)
  t)

(defun make-face (name)
  (make-hash-table))

(defun set-face-foreground (face color &optional frame)
  (when (stringp color)
    (setf (gethash 'foreground face) color)))

(defun set-face-background (face color &optional frame)
  (when (stringp color)
    (setf (gethash 'background face) color)))

(defun set-face-stipple (face pattern &optional frame)
  (when (stringp pattern)
    (setf (gethash 'stipple face) pattern)))

(defun set-face-font (face font &optional frame)
  (when (stringp font)
    (setf (gethash 'font face) font)))

(defun set-face-bold-p (face bold &optional frame)
  (setf (gethash 'bold-p face) (and bold t)))

(defun set-face-italic-p (face italic &optional frame)
  (setf (gethash 'italic-p face) (and italic t)))

(defun set-face-underline-p (face underline &optional frame)
  (setf (gethash 'underline-p face) (and underline t)))

;;->howm
(defun file-attributes (file)
  (lisp::let* ((s (si:make-string-chunk (expand-file-name file)))
	       (h (winapi::CreateFile s #x80000000 0 0 3 0 0)))
    (when (/= 0 h)
      (unwind-protect
	  (lisp::let* ((c (winapi::make-FILETIME))
		       (l (winapi::make-FILETIME))
		       (w (winapi::make-FILETIME))
		       (lst (list c w w)))
	    (when (= 1 (winapi::GetFileTime h c l w))
	      (setq lst (mapcar
			 #'(lisp::lambda (time)
			     (setq time
				   (+ (* (winapi::FILETIME-dwHighDateTime time)
					 #xFFFFFFFF)
				      (winapi::FILETIME-dwLowDateTime time)))
			     (- (truncate (/ time 10000000.0))
				9435484800))
			 lst))
	      (setq lst (mapcar #'(lisp::lambda (time)
				    (append (multiple-value-list
					     (floor time 65536))
					    '(0)))
				lst))
	      `(nil ;t for directory, string (name linked to) for symbolic link, or nil.
		nil ;Number of links to file.
		nil ;File uid.
		nil ;File gid.
		,@lst)))
	(winapi::CloseHandle h)))))
;;<-howm
;;->simple.el
(defvar comment-padding 1
  "Number of spaces `comment-region' puts between comment chars and text.

Extra spacing between the comment characters and the comment text
makes the comment easier to read.  Default is 1.  Nil means 0 and is
more efficient.")

(defun comment-region (beg end &optional arg)
  "Comment or uncomment each line in the region.
With just C-u prefix arg, uncomment each line in region.
Numeric prefix arg ARG means use ARG comment characters.
If ARG is negative, delete that many comment characters instead.
Comments are terminated on each line, even for syntax in which newline does
not end the comment.  Blank lines do not get comments."
  ;; if someone wants it to only put a comment-start at the beginning and
  ;; comment-end at the end then typing it, C-x C-x, closing it, C-x C-x
  ;; is easy enough.  No option is made here for other than commenting
  ;; every line.
  (interactive "r\nP")
  (or comment-start (error "No comment syntax is defined"))
  (if (> beg end) (let (mid) (setq mid beg beg end end mid)))
  (save-excursion
    (save-restriction
      (let ((cs comment-start) (ce comment-end)
	    (cp (when comment-padding
		  (make-string comment-padding #\SPC)))
	    numarg)
	(if (consp arg) (setq numarg t)
	  (setq numarg (prefix-numeric-value arg))
	  ;; For positive arg > 1, replicate the comment delims now,
	  ;; then insert the replicated strings just once.
	  (while (> numarg 1)
	    (setq cs (concat cs comment-start)
		  ce (concat ce comment-end))
	    (setq numarg (1- numarg))))
	;; Loop over all lines from BEG to END.
	(narrow-to-region beg end)
	(goto-char beg)
	(if (or (eq numarg t) (< numarg 0))
	    (while (not (eobp))
	      (let (found-comment)
		;; Delete comment start from beginning of line.
		(if (eq numarg t)
		    (while (looking-at (regexp-quote cs))
		      (setq found-comment t)
		      (delete-char (length cs)))
		  (let ((count numarg))
		    (while (and (> 1 (setq count (1+ count)))
				(looking-at (regexp-quote cs)))
		      (setq found-comment t)
		      (delete-char (length cs)))))
		;; Delete comment padding from beginning of line
		(when (and found-comment comment-padding
			   (looking-at (regexp-quote cp)))
		  (delete-char comment-padding))
		;; Delete comment end from end of line.
		(if (string= "" ce)
		    nil
		  (if (eq numarg t)
		      (progn
			(end-of-line)
			;; This is questionable if comment-end ends in
			;; whitespace.  That is pretty brain-damaged,
			;; though.
			(while (progn (skip-chars-backward " \t")
				      (and (>= (- (point) (point-min)) (length ce))
					   (save-excursion
					     (backward-char (length ce))
					     (looking-at (regexp-quote ce)))))
			    (delete-char (- (length ce)))))
		    (let ((count numarg))
		      (while (> 1 (setq count (1+ count)))
			(end-of-line)
			;; this is questionable if comment-end ends in whitespace
			;; that is pretty brain-damaged though
			(skip-chars-backward " \t")
			(if (>= (- (point) (point-min)) (length ce))
			    (save-excursion
			      (backward-char (length ce))
			      (if (looking-at (regexp-quote ce))
				  (delete-char (length ce)))))))))
		(forward-line 1)))

	  (when comment-padding
	    (setq cs (concat cs cp)))
	  (while (not (eobp))
	    ;; Insert at beginning and at end.
	    (if (looking-at "[ \t]*$") ()
	      (insert cs)
	      (if (string= "" ce) ()
		(end-of-line)
		(insert ce)))
	    (search-forward "\n" nil 'move)))))))
;;<-simple.el

(defun setcdr (cons object)
  (rplacd cons object)
  object)
