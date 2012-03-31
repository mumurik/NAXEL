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

extern "C" {
BROWSER_API HWND WINAPI GetHwnd();
BROWSER_API int WINAPI create( HWND parent, void *xpiArgs);
BROWSER_API int WINAPI close();
BROWSER_API int WINAPI createex( HWND parent, void* xpiArgs, int size, DWORD flag);
BROWSER_API int WINAPI navigate( char* url );
BROWSER_API int WINAPI refresh();
BROWSER_API int WINAPI goBack();
BROWSER_API int WINAPI goForward();
BROWSER_API int WINAPI goHome();
BROWSER_API int WINAPI locationURL(int len, char *outUrl);
}