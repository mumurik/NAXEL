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