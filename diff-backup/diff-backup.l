;;; diff-backup.l --- �o�b�N�A�b�v�t�@�C���Ƃ�diff��\��

;; Author: rufein 
;; Created: 2008-03-15
;; Version: 0.0.2
;; Keywords: Text

;; Licence:
;; 
;; diff-backup.l �� MIT license �Ɋ�Â��ė��p�\�ł��B
;; 
;; Copyright (C) 2008 rufein.
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

;;; Commentary:
;;
;; == �T�v
;; �o�b�N�A�b�v�t�@�C���Ƃ�diff��\�����܂��B
;; 
;; �o�b�N�A�b�v���Ƃ�ݒ�ɂȂ��Ă��Ȃ���ΈӖ��̂Ȃ��g���ł��B
;; �g�p�����ꍇ�́A�c�[�� -> ���ʐݒ� -> �o�b�N�A�b�v�t�@�C�� �ŁA
;; �o�b�N�A�b�v�t�@�C�������� �Ƀ`�F�b�N�����Ă��������B
;;
;; === ���ӓ_
;; �ȉ��̏ꍇ�����m�F���Ă��܂���B
;; (1) �o�b�N�A�b�v�t�@�C�����I���W�i���̃t�@�C���Ɠ����f�B���N�g���ɍ쐬�����ꍇ(*backup-directory* �� nil �̏ꍇ)
;;     "�o�b�N�A�b�v�t�@�C��������"�ȊO�̓f�t�H���g�̂܂܂Ȃ炱����ɂ��Ă͂܂�͂��ł��B
;; (2) �o�b�N�A�b�v�f�B���N�g�����ȉ��̂悤�ɐݒ肵�Ă���ꍇ
;;       (require "backup")
;;       (setq *backup-directory* "C:/path/to/backup")
;;       (setq *hierarchic-backup-directory* t)
;;     *backup-directory* �Ƀ��X�g��ݒ肵����A"/"���܂܂Ȃ��ݒ�ɂ��Ă���A�������́A
;;     *hierarchic-backup-directory* �� nil �ɂȂ��Ă���ꍇ�͖��m�F�ł��B
;; 
;; 
;; == �C���X�g�[��
;; NetInstaller�ŃC���X�g�[�������ꍇ��(1),(2)�͕K�v����܂���B
;; 
;; (1) diff-backup.lzh���_�E�����[�h���ēW�J���Adiff-backup.l��site-lisp�ȉ��ɕۑ����Ă��������B
;; (2) .xyzzy ��
;;     (require "diff-backup")
;;     �Ƃ��Ă��������B
;; (3) �L�[�o�C���h��ݒ肷��ꍇ��
;;     (global-set-key #\S-#\F10 'diff-backup)
;;     �ȂǂƂ��Ă��������B(Shift+F10 �Ɋ��蓖�Ă�ꍇ)
;;
;; == �g�p���@
;; �o�b�N�A�b�v�t�@�C���Ƃ�diff���Ƃ肽���o�b�t�@��I�����āA
;;  M-x diff-backup
;; �Ƃ��Ă��������B
;; 
;; �������̓L�[�o�C���h��ݒ肵�Ď��s���Ă��������B
;; 
;; �f�t�H���g�ł͍ŐV(1����O)�̃o�b�N�A�b�v�t�@�C���Ƃ�diff��\�����܂����A
;;   C-u 2 diff-backup
;; �Ƃ���ƁA2����O�̃o�b�N�A�b�v�t�@�C���Ƃ�diff��\�����܂��B
;;

;;; Change log:
;; * 2008-03-15  ver 0.0.1
;;   *  �쐬
;; * 2008-03-20  ver 0.0.2
;;   * diff-backup�̈�����ύX
;;   * �o�b�N�A�b�v�t�@�C�����̌����̐��K�\�����C��
;;   * NetInstaller�Ή�
;;

;;; Code:

(provide "diff-backup")

(in-package "editor")
(require "diff")
(require "backup")

(export
 '(diff-backup))

(defun diff-backup (&optional (count 1))
  "�o�b�N�A�b�v�t�@�C���Ƃ�diff��\��"
  (interactive "p")
  (let* ((original (get-buffer-file-name (selected-buffer)))
	 (backup (get-backup-file-name original count)))
    (unless backup
      (error "�o�b�N�A�b�v�t�@�C��������܂���B"))
    (diff original
	  backup)))

(defun get-backup-file-name (file-absolute-path-name count)
  "�o�b�N�A�b�v�t�@�C���̃p�X��Ԃ��B
file-absolute-path-name �̓I���W�i���̃t�@�C���̐�΃p�X���B
count �ɉ�����O�̂��̂����w�肷��B"
  ;  (car (list-backup-files (get-backup-base-file-name file-absolute-path-name))))
  (let ((backup-files (list-backup-files (get-backup-base-file-name file-absolute-path-name)))
	(backup))
    (and (> count 0)
	 (<= count (length backup-files))
	 (setf backup (nth (- count 1) backup-files)))
    backup))

(defun list-backup-files (base-file-name)
  "�o�b�N�A�b�v�t�@�C���̈ꗗ�����X�g�Ŏ擾����B
base-file-name�̓o�b�N�A�b�v�t�@�C�����̊�ƂȂ�t�@�C�����B(��΃p�X)
C:/original/foo.txt �̃o�b�N�A�b�v�t�@�C���̈ꗗ���擾����ɂ́A
C:/path/to/backup/C/original/foo.txt �Ƃ����p�X��n���K�v������B"
  (let* ((directory-name (directory-namestring base-file-name))
	 (backup-files (directory directory-name :absolute t :recursive nil :file-only t )))
    (sort
     (remove-if-not #'(lambda (x)
			(string-match (format nil "^~A\.??[0-9]*~~$" base-file-name) x))
		    backup-files)
     #'file-newer-than-file-p)))

(defun get-backup-base-file-name (file-absolute-path-name)
  "�o�b�N�A�b�v�t�@�C�����̊�ƂȂ�t�@�C�������擾����B
file-absolute-path-name �̓I���W�i���̃t�@�C���̐�΃p�X���B"
  (if *backup-directory*
      (merge-pathnames
       (substitute-string file-absolute-path-name ":" "")
       *backup-directory*)
    file-absolute-path-name))

;;; diff-backup.l ends here