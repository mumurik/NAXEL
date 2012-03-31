#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             
#include <windows.h>


#define _ATL_CSTRING_EXPLICIT_CONSTRUCTORS      // 一部の CString コンストラクターは明示的です。

#include <atlbase.h>
extern CComModule _Module;
#include <atlstr.h>
#include <atlwin.h>
#include <atlhost.h>
#include <atltypes.h>

#include "xpi.h"
