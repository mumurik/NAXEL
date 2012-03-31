// Browser.cpp : DLL アプリケーション用にエクスポートされる関数を定義します。
//

#include "stdafx.h"
#include "Browser.h"

class CBrowser {
public:
	CBrowser(void) {
	}

	int CreateWnd( HWND parent, int size)
	{
		HRESULT hRes;
		wndIE.Create(parent, CRect(0, 0, 100, 100), _T("Shell.Explorer.2"), WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN, WS_EX_CLIENTEDGE);
		hRes = wndIE.QueryControl(&pWebBrowser2);
		if(!SUCCEEDED(hRes))
			return 0;

		return 1;
	}

	int CreateXpi(void *xpiArgs, int size, DWORD flag)
	{
		xpiHandle = xpiCreatePane(wndIE, size, size, flag); 
		return (int)xpiHandle;
	}

	HWND GetWndHandle()
	{
		return wndIE;
	}

	IWebBrowser2* GetIWeb2()
	{
		return pWebBrowser2;
	}


private:
	CAxWindow	wndIE;
	CComPtr<IWebBrowser2> pWebBrowser2;
	XPIHANDLE xpiHandle;
};

class CApp
{
public:
	CApp() { browser = NULL; }
	CBrowser *browser;
	bool CreateBrowser()
	{
		if(!browser)
			browser = new CBrowser();
		return browser != NULL;
	}
	void DeleteBrowser()
	{
		if(browser)
			delete browser;
		browser = NULL;
	}
	IWebBrowser2* GetIWeb2()
	{
		return browser->GetIWeb2();
	}

};

class CApp gApp;

extern "C" { 

BROWSER_API HWND WINAPI GetHwnd()
{ 
	return gApp.browser->GetWndHandle(); 
}

BROWSER_API int WINAPI create( HWND parent, void *xpiArgs)
{ 
	CWindow wnd(parent);
	CRect r;
	wnd.GetClientRect(&r);
	int size = r.Width() /2;
	return createex(parent, xpiArgs, size, XPIS_LEFT);
}
BROWSER_API int WINAPI createex( HWND parent, void* xpiArgs, int size, DWORD flag)
{ 
	if (!xpiInit(xpiArgs))
		return 0;
	if(!gApp.CreateBrowser())
		return 0;

	if(!gApp.browser->CreateWnd(parent, size))
		return 0; 

	if(!gApp.browser->CreateXpi(xpiArgs, size, flag))
		return 0;

	return 1;
}
BROWSER_API int WINAPI close()
{
	gApp.DeleteBrowser();
	return 1;
}
BROWSER_API int WINAPI navigate( char* url )
{
	CComBSTR bUrl(url);
	CComVariant vt;

	HRESULT hRet = gApp.GetIWeb2()->Navigate(bUrl, &vt, &vt, &vt, &vt); 
	return SUCCEEDED(hRet);
}

BROWSER_API int WINAPI refresh() { return 0; }
BROWSER_API int WINAPI goBack() { return 0; }
BROWSER_API int WINAPI goForward() { return 0; }
BROWSER_API int WINAPI goHome() { return 0; }
BROWSER_API int WINAPI locationURL(int len, char *outUrl) { return 0; }

}