// 以下の ifdef ブロックは DLL からのエクスポートを容易にするマクロを作成するための 
// 一般的な方法です。この DLL 内のすべてのファイルは、コマンド ラインで定義された BROWSER_EXPORTS
// シンボルを使用してコンパイルされます。このシンボルは、この DLL を使用するプロジェクトでは定義できません。
// ソースファイルがこのファイルを含んでいる他のプロジェクトは、 
// BROWSER_API 関数を DLL からインポートされたと見なすのに対し、この DLL は、このマクロで定義された
// シンボルをエクスポートされたと見なします。
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


