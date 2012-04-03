;;; -*- Mode: Lisp; Package: TTERM -*-
;;;
;;;  tterm.l : Telnet terminal for xyzzy
;;;
;;;
;;;  Author     : YAMAMOTO Shinji  <sinj@mb.neweb.ne.jp>
;;;  Supported by KAMEI Tetsuya and Toy.
;;;
;;;  Last Modify : January 02, 2005
;;;
;;
;; Telnet í[ññÇ≈Ç∑ÅB
;;
;; é©óRÇ…égópÇµÇƒç\Ç¢Ç‹ÇπÇÒÅBÉRÉsÅ[Ç‚â¸ë¢ï®ÇÃîzïzÇ‡é©óRÇ≈Ç∑ÅB
;; ñ≥ï€èÿÇ≈Ç∑ÅBã@î\ïsë´Ç‚ÉoÉOÇ»Ç«ÇÕèüéËÇ…èCê≥ÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB
;;
;;
;; égópó·
;;   *load-path* ÇÃí Ç¡ÇƒÇ¢ÇÈÇ∆Ç±ÇÎÇ…ÅAtterm.l ÇíuÇ≠
;;   tterm.l ÇÉoÉCÉgÉRÉìÉpÉCÉãÇ∑ÇÈ
;;   (load-library "tterm")
;;   (use-package "tterm")
;;   M-x tterm
;;     Ç‹ÇΩÇÕ  ESC ESC (tterm "server" 23 :user "name")
;;
;;
;;
;;
;; Changes
;;   0.35
;;   - (ãTà‰Ç≥ÇÒ) erase chars í«â¡ ( tterm-csi-X )
;;   0.34
;;   - (ãTà‰Ç≥ÇÒ) "~/.tterm"ì«Ç›çûÇ›
;;   - (ãTà‰Ç≥ÇÒ) ÉGÉìÉRÅ[ÉhÇÃêÿÇËë÷Ç¶
;;   0.33
;;   - ÇªÇÍÇ»ÇËÉ}ÉEÉX
;;   - ïœÇ»ÉoÅ[ÉWÉáÉìÉ`ÉFÉbÉNÇé~ÇﬂÇΩ
;;   0.32
;;   - ãTà‰Ç≥ÇÒÇ©ÇÁÇÃÉNÉäÉbÉvÉ{Å[ÉhÇ©ÇÁÇÃëóêMÇ∆ÅAÇ…ÇπÉtÉåÅ[ÉÄëŒâû
;;   0.31
;;   - Toy Ç≥ÇÒÇÃÇ≤óvñ]Ç…ÇÊÇË*tterm-favorite-hosts*Ç©ÇÁhostÇëIÇ‘ÇÊÇ§Ç…
;;

;; Modified by DeaR <nayuri@kuonn.mydns.jp>
;; Last Updated: <2012-04-03 15:05:00 DeaR>


;; Code

(provide "tterm")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "tterm")
    (defpackage "tterm" (:use "lisp" "editor"))))

(in-package "tterm")

(export '(tterm *tterm-version*
	  *tterm-mode-map* *tterm-char-mode-map* *tterm-cmd-mode-map*
	  *tterm-mode-hook* *tterm-cmd-mode-hook*
	  *tterm-input-encoding* *tterm-output-encoding*
	  *tterm-max-log-lines*
	  *tterm-text-fg-black* *tterm-text-fg-red*
	  *tterm-text-fg-green* *tterm-text-fg-yellow*
	  *tterm-text-fg-blue* *tterm-text-fg-magenta*
	  *tterm-text-fg-cyan* *tterm-text-fg-white*
	  *tterm-text-bg-black* *tterm-text-bg-red*
	  *tterm-text-bg-green* *tterm-text-bg-yellow*
	  *tterm-text-bg-blue* *tterm-text-bg-magenta*
	  *tterm-text-bg-cyan* *tterm-text-bg-white*
	  *tterm-meta-code*
	  tterm-reset-terminal
	  tterm-set-input-encoding tterm-set-output-encoding
	  tterm-char-mode tterm-toggle-meta tterm-toggle-meta-emu
	  tterm-toggle-crlf tterm-toggle-crmod
	  *tterm-favorite-hosts*
	  *tterm-io-encoding-alist*))

(defconstant *tterm-version* "tterm.l version 0.35+1.0")


;;;------------------------------------------------------------------------
;;; èâä˙âª
;;;

(defconstant *TELNET-CMD-EOF* (code-char 236))
(defconstant *TELNET-CMD-SUSP* (code-char 237))
(defconstant *TELNET-CMD-ABORT* (code-char 238))
(defconstant *TELNET-CMD-EOR* (code-char 239))
(defconstant *TELNET-CMD-SE* (code-char 240))
(defconstant *TELNET-CMD-NOP* (code-char 241))
(defconstant *TELNET-CMD-DM* (code-char 242))
(defconstant *TELNET-CMD-BRK* (code-char 243))
(defconstant *TELNET-CMD-IP* (code-char 244))
(defconstant *TELNET-CMD-AO* (code-char 245))
(defconstant *TELNET-CMD-AYT* (code-char 246))
(defconstant *TELNET-CMD-EC* (code-char 247))
(defconstant *TELNET-CMD-EL* (code-char 248))
(defconstant *TELNET-CMD-GA* (code-char 249))
(defconstant *TELNET-CMD-SB* (code-char 250))
(defconstant *TELNET-CMD-WILL* (code-char 251))
(defconstant *TELNET-CMD-WONT* (code-char 252))
(defconstant *TELNET-CMD-DO* (code-char 253))
(defconstant *TELNET-CMD-DONT* (code-char 254))
(defconstant *TELNET-CMD-IAC* (code-char 255))

(defconstant *TELNET-OP-BINARY* (code-char 0))
(defconstant *TELNET-OP-ECHO* (code-char 1))
(defconstant *TELNET-OP-RCP* (code-char 2))
(defconstant *TELNET-OP-SGA* (code-char 3))
(defconstant *TELNET-OP-NAMS* (code-char 4))
(defconstant *TELNET-OP-STATUS* (code-char 5))
(defconstant *TELNET-OP-TM* (code-char 6))
(defconstant *TELNET-OP-RCTE* (code-char 7))
(defconstant *TELNET-OP-NAOL* (code-char 8))
(defconstant *TELNET-OP-NAOP* (code-char 9))
(defconstant *TELNET-OP-NAOCRD* (code-char 10))
(defconstant *TELNET-OP-NAOHTS* (code-char 11))
(defconstant *TELNET-OP-NAOHTD* (code-char 12))
(defconstant *TELNET-OP-NAOFFD* (code-char 13))
(defconstant *TELNET-OP-NAOVTS* (code-char 14))
(defconstant *TELNET-OP-NAOVTD* (code-char 15))
(defconstant *TELNET-OP-NAOLFD* (code-char 16))
(defconstant *TELNET-OP-XASCII* (code-char 17))
(defconstant *TELNET-OP-LOGOUT* (code-char 18))
(defconstant *TELNET-OP-BM* (code-char 19))
(defconstant *TELNET-OP-DET* (code-char 20))
(defconstant *TELNET-OP-SUPDUP* (code-char 21))
(defconstant *TELNET-OP-SUPDUPOUTPUT* (code-char 22))
(defconstant *TELNET-OP-SNDLOC* (code-char 23))
(defconstant *TELNET-OP-TTYPE* (code-char 24))
(defconstant *TELNET-OP-EOR* (code-char 25))
(defconstant *TELNET-OP-TUID* (code-char 26))
(defconstant *TELNET-OP-OUTMRK* (code-char 27))
(defconstant *TELNET-OP-TTYLOC* (code-char 28))
(defconstant *TELNET-OP-REGIME3270* (code-char 29))
(defconstant *TELNET-OP-X3PAD* (code-char 30))
(defconstant *TELNET-OP-NAWS* (code-char 31))
(defconstant *TELNET-OP-TSPEED* (code-char 32))
(defconstant *TELNET-OP-LFLOW* (code-char 33))
(defconstant *TELNET-OP-LINEMODE* (code-char 34))
(defconstant *TELNET-OP-XDISPLOC* (code-char 35))
(defconstant *TELNET-OP-ENVIRON* (code-char 36))
(defconstant *TELNET-OP-AUTHENTICATION* (code-char 37))
(defconstant *TELNET-OP-ENCRYPT* (code-char 38))
(defconstant *TELNET-OP-NEW_ENVIRON* (code-char 39))
(defconstant *TELNET-OP-TN3247* (code-char 40))
(defconstant *TELNET-OP-CHARSET* (code-char 42))
(defconstant *TELNET-OP-COM_PART* (code-char 44))
;(defconstant *TELNET-OP-EXOPL* (code-char 128))

(defconstant *TELNET-SUB-IS* (code-char 0))
(defconstant *TELNET-SUB-SEND* (code-char 1))
(defconstant *TELNET-SUB-INFO* (code-char 2))
(defconstant *TELNET-SUB-REPLY* (code-char 2))
(defconstant *TELNET-SUB-NAME* (code-char 3))

(defconstant *TELNET-SUB-MODE* (code-char 1))
(defconstant *TELNET-SUB-FORWARDMASK* (code-char 2))
(defconstant *TELNET-SUB-SLC* (code-char 3))

(defconstant *TELNET-MODE-EDIT 1)
(defconstant *TELNET-MODE-TRAPSIG 2)
(defconstant *TELNET-MODE-MODE_ACK 4)
(defconstant *TELNET-MODE-SOFT_TAB 8)
(defconstant *TELNET-MODE-LIT_ECHO 16)

(defconstant *TELNET-SLC-SYNCH* (code-char 1))
(defconstant *TELNET-SLC-BRK* (code-char 2))
(defconstant *TELNET-SLC-IP* (code-char 3))
(defconstant *TELNET-SLC-AO* (code-char 4))
(defconstant *TELNET-SLC-AYT* (code-char 5))
(defconstant *TELNET-SLC-EOR* (code-char 6))
(defconstant *TELNET-SLC-ABORT* (code-char 7))
(defconstant *TELNET-SLC-EOF* (code-char 8))
(defconstant *TELNET-SLC-SUSP* (code-char 9))
(defconstant *TELNET-SLC-EC* (code-char 10))
(defconstant *TELNET-SLC-EL* (code-char 11))
(defconstant *TELNET-SLC-EW* (code-char 12))
(defconstant *TELNET-SLC-RP* (code-char 13))
(defconstant *TELNET-SLC-LNEXT* (code-char 14))
(defconstant *TELNET-SLC-XON* (code-char 15))
(defconstant *TELNET-SLC-XOFF* (code-char 16))
(defconstant *TELNET-SLC-FORW1* (code-char 17))
(defconstant *TELNET-SLC-FORW2* (code-char 18))
(defconstant *TELNET-SLC-MCL* (code-char 19))
(defconstant *TELNET-SLC-MCR* (code-char 20))
(defconstant *TELNET-SLC-MCWL* (code-char 21))
(defconstant *TELNET-SLC-MCWR* (code-char 22))
(defconstant *TELNET-SLC-MCBOL* (code-char 23))
(defconstant *TELNET-SLC-MCEOL* (code-char 24))
(defconstant *TELNET-SLC-INSRT* (code-char 25))
(defconstant *TELNET-SLC-OVER* (code-char 26))
(defconstant *TELNET-SLC-ECR* (code-char 27))
(defconstant *TELNET-SLC-EWR* (code-char 28))
(defconstant *TELNET-SLC-EBOL* (code-char 29))
(defconstant *TELNET-SLC-EEOL* (code-char 30))

(defconstant *TELNET-SLC-DEFAULT* (code-char 3))
(defconstant *TELNET-SLC-NOSUPPORT 0)
(defconstant *TELNET-SLC-CANTCHANGE 1)
(defconstant *TELNET-SLC-VALUE 2)
(defconstant *TELNET-SLC-LEVELBITS 3)
(defconstant *TELNET-SLC-FLUSHOUT 32)
(defconstant *TELNET-SLC-FLUSHIN 64)
(defconstant *TELNET-SLC-ACK 128)

(defconstant *TELNET-SENT-DO* 1)    ; rcvd wont
(defconstant *TELNET-SENT-WILL* 2)  ; rcvd dont
(defconstant *TELNET-RCVD-DO* 4)    ; sent wont
(defconstant *TELNET-RCVD-WILL* 8)  ; sent dont
(defconstant *TELNET-I-ACT* (logior *TELNET-SENT-WILL* *TELNET-RCVD-DO*))
(defconstant *TELNET-PEER-ACT* (logior *TELNET-SENT-DO* *TELNET-RCVD-WILL*))

(defconstant *MOUSE-X10* 9)
(defconstant *MOUSE-VT200* 1000)
(defconstant *MOUSE-HIGHLIGHT* 1001)
(defconstant *MOUSE-BTNEVENT* 1002)
(defconstant *MOUSE-ANYEVENT* 1003)

(defmacro tterm-sent-do-p (code)
  `(logtest (svref tterm-telnet-option ,code) *TELNET-SENT-DO*))

(defmacro tterm-sent-will-p (code)
  `(logtest (svref tterm-telnet-option ,code) *TELNET-SENT-WILL*))

(defmacro tterm-set-telnet-option (code flag)
  `(setf (svref tterm-telnet-option ,code)
	 (logior (svref tterm-telnet-option ,code) ,flag)))

(defmacro tterm-unset-telnet-option (code flag)
  `(setf (svref tterm-telnet-option ,code)
	 (logandc2 (svref tterm-telnet-option ,code) ,flag)))

(defmacro tterm-get-telnet-option (code &optional peer)
  `(= (logand (svref tterm-telnet-option ,code)
	      (if ,peer *TELNET-PEER-ACT* *TELNET-I-ACT*))
      (if ,peer *TELNET-PEER-ACT* *TELNET-I-ACT*)))

(defvar *tterm-mode-hook* nil)
(defvar *tterm-cmd-mode-hook* nil)

(defvar *tterm-mode-map* nil)
(unless *tterm-mode-map*
  (setq *tterm-mode-map* (make-sparse-keymap))
  (define-key *tterm-mode-map* #\RET 'tterm-send-command-line)
  (define-key *tterm-mode-map* #\RBtnUp 'tterm-popup-menu)
  (define-key *tterm-mode-map* '(#\C-] #\C-]) 'tterm-char-mode)
  (define-key *tterm-mode-map* #\S-Insert 'tterm-paste)
)

(defvar *tterm-char-mode-map* nil)
(unless *tterm-char-mode-map*
  (setq *tterm-char-mode-map* (make-keymap))
  (dotimes (n #x80)
    (define-key *tterm-char-mode-map* (code-char n) 'tterm-self-send-command))
  (undefine-key *tterm-char-mode-map* #\C-])
  (define-key *tterm-char-mode-map* '(#\C-] #\C-y) 'tterm-yank)
  (define-key *tterm-char-mode-map* '(#\C-] #\C-q) 'tterm-send-quote-char)
  (define-key *tterm-char-mode-map* #\RET 'tterm-send-eol)
  (define-key *tterm-char-mode-map* #\Left 'tterm-send-cursor-code)
  (define-key *tterm-char-mode-map* #\Up 'tterm-send-cursor-code)
  (define-key *tterm-char-mode-map* #\Right 'tterm-send-cursor-code)
  (define-key *tterm-char-mode-map* #\Down 'tterm-send-cursor-code)
  (define-key *tterm-char-mode-map* #\S-PageUp 'previous-page)
  (define-key *tterm-char-mode-map* #\S-PageDown 'next-page)
  (define-key *tterm-char-mode-map* #\PageUp 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\PageDown 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\End 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\Home 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\Insert 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\Delete 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F1 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F2 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F3 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F4 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F5 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F6 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F7 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F8 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F9 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F10 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F11 'tterm-send-control-code)
  (define-key *tterm-char-mode-map* #\F12 'tterm-send-control-code)
)

(defvar *tterm-meta-keymap* nil)
(unless *tterm-meta-keymap*
  (let ((m (make-keymap)))
    (dotimes (x 128)
      (define-key m (code-char x) 'tterm-send-meta-code))
    (setq *tterm-meta-keymap* (make-sparse-keymap))
    (define-key *tterm-meta-keymap* #\ESC m)))


(defvar *tterm-mouse-mode-map* nil)
(unless *tterm-mouse-mode-map*
  (setq *tterm-mouse-mode-map* (make-sparse-keymap))
  (define-key *tterm-mouse-mode-map* #\LBtnDown 'tterm-lbtndown)
  (define-key *tterm-mouse-mode-map* #\S-LBtnDown 'tterm-s-lbtndown)
  (define-key *tterm-mouse-mode-map* #\M-LBtnDown 'tterm-m-lbtndown)
  (define-key *tterm-mouse-mode-map* #\C-LBtnDown 'tterm-c-lbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-LBtnDown 'tterm-s-m-lbtndown)
  (define-key *tterm-mouse-mode-map* #\S-C-LBtnDown 'tterm-s-c-lbtndown)
  (define-key *tterm-mouse-mode-map* #\M-C-LBtnDown 'tterm-m-c-lbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-C-LBtnDown 'tterm-s-m-c-lbtndown)
  (define-key *tterm-mouse-mode-map* #\MBtnDown 'tterm-mbtndown)
  (define-key *tterm-mouse-mode-map* #\S-MBtnDown 'tterm-s-mbtndown)
  (define-key *tterm-mouse-mode-map* #\M-MBtnDown 'tterm-m-mbtndown)
  (define-key *tterm-mouse-mode-map* #\C-MBtnDown 'tterm-c-mbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-MBtnDown 'tterm-s-m-mbtndown)
  (define-key *tterm-mouse-mode-map* #\S-C-MBtnDown 'tterm-s-c-mbtndown)
  (define-key *tterm-mouse-mode-map* #\M-C-MBtnDown 'tterm-m-c-mbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-C-MBtnDown 'tterm-s-m-c-mbtndown)
  (define-key *tterm-mouse-mode-map* #\RBtnDown 'tterm-rbtndown)
  (define-key *tterm-mouse-mode-map* #\S-RBtnDown 'tterm-s-rbtndown)
  (define-key *tterm-mouse-mode-map* #\M-RBtnDown 'tterm-m-rbtndown)
  (define-key *tterm-mouse-mode-map* #\C-RBtnDown 'tterm-c-rbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-RBtnDown 'tterm-s-m-rbtndown)
  (define-key *tterm-mouse-mode-map* #\S-C-RBtnDown 'tterm-s-c-rbtndown)
  (define-key *tterm-mouse-mode-map* #\M-C-RBtnDown 'tterm-m-c-rbtndown)
  (define-key *tterm-mouse-mode-map* #\S-M-C-RBtnDown 'tterm-s-m-c-rbtndown)
;  (define-key *tterm-mouse-mode-map* #\LBtnMove 'tterm-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-LBtnMove 'tterm-s-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-LBtnMove 'tterm-m-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\C-LBtnMove 'tterm-c-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-LBtnMove 'tterm-s-m-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-C-LBtnMove 'tterm-s-c-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-C-LBtnMove 'tterm-m-c-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-C-LBtnMove 'tterm-s-m-c-lbtnmove)
;  (define-key *tterm-mouse-mode-map* #\RBtnMove 'tterm-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-RBtnMove 'tterm-s-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-RBtnMove 'tterm-m-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\C-RBtnMove 'tterm-c-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-RBtnMove 'tterm-s-m-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-C-RBtnMove 'tterm-s-c-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-C-RBtnMove 'tterm-m-c-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-C-RBtnMove 'tterm-s-m-c-rbtnmove)
;  (define-key *tterm-mouse-mode-map* #\MBtnMove 'tterm-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-MBtnMove 'tterm-s-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-MBtnMove 'tterm-m-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\C-MBtnMove 'tterm-c-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-MBtnMove 'tterm-s-m-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-C-MBtnMove 'tterm-s-c-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\M-C-MBtnMove 'tterm-m-c-mbtnmove)
;  (define-key *tterm-mouse-mode-map* #\S-M-C-MBtnMove 'tterm-s-m-c-mbtnmove)
  (define-key *tterm-mouse-mode-map* #\LBtnUp 'tterm-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-LBtnUp 'tterm-s-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-LBtnUp 'tterm-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\C-LBtnUp 'tterm-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-LBtnUp 'tterm-s-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-C-LBtnUp 'tterm-s-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-C-LBtnUp 'tterm-m-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-C-LBtnUp 'tterm-s-m-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\RBtnUp 'tterm-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-RBtnUp 'tterm-s-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-RBtnUp 'tterm-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\C-RBtnUp 'tterm-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-RBtnUp 'tterm-s-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-C-RBtnUp 'tterm-s-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-C-RBtnUp 'tterm-m-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-C-RBtnUp 'tterm-s-m-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\MBtnUp 'tterm-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-MBtnUp 'tterm-s-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-MBtnUp 'tterm-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\C-MBtnUp 'tterm-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-MBtnUp 'tterm-s-m-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-C-MBtnUp 'tterm-s-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\M-C-MBtnUp 'tterm-m-c-btn-release)
  (define-key *tterm-mouse-mode-map* #\S-M-C-MBtnUp 'tterm-s-m-c-btn-release)
)

#|
(unless *tterm-meta-keymap*
  (setq *tterm-meta-keymap* (make-sparse-keymap))
  (do* ((meta-max #x807F) (n #x8000 (1+ n)))
      ((>= n meta-max))
    (define-key *tterm-meta-keymap* (code-char n) 'tterm-send-meta-code)))
|#

#|
(defvar *tterm-line-mode-map* nil)
(unless *tterm-line-mode-map*
  (define-key *tterm-line-mode-map* '#\C-] 'tterm-escape-terminal))
|#

(defvar *tterm-cmd-mode-map* nil)
(unless *tterm-cmd-mode-map*
  (setq *tterm-cmd-mode-map* (make-sparse-keymap))
  (define-key *tterm-cmd-mode-map* #\RET 'tterm-detect-command)
  (define-key *tterm-cmd-mode-map* #\TAB 'tterm-completion-command)
;  (define-key *tterm-cmd-mode-map* #\C-p 'tterm-prev-command-history)
;  (define-key *tterm-cmd-mode-map* #\C-n 'tterm-next-command-history)
)

(defvar *tterm-char-mode* t)

(defvar *tterm-meta-code* nil)

(defvar *tterm-flag-crlf* nil)
(defvar *tterm-flag-crmod* nil)

(defvar *tterm-flag-netdata* nil)
(defvar *tterm-flag-options* nil)
(defvar *tterm-flag-prettydump* nil)

(defvar *tterm-text-fg-black* 8)
(defvar *tterm-text-fg-red* 1)
(defvar *tterm-text-fg-green* 2)
(defvar *tterm-text-fg-yellow* 3)
(defvar *tterm-text-fg-blue* 4)
(defvar *tterm-text-fg-magenta* 5)
(defvar *tterm-text-fg-cyan* 6)
(defvar *tterm-text-fg-white* 7)
(defvar *tterm-text-bg-black* 8)
(defvar *tterm-text-bg-red* 1)
(defvar *tterm-text-bg-green* 2)
(defvar *tterm-text-bg-yellow* 3)
(defvar *tterm-text-bg-blue* 4)
(defvar *tterm-text-bg-magenta* 5)
(defvar *tterm-text-bg-cyan* 6)
(defvar *tterm-text-bg-white* 7)
(defvar *tterm-pframe-p* t)

(defvar *tterm-max-log-lines* 5000)

(defvar *tterm-ttype* "xterm")

; Input encoding: See *tterm-encoding-list*
(defvar *tterm-input-encoding* "euc-jp-with-esc")
; Output encoding
(defvar *tterm-output-encoding* *encoding-euc-jp*)

(defvar *tterm-encoding-list*
  '(("sjis" *tterm-state-sjis* *tterm-state-esc*)
    ("euc-jp" *tterm-state-eucjp* *tterm-state-esc*)
    ("iso-2022" *tterm-state-iso2022* *tterm-state-iso2022-esc* :us-ascii)
    ("utf8" *tterm-state-utf8* *tterm-state-iso2022-esc* :us-ascii)
    ("euc-jp-with-esc" *tterm-state-iso2022* *tterm-state-iso2022-esc*
     :us-ascii :jisx0208 :jisx0201-kana :jisx0212)
    ("sjis-with-esc" *tterm-state-sjis-with-esc* *tterm-state-iso2022-esc*
     :us-ascii :jisx0201-kana)
    ("iso-8859-1" *tterm-state-iso2022* *tterm-state-iso2022-esc*
     :us-ascii :iso8859-1)))

(mapc #'(lambda (x)
	  (setf (get (car x) 'tterm-iso2022-bytes) (cdr x)))
      '((:us-ascii . 1)
	(:jisx0201-kana . 1)
	(:iso8859-1 . 1)
	(:iso8859-2 . 1)
	(:iso8859-3 . 1)
	(:iso8859-4 . 1)
	(:iso8859-5 . 1)
	(:iso8859-7 . 1)
	(:iso8859-9 . 1)
	(:iso8859-10 . 1)
	(:jisx0208 . 2)
	(:gb2312 . 2)
	(:ksc5601 . 2)
	(:jisx0212 . 2)
	(:cns11643-1 . 2)
	(:cns11643-2 . 2)))

(defun tterm-define-state (symbol defs)
  (let ((table (make-vector 256)))
    (mapc #'(lambda (def)
	      (cond ((consp def)
		     (let ((ch (car def))
			   (fn (cdr def)))
		       (cond ((eq ch '*)
			      (dotimes (i 256)
				(setf (svref table i) fn)))
			     ((consp ch)
			      (let ((from (car ch))
				    (to (cdr ch)))
				(and (eq from '*) (setq from 0))
				(and (symbolp from) (setq from (symbol-value from)))
				(and (characterp from) (setq from (char-code from)))
				(and (eq to '*) (setq to 255))
				(and (symbolp to) (setq to (symbol-value to)))
				(and (characterp to) (setq to (char-code to)))
				(do ((i from (1+ i)))
				    ((> i to))
				  (setf (svref table i) fn))))
			     (t
			      (and (symbolp ch) (setq ch (symbol-value ch)))
			      (and (characterp ch) (setq ch (char-code ch)))
			      (setf (svref table ch) fn)))))
		    ((symbolp def)
		     (setq def (symbol-value def))
		     (when (and (vectorp def)
				(= (length def) (length table)))
		       (si:*copy-into-seq table def)))))
	  defs)
    (set symbol table)))

(tterm-define-state '*tterm-state-neutral*
		    '((* . tterm-insert-self)
		      ((0 . 31) . tterm-nul)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\C-g . tterm-bel)
		      (#\C-h . tterm-bs)
		      (#\TAB . tterm-ht)
		      (#\LFD . tterm-lf)
		      (#\C-k . tterm-lf)
		      (#\C-l . tterm-ff)
		      (#\RET . tterm-cr)
;		      (#\C-n . tterm-so)
;		      (#\C-o . tterm-si)
		      (#\C-x . tterm-can)
		      (#\C-z . tterm-can)
		      (#\ESC . tterm-esc)
		      (#\DEL . tterm-nul)
		      (#\x9b . tterm-csi)
		     ))

(tterm-define-state '*tterm-state-iac*
		    '((* . tterm-iac-unknown)
		      (*TELNET-CMD-DM* . tterm-iac-dm)
		      (*TELNET-CMD-DO* . tterm-iac-do)
		      (*TELNET-CMD-WILL* . tterm-iac-will)
		      (*TELNET-CMD-SB* . tterm-iac-sb)
		      ;(*TELNET-CMD-EL* . tterm-iac-el)
		      ;(*TELNET-CMD-EC* . tterm-iac-ec)
		      (*TELNET-CMD-DONT* . tterm-iac-dont)
		      (*TELNET-CMD-WONT* . tterm-iac-wont)))

(tterm-define-state '*tterm-state-iac-do*
		    '((* . tterm-iac-do-unknown)
		      ((0 . 44) . tterm-iac-do-any)
		      (*TELNET-OP-BINARY* . tterm-iac-do-binary)
		      (*TELNET-OP-ECHO* . tterm-iac-do-echo)
		      (*TELNET-OP-STATUS* . tterm-iac-do-status)
		      (*TELNET-OP-TM* . tterm-iac-do-tm)
		      (*TELNET-OP-TTYPE* . tterm-iac-do-ttype)
		      (*TELNET-OP-NAWS* . tterm-iac-do-naws)
		      (*TELNET-OP-TSPEED* . tterm-iac-do-tspeed)
;		      (*TELNET-OP-LINEMODE* . tterm-iac-do-linemode)
		      (*TELNET-OP-NEW_ENVIRON* . tterm-iac-do-nenviron)
		     ))

(tterm-define-state '*tterm-state-iac-will*
		    '((* . tterm-iac-will-unknown)
		      ((0 . 44) . tterm-iac-will-any)
		      (*TELNET-OP-BINARY* . tterm-iac-will-binary)
		      (*TELNET-OP-ECHO* . tterm-iac-will-echo)
		      (*TELNET-OP-SGA* . tterm-iac-will-sga)
		      (*TELNET-OP-STATUS* . tterm-iac-will-status)
		      (*TELNET-OP-TM* . tterm-iac-will-tm)
		      (*TELNET-OP-LOGOUT* . tterm-iac-will-logout)
;		      (*TELNET-OP-LINEMODE* . tterm-iac-will-linemode)
		     ))

(tterm-define-state '*tterm-state-iac-sb*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-OP-NAWS* . tterm-iac-sb-naws)
		      (*TELNET-OP-TSPEED* . tterm-iac-sb-tspeed)
		      (*TELNET-OP-TTYPE* . tterm-iac-sb-ttype)
		      (*TELNET-OP-LINEMODE* . tterm-iac-sb-linemode)
		      (*TELNET-OP-NEW_ENVIRON* . tterm-iac-sb-nenviron)
		     ))

(tterm-define-state '*tterm-state-iac-sb-unknown*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)))

(tterm-define-state '*tterm-state-iac-sb-naws*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)
		      (*TELNET-SUB-SEND* . tterm-iac-sb-naws-send)))

(tterm-define-state '*tterm-state-iac-sb-tspeed*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)
		      (*TELNET-SUB-SEND* . tterm-iac-sb-tspeed-send)))

(tterm-define-state '*tterm-state-iac-sb-ttype*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)
		      (*TELNET-SUB-SEND* . tterm-iac-sb-ttype-send)))

(tterm-define-state '*tterm-state-iac-sb-linemode*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)
		      (*TELNET-SUB-MODE* . tterm-iac-sb-linemode-mode)
		      (*TELNET-SUB-SLC* . tterm-iac-sb-linemode-slc)))

(tterm-define-state '*tterm-state-iac-sb-linemode-mode*
		    '((* . tterm-iac-sb-linemode-mode-any)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-linemode-slc-iac)))

(tterm-define-state '*tterm-state-iac-sb-linemode-slc*
		    '((* . tterm-iac-sb-linemode-slc-any)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-linemode-slc-iac)))

(tterm-define-state '*tterm-state-iac-sb-nenviron*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac-sb-unknown-iac)
		      (*TELNET-SUB-SEND* . tterm-iac-sb-nenviron-send)))

(tterm-define-state '*tterm-state-iac-sb-unknown-iac*
		    '((* . tterm-iac-sb-unknown)
		      (*TELNET-CMD-SE* . tterm-iac-sb-unknown-iac-se)))

(tterm-define-state '*tterm-state-iac-dont*
		    '((* . tterm-iac-dont-unknown)
		      ((0 . 44) . tterm-iac-dont-any)
		      (*TELNET-OP-ECHO* . tterm-iac-dont-echo)))

(tterm-define-state '*tterm-state-iac-wont*
		    '((* . tterm-iac-wont-unknown)
		      ((0 . 44) . tterm-iac-wont-any)
		      (*TELNET-OP-ECHO* . tterm-iac-wont-echo)
		      (*TELNET-OP-SGA* . tterm-iac-wont-sga)))

(tterm-define-state '*tterm-state-esc*
		    '((* . tterm-esc-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\[ . tterm-csi)
		      (#\] . tterm-osc)
		      (#\7 . tterm-esc-7)
		      (#\8 . tterm-esc-8)
		      (#\D . tterm-esc-D)
		      (#\M . tterm-esc-M)
		      (#\C-x . tterm-can)
		      (#\C-z . tterm-can)
		     ))

(tterm-define-state '*tterm-state-csi*
		    '((* . tterm-csi-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\0 . tterm-csi-digit)
		      (#\1 . tterm-csi-digit)
		      (#\2 . tterm-csi-digit)
		      (#\3 . tterm-csi-digit)
		      (#\4 . tterm-csi-digit)
		      (#\5 . tterm-csi-digit)
		      (#\6 . tterm-csi-digit)
		      (#\7 . tterm-csi-digit)
		      (#\8 . tterm-csi-digit)
		      (#\9 . tterm-csi-digit)
		      (#\; . tterm-csi-semi)
		      (#\@ . tterm-csi-@)
		      (#\` . tterm-csi-G)
		      (#\? . tterm-csi-ques)
		      (#\A . tterm-csi-A)
		      (#\B . tterm-csi-B)
		      (#\C . tterm-csi-C)
		      (#\D . tterm-csi-D)
		      (#\G . tterm-csi-G)
		      (#\H . tterm-csi-H)
		      (#\J . tterm-csi-J)
		      (#\K . tterm-csi-K)
		      (#\L . tterm-csi-L)
		      (#\M . tterm-csi-M)
		      (#\P . tterm-csi-P)
		      (#\X . tterm-csi-X)
		      (#\d . tterm-csi-d)
		      (#\f . tterm-csi-H)
		      (#\h . tterm-csi-h)
		      (#\l . tterm-csi-l)
		      (#\m . tterm-csi-m)
		      (#\r . tterm-csi-r)
		      (#\C-x . tterm-can)
		      (#\C-z . tterm-can)
		     ))

(tterm-define-state '*tterm-state-csi-ques*
		    '((* . tterm-csi-ques-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\0 . tterm-csi-digit)
		      (#\1 . tterm-csi-digit)
		      (#\2 . tterm-csi-digit)
		      (#\3 . tterm-csi-digit)
		      (#\4 . tterm-csi-digit)
		      (#\5 . tterm-csi-digit)
		      (#\6 . tterm-csi-digit)
		      (#\7 . tterm-csi-digit)
		      (#\8 . tterm-csi-digit)
		      (#\9 . tterm-csi-digit)
		      (#\; . tterm-csi-semi)
		      (#\h . tterm-csi-ques-h)
		      (#\l . tterm-csi-ques-l)
		      (#\r . tterm-csi-ques-l)
		      (#\s . tterm-csi-ques-h)
		     ))

(tterm-define-state '*tterm-state-osc*
		    '((* . tterm-osc-unknown)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\0 . tterm-csi-digit)
		      (#\1 . tterm-csi-digit)
		      (#\2 . tterm-csi-digit)
		      (#\3 . tterm-csi-digit)
		      (#\4 . tterm-csi-digit)
		      (#\5 . tterm-csi-digit)
		      (#\6 . tterm-csi-digit)
		      (#\7 . tterm-csi-digit)
		      (#\8 . tterm-csi-digit)
		      (#\9 . tterm-csi-digit)
		      (#\; . tterm-osc-semi)
		      (#\C-x . tterm-can)
		      (#\C-z . tterm-can)
		     ))

(tterm-define-state '*tterm-state-osc-semi*
		    '((* . tterm-osc-semi-txt)
		      (#\C-g . tterm-osc-semi-bel)
		      (#\C-x . tterm-can)
		      (#\C-z . tterm-can)
		     ))

(defun tterm-init-input-encoding ()
  (setq tterm-iso2022-gl 0)
  (setq tterm-iso2022-gr 1)
  (setq tterm-iso2022-ss nil)
  (dotimes (x 4)
    (setf (svref tterm-iso2022-g x) nil))
  (let ((x (find tterm-input-encoding *tterm-encoding-list*
		 :key #'car :test #'equalp)))
    (cond (x
	   (setq x (cdr x))
	   (setq tterm-state-neutral (symbol-value (pop x)))
	   (setq tterm-state-esc (symbol-value (pop x)))
	   (let ((i 0))
	     (while x
	       (setf (svref tterm-iso2022-g i) (pop x))
	       (incf i))))
	  (t
	   (setq tterm-state-neutral *tterm-state-neutral*)
	   (setq tterm-state-esc *tterm-state-esc*)
	   (warn "unknown encoding: ~a" tterm-input-encoding))))
  (setq tterm-state tterm-state-neutral))

#|
(defmacro tterm-input-eol ()
  `(if tterm-flag-crmod "\r" "\r\n"))
|#

(defmacro tterm-output-eol ()
  `(if tterm-flag-crlf "\r\n" "\r"))

(defun tterm-mode ()
  (kill-all-local-variables)
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf (+ *window-flag-newline*
				   *window-flag-tab* 
				   *window-flag-full-width-space* 
				   *window-flag-eof* 
				   *window-flag-hscroll-bar* 
				   *window-flag-cursor-line* 
				   *window-flag-line-number* 
				   *window-flag-half-width-space* 
				   *window-flag-scrolling*)
			    nil)
    (set-local-window-flags buf (+ *window-flag-vscroll-bar*
				   *window-flag-mode-line*
				   (if (boundp '*window-flag-fold-mark*)
				       *window-flag-fold-mark*
				     *window-flag-fold-line*))
			    t))
  (set-buffer-fold-width nil (selected-buffer))
  (set-tab-columns 8 (selected-buffer))

  (make-local-variable 'need-not-save)
  (make-local-variable '*scroll-margin*)

  (setq buffer-mode 'tterm-mode
	mode-name "TTerm"
	kept-undo-information nil
	need-not-save t
	buffer-read-only nil
	*scroll-margin* 0)

  (make-local-variable 'cmd-buffer)
  (make-local-variable 'scr-buffer)

  (make-local-variable 'tterm-char-mode)
  (make-local-variable 'tterm-meta-code)
  (setq tterm-meta-code *tterm-meta-code*)

  (make-local-variable 'tterm-host)
  (make-local-variable 'tterm-user)

  (make-local-variable 'tterm-flag-crlf)
  (make-local-variable 'tterm-flag-crmod)
  (setq tterm-flag-crlf *tterm-flag-crlf*
	tterm-flag-crmod *tterm-flag-crmod*)

  (make-local-variable 'tterm-flag-netdata)
  (make-local-variable 'tterm-flag-options)
  (make-local-variable 'tterm-flag-prettydump)
  (setq tterm-flag-netdata *tterm-flag-netdata*
	tterm-flag-options *tterm-flag-options*
	tterm-flag-prettydump *tterm-flag-prettydump*)

  (make-local-variable 'tterm-state)
  (make-local-variable 'tterm-before-state)
  (make-local-variable 'tterm-state-neutral)
  (make-local-variable 'tterm-state-esc)
  (setq tterm-state-neutral *tterm-state-neutral*)
  (setq tterm-state-esc *tterm-state-esc*)

  (make-local-variable 'tterm-cursor-x)
  (make-local-variable 'tterm-cursor-y)
;  (setq tterm-cursor-x 0 tterm-cursor-y 0)

  (make-local-variable 'tterm-window-width)
  (make-local-variable 'tterm-window-height)
  (make-local-variable 'tterm-window-width-1)
  (make-local-variable 'tterm-window-height-1)
  (setq tterm-window-width 80
	tterm-window-height 24)
  (setq tterm-window-width-1 (1- tterm-window-width)
	tterm-window-height-1 (1- tterm-window-height))
  (tterm-window-size)

  (make-local-variable 'tterm-buffer-start)
  (make-local-variable 'tterm-window-start)
  (make-local-variable '*tterm-buffer*)
  (make-local-variable 'tterm-title)
  (setq tterm-window-start 1)
  (setq *tterm-buffer* (make-vector 256
				    :element-type 'character
				    :adjustable t
				    :fill-pointer 0))
  (setq tterm-title (make-vector 32
				 :element-type 'character
				 :adjustable t
				 :fill-pointer 0))

  (make-local-variable 'tterm-csi-param)
  (make-local-variable 'tterm-csi-nparams)
  (make-local-variable 'tterm-csi-value)
  (setq tterm-csi-param (make-vector 16))

  (make-local-variable 'tterm-text-fg)
  (make-local-variable 'tterm-text-bg)
  (make-local-variable 'tterm-text-bo)
  (make-local-variable 'tterm-text-ul)
  (make-local-variable 'tterm-text-rv)
  (make-local-variable 'tterm-text-attribute-list)
  (make-local-variable 'tterm-text-attribute-start)

  (make-local-variable 'tterm-scroll-range-top)
  (make-local-variable 'tterm-scroll-range-bottom)
;  (setq tterm-scroll-range-top nil)
;  (setq tterm-scroll-range-bottom nil)

  (make-local-variable 'tterm-screen-stack)
  (make-local-variable 'tterm-cursor-stack)
;  (setq tterm-cursor-stack nil)
  (make-local-variable 'tterm-insert-mode)
;  (setq tterm-insert-mode nil)

  (make-local-variable 'tterm-lead-char)

  (make-local-variable 'tterm-lead-char-2)
  (make-local-variable 'tterm-lead-char-3)

  (make-local-variable 'tterm-iso2022-g)
  (make-local-variable 'tterm-iso2022-gl)
  (make-local-variable 'tterm-iso2022-gr)
  (make-local-variable 'tterm-iso2022-ss)
  (make-local-variable 'tterm-iso2022-sg)
  (make-local-variable 'tterm-iso2022-charset)

  (setq tterm-iso2022-g (make-vector 4))
  (setq tterm-iso2022-gl 0)
  (setq tterm-iso2022-gr 1)
  (setq tterm-iso2022-ss nil)
  (setf (svref tterm-iso2022-g 0) :us-ascii)

  (make-local-variable 'tterm-input-encoding)
  (setq tterm-input-encoding *tterm-input-encoding*)
  (tterm-init-input-encoding)
  (make-local-variable 'tterm-output-encoding)
  (setq tterm-output-encoding *tterm-output-encoding*)
  (make-local-variable 'default-input-function)
  (setq default-input-function 'tterm-self-send-command)

  (make-local-variable 'tterm-telnet-option)
  (setq tterm-telnet-option
	(make-vector 45 :element-type 'integer :initial-element 0))

  (make-local-variable '*tterm-proc*)
  (make-local-variable '*tterm-char*)
  (make-local-variable '*tterm-code*)

  (make-local-variable 'option-string)
  (make-local-variable 'tterm-prompt-end-point)

  (make-local-variable 'tterm-reset-p)
  (make-local-variable 'tterm-local-echo-p)
  (make-local-variable 'tterm-app-cursor-p)
  (make-local-variable 'tterm-mouse-mode)

  (make-local-variable 'tterm-filter-hook)

  (use-keymap *tterm-mode-map*)
  (run-hooks '*tterm-mode-hook*)
)

(defun tterm-cmd-mode ()
  (kill-all-local-variables)
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf *window-flag-mode-line* t)
    (set-local-window-flags buf *window-flag-cursor-line* nil))

  (make-local-variable 'need-not-save)
  (setq buffer-mode 'tterm-cmd-mode
	mode-name "TTerm Command"
	kept-undo-information nil
	need-not-save t)
  (make-local-variable 'tterm-pframe)
  (setq tterm-pframe nil)
  (make-local-variable '*delete-buffer-hook*)
  (setq *delete-buffer-hook*
	#'(lambda (buffer)
	    (let ((pframe (buffer-local-value buffer 'tterm-pframe)))
	      (and pframe (delete-pseudo-frame pframe)))
	    t))

  (make-local-variable 'term-buffer)

  (use-keymap *tterm-cmd-mode-map*)

  (run-hooks '*tterm-cmd-mode-hook*)
)

(defvar-local tterm-char-mode nil)
(pushnew '(tterm-char-mode . "Char") *minor-mode-alist* :key #'car)

(defun tterm-char-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode 'tterm-char-mode arg sv)
  (update-mode-line t)
  (cond (tterm-char-mode
	 (set-minor-mode-map *tterm-char-mode-map*)
	 (and tterm-meta-code
	      (set-minor-mode-map *tterm-meta-keymap*)))
	(t
	 (unset-minor-mode-map *tterm-char-mode-map*)
	 (and tterm-meta-code
	      (unset-minor-mode-map *tterm-meta-keymap*))))
  t)

(defun tterm-toggle-meta (&optional (arg nil sv))
  (interactive "p")
  (setq tterm-meta-code (if sv
			    arg
			  (null (eq tterm-meta-code t))))
  (when tterm-char-mode
    (if tterm-meta-code
	(set-minor-mode-map *tterm-meta-keymap*)
      (unset-minor-mode-map *tterm-meta-keymap*))))

(defun tterm-toggle-meta-emu (&optional (arg nil sv))
  (interactive "p")
  (if sv
      (tterm-toggle-meta (if arg :esc))
    (tterm-toggle-meta (unless (eq tterm-meta-code :esc)
			 :esc))))

(defmacro tterm-fixed-buffer (name init-func)
  `(let ((buffer (create-new-buffer ,name)))
     (save-excursion
       (set-buffer buffer)
       (funcall ,init-func)
       buffer)))

(defconstant *tterm-buffer-name* "*tterm*")

(defun tterm-init-buffer (&optional title)
  (let ((term (tterm-fixed-buffer (concat *tterm-buffer-name*
					  (or title ""))
				  #'tterm-mode))
	(cmd (tterm-fixed-buffer "*tterm command*" #'tterm-cmd-mode)))
    (let ((pframe (and *tterm-pframe-p*
		       (fboundp 'new-pseudo-frame)
		       (save-window-excursion
			 (new-pseudo-frame (buffer-name term))))))
      (set-buffer term)
      (setq cmd-buffer cmd)
      (set-buffer cmd)
      (setq term-buffer term)
      (setq tterm-pframe pframe)
      (insert (format nil "~a~%" *tterm-version*))
      (values term cmd))))

(defun tterm-sync-stream (buffer)
  (if (eq (selected-buffer) buffer)
      (goto-char (buffer-stream-point *standard-output*))
    (let ((ow (selected-window))
	  (w (get-buffer-window buffer)))
      (cond (w
	     (set-window w)
	     (goto-char (buffer-stream-point *standard-output*))
	     (set-window ow))
	    (t
	     (save-excursion
	       (set-buffer buffer)
	       (goto-char (buffer-stream-point *standard-output*))))))))

;;
;; tterm main
;;
(defun tterm (&optional host port &key user)
  (interactive)
  (trap-errors
    (load "~/.tterm" :if-does-not-exist nil :verbose nil :print nil))
  (unless host
    (setq host (completing-read "Host: " *tterm-favorite-hosts*)))
  (multiple-value-bind (term cmd)
      (tterm-init-buffer)
    (pop-to-buffer cmd)
    (with-output-to-buffer (cmd (point-max))
      (princ "\n")
      (unwind-protect
	  (if (equal host "")
	      (princ "tterm> ")
	    (progn
	      (if port
		  (setq port (format nil "~d" port))
		(setq port (read-string "Port: " :default "telnet")))
	      (if user (save-excursion
			 (set-buffer term-buffer)
			 (setq tterm-user user)))
	      (princ "\n")
	      (funcall #'tterm-cmd-open host port)))
	(tterm-sync-stream cmd)))
    term))

(setf (get 'with-tterm-cmd-buffer 'ed:lisp-indent-hook) 0)

(defmacro with-tterm-cmd-buffer (term &rest body)
  `(let ((obuf (selected-buffer))
	 (tbuf ,term))
     (let ((ow (selected-window))
	   (tw (get-buffer-window tbuf)))
       (cond ((eq tbuf (selected-buffer)))
	     (tw
	      (set-window tw))
	     (t
	      (set-buffer tbuf)))
       (with-output-to-buffer (cmd-buffer (buffer-size cmd-buffer))
	 ,@body
	 (tterm-sync-stream cmd-buffer)
	 (cond ((eq ow tw)
		(refresh-screen))
	       (tw
		(set-window ow)
		(refresh-screen))
	       (t
		(set-buffer obuf)))))))

;;;------------------------------------------------------------------------
;;; ÉRÉ}ÉìÉh
;;;

(defvar tterm-cmd-alist
  '(("close"    . tterm-cmd-close)
    ("logout"   . tterm-cmd-unsupported)
    ("display"  . tterm-cmd-unsupported)
    ("mode" . tterm-cmd-change-mode)
    ("open" . tterm-cmd-open)
    ("quit" . tterm-cmd-quit)
    ("send" . tterm-cmd-unsupported)
    ("set"  . tterm-cmd-unsupported)
    ("unset"    . tterm-cmd-unsupported)
    ("status"   . tterm-cmd-unsupported)
    ("toggle"   . tterm-cmd-toggle)
    ("slc"  . tterm-cmd-unsupported)
    ("z"    . tterm-cmd-unsupported)
    ("!"    . tterm-cmd-unsupported)
    ("environ"  . tterm-cmd-unsupported)
    ("?"    . tterm-cmd-help)
    ("help" . tterm-cmd-help)))

(defun tterm-detect-command ()
  (interactive)
  (when (eq buffer-mode 'tterm-cmd-mode)
    (let ((cmdline (save-excursion
		     (goto-bol)
		     (if (scan-buffer "^tterm> \\(.*\\)$" :regexp t)
			 (split-string (match-string 1) #\SPC))))
	  (buf (selected-buffer))
	  func)
      (setq func (cdr (assoc (car cmdline)
			     tterm-cmd-alist :test #'string-equal)))
      (with-output-to-buffer (buf (point-max))
	(princ "\n")
	(unwind-protect
	    (if func
		(apply func (cdr cmdline))
	      (if cmdline
		  (format t "?Invalid command~{~[~; ~s~]~}.~%"
			  (if cmdline (list 1 (car cmdline)) '(0)))
		(when (tterm-buffer-process term-buffer)
		  (pop-to-buffer term-buffer))))
	  (unless (deleted-buffer-p buf)
	    (princ "tterm> ")
	    (tterm-sync-stream buf)))))))

(defvar *tterm-favorite-hosts* '("localhost" "your.favorite.host"))

(defun tterm-completion-command ()
  (interactive)
  (let* ((compl '("close"
		  ;"logout"
		  ;"display"
		  ("mode" "character" "line")
		  ("open" . *tterm-favorite-hosts*)
		  "quit"
		  ;"send"
		  ;"set"
		  ;"unset"
		  ;"status"
		  ("toggle" "crlf" "crmod" "options" "netdata" "prettydump")
		  ;"slc"
		  ;"z"
		  ;"!"
		  ;"environ"
		  ("help" "close" "mode" "open" "quit" "toggle")))
	 (beg
	  (save-excursion
	    (let* ((cmdline (let ((opoint (point)))
			      (goto-bol)
			      (unless (scan-buffer "^tterm> *\\(.*\\)"
						   :limit opoint :regexp t :tail t)
				(return-from tterm-completion-command))
			      (split-string (match-string 1) #\SPC)))
		   (beg (match-beginning 1))
		   (nargs (length cmdline)))
	      (and (plusp nargs)
		   (skip-chars-backward "^ ")
		   (decf nargs))
	      (while (and (plusp nargs)
			  (setq compl (cdr (find-if #'(lambda (x)
							(and (consp x)
							     (equal (car x) (car cmdline))))
						    compl))))
		(decf nargs)
		(pop cmdline)
		(when (symbolp compl)
		  (setq compl (symbol-value compl))))
	      (max beg (point))))))
    (let* ((no-match nil)
	   (*print-completion-list-hook*
	    #'(lambda (list prefix)
		(let ((opoint (point))
		      (line (buffer-substring (progn (goto-bol) (point))
					      (progn (goto-eol) (point)))))
		  (decf opoint (point))
		  (or (forward-line 1)
		      (insert #\LFD))
		  (insert (format nil "~{~A~^  ~}~%" list))
		  (insert line)
		  (forward-char opoint)
		  (setq no-match t)))))
      (do-completion-internal beg (point) :list compl)
      (or no-match
	  (let ((string (buffer-substring beg (point))))
	    (and (find-if #'(lambda (x)
			      (string= string (if (consp x) (car x) x)))
			  compl)
		 (or (find-if #'(lambda (x)
				  (eql (string/= string (if (consp x) (car x) x))
				       (length string)))
			      compl)
		     (if (looking-for " ")
			 (forward-char 1)
		       (insert " ")))))))
    t))

(defun tterm-cmd-unsupported (&optional arg)
  (princ "Unsupported command.\n"))

(let ((*help-string-alist*
       '(("close"   .	"close current connection")
;	 ("logout"  .	"forcibly logout remote user and close the connection")
;	 ("display" .	"display operating parameters")
	 ("mode"    .	"try to enter line or character mode ('mode ?' for more)")
	 ("open"    .	"connect to a site")
	 ("quit"    .	"exit telnet")
;	 ("send"    .	"transmit special characters ('send ?' for more)")
;	 ("set"	.   "set operating parameters ('set ?' for more)")
;	 ("unset"   .	"unset operating parameters ('unset ?' for more)")
;	 ("status"  .	"print status information")
	 ("toggle"  .	"toggle operating parameters ('toggle ?' for more)")
;	 ("slc"	.   "change state of special charaters ('slc ?' for more)")
;	 ("z"	.   "suspend telnet")
;	 ("!"	.   "invoke a subshell")
;	 ("environ" .	"change environment variables ('environ ?' for more)")
	 ("?"	.   "print help information")))
      (*help-string-toggle-alist*
       '(
;	 ("autoflush"	.   "toggle flushing of output when sending interrupt characters")
;	 ("autosynch"	.   "toggle automatic sending of interrupt characters in urgent mode")
;	 ("skiprc"  .	"toggle don't read ~/.telnetrc file")
;	 ("binary"  .	"toggle sending and receiving of binary data")
;	 ("inbinary"	.   "toggle receiving of binary data")
;	 ("outbinary"	.   "toggle sending of binary data")
	 ("crlf"    .	"toggle sending carriage returns as telnet <CR><LF>")
	 ("crmod"   .	"toggle mapping of received carriage returns")
;	 ("localchars"	.   "toggle local recognition of certain control characters")
	 ("")
;	 ("debug"   .	"toggle debugging")
	 ("netdata" .	"toggle printing of hexadecimal network data (debugging)")
	 ("prettydump"	.   "toggle output of 'netdata' to user readable format (debugging)")
	 ("options" .	"toggle viewing of options processing (debugging)")
;	 ("termdata"	.   "toggle (debugging) toggle printing of hexadecimal terminal data")
	 ("")
	 ("?"	.   "display help information")))
      (*help-string-mode-alist*
       '(("format is:  'mode Mode', where 'Mode' is one of:")
	 ("")
	 ("character" . "Disable LINEMODE option")
	 ("(or disable obsolete line-by-line mode)")
	 ("line" . "Enable LINEMODE option")
	 ("(or enable obsolete line-by-line mode)")
	 ("")
;	 ("These require the LINEMODE option to be enabled" . "")
;	 ("isig" . "Enable signal trapping")
;	 ("-isig" . "Disable signal trapping")
;	 ("edit" . "Enable character editing")
;	 ("-edit" . "Disable character editing")
;	 ("softtabs" . "Enable tab expansion")
;	 ("-softtabs" . "Disable character editing")
;	 ("litecho" . "Enable literal character echo")
;	 ("-litecho" . "Disable literal character echo")
;	 ("")
	 ("?" . "Print help information"))))

  (let ((*help-alist* (list (cons ':mode *help-string-mode-alist*)
			    (cons ':toggle *help-string-toggle-alist*))))
    (defun tterm-help-more (arg)
      (let ((more-alist (cdr (assoc arg *help-alist* :test #'equal))))
	(mapc #'(lambda (x)
		  (format t "~A~@[~16T~A~]~%" (car x) (cdr x)))
	      more-alist))))

  (defun tterm-cmd-help (&optional arg)
    (if arg
	(let ((help-string (cdr (assoc arg *help-string-alist*
				       :test #'string-equal))))
	  (if help-string
	      (format t "~A~%" help-string)
	    (format t "?Invalid help command ~A~%" arg)))
      (mapc #'(lambda (x)
		(format t "~A~@[~16T~A~]~%" (car x) (cdr x)))
	    *help-string-alist*)))
)

(defvar *tterm-initial-telnet-option*
  '((*TELNET-OP-SGA* . *TELNET-CMD-DO*)
    (*TELNET-OP-TTYPE* . *TELNET-CMD-WILL*)
    (*TELNET-OP-NAWS* . *TELNET-CMD-WILL*)
    (*TELNET-OP-TSPEED* . *TELNET-CMD-WILL*)
;    (*TELNET-OP-LFLOW* . *TELNET-CMD-WILL*)
;    (*TELNET-OP-LINEMODE* . *TELNET-CMD-WILL*)
    (*TELNET-OP-NEW_ENVIRON* . *TELNET-CMD-WILL*)
    (*TELNET-OP-STATUS* . *TELNET-CMD-DO*)
   ))

(defvar *tterm-io-encoding-alist*
  '(("localhost" "sjis-with-esc" *encoding-sjis*)))

(defun tterm-cmd-open (&optional host (port "telnet"))
  (if (tterm-buffer-process term-buffer)
      (format t "?Already connected to ~A.~%"
	      (save-excursion
		(set-buffer term-buffer)
		(tterm-host)))
    (cond (host
;	   (erase-buffer term-buffer)
	   (if (get-buffer-window term-buffer)
	       (pop-to-buffer term-buffer)
	     (set-buffer term-buffer))
	   (let ((def (assoc host *tterm-io-encoding-alist* :test #'string=)))
	     (when def
	       (setq tterm-input-encoding (cadr def))
	       (setq tterm-output-encoding (if (symbolp (caddr def))
					       (symbol-value (caddr def))
					     (caddr def)))))
	   (tterm-reset-terminal)
	   (message "Trying ~a..." host)
	   (tterm-connect host port)
	   (message "Connected to ~a. Escape character is ~a."
		    host
		    (let ((keys (command-keys 'tterm-char-mode
					      *tterm-mode-map* nil)))
		      (if keys
			  (key-to-string (car keys))
			"not available")))
	   (setq tterm-host host)
	   (cond ((or (equal port "23") (equal port "telnet"))
		  (mapc #'(lambda (x)
			    (let ((op (symbol-value (car x))))
			      (cond ((eq (symbol-value (cdr x)) *TELNET-CMD-DO*)
				     (tterm-send-do op))
				    ((eq (symbol-value (cdr x)) *TELNET-CMD-WILL*)
				     (tterm-send-will op))
				    ((eq (symbol-value (cdr x)) *TELNET-CMD-DONT*)
				     (tterm-send-dont op))
				    ((eq (symbol-value (cdr x)) *TELNET-CMD-WONT*)
				     (tterm-send-wont op)))))
			*tterm-initial-telnet-option*)
		  (tterm-process-send-string (buffer-process (selected-buffer))))
		 (t
		  (setq tterm-flag-crlf t))))
	  (t
	   (princ "usage: open host-name [port]\n")))))

(defun tterm-cmd-close (&optional arg)
  (let ((proc (tterm-buffer-process term-buffer)))
    (if proc
	(progn
	  (kill-process proc)
	  (princ "Connection closed.\n"))
      (princ "?Need to be connected first.\n"))))

(defun tterm-cmd-change-mode (&optional arg)
  (if arg
      (cond ((equal arg "character")
	     (save-excursion
	       (set-buffer term-buffer)
	       (let ((sga-code (char-code *TELNET-OP-SGA*))
		     (echo-code (char-code *TELNET-OP-ECHO*)))
		 (or (tterm-get-telnet-option sga-code t)
		     (tterm-send-do *TELNET-OP-SGA*
				    sga-code "SUPPRESS-GO-AHEAD"))
		 (or (tterm-get-telnet-option echo-code)
		     (tterm-send-will *TELNET-OP-ECHO* echo-code "ECHO"))
		 (tterm-process-send-string (buffer-process (selected-buffer)))
	       )))
	    ((equal arg "line")
	     (save-excursion
	       (set-buffer term-buffer)
	       (let ((sga-code (char-code *TELNET-OP-SGA*))
		     (echo-code (char-code *TELNET-OP-ECHO*)))
		 (and (tterm-get-telnet-option sga-code t)
		      (tterm-send-dont *TELNET-OP-SGA* sga-code
				       "SUPPRESS-GO-AHEAD"))
		 (and (tterm-get-telnet-option echo-code)
		      (tterm-send-wont *TELNET-OP-ECHO* echo-code "ECHO"))
		 (tterm-process-send-string (buffer-process (selected-buffer)))
	       )))
	    ((equal arg "?")
	     (tterm-help-more ':mode))
	    (t
	     (format t "'~A' : unknown argument ('mode ?' for help).~%" arg)))
    (princ "?Need an argument to 'mode' command.  'mode ?' for help.\n")))

(defun tterm-cmd-quit (&optional arg)
  (if (tterm-buffer-process term-buffer)
      (princ "?Need to be closed first.\n")
    (progn
      (set-buffer term-buffer)
      (let ((tb (selected-buffer))
	    (cb cmd-buffer)
	    (sb scr-buffer))
	(let ((tw (get-buffer-window tb))
	      (cw (get-buffer-window cb)))
	  (when (and tw cw)
	    (set-window cw)
	    (delete-window)))
	(delete-buffer tb)
	(delete-buffer cb)
	(and sb (delete-buffer sb))))))

(defun tterm-cmd-toggle (&optional arg)
  (if arg
      (cond ((equal arg "crlf")
	     (save-excursion
	       (set-buffer term-buffer)
	       (format t "Will send carriage returns as telnet <CR><~A>.~%"
		       (if (setq tterm-flag-crlf (null tterm-flag-crlf))
			   "LF" "NUL"))))
	    ((equal arg "crmod")
	     (save-excursion
	       (set-buffer term-buffer)
	       (format t "W~A map carriage return on output.~%"
		       (if (setq tterm-flag-crmod (null tterm-flag-crmod))
			   "ill" "on't"))))
	    ((equal arg "options")
	     (save-excursion
	       (set-buffer term-buffer)
	       (format t "W~A show option processing.~%"
		       (if (setq tterm-flag-options (null tterm-flag-options))
			   "ill" "on't"))))
	    ((equal arg "netdata")
	     (save-excursion
	       (set-buffer term-buffer)
	       (format t "W~A print hexadecimal representation of network traffic.~%"
		       (if (setq tterm-flag-netdata (null tterm-flag-netdata))
			   "ill" "on't"))))
	    ((equal arg "prettydump")
	     (save-excursion
	       (set-buffer term-buffer)
	       (format t "W~A print user readable output for 'netdata'.~%"
		       (if (setq tterm-flag-prettydump (null tterm-flag-prettydump))
			   "ill" "on't"))))
	    ((equal arg "?")
	     (tterm-help-more ':toggle))
	    (t
	     (format t "'~A' : unknown argument ('toggle ?' for help).~%" arg)))
    (princ "?Need an argument to 'toggle' command.  'toggle ?' for help.\n")))



(defmacro tterm-display-option (&rest arg)
  `(and tterm-flag-options
	(format t ,@arg)))

(defun tterm-display-netdata (str &key (direction 'input))
  (when tterm-flag-netdata
    (let ((is (make-string-input-stream str))
	  (n 0)
	  c)
      (while (setq c (read-char is nil nil))
	(if (eq (mod n 32) 0)
	    (format t "~%~[<~;>~] ~:@(~2,'0X~)  "
		    (if (eq direction 'input) 0 1)
		    (truncate n 16)))
	(format t "~:@(~2,'0X~)" (char-code c))
	(incf n))
      (princ "\n"))
  ))

(defmacro tterm-display-prettydump (str)
  `(and tterm-flag-prettydump
	(format t "~A~%" ,str)))


;;;------------------------------------------------------------------------
;;; Telnet èàóù
;;;

(defun tterm-push-option-string (str)
  (if option-string
      (setq option-string (concat option-string str))
    (setq option-string str)))

(defun tterm-process-send-string (process &optional str)
  (when (or str (prog1 (setq str option-string)
		  (setq option-string nil)))
    (tterm-display-netdata str :direction 'output)
    (process-send-string process str)))

(defun tterm-send-string (proc string)
  (with-tterm-cmd-buffer
   (selected-buffer)
   (let ((str (convert-encoding-from-internal tterm-output-encoding string)))
     (tterm-process-send-string proc str)
     (if tterm-local-echo-p
	 (tterm-process-input proc str)))))

(defun tterm-connect (host port)
  (let ((proc (open-network-stream (selected-buffer) host port
				   :incode *encoding-binary*
				   :outcode *encoding-binary*
				   :eol-code *eol-lf*)))
    (set-process-filter proc #'tterm-process-filter)
    (set-process-sentinel proc #'(lambda (proc)
				   (save-excursion
				     (set-buffer (process-buffer proc))
				     (setq tterm-host nil tterm-user nil))
				   (message "Connection closed.")))))

(defun tterm-buffer-process (buffer)
  (let ((proc (buffer-process buffer)))
    (when proc
      (if (eq (process-status proc) :run)
	  proc))))

(defun tterm-send-do (char &optional code msgstr)
  (or code (setq code (char-code char)))
  (tterm-push-option-string (format nil "~c~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-DO* char))
  (tterm-display-option "SENT DO ~A~%" (or msgstr code))
  (tterm-set-telnet-option code *TELNET-SENT-DO*))

(defun tterm-send-will (char &optional code msgstr)
  (or code (setq code (char-code char)))
  (tterm-push-option-string (format nil "~c~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-WILL* char))
  (tterm-display-option "SENT WILL ~A~%" (or msgstr code))
  (tterm-set-telnet-option code *TELNET-SENT-WILL*))

(defun tterm-send-dont (char &optional code msgstr)
  (or code (setq code (char-code char)))
  (tterm-push-option-string (format nil "~c~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-DONT* char))
  (tterm-display-option "SENT DONT ~A~%" (or msgstr code))
  (tterm-unset-telnet-option code *TELNET-RCVD-WILL*))

(defun tterm-send-wont (char &optional code msgstr)
  (or code (setq code (char-code char)))
  (tterm-push-option-string (format nil "~c~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-WONT* char))
  (tterm-display-option "SENT WONT ~A~%" (or msgstr code))
  (tterm-unset-telnet-option code *TELNET-RCVD-DO*))

(defun tterm-send-ip ()
  (tterm-push-option-string (format nil "~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-IP*))
  (tterm-display-option "SENT IP~%"))

(defun tterm-window-size ()
  (let ((w (window-columns))
	(h (window-lines)))
    (when (> w 4)
      (setq tterm-window-width (- w 2))
      (setq tterm-window-width-1 (1- tterm-window-width)))
    (when (> h 2)
      (setq tterm-window-height h)
      (setq tterm-window-height-1 (1- tterm-window-height)))))

(defun tterm-send-window-size ()
  (if (tterm-get-telnet-option (char-code *TELNET-OP-NAWS*))
      (let ((c tterm-window-width)
	    (r tterm-window-height))
	(tterm-push-option-string (format nil "~c~c~c~c~c~c~c~c~c"
				   *TELNET-CMD-IAC*
				   *TELNET-CMD-SB*
				   *TELNET-OP-NAWS*
				   (code-char (truncate c 256))   ; columns
				   (code-char (logand #xFF c))    ;
				   (code-char (truncate r 256))   ; row
				   (code-char (logand #xFF r))    ;
				   *TELNET-CMD-IAC* *TELNET-CMD-SE*))
	(tterm-display-option "SENT IAC SB NAWS ~d ~d (~d) ~d ~d (~d)~%"
			      (truncate c 256) (logand #xFF c) c
			      (truncate r 256) (logand #xFF r) r))))

(defmacro tterm-correct-screen ()
  `(let ((nlines (- (buffer-lines) tterm-window-start
		    tterm-window-height -1)))
     (unless (<= nlines 0)
       (setq tterm-cursor-y (max (- tterm-cursor-y nlines) 0))
       (incf tterm-window-start nlines))))

(defun tterm-check-window-size ()
  (let ((c tterm-window-width)
	(r tterm-window-height))
    (tterm-window-size)
    (unless (and (eql c tterm-window-width)
		 (eql r tterm-window-height))
      (tterm-send-window-size)
      (tterm-correct-screen))))

(defun tterm-do-ack (msgstr)
  (tterm-display-option "RCVD DO ~A~%" msgstr)
  (tterm-set-telnet-option *tterm-code* *TELNET-RCVD-DO*)
  (unless (tterm-get-telnet-option *tterm-code*)
    (tterm-send-will *tterm-char* *tterm-code* msgstr)))

(defun tterm-do-nak (msgstr)
  (tterm-display-option "RCVD DO ~A~%" msgstr)
  (tterm-set-telnet-option *tterm-code* *TELNET-RCVD-DO*)
  (unless (tterm-sent-will-p *tterm-code*)
    (tterm-send-wont *tterm-char* *tterm-code* msgstr)))

(defun tterm-will-ack (msgstr)
  (tterm-display-option "RCVD WILL ~A~%" msgstr)
  (tterm-set-telnet-option *tterm-code* *TELNET-RCVD-WILL*)
  (unless (tterm-get-telnet-option *tterm-code* t)
    (tterm-send-do *tterm-char* *tterm-code* msgstr)))

(defun tterm-will-nak (msgstr)
  (tterm-display-option "RCVD WILL ~A~%" msgstr)
  (tterm-set-telnet-option *tterm-code* *TELNET-RCVD-WILL*)
  (unless (tterm-sent-do-p *tterm-code*)
    (tterm-send-dont *tterm-char* *tterm-code* msgstr)))

(defun tterm-dont-nak (msgstr)
  (tterm-display-option "RCVD DONT ~A~%" msgstr)
  (if (tterm-sent-will-p *tterm-code*)
      (tterm-send-wont *tterm-char* *tterm-code* msgstr)
    (tterm-unset-telnet-option *tterm-code* *TELNET-SENT-WILL*)))

(defun tterm-wont-nak (msgstr)
  (tterm-display-option "RCVD WONT ~A~%" msgstr)
  (if (tterm-sent-do-p *tterm-code*)
      (tterm-send-dont *tterm-char* *tterm-code* msgstr)
    (tterm-unset-telnet-option *tterm-code* *TELNET-SENT-DO*)))

(defun tterm-iac ()
  (setq tterm-before-state tterm-state)
  (setq tterm-state *tterm-state-iac*))

(defun tterm-iac-dm ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD IAC DM~%"))

(defun tterm-iac-do ()
  (setq tterm-state *tterm-state-iac-do*))

(defun tterm-iac-will ()
  (setq tterm-state *tterm-state-iac-will*))

(defun tterm-iac-sb ()
  (setq tterm-state *tterm-state-iac-sb*))

(defun tterm-iac-dont ()
  (setq tterm-state *tterm-state-iac-dont*))

(defun tterm-iac-wont ()
  (setq tterm-state *tterm-state-iac-wont*))

(defun tterm-iac-unknown ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD IAC ~d~%" *tterm-code*))

(defun tterm-iac-do-binary ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "TRANSMIT-BINARY"))

(defun tterm-iac-do-echo ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "ECHO")
  (setq tterm-local-echo-p t))

(defun tterm-iac-do-status ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "STATUS"))

(defun tterm-iac-do-tm ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "TIMING-MARK"))

(defun tterm-iac-do-ttype ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "TERMINAL-TYPE"))

(defun tterm-iac-do-naws ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "NAWS")
  (tterm-window-size)
  (tterm-send-window-size))

(defun tterm-iac-do-tspeed ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "TERMINAL-SPEED"))

(defun tterm-iac-do-linemode ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "LINEMODE")
  (tterm-push-option-string
   (format nil "~@{~c~}"
	   *TELNET-CMD-IAC* *TELNET-CMD-SB* *TELNET-OP-LINEMODE* *TELNET-SUB-SLC*
	   *TELNET-SLC-SYNCH* *TELNET-SLC-DEFAULT* #\NUL
	   *TELNET-SLC-IP* (code-char (logior *TELNET-SLC-VALUE
					      *TELNET-SLC-FLUSHIN
					      *TELNET-SLC-FLUSHOUT)) #\C-c
	   *TELNET-SLC-AO* (code-char *TELNET-SLC-VALUE) #\C-o
	   *TELNET-SLC-AYT* *TELNET-SLC-DEFAULT* #\NUL
	   *TELNET-SLC-ABORT* (code-char (logior *TELNET-SLC-VALUE
						 *TELNET-SLC-FLUSHIN
						 *TELNET-SLC-FLUSHOUT)) #\C-\\
	   *TELNET-SLC-EOF* (code-char *TELNET-SLC-VALUE) #\C-d
	   *TELNET-SLC-SUSP* (code-char (logior *TELNET-SLC-VALUE
						*TELNET-SLC-FLUSHIN)) #\C-z
	   *TELNET-SLC-EC* (code-char *TELNET-SLC-VALUE) #\C-h
	   *TELNET-SLC-EL* (code-char *TELNET-SLC-VALUE) #\C-u
	   *TELNET-SLC-EW* (code-char *TELNET-SLC-VALUE) #\C-w
	   *TELNET-SLC-RP* (code-char *TELNET-SLC-VALUE) #\C-r
	   *TELNET-SLC-LNEXT* (code-char *TELNET-SLC-VALUE) #\C-v
	   *TELNET-SLC-XON* (code-char *TELNET-SLC-VALUE) #\C-q
	   *TELNET-SLC-XOFF* (code-char *TELNET-SLC-VALUE) #\C-s
	   *TELNET-SLC-FORW1* (code-char *TELNET-SLC-VALUE) #\NUL
	   *TELNET-SLC-FORW2* (code-char *TELNET-SLC-VALUE) #\NUL
	   *TELNET-CMD-IAC* *TELNET-CMD-SE*))
  (tterm-display-option "SENT IAC SB LINEMODE SLC SYNCH DEFAULT 0; IP VARIABLE|FLUSHIN|FLUSHOUT 3; AO VARIABLE 15; AYT DEFAULT 0; ABORT VARIABLE|FLUSHIN|FLUSHOUT 28; EOF VARIABLE 4; SUSP VARIABLE|FLUSHIN 26; EC VARIABLE 8; EL VARIABLE 21; EW VARIABLE 23; RP VARIABLE 18; LNEXT VARIABLE 22; XON VARIABLE 17; XOFF VARIABLE 19; FORW1 VARIABLE 0; FORW2 VARIABLE 0;~%"))

(defun tterm-iac-do-nenviron ()
  (setq tterm-state tterm-before-state)
  (tterm-do-ack "NEW_ENVIRON"))

(defun tterm-iac-do-any ()
  (setq tterm-state tterm-before-state)
  (tterm-do-nak (format nil "~d" *tterm-code*)))

(defun tterm-iac-do-unknown ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD DO unknown ~d~%" *tterm-code*)
  (tterm-send-wont *tterm-char* *tterm-code*))

(defun tterm-iac-will-binary ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "TRANSMIT-BINARY"))

(defun tterm-iac-will-echo ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "ECHO")
  (setq tterm-local-echo-p nil))

(defun tterm-iac-will-sga ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "SUPPRESS-GO-AHEAD")
  (and *tterm-char-mode* (tterm-char-mode t)))

(defun tterm-iac-will-status ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "STATUS"))

(defun tterm-iac-will-tm ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "TIMING-MARK")
;  (setq tterm-reset-p t)
)

(defun tterm-iac-will-logout ()
  (setq tterm-state tterm-before-state)
  (tterm-will-ack "LOGOUT"))

(defun tterm-iac-will-any ()
  (setq tterm-state tterm-before-state)
  (tterm-will-nak (format nil "~d" *tterm-code*)))

(defun tterm-iac-will-unknown ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD WILL unknown ~d~%" *tterm-code*)
  (tterm-send-dont *tterm-char* *tterm-code*))


(defun tterm-iac-sb-unknown ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB ~d~%" *tterm-code*))

(defun tterm-iac-sb-ttype ()
  (setq tterm-state *tterm-state-iac-sb-ttype*))

(defun tterm-iac-sb-naws ()
  (setq tterm-state *tterm-state-iac-sb-naws*))

(defun tterm-iac-sb-tspeed ()
  (setq tterm-state *tterm-state-iac-sb-tspeed*))

(defun tterm-iac-sb-linemode ()
  (setq tterm-state *tterm-state-iac-sb-linemode*))

(defun tterm-iac-sb-nenviron ()
  (setq tterm-state *tterm-state-iac-sb-nenviron*))

(defun tterm-iac-sb-naws-send ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB NAWS SEND~%")
  (tterm-window-size)
  (tterm-send-window-size))

(defun tterm-iac-sb-tspeed-send ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB TERMINAL-SPEED SEND~%")
  (let ((tspeed "9600,9600"))
  (tterm-push-option-string (format nil "~c~c~c~c~a~c~c"
			     *TELNET-CMD-IAC* *TELNET-CMD-SB*
			     *TELNET-OP-TSPEED* *TELNET-SUB-IS* tspeed
			     *TELNET-CMD-IAC* *TELNET-CMD-SE*))
    (tterm-display-option "SENT IAC SB TERMINAL-SPEED IS ~s~%" tspeed)))

(defun tterm-iac-sb-ttype-send ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB TERMINAL-TYPE SEND~%")
  (tterm-push-option-string (format nil "~c~c~c~c~a~c~c"
				    *TELNET-CMD-IAC* *TELNET-CMD-SB*
				    *TELNET-OP-TTYPE* *TELNET-SUB-IS* *tterm-ttype*
				    *TELNET-CMD-IAC* *TELNET-CMD-SE*))
  (tterm-display-option "SENT IAC SB TERMINAL-TYPE IS ~s~%" *tterm-ttype*))

(defun tterm-iac-sb-linemode-mode ()
  (setq tterm-state *tterm-state-iac-sb-linemode-mode*))

(defun tterm-iac-sb-linemode-mode-any ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB LINEMODE MODE ~D~%" *tterm-code*)
  (tterm-push-option-string (format nil "~@{~c~}"
				    *TELNET-CMD-IAC* *TELNET-CMD-SB*
				    *TELNET-OP-LINEMODE* *TELNET-SUB-MODE*
				    (code-char (logior *tterm-code*
						       *TELNET-MODE-MODE_ACK))
				    *TELNET-CMD-IAC* *TELNET-CMD-SE*))
  (tterm-display-option "SENT IAC SB LINEMODE MODE ~d|ACK~%" *tterm-code*))

(defun tterm-iac-sb-linemode-slc ()
  (setq tterm-state *tterm-state-iac-sb-linemode-slc*)
  (tterm-display-option "RCVD IAC SB LINEMODE SLC "))

(defun tterm-iac-sb-linemode-slc-any ()
  (tterm-display-option "~d " *tterm-code*))

(defun tterm-iac-sb-linemode-slc-iac ()
  (setq tterm-state *tterm-state-iac-sb-unknown-iac*)
  (tterm-display-option "~%"))

(defun tterm-iac-sb-nenviron-send ()
  (setq tterm-state *tterm-state-iac-sb-unknown*)
  (tterm-display-option "RCVD IAC SB NEW-ENVIRON SEND~%")
  (let ((var-value (if tterm-user
		       (format nil "~cUSER~c~a" #\x0 #\x1 tterm-user)
		     "")))
    (tterm-push-option-string
     (format nil "~c~c~c~c~a~c~c"
	     *TELNET-CMD-IAC* *TELNET-CMD-SB* *TELNET-OP-NEW_ENVIRON*
	     *TELNET-SUB-IS* var-value *TELNET-CMD-IAC* *TELNET-CMD-SE*))
    (if tterm-user
	(tterm-display-option "SENT IAC SB ENVIRON IS VAR \"USER\" VALUE ~s~%"
			      tterm-user)
      (tterm-display-option "SENT IAC SB ENVIRON IS~%"))))

(defun tterm-iac-sb-unknown-iac ()
  (setq tterm-state *tterm-state-iac-sb-unknown-iac*))

(defun tterm-iac-sb-unknown-iac-se ()
  (setq tterm-state tterm-before-state))


(defun tterm-iac-dont-any ()
  (setq tterm-state tterm-before-state)
  (tterm-dont-nak (format nil "unknown ~d" *tterm-code*)))

(defun tterm-iac-dont-echo ()
  (setq tterm-state tterm-before-state)
  (tterm-dont-nak "ECHO")
  (setq tterm-local-echo-p nil))

(defun tterm-iac-dont-unknown ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD DONT unknown ~d~%" *tterm-code*)
  (tterm-send-wont *tterm-char* *tterm-code*))

(defun tterm-iac-wont-any ()
  (setq tterm-state tterm-before-state)
  (tterm-wont-nak (format nil "unknown ~d" *tterm-code*)))

(defun tterm-iac-wont-echo ()
  (setq tterm-state tterm-before-state)
  (tterm-wont-nak "ECHO")
  (setq tterm-local-echo-p t))

(defun tterm-iac-wont-sga ()
  (setq tterm-state tterm-before-state)
  (tterm-wont-nak "SGA")
  (or *tterm-char-mode* (tterm-char-mode nil)))

(defun tterm-iac-wont-unknown ()
  (setq tterm-state tterm-before-state)
  (tterm-display-option "RCVD WONT unknown ~d~%" *tterm-code*)
  (tterm-send-dont *tterm-char* *tterm-code*))


;;;------------------------------------------------------------------------
;;; í[ññÉCÉxÉìÉgèàóù
;;;

(defmacro tterm-popup-cmd-buffer ()
  `(progn
     (if (get-buffer-window cmd-buffer)
	 (pop-to-buffer cmd-buffer)
       (set-buffer cmd-buffer))
     (goto-char (point-max))
     (unless (scan-buffer "^tterm> " :regexp t :reverse t :tail t)
       (or (bolp) (insert "\n"))
       (insert "tterm> "))))

(defun tterm-self-send-command ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(tterm-send-string proc (string *last-command-char*))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-send-eol ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(tterm-send-string proc (tterm-output-eol))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-send-meta-code ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	  (selected-buffer)
	  (let ((code (logand (char-code *last-command-char*) #xFF)))
	    (tterm-process-send-string proc
				       (if (eq tterm-meta-code :esc)
					   (format nil "~c~c" #\ESC (code-char code))
					 (string (code-char (logior code #x80)))))))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-send-cursor-code ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	 (selected-buffer)
	 (let ((prefix (if tterm-app-cursor-p "O" "["))
	       (cursor (cond ((eq *last-command-char* #\Up) "A")
			     ((eq *last-command-char* #\Down) "B")
			     ((eq *last-command-char* #\Right) "C")
			     ((eq *last-command-char* #\Left) "D"))))
	   (tterm-process-send-string proc (concat prefix cursor))))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defconstant tterm-control-code-hash (make-hash-table))

(mapc #'(lambda (x)
	  (setf (gethash (car x) tterm-control-code-hash) (cdr x)))
      '((#\Home . "[1~")
	(#\Insert . "[2~")
	(#\Delete . "[3~")
	(#\End . "[4~")
	(#\PageUp . "[5~")
	(#\PageDown . "[6~")
	(#\F1 . "OP")
	(#\F2 . "OQ")
	(#\F3 . "OR")
	(#\F4 . "OS")
	(#\F5 . "[15~")
	(#\F6 . "[17~")
	(#\F7 . "[18~")
	(#\F8 . "[19~")
	(#\F9 . "[20~")
	(#\F10 . "[21~")
	(#\F11 . "[22~")
	(#\F12 . "[23~")
	(#\S-F1 . "[23~")
	(#\S-F2 . "[24~")
	(#\S-F3 . "[25~")
	(#\S-F4 . "[26~")
	(#\S-F5 . "[28~")
	(#\S-F6 . "[29~")
	(#\S-F7 . "[31~")
	(#\S-F8 . "[32~")
	(#\S-F9 . "[33~")
	(#\S-F10 . "[34~")))

(defun tterm-send-control-code ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	 (selected-buffer)
	 (tterm-process-send-string proc
				    (gethash *last-command-char*
					     tterm-control-code-hash)))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

#|
(defun tterm-send-interrupt ()
  (interactive)
  (if (tterm-buffer-process (selected-buffer))
      (with-tterm-cmd-buffer
       (selected-buffer)
       (tterm-send-ip)
       (tterm-send-do *TELNET-OP-TM* (char-code *TELNET-OP-TM*) "TIMING-MARK"))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer))))
|#

(defun tterm-send-areyouthere ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	  (selected-buffer)
	  (tterm-process-send-string proc
				    (format nil "~c~c"
					    *TELNET-CMD-IAC* *TELNET-CMD-AYT*))
	  (tterm-display-option "SENT AYT~%"))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-send-break ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	  (selected-buffer)
	  (tterm-process-send-string proc
				     (format nil "~c~c"
					     *TELNET-CMD-IAC* *TELNET-CMD-BRK*))
	  (tterm-display-option "SENT BRK~%"))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-send-logout ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	  (selected-buffer)
	  (tterm-send-do *TELNET-OP-LOGOUT*
			 (char-code *TELNET-OP-LOGOUT*)
			 "LOGOUT")
	  (tterm-process-send-string proc))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-yank (prefix &optional (arg 0))
  (interactive "*P\np")
  (if (eq prefix 'universal-argument)
      (progn
	(apply #'tterm-send-string
	       (buffer-process (selected-buffer)) (ed::current-kill 0))
	(setq *last-yank-point* (point)))
    (progn
      (setq *last-yank-point* (point))
      (apply #'tterm-send-string
	     (buffer-process (selected-buffer)) (ed::current-kill arg)))))

(defun tterm-send-quote-char ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	  (selected-buffer)
	  (let ((c (ed::quote-char-read)))
	    (if (char<= #\x8000 c)
		(setq c (code-char (logandc2 (char-code c) #\x8080))))
	    (tterm-process-send-string proc (string c))))
      (progn
	(tterm-char-mode nil)
	(tterm-popup-cmd-buffer)))))

(defun tterm-toggle-crlf ()
  (interactive)
  (setq tterm-flag-crlf (null tterm-flag-crlf)))

(defun tterm-toggle-crmod ()
  (interactive)
  (setq tterm-flag-crmod (null tterm-flag-crmod)))

(defun tterm-toggle-local-echo ()
  (interactive)
  (setq tterm-local-echo-p (null tterm-local-echo-p)))

#|
(defun tterm-flow-on (telnet)
)
(defun tterm-flow-off (telnet)
)
|#

(defmacro tterm-flush-buffer ()
  `(when tterm-buffer-start
     (tterm-flush-buffer-1)))

(defun tterm-send-command-line ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (if proc
	(with-tterm-cmd-buffer
	 (selected-buffer)
	 (let ((str (convert-encoding-from-internal
			     tterm-output-encoding
			     (concat (buffer-substring tterm-prompt-end-point
						       (progn (goto-eol) (point)))
				     (tterm-output-eol)))))
	   (setq tterm-prompt-end-point (point))
	   (tterm-flush-buffer)
	   (tterm-send-string proc str)))
      (tterm-popup-cmd-buffer))))

;; mouse

(defun tterm-mouse-tracking (button &optional shift meta ctrl move)
  (set-window *last-mouse-window*)
  (when (eq buffer-mode 'tterm-mode)
    (let ((proc (tterm-buffer-process (selected-buffer))))
      (if proc
	  (with-tterm-cmd-buffer
	    (selected-buffer)
	    (let ((cb (+ 32 button
			 (if (eql tterm-mouse-mode *MOUSE-X10*)
			     0
			   (+ (if shift 4 0)
			      (if meta 8 0)
			      (if ctrl 16 0))))))
	      (tterm-process-send-string proc
					 (format nil "[M~c~c~c"
						 (code-char cb)
						 (code-char (+ 33 *last-mouse-column*))
						 (code-char (+ 33 (- *last-mouse-line*
								     (get-window-start-line)))))))
	    (goto-last-mouse-point))))))

(defun tterm-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0))

(defun tterm-s-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 t))

(defun tterm-m-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 nil t))

(defun tterm-c-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 nil nil t))

(defun tterm-s-m-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 t t nil))

(defun tterm-s-c-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 t nil t))

(defun tterm-m-c-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 nil t t))

(defun tterm-s-m-c-lbtndown ()
  (interactive)
  (tterm-mouse-tracking 0 t t t))

(defun tterm-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1))

(defun tterm-s-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 t))

(defun tterm-m-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 nil t))

(defun tterm-c-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 nil nil t))

(defun tterm-s-m-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 t t nil))

(defun tterm-s-c-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 t nil t))

(defun tterm-m-c-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 nil t t))

(defun tterm-s-m-c-mbtndown ()
  (interactive)
  (tterm-mouse-tracking 1 t t t))

(defun tterm-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2))

(defun tterm-s-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 t))

(defun tterm-m-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 nil t))

(defun tterm-c-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 nil nil t))

(defun tterm-s-m-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 t t nil))

(defun tterm-s-c-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 t nil t))

(defun tterm-m-c-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 nil t t))

(defun tterm-s-m-c-rbtndown ()
  (interactive)
  (tterm-mouse-tracking 2 t t t))

#|
(defun tterm-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 nil nil nil t))

(defun tterm-s-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 t nil nil t))

(defun tterm-m-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 nil t nil t))

(defun tterm-c-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 nil nil t t))

(defun tterm-s-m-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 t t nil t))

(defun tterm-s-c-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 t nil t t))

(defun tterm-m-c-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 nil t t t))

(defun tterm-s-m-c-lbtnmove()
  (interactive)
  (tterm-mouse-tracking 0 t t t t))

(defun tterm-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 nil nil nil t))

(defun tterm-s-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 t nil nil t))

(defun tterm-m-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 nil t nil t))

(defun tterm-c-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 nil nil t t))

(defun tterm-s-m-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 t t nil t))

(defun tterm-s-c-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 t nil t t))

(defun tterm-m-c-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 nil t t t))

(defun tterm-s-m-c-mbtnmove()
  (interactive)
  (tterm-mouse-tracking 1 t t t t))

(defun tterm-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 nil nil nil t))

(defun tterm-s-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 t nil nil t))

(defun tterm-m-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 nil t nil t))

(defun tterm-c-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 nil nil t t))

(defun tterm-s-m-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 t t nil t))

(defun tterm-s-c-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 t nil t t))

(defun tterm-m-c-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 nil t t t))

(defun tterm-s-m-c-rbtnmove()
  (interactive)
  (tterm-mouse-tracking 2 t t t t))
|#

(defun tterm-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3))

(defun tterm-s-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 t))

(defun tterm-m-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 nil t))

(defun tterm-c-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 nil nil t))

(defun tterm-s-m-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 t t))

(defun tterm-s-c-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 t nil t))

(defun tterm-m-c-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 nil t t))

(defun tterm-s-m-c-btn-release ()
  (interactive)
  (tterm-mouse-tracking 3 t t t))

;; menu

(defvar *tterm-popup-menu*
  (define-popup-menu
    (:item nil "&Are you there" 'tterm-send-areyouthere
     #'(lambda () (unless (tterm-buffer-process (selected-buffer))
		    :disable)))
    (:item nil "Send &Break" 'tterm-send-break
     #'(lambda () (unless (tterm-buffer-process (selected-buffer))
		    :disable)))
    (:item nil "Log&out" 'tterm-send-logout
     #'(lambda () (unless (tterm-buffer-process (selected-buffer))
		    :disable)))
    (:item nil "&Disconnect" 'kill-subprocess
     #'(lambda () (unless (tterm-buffer-process (selected-buffer))
		    :disable)))
    (:item nil "&Paste" 'tterm-paste
     #'(lambda () (when (or (null (tterm-buffer-process (selected-buffer)))
			    (clipboard-empty-p))
		    :disable)))
    (:item nil "Paste (&Noconv)" 'tterm-paste-noconv
     #'(lambda () (when (or (null (tterm-buffer-process (selected-buffer)))
			    (clipboard-empty-p))
		    :disable)))
    :sep
    (:item nil "Cr&lf" 'tterm-toggle-crlf
     #'(lambda () (if tterm-flag-crlf :check)))
    (:item nil "C&rmod" 'tterm-toggle-crmod
     #'(lambda () (if tterm-flag-crmod :check)))
    (:item nil "Local &Echo" 'tterm-toggle-local-echo
     #'(lambda () (if tterm-local-echo-p :check)))
    (:popup 'meta "&Meta Key"
     (:item nil "ESC &Emulate" 'tterm-toggle-meta-emu
      #'(lambda () (if tterm-char-mode
		       (if (eq tterm-meta-code :esc) :check)
		     :disable)))
     (:item nil "&Meta Code" 'tterm-toggle-meta
      #'(lambda () (if tterm-char-mode
		       (if (eq tterm-meta-code t) :check)
		     :disable))))
    :sep
    (:item nil "&Character Mode" 'tterm-char-mode
     #'(lambda () (if tterm-char-mode :check)))
    :sep
    (:menu nil "&Keyboard Encoding"
     (make-char-encoding-popup-menu
      #'(lambda (encoding)
	  (interactive)
	  (tterm-set-output-encoding encoding))
      #'(lambda (encoding)
	  (and (eq tterm-output-encoding encoding) :check))
      *clipboard-char-encoding-list*))
    (:menu nil "D&isplay Encoding"
     (let ((menu (create-popup-menu)))
       (mapc #'(lambda (x)
		 (let ((name (car x)))
		   (add-menu-item menu nil name
				  #'(lambda ()
				      (interactive)
				      (tterm-set-input-encoding name))
				  #'(lambda ()
				      (and (equal tterm-input-encoding name) :check)))))
	     *tterm-encoding-list*)
       menu))
    ))

#-multiple-frames
(defun tterm-popup-menu ()
  (interactive)
  (continue-pre-selection)
  (set-window *last-mouse-window*)
  (if (eq buffer-mode 'tterm-mode)
      (progn
	(insert-popup-menu *app-popup-menu* 0 *tterm-popup-menu* "&TTerm")
	(insert-menu-separator *app-popup-menu* 1 'tterm-sep)
	(unwind-protect
	    (call-interactively 'ed::mouse-menu-popup)
	  (delete-menu *app-popup-menu* 0 t)
	  (delete-menu *app-popup-menu* 'tterm-sep)))
    (call-interactively 'ed::mouse-menu-popup)))
#+multiple-frames
(defun tterm-popup-menu ()
  (interactive)
  (continue-pre-selection)
  (set-window *last-mouse-window*)
  (if (eq buffer-mode 'tterm-mode)
      (let ((app-popup-menu (get-app-popup-menu (selected-frame))))
        (insert-popup-menu app-popup-menu 0 *tterm-popup-menu* "&TTerm")
        (insert-menu-separator app-popup-menu 1 'tterm-sep)
        (unwind-protect
            (call-interactively 'ed::mouse-menu-popup)
          (delete-menu app-popup-menu 0 t)
          (delete-menu app-popup-menu 'tterm-sep)))
    (call-interactively 'ed::mouse-menu-popup)))



;;;------------------------------------------------------------------------
;;; í[ññï\é¶èàóù
;;;

(defun tterm-process-input (proc str)
  (setq *tterm-proc* proc)
  (tterm-check-window-size)
  (setq tterm-buffer-start nil)
  (setf (fill-pointer *tterm-buffer*) 0)
  (dotimes (i (length str))
    (setq *tterm-char* (char str i))
    (setq *tterm-code* (char-code *tterm-char*))
    (funcall (svref tterm-state *tterm-code*)))
  (tterm-process-send-string proc)
  (tterm-flush-buffer)
  (let ((nlines (buffer-lines)))
    (when (< *tterm-max-log-lines* nlines)
      (decf nlines *tterm-max-log-lines*)
      (delete-region (point-min)
		     (progn
		       (goto-char (point-min))
		       (forward-line nlines)
		       (point)))
      (decf tterm-window-start nlines)))
  (scroll-window (- tterm-window-start (get-window-start-line)))
  (tterm-locate-cursor))

(defun tterm-process-filter (proc str)
;  (handler-case
       (with-tterm-cmd-buffer (process-buffer proc)
	 (tterm-display-prettydump str)
	 (tterm-display-netdata str)
	 (or (and tterm-reset-p
		  (if (eq (elt str 0) *TELNET-CMD-IAC*)
		      (setq tterm-reset-p nil)
		    t))
	     (tterm-process-input proc str))
	 (setq tterm-prompt-end-point (point))
	 (run-hooks 'tterm-filter-hook))
;    (error (c)
;      (si:*print-condition c)))
)

(defun tterm-goto-cursor (cx cy)
  (let ((y (+ tterm-window-start cy)))
    (goto-line y)
    (let ((curline (current-line-number)))
      (when (> y curline)
	(goto-char (point-max))
	(insert #\LFD (- y curline)))))
  (let ((x (goto-column cx)))
    (cond ((= cx x))
	  ((eolp)
	   (insert #\SPC (- cx x)))
	  (t
	   (delete-region (point) (1+ (point)))
	   (insert #\SPC 2)
	   (forward-char -1)))))

(defun tterm-locate-cursor ()
  (let ((y (+ tterm-window-start tterm-cursor-y)))
    (goto-line y)
    (let ((curline (current-line-number)))
      (when (> y curline)
	(goto-char (point-max))
	(insert #\LFD (- y curline)))))
  (let ((column (min tterm-cursor-x tterm-window-width-1)))
    (let ((x (goto-column column)))
      (when (and (/= column x) (eolp))
	(insert #\SPC (- column x))))))

(defun tterm-flush-buffer-1 ()
  (tterm-goto-cursor tterm-buffer-start tterm-cursor-y)
   (cond (tterm-insert-mode
	 (insert *tterm-buffer*)
	 (let ((opoint (point)))
	   (goto-column tterm-window-width)
	   (unless (eolp)
	     (delete-region (point) (progn (goto-eol) (point))))
	   (goto-char opoint)))
	(t
	 (delete-region (point)
			(let ((x (forward-column tterm-buffer-start tterm-cursor-x)))
			  (cond ((= x tterm-cursor-x))
				((eolp))
				(t
				 (forward-char 1)
				 (insert #\SPC)
				 (forward-char -1)))
			  (point)))
	 (insert *tterm-buffer*)))
  (let ((base (- (point) (length *tterm-buffer*))))
    (mapc #'(lambda (x)
	      (apply #'set-text-attribute
		     (+ (car x) base) (+ (cadr x) base) (cddr x)))
	  tterm-text-attribute-list)
    (setq tterm-text-attribute-list nil)
    (set-text-attribute (+ base tterm-text-attribute-start)
			(point)
			nil
			:foreground (if tterm-text-rv
					(or tterm-text-bg *tterm-text-fg-white*)
				      tterm-text-fg)
			:background (if tterm-text-rv
					(or tterm-text-fg *tterm-text-bg-black*)
				      tterm-text-bg)
			:bold tterm-text-bo
			:underline tterm-text-ul))
  (setq tterm-text-attribute-start 0)
  (setq tterm-buffer-start nil)
  (setf (fill-pointer *tterm-buffer*) 0))

(defun tterm-write-char (&optional (cc *tterm-char*))
  (let ((cw (char-columns cc)))
    (when (> (+ tterm-cursor-x cw) tterm-window-width)
      (tterm-flush-buffer)
      (or (eolp)
	  (delete-region (point) (progn (goto-eol) (point))))
      (or (forward-line 1)
	  (insert #\LFD))
      (setq tterm-cursor-x 0)
      (if (= tterm-cursor-y tterm-window-height-1)
	  (incf tterm-window-start)
	(incf tterm-cursor-y)))
    (unless tterm-buffer-start
      (setq tterm-buffer-start tterm-cursor-x))
    (vector-push-extend cc *tterm-buffer*)
    (incf tterm-cursor-x cw)))

(defmacro tterm-check-cursor-x-min ()
  `(when (minusp tterm-cursor-x)
     (setq tterm-cursor-x 0)))

(defmacro tterm-check-cursor-x-max ()
  `(when (>= tterm-cursor-x tterm-window-width)
     (setq tterm-cursor-x tterm-window-width-1)))

(defmacro tterm-check-cursor-x-min-max ()
  `(if (minusp tterm-cursor-x)
       (setq tterm-cursor-x 0)
     (if (>= tterm-cursor-x tterm-window-width)
	 (setq tterm-cursor-x tterm-window-width-1))))

(defmacro tterm-check-cursor-y-min ()
  `(when (minusp tterm-cursor-y)
     (setq tterm-cursor-y 0)))

(defmacro tterm-check-cursor-y-max ()
  `(when (>= tterm-cursor-y tterm-window-height)
     (setq tterm-cursor-y tterm-window-height-1)))

(defmacro tterm-check-cursor-y-min-max ()
  `(if (minusp tterm-cursor-y)
       (setq tterm-cursor-y 0)
     (if (>= tterm-cursor-y tterm-window-height)
	 (setq tterm-cursor-y tterm-window-height-1))))

(defun tterm-nul ())

(defun tterm-lf ()
  (tterm-flush-buffer)
  (cond ((and tterm-scroll-range-top
	      (= tterm-cursor-y tterm-scroll-range-bottom))
	 (let ((top (+ tterm-window-start tterm-scroll-range-top))
	       (bottom (+ tterm-window-start tterm-scroll-range-bottom 1)))
	   (goto-line bottom)
	   (when (= (current-line-number) bottom)
	     (or (eobp)
		 (insert #\LFD)))
	   (goto-line top)
	   (when (= (current-line-number) top)
	     (delete-region (point)
			    (progn
			      (or (forward-line 1)
				  (goto-eol))
			      (point))))))
	((= tterm-cursor-y tterm-window-height-1)
	 (incf tterm-window-start))
	(t
	 (incf tterm-cursor-y))))

#|
(defun tterm-lf ()
  (tterm-flush-buffer)
  (if (= tterm-cursor-y tterm-window-height-1)
      (incf tterm-window-start)
    (incf tterm-cursor-y)))
|#

(defun tterm-cr ()
  (tterm-flush-buffer)
  (setq tterm-cursor-x 0)
  (when tterm-flag-crmod
    (if (= tterm-cursor-y tterm-window-height-1)
	(incf tterm-window-start)
      (incf tterm-cursor-y))))

(defun tterm-bs ()
  (unless (zerop tterm-cursor-x)
    (tterm-flush-buffer)
    (decf tterm-cursor-x)))

(defun tterm-bel ()
  (ding))

(defun tterm-ht ()
  (tterm-flush-buffer)
  (setq tterm-cursor-x (min (logandc2 (+ tterm-cursor-x 8) 7)
			    tterm-window-width)))

(defun tterm-ff ()
  (tterm-flush-buffer)
  (incf tterm-window-start tterm-window-height)
  (setq tterm-cursor-x 0 tterm-cursor-y 0))

(defun tterm-can ()
  (setq tterm-state tterm-state-neutral))

(setf (symbol-function 'tterm-insert-self) #'tterm-write-char)

(defun tterm-esc ()
  (setq tterm-state tterm-state-esc))

(defun tterm-esc-unknown ()
  (setq tterm-state tterm-state-neutral)
  (tterm-display-option "Unknown ESC ~a~%" *tterm-char*))

; save cursor attributes
(defun tterm-esc-7 ()
  (setq tterm-state tterm-state-neutral)
  (push (cons tterm-cursor-x tterm-cursor-y) tterm-cursor-stack))

; restore cursor attrbutes
(defun tterm-esc-8 ()
  (setq tterm-state tterm-state-neutral)
  (let ((x (pop tterm-cursor-stack)))
    (when x
      (tterm-flush-buffer)
      (setq tterm-cursor-x (car x)
	    tterm-cursor-y (cdr x))
      (tterm-correct-screen))))

; index
(defun tterm-esc-D ()
  (setq tterm-state tterm-state-neutral)
  (tterm-flush-buffer)
  (let (top bottom)
    (if tterm-scroll-range-top
	(setq top (+ tterm-window-start tterm-scroll-range-top)
	      bottom (+ tterm-window-start tterm-scroll-range-bottom 1))
      (setq top tterm-window-start
	    bottom (+ tterm-window-start tterm-window-height)))
    (goto-line bottom)
    (when (= (current-line-number) bottom)
      (or (eobp)
	  (insert #\LFD)))
    (goto-line top)
    (when (= (current-line-number) top)
      (delete-region (point)
		     (progn
		       (or (forward-line 1)
			   (goto-eol))
		       (point))))))

; reverse index
(defun tterm-esc-M ()
  (setq tterm-state tterm-state-neutral)
  (tterm-flush-buffer)
  (let (top bottom)
    (if tterm-scroll-range-top
	(setq top (+ tterm-window-start tterm-scroll-range-top)
	      bottom (+ tterm-window-start tterm-scroll-range-bottom))
      (setq top tterm-window-start
	    bottom (+ tterm-window-start tterm-window-height-1)))
    (goto-line bottom)
    (when (= (current-line-number) bottom)
      (delete-region (point)
		     (progn
		       (or (forward-line 1)
			   (goto-eol))
		       (point))))
    (goto-line top)
    (when (and (= (current-line-number) top)
	       (not (eobp)))
      (insert #\LFD))))

(defun tterm-csi ()
  (setq tterm-state *tterm-state-csi*)
  (setq tterm-csi-value nil)
  (setq tterm-csi-nparams 0))

(defun tterm-csi-unknown ()
  (setq tterm-state tterm-state-neutral)
  (tterm-display-option "Unknown CSI ~a~%" *tterm-char*))

(defun tterm-csi-digit ()
  (setq tterm-csi-value 
	(if tterm-csi-value
	    (+ (* tterm-csi-value 10) (digit-char-p *tterm-char*))
	  (digit-char-p *tterm-char*))))

(defun tterm-csi-semi ()
  (when (< tterm-csi-nparams 16)
    (setf (svref tterm-csi-param tterm-csi-nparams) tterm-csi-value)
    (incf tterm-csi-nparams)
    (setq tterm-csi-value nil)))

(defmacro tterm-csi-finish-arg ()
  `(when (and tterm-csi-value
	      (< tterm-csi-nparams 16))
     (setf (svref tterm-csi-param tterm-csi-nparams) tterm-csi-value)
     (incf tterm-csi-nparams)))

(defmacro tterm-csi-arg (n def)
  `(if (< ,n tterm-csi-nparams)
       (or (svref tterm-csi-param ,n) ,def)
     ,def))

;cursor up
(defun tterm-csi-A ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (decf tterm-cursor-y (tterm-csi-arg 0 1))
  (tterm-check-cursor-y-min))

;cursor down
(defun tterm-csi-B ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (incf tterm-cursor-y (tterm-csi-arg 0 1))
  (tterm-check-cursor-y-max))

; cursor forward
(defun tterm-csi-C ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (incf tterm-cursor-x (tterm-csi-arg 0 1))
  (tterm-check-cursor-x-max))

; cursor backward
(defun tterm-csi-D ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (decf tterm-cursor-x (tterm-csi-arg 0 1))
  (tterm-check-cursor-x-min))

; cursor char absolute [column]
(defun tterm-csi-G ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (setq tterm-cursor-x (1- (tterm-csi-arg 0 1)))
  (tterm-check-cursor-x-min-max))

; line position [row]
(defun tterm-csi-d ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (setq tterm-cursor-y (1- (tterm-csi-arg 0 1)))
  (tterm-check-cursor-y-min-max))

; cursor position [row;column]
(defun tterm-csi-H ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (cond ((= tterm-csi-nparams 2)
	 (let ((p1 (svref tterm-csi-param 0))
	       (p2 (svref tterm-csi-param 1)))
	   (cond ((or p1 p2)
		  (when p1
		    (setq tterm-cursor-y (1- p1))
		    (tterm-check-cursor-y-min-max))
		  (when p2
		    (setq tterm-cursor-x (1- p2))
		    (tterm-check-cursor-x-min-max)))
		 (t
		  (setq tterm-cursor-x 0)
		  (setq tterm-cursor-y 0)))))
	(t
	 (let ((p1 (tterm-csi-arg 0 nil)))
	   (cond (p1
		  (setq tterm-cursor-x (1- p1))
		  (tterm-check-cursor-x-min-max))
		 (t
		  (setq tterm-cursor-x 0)
		  (setq tterm-cursor-y 0)))))))

;; erase line
(defun tterm-csi-J ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (case (tterm-csi-arg 0 0)
    (0 ; eraseing from cursor to end of screen
       (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
       (delete-region (point) (point-max)))
    (1 ; eraseing from beginning of screen to cursor
       (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
       (delete-region (point)
		      (progn
			(goto-line tterm-window-start)
			(point)))
       (insert #\LFD tterm-cursor-y)
       (insert #\SPC tterm-cursor-x))
    (2 ; erasing entire screen
       (delete-region (progn
			(goto-virtual-line tterm-window-start)
			(point))
		      (point-max)))))

;; erase screen
(defun tterm-csi-K ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (tterm-flush-buffer)
  (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
  (case (tterm-csi-arg 0 0)
    (0 ; erasing from cursor to end of line
       (delete-region (point)
		      (progn
			(goto-eol)
			(point))))
    (1 ; erasing from beginning of line to cursor
       (delete-region (point)
		      (progn
			(goto-bol)
			(point)))
       (insert #\SPC tterm-cursor-x))
    (2 ; erasing entrire line containing
       (delete-region (progn
			(goto-bol)
			(point))
		      (progn
			(goto-eol)
			(point))))))

; insert line
(defun tterm-csi-L ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (let ((nlines (tterm-csi-arg 0 1)))
    (when (> nlines 0)
      (tterm-flush-buffer)
      (let ((ins (+ tterm-window-start tterm-cursor-y))
	    (del (+ tterm-window-start (if tterm-scroll-range-top
					   tterm-scroll-range-bottom
					 tterm-window-height-1)
		    1)))
	(goto-line ins)
	(when (and (= (current-line-number) ins)
		   (not (eobp)))
	  (insert #\LFD nlines))
	(goto-line del)
	(when (= (current-line-number) del)
	  (delete-region (point)
			 (progn
			   (forward-line (1- nlines))
			   (or (forward-line 1)
			       (goto-eol))
			   (point))))))))

; delete line
(defun tterm-csi-M ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (let ((nlines (tterm-csi-arg 0 1)))
    (when (> nlines 0)
      (tterm-flush-buffer)
      (let ((ins (+ tterm-window-start (if tterm-scroll-range-top
					   tterm-scroll-range-bottom
					 tterm-window-height-1)))
	    (del (+ tterm-window-start tterm-cursor-y)))
	(goto-line ins)
	(when (and (= (current-line-number) ins)
		   (goto-eol)
		   (not (eobp)))
	  (insert #\LFD nlines))
	(goto-line del)
	(when (= (current-line-number) del)
	  (delete-region (point)
			 (progn
			   (forward-line (1- nlines))
			   (or (forward-line 1)
			       (goto-eol))
			   (point))))))))

; insert chars
(defun tterm-csi-@ ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (let ((nchars (tterm-csi-arg 0 1)))
    (when (> nchars 0)
      (tterm-flush-buffer)
      (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
      (insert #\SPC nchars)
      (delete-region (progn
		       (tterm-goto-cursor tterm-window-width tterm-cursor-y)
		       (point))
		     (progn
		       (goto-eol)
		       (point))))))

; delete-chars
(defun tterm-csi-P ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (let ((nchars (tterm-csi-arg 0 1)))
    (when (> nchars 0)
      (tterm-flush-buffer)
      (delete-region (progn
		       (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
		       (point))
		     (progn
		       (tterm-goto-cursor (+ tterm-cursor-x nchars) tterm-cursor-y)
		       (point))))))

;; erase chars
(defun tterm-csi-X ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (let ((nchars (tterm-csi-arg 0 1)))
	(when (> nchars 0)
	  (tterm-flush-buffer)
	  (delete-region (progn
					   (tterm-goto-cursor tterm-cursor-x tterm-cursor-y)
					   (point))
					 (progn
					   (tterm-goto-cursor (+ tterm-cursor-x nchars) tterm-cursor-y)
					   (point)))
	  (insert #\SPC nchars))))

(defconstant tterm-text-attribute-hash (make-hash-table :size 30))

(mapc #'(lambda (x)
	  (setf (gethash (car x) tterm-text-attribute-hash) (cdr x)))
      '((0 . (setq tterm-text-fg nil tterm-text-bg nil
		   tterm-text-bo nil tterm-text-ul nil tterm-text-rv nil))
	(1 . (setq tterm-text-bo t))
	(4 . (setq tterm-text-ul t))
	(7 . (setq tterm-text-rv t))
	(8 . (setq tterm-text-fg 15 tterm-text-bg 15))
	(21 . (setq tterm-text-fg nil tterm-text-bg nil
		    tterm-text-bo nil tterm-text-ul nil tterm-text-rv nil))
	(22 . (setq tterm-text-fg nil tterm-text-bg nil
		    tterm-text-bo nil tterm-text-ul nil tterm-text-rv nil))
	(24 . (setq tterm-text-ul nil))
	(27 . (setq tterm-text-rv nil))
	(28 . (setq tterm-text-fg nil tterm-text-bg nil))
	(30 . (setq tterm-text-fg *tterm-text-fg-black*))
	(31 . (setq tterm-text-fg *tterm-text-fg-red*))
	(32 . (setq tterm-text-fg *tterm-text-fg-green*))
	(33 . (setq tterm-text-fg *tterm-text-fg-yellow*))
	(34 . (setq tterm-text-fg *tterm-text-fg-blue*))
	(35 . (setq tterm-text-fg *tterm-text-fg-magenta*))
	(36 . (setq tterm-text-fg *tterm-text-fg-cyan*))
	(37 . (setq tterm-text-fg *tterm-text-fg-white*))
	(38 . (setq tterm-text-ul t tterm-text-fg nil))
	(39 . (setq tterm-text-ul nil tterm-text-fg nil))
	(40 . (setq tterm-text-bg *tterm-text-bg-black*))
	(41 . (setq tterm-text-bg *tterm-text-bg-red*))
	(42 . (setq tterm-text-bg *tterm-text-bg-green*))
	(43 . (setq tterm-text-bg *tterm-text-bg-yellow*))
	(44 . (setq tterm-text-bg *tterm-text-bg-blue*))
	(45 . (setq tterm-text-bg *tterm-text-bg-magenta*))
	(46 . (setq tterm-text-bg *tterm-text-bg-cyan*))
	(47 . (setq tterm-text-bg *tterm-text-bg-white))
	(49 . (setq tterm-text-bg nil))
       ))


; text attribute
(defun tterm-csi-m ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (if (/= tterm-text-attribute-start (length *tterm-buffer*))
    (push (list tterm-text-attribute-start
		(length *tterm-buffer*)
		nil
		':foreground (if tterm-text-rv
				 (or tterm-text-bg *tterm-text-fg-white*)
			       tterm-text-fg)
		':background (if tterm-text-rv
				 (or tterm-text-fg *tterm-text-bg-black*)
			       tterm-text-bg)
		':bold tterm-text-bo
		':underline tterm-text-ul)
	  tterm-text-attribute-list))
  (dotimes (n (max tterm-csi-nparams 1))
    (eval (gethash (tterm-csi-arg n 0) tterm-text-attribute-hash)))
  (setq tterm-text-attribute-start (length *tterm-buffer*)))

; set scrolling area
(defun tterm-csi-r ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (cond ((= tterm-csi-nparams 2)
	 (let ((p1 (svref tterm-csi-param 0))
	       (p2 (svref tterm-csi-param 1)))
	   (when p1
	     (setq tterm-scroll-range-top (1- p1)))
	   (when p2
	     (setq tterm-scroll-range-bottom (1- p2)))
	   (unless (and tterm-scroll-range-top
			tterm-scroll-range-bottom
			(> tterm-scroll-range-bottom tterm-scroll-range-top)
			(>= tterm-scroll-range-top 0)
			(<= tterm-scroll-range-bottom tterm-window-height-1)
			(or (/= tterm-scroll-range-top 0)
			    (/= tterm-scroll-range-bottom tterm-window-height-1)))
	     (setq tterm-scroll-range-top nil
		   tterm-scroll-range-bottom nil))))
	(t
	 (setq tterm-scroll-range-top nil
	       tterm-scroll-range-bottom nil))))

; enter mode
(defun tterm-csi-h ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (when (and (eql (tterm-csi-arg 0 nil) 4)
	     (not tterm-insert-mode))
    (tterm-flush-buffer)
    (setq tterm-insert-mode t)))

; exit mode
(defun tterm-csi-l ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (when (and (eql (tterm-csi-arg 0 nil) 4)
	     tterm-insert-mode)
    (tterm-flush-buffer)
    (setq tterm-insert-mode nil)))

(defun tterm-csi-ques-unknown ()
  (setq tterm-state tterm-state-neutral)
  (tterm-display-option "Unknown CSI ? ~a~%" *tterm-char*))

(defun tterm-csi-ques ()
  (setq tterm-state *tterm-state-csi-ques*))

; DEC private mode set
(defun tterm-csi-ques-h ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (dotimes (n tterm-csi-nparams)
    (let ((ps (tterm-csi-arg n nil)))
      (cond ((eql ps 1) ; application cursor key
	     (setq tterm-app-cursor-p t))
	    ((or (eql ps *MOUSE-X10*)
		 (eql ps *MOUSE-VT200*)
		 (eql ps *MOUSE-HIGHLIGHT*))
	     (setq tterm-mouse-mode ps)
	     (set-minor-mode-map *tterm-mouse-mode-map*))
	    ((or (eql ps 47)
		 (eql ps 1047))
	     (tterm-flush-buffer)
	     (push (cons tterm-window-start
			 (cons (buffer-substring (point-min) (point-max))
			       (list-text-attributes)))
		   tterm-screen-stack))
	    ((eql ps 1048)
	     (tterm-esc-7))
	    (t
	     (tterm-display-option "Unknown DECSET ~d~%" *tterm-code*))))))

; DEC private mode reset
(defun tterm-csi-ques-l ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (dotimes (n tterm-csi-nparams)
    (let ((ps (tterm-csi-arg n nil)))
      (cond ((eql ps 1) ; normal cursor key
	     (setq tterm-app-cursor-p nil))
	    ((or (eql ps 9)
		 (eql ps 1000)
		 (eql ps 1001))
	     (setq tterm-mouse-mode nil)
	     (unset-minor-mode-map *tterm-mouse-mode-map*))
	    ((or (eql ps 47)
		 (eql ps 1047))
	     (let ((x (pop tterm-screen-stack)))
	       (when x
		 (tterm-flush-buffer)
		 (delete-region (point-min) (point-max))
		 (setq tterm-window-start (car x))
		 (insert (cadr x))
		 (mapc #'(lambda (attr)
			   (apply #'set-text-attribute attr))
		       (cddr x)))))
	    ((eql ps 1048)
	     (tterm-esc-8))
	    (t
	     (tterm-display-option "Unknown DECRST ~d~%" *tterm-code*))))))

; OSC
(defun tterm-osc ()
  (setq tterm-state *tterm-state-osc*)
  (setq tterm-csi-value nil)
  (setq tterm-csi-nparams 0))

(defun tterm-osc-unknown ()
  (setq tterm-state tterm-state-neutral)
  (tterm-display-option "Unknown OSC ~a~%" *tterm-char*))

(defun tterm-osc-semi ()
  (setq tterm-state *tterm-state-osc-semi*)
  (when (< tterm-csi-nparams 1)
    (setf (svref tterm-csi-param tterm-csi-nparams) tterm-csi-value)
    (incf tterm-csi-nparams)
    (setq tterm-csi-value nil))
  (setf (fill-pointer tterm-title) 0))

(defun tterm-osc-semi-txt ()
  (vector-push-extend *tterm-char* tterm-title))

(defun tterm-osc-semi-bel ()
  (setq tterm-state tterm-state-neutral)
  (tterm-csi-finish-arg)
  (when (and (= tterm-csi-nparams 1)
	     (<= (tterm-csi-arg 0 100) 2))
    (rename-buffer (concat *tterm-buffer-name* " " tterm-title))
    (update-mode-line t)
    (and (fboundp 'refresh-title-bar)
	 (refresh-title-bar))))

; Shift_JIS
(tterm-define-state '*tterm-state-sjis*
		    '(*tterm-state-neutral*
		      ((#x81 . #x9f) . tterm-sjis-lead)
		      (#xa0 . tterm-nul)
		      ((#xa1 . #xdf) . tterm-write-char)
		      ((#xe0 . #xfc) . tterm-sjis-lead)
		      (#xfd . tterm-nul)
		      (#xfe . tterm-nul)))

(tterm-define-state '*tterm-state-sjis-lead*
		    '((* . tterm-sjis-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((#x40 . #x7e) . tterm-sjis-insert)
		      ((#x80 . #xfc) . tterm-sjis-insert)))

(defun tterm-sjis-lead ()
  (setq tterm-state *tterm-state-sjis-lead*)
  (setq tterm-lead-char *tterm-char*))

(defun tterm-sjis-insert ()
  (setq tterm-state tterm-state-neutral)
  (tterm-write-char (code-char (+ (* (char-code tterm-lead-char) 256)
				  (char-code *tterm-char*)))))

(defun tterm-sjis-invalid ()
  (setq tterm-state tterm-state-neutral))

; EUC-JP
(tterm-define-state '*tterm-state-eucjp*
		    '(*tterm-state-neutral*
		      ((#x80 . #x9f) . tterm-nul)
		      (#x8e . tterm-eucjp-ss2)
		      (#x8f . tterm-eucjp-ss3)
		      (#xa0 . tterm-nul)
		      ((#xa1 . #xfe) . tterm-eucjp-lead)))

(tterm-define-state '*tterm-state-eucjp-lead*
		    '((* . tterm-eucjp-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((#xa1 . #xfe) . tterm-eucjp-insert)))

(tterm-define-state '*tterm-state-eucjp-ss2*
		    '((* . tterm-eucjp-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((#xa1 . #xef) . tterm-eucjp-insert-ss2)))

(tterm-define-state '*tterm-state-eucjp-ss3*
		    '((* . tterm-eucjp-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((#xa1 . #xfe) . tterm-eucjp-ss3-lead)))

(tterm-define-state '*tterm-state-eucjp-ss3-lead*
		    '((* . tterm-eucjp-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((#xa1 . #xfe) . tterm-eucjp-insert-ss3)))

(defun tterm-eucjp-lead ()
  (setq tterm-state *tterm-state-eucjp-lead*)
  (setq tterm-lead-char *tterm-char*))

(defun tterm-eucjp-insert ()
  (setq tterm-state tterm-state-neutral)
  (tterm-write-char (iso-code-char (+ (* (char-code tterm-lead-char) 256)
				      (char-code *tterm-char*))
				   :jisx0208)))

(defun tterm-eucjp-ss2 ()
  (setq tterm-state *tterm-state-eucjp-ss2*))

(defun tterm-eucjp-insert-ss2 ()
  (setq tterm-state tterm-state-neutral)
  (tterm-write-char))

(defun tterm-eucjp-ss3 ()
  (setq tterm-state *tterm-state-eucjp-ss3*))

(defun tterm-eucjp-ss3-lead ()
  (setq tterm-state *tterm-state-eucjp-ss3-lead*)
  (setq tterm-lead-char *tterm-char*))

(defun tterm-eucjp-insert-ss3 ()
  (setq tterm-state tterm-state-neutral)
  (tterm-write-char (iso-code-char (+ (* (char-code tterm-lead-char) 256)
				      (char-code *tterm-char*))
				   :jisx0212)))

(defun tterm-eucjp-invalid ()
  (setq tterm-state tterm-state-neutral))

; ISO 2022

(tterm-define-state '*tterm-state-iso2022*
		    '(*tterm-state-neutral*
		      ((#x20 . #x7f) . tterm-iso2022-insert-self-l)
		      ((#x80 . #xfe) . tterm-iso2022-insert-self-r)
		      (#x0e . tterm-iso2022-so)
		      (#x0f . tterm-iso2022-si)
		      (#x8e . tterm-iso2022-ss2)
		      (#x8f . tterm-iso2022-ss3)))

(tterm-define-state '*tterm-state-iso2022-esc*
		    '(*tterm-state-esc*
		      (#\$ . tterm-iso2022-n)
		      (#\( . tterm-iso2022-94-g0)
		      (#\) . tterm-iso2022-94-g1)
		      (#\* . tterm-iso2022-94-g2)
		      (#\+ . tterm-iso2022-94-g3)
		      (#\, . tterm-iso2022-96-g0)
		      (#\- . tterm-iso2022-96-g1)
		      (#\. . tterm-iso2022-96-g2)
		      (#\/ . tterm-iso2022-96-g3)
		      (#\N . tterm-iso2022-ss2)
		      (#\O . tterm-iso2022-ss3)
		      (#\n . tterm-iso2022-ls2)
		      (#\o . tterm-iso2022-ls3)
		      (#\~ . tterm-iso2022-ls1r)
		      (#\} . tterm-iso2022-ls2r)
		      (#\| . tterm-iso2022-ls3r)))

(tterm-define-state '*tterm-state-iso2022-94*
		    '((* . tterm-iso2022-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\@ . tterm-iso2022-usascii)
		      (#\B . tterm-iso2022-usascii)
		      (#\I . tterm-iso2022-jisx0201)
		      (#\J . tterm-iso2022-usascii)))

(tterm-define-state '*tterm-state-iso2022-96*
		    '((* . tterm-iso2022-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\A . tterm-iso2022-iso8859-1)
		      (#\B . tterm-iso2022-iso8859-2)
		      (#\C . tterm-iso2022-iso8859-3)
		      (#\D . tterm-iso2022-iso8859-4)
		      (#\F . tterm-iso2022-iso8859-7)
		      (#\L . tterm-iso2022-iso8859-5)
		      (#\M . tterm-iso2022-iso8859-9)
		      (#\V . tterm-iso2022-iso8859-10)))

(tterm-define-state '*tterm-state-iso2022-94n*
		    '((* . tterm-iso2022-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\@ . tterm-iso2022-jisx0208)
		      (#\A . tterm-iso2022-gb2312)
		      (#\B . tterm-iso2022-jisx0208)
		      (#\C . tterm-iso2022-ksc5601)
		      (#\D . tterm-iso2022-jisx0212)
		      (#\G . tterm-iso2022-cns11643-1)
		      (#\H . tterm-iso2022-cns11643-2)))

(tterm-define-state '*tterm-state-iso2022-96n*
		    '((* . tterm-iso2022-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)))

(tterm-define-state '*tterm-state-iso2022-n*
		    '((* . tterm-iso2022-invalid)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      (#\( . tterm-iso2022-94n-g0)
		      (#\) . tterm-iso2022-94n-g1)
		      (#\* . tterm-iso2022-94n-g2)
		      (#\+ . tterm-iso2022-94n-g3)
		      (#\, . tterm-iso2022-96n-g0)
		      (#\- . tterm-iso2022-96n-g1)
		      (#\. . tterm-iso2022-96n-g2)
		      (#\/ . tterm-iso2022-96n-g3)
		      (#\@ . tterm-iso2022-jisx0208-short)
		      (#\A . tterm-iso2022-gb2312-short)
		      (#\B . tterm-iso2022-jisx0208-short)))

(tterm-define-state '*tterm-state-iso2022-lead*
		    '((* . tterm-iso2022-insert-self-mb)
		      (*TELNET-CMD-IAC* . tterm-iac)
		      ((0 . 32) . tterm-iso2022-invalid)
		      ((127 . 160) . tterm-iso2022-invalid)))

(defun tterm-iso2022-si ()
  (when (svref tterm-iso2022-g 1)
    (setq tterm-iso2022-gl 0)))

(defun tterm-iso2022-so ()
  (when (svref tterm-iso2022-g 1)
    (setq tterm-iso2022-gl 1)))

(defun tterm-iso2022-ls2 ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 2)
    (setq tterm-iso2022-gl 2)))

(defun tterm-iso2022-ls3 ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 3)
    (setq tterm-iso2022-gl 3)))

(defun tterm-iso2022-ls1r ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 1)
    (setq tterm-iso2022-gr 1)))

(defun tterm-iso2022-ls2r ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 2)
    (setq tterm-iso2022-gr 2)))

(defun tterm-iso2022-ls3r ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 3)
    (setq tterm-iso2022-gr 3)))

(defun tterm-iso2022-ss2 ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 2)
    (setq tterm-iso2022-ss 2)))

(defun tterm-iso2022-ss3 ()
  (setq tterm-state tterm-state-neutral)
  (when (svref tterm-iso2022-g 3)
    (setq tterm-iso2022-ss 3)))

(defun tterm-iso2022-n ()
  (setq tterm-state *tterm-state-iso2022-n*))

(defun tterm-iso2022-94-g0 ()
  (setq tterm-state *tterm-state-iso2022-94*)
  (setq tterm-iso2022-sg 0))

(defun tterm-iso2022-94-g1 ()
  (setq tterm-state *tterm-state-iso2022-94*)
  (setq tterm-iso2022-sg 1))

(defun tterm-iso2022-94-g2 ()
  (setq tterm-state *tterm-state-iso2022-94*)
  (setq tterm-iso2022-sg 2))

(defun tterm-iso2022-94-g3 ()
  (setq tterm-state *tterm-state-iso2022-94*)
  (setq tterm-iso2022-sg 3))

(defun tterm-iso2022-96-g0 ()
  (setq tterm-state *tterm-state-iso2022-96*)
  (setq tterm-iso2022-sg 0))

(defun tterm-iso2022-96-g1 ()
  (setq tterm-state *tterm-state-iso2022-96*)
  (setq tterm-iso2022-sg 1))

(defun tterm-iso2022-96-g2 ()
  (setq tterm-state *tterm-state-iso2022-96*)
  (setq tterm-iso2022-sg 2))

(defun tterm-iso2022-96-g3 ()
  (setq tterm-state *tterm-state-iso2022-96*)
  (setq tterm-iso2022-sg 3))

(defun tterm-iso2022-94n-g0 ()
  (setq tterm-state *tterm-state-iso2022-94n*)
  (setq tterm-iso2022-sg 0))

(defun tterm-iso2022-94n-g1 ()
  (setq tterm-state *tterm-state-iso2022-94n*)
  (setq tterm-iso2022-sg 1))

(defun tterm-iso2022-94n-g2 ()
  (setq tterm-state *tterm-state-iso2022-94n*)
  (setq tterm-iso2022-sg 2))

(defun tterm-iso2022-94n-g3 ()
  (setq tterm-state *tterm-state-iso2022-94n*)
  (setq tterm-iso2022-sg 3))

(defun tterm-iso2022-96n-g0 ()
  (setq tterm-state *tterm-state-iso2022-96n*)
  (setq tterm-iso2022-sg 0))

(defun tterm-iso2022-96n-g1 ()
  (setq tterm-state *tterm-state-iso2022-96n*)
  (setq tterm-iso2022-sg 1))

(defun tterm-iso2022-96n-g2 ()
  (setq tterm-state *tterm-state-iso2022-96n*)
  (setq tterm-iso2022-sg 2))

(defun tterm-iso2022-96n-g3 ()
  (setq tterm-state *tterm-state-iso2022-96n*)
  (setq tterm-iso2022-sg 3))

(defun tterm-iso2022-invalid ()
  (setq tterm-state tterm-state-neutral))

(defun tterm-iso2022-usascii ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :us-ascii))

(defun tterm-iso2022-jisx0201 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :jisx0201-kana))

(defun tterm-iso2022-iso8859-1 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-1))

(defun tterm-iso2022-iso8859-2 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-2))

(defun tterm-iso2022-iso8859-3 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-3))

(defun tterm-iso2022-iso8859-4 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-4))

(defun tterm-iso2022-iso8859-5 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-5))

(defun tterm-iso2022-iso8859-7 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-7))

(defun tterm-iso2022-iso8859-9 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-9))

(defun tterm-iso2022-iso8859-10 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :iso8859-10))

(defun tterm-iso2022-jisx0208 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :jisx0208))

(defun tterm-iso2022-jisx0208-short ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g 0) :jisx0208))

(defun tterm-iso2022-gb2312 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :gb2312))

(defun tterm-iso2022-gb2312-short ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g 0) :gb2312))

(defun tterm-iso2022-ksc5601 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :ksc5601))

(defun tterm-iso2022-jisx0212 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :jisx0212))

(defun tterm-iso2022-cns11643-1 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :cns11643-1))

(defun tterm-iso2022-cns11643-2 ()
  (setq tterm-state tterm-state-neutral)
  (setf (svref tterm-iso2022-g tterm-iso2022-sg) :cns11643-2))

(defun tterm-iso2022-insert-self-l ()
  (let* ((n (or tterm-iso2022-ss tterm-iso2022-gl))
	 (charset (svref tterm-iso2022-g n)))
    (if (= (get charset 'tterm-iso2022-bytes) 1)
	(tterm-write-char (iso-code-char (char-code *tterm-char*) charset))
      (progn
	(setq tterm-state *tterm-state-iso2022-lead*)
	(setq tterm-lead-char *tterm-char*)
	(setq tterm-iso2022-charset charset)))
    (setq tterm-iso2022-ss nil)))

(defun tterm-iso2022-insert-self-r ()
  (let* ((n (or tterm-iso2022-ss tterm-iso2022-gr))
	 (charset (svref tterm-iso2022-g n)))
    (cond ((null charset)
	   (tterm-write-char))
	  ((= (get charset 'tterm-iso2022-bytes) 1)
	   (tterm-write-char (iso-code-char (char-code *tterm-char*) charset)))
	  (t
	   (setq tterm-state *tterm-state-iso2022-lead*)
	   (setq tterm-lead-char *tterm-char*)
	   (setq tterm-iso2022-charset charset)))
    (setq tterm-iso2022-ss nil)))

(defun tterm-iso2022-insert-self-mb ()
  (setq tterm-state tterm-state-neutral)
  (let ((c (iso-code-char (+ (* (char-code tterm-lead-char) 256)
			     (char-code *tterm-char*))
			  tterm-iso2022-charset)))
    (and c (tterm-write-char c))))


; Shift_JIS with ESC
(tterm-define-state '*tterm-state-sjis-with-esc*
		    '(*tterm-state-iso2022*
		      ((#x81 . #x9f) . tterm-sjis-with-esc-lead)
		      ((#xe0 . #xfc) . tterm-sjis-with-esc-lead)))

(defun tterm-sjis-with-esc-lead ()
  (let* ((n (or tterm-iso2022-ss tterm-iso2022-gr))
	 (charset (svref tterm-iso2022-g n)))
    (cond ((eq charset :jisx0201-kana)
	   (setq tterm-state *tterm-state-sjis-lead*)
	   (setq tterm-lead-char *tterm-char*))
	  ((= (get charset 'tterm-iso2022-bytes) 1)
	   (tterm-write-char (iso-code-char (char-code *tterm-char*) charset)))
	  (t
	   (setq tterm-state *tterm-state-iso2022-lead*)
	   (setq tterm-lead-char *tterm-char*)
	   (setq tterm-iso2022-charset charset)))
    (setq tterm-iso2022-ss nil)))



(defun tterm-reset-terminal ()
  (interactive)
  (tterm-init-input-encoding)
  (setq tterm-text-fg nil)
  (setq tterm-text-bg nil)
  (setq tterm-text-bo nil)
  (setq tterm-text-ul nil)
  (setq tterm-text-rv nil)
  (setq tterm-text-attribute-list nil)
  (setq tterm-text-attribute-start 0)
  (setq tterm-cursor-x 0)
  (setq tterm-cursor-y 0)
  (setq tterm-scroll-range-top nil)
  (setq tterm-scroll-range-bottom nil)
  (setq tterm-window-start-backup nil)
  (setq tterm-cursor-stack nil)
  (setq tterm-insert-mode nil)
  (dotimes (n 45)
    (setf (svref tterm-telnet-option n) 0))
  (setq tterm-local-echo-p t)
  (setq tterm-app-cursor-p nil)
  (setq tterm-mouse-mode nil)
  (setq tterm-prompt-end-point (point-max))
  (tterm-char-mode nil)
  (goto-char (point-max))
  (or (bolp)
      (insert #\LFD))
  (setq tterm-window-start (current-line-number))
  (scroll-window (- tterm-window-start (get-window-start-line)))
  (tterm-locate-cursor))

(defun tterm-set-input-encoding (encoding)
  (interactive (list (completing-read "Encoding: "
				      *tterm-encoding-list*
				      :must-match t
				      :case-fold t)))
  (setq tterm-input-encoding encoding)
  (tterm-init-input-encoding))

(defun tterm-set-output-encoding (encoding)
  (interactive "ZOutput encoding: ")
  (setq tterm-output-encoding encoding))

(defun tterm-paste ()
  (interactive)
  (let ((proc (tterm-buffer-process (selected-buffer))))
    (when proc
      (let ((string (get-clipboard-data)))
	(when string
	  (tterm-send-string proc string))))))

(defun tterm-paste-noconv ()
  (interactive)
  (let ((tterm-output-encoding *encoding-binary*))
    (declare (special tterm-output-encoding))
    (tterm-paste)))


;; end of tterm.l


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
(defvar *tterm-error*
  (make-buffer-stream (get-buffer-create "*Trace*")))

(setq *error-output* *tterm-error*)
(setq si:*trace-on-error* t)
|#

#|
(defun tterm-tty-debug (str)
  (interactive "sString: ")
  (let (*tterm-char*
	*tterm-code*)
    (setq tterm-buffer-start nil)
    (setf (fill-pointer *tterm-buffer*) 0)
    (dotimes (i (length str))
      (setq *tterm-char* (char str i))
      (setq *tterm-code* (char-code *tterm-char*))
      (funcall (svref tterm-state *tterm-code*)))
    (tterm-flush-buffer)))
|#

#|
(defun tterm-send-do-command (n)
  (interactive "ncode: ")
  (with-tterm-cmd-buffer
    (selected-buffer)
    (tterm-send-do (code-char n) n)
    (tterm-display-option "SENT DO ~d~%" n)
    (tterm-process-send-string (buffer-process (selected-buffer)))))

(defun tterm-send-will-command (n)
  (interactive "ncode: ")
  (with-tterm-cmd-buffer
    (selected-buffer)
    (tterm-send-will (code-char n) n)
    (tterm-display-option "SENT WILL ~d~%" n)
    (tterm-process-send-string (buffer-process (selected-buffer)))))

(defun tterm-send-dont-command (n)
  (interactive "ncode: ")
  (with-tterm-cmd-buffer
    (selected-buffer)
    (tterm-send-dont (code-char n) n)
    (tterm-display-option "SENT DONT ~d~%" n)
    (tterm-process-send-string (buffer-process (selected-buffer)))))

(defun tterm-send-wont-command (n)
  (interactive "ncode: ")
  (with-tterm-cmd-buffer
    (selected-buffer)
    (tterm-send-wont (code-char n) n)
    (tterm-display-option "SENT WONT ~d~%" n)
    (tterm-process-send-string (buffer-process (selected-buffer)))))
|#

#|
(defun pass ()
  (when (scan-buffer "^Password:$"
		     :regexp t :reverse t :tail t
		     :limit (save-excursion
			      (goto-bol)
			      (point)))
    (tterm-send-string *tterm-proc* "password\r")
    (delete #'bar tterm-filter-hook)))

(defun login ()
  (interactive)
  (let ((buf (tterm "hostname" 23 :user "username")))
    (add-hook 'tterm-filter-hook #'bar)))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  èëÇ¢ÇƒÇ†ÇÈÇæÇØÇ≈ëŒâûÇµÇƒÇ¢ÇÈÇÌÇØÇ≈ÇÕÇ†ÇËÇ‹ÇπÇÒ
;;  ãªñ°Ç™Ç†ÇÈêlÇÕí≤Ç◊ÇƒÇ›ÇƒÇ≠ÇæÇ≥Ç¢
;;
;;  <REFERENCE>
;;
;;      RFC 698  : TELNET EXTENDED ASCII OPTION
;;      RFC 726  : REMOTE CONTROLLED TRANSMISSION AND ECHOING TELNET OPTION
;;      RFC 727  : TELNET LOGOUT OPTION
;;      RFC 735  : REVISED TELNET BYTE MACRO OPTION
;;      RFC 736  : TELNET SUPDUP OPTION
;;      RFC 749  : TELNET SUPDUP-OUT OPTION
;;      RFC 779  : TELNET SEND-LOCATION OPTION
;;      RFC 854  : TELNET PROTCOL SPECIFICATION
;;      RFC 855  : TELNET OPTION SPECIFICATIONS
;;      RFC 856  : TELNET BINARY TRANSMISSION
;;      RFC 857  : TELNET ECHO OPTION
;;      RFC 858  : TELNET SUPPRESS GO AHEAD OPTION
;;      RFC 859  : TELNET STATUS OPTION
;;      RFC 860  : TELNET TIMING MARK OPTION
;;      RFC 861  : TELNET EXTENDED OPTIONS - LIST OPTION
;;      RFC 885  : TELNET END OF RECORD OPTION
;;      RFC 927  : TACACS USER IDENTIFICATION TELNET OPTION
;;      RFC 933  : OUTPUT MARKING TELNET OPTION
;;      RFC 946  : TELNET TERMINAL LOCATION NUMBER OPTION
;;      RFC 1041 : TELNET 3270 REGIME OPTION
;;      RFC 1043 : TELNET DATA ENTRY TERMINAL OPTION
;;      RFC 1053 : TELNET X.3 PAD OPTION
;;      RFC 1073 : TELNET WINDOW SIZE OPTION
;;      RFC 1079 : TELNET TERMINAL SPEED OPTION
;;      RFC 1091 : TELNET TERMINAL-TYPE OPTION
;;      RFC 1096 : TELNET X DISPLAY LOCATION OPTION
;;      RFC 1184 : TELNET LINEMODE OPTION
;;      RFC 1372 : TELNET REMOTE FLOW CONTROL OPTION
;;      RFC 1572 : TELNET ENVIRONMENT OPTION
;;
;;      ANSI X3.64
;;      Xterm Control Sequence
;;      Linux Man Page
;;      Screen User's Manual
;;
;;      ECMA-35:1994 Character Code Structure and Extension Techniques
;;      ECMA-48:1991 Control Functions for Coded Character Sets
;;


(tterm-define-state '*tterm-state-utf8*
                    '(*tterm-state-neutral*
                      (#xa0 . tterm-nul)
                      ((#xc2 . #xdf) . tterm-utf8-2_2)
                      ((#xe0 . #xef) . tterm-utf8-3_2)
                      ((#xf0 . #xf7) . tterm-utf8-4_2)))
(tterm-define-state '*tterm-state-utf8-2_2*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-insert-2)))
(tterm-define-state '*tterm-state-utf8-3_2*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-3_3)))
(tterm-define-state '*tterm-state-utf8-3_3*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-insert-3)))
(tterm-define-state '*tterm-state-utf8-4_2*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-4_3)))
(tterm-define-state '*tterm-state-utf8-4_3*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-4_4)))
(tterm-define-state '*tterm-state-utf8-4_4*
                    '((* . tterm-utf8-invalid)
                      (*TELNET-CMD-IAC* . tterm-iac)
                      ((#x80 . #xbf) . tterm-utf8-insert-4)))
(defun tterm-utf8-2_2 ()
  "ëÊ1ÉoÉCÉgÇ™0xc2~dfÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-2_2*)
  (setf tterm-lead-char *tterm-char*))
(defun tterm-utf8-insert-2 ()
  "ëÊ1ÉoÉCÉgÇ™0xc2~dfÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state tterm-state-neutral)
  (tterm-write-char (unicode-char (logior (ash (logand (char-code tterm-lead-char) #x1f) 6)
                                          (logand (char-code *tterm-char*) #x3f)))))
(defun tterm-utf8-3_2 ()
  "ëÊ1ÉoÉCÉgÇ™0xe0~efÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-3_2*)
  (setf tterm-lead-char *tterm-char*))
(defun tterm-utf8-3_3 ()
  "ëÊ1ÉoÉCÉgÇ™0xe0~efÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-3_3*)
  (setf tterm-lead-char-2 *tterm-char*))
(defun tterm-utf8-insert-3 ()
  "ëÊ1ÉoÉCÉgÇ™0xe0~efÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÅAëÊ3ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state tterm-state-neutral)
  (tterm-write-char (unicode-char (logior (ash (logand (char-code tterm-lead-char) #x0f) 12)
                                          (ash (logand (char-code tterm-lead-char-2) #x3f) 6)
                                          (logand (char-code *tterm-char*) #x3f)))))
(defun tterm-utf8-4_2 ()
  "ëÊ1ÉoÉCÉgÇ™0xf0~f7ÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-4_2*)
  (setf tterm-lead-char *tterm-char*))
(defun tterm-utf8-4_3 ()
  "ëÊ1ÉoÉCÉgÇ™0xf0~f7ÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-4_3*)
  (setf tterm-lead-char-2 *tterm-char*))
(defun tterm-utf8-4_4 ()
  "ëÊ1ÉoÉCÉgÇ™0xf0~f7ÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÅAëÊ3ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state *tterm-state-utf8-4_4*)
  (setf tterm-lead-char-3 *tterm-char*))
(defun tterm-utf8-insert-4 ()
  "ëÊ1ÉoÉCÉgÇ™0xf0~f7ÅAëÊ2ÉoÉCÉgÇ™0x80~0xbfÅAëÊ3ÉoÉCÉgÇ™0x80~0xbfÅAëÊ4ÉoÉCÉgÇ™0x80~0xbfÇÃèÍçá"
  (setf tterm-state tterm-state-neutral)
  (tterm-write-char (unicode-char (logior (ash (logand (char-code tterm-lead-char) #x07) 18)
                                          (ash (logand (char-code tterm-lead-char-2) #x3f) 12)
                                          (ash (logand (char-code tterm-lead-char-3) #x3f) 6)
                                          (logand (char-code *tterm-char*) #x3f)))))
(defun tterm-utf8-invalid ()
  "ïsê≥ï∂éöÇÃèÍçá"
  (setf tterm-state tterm-state-neutral))
