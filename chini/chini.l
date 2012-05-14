;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; chini.l --- xyzzy.ini �̒��ڑ���ɂ��ݒ�ύX

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Modified by mumurik765 2012/05/14
;;
;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 11:00:16 +0900>

;;; Commentary:

;; Description:
;;
;;  xyzzy.ini �𒼐ڑ��삵�ݒ��ύX���܂��B
;;
;;    �E����ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;    �E�t�@�C���ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;    �E�o�b�t�@�Z���N�^�ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;    �EMisc�ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;
;;    �E�t�H���g�ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;    �E�F�ݒ�̕ۑ�/�Ǎ�(�ؑ�)
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� chini.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/chini.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "chini")
;;
;;      4. �K�v�ɉ����A���j���[�ǉ��R�[�h��ǉ����܂��B
;;         :position �̌�̐��A:head-sep ���ɂ��Ă͓K�X�ύX���Ă��������B
;;
;;              ;; ����ݒ�� *chini-popup-menu* ��ǉ������
;;              (add-hook '*init-app-menus-hook*
;;                        #'(lambda ()
;;                            ;; �t�H���g
;;                            ;(chini-font-insert-menu-items :head-sep t)
;;                            ;; �F
;;                            ;(chini-color-insert-menu-items :head-sep t)
;;                            ;; ���
;;                            (chini-print-insert-menu-items :pre-tag 'ed::print-selected-buffer-dialog)
;;                            ;; �t�@�C��
;;                            ;(chini-filer-insert-menu-items :head-sep t)
;;                            ;; �o�b�t�@�Z���N�^
;;                            ;(chini-bufselector-insert-menu-items :head-sep t)
;;                            ;; Misc
;;                            ;(chini-misc-insert-menu-items :head-sep t)
;;                            ;; *chini-popup-menu*
;;                            (chini-insert-menu-items :head-sep t :access-key #\0)) t)
;;
;;      5. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::chini-uninstall) �ƃ^�C�v���A
;;         chini.l �֘A�̏��� xyzzy ����폜���܂��B
;;
;;      2. chini.l �Ɋւ���L�q���폜���܂��B
;;
;;      3. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Usage:
;;
;;      �ȉ��u����v�̐ݒ�ύX���@�B�������l�B
;;
;;      [�~�j�o�b�t�@]
;;      1. M-x chini-save-print-setting �ň���ݒ��ۑ�����B
;;      2. M-x chini-load-print-setting �ň���ݒ��ǂݍ��ށB
;;
;;      [�_�C�A���O]
;;      1. ���j���[�� [�t�@�C��]-[����ݒ�̕ۑ�] �ň���ݒ��ۑ�����B
;;      2. ���j���[�� [�t�@�C��]-[����ݒ�̓ǂݍ���] �������́A
;;         [�t�@�C��]-[�ŋߎg��������ݒ�] �ň���ݒ��ǂݍ��ށB
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 11:00:12 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Wed, 13 Apr 2005 00:15:36 +0900
;;        �Exyzzy 0.2.2.234 �Ή�
;;          - ���p�J�i��S�p�J�i�ɕύX�B
;;          - chini-insert-menu-items �X�V�B
;;            �uxyzzy.ini �ݒ�ύX�v���j���[��ǉ�����ʒu�̃f�t�H���g��
;;            �u(>_<)�v�̉��ɁB
;;          - chini-*-insert-menu-items �X�V�B
;;            ���j���[�ǉ��ʒu�̎w��� :pre-tag �ł��w��ł���悤�ɁB
;;
;;      Wed, 07 Jul 2004 23:46:25 +0900
;;        �E�t�H���g/���/�t�@�C��/�o�b�t�@�Z���N�^/Misc �ɂ��Ă�
;;          �ݒ�؂�ւ���ǉ��B
;;        �E�e�֐����ꊇ��������悤�ɕύX(ed::chini-generate-function)�B
;;          �֐��������� compile ���邩�� ed::*chini-compile-function-p*
;;          �ϐ��Ő��䂷��B
;;        �E*chini-directory* �̏����l�� (user-homedir-pathname) ����
;;          (user-config-path) �ɕύX�B
;;        �E*chini-popup-menu* �ǉ��B(chini-insert-menu-items) �ł�
;;          �f�t�H���g�ł� "�c�[��" ���j���[�ɒǉ�����B
;;        �Echini-*-insert-menu-items �� access-key ���w��ł���悤�ɁB
;;
;;      Mon, 05 Jul 2004 12:37:28 +0900
;;        �E�_���v�t�@�C������ chini.l �̏������܂܂ꂽ�ꍇ��
;;          �G���[����������̂��C���B
;;          (create-popup-menu ���s���^�C�~���O�̏C��)
;;
;;      Mon, 28 Jun 2004 23:21:58 +0900
;;        �E���ō쐬�B
;;

;; Licence:
;;
;;    chini �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "chini")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))
(require "app-menu")

(in-package "winapi")

;; WINBASE.H
(*define-dll-entry DWORD GetPrivateProfileString
                   ;AppName KeyName Default ReturnedString Size  FileName
                   (LPCSTR  LPCSTR  LPCSTR  LPCSTR         DWORD LPCSTR)
                   "kernel32" "GetPrivateProfileStringA")
(*define-dll-entry BOOL WritePrivateProfileString
                   ;AppName KeyName String FileName
                   (LPCSTR  LPCSTR  LPCSTR LPCSTR)
                   "kernel32" "WritePrivateProfileStringA")

(in-package "editor")

(export '(*chini-directory*
          *chini-font-directory*
          *chini-color-directory*
          *chini-print-directory*
          *chini-filer-directory*
          *chini-bufselector-directory*
          *chini-misc-directory*
          *chini-setting-list*
          *chini-compile-function-p*
          *chini-backup-config-file-directory*
          *chini-uninstall-hook*
          *chini-popup-menu*
          chini-backup-config-file
          chini-restore-config-file
          chini-backup-config-file-dialog
          chini-restore-config-file-dialog
          chini-backup-config-file-insert-menu-items
          chini-insert-menu-items))

(defvar *chini-directory* (user-config-path))
(defvar *chini-buffer-name-tmp* " *chini: tmp*")
(defvar *chini-uninstall-hook* nil)
(defvar *chini-popup-menu* nil)

;; �t�H���g�ݒ�
(defvar *chini-font-directory* *chini-directory*)
(define-history-variable *chini-font-setting-history* nil)
(defvar *chini-recent-font-setting-popup-menu* nil)
;; �F�ݒ�
(defvar *chini-color-directory* *chini-directory*)
(define-history-variable *chini-color-setting-history* nil)
(defvar *chini-recent-color-setting-popup-menu* nil)
;; ����ݒ�
(defvar *chini-print-directory* *chini-directory*)
(define-history-variable *chini-print-setting-history* nil)
(defvar *chini-recent-print-setting-popup-menu* nil)
;; �t�@�C���ݒ�
(defvar *chini-filer-directory* *chini-directory*)
(define-history-variable *chini-filer-setting-history* nil)
(defvar *chini-recent-filer-setting-popup-menu* nil)
;; �o�b�t�@�Z���N�^�ݒ�
(defvar *chini-bufselector-directory* *chini-directory*)
(define-history-variable *chini-bufselector-setting-history* nil)
(defvar *chini-recent-bufselector-setting-popup-menu* nil)
;; Misc �ݒ�
(defvar *chini-misc-directory* *chini-directory*)
(define-history-variable *chini-misc-setting-history* nil)
(defvar *chini-recent-misc-setting-popup-menu* nil)

;; �o�b�N�A�b�v/���X�g�A �p
(defvar *chini-backup-config-file-directory* *chini-directory*)
(define-history-variable *chini-backup-config-file-history* nil)
(defvar *chini-recent-backup-config-file-popup-menu* nil)

;; �ꊇ�t�@���N�V���������p
(defvar *chini-setting-list*
  '((font "�t�H���g" ("Font")
          *chini-font-directory*
          *chini-font-setting-history*
          *chini-recent-font-setting-popup-menu*)
    (color "�F" ("Colors")
           *chini-color-directory*
           *chini-color-setting-history*
           *chini-recent-color-setting-popup-menu*)
    (print "���" ("PrintPreview" "Print" "header" "footer")
           *chini-print-directory*
           *chini-print-setting-history*
           *chini-recent-print-setting-popup-menu*)
    (filer "�t�@�C��" ("Filer")
           *chini-filer-directory*
           *chini-filer-setting-history*
           *chini-recent-filer-setting-popup-menu*)
    (bufselector "�o�b�t�@�Z���N�^" ("BufferSelector")
                 *chini-bufselector-directory*
                 *chini-bufselector-setting-history*
                 *chini-recent-bufselector-setting-popup-menu*)
    (misc "Misc" ("Misc")
          *chini-misc-directory*
          *chini-misc-setting-history*
          *chini-recent-misc-setting-popup-menu*))
  "chini: �ꊇ�t�@���N�V���������p�ݒ�")
(defvar *chini-compile-function-p* nil
  "chini: �ꊇ�t�@���N�V���������� compile ���{")

;; base
(defun chini-get-private-profile-string (app key default size file)
  (let ((chunk (si:make-chunk nil size)))
    (winapi::GetPrivateProfileString (si:make-string-chunk app)
                                     (si:make-string-chunk key)
                                     (si:make-string-chunk default)
                                     chunk
                                     size
                                     (si:make-string-chunk file))
    (si:unpack-string chunk 0)))

(defun chini-write-private-profile-string (app key str file)
  (winapi::WritePrivateProfileString (si:make-string-chunk app)
                                     (si:make-string-chunk key)
                                     (si:make-string-chunk str)
                                     (si:make-string-chunk file)))

(defun chini-read-config-data-1 (section &optional config-path)
  (unless config-path
    (setq config-path (merge-pathnames "xyzzy.ini" (user-config-path))))
  (when (file-exist-p config-path)
    (let ((temp-buffer (create-new-buffer *chini-buffer-name-tmp*))
          alist)
      (unwind-protect
          (save-excursion
            (setup-temp-buffer temp-buffer)
            (set-buffer temp-buffer)
            (insert-file-contents config-path)
            (goto-char (point-min))
            (when (scan-buffer (format nil "^\\[~A\\]" section) :regexp t)
              (while (and (forward-line)
                          (not (looking-at "^\\[.+\\]")))
                (if (looking-at "^\\([^=\n]+\\)=\\(.*\\)$")
                    (push (cons (match-string 1) (match-string 2)) alist)))))
        (progn
          (delete-buffer temp-buffer)))
      (nreverse alist))))

(defun chini-read-config-data (section &optional config-path)
  (let (data)
    (unless (listp section)
      (setq section (list section)))
    (dolist (x section)
      (push (list x (chini-read-config-data-1 x config-path)) data))
    (nreverse data)))

(defun chini-write-config-data (data &optional config-path)
  (unless config-path
    (setq config-path (merge-pathnames "xyzzy.ini" (user-config-path))))
  (let (section key val)
    (dolist (x data)
      (setq section (car x))
      (setq x (cadr x))
      (dolist (key-val x)
        (chini-write-private-profile-string section (car key-val)
                                            (cdr key-val) config-path)))))

;; �ꊇ�t�@���N�V���������p
(defun chini-generate-function (setting)
  (let* ((sym (nth 0 setting))
         (display-name (nth 1 setting))
         (sections (nth 2 setting))
         (directory (nth 3 setting))
         (history (nth 4 setting))
         (popup-menu (nth 5 setting))
         (save-func
          (intern (concat "chini-save-" (symbol-name sym) "-setting")))
         (load-func
          (intern (concat "chini-load-" (symbol-name sym) "-setting")))
         (save-dialog-func
          (intern (concat "chini-save-" (symbol-name sym) "-setting-dialog")))
         (load-dialog-func
          (intern (concat "chini-load-" (symbol-name sym) "-setting-dialog")))
         (history-to-menu-func
          (intern (concat "chini-add-" (symbol-name sym) "-setting-history-to-menu")))
         (insert-menu-items-func
          (intern (concat "chini-" (symbol-name sym) "-insert-menu-items")))
         (delete-menu-func
          (intern (concat "chini-" (symbol-name sym) "-delete-menu")))
         (popup-menu-tag
          (intern (concat "chini-recent-" (symbol-name sym) "-setting-popup-menu")))
         (menu-sep-tag
          (intern (concat "chini-" (symbol-name sym) "-sep"))))
    (eval
     `(progn
        (export '(,save-func ,load-func ,save-dialog-func ,load-dialog-func
                  ,insert-menu-items-func))
        (defun ,save-func (file)
          (interactive "FFile: " :default0 ,directory)
          (when (valid-path-p file)
            (chini-write-config-data
             (chini-read-config-data (quote ,sections))
             file)
            (add-history file (quote ,history))
            (,history-to-menu-func)))
        (defun ,load-func (file)
          (interactive "fFile: " :default0 ,directory)
          (if (file-exist-p file)
              (progn
                (chini-write-config-data
                 (chini-read-config-data (quote ,sections) file))
                (add-history file (quote ,history))
                (,history-to-menu-func))
            (message "~A �͑��݂��܂���B" file)))
        (defun ,save-dialog-func ()
          (interactive)
          (multiple-value-bind (file index encoding eol-code)
              (file-name-dialog :save t
                                :title ,(concat display-name "�ݒ�̕ۑ�")
                                :initial-directory ,directory
                                :filter '(("INI�t�@�C��(*.ini)" . "*.ini"))
                                :extension "ini"
                                :overwrite t
                                :hide-read-only t)
            (when file
              (,save-func file))))
        (defun ,load-dialog-func ()
          (interactive)
          (multiple-value-bind (file index encoding eol-code)
              (file-name-dialog :title ,(concat display-name "�ݒ�̓ǂݍ���")
                                :initial-directory ,directory
                                :filter '(("INI�t�@�C��(*.ini)" . "*.ini"))
                                :extension "ini"
                                :must-exist t)
            (when file
              (,load-func file))))
        (defun ,history-to-menu-func ()
          (unless (menup ,popup-menu)
            (setq ,popup-menu
                  (create-popup-menu (quote ,popup-menu-tag))))
          (add-lru-menu ,popup-menu
                        ,history
                        #'(lambda (filename)
                            #'(lambda ()
                                (interactive)
                                (,load-func filename)
                                (add-history filename (quote ,history))))))
        (defun ,insert-menu-items-func (&key menu pre-tag position head-sep tail-sep access-key)
          (,history-to-menu-func)
          (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
              (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::file)))
          (when (menup menu)
            (,delete-menu-func menu)
            (when (and pre-tag
                       (setq position (get-menu-position menu pre-tag)))
              (incf position))
            (unless (and (numberp position) (integerp position) (not (minusp position))
                         (get-menu menu position t))
              (setq position -1)
              (while (get-menu menu (incf position) t)))
            (decf position)
            (if (and head-sep
                     (not (minusp position))
                     (get-menu menu position t))
                (insert-menu-separator menu (incf position) (quote ,menu-sep-tag)))
            (unless (characterp access-key)
              (setq access-key #\0))
            (insert-popup-menu menu (incf position)
                               ,popup-menu
                               (format nil "�ŋߎg����~A�ݒ�(&~C)" ,display-name access-key))
            (setq access-key (code-char (1+ (char-code access-key))))
            (insert-menu-item menu (incf position) (quote ,load-dialog-func)
                              (format nil "~A�ݒ�̓ǂݍ���(&~C)..." ,display-name access-key)
                              (quote ,load-dialog-func))
            (setq access-key (code-char (1+ (char-code access-key))))
            (insert-menu-item menu (incf position) (quote ,save-dialog-func)
                              (format nil "~A�ݒ�̕ۑ�(&~C)..." ,display-name access-key)
                              (quote ,save-dialog-func))
            (if (and tail-sep
                     (get-menu menu (incf position) t))
                (insert-menu-separator menu position (quote ,menu-sep-tag)))))

        (defun ,delete-menu-func (&optional menu)
          (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
              (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::file)))
          (when (menup menu)
            (while (delete-menu menu (quote ,popup-menu-tag)))
            (while (delete-menu menu (quote ,load-dialog-func)))
            (while (delete-menu menu (quote ,save-dialog-func)))
            (while (delete-menu menu (quote ,menu-sep-tag)))))
        (when *chini-compile-function-p*
          (compile (quote ,save-func))
          (compile (quote ,load-func))
          (compile (quote ,save-dialog-func))
          (compile (quote ,load-dialog-func))
          (compile (quote ,history-to-menu-func))
          (compile (quote ,insert-menu-items-func))
          (compile (quote ,delete-menu-func)))
        (add-hook '*chini-uninstall-hook* (quote ,delete-menu-func))))))

;; �ꊇ�t�@���N�V��������
(dolist (setting *chini-setting-list*)
  (chini-generate-function setting))

;; xyzzy.ini �o�b�N�A�b�v/���X�g�A
(defun chini-backup-config-file (file)
  "chini: xyzzy.ini �̃o�b�N�A�b�v"
  (interactive "FFile: " :default0
    (merge-pathnames (concat "xyzzy-" (format-date-string "%Y%m%d_%H%M") ".ini")
                     *chini-backup-config-file-directory*))
  (let ((config-file (merge-pathnames "xyzzy.ini" (user-config-path))))
    (when (and (file-exist-p config-file)
               (valid-path-p file))
      (copy-file config-file file :if-exists :overwrite)
      (add-history file '*chini-backup-config-file-history*)
      (chini-add-backup-config-file-history-to-menu))))
(defun chini-restore-config-file (file)
  "chini: xyzzy.ini �̃��X�g�A"
  (interactive "fFile: " :default0 *chini-backup-config-file-directory*)
  (let ((config-file (merge-pathnames "xyzzy.ini" (user-config-path))))
    (if (file-exist-p file)
        (progn
          (copy-file file config-file :if-exists :overwrite)
          (add-history file '*chini-backup-config-file-history*)
          (chini-add-backup-config-file-history-to-menu))
      (message "~A �͑��݂��܂���B" file))))
(defun chini-backup-config-file-dialog ()
  "chini: xyzzy.ini �̃o�b�N�A�b�v�_�C�A���O"
  (interactive)
  (multiple-value-bind (file index encoding eol-code)
      (file-name-dialog :save t
                        :title "xyzzy.ini�̃o�b�N�A�b�v"
                        :initial-directory *chini-backup-config-file-directory*
                        :default (merge-pathnames (concat "xyzzy-" (format-date-string "%Y%m%d_%H%M") ".ini")
                                                  *chini-backup-config-file-directory*)
                        :filter '(("INI�t�@�C��(*.ini)" . "*.ini"))
                        :extension "ini"
                        :overwrite t
                        :hide-read-only t)
    (when file
      (chini-backup-config-file file))))
(defun chini-restore-config-file-dialog ()
  "chini: xyzzy.ini �̃��X�g�A�_�C�A���O"
  (interactive)
  (multiple-value-bind (file index encoding eol-code)
      (file-name-dialog :title "xyzzy.ini�̃��X�g�A"
                        :initial-directory *chini-backup-config-file-directory*
                        :filter '(("INI�t�@�C��(*.ini)" . "*.ini"))
                        :extension "ini"
                        :must-exist t)
    (when file
      (chini-restore-config-file file))))
(defun chini-add-backup-config-file-history-to-menu ()
  (unless (menup *chini-recent-backup-config-file-popup-menu*)
    (setq *chini-recent-backup-config-file-popup-menu*
          (create-popup-menu 'chini-recent-backup-config-file-popup-menu)))
  (add-lru-menu *chini-recent-backup-config-file-popup-menu*
                *chini-backup-config-file-history*
                #'(lambda (filename)
                    #'(lambda ()
                        (interactive)
                        (chini-restore-config-file filename)
                        (add-history filename *chini-backup-config-file-history*)))))
(defun chini-backup-config-file-insert-menu-items (&key menu position head-sep tail-sep access-key)
  (chini-add-backup-config-file-history-to-menu)
  (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
      (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::file)))
  (when (menup menu)
    (chini-backup-config-file-delete-menu)
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'chini-backup-config-file-sep))
    (unless (characterp access-key)
      (setq access-key #\0))
    (insert-popup-menu menu (incf position)
                       *chini-recent-backup-config-file-popup-menu*
                       (format nil "�ŋߎg���� xyzzy.ini �o�b�N�A�b�v(&~C)" access-key))
    (setq access-key (code-char (1+ (char-code access-key))))
    (insert-menu-item menu (incf position) 'chini-restore-config-file-dialog
                      (format nil "xyzzy.ini �o�b�N�A�b�v����̕���(&~C)..." access-key)
                      'chini-restore-config-file-dialog)
    (setq access-key (code-char (1+ (char-code access-key))))
    (insert-menu-item menu (incf position) 'chini-backup-config-file-dialog
                      (format nil "xyzzy.ini �̃o�b�N�A�b�v(&~C)..." access-key)
                      'chini-backup-config-file-dialog)
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'chini-backup-config-file-sep))))
(defun chini-backup-config-file-delete-menu (&optional menu)
  (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
      (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::file)))
  (when (menup menu)
    (while (delete-menu menu 'chini-recent-backup-config-file-popup-menu))
    (while (delete-menu menu 'chini-restore-config-file-dialog))
    (while (delete-menu menu 'chini-backup-config-file-dialog))
    (while (delete-menu menu 'chini-backup-config-file-sep))))

;;
(defun chini-create-popup-menu ()
  (let ((menu (create-popup-menu 'chini-menu))
        (access-key #\A))
    (chini-font-insert-menu-items :menu menu :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-color-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-print-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-filer-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-bufselector-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-misc-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-backup-config-file-insert-menu-items :menu menu :head-sep t :access-key access-key)
    menu))

(defun chini-insert-menu-items (&key menu pre-tag position head-sep tail-sep access-key)
  (unless *chini-popup-menu*
    (setq *chini-popup-menu* (chini-create-popup-menu)))
  (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
      (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::tools)))
  (when (menup menu)
    (chini-delete-menu)
    (unless (or pre-tag position)
      (setq pre-tag :|(>_<)-popup|))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'chini-sep))
    (unless (characterp access-key)
      (setq access-key #\0))
    (insert-popup-menu menu (incf position)
                       *chini-popup-menu*
                       (format nil "xyzzy.ini �ݒ�ύX(&~C)" access-key))
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'chini-sep))))
(defun chini-delete-menu (&optional menu)
  (if (and (not (menup menu)) (menup (get-app-menu (selected-frame))))
      (setq menu (get-menu (get-app-menu (selected-frame)) 'ed::tools)))
  (when (menup menu)
    (while (delete-menu menu 'chini-menu))
    (while (delete-menu menu 'chini-sep))))

;; uninstall
(defun chini-uninstall ()
  (let ((history-variables
         '(*chini-font-setting-history*
           *chini-color-setting-history*
           *chini-print-setting-history*
           *chini-filer-setting-history*
           *chini-bufselector-setting-history*
           *chini-misc-setting-history*
           *chini-backup-config-file-history*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable)))
  (run-hooks '*chini-uninstall-hook*))

;;
(add-hook '*init-app-menus-hook*
          #'(lambda ()
              (unless *chini-popup-menu*
                (setq *chini-popup-menu* (chini-create-popup-menu)))))

;;; chini.l ends here