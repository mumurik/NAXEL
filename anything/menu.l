;;; -*- Mode: Lisp -*-
;;  menu:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       menu is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :user)

;; migemo �̉��b�Ń��j���[�Ȃ񂩂��ӊO�Ƃ�����

(defvar *anything-menu*
  '(("���ʐݒ�(&C)..." . option-property-sheet)
    ("���[�J���ݒ�(&L)..." . local-option-property-sheet)
    ("�V�K�쐬(&N)" . new-file)
    ("�J��(&O)..." . open-file-dialog)
    ("���O��t���ĕۑ�(&A)..." . save-as-dialog)
    ("�t�@�C���̑}��(&I)..." . insert-file-dialog)
    ("���O�̕ύX(&R)..." . rename-dialog)
    ("�S�ĕۑ�(&V)" . save-all-buffers)
    ("�Z�b�V�������J��(&D)..." . open-session-dialog)
    ("�Z�b�V�����̕ۑ�(&W)..." . save-session-dialog)
    ("�Z�b�V���������(&Y)" . close-session-dialog)
    ("���(&P)..." . print-selected-buffer-dialog)
    ("����(&F)..." . search-dialog)
    ("�u��(&R)..." . replace-dialog)
    ("��v���镶����𐔂���(&C)..." . count-matches-dialog)
    ("�ŏ��̃^�O(&I)" . first-error)
    ("���̃^�O(&E)" .  next-error)
    ("�w��s(&J)..." . goto-line-dialog)
    ("�}�[�N(&M)..." . mark-dialog-box)
    ("Gresreg(&S)..." . gresreg-dialog)
    ("Grep(&G)..." . grep-dialog)
    ("�V�����t���[��(&F)" . new-pseudo-frame)
    ("���݂̃t���[�������(&D)" . delete-pseudo-frame)
    ("���ɕ���(&S)" . split-window)
    ("�c�ɕ���(&V)" . split-window-vertically)
    ("���̃E�B���h�E�����(&O)" . delete-other-windows)
    ("���݂̃E�B���h�E�����(&C)" . delete-window)
    ("���̃E�B���h�E(&N)" . other-window)
    ("�O�̃E�B���h�E(&P)" . move-previous-window)
    ("�o�b�t�@�I��(&B)..." . select-buffer)
    ("�R���\�[���v���O������񓯊��Ŏ��s(&A)..." .  execute-subprocess-dialog)
    ("�񓯊��v���O���������Ȃ�(&K)" . kill-subprocess)
    ("�R���\�[���v���O�����̎��s(&P)..." . pipe-command-dialog)
    ("�L�[�{�[�h�}�N���L�^�J�n(&S)" . start-kbd-macro)
    ("�L�[�{�[�h�}�N���L�^�I��(&E)" . end-kbd-macro)
    ("�L�[�{�[�h�}�N�����s(&X)" . call-last-kbd-macro)
    ("�r�����[�h(&R)" . box-drawings-mode)
    ("���t�Ǝ����̑}��(&M)..." . insert-date-string)
    ("�t�@�C��(&F)..." . open-filer)
    ("TAGS�t�@�C���̍쐬(&G)..." . make-tags-file-dialog)
    ("�^�O�W�����v(&J)" .  jump-tag)
    ("�_�C���N�g�^�O�W�����v(&U)" . direct-tag-jump)
    ("�o�b�N�^�O�W�����v(&B)" . back-tag-jump)
    ("�L�[���蓖�Ĉꗗ(&K)" . describe-bindings)
    ("�ŋߓ��͂����L�[(&L)" . view-lossage)
    ("�ɂ���(&A)..." . about-dialog)
    ("�����������[�h(&D)" . edict-mode)
    ))

(add-anything-sources
 :name "XYZZY MENU"
 :candidates (lambda()(mapcar 'car *anything-menu*))
 :action (lambda(m)(command-execute (cdr(assoc m *anything-menu* :test 'equal)))))

(provide :anything/menu)
;;end