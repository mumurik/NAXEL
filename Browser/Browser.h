// �ȉ��� ifdef �u���b�N�� DLL ����̃G�N�X�|�[�g��e�Ղɂ���}�N�����쐬���邽�߂� 
// ��ʓI�ȕ��@�ł��B���� DLL ���̂��ׂẴt�@�C���́A�R�}���h ���C���Œ�`���ꂽ BROWSER_EXPORTS
// �V���{�����g�p���ăR���p�C������܂��B���̃V���{���́A���� DLL ���g�p����v���W�F�N�g�ł͒�`�ł��܂���B
// �\�[�X�t�@�C�������̃t�@�C�����܂�ł��鑼�̃v���W�F�N�g�́A 
// BROWSER_API �֐��� DLL ����C���|�[�g���ꂽ�ƌ��Ȃ��̂ɑ΂��A���� DLL �́A���̃}�N���Œ�`���ꂽ
// �V���{�����G�N�X�|�[�g���ꂽ�ƌ��Ȃ��܂��B
#ifdef BROWSER_EXPORTS
#define BROWSER_API __declspec(dllexport)
#else
#define BROWSER_API __declspec(dllimport)
#endif


BROWSER_API HWND GetHwnd();
BROWSER_API int create( HWND parent, void *xpiArgs);
BROWSER_API int close();
BROWSER_API int createex( HWND parent, void* xpiArgs, int size, DWORD flag);
BROWSER_API int navigate( char* url );
BROWSER_API int refresh();
BROWSER_API int goBack();
BROWSER_API int goForward();
BROWSER_API int goHome();
BROWSER_API int locationURL(int len, char *outUrl);

