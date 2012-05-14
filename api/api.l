;;; -*- Mode: Lisp; Package: WINAPI -*-
;;;  winapi.l
;;; Last updated: <2005/05/25 07:02:58 +0900>

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))

(in-package "winapi")
(provide "api")

;; mapiwin.h
(*define CREATE_NEW          1)
(*define CREATE_ALWAYS       2)
(*define OPEN_EXISTING       3)
(*define OPEN_ALWAYS         4)
(*define TRUNCATE_EXISTING   5)

(*define INVALID_HANDLE_VALUE		-1)

;; winnt.h
(*define GENERIC_READ                     #x80000000)
(*define GENERIC_WRITE                    #x40000000)
(*define GENERIC_EXECUTE                  #x20000000)
(*define GENERIC_ALL                      #x10000000)
(*define FILE_ATTRIBUTE_READONLY             #x00000001)
(*define FILE_ATTRIBUTE_HIDDEN               #x00000002)
(*define FILE_ATTRIBUTE_SYSTEM               #x00000004)
(*define FILE_ATTRIBUTE_DIRECTORY            #x00000010)
(*define FILE_ATTRIBUTE_ARCHIVE              #x00000020)
(*define FILE_ATTRIBUTE_DEVICE               #x00000040)
(*define FILE_ATTRIBUTE_NORMAL               #x00000080)
(*define FILE_ATTRIBUTE_TEMPORARY            #x00000100)
(*define FILE_ATTRIBUTE_SPARSE_FILE          #x00000200)
(*define FILE_ATTRIBUTE_REPARSE_POINT        #x00000400)
(*define FILE_ATTRIBUTE_COMPRESSED           #x00000800)
(*define FILE_ATTRIBUTE_OFFLINE              #x00001000)
(*define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  #x00002000)
(*define FILE_ATTRIBUTE_ENCRYPTED            #x00004000)

;; winbase.h
(*define-c-struct
 DCB
 (DWORD DCBlength)      #| sizeof(DCB)                     |#
 (DWORD BaudRate)       #| Baudrate at which running       |#
 (DWORD fBitFields)
 ;1 fBinary             #| Binary Mode (skip EOF check)    |#
 ;1 fParity             #| Enable parity checking          |#
 ;1 fOutxCtsFlow        #| CTS handshaking on output       |#
 ;1 fOutxDsrFlow        #| DSR handshaking on output       |#
 ;2 fDtrControl         #| DTR Flow control                |#
 ;1 fDsrSensitivity     #| DSR Sensitivity                 |#
 ;1 fTXContinueOnXoff   #| Continue TX when Xoff sent      |#
 ;1 fOutX               #| Enable output X-ON/X-OFF        |#
 ;1 fInX:               #| Enable input X-ON/X-OFF         |#
 ;1 fErrorChar          #| Enable Err Replacement          |#
 ;1 fNull               #| Enable Null stripping           |#
 ;2 fRtsControl         #| Rts Flow control                |#
 ;1 fAbortOnError       #| Abort all reads and writes on Error |#
 ;17 fDummy2            #| Reserved                        |#
 (WORD wReserved)       #| Not currently used              |#
 (WORD XonLim)          #| Transmit X-ON threshold         |#
 (WORD XoffLim)         #| Transmit X-OFF threshold        |#
 (BYTE ByteSize)        #| Number of bits/byte, 4-8        |#
 (BYTE Parity)          #| 0-4=None,Odd,Even,Mark,Space    |#
 (BYTE StopBits)        #| 0,1,2 = 1, 1.5, 2               |#
 (char XonChar)         #| Tx and Rx X-ON character        |#
 (char XoffChar)        #| Tx and Rx X-OFF character       |#
 (char ErrorChar)       #| Error replacement char          |#
 (char EofChar)         #| End of Input character          |#
 (char EvtChar)         #| Received Event character        |#
 (WORD wReserved1)      #| Fill for now.                   |#
 )
(*define-c-struct
 COMMTIMEOUTS
 (DWORD ReadIntervalTimeout)          #| Maximum time between read chars. |#
 (DWORD ReadTotalTimeoutMultiplier)   #| Multiplier of characters.        |#
 (DWORD ReadTotalTimeoutConstant)     #| Constant in milliseconds.        |#
 (DWORD WriteTotalTimeoutMultiplier)  #| Multiplier of characters.        |#
 (DWORD WriteTotalTimeoutConstant)    #| Constant in milliseconds.        |#
 )

(*define-c-struct
 COMMPROP
 (WORD wPacketLength)
 (WORD wPacketVersion)
 (DWORD dwServiceMask)
 (DWORD dwReserved1)
 (DWORD dwMaxTxQueue)
 (DWORD dwMaxRxQueue)
 (DWORD dwMaxBaud)
 (DWORD dwProvSubType)
 (DWORD dwProvCapabilities)
 (DWORD dwSettableParams)
 (DWORD dwSettableBaud)
 (WORD wSettableData)
 (WORD wSettableStopParity)
 (DWORD dwCurrentTxQueue)
 (DWORD dwCurrentRxQueue)
 (DWORD dwProvSpec1)
 (DWORD dwProvSpec2)
 (WCHAR wcProvChar 1)
 )

(*define-c-struct
  SECURITY_ATTRIBUTES
  (DWORD nLength)
  (LPVOID lpSecurityDescriptor)
  (BOOL bInheritHandle)
  )

(*define-dll-entry BOOL ReadFile (HANDLE LPVOID DWORD (DWORD *) LPVOID) "kernel32")
(*define-dll-entry BOOL WriteFile(HANDLE LPVOID DWORD (DWORD *) LPVOID) "kernel32")
(*define-dll-entry HANDLE CreateFile (LPCSTR DWORD DWORD (SECURITY_ATTRIBUTES *) DWORD DWORD HANDLE) "kernel32" "CreateFileA")
(*define-dll-entry BOOL CloseHandle  (HANDLE) "kernel32")
(*define-dll-entry UINT GetWindowsDirectory (LPSTR UINT) "kernel32" "GetWindowsDirectoryA")


(*define-dll-entry LONG GetLogicalDrives nil "kernel32")
(*define-dll-entry DWORD GetPrivateProfileString (LPCSTR LPCSTR LPCSTR LPSTR  DWORD LPCSTR)
  "kernel32" "GetPrivateProfileStringA")
(*define-dll-entry BOOL WritePrivateProfileString (LPCSTR LPCSTR LPCSTR LPCSTR)
  "kernel32" "WritePrivateProfileStringA")
(*define-dll-entry DWORD GetModuleFileName (HMODULE LPSTR DWORD)
  "kernel32" "GetModuleFileNameA")
;シリアルポート関連
(*define-dll-entry BOOL SetCommState(HANDLE (DCB *)) "kernel32")
(*define-dll-entry BOOL GetCommState(HANDLE (DCB *)) "kernel32")
(*define-dll-entry BOOL GetCommTimeouts(HANDLE (COMMTIMEOUTS *)) "kernel32")
(*define-dll-entry BOOL SetCommTimeouts(HANDLE (COMMTIMEOUTS *)) "kernel32")
(*define-dll-entry BOOL GetCommProperties(HANDLE (COMMPROP *)) "kernel32")
(*define-dll-entry BOOL EscapeCommFunction(HANDLE DWORD) "kernel32")

;; winuser.h

;#ifndef NOSCROLL
(*define-c-struct NMHDR
  (HWND hwndFrom)   ; コントロールのハンドル
  (UINT idFrom)     ; コントロールID
  (UINT code))      ; 通知コード

#|
 * Scroll Bar Constants
 |#
(*define SB_HORZ             0)
(*define SB_VERT             1)
(*define SB_CTL              2)
(*define SB_BOTH             3)

#|
 * Scroll Bar Commands
 |#
(*define SB_LINEUP           0)
(*define SB_LINELEFT         0)
(*define SB_LINEDOWN         1)
(*define SB_LINERIGHT        1)
(*define SB_PAGEUP           2)
(*define SB_PAGELEFT         2)
(*define SB_PAGEDOWN         3)
(*define SB_PAGERIGHT        3)
(*define SB_THUMBPOSITION    4)
(*define SB_THUMBTRACK       5)
(*define SB_TOP              6)
(*define SB_LEFT             6)
(*define SB_BOTTOM           7)
(*define SB_RIGHT            7)
(*define SB_ENDSCROLL        8)

;#endif /* !NOSCROLL */

;#ifndef NOSHOWWINDOW

#|
 * Old ShowWindow() Commands
 |#

(*define HIDE_WINDOW         0)
(*define SHOW_OPENWINDOW     1)
(*define SHOW_ICONWINDOW     2)
(*define SHOW_FULLSCREEN     3)
(*define SHOW_OPENNOACTIVATE 4)

#|
 * Identifiers for the WM_SHOWWINDOW message
 |#
(*define SW_PARENTCLOSING    1)
(*define SW_OTHERZOOM        2)
(*define SW_PARENTOPENING    3)
(*define SW_OTHERUNZOOM      4)

;#endif /* !NOSHOWWINDOW */

;#if(WINVER >= 0x0500)

#|
 * AnimateWindow() Commands
 |#
(*define AW_HOR_POSITIVE             #x00000001)
(*define AW_HOR_NEGATIVE             #x00000002)
(*define AW_VER_POSITIVE             #x00000004)
(*define AW_VER_NEGATIVE             #x00000008)
(*define AW_CENTER                   #x00000010)
(*define AW_HIDE                     #x00010000)
(*define AW_ACTIVATE                 #x00020000)
(*define AW_SLIDE                    #x00040000)
(*define AW_BLEND                    #x00080000)
;#endif /* WINVER >= 0x0500 */

#|
 * WM_KEYUP/DOWN/CHAR HIWORD(lParam) flags
 |#
(*define KF_EXTENDED       #x0100)
(*define KF_DLGMODE        #x0800)
(*define KF_MENUMODE       #x1000)
(*define KF_ALTDOWN        #x2000)
(*define KF_REPEAT         #x4000)
(*define KF_UP             #x8000)



#|
 * SetWindowsHook() codes
 |#
(*define WH_MIN              -1)
(*define WH_MSGFILTER        -1)
(*define WH_JOURNALRECORD    0)
(*define WH_JOURNALPLAYBACK  1)
(*define WH_KEYBOARD         2)
(*define WH_GETMESSAGE       3)
(*define WH_CALLWNDPROC      4)
(*define WH_CBT              5)
(*define WH_SYSMSGFILTER     6)
(*define WH_MOUSE            7)
;#if defined(_WIN32_WINDOWS)
(*define WH_HARDWARE         8)
;#endif
(*define WH_DEBUG            9)
(*define WH_SHELL           10)
(*define WH_FOREGROUNDIDLE  11)
;#if(WINVER >= 0x0400)
(*define WH_CALLWNDPROCRET  12)
;#endif /* WINVER >= 0x0400 */

;#if (_WIN32_WINNT >= 0x0400)
(*define WH_KEYBOARD_LL     13)
(*define WH_MOUSE_LL        14)
;#endif // (_WIN32_WINNT >= 0x0400)

;#if(WINVER >= 0x0400)
;#if (_WIN32_WINNT >= 0x0400)
(*define WH_MAX             14)
;#else
(*define WH_MAX             12)
;#endif // (_WIN32_WINNT >= 0x0400)
;#else
(*define WH_MAX             11)
;#endif

(*define WH_MINHOOK         WH_MIN)
(*define WH_MAXHOOK         WH_MAX)

#|
 * Hook Codes
 |#
(*define HC_ACTION           0)
(*define HC_GETNEXT          1)
(*define HC_SKIP             2)
(*define HC_NOREMOVE         3)
(*define HC_NOREM            HC_NOREMOVE)
(*define HC_SYSMODALON       4)
(*define HC_SYSMODALOFF      5)

#|
 * CBT Hook Codes
 |#
(*define HCBT_MOVESIZE       0)
(*define HCBT_MINMAX         1)
(*define HCBT_QS             2)
(*define HCBT_CREATEWND      3)
(*define HCBT_DESTROYWND     4)
(*define HCBT_ACTIVATE       5)
(*define HCBT_CLICKSKIPPED   6)
(*define HCBT_KEYSKIPPED     7)
(*define HCBT_SYSCOMMAND     8)
(*define HCBT_SETFOCUS       9)

#|
 * System Menu Command Values
 |#
(*define SC_SIZE         #xF000)
(*define SC_MOVE         #xF010)
(*define SC_MINIMIZE     #xF020)
(*define SC_MAXIMIZE     #xF030)
(*define SC_NEXTWINDOW   #xF040)
(*define SC_PREVWINDOW   #xF050)
(*define SC_CLOSE        #xF060)
(*define SC_VSCROLL      #xF070)
(*define SC_HSCROLL      #xF080)
(*define SC_MOUSEMENU    #xF090)
(*define SC_KEYMENU      #xF100)
(*define SC_ARRANGE      #xF110)
(*define SC_RESTORE      #xF120)
(*define SC_TASKLIST     #xF130)
(*define SC_SCREENSAVE   #xF140)
(*define SC_HOTKEY       #xF150)
;#if(WINVER >= 0x0400)
(*define SC_DEFAULT      #xF160)
(*define SC_MONITORPOWER #xF170)
(*define SC_CONTEXTHELP  #xF180)
(*define SC_SEPARATOR    #xF00F)
;#endif /* WINVER >= 0x0400 */

#|
 * Obsolete names
 |#
(*define SC_ICON         SC_MINIMIZE)
(*define SC_ZOOM         SC_MAXIMIZE)

#|
 * HCBT_CREATEWND parameters pointed to by lParam
 |#

(*define VK_LBUTTON #x01)
(*define VK_RBUTTON #x02)
(*define VK_CANCEL  #x03)
(*define VK_MBUTTON #x04)    #| NOT contiguous with L & RBUTTON |#

;#if(_WIN32_WINNT >= #x0500)
(*define VK_XBUTTON1 #x05)   #| NOT contiguous with L & RBUTTON |#
(*define VK_XBUTTON2 #x06)   #| NOT contiguous with L & RBUTTON |#
;#endif #| _WIN32_WINNT >= #x0500 |#

#|
 * #x07 : unassigned
 |#

(*define VK_BACK #x08)
(*define VK_TAB  #x09)

#|
 | #x0A - #x0B : reserved
 |#

(*define VK_CLEAR  #x0C)
(*define VK_RETURN #x0D)

(*define VK_SHIFT   #x10)
(*define VK_CONTROL #x11)
(*define VK_MENU    #x12)
(*define VK_PAUSE   #x13)
(*define VK_CAPITAL #x14)

(*define VK_KANA    #x15)
(*define VK_HANGEUL #x15)  #| old name - should be here for compatibility |#
(*define VK_HANGUL  #x15)
(*define VK_JUNJA   #x17)
(*define VK_FINAL   #x18)
(*define VK_HANJA   #x19)
(*define VK_KANJI   #x19)

(*define VK_ESCAPE  #x1B)

(*define VK_CONVERT    #x1C)
(*define VK_NONCONVERT #x1D)
(*define VK_ACCEPT     #x1E)
(*define VK_MODECHANGE #x1F)

(*define VK_SPACE    #x20)
(*define VK_PRIOR    #x21)
(*define VK_NEXT     #x22)
(*define VK_END      #x23)
(*define VK_HOME     #x24)
(*define VK_LEFT     #x25)
(*define VK_UP       #x26)
(*define VK_RIGHT    #x27)
(*define VK_DOWN     #x28)
(*define VK_SELECT   #x29)
(*define VK_PRINT    #x2A)
(*define VK_EXECUTE  #x2B)
(*define VK_SNAPSHOT #x2C)
(*define VK_INSERT   #x2D)
(*define VK_DELETE   #x2E)
(*define VK_HELP     #x2F)

#|
 | VK_0 - VK_9 are the same as ASCII '0' - '9' (#x30 - #x39)
 | #x40 : unassigned
 | VK_A - VK_Z are the same as ASCII 'A' - 'Z' (#x41 - #x5A)
 |#

(*define VK_0 #x30)
(*define VK_1 #x31)
(*define VK_2 #x32)
(*define VK_3 #x33)
(*define VK_4 #x34)
(*define VK_5 #x35)
(*define VK_6 #x36)
(*define VK_7 #x37)
(*define VK_8 #x38)
(*define VK_9 #x39)

(*define VK_A #x41)
(*define VK_B #x42)
(*define VK_C #x43)
(*define VK_D #x44)
(*define VK_E #x45)
(*define VK_F #x46)
(*define VK_G #x47)
(*define VK_H #x48)
(*define VK_I #x49)
(*define VK_J #x4a)
(*define VK_K #x4b)
(*define VK_L #x4c)
(*define VK_M #x4d)
(*define VK_N #x4e)
(*define VK_O #x4f)
(*define VK_P #x50)
(*define VK_Q #x51)
(*define VK_R #x52)
(*define VK_S #x53)
(*define VK_T #x54)
(*define VK_U #x55)
(*define VK_V #x56)
(*define VK_W #x57)
(*define VK_X #x58)
(*define VK_Y #x59)
(*define VK_Z #x5a)

(*define VK_LWIN #x5B)
(*define VK_RWIN #x5C)
(*define VK_APPS #x5D)

#|
 | #x5E : reserved
 |#

(*define VK_SLEEP #x5F)

(*define VK_NUMPAD0 #x60)
(*define VK_NUMPAD1 #x61)
(*define VK_NUMPAD2 #x62)
(*define VK_NUMPAD3 #x63)
(*define VK_NUMPAD4 #x64)
(*define VK_NUMPAD5 #x65)
(*define VK_NUMPAD6 #x66)
(*define VK_NUMPAD7 #x67)
(*define VK_NUMPAD8 #x68)
(*define VK_NUMPAD9 #x69)
(*define VK_MULTIPLY #x6A)
(*define VK_ADD #x6B)
(*define VK_SEPARATOR #x6C)
(*define VK_SUBTRACT #x6D)
(*define VK_DECIMAL #x6E)
(*define VK_DIVIDE #x6F)
(*define VK_F1 #x70)
(*define VK_F2 #x71)
(*define VK_F3 #x72)
(*define VK_F4 #x73)
(*define VK_F5 #x74)
(*define VK_F6 #x75)
(*define VK_F7 #x76)
(*define VK_F8 #x77)
(*define VK_F9 #x78)
(*define VK_F10 #x79)
(*define VK_F11 #x7A)
(*define VK_F12 #x7B)
(*define VK_F13 #x7C)
(*define VK_F14 #x7D)
(*define VK_F15 #x7E)
(*define VK_F16 #x7F)
(*define VK_F17 #x80)
(*define VK_F18 #x81)
(*define VK_F19 #x82)
(*define VK_F20 #x83)
(*define VK_F21 #x84)
(*define VK_F22 #x85)
(*define VK_F23 #x86)
(*define VK_F24 #x87)

#|
 | #x88 - #x8F : unassigned
 |#

(*define VK_NUMLOCK #x90)
(*define VK_SCROLL #x91)

#|
 | NEC PC-9800 kbd definitions
 |#
(*define VK_OEM_NEC_EQUAL #x92) ; '=' key on numpad

#|
 | Fujitsu/OASYS kbd definitions
 |#
(*define VK_OEM_FJ_JISHO #x92) ; 'Dictionary' key
(*define VK_OEM_FJ_MASSHOU #x93) ; 'Unregister word' key
(*define VK_OEM_FJ_TOUROKU #x94) ; 'Register word' key
(*define VK_OEM_FJ_LOYA #x95) ; 'Left OYAYUBI' key
(*define VK_OEM_FJ_ROYA #x96) ; 'Right OYAYUBI' key

#|
 | #x97 - #x9F : unassigned
 |#

#|
 | VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
 | Used only as parameters to GetAsyncKeyState() and GetKeyState().
 | No other API or message will distinguish left and right keys in this way.
 |#
(*define VK_LSHIFT #xA0)
(*define VK_RSHIFT #xA1)
(*define VK_LCONTROL #xA2)
(*define VK_RCONTROL #xA3)
(*define VK_LMENU #xA4)
(*define VK_RMENU #xA5)

;#if(_WIN32_WINNT >= #x0500)
(*define VK_BROWSER_BACK #xA6)
(*define VK_BROWSER_FORWARD #xA7)
(*define VK_BROWSER_REFRESH #xA8)
(*define VK_BROWSER_STOP #xA9)
(*define VK_BROWSER_SEARCH #xAA)
(*define VK_BROWSER_FAVORITES #xAB)
(*define VK_BROWSER_HOME #xAC)

(*define VK_VOLUME_MUTE #xAD)
(*define VK_VOLUME_DOWN #xAE)
(*define VK_VOLUME_UP #xAF)
(*define VK_MEDIA_NEXT_TRACK #xB0)
(*define VK_MEDIA_PREV_TRACK #xB1)
(*define VK_MEDIA_STOP #xB2)
(*define VK_MEDIA_PLAY_PAUSE #xB3)
(*define VK_LAUNCH_MAIL #xB4)
(*define VK_LAUNCH_MEDIA_SELECT #xB5)
(*define VK_LAUNCH_APP1 #xB6)
(*define VK_LAUNCH_APP2 #xB7)

;#endif #| _WIN32_WINNT >= #x0500 |#

#|
 | #xB8 - #xB9 : reserved
 |#

(*define VK_OEM_1 #xBA)     ; ';:' for US
(*define VK_OEM_PLUS #xBB)  ; '+' any country
(*define VK_OEM_COMMA #xBC) ; ',' any country
(*define VK_OEM_MINUS #xBD) ; '-' any country
(*define VK_OEM_PERIOD #xBE); '.' any country
(*define VK_OEM_2 #xBF)     ; '/?' for US
(*define VK_OEM_3 #xC0)     ; '`~' for US

#|
 | #xC1 - #xD7 : reserved
 |#

#|
 | #xD8 - #xDA : unassigned
 |#

(*define VK_OEM_4 #xDB) ;  '[{' for US
(*define VK_OEM_5 #xDC) ;  '\|' for US
(*define VK_OEM_6 #xDD) ;  ']}' for US
(*define VK_OEM_7 #xDE) ;  ''"' for US
(*define VK_OEM_8 #xDF)

#|
 | #xE0 : reserved
 |#

#|
 | Various extended or enhanced keyboards
 |#
(*define VK_OEM_AX #xE1)  ;  'AX' key on Japanese AX kbd
(*define VK_OEM_102 #xE2) ;  "<>" or "\|" on RT 102-key kbd.
(*define VK_ICO_HELP #xE3);  Help key on ICO
(*define VK_ICO_00 #xE4)  ;  00 key on ICO

;#if(WINVER >= #x0400)
(*define VK_PROCESSKEY #xE5)
;#endif #| WINVER >= #x0400 |#

(*define VK_ICO_CLEAR #xE6)


;#if(_WIN32_WINNT >= #x0500)
(*define VK_PACKET #xE7)
;#endif #| _WIN32_WINNT >= #x0500 |#

#|
 | #xE8 : unassigned
 |#

#|
 | Nokia/Ericsson definitions
 |#
(*define VK_OEM_RESET #xE9)
(*define VK_OEM_JUMP #xEA)
(*define VK_OEM_PA1 #xEB)
(*define VK_OEM_PA2 #xEC)
(*define VK_OEM_PA3 #xED)
(*define VK_OEM_WSCTRL #xEE)
(*define VK_OEM_CUSEL #xEF)
(*define VK_OEM_ATTN #xF0)
(*define VK_OEM_FINISH #xF1)
(*define VK_OEM_COPY #xF2)
(*define VK_OEM_AUTO #xF3)
(*define VK_OEM_ENLW #xF4)
(*define VK_OEM_BACKTAB #xF5)

(*define VK_ATTN #xF6)
(*define VK_CRSEL #xF7)
(*define VK_EXSEL #xF8)
(*define VK_EREOF #xF9)
(*define VK_PLAY #xFA)
(*define VK_ZOOM #xFB)
(*define VK_NONAME #xFC)
(*define VK_PA1 #xFD)
(*define VK_OEM_CLEAR #xFE)

#|
 | Window Messages
 |#

(*define WM_NULL                         #x0000)
(*define WM_CREATE                       #x0001)
(*define WM_DESTROY                      #x0002)
(*define WM_MOVE                         #x0003)
(*define WM_SIZE                         #x0005)

(*define WM_ACTIVATE                     #x0006)
#|
 | WM_ACTIVATE state values
 |#

(*define WM_SETFOCUS                     #x0007)
(*define WM_KILLFOCUS                    #x0008)
(*define WM_ENABLE                       #x000A)
(*define WM_SETREDRAW                    #x000B)
(*define WM_SETTEXT                      #x000C)
(*define WM_GETTEXT                      #x000D)
(*define WM_GETTEXTLENGTH                #x000E)
(*define WM_PAINT                        #x000F)
(*define WM_CLOSE                        #x0010)
;#ifndef _WIN32_WCE
(*define WM_QUERYENDSESSION              #x0011)
(*define WM_QUERYOPEN                    #x0013)
(*define WM_ENDSESSION                   #x0016)
;#endif
(*define WM_QUIT                         #x0012)
(*define WM_ERASEBKGND                   #x0014)
(*define WM_SYSCOLORCHANGE               #x0015)
(*define WM_SHOWWINDOW                   #x0018)
(*define WM_WININICHANGE                 #x001A)
;#if(WINVER >= #x0400)
(*define WM_SETTINGCHANGE                WM_WININICHANGE)
;#endif #| WINVER >= #x0400 |#


(*define WM_DEVMODECHANGE                #x001B)
(*define WM_ACTIVATEAPP                  #x001C)
(*define WM_FONTCHANGE                   #x001D)
(*define WM_TIMECHANGE                   #x001E)
(*define WM_CANCELMODE                   #x001F)
(*define WM_SETCURSOR                    #x0020)
(*define WM_MOUSEACTIVATE                #x0021)
(*define WM_CHILDACTIVATE                #x0022)
(*define WM_QUEUESYNC                    #x0023)

(*define WM_GETMINMAXINFO                #x0024)
#|
 | Struct pointed to by WM_GETMINMAXINFO lParam
 |#

(*define WM_PAINTICON                    #x0026)
(*define WM_ICONERASEBKGND               #x0027)
(*define WM_NEXTDLGCTL                   #x0028)
(*define WM_SPOOLERSTATUS                #x002A)
(*define WM_DRAWITEM                     #x002B)
(*define WM_MEASUREITEM                  #x002C)
(*define WM_DELETEITEM                   #x002D)
(*define WM_VKEYTOITEM                   #x002E)
(*define WM_CHARTOITEM                   #x002F)
(*define WM_SETFONT                      #x0030)
(*define WM_GETFONT                      #x0031)
(*define WM_SETHOTKEY                    #x0032)
(*define WM_GETHOTKEY                    #x0033)
(*define WM_QUERYDRAGICON                #x0037)
(*define WM_COMPAREITEM                  #x0039)
;#if(WINVER >= #x0500)
;#ifndef _WIN32_WCE
(*define WM_GETOBJECT                    #x003D)
;#endif
;#endif #| WINVER >= #x0500 |#
(*define WM_COMPACTING                   #x0041)
(*define WM_COMMNOTIFY                   #x0044  #| no longer suported |#)
(*define WM_WINDOWPOSCHANGING            #x0046)
(*define WM_WINDOWPOSCHANGED             #x0047)

(*define WM_POWER                        #x0048)
#|
 | wParam for WM_POWER window message and DRV_POWER driver notification
 |#
(*define PWR_OK              1)
(*define PWR_FAIL            -1)
(*define PWR_SUSPENDREQUEST  1)
(*define PWR_SUSPENDRESUME   2)
(*define PWR_CRITICALRESUME  3)

(*define WM_COPYDATA                     #x004A)
(*define WM_CANCELJOURNAL                #x004B)


(*define SW_HIDE             0)
(*define SW_SHOWNORMAL       1)
(*define SW_NORMAL           1)
(*define SW_SHOWMINIMIZED    2)
(*define SW_SHOWMAXIMIZED    3)
(*define SW_MAXIMIZE         3)
(*define SW_SHOWNOACTIVATE   4)
(*define SW_SHOW             5)
(*define SW_MINIMIZE         6)
(*define SW_SHOWMINNOACTIVE  7)
(*define SW_SHOWNA           8)
(*define SW_RESTORE          9)
(*define SW_SHOWDEFAULT      10)
(*define SW_FORCEMINIMIZE    11)
(*define SW_MAX              11)

#|
 * lParam of WM_COPYDATA message points to...
 |#
#|typedef struct tagCOPYDATASTRUCT {
    ULONG_PTR dwData;
    DWORD cbData;
    PVOID lpData;
} COPYDATASTRUCT, *PCOPYDATASTRUCT;
|#
;#if(WINVER >= #x0400)
#|
typedef struct tagMDINEXTMENU
{
    HMENU   hmenuIn;
    HMENU   hmenuNext;
    HWND    hwndNext;
} MDINEXTMENU, * PMDINEXTMENU, FAR * LPMDINEXTMENU;
#endif #| WINVER >= #x0400 |#
|#

;#if(WINVER >= #x0400)
(*define WM_NOTIFY                       #x004E)
(*define WM_INPUTLANGCHANGEREQUEST       #x0050)
(*define WM_INPUTLANGCHANGE              #x0051)
(*define WM_TCARD                        #x0052)
(*define WM_HELP                         #x0053)
(*define WM_USERCHANGED                  #x0054)
(*define WM_NOTIFYFORMAT                 #x0055)

(*define NFR_ANSI                             1)
(*define NFR_UNICODE                          2)
(*define NF_QUERY                             3)
(*define NF_REQUERY                           4)

(*define WM_CONTEXTMENU                  #x007B)
(*define WM_STYLECHANGING                #x007C)
(*define WM_STYLECHANGED                 #x007D)
(*define WM_DISPLAYCHANGE                #x007E)
(*define WM_GETICON                      #x007F)
(*define WM_SETICON                      #x0080)
;#endif #| WINVER >= #x0400 |#

(*define WM_NCCREATE                     #x0081)
(*define WM_NCDESTROY                    #x0082)
(*define WM_NCCALCSIZE                   #x0083)
(*define WM_NCHITTEST                    #x0084)
(*define WM_NCPAINT                      #x0085)
(*define WM_NCACTIVATE                   #x0086)
(*define WM_GETDLGCODE                   #x0087)
;#ifndef _WIN32_WCE
(*define WM_SYNCPAINT                    #x0088)
;#endif
(*define WM_NCMOUSEMOVE                  #x00A0)
(*define WM_NCLBUTTONDOWN                #x00A1)
(*define WM_NCLBUTTONUP                  #x00A2)
(*define WM_NCLBUTTONDBLCLK              #x00A3)
(*define WM_NCRBUTTONDOWN                #x00A4)
(*define WM_NCRBUTTONUP                  #x00A5)
(*define WM_NCRBUTTONDBLCLK              #x00A6)
(*define WM_NCMBUTTONDOWN                #x00A7)
(*define WM_NCMBUTTONUP                  #x00A8)
(*define WM_NCMBUTTONDBLCLK              #x00A9)



;#if(_WIN32_WINNT >= #x0500)
(*define WM_NCXBUTTONDOWN                #x00AB)
(*define WM_NCXBUTTONUP                  #x00AC)
(*define WM_NCXBUTTONDBLCLK              #x00AD)
;#endif #| _WIN32_WINNT >= #x0500 |#


;#if(_WIN32_WINNT >= #x0501)
(*define WM_INPUT                        #x00FF)
;#endif #| _WIN32_WINNT >= #x0501 |#

(*define WM_KEYFIRST                     #x0100)
(*define WM_KEYDOWN                      #x0100)
(*define WM_KEYUP                        #x0101)
(*define WM_CHAR                         #x0102)
(*define WM_DEADCHAR                     #x0103)
(*define WM_SYSKEYDOWN                   #x0104)
(*define WM_SYSKEYUP                     #x0105)
(*define WM_SYSCHAR                      #x0106)
(*define WM_SYSDEADCHAR                  #x0107)
;#if(_WIN32_WINNT >= #x0501)
(*define WM_UNICHAR                      #x0109)
(*define WM_KEYLAST                      #x0109)
(*define UNICODE_NOCHAR                  #xFFFF)
;#else
(*define WM_KEYLAST                      #x0108)
;#endif #| _WIN32_WINNT >= #x0501 |#

;#if(WINVER >= #x0400)
(*define WM_IME_STARTCOMPOSITION         #x010D)
(*define WM_IME_ENDCOMPOSITION           #x010E)
(*define WM_IME_COMPOSITION              #x010F)
(*define WM_IME_KEYLAST                  #x010F)
;#endif #| WINVER >= #x0400 |#

(*define WM_INITDIALOG                   #x0110)
(*define WM_COMMAND                      #x0111)
(*define WM_SYSCOMMAND                   #x0112)
(*define WM_TIMER                        #x0113)
(*define WM_HSCROLL                      #x0114)
(*define WM_VSCROLL                      #x0115)
(*define WM_INITMENU                     #x0116)
(*define WM_INITMENUPOPUP                #x0117)
(*define WM_MENUSELECT                   #x011F)
(*define WM_MENUCHAR                     #x0120)
(*define WM_ENTERIDLE                    #x0121)
;#if(WINVER >= #x0500)
;#ifndef _WIN32_WCE
(*define WM_MENURBUTTONUP                #x0122)
(*define WM_MENUDRAG                     #x0123)
(*define WM_MENUGETOBJECT                #x0124)
(*define WM_UNINITMENUPOPUP              #x0125)
(*define WM_MENUCOMMAND                  #x0126)

;#ifndef _WIN32_WCE
;#if(_WIN32_WINNT >= #x0500)
(*define WM_CHANGEUISTATE                #x0127)
(*define WM_UPDATEUISTATE                #x0128)
(*define WM_QUERYUISTATE                 #x0129)

#|
 | LOWORD(wParam) values in WM_*UISTATE*
 |#

(*define UIS_SET         1)
(*define UIS_CLEAR       2)
(*define UIS_INITIALIZE  3)
#|
 | HIWORD(wParam) values in WM_*UISTATE*
 |#

(*define UISF_HIDEFOCUS   #x1)
(*define UISF_HIDEACCEL   #x2)


(*define WM_CTLCOLORMSGBOX               #x0132)
(*define WM_CTLCOLOREDIT                 #x0133)
(*define WM_CTLCOLORLISTBOX              #x0134)
(*define WM_CTLCOLORBTN                  #x0135)
(*define WM_CTLCOLORDLG                  #x0136)
(*define WM_CTLCOLORSCROLLBAR            #x0137)
(*define WM_CTLCOLORSTATIC               #x0138)


(*define WM_MOUSEFIRST                   #x0200)
(*define WM_MOUSEMOVE                    #x0200)
(*define WM_LBUTTONDOWN                  #x0201)
(*define WM_LBUTTONUP                    #x0202)
(*define WM_LBUTTONDBLCLK                #x0203)
(*define WM_RBUTTONDOWN                  #x0204)
(*define WM_RBUTTONUP                    #x0205)
(*define WM_RBUTTONDBLCLK                #x0206)
(*define WM_MBUTTONDOWN                  #x0207)
(*define WM_MBUTTONUP                    #x0208)
(*define WM_MBUTTONDBLCLK                #x0209)
;#if (_WIN32_WINNT >= #x0400) || (_WIN32_WINDOWS > #x0400)
(*define WM_MOUSEWHEEL                   #x020A)
;#endif
;#if (_WIN32_WINNT >= #x0500)
(*define WM_XBUTTONDOWN                  #x020B)
(*define WM_XBUTTONUP                    #x020C)
(*define WM_XBUTTONDBLCLK                #x020D)
;#endif
;#if (_WIN32_WINNT >= #x0500)
(*define WM_MOUSELAST                    #x020D)
;#elif (_WIN32_WINNT >= #x0400) || (_WIN32_WINDOWS > #x0400)
(*define WM_MOUSELAST                    #x020A)
;#else
(*define WM_MOUSELAST                    #x0209)
;#endif #| (_WIN32_WINNT >= #x0500) |#


;#if(_WIN32_WINNT >= #x0400)
#| Value for rolling one detent |#
(*define WHEEL_DELTA                     120)
;(*define GET_WHEEL_DELTA_WPARAM (wParam)  ((short)HIWORD(wParam))

#| Setting to scroll one page for SPI_GET/SETWHEELSCROLLLINES |#
(*define WHEEL_PAGESCROLL                4294967295);平成15年02月10日(月)　(UINT_MAX)あってんのかなぁ
;#endif #| _WIN32_WINNT >= #x0400 |#

;#if(_WIN32_WINNT >= #x0500)
;(*define GET_KEYSTATE_WPARAM(wParam)     (LOWORD(wParam)))
;(*define GET_NCHITTEST_WPARAM(wParam)    ((short)LOWORD(wParam))
;(*define GET_XBUTTON_WPARAM(wParam)      (HIWORD(wParam))

#| XButton values are WORD flags |#
(*define XBUTTON1      #x0001)
(*define XBUTTON2      #x0002)
#| Were there to be an XBUTTON3, it's value would be #x0004 |#
;#endif #| _WIN32_WINNT >= #x0500 |#

(*define WM_PARENTNOTIFY                 #x0210)
(*define WM_ENTERMENULOOP                #x0211)
(*define WM_EXITMENULOOP                 #x0212)

;#if(WINVER >= #x0400)
(*define WM_NEXTMENU                     #x0213)
(*define WM_SIZING                       #x0214)
(*define WM_CAPTURECHANGED               #x0215)
(*define WM_MOVING                       #x0216)
;#endif #| WINVER >= #x0400 |#

;#if(WINVER >= #x0400)


(*define WM_POWERBROADCAST               #x0218)

;#ifndef _WIN32_WCE
(*define PBT_APMQUERYSUSPEND             #x0000)
(*define PBT_APMQUERYSTANDBY             #x0001)

(*define PBT_APMQUERYSUSPENDFAILED       #x0002)
(*define PBT_APMQUERYSTANDBYFAILED       #x0003)

(*define PBT_APMSUSPEND                  #x0004)
(*define PBT_APMSTANDBY                  #x0005)

(*define PBT_APMRESUMECRITICAL           #x0006)
(*define PBT_APMRESUMESUSPEND            #x0007)
(*define PBT_APMRESUMESTANDBY            #x0008)

(*define PBTF_APMRESUMEFROMFAILURE       #x00000001)

(*define PBT_APMBATTERYLOW               #x0009)
(*define PBT_APMPOWERSTATUSCHANGE        #x000A)

(*define PBT_APMOEMEVENT                 #x000B)
(*define PBT_APMRESUMEAUTOMATIC          #x0012)
;#endif

;#endif #| WINVER >= #x0400 |#

;#if(WINVER >= #x0400)
(*define WM_DEVICECHANGE                 #x0219)
;#endif #| WINVER >= #x0400 |#

(*define WM_MDICREATE                    #x0220)
(*define WM_MDIDESTROY                   #x0221)
(*define WM_MDIACTIVATE                  #x0222)
(*define WM_MDIRESTORE                   #x0223)
(*define WM_MDINEXT                      #x0224)
(*define WM_MDIMAXIMIZE                  #x0225)
(*define WM_MDITILE                      #x0226)
(*define WM_MDICASCADE                   #x0227)
(*define WM_MDIICONARRANGE               #x0228)
(*define WM_MDIGETACTIVE                 #x0229)


(*define WM_MDISETMENU                   #x0230)
(*define WM_ENTERSIZEMOVE                #x0231)
(*define WM_EXITSIZEMOVE                 #x0232)
(*define WM_DROPFILES                    #x0233)
(*define WM_MDIREFRESHMENU               #x0234)


;#if(WINVER >= #x0400)
(*define WM_IME_SETCONTEXT               #x0281)
(*define WM_IME_NOTIFY                   #x0282)
(*define WM_IME_CONTROL                  #x0283)
(*define WM_IME_COMPOSITIONFULL          #x0284)
(*define WM_IME_SELECT                   #x0285)
(*define WM_IME_CHAR                     #x0286)
;#endif #| WINVER >= #x0400 |#
;#if(WINVER >= #x0500)
(*define WM_IME_REQUEST                  #x0288)
;#endif #| WINVER >= #x0500 |#
;#if(WINVER >= #x0400)
(*define WM_IME_KEYDOWN                  #x0290)
(*define WM_IME_KEYUP                    #x0291)
;#endif #| WINVER >= #x0400 |#

;#if((_WIN32_WINNT >= #x0400) || (WINVER >= #x0500))
(*define WM_MOUSEHOVER                   #x02A1)
(*define WM_MOUSELEAVE                   #x02A3)
;#endif
;#if(WINVER >= #x0500)
(*define WM_NCMOUSEHOVER                 #x02A0)
(*define WM_NCMOUSELEAVE                 #x02A2)
;#endif #| WINVER >= #x0500 |#

(*define WM_CUT                          #x0300)
(*define WM_COPY                         #x0301)
(*define WM_PASTE                        #x0302)
(*define WM_CLEAR                        #x0303)
(*define WM_UNDO                         #x0304)
(*define WM_RENDERFORMAT                 #x0305)
(*define WM_RENDERALLFORMATS             #x0306)
(*define WM_DESTROYCLIPBOARD             #x0307)
(*define WM_DRAWCLIPBOARD                #x0308)
(*define WM_PAINTCLIPBOARD               #x0309)
(*define WM_VSCROLLCLIPBOARD             #x030A)
(*define WM_SIZECLIPBOARD                #x030B)
(*define WM_ASKCBFORMATNAME              #x030C)
(*define WM_CHANGECBCHAIN                #x030D)
(*define WM_HSCROLLCLIPBOARD             #x030E)
(*define WM_QUERYNEWPALETTE              #x030F)
(*define WM_PALETTEISCHANGING            #x0310)
(*define WM_PALETTECHANGED               #x0311)
(*define WM_HOTKEY                       #x0312)

;#if(WINVER >= #x0400)
(*define WM_PRINT                        #x0317)
(*define WM_PRINTCLIENT                  #x0318)
;#endif #| WINVER >= #x0400 |#

;#if(_WIN32_WINNT >= #x0500)
(*define WM_APPCOMMAND                   #x0319)
;#endif #| _WIN32_WINNT >= #x0500 |#

;#if(WINVER >= #x0400)

(*define WM_HANDHELDFIRST                #x0358)
(*define WM_HANDHELDLAST                 #x035F)

(*define WM_AFXFIRST                     #x0360)
(*define WM_AFXLAST                      #x037F)
;#endif #| WINVER >= #x0400 |#

(*define WM_PENWINFIRST                  #x0380)
(*define WM_PENWINLAST                   #x038F)


;#if(WINVER >= #x0400)
(*define WM_APP                          #x8000)
;#endif #| WINVER >= #x0400 |#


#|
 * NOTE: All Message Numbers below #x0400 are RESERVED.
 *
 * Private Window Messages Start Here:
 |#
(*define WM_USER                         #x0400)

;#if(WINVER >= #x0400)

#|  wParam for WM_SIZING message  |#
(*define WMSZ_LEFT           1)
(*define WMSZ_RIGHT          2)
(*define WMSZ_TOP            3)
(*define WMSZ_TOPLEFT        4)
(*define WMSZ_TOPRIGHT       5)
(*define WMSZ_BOTTOM         6)
(*define WMSZ_BOTTOMLEFT     7)
(*define WMSZ_BOTTOMRIGHT    8)
;#endif #| WINVER >= #x0400 |#

;#ifndef NONCMESSAGES

#|
 * WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes
 |#
(*define HTERROR             -2)
(*define HTTRANSPARENT       -1)
(*define HTNOWHERE           0)
(*define HTCLIENT            1)
(*define HTCAPTION           2)
(*define HTSYSMENU           3)
(*define HTGROWBOX           4)
(*define HTSIZE              HTGROWBOX)
(*define HTMENU              5)
(*define HTHSCROLL           6)
(*define HTVSCROLL           7)
(*define HTMINBUTTON         8)
(*define HTMAXBUTTON         9)
(*define HTLEFT              10)
(*define HTRIGHT             11)
(*define HTTOP               12)
(*define HTTOPLEFT           13)
(*define HTTOPRIGHT          14)
(*define HTBOTTOM            15)
(*define HTBOTTOMLEFT        16)
(*define HTBOTTOMRIGHT       17)
(*define HTBORDER            18)
(*define HTREDUCE            HTMINBUTTON)
(*define HTZOOM              HTMAXBUTTON)
(*define HTSIZEFIRST         HTLEFT)
(*define HTSIZELAST          HTBOTTOMRIGHT)
;#if(WINVER >= #x0400)
(*define HTOBJECT            19)
(*define HTCLOSE             20)
(*define HTHELP              21)
;#endif #| WINVER >= #x0400 |#

#|
 * SendMessageTimeout values
 |#
(*define SMTO_NORMAL         #x0000)
(*define SMTO_BLOCK          #x0001)
(*define SMTO_ABORTIFHUNG    #x0002)
;#if(WINVER >= #x0500)
(*define SMTO_NOTIMEOUTIFNOTHUNG #x0008)
;#endif #| WINVER >= #x0500 |#
;#endif #| !NONCMESSAGES |#

#|
 * WM_MOUSEACTIVATE Return Codes
 |#
(*define MA_ACTIVATE         1)
(*define MA_ACTIVATEANDEAT   2)
(*define MA_NOACTIVATE       3)
(*define MA_NOACTIVATEANDEAT 4)


(*define IMAGE_BITMAP        0)
(*define IMAGE_ICON          1)
(*define IMAGE_CURSOR        2)
;#if(WINVER >= #x0400)
(*define IMAGE_ENHMETAFILE   3)

(*define LR_DEFAULTCOLOR     #x0000)
(*define LR_MONOCHROME       #x0001)
(*define LR_COLOR            #x0002)
(*define LR_COPYRETURNORG    #x0004)
(*define LR_COPYDELETEORG    #x0008)
(*define LR_LOADFROMFILE     #x0010)
(*define LR_LOADTRANSPARENT  #x0020)
(*define LR_DEFAULTSIZE      #x0040)
(*define LR_VGACOLOR         #x0080)
(*define LR_LOADMAP3DCOLORS  #x1000)
(*define LR_CREATEDIBSECTION #x2000)
(*define LR_COPYFROMRESOURCE #x4000)
(*define LR_SHARED           #x8000)

(*define ICON_SMALL          0)
(*define ICON_BIG            1)
(*define ICON_SMALL2         2)

(*define-dll-entry BOOL SetWindowPos (HWND HWND int int int int UINT) "user32")
(*define-dll-entry c:short GetKeyState (c:int) "user32")
(*define-dll-entry LONG GetWindowLong (HWND c:int) 
  "user32" "GetWindowLongA") 
(*define-dll-entry LONG SetWindowLong (HWND c:int LONG)
  "user32" "SetWindowLongA") 
(*define-dll-entry LONG 
  SetLayeredWindowAttributes (HWND DWORD BYTE DWORD) "user32")
(*define-dll-entry HWND 
  FindWindow (LPCSTR LPCSTR) "user32" "FindWindowA")
(*define-dll-entry HWND
  FindWindowEx (HWND HWND LPCSTR LPCSTR) "user32" "FindWindowExA")

(*define-dll-entry int
  GetClassName (HWND LPSTR int) "user32" "GetClassNameA")
(*define-dll-entry UINT
  GetWindowModuleFileName (HWND LPSTR UINT) "user32" "GetWindowModuleFileNameA")
(*define-dll-entry BOOL
  EnableWindow (HWND BOOL) "user32")
(*define-dll-entry BOOL
  IsWindowEnabled (HWND) "user32")
(*define-dll-entry BOOL
  UpdateWindow (HWND) "user32")
(*define-dll-entry HWND
  SetActiveWindow (HWND) "user32")
(*define-dll-entry HWND
  GetForegroundWindow () "user32")
(*define-dll-entry BOOL
  PaintDesktop (HDC) "user32")
(*define-dll-entry BOOL
  SetWindowText (HWND LPCSTR) "user32" "SetWindowTextA")
(*define-dll-entry int
  GetWindowTextLength (HWND) "user32" "GetWindowTextLengthA")
(*define-dll-entry BOOL
  MessageBeep(UINT) "user32")
(*define-dll-entry int
  ShowCursor (BOOL) "user32")
(*define-dll-entry BOOL
  SetCursorPos (int int) "user32")
(*define-dll-entry BOOL
  SetCaretPos (int int) "user32")
(*define-dll-entry DWORD
  GetSysColor (int) "user32")
;#define ExitWindows(dwReserved, Code) ExitWindowsEx(EWX_LOGOFF, 0xFFFFFFFF)
(*define-dll-entry BOOL
  ShowOwnedPopups (HWND BOOL) "user32")
(*define-dll-entry BOOL
  OpenIcon (HWND) "user32")
(*define-dll-entry BOOL
  CloseWindow(HWND) "user32")
(*define-dll-entry BOOL
  MoveWindow(HWND int int int int BOOL) "user32")
(*define-dll-entry HWND
  WindowFromPoint(int int) "user32")
(*define-dll-entry int
  GetSystemMetrics(int) "user32")
(*define-dll-entry BOOL
  GetKeyboardState ((BYTE *)) "user32")
(*define-dll-entry BOOL
  SetKeyboardState((BYTE *)) "user32")
(*define-dll-entry void
  keybd_event(BYTE BYTE DWORD LONG) "user32")


(*define ENDSESSION_LOGOFF    #x80000000)

(*define EWX_LOGOFF          0)
(*define EWX_SHUTDOWN        #x00000001)
(*define EWX_REBOOT          #x00000002)
(*define EWX_FORCE           #x00000004)
(*define EWX_POWEROFF        #x00000008)
(*define EWX_FORCEIFHUNG     #x00000010)

(*define-c-macro ExitWindows(dwReserved Code)
  `(ExitWindowsEx EWX_LOGOFF #xFFFFFFFF))

(*define-dll-entry BOOL
  ExitWindowsEx (UINT DWORD) "user32")



(*define LWA_COLORKEY            #x00000001)
(*define LWA_ALPHA               #x00000002)
(*define-dll-entry HANDLE
  LoadImage (HINSTANCE LPCSTR UINT int int UINT)  "user32" "LoadImageA")

(*define-dll-entry int
  GetWindowText (HWND LPSTR int) "user32" "GetWindowTextA")

#|
 | Window field offsets for GetWindowLong()
 |#

(*define GWL_WNDPROC -4)
(*define GWL_HINSTANCE -6)
(*define GWL_HWNDPARENT -8)
(*define GWL_STYLE -16)
(*define GWL_EXSTYLE -20)
(*define GWL_USERDATA -21)
(*define GWL_ID -12)

;#ifdef _WIN64
;#undef GWL_WNDPROC
;#undef GWL_HINSTANCE
;#undef GWL_HWNDPARENT
;#undef GWL_USERDATA
;#endif #| _WIN64 |#

(*define GWLP_WNDPROC -4)
(*define GWLP_HINSTANCE -6)
(*define GWLP_HWNDPARENT -8)
(*define GWLP_USERDATA -21)
(*define GWLP_ID -12)


#|
 | SetWindowPos Flags
 |#
(*define SWP_NOSIZE          #x0001)
(*define SWP_NOMOVE          #x0002)
(*define SWP_NOZORDER        #x0004)
(*define SWP_NOREDRAW        #x0008)
(*define SWP_NOACTIVATE      #x0010)
(*define SWP_FRAMECHANGED    #x0020)  #| The frame changed: send WM_NCCALCSIZE |#
(*define SWP_SHOWWINDOW      #x0040)
(*define SWP_HIDEWINDOW      #x0080)
(*define SWP_NOCOPYBITS      #x0100)
(*define SWP_NOOWNERZORDER   #x0200)  #| Don't do owner Z ordering |#
(*define SWP_NOSENDCHANGING  #x0400)  #| Don't send WM_WINDOWPOSCHANGING |#

(*define SWP_DRAWFRAME       SWP_FRAMECHANGED)
(*define SWP_NOREPOSITION    SWP_NOOWNERZORDER)

(*define SWP_DEFERERASE      #x2000)
(*define SWP_ASYNCWINDOWPOS  #x4000)


(*define HWND_TOP        0)
(*define HWND_BOTTOM     1)
(*define HWND_TOPMOST   -1)
(*define HWND_NOTOPMOST -2)

#|
 | Window Styles
 |#
(*define WS_OVERLAPPED       #x00000000)
(*define WS_POPUP            #x80000000)
(*define WS_CHILD            #x40000000)
(*define WS_MINIMIZE         #x20000000)
(*define WS_VISIBLE          #x10000000)
(*define WS_DISABLED         #x08000000)
(*define WS_CLIPSIBLINGS     #x04000000)
(*define WS_CLIPCHILDREN     #x02000000)
(*define WS_MAXIMIZE         #x01000000)
(*define WS_CAPTION          #x00C00000)     #| WS_BORDER | WS_DLGFRAME  |#
(*define WS_BORDER           #x00800000)
(*define WS_DLGFRAME         #x00400000)
(*define WS_VSCROLL          #x00200000)
(*define WS_HSCROLL          #x00100000)
(*define WS_SYSMENU          #x00080000)
(*define WS_THICKFRAME       #x00040000)
(*define WS_GROUP            #x00020000)
(*define WS_TABSTOP          #x00010000)

(*define WS_MINIMIZEBOX      #x00020000)
(*define WS_MAXIMIZEBOX      #x00010000)


(*define WS_TILED            WS_OVERLAPPED)
(*define WS_ICONIC           WS_MINIMIZE)
(*define WS_SIZEBOX          WS_THICKFRAME)
(*define WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW)

#|
 | Common Window Styles
 |#
(*define WS_OVERLAPPEDWINDOW #x00CF0000)
;(WS_OVERLAPPED WS_CAPTION WS_SYSMENU WS_THICKFRAME WS_MINIMIZEBOX WS_MAXIMIZEBOX)

(*define WS_POPUPWINDOW #x80880000)
;(WS_POPUP WS_BORDER WS_SYSMENU)

(*define WS_CHILDWINDOW WS_CHILD)
;(WS_CHILD)

#|
 | Extended Window Styles
 |#
(*define WS_EX_DLGMODALFRAME     #x00000001)
(*define WS_EX_NOPARENTNOTIFY    #x00000004)
(*define WS_EX_TOPMOST           #x00000008)
(*define WS_EX_ACCEPTFILES       #x00000010)
(*define WS_EX_TRANSPARENT       #x00000020)

(*define WS_EX_MDICHILD          #x00000040)
(*define WS_EX_TOOLWINDOW        #x00000080)
(*define WS_EX_WINDOWEDGE        #x00000100)
(*define WS_EX_CLIENTEDGE        #x00000200)
(*define WS_EX_CONTEXTHELP       #x00000400)

(*define WS_EX_RIGHT             #x00001000)
(*define WS_EX_LEFT              #x00000000)
(*define WS_EX_RTLREADING        #x00002000)
(*define WS_EX_LTRREADING        #x00000000)
(*define WS_EX_LEFTSCROLLBAR     #x00004000)
(*define WS_EX_RIGHTSCROLLBAR    #x00000000)

(*define WS_EX_CONTROLPARENT     #x00010000)
(*define WS_EX_STATICEDGE        #x00020000)
(*define WS_EX_APPWINDOW         #x00040000)


(*define WS_EX_OVERLAPPEDWINDOW  #x00000300)
;(WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
(*define WS_EX_PALETTEWINDOW     #x00000188)
;(WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)


(*define WS_EX_LAYERED           #x00080000)


(*define WS_EX_NOINHERITLAYOUT   #x00100000) ; Disable inheritence of mirroring by children
(*define WS_EX_LAYOUTRTL         #x00400000) ; Right to left mirroring

(*define WS_EX_NOACTIVATE        #x08000000)


#|
 | Class styles
 |#
(*define CS_VREDRAW          #x0001)
(*define CS_HREDRAW          #x0002)
(*define CS_DBLCLKS          #x0008)
(*define CS_OWNDC            #x0020)
(*define CS_CLASSDC          #x0040)
(*define CS_PARENTDC         #x0080)
(*define CS_NOCLOSE          #x0200)
(*define CS_SAVEBITS         #x0800)
(*define CS_BYTEALIGNCLIENT  #x1000)
(*define CS_BYTEALIGNWINDOW  #x2000)
(*define CS_GLOBALCLASS      #x4000)

(*define CS_IME              #x00010000)

#| WM_PRINT flags |#
(*define PRF_CHECKVISIBLE    #x00000001)
(*define PRF_NONCLIENT       #x00000002)
(*define PRF_CLIENT          #x00000004)
(*define PRF_ERASEBKGND      #x00000008)
(*define PRF_CHILDREN        #x00000010)
(*define PRF_OWNED           #x00000020)

#| 3D border styles |#
(*define BDR_RAISEDOUTER #x0001)
(*define BDR_SUNKENOUTER #x0002)
(*define BDR_RAISEDINNER #x0004)
(*define BDR_SUNKENINNER #x0008)

(*define BDR_OUTER       #x0003);(BDR_RAISEDOUTER | BDR_SUNKENOUTER)
(*define BDR_INNER       #x000C);(BDR_RAISEDINNER | BDR_SUNKENINNER)
(*define BDR_RAISED      #x0005);(BDR_RAISEDOUTER | BDR_RAISEDINNER)
(*define BDR_SUNKEN      #x000A);(BDR_SUNKENOUTER | BDR_SUNKENINNER)


(*define EDGE_RAISED     #x0005);(BDR_RAISEDOUTER | BDR_RAISEDINNER)
(*define EDGE_SUNKEN     #x000A);(BDR_SUNKENOUTER | BDR_SUNKENINNER)
(*define EDGE_ETCHED     #x0006);(BDR_SUNKENOUTER | BDR_RAISEDINNER)
(*define EDGE_BUMP       #x0009);(BDR_RAISEDOUTER | BDR_SUNKENINNER)

#| Border flags |#
(*define BF_LEFT         #x0001)
(*define BF_TOP          #x0002)
(*define BF_RIGHT        #x0004)
(*define BF_BOTTOM       #x0008)

(*define BF_TOPLEFT      #x0003);(BF_TOP | BF_LEFT)
(*define BF_TOPRIGHT     #x0006);(BF_TOP | BF_RIGHT)
(*define BF_BOTTOMLEFT   #x0009);(BF_BOTTOM | BF_LEFT)
(*define BF_BOTTOMRIGHT  #x000C);(BF_BOTTOM | BF_RIGHT)
(*define BF_RECT         #x000F);(BF_LEFT | BF_TOP | BF_RIGHT | BF_BOTTOM)

(*define BF_DIAGONAL     #x0010)

; For diagonal lines, the BF_RECT flags specify the end point of the
; vector bounded by the rectangle parameter.
(*define BF_DIAGONAL_ENDTOPLEFT      #x0013);(BF_DIAGONAL | BF_TOP | BF_LEFT)
(*define BF_DIAGONAL_ENDTOPRIGHT     #x0016);(BF_DIAGONAL | BF_TOP | BF_RIGHT)
(*define BF_DIAGONAL_ENDBOTTOMLEFT   #x0019);(BF_DIAGONAL | BF_BOTTOM | BF_LEFT)
(*define BF_DIAGONAL_ENDBOTTOMRIGHT  #x001C);(BF_DIAGONAL | BF_BOTTOM | BF_RIGHT)


(*define BF_MIDDLE       #x0800)  #| Fill in the middle |#
(*define BF_SOFT         #x1000)  #| For softer buttons |#
(*define BF_ADJUST       #x2000)  #| Calculate the space left over |#
(*define BF_FLAT         #x4000)  #| For flat rather than 3D borders |#
(*define BF_MONO         #x8000)  #| For monochrome borders |#


#|
 | WH_MSGFILTER Filter Proc Codes
 |#
(*define MSGF_DIALOGBOX      0)
(*define MSGF_MESSAGEBOX     1)
(*define MSGF_MENU           2)
(*define MSGF_SCROLLBAR      5)
(*define MSGF_NEXTWINDOW     6)
(*define MSGF_MAX            8)                       ; unused
(*define MSGF_USER           4096)

#|
 | Shell support
 |#
(*define HSHELL_WINDOWCREATED        1)
(*define HSHELL_WINDOWDESTROYED      2)
(*define HSHELL_ACTIVATESHELLWINDOW  3)

(*define HSHELL_WINDOWACTIVATED      4)
(*define HSHELL_GETMINRECT           5)
(*define HSHELL_REDRAW               6)
(*define HSHELL_TASKMAN              7)
(*define HSHELL_LANGUAGE             8)
(*define HSHELL_ACCESSIBILITYSTATE   11)
(*define HSHELL_APPCOMMAND           12)
#| wparam for HSHELL_ACCESSIBILITYSTATE |#
(*define    ACCESS_STICKYKEYS            #x0001)
(*define    ACCESS_FILTERKEYS            #x0002)
(*define    ACCESS_MOUSEKEYS             #x0003)

#| cmd for HSHELL_APPCOMMAND and WM_APPCOMMAND |#
(*define APPCOMMAND_BROWSER_BACKWARD       1)
(*define APPCOMMAND_BROWSER_FORWARD        2)
(*define APPCOMMAND_BROWSER_REFRESH        3)
(*define APPCOMMAND_BROWSER_STOP           4)
(*define APPCOMMAND_BROWSER_SEARCH         5)
(*define APPCOMMAND_BROWSER_FAVORITES      6)
(*define APPCOMMAND_BROWSER_HOME           7)
(*define APPCOMMAND_VOLUME_MUTE            8)
(*define APPCOMMAND_VOLUME_DOWN            9)
(*define APPCOMMAND_VOLUME_UP              10)
(*define APPCOMMAND_MEDIA_NEXTTRACK        11)
(*define APPCOMMAND_MEDIA_PREVIOUSTRACK    12)
(*define APPCOMMAND_MEDIA_STOP             13)
(*define APPCOMMAND_MEDIA_PLAY_PAUSE       14)
(*define APPCOMMAND_LAUNCH_MAIL            15)
(*define APPCOMMAND_LAUNCH_MEDIA_SELECT    16)
(*define APPCOMMAND_LAUNCH_APP1            17)
(*define APPCOMMAND_LAUNCH_APP2            18)
(*define APPCOMMAND_BASS_DOWN              19)
(*define APPCOMMAND_BASS_BOOST             20)
(*define APPCOMMAND_BASS_UP                21)
(*define APPCOMMAND_TREBLE_DOWN            22)
(*define APPCOMMAND_TREBLE_UP              23)

(*define FAPPCOMMAND_MOUSE #x8000)
(*define FAPPCOMMAND_KEY   0)
(*define FAPPCOMMAND_OEM   #x1000)
(*define FAPPCOMMAND_MASK  #xF000)

#|
 * GetSystemMetrics() codes
 |#

(*define SM_CXSCREEN             0)
(*define SM_CYSCREEN             1)
(*define SM_CXVSCROLL            2)
(*define SM_CYHSCROLL            3)
(*define SM_CYCAPTION            4)
(*define SM_CXBORDER             5)
(*define SM_CYBORDER             6)
(*define SM_CXDLGFRAME           7)
(*define SM_CYDLGFRAME           8)
(*define SM_CYVTHUMB             9)
(*define SM_CXHTHUMB             10)
(*define SM_CXICON               11)
(*define SM_CYICON               12)
(*define SM_CXCURSOR             13)
(*define SM_CYCURSOR             14)
(*define SM_CYMENU               15)
(*define SM_CXFULLSCREEN         16)
(*define SM_CYFULLSCREEN         17)
(*define SM_CYKANJIWINDOW        18)
(*define SM_MOUSEPRESENT         19)
(*define SM_CYVSCROLL            20)
(*define SM_CXHSCROLL            21)
(*define SM_DEBUG                22)
(*define SM_SWAPBUTTON           23)
(*define SM_RESERVED1            24)
(*define SM_RESERVED2            25)
(*define SM_RESERVED3            26)
(*define SM_RESERVED4            27)
(*define SM_CXMIN                28)
(*define SM_CYMIN                29)
(*define SM_CXSIZE               30)
(*define SM_CYSIZE               31)
(*define SM_CXFRAME              32)
(*define SM_CYFRAME              33)
(*define SM_CXMINTRACK           34)
(*define SM_CYMINTRACK           35)
(*define SM_CXDOUBLECLK          36)
(*define SM_CYDOUBLECLK          37)
(*define SM_CXICONSPACING        38)
(*define SM_CYICONSPACING        39)
(*define SM_MENUDROPALIGNMENT    40)
(*define SM_PENWINDOWS           41)
(*define SM_DBCSENABLED          42)
(*define SM_CMOUSEBUTTONS        43)

;#if(WINVER >= 0x0400)
(*define SM_CXFIXEDFRAME           SM_CXDLGFRAME)  #| ;win40 name change |#
(*define SM_CYFIXEDFRAME           SM_CYDLGFRAME)  #| ;win40 name change |#
(*define SM_CXSIZEFRAME            SM_CXFRAME)     #| ;win40 name change |#
(*define SM_CYSIZEFRAME            SM_CYFRAME)     #| ;win40 name change |#

(*define SM_SECURE               44)
(*define SM_CXEDGE               45)
(*define SM_CYEDGE               46)
(*define SM_CXMINSPACING         47)
(*define SM_CYMINSPACING         48)
(*define SM_CXSMICON             49)
(*define SM_CYSMICON             50)
(*define SM_CYSMCAPTION          51)
(*define SM_CXSMSIZE             52)
(*define SM_CYSMSIZE             53)
(*define SM_CXMENUSIZE           54)
(*define SM_CYMENUSIZE           55)
(*define SM_ARRANGE              56)
(*define SM_CXMINIMIZED          57)
(*define SM_CYMINIMIZED          58)
(*define SM_CXMAXTRACK           59)
(*define SM_CYMAXTRACK           60)
(*define SM_CXMAXIMIZED          61)
(*define SM_CYMAXIMIZED          62)
(*define SM_NETWORK              63)
(*define SM_CLEANBOOT            67)
(*define SM_CXDRAG               68)
(*define SM_CYDRAG               69)
;#endif /* WINVER >= 0x0400 */
(*define SM_SHOWSOUNDS           70)
;#if(WINVER >= 0x0400)
(*define SM_CXMENUCHECK          71)   #| Use instead of GetMenuCheckMarkDimensions()! |#
(*define SM_CYMENUCHECK          72)
(*define SM_SLOWMACHINE          73)
(*define SM_MIDEASTENABLED       74)
;#endif /* WINVER >= 0x0400 */

;#if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
(*define SM_MOUSEWHEELPRESENT    75)
;#endif
;#if(WINVER >= 0x0500)
(*define SM_XVIRTUALSCREEN       76)
(*define SM_YVIRTUALSCREEN       77)
(*define SM_CXVIRTUALSCREEN      78)
(*define SM_CYVIRTUALSCREEN      79)
(*define SM_CMONITORS            80)
(*define SM_SAMEDISPLAYFORMAT    81)
;#endif /* WINVER >= 0x0500 */
;#if(_WIN32_WINNT >= 0x0500)
(*define SM_IMMENABLED           82)
;#endif /* _WIN32_WINNT >= 0x0500 */

;#if (WINVER < 0x0500) && (!defined(_WIN32_WINNT) || (_WIN32_WINNT < 0x0400))
;(*define SM_CMETRICS             76)
;#else
(*define SM_CMETRICS             83)
;#endif

;#if(WINVER >= 0x0500)
(*define SM_REMOTESESSION        #x1000)
;#endif /* WINVER >= 0x0500 */

;#define GET_APPCOMMAND_LPARAM(lParam) ((short)(HIWORD(lParam) & ~FAPPCOMMAND_MASK))
;#define GET_DEVICE_LPARAM(lParam)     ((WORD)(HIWORD(lParam) & FAPPCOMMAND_MASK))
;#define GET_MOUSEORKEY_LPARAM         GET_DEVICE_LPARAM
;#define GET_FLAGS_LPARAM(lParam)      (LOWORD(lParam))
;#define GET_KEYSTATE_LPARAM(lParam)   GET_FLAGS_LPARAM(lParam)

;かめーさんの書いていたのっぽいの。
;ref[xyzzy:04578]
(*define-dll-entry HWND GetActiveWindow () "user32")
(*define-dll-entry BOOL BringWindowToTop (HWND) "user32")
;ref[xyzzy:03275]
(*define-dll-entry c:int GetWindowRect (HWND (RECT *)) "user32")

;From OLT
(*define-dll-entry HWND SetFocus (HWND) "user32")
(*define-dll-entry int IsZoomed (HWND) "user32")

;From ttray
(*define-dll-entry BOOL IsIconic (HWND) "user32")
(*define-dll-entry BOOL ShowWindow (HWND c:int) "user32")
(*define-dll-entry BOOL DestroyWindow (HWND) "user32")
(*define-dll-entry BOOL DestroyIcon (HICON) "user32")
(*define-dll-entry BOOL TrackPopupMenu (HMENU UINT int int int HWND (RECT *)) "user32")
(*define-dll-entry HMENU CreatePopupMenu () "user32")
(*define-dll-entry BOOL AppendMenu (HMENU UINT UINT LPSTR) "user32" "AppendMenuA")
(*define-dll-entry BOOL DestroyMenu (HMENU) "user32")
(*define-dll-entry BOOL GetCursorPos ((POINT *)) "user32")
(*define-dll-entry BOOL SetForegroundWindow (HWND) "user32")

;; wingdi.h

#| Stock Logical Objects |#
(*define WHITE_BRUSH         0)
(*define LTGRAY_BRUSH        1)
(*define GRAY_BRUSH          2)
(*define DKGRAY_BRUSH        3)
(*define BLACK_BRUSH         4)
(*define NULL_BRUSH          5)
(*define HOLLOW_BRUSH        NULL_BRUSH)
(*define WHITE_PEN           6)
(*define BLACK_PEN           7)
(*define NULL_PEN            8)
(*define OEM_FIXED_FONT      10)
(*define ANSI_FIXED_FONT     11)
(*define ANSI_VAR_FONT       12)
(*define SYSTEM_FONT         13)
(*define DEVICE_DEFAULT_FONT 14)
(*define DEFAULT_PALETTE     15)
(*define SYSTEM_FIXED_FONT   16)

;#if(WINVER >= 0x0400)
(*define DEFAULT_GUI_FONT    17)
;#endif /* WINVER >= 0x0400 */

;#if (_WIN32_WINNT >= 0x0500)
(*define DC_BRUSH            18)
(*define DC_PEN              19)
;#endif

;;; どれを選んだらいいのか分からん
;#if (_WIN32_WINNT >= 0x0500)
(*define STOCK_LAST          19)
;#elif (WINVER >= 0x0400)
;(*define STOCK_LAST          17)
;#else
;(*define STOCK_LAST          16)
;#endif

(*define CLR_INVALID     #xFFFFFFFF)

#| Brush Styles |#
(*define BS_SOLID            0)
(*define BS_NULL             1)
(*define BS_HOLLOW           BS_NULL)
(*define BS_HATCHED          2)
(*define BS_PATTERN          3)
(*define BS_INDEXED          4)
(*define BS_DIBPATTERN       5)
(*define BS_DIBPATTERNPT     6)
(*define BS_PATTERN8X8       7)
(*define BS_DIBPATTERN8X8    8)
(*define BS_MONOPATTERN      9)

#| Hatch Styles |#
(*define HS_HORIZONTAL       0)       #| ----- |#
(*define HS_VERTICAL         1)       #| ||||| |#
(*define HS_FDIAGONAL        2)       #| \\\\\ |#
(*define HS_BDIAGONAL        3)       #| ///// |#
(*define HS_CROSS            4)       #| +++++ |#
(*define HS_DIAGCROSS        5)       #| xxxxx |#

#| Pen Styles |#
(*define PS_SOLID            0)
(*define PS_DASH             1)       #| -------  |#
(*define PS_DOT              2)       #| .......  |#
(*define PS_DASHDOT          3)       #| _._._._  |#
(*define PS_DASHDOTDOT       4)       #| _.._.._  |#
(*define PS_NULL             5)
(*define PS_INSIDEFRAME      6)
(*define PS_USERSTYLE        7)
(*define PS_ALTERNATE        8)
(*define PS_STYLE_MASK       #x0000000F)

(*define PS_ENDCAP_ROUND     #x00000000)
(*define PS_ENDCAP_SQUARE    #x00000100)
(*define PS_ENDCAP_FLAT      #x00000200)
(*define PS_ENDCAP_MASK      #x00000F00)

(*define PS_JOIN_ROUND       #x00000000)
(*define PS_JOIN_BEVEL       #x00001000)
(*define PS_JOIN_MITER       #x00002000)
(*define PS_JOIN_MASK        #x0000F000)

(*define PS_COSMETIC         #x00000000)
(*define PS_GEOMETRIC        #x00010000)
(*define PS_TYPE_MASK        #x000F0000)

(*define AD_COUNTERCLOCKWISE 1)
(*define AD_CLOCKWISE        2)

(*define-dll-entry HPEN CreatePen (int int COLORREF) "gdi32")
(*define-dll-entry BOOL Rectangle (HDC int int int int) "gdi32")
(*define-dll-entry BOOL Ellipse (HDC int int int int) "gdi32")
(*define-dll-entry BOOL RoundRect (HDC int int int int int int) "gdi32")
(*define-dll-entry BOOL Arc (HDC int int int int int int int int) "gdi32")
(*define-dll-entry BOOL Pie (HDC int int int int int int int int) "gdi32")
(*define-dll-entry BOOL Chord (HDC int int int int int int int int) "gdi32")
(*define-dll-entry HBRUSH CreateSolidBrush (COLORREF) "gdi32")
(*define-dll-entry HBRUSH CreateHatchBrush (int COLORREF) "gdi32")

(*define-c-macro RGB (r g b) `(logior ,r (ash ,g 8) (ash ,b 16)))
