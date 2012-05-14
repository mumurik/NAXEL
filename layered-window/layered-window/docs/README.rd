= layered-window - �E�B���h�E�𔼓������E���ߐF�̐ݒ�

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/layered-window.html>))
* Version: 1.0.1


== NAME

layered-window - �E�B���h�E�𔼓������E���ߐF�̐ݒ�


== SYNOPSIS

* UI

    M-x layered-window-set-opacity
    M-x layered-window-set-alpha
    M-x layered-window-set-transparency-color
    M-x layered-window-set-transparency-color-bgr
    M-x layered-window-set-opaque
    M-x toggle-layered-window

* API

    (in-package :your-application)

    (require "layered-window/api")
    (use-package :layered-window.api)

    (set-layered-window-attributes/alpha hwnd 200)


== DESCRIPTION

layered-window �͈ȉ��̋@�\��񋟂��܂��B

* �C�ӂ̃E�B���h�E�̔�������
* �C�ӂ̃E�B���h�E�̓��ߐF�ݒ�

�܂��Axyzzy �̃E�B���h�E�̔��������E���ߐF�ݒ�ɓ������� �C���^�[�t�F�C�X
(API�A���j���[�A�R�}���h) ��񋟂��܂��B

xyzzy �ȊO�̃E�B���h�E�̔��������E���ߐF�ݒ���������ꍇ�� layered-window.api �p�b�P�[�W���̊֐��𗘗p���Ă��������B


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 4 �ȍ~���A
NetInstaller + (({ni-autoload})) ���g���Ă���l�� 5 �ȍ~�� OK �ł��B

(1) api.l ���K�v�Ȃ̂ŃC���X�g�[�����܂� (NetInstaller �ł��C���X�g�[���ł��܂�)�B

    ((<URL:http://xyzzy.s53.xrea.com/wiki/index.php?%B3%C8%C4%A5lisp%2Fwinapi>))

(2) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/layered-window.zip>))

(3) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(4) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; layered-window
        (require "layered-window")

(5) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(6) �E�B���h�E���j���[�������� �Ŕ������ɂł��܂��B


== MODULE

=== PACKAGE

layered-window �͈ȉ��̃p�b�P�[�W���`���Ă��܂��B

* layered-window.api

  �C�ӂ̃E�B���h�E�̔��������E���ߐF�ݒ�������Ȃ����C�u�����B

* layered-window.editor

  xyzzy �̃E�B���h�E�ɓ��������R�}���h�A���j���[�A�t�b�N�̒�`�B

  user, editor �p�b�P�[�W���� use-package ����悤�ɂ��Ă��܂��B

* layered-window.ffi

  winapi ��`�B


=== EXPORT

layered-window �͈ȉ��̊֐��� export ���Ă��܂�
(layered-window.ffi �͓����p�b�P�[�W�Ȃ̂ŏȗ�)�B

==== layered-window.api �p�b�P�[�W

  * ((<"set-layered-window-attributes/alpha"|URL:#label-24 >))
  * ((<"set-layered-window-attributes/color"|URL:#label-25 >))

  * ((<"get-layered-window-attributes/alpha"|URL:#label-26 >))
  * ((<"get-layered-window-attributes/color"|URL:#label-27 >))

  * ((< set-window-ex-layered >))
  * ((< window-ex-layered-p >))

  * ((< alpha->opacity >))
  * ((< opacity->alpha >))
  * ((< color->rgb >))
  * ((< rgb->color >))
  * ((< coerce-to-color >))

  * ((< layered-window-api-version >))


==== layered-window.editor �p�b�P�[�W

  * ((< *layered-window-default-opacity* >))
  * ((< *layered-window-hook* >))

  * ((< layered-window-set-alpha >))
  * ((< layered-window-set-opacity >))
  * ((< layered-window-set-transparency-color >))
  * ((< layered-window-set-transparency-color-bgr >))
  * ((< layered-window-set-opaque >))

  * ((< layered-window-get-alpha >))
  * ((< layered-window-get-opacity >))
  * ((< layered-window-get-transparency-color >))

  * ((< toggle-layered-window >))
  * ((< layered-window-p >))

  * ((< layered-window-version >))


=== VARIABLE

==== layered-window.editor �p�b�P�[�W

--- *layered-window-default-opacity*
    toggle-layered-window �E�B���h�E�̓����E�s������
    �؂�ւ���Ƃ��̕s�����x���w�肵�܂��B

    0 ���� 100 �܂ł̒l���w��\�ł��B
    0 �͊��S�ȓ����A100 �͊��S�ȕs�������Ӗ����܂��B

    �f�t�H���g�� 80 % �ł��B

      ;; �f�t�H���g�̕s�����x�� 95% �ɐݒ�
      (setf *layered-window-default-opacity* 95)

--- *layered-window-hook*

    xyzzy �̃E�B���h�E�̓����x�A���ߐF�ݒ��ύX���邽�тɎ��s�����t�b�N�ł��B
    �t�b�N�̈����� xyzzy �̃E�B���h�E�n���h���ł��B

    �f�t�H���g�ł͉�ʂ̍ĕ`��֐� (layered-window-refresh) ���o�^����Ă��܂��B

        (add-hook '*layered-window-hook* #'(lambda (hwnd)
                                             (msgbox "hello layered-window")))


=== COMMAND

==== layered-window.editor �p�b�P�[�W

--- layered-window-set-opacity

    call-seq:
      (layered-window-set-opacity opacity) => nil

    �s�����x���w�肵�E�B���h�E�𓧉߂��܂��B

    �����ɂ͕s�����x���p�[�Z���e�[�W�Ŏw�肵�܂��B
    0 ���� 100 �܂ł̒l���w��\�ł���A
    0 �͊��S�ȓ����A100 �͊��S�ȕs�������Ӗ����܂��B

    ex)
        ;; 70% �̃A���t�@�l�œ�����
        (layered-window-set-opacity 70)

--- layered-window-set-alpha

    call-seq:
      (layered-window-set-alpha alpha) => nil

    �A���t�@�l���w�肵�E�B���h�E�𓧉߂��܂��B

    �����ɂ̓A���t�@�l�����Ă��܂��B
    0 ���� 255 �܂ł̒l���w��\�ł���A
    0 �͊��S�ȓ����A255 �͊��S�ȕs�������Ӗ����܂��B

    ex)
        ;; 50�� ���炢�œ�����
        (layered-window-set-alpha 127)

--- layered-window-set-transparency-color

    call-seq:
      (layered-window-set-transparency-color r g b) => nil

    �w�肳�ꂽ�F�𓧉ߐF�ɐݒ肵�܂��B

    �F�� 0 ���� 255 �� RGB �l�̃��X�g�Ŏw�肵�܂��B
    ���ߐF�̉����� (layered-window-set-opaque) �����s���܂��B

    ex)
        ;; ���𓧉ߐF�ɐݒ�
        (layered-window-set-transparency-color 255 255 255)

--- layered-window-set-transparency-color-bgr

    call-seq:
      (layered-window-set-transparency-color-bgr bgr) => nil

    �w�肳�ꂽ�F�𓧉ߐF�ɐݒ肵�܂��B

    �F�͕����� (BGR) �Ŏw�肵�܂��B
    ��s���� 0 �͏ȗ��ł��A������̐擪�� "#" �� "#x" ��������܂��B

    �� xyzzy.ini �� backColor �����̂܂܎w��ł��܂��B

    ex)
        ;; �Ԃ𓧉ߐF�ɐݒ� "FF" -> "0000FF"
        (layered-window-set-transparency-color "FF")
        ;; �𓧉ߐF�ɐݒ� (# �Ȃǂ͖��������)
        (layered-window-set-transparency-color "#FF0000")

--- layered-window-set-opaque

    call-seq:
      (layered-window-set-opaque) => nil

    xyzzy �̃E�B���h�E�����S�ɕs�����ɂ��܂��B

    ���S�ɕs�����ɂ����ꍇ�A�ēx����������Ƃ��ɉ�ʂ�������܂��B
    ����������ɂ͑���� (layered-window-set-opacity 100) �𗘗p���Ă��������B

--- toggle-layered-window

    call-seq:
      (toggle-layered-window) => nil

    xyzzy �E�B���h�E�̓����E�s������؂�ւ��܂��B


=== FUNCTION

==== layered-window.api

--- set-layered-window-attributes/alpha

    call-seq:
      (set-layered-window-attributes/alpha hwnd alpha) => nil

    hwnd �Ŏw�肳�ꂽ window ���w�肳�ꂽ���l�Ŕ������ɐݒ肵�܂��B

--- set-layered-window-attributes/color

    call-seq:
      (set-layered-window-attributes/alpha hwnd '(r g b)) => nil

    hwnd �Ŏw�肳�ꂽ window �̎w�肳�ꂽ�F�𓧉ߐF�ɐݒ肵�܂��B

--- get-layered-window-attributes/alpha

    call-seq:
      (get-layered-window-attributes/alpha hwnd) => ���l or nil

    hwnd �Ŏw�肳�ꂽ window �̃��l��Ԃ��܂��B

    ������������Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- get-layered-window-attributes/color

    call-seq:
      (get-layered-window-attributes/color hwnd) => (r g b) or nil

    hwnd �Ŏw�肳�ꂽ window �̓��ߐF�� RGB �̃��X�g�ŕԂ��܂��B

    ������������Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- set-window-ex-layered

    call-seq:
      (set-window-ex-layered hwnd flag) => nil

    hwnd �Ŏw�肳�ꂽ window �� WS_EX_LAYERED �t���O��ݒ肵�܂��B

    * flag �� non-nil �Ȃ� window �� layered window �ɐݒ肵�܂��B
    * flag �� nil �Ȃ� layered window ���������܂��B

--- window-ex-layered-p

    call-seq:
      (window-ex-layered-p hwnd) => t or nil

    hwnd �Ŏw�肳�ꂽ window �� layered window �Ȃ� t ��Ԃ��܂��B


--- alpha->opacity

    call-seq:
      (alpha->opacity alpha) => opacity

    �w�肳�ꂽ���l (0-255) ��s�����x (0-100) �ɕϊ����܂��B

--- opacity->alpha

    call-seq:
      (opacity->alpha opacity) => alpha

    �w�肳�ꂽ�s�����x (0-100) �����l (0-255) �ɕϊ����܂��B

--- color->rgb

    call-seq:
      (color->rgb '(r g b)) => rgb (DWORD)

    �w�肳�ꂽ RGB �̃��X�g�� RGB �l (DWORD) �ɕϊ����܂��B
    RGB �̃��X�g�̊e�l�� 0-255 �ł��Ă����Ă��������B

--- rgb->color

    call-seq:
      (rgb->color rgb) => (r g b)

    �w�肳�ꂽ RGB �l (DWORD) �� RGB �̃��X�g�ɕϊ����܂��B

--- coerce-to-color

    call-seq:
      (coerce-to-color rgb-or-list) => rgb

    �w�肳�ꂽ�l�� RGB �l (DWORD) �ɕϊ����܂��B

    * RGB �̃��X�g�Ȃ� RGB �l (DWORD) �ɕϊ����܂��B
    * integer �Ȃ炻�̂܂ܕԂ��܂��B
    * ����ȊO�Ȃ� type-error ���X���[���܂��B

--- layered-window-api-version

    call-seq:
      (layered-window-api-version) => 1

    layered-window.api �p�b�P�[�W�̃o�[�W������Ԃ��܂��B

    �o�[�W�����͒P���Ȑ��l�ł��B

    layered-window.api �p�b�P�[�W�Œ�`���Ă��� API �ɒǉ��E�ύX���������ꍇ��
    �C���N�������g���܂��B


==== layered-window.editor

--- layered-window-get-opacity
    �E�B���h�E�̕s�����x���擾���܂��B

    0 �͊��S�ȓ����A100 �͊��S�ȕs�������Ӗ����܂��B
    ���ߐݒ肵�Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- layered-window-get-alpha
    �E�B���h�E�̃A���t�@�l���擾���܂��B

    0 �͊��S�ȓ����A255 �͊��S�ȕs�������Ӗ����܂��B
    ���ߐݒ肵�Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- layered-window-get-transparency-color
    �ݒ肳��Ă��铧�ߐF���擾���܂��B

    ���ߐF�� 0 ���� 255 �� RGB �l�̃��X�g�ł� '(R G B)�B

--- layered-window-p
    �E�B���h�E������������Ă���Ȃ� ((|non-nil|)) ��Ԃ��܂��B
    �s�����x 100% �œ��߂��Ă���ꍇ�� ((|t|)) ��Ԃ��܂��B

--- layered-window-version

    call-seq:
      (layered-window-version) => 1.0.1

    �{�p�b�P�[�W�̃o�[�W������Ԃ��܂��B

    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B
    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�
    (Ruby �Ɠ����ł� :-)�B

        (if (string<= "1.1.0" (layered-window-version))
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))


== SAMPLE

�L�[�̐ݒ��ƃT���v���X�N���v�g�ł��B

    ;; Ctrl+F12 �œ�������؂�ւ�
    (global-set-key #\C-F12 'toggle-layered-window)

    ;; xyzzy �I�����Ƀt�F�[�h�A�E�g����
    (add-hook '*kill-xyzzy-hook*
              #'(lambda ()
                  (do ((n 100 (- n 10)))
                      ((< n 0))
                    (layered-window-set-opacity n)
                    (sit-for 0.05))))

    ;; ��A�N�e�B�u�ȂƂ��͔������ɂ���
    (add-hook '*deactivate-hook*
              #'(lambda ()
                  (layered-window-set-opacity 50)))
    (add-hook '*activate-hook*
              #'(lambda ()
                  (layered-window-set-opaque)))

    ;; �������Ȃ��Ƃǂ�ǂ񓧖��ɂȂ��Ă����E�E�E (�d������)
    (let ((alpha 255))
      (add-hook '*post-command-hook*
                #'(lambda (&optional ignore)
                    (setf alpha 255)))
      (start-timer 1
                   #'(lambda ()
                       (decf alpha)
                       (if (< 10 alpha) ; �������炢�c����
                           (layered-window-set-alpha alpha)))))

    ;; libini ���g���Ĕw�i�F���擾���ē��߂���
    (require "libini/libini")
    (defun set-transparency-bgcolor ()
      (let ((ini (libini:ini-to-list (merge-pathnames "xyzzy.ini" (user-config-path)))))
        (layered-window-set-transparency-color-bgr
         (cdr (assoc "backColor" (libini:get-section ini "Colors") :test 'string=)))))

    ;; �F�I���_�C�A���O���g���ē��ߐF��ݒ肷��
    (require "winapi/commdlg")
    (defun choose-transparency-color ()
      (layered-window-set-transparency-color-bgr
       (win-user::choose-color-dialog)))


== TODO

* �c�[�������ʐݒ�̂Ƃ���ɉ��������B


== KNOWN BUGS

* toggle-layered-window �͑O��̓����x�Ȃǂ𖳎����A��� ((< *layered-window-default-opacity* >)) �̐ݒ�𗘗p����
* layered-window.api �̃h�L�������g���Ȃ�


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

: api.l
    ((<URL:http://xyzzy.s53.xrea.com/wiki/index.php?%B3%C8%C4%A5lisp%2Fwinapi>))

: ���C���[�h �E�B���h�E - Windows �A�v���P�[�V�����Ŕ������Ɠ������ʂ��g�p����V������i
    ((<URL:http://www.microsoft.com/japan/msdn/windows/windows2000/layerwin.asp>))

: SetLayeredWindowAttributes
    ((<URL:http://msdn.microsoft.com/library/ja/jpwinui/html/_Win32_SetLayeredWindowAttributes.asp>))

: SetWindowLong
    ((<URL:http://msdn.microsoft.com/library/ja/default.asp?url=/library/ja/jpwinui/html/_win32_setwindowlong.asp>))


== COPYRIGHT

layered-window �� MIT/X ���C�Z���X�ɂ��������ė��p�\�ł��B

See cairo/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
