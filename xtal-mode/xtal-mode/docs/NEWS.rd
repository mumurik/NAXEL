=begin

=== 2008-07-12 / 0.0.5

xtal-mode 0.0.5 �����[�X!

: �V�K�@�\

    * �Ȃ�

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * �Ȃ�

: ���̑�

    * ���C�Z���X�t�@�C���𓯍�


=== 2007-09-30 / 0.0.4

xtal-mode 0.0.4 �����[�X!

: �V�K�@�\

    * �Ȃ�

: �o�O�C��

    * c-indent-level �� 4 ����Ȃ��ꍇ�ɃC���f���g�����������Ȃ��Ă����̂��C���B

: ��݊����܂ޕύX�_

    * �u{�v���͎��̕����ʎ����}����̃J�[�\���ʒu��ύX���܂����B
       * before
             n.times {
                 ��
             } �� �����}��
       * after
             n.times {��
             } �� �����}��

    * �u{�v���͎��ɑΉ���������ʂ�����A�C���f���g���x���������Ȃ�
      �����ʂ������}�����Ȃ��悤�ɂ��܂����B

: ���̑�

    * �Ȃ�


=== 2007-09-10 / 0.0.3

xtal-mode 0.0.3 �����[�X!

: �V�K�@�\

    * Xtal trunk (0.9.7 ����̃o�[�W����) �� exe �� bin �f�B���N�g����
      �u�����悤�ɂȂ����̂őΉ�

    * C-c C-x �� Xtal ���s�O�Ƀt�@�C����ۑ�����悤�ɂ���

    * �Ή���������ʂ������I�ɑ}������悤�ɂ���

      ���̋@�\�� ((<*xtal-electric-insert-close-parentheses*>)) �� nil
      ��ݒ肷�邱�Ƃ� off �ɂł��܂��B

    * ������������I�ɑ}������悤�ɂ���

      ���̋@�\�� ((<*xtal-electric-insert-close-string*>)) �� nil
      ��ݒ肷�邱�Ƃ� off �ɂł��܂��B

    * �ȉ��̃R�}���h��ǉ�
      * ix �� xyzzy ���Ŏ��s (C-c 1)
        * Xtal trunk ���K�v (0.9.7 �ł͓����܂���)
        * ((<ix>))
      * ix ���O���Ŏ��s (C-c !)
        * ((<ix-console>))
      * �X�e�[�g�����g���}�[�N (M-SPC)
        * ((<xtal-mark-statement>))
      * ���̃X�e�[�g�����g (C-M-n)
        * ((<xtal-forward-statement>))
      * �O�̃X�e�[�g�����g (C-M-p)
        * ((<xtal-backward-statement>))
      * ����X�R�[�v�̎��̃X�e�[�g�����g (C-M-j)
        * ((<xtal-forward-statement-in-scope>))
      * ����X�R�[�v�̑O�̃X�e�[�g�����g (C-M-k)
        * ((<xtal-backward-statement-in-scope>))
      * �X�R�[�v����Ɉړ� (C-M-u)
        * ((<xtal-up-statement>))
      * �X�R�[�v�����Ɉړ� (C-M-d)
        * ((<xtal-down-statement>))
      * �O��̃X�e�[�g�����g�����ւ� (C-M-t)
        * ((<xtal-transpose-statement>))
      * Xtal �C���X�g�[���p�X���R�}���h�v�����v�g�ŊJ��
        * ((<xtal-open-install-path-by-command-prompt>))
      * Xtal �C���X�g�[���p�X���G�N�X�v���[���ŊJ��
        * ((<xtal-open-install-path-by-explorer>))

: �o�O�C��

    * Xtal ���s���� C-c C-x �ł�����x Xtal �����s����ƁA
      �O��� Xtal ���~�ł��Ă��Ȃ����������C��

    * svn-mode ���g���Ă���� xtal-mode �̃��j���[���\������Ȃ��ꍇ������������

: ��݊����܂ޕύX�_

    * �Ȃ�

: ���̑�

    * �Ȃ�

=== 2007-08-14 / 0.0.2

xtal-mode 0.0.2 �����[�X!

: �V�K�@�\

    * Xtal 0.9.7.x �Œǉ����ꂽ�L�[���[�h�A���\�b�h���`

    * Xtal ���j���[�Ɏw�肳�ꂽ�t�@�C���EURL ���J�����ڂ�ǉ�����֐����`

        (xtal-add-bookmark-menu :chm "Xtal ���t�@�����X (&C)"
                                (merge-pathnames "xtal.chm" *xtal-install-path*))

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * *xtal-mode-map* �� *xtal-syntax-table* �� require "xtal-mode"
      �������_�Œ�`����悤�ɂ���

: ���̑�

    * �Ȃ�

=== 2007-08-13 / 0.0.1

xtal-mode 0.0.1 �����[�X!

=end
