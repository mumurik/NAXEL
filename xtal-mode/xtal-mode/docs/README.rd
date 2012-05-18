=begin

= xtal-mode - Xtal ����̃��W���[���[�h

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xtal-mode/intro.htm>))
  * Version: 0.0.5


== DESCRIPTION

xtal-mode �� ((<Xtal|URL:http://code.google.com/p/xtal-language/>))
�����ҏW���邽�߂̃��W���[���[�h�ł��B

�ȉ��̋@�\��񋟂��܂��B

  * �L�[���[�h�E�g�ݍ��݊֐��E���\�b�h�̐F�Â�
  * �L�[���[�h�E�g�ݍ��݊֐��E���\�b�h�̕⊮
  * �����C���f���g
  * �N���X�E���\�b�h�̈ꗗ
  * ���P�� (�N���X�E���\�b�h�E���Ȃ�) �ł̈ړ��E�ҏW
  * �^�O�W�����v
  * xtal �̎��s
  * ix �̎��s


== INSTALL

=== NetInstaller �ŃC���X�g�[��

(1) NetInstaller �� xtal-mode ���C���X�g�[�����Ă��������B

(2) ((*ni-autoload �𗘗p���Ă��Ȃ��ꍇ*))�́A
    ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����Ă��������B

        ;; xtal-mode
        (require "xtal-mode")
        (pushnew '("\\.xtal$" . xtal-mode) *auto-mode-alist* :test 'equal)

    ni-autoload �𗘗p���Ă���ꍇ�͒ǉ�����K�v�͂���܂���B

(3) �����悤�� xtal �̃C���X�g�[���f�B���N�g����ݒ肵�Ă��������B

        ;; xtal �̃C���X�g�[����
        (setf *xtal-install-path* "c:/Program Files/xtal/")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) �g���q�� .xtal �̃t�@�C�����J���� xtal-mode �Ɉڍs���܂��B

=== NetInstaller ���g�킸�ɃC���X�g�[��

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xtal-mode.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; xtal-mode
        (require "xtal-mode")
        (pushnew '("\\.xtal$" . xtal-mode) *auto-mode-alist* :test 'equal)
        ;; xtal �̃C���X�g�[����
        (setf *xtal-install-path* "c:/Program Files/xtal/")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) �g���q�� .xtal �̃t�@�C�����J���� xtal-mode �Ɉڍs���܂��B



== MODULE

=== PACKAGE

xtal-mode �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * xtal-mode

xtal-mode �p�b�P�[�W����͈ȉ��̕ϐ��E�֐��� export ���Ă��܂��B

�܂��Axtal-mode �p�b�P�[�W�̓f�t�H���g�� user ����� editor �p�b�P�[�W���� use ����܂��B


=== VARIABLE

--- *xtal-mode-map*
    xtal-mode �̃L�[�}�b�v

--- *xtal-mode-syntax-table*
    xtal-mode �̃V���^�b�N�X�e�[�u��

--- *xtal-mode-hook*
    xtal-mode ���s���ɌĂ΂��t�b�N

--- *xtal-create-output-buffer-hook*
    xtal �R�}���h�̎��s���ʃo�b�t�@�쐬���ɌĂ΂��t�b�N

--- *xtal-before-run-xtal-hook*
    xtal �R�}���h���s���O�ɌĂ΂��t�b�N

--- *xtal-run-xtal-hook*
    xtal �R�}���h���s�J�n���ɌĂ΂��t�b�N�B������ xtal.exe �� process

--- *xtal-after-run-xtal-hook*
    xtal �R�}���h�̎��s���I�������Ƃ��ɌĂ΂��t�b�N�B������ xtal.exe �� process

--- *xtal-comment-column*
    indent-for-comment �ő}������R�����g�̊J�n�ʒu

--- *xtal-indent-level*
    �C���f���g���x�� (�f�t�H���g: 4)

      ;; �C���f���g���x���� 2 �ɂ���
      (setf *xtal-indent-level* 2)

--- *xtal-electric-insert-close-parentheses*
    �Ή���������ʂ������I�ɑ}������ꍇ non-nil (�f�t�H���g: t)

--- *xtal-electric-insert-close-string*
    ������������I�ɕ���ꍇ non-nil (�f�t�H���g: t)

--- *xtal-keyword-file*
    �L�[���[�h�t�@�C���� (�f�t�H���g: Xtal)�B

    $XYZZY/etc �z���̃t�@�C�������w��B

--- *xtal-install-path*
    Xtal �̃C���X�g�[���p�X�B

    ���̒l�͕K���ݒ肵�Ă��������B

        (setf *xtal-install-path* "d:/usr/local/xtal")

--- *xtal-command-xtal*
    xtal.exe �̃p�X (�f�t�H���g: "xtal.exe")�B

    ���΃p�X�̏ꍇ ((<*xtal-install-path*>)) ����T���܂��B

--- *xtal-command-ix*
    ix.exe �̃p�X (�f�t�H���g: "ix.exe")�B

    ���΃p�X�̏ꍇ ((<*xtal-install-path*>)) ����T���܂��B

--- *xtal-mode-output-buffer-name*
    xtal �R�}���h�̎��s���ʃo�b�t�@�̖��O (�f�t�H���g: "*Xtal*")

--- *xtal-command-output-window-height*
    xtal �̎��s���ʂ�\������E�B���h�E�̍��� (�f�t�H���g -10)

--- *xtal-ix-buffer-name*
    ix �����s����o�b�t�@�̖��O (�f�t�H���g: "*ix*")

--- *xtal-ix-window-height*
    ix �����s����E�B���h�E�̍��� (�f�t�H���g: -20)

--- *xtal-online-reference-url*
    �I�����C�����t�@�����X�� URL

--- *xtal-home-url*
    Home URL


=== COMMAND

--- xtal-mode

    �o�b�t�@�� Xtal �ҏW���[�h�ɂ��܂��B

--- xtal-completion

    �f�t�H���g�L�[�o�C���h: ((%M-TAB%))

    Xtal �̃L�[���[�h�A���\�b�h����⊮���܂��B

--- xtal-indent-buffer

    �f�t�H���g�L�[�o�C���h: ((%C-c C-\%))

    �o�b�t�@�S�̂��C���f���g���܂��B

--- xtal-comment-region

    �f�t�H���g�L�[�o�C���h: ((%C-c C-9%))

    ���[�W�������R�����g�A�E�g���܂��B

--- xtal-uncomment-region

    �f�t�H���g�L�[�o�C���h: ((%C-c C-8%))

    ���[�W�������R�����g���������܂��B

--- xtal-toggle-comment-line

    �f�t�H���g�L�[�o�C���h: ((%C-c C-/%))

    �J�[�\���s�� 1 �s�R�����g��؂�ւ��܂��B

--- xtal-run-with-current-buffer

    �f�t�H���g�L�[�o�C���h: ((%C-c C-x%))

    �ҏW���̃o�b�t�@�� xtal �Ŏ��s���܂��B

    * �t�@�C����ۑ����Ă��Ȃ��ꍇ�́A�t�@�C���ɕۑ����Ă�����s���܂��B
    * �t�@�C���������݂��Ȃ��ꍇ�́A�ꎞ�t�@�C���ɕۑ����Ă�����s���܂��B

--- xtal-first-error

    �f�t�H���g�L�[�o�C���h: ((%F10%))

    Xtal �����s���ʂ̍ŏ��̃G���[�Ɉړ����܂��B

    ���̌�AF11 ���������ƂŎ��̃G���[�Ɉړ��ł��܂��B

--- xtal-close-output-buffer

    �f�t�H���g�L�[�o�C���h: ((%C-c 0%))

    Xtal �̎��s���ʂ��o�b�t�@���폜���܂��B

--- ix

    �f�t�H���g�L�[�o�C���h: ((%C-c 1%))

    ix �� xyzzy �����Ŏ��s���܂��B
    ix �o�b�t�@�̑�����@�� ((<ix-mode>)) ���Q�Ƃ��Ă��������B

--- ix-console

    �f�t�H���g�L�[�o�C���h: ((%C-c !%))

    �R�}���h�v�����v�g�� ix ���N�����܂��B

--- xtal-mark-statement

    �f�t�H���g�L�[�o�C���h: ((%M-SPC%))

    �J�[�\��������s�̕��S�̂��}�[�N���܂��B

    ��:

      ��Hello: class {
      ��    world: method() {
                say("World!");
            }
            say: method(name) {
                print("Hello, " ~ name);
            }
        }

    * ���ɃJ�[�\����u���Ď��s����� Hello �N���X�S�̂��}�[�N���܂��B
    * ���ɃJ�[�\����u���Ď��s����� world ���\�b�h�S�̂��}�[�N���܂��B

--- xtal-forward-statement

    �f�t�H���g�L�[�o�C���h: ((%C-M-n%))

    ���̕��Ɉړ����܂��B

    ��:

      Hello: class {
        ��world: method() {
            ��say("World!");
          }
        ��say: method(name) {
              print("Hello, " ~ name);
          }
      }

    * ���ɃJ�[�\����u���Ď��s����� say() �̐擪 (��) �Ɉړ����܂��B
    * ������x���s����� say method �̐擪 (��) �Ɉړ����܂��B

--- xtal-backward-statement

    �f�t�H���g�L�[�o�C���h: ((%C-M-p%))

    �O�̕��Ɉړ����܂��B

--- xtal-forward-statement-in-scope

    �f�t�H���g�L�[�o�C���h: ((%C-M-j%))

    ����̃X�R�[�v���Ŏ��̕��Ɉړ����܂��B

    ��:

      Hello: class {
        ��world: method() {
              say("World!");
          }
        ��say: method(name) {
              print("Hello, " ~ name);
          }
      }

    * ���ɃJ�[�\����u���Ď��s����� say method �̐擪 (��) �Ɉړ����܂��B
    * ������x���s����ƃJ�[�\���͈ړ����܂���B

--- xtal-backward-statement-in-scope

    �f�t�H���g�L�[�o�C���h: ((%C-M-k%))

    ����̃X�R�[�v���őO�̕��Ɉړ����܂��B

--- xtal-up-statement

    �f�t�H���g�L�[�o�C���h: ((%C-M-u%))

    �ЂƂ�̃X�R�[�v�Ɉړ����܂��B

    ��:

      ��Hello: class {
            world: method() {
                say("World!");
            }
          ��say: method(name) {
              ��print("Hello, " ~ name);
            }
        }

    * ���ɃJ�[�\����u���Ď��s����� say method �̐擪 (��) �Ɉړ����܂��B
    * ������x���s����� Hello �N���X�̐擪 (��) �Ɉړ����܂��B

--- xtal-down-statement

    �f�t�H���g�L�[�o�C���h: ((%C-c 0%))

    �ЂƂ��̃X�R�[�v�Ɉړ����܂��B

    ��:

      ��Hello: class {
          ��world: method() {
              ��say("World!");
            }
            say: method(name) {
                print("Hello, " ~ name);
            }
        }

    * ���ɃJ�[�\����u���Ď��s����� world method �̐擪 (��) �Ɉړ����܂��B
    * ������x���s����� say() �̐擪 (��) �Ɉړ����܂��B

--- xtal-transpose-statement

    �f�t�H���g�L�[�o�C���h: ((%C-M-t%))

    ���ƕ��̊ԂŎ��s����ƕ������ւ��܂��B
    �N���X�⃁�\�b�h�P�ʂœ���ւ��邱�Ƃ��ł��܂��B

    �������Ŏ��s����ƃJ�[�\���O��̎������ւ��܂� (�ʏ�� transpose-sexp �Ǔ���)�B

    ��:

        Hello: class {
            world: method() {
                say("World!");
            }
            ��
            say: method(name) {
                print("Hello,"�� ~ name);
            }
        }

    * ���ɃJ�[�\����u���Ď��s����� world ���\�b�h�� say ���\�b�h������ւ��܂��B
    * ���ɃJ�[�\����u���Ď��s����� "Hello, " �� name ������ւ��܂��B

    �� 2:

    xtal-transpose-statement �� if �� else if �̂ݓ��ʂȏ��������܂�
    (if �� else �̓���ւ��͉����l��������ւ��邾��)�B

        if (a == 1) {
          hello();
        }��else if (a == 2) {
          world();
        }

    ���ɃJ�[�\����u���Ď��s����ƈȉ��̂悤�ɂȂ�܂��B

        if (a == 2) {
            world();
        } else if (a == 1) {
            hello();
        }

--- xtal-open-install-path-by-command-prompt

    ((<*xtal-install-path*>)) �Őݒ肵���f�B���N�g����
    �R�}���h�v�����v�g�ŊJ���܂��B

--- xtal-open-install-path-by-explorer

    ((<*xtal-install-path*>)) �Őݒ肵���f�B���N�g����
    �G�N�X�v���[���ŊJ���܂��B

--- xtal-track-popup-menu

    xtal-mode �̃��j���[���|�b�v�A�b�v�\�����܂��B

--- xtal-mode-show-credit

    xtal-mode �̃o�[�W������\�����܂��B


=== FUNCTION

--- xtal-add-bookmark-menu tag name file-or-url

    �w�肵���t�@�C���� URL ���J�����j���[���ڂ� Xtal ���j���[�ɒǉ�����֐��ł��B

    ���j���[���ڂ̓o�[�W�����ԍ��̏�ɒǉ�����܂��B

    * tag �ɂ̓��j���[���ڂ����Ƃ��环�ʂł���悤�ɂ���l���w�肵�܂��Bnil �ł����܂��܂���B
    * name �ɂ̓��j���[�ɕ\�����閼�O���w�肵�܂��B
    * file-or-url �ɂ̓t�@�C���p�X�܂��� URL �𕶎���Ŏw�肵�܂��B
      file-or-url �� shell-execute �Ŏ��s����܂��B

    ��:

        ;; Xtgl �� HTML �w���v�����j���[�ɒǉ��B
        ;; xtal.chm �� xtal.exe �Ɠ����ꏊ�ɂ����Ă����B
        (xtal-add-bookmark-menu :chm "Xtal ���t�@�����X (&C)"
                                (merge-pathnames "xtal.chm" *xtal-install-path*))

--- goto-matched-multi-line-comment

    �Ή����镡���s�R�����g�̊J�n�E�I���ʒu�Ɉړ����܂��B

    * �u/*�v�̋߂��Ŏ��s�����ꍇ�Ή�����u*/�v�Ɉړ����܂��B
    * �u*/�v�̋߂��Ŏ��s�����ꍇ�Ή�����u/*�v�Ɉړ����܂��B

--- goto-beginning-of-multi-line-comment

    �����s�R�����g�̊J�n (/*) �Ɉړ����܂��B

--- goto-end-of-multi-line-comment

    �����s�R�����g�̏I�� (*/) �Ɉړ����܂��B

--- xtal-comment-line-p

    ���ݍs���R�����g�s�Ȃ� t ��Ԃ��܂��B

--- xtal-in-comment-p

    �J�[�\���̂���ʒu�� 1 �s�R�����g�܂��͕����s�R�����g�Ȃ� t ��Ԃ��܂��B

--- xtal-in-multiline-comment-p

    �J�[�\���̂���ʒu�������s�R�����g�Ȃ� t ��Ԃ��܂��B
    1 �s�R�����g�̏ꍇ�� nil ��Ԃ��܂��B

--- xtal-in-shebang-comment-p

    �J�[�\���̂���ʒu���u#!�v�Ŏn�܂�R�����g�s�Ȃ� t ��Ԃ��܂��B

--- xtal-parse-point-syntax

    �u#!�v�R�����g�ɑΉ����� parse-point-syntax �ł��B

--- xtal-mode-version

    xtal-mode �̃o�[�W������Ԃ��܂��B

    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B
    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�

        (if (string<= "1.1.0" (xtal-mode-version))
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))


== ix-mode

xyzzy �̃o�b�t�@���� ix ���N�� (((<ix>))) ����� ix-mode �ɂȂ�܂��B

ix-mode �ł͈ȉ��̃L�[����`����Ă��܂��B

: RET
    ���͂��Ă���R�}���h�� ix �ɑ���܂��B

: C-c C-c
    ix ���~���܂��B

: C-c 0
    ix ���~���A�o�b�t�@����܂��B

: C-p
    �ߋ��ɓ��͂��� ix �R�}���h�̗�����}�����܂��B
    �A�����Ď��s���邱�Ƃŗ������Â����ւ����̂ڂ��čs���܂��B

: C-n
    �ߋ��ɓ��͂��� ix �R�}���h�̗�����}�����܂��B
    �A�����Ď��s���邱�Ƃŗ�����V�������ւ����̂ڂ��čs���܂��B

: C-M-p
    ��O�̃v�����v�g�Ɉړ����܂��B

    �ߋ��̃v�����v�g�� Enter �������Ƃ��̃R�}���h���Ď��s�ł��܂��B
    ���͒��̃R�}���h�͕ۑ�����܂� (M-q �Ɠ���)�B

: C-M-n
    ���̃v�����v�g�Ɉړ����܂��B

: M-q
    ���ݓ��͒��̃R�}���h��ۑ����ē��͍s���N���A���܂��B

    ���̃R�}���h�����s����Ǝ��̃v�����v�g�ɂ͕ۑ��������͍s�������I�ɑ}������܂��B


== TODO

* lib:foo ���� foo.xtal ���J��
* xtal-mode
  * xtal ���s���Ɉ����̎w��i�O�u�����j
* xtal
  * �O���v���O�����Ƃ��� xtal.exe �����s�B
    * �K�v?
* ix
  * �J�[�\���ړ��n�̑O�u����
  * ���݂̃N���X�𑗂�
  * ���݂̃��\�b�h�𑗂�
  * �q�X�g��
    * �q�X�g���̕ҏW
    * �q�X�g���̈ꗗ
      * popup
    * !23
    * �q�X�g������ (C-r)
    * �����s
      * �����I�����Ă��邩�ǂ����̔�������O��
      * zsh
      * inferior-ruby-mode
  * //=> �`���Ŏ��s���ʂ̑}��
  * ���͍s���܂Ƃ߂ăo�b�t�@�ɕϊ�
* �O�� ix
  * �E�B���h�E�̊Ǘ�
    * xyzzy �̎q�v���Z�X
    * ����
    * forground
    * 2�d�N���h�~
    * �E�B���h�E�̐؂�ւ�
  * ���݂�xxx�𑗂�
    * clipborad �o�R?
* �R���e�L�X�g�ɉ������⊮
  * math:: �̌�Ȃ� math �̃��\�b�h����, ::?
  * . �̂��ƂȂ烁�\�b�h����, .?
  * �O�ɂȂɂ��Ȃ��Ȃ�A
  * ���l���e�����A�����񃊃e�����̂���
  * �N���X���𖾎������⊮
* HTML Help
  * �E�B���h�E�ʒu�̕ۑ�
  * �L�[���[�h����
* �\�[�X�̐���
  * �K�w��
* iterator �̃N���X�e���v���[�g�̑}��
  * iter_first, iter_next, iter_break
* ������ xtal �̐؂�ւ�
  * menu
  * history
* �s���� ~ �� + ������ꍇ�̃C���f���g
* lambda ���̃C���f���g


== KNOWN BUGS

�Ȃ��B


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

  : Xtal Language
        ((<URL:http://code.google.com/p/xtal-language/>))

  : Xtal �I�����C�����t�@�����X
        ((<URL:http://www.h5.dion.ne.jp/~putora/xtal_doc/>))


== COPYRIGHT

xtal-mode �� MIT/X ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

See xtal-mode/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
