#|text
���@�\
�Z�b�V�����Ɋ܂߂�����g�����邽�߂ɁA�t�b�N��ǉ����܂����B
���̃t�@�C�������[�h���������ł́A�I���W�i���̓���ƂقƂ�ǈႢ�����
����B��{�I�Ƀt�b�N��ǉ����鎖�ŁA������ǉ��ł���悤�ɂ��܂��B

�����̊g��lisp�ł����̊֐����Ē�`���Ă��āA�������錴���ƂȂ��Ă���
���B������������邽�߂ɂ������̃t�b�N��ǉ����A�g��lisp���Ē�`����
���ƂȂ��t�b�N��ǉ����鎖�ŋ@�\��ǉ��ł���悤�ɂ��܂��B


save-session-info, restore-session-info, load-session,
list-buffer-info �̒�`���㏑�����Ă��܂��B

  *save-session-hook* :
    �Z�b�V�����t�@�C���ւ̏o�̓X�g���[���������Ƃ����֐������s���܂��B
    �Z�b�V���������g������Ƃ��́A�ʏ킱�̃t�b�N�Ɋ֐���ǉ����鎖��
    �s���܂��B

  *pre-restore-buffer-info-hook* :
    �Z�b�V�����̃��[�h�ŁA�o�b�t�@�ɏ���ݒ肵�Ȃ����O�ɑS��1�x����
    �Ăяo����܂��B

  *restore-session-hook* :
    �Z�b�V�����̃��[�h�ŁA�o�b�t�@�ɏ���ݒ肵�Ȃ����O�ɁA�o�b�t�@��
    �ƂɈ�x���Ăяo����܂��B
    run-hook-with-args �Ńt�@�C���̃p�X�������ɂ��ČĂяo����܂��B 

  *post-restore-buffer-info-hook* :
    �Z�b�V�����̃��[�h�ŁA�o�b�t�@�ɏ���ݒ肵�Ȃ�������ɑS��1�x��
    ���Ăяo����܂��B

  *after-session-load-hook*
    �Z�b�V�����t�@�C�����[�h��Ɏ��s�����t�b�N�ł��B

  *before-save-session* :
    �Z�b�V�����̕ۑ��Ńo�b�t�@����ۑ����邩�̔���ɗ��p����܂��B
    run-hook-with-args-until-success �Ńo�b�t�@�������ɂ��ČĂяo����܂��B

  *before-restore-session* :
    �Z�b�V�����̃��[�h�Ńo�b�t�@�������[�h���邩�̔���ɗ��p����܂��B
    run-hook-with-args-until-success �Ńo�b�t�@�������ɂ��ČĂяo����܂��B

���C���X�g�[��
  .xyzzy �� siteini.l �ɉ��̂������Ă��������D
   ni-autoload ���g�p���Ă���l�͕K�v����܂���B
  (require "session-ext")

�����ӎ���
  �ȉ��̒�`���㏑�����Ă��܂��B
    save-session-info, 
    restore-session-info,
    load-session 

��License
Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the 
"Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to 
the following conditions: 

The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

copyright 2006   Masahiro Nakano
modified by mumurik765 2012/05/16

�EAuthor 
    Masahiro Nakano <m-nakano@jaist.ac.jp>


���X�V����
  on 12/11/2006
   �Erestore-session-info, list-buffer-info �ɑ΂��Ă��t�b�N��ǉ��B
   �E�����debug�p�̃R�[�h�������Ă����̂��C�� + 1

  on 06/30/2007
   �E�o�b�t�@����ۑ�����I�v�V���� *session-keeps-buffer-name* ��ǉ�

  on 09/08/2006
   �E���J
|#


(provide "session-ext")


(in-package "editor")

(export '(*save-session-hook*
	  *pre-restore-buffer-info-hook*
	  *restore-buffer-info-hook*
	  *post-restore-buffer-info-hook*
	  *after-session-load-hook*
	  *before-save-session*
	  *before-restore-session*
	  *session-keeps-buffer-name*
	  ))

(defvar *save-session-hook* nil
  "�Z�b�V������ۑ����ɌĂяo����܂��B")
(defvar *pre-restore-buffer-info-hook* nil
  "�Z�b�V�����̃��[�h�Ńo�b�t�@����ݒ肷��O�ɌĂяo����܂��B")
(defvar *restore-buffer-info-hook* nil
  "�Z�b�V�����̃��[�h�Ńo�b�t�@����ݒ肷�鎞�ɌĂяo����܂��B
run-hook-with-args �Ńt�@�C���̃p�X�������ɂ��ČĂяo����܂��B ")

(defvar *post-restore-buffer-info-hook* nil
  "�Z�b�V�����̃��[�h�őS�o�b�t�@����ݒ肵����ɌĂяo����܂��B")
(defvar *after-session-load-hook* nil
  "�Z�b�V���������[�h��ɌĂяo����܂��B")

(defvar *before-save-session* nil
  "�Z�b�V�����̕ۑ��Ńo�b�t�@����ۑ����邩�̔���ɗ��p����܂��B
run-hook-with-args-until-success �Ńo�b�t�@�������ɂ��ČĂяo����܂��B ")

(defvar *before-restore-session* nil
  "�Z�b�V�����̃��[�h�Ńo�b�t�@�������[�h���邩�̔���ɗ��p����܂��B
run-hook-with-args-until-success �Ńo�b�t�@�������ɂ��ČĂяo����܂��B")


(defvar *session-keeps-buffer-name* nil
  "�o�b�t�@����ۑ����鎞 non-nil")

; �f�t�H���g�̊֐����㏑��
; from session.l
(defun list-buffer-info ()
  (save-excursion
    (let ((info nil))
      (mapc #'(lambda (buffer)
		(when (or (file-visited-p buffer)
			  (run-hook-with-args-until-success '*before-save-session* buffer))  ;;
		  (set-buffer buffer)
		  (push (list (or (get-buffer-file-name buffer)
				  (get-buffer-alternate-file-name buffer))  ;; �t�b�N�ǉ��ȊO�̕ύX�_
			      (point)
			      (cons buffer-mode ;; user�p�b�P�[�W�ȊO�̃V���{���ŁA
				                ;; ����export����Ă��Ȃ��ƃ��[�h���ɃG���[
				    (mapcan #'(lambda (mode)
						(let ((var (and (consp mode) (car mode))))
						  (and (symbolp var)
						       (boundp var)
						       (symbol-value var)
						       (list var))))
					    *minor-mode-alist*))
			      (mapcar #'(lambda (var)
					  (and (symbolp var)
					       (local-variable-p var)
					       (cons var (symbol-value var))))
				      *buffer-info-variable-list*)
			      (buffer-name buffer)
			      )
			info)))
	    (buffer-list :buffer-bar-order t))
      (nreverse info))))

; �f�t�H���g�̊֐����㏑��
; from session.l
(defun save-session-info (s)
  (save-current-pseudo-frame)
  (let ((finfo (mapcan #'(lambda (frame)
			   (when (pseudo-frame-save-p frame)
			     (list (list (pseudo-frame-name frame)
					 (winconf-to-readable-winconf
					  (pseudo-frame-winconf frame))
					 (eq frame (get-current-pseudo-frame (selected-frame)))))))
		       (get-pseudo-frame-list (selected-frame))))
	(binfo (list-buffer-info)))
    (princ ";;; xyzzy session file.\n;;; This file is generated automatically. do not edit.\n" s)
    (write `(in-package ,(package-name *package*)) :stream s :escape t)
    (terpri s)
    (write `(restore-session ',binfo ',finfo) :stream s :escape t)
    (terpri s))
  (run-hook-with-args '*save-session-hook* s))

;; �f�t�H���g�̊֐����㏑��
;; from session.l
(defun restore-buffer-info (info)
  (run-hooks '*pre-restore-buffer-info-hook*) ;;
  (unwind-protect                             ;;
      (let ((obuffer (selected-buffer)))
	(mapc #'(lambda (i)
		  (let ((file (pop i)))
		    (when (or (file-exist-p file)
			      (run-hook-with-args-until-success     ;;
				   '*before-restore-session* file)) ;;
		      (handler-case
			  (let ((point (pop i))
				(mode (pop i))
				(minor nil)
				(name nil))                         ;;
			    (if (listp mode)
				(setq minor (cdr mode)
				      mode (car mode)))
			    (let ((*find-file-auto-mode-function* mode))
			      (find-file file)
			      (run-hook-with-args '*restore-buffer-info-hook* file)  ;;
			      )
			    (goto-char point)
			    (mapc #'(lambda (f) (and (fboundp f) (funcall f))) minor)
			    (mapc #'(lambda (x)
				      (let ((carx (car x)))
					(when (and carx (symbolp carx))
					  (make-local-variable carx)
					  (set carx (cdr x)))))
				  (pop i))
			    (setq name (pop i))              ;;
			    (and *session-keeps-buffer-name* ;;
				 name                        ;;
				 (rename-buffer name))       ;;
			    )
			(file-error (c)
			  (si:*print-condition c))))))
	      info)
	(set-buffer obuffer))
    (run-hooks '*post-restore-buffer-info-hook*) ;;
    ))


;; �f�t�H���g�̊֐����㏑��
;; from session.l
(defun load-session (filename &optional not-close)
  (interactive "fLoad session: \np"
    :title0 "Load session" :history0 '*session-file-history*
    :default0 (session-directory))
  (long-operation
    (setq filename (namestring filename))
    (with-open-file (s filename
		       :direction :input
		       :if-does-not-exist :error)
      (unless (equal (read-line s nil) ";;; xyzzy session file.")
	(error "�Z�b�V�����t�@�C���ł͂���܂���")))
    (unwind-protect
	(progn
	  (or not-close
	      (close-session nil nil (if (interactive-p)
					 #'write-file #'save-buffer-dialog)))
	  (load filename :verbose nil :print nil)
	  (setq *current-session-file-name* filename)
	  (run-hooks '*after-session-load-hook*)
	  )
      (init-pseudo-frame))
    t))
