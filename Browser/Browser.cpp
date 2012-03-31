// Browser.cpp : DLL アプリケーション用にエクスポートされる関数を定義します。
//

#include "stdafx.h"
#include "Browser.h"

class CBrowser {
public:
	CBrowser(void) {
	}
};



BROWSER_API HWND GetHwnd() { return 0; }
BROWSER_API int create( HWND parent, void *xpiArgs) { return 0; }
BROWSER_API int close() { return 0; }
BROWSER_API int createex( HWND parent, void* xpiArgs, int size, DWORD flag) { return 0; }
BROWSER_API int navigate( char* url ) { return 0; }
BROWSER_API int refresh() { return 0; }
BROWSER_API int goBack() { return 0; }
BROWSER_API int goForward() { return 0; }
BROWSER_API int goHome() { return 0; }
BROWSER_API int locationURL(int len, char *outUrl) { return 0; }


