# Microsoft Developer Studio Project File - Name="libssh2" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **
# only OpenSSL and WinCNG are supported with this build system

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=libssh2 - Win32 OpenSSL Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "libssh2.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "libssh2.mak" CFG="libssh2 - Win32 DLL Debug"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "libssh2 - Win32 OpenSSL DLL Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libssh2 - Win32 OpenSSL DLL Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libssh2 - Win32 OpenSSL LIB Release" (based on "Win32 (x86) Static Library")
!MESSAGE "libssh2 - Win32 OpenSSL LIB Debug" (based on "Win32 (x86) Static Library")
!MESSAGE "libssh2 - Win32 WinCNG DLL Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libssh2 - Win32 WinCNG DLL Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libssh2 - Win32 WinCNG LIB Release" (based on "Win32 (x86) Static Library")
!MESSAGE "libssh2 - Win32 WinCNG LIB Debug" (based on "Win32 (x86) Static Library")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libssh2 - Win32 OpenSSL DLL Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release_dll"
# PROP BASE Intermediate_Dir "Release_dll"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release_dll"
# PROP Intermediate_Dir "Release_dll"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "..\win32" /I "..\include" /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 gdi32.lib advapi32.lib user32.lib kernel32.lib ws2_32.lib libeay32.lib zlib.lib /nologo /dll /map /debug /machine:I386

!ELSEIF  "$(CFG)" == "libssh2 - Win32 OpenSSL DLL Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug_dll"
# PROP BASE Intermediate_Dir "Debug_dll"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug_dll"
# PROP Intermediate_Dir "Debug_dll"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /MD /W3 /Gm /GX /ZI /Od /I "..\win32" /I "..\include" /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /D "LIBSSH2DEBUG" /YX /FD /GZ /c
# SUBTRACT CPP /WX /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 gdi32.lib advapi32.lib user32.lib kernel32.lib ws2_32.lib libeay32.lib zlib.lib /nologo /dll /incremental:no /map /debug /machine:I386 /pdbtype:sept
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "libssh2 - Win32 OpenSSL LIB Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release_lib"
# PROP BASE Intermediate_Dir "Release_lib"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release_lib"
# PROP Intermediate_Dir "Release_lib"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "..\win32" /I "..\include" /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
# ADD LIB32 /nologo /out:"Release_lib\libssh2.lib"

!ELSEIF  "$(CFG)" == "libssh2 - Win32 OpenSSL LIB Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug_lib"
# PROP BASE Intermediate_Dir "Debug_lib"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug_lib"
# PROP Intermediate_Dir "Debug_lib"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /MD /W3 /Gm /GX /ZI /Od /I "..\win32" /I "..\include" /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_OPENSSL" /D "_MBCS" /D "_LIB" /D "LIBSSH2DEBUG" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"Debug_lib\libssh2d.lib"

!ELSEIF  "$(CFG)" == "libssh2 - Win32 WinCNG LIB Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release_dll"
# PROP BASE Intermediate_Dir "Release_dll"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release_dll"
# PROP Intermediate_Dir "Release_dll"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "..\win32" /I "..\include" /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 gdi32.lib advapi32.lib user32.lib kernel32.lib ws2_32.lib crypt32.lib bcrypt.lib /nologo /dll /map /debug /machine:I386

!ELSEIF  "$(CFG)" == "libssh2 - Win32 WinCNG DLL Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug_dll"
# PROP BASE Intermediate_Dir "Debug_dll"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug_dll"
# PROP Intermediate_Dir "Debug_dll"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /MD /W3 /Gm /GX /ZI /Od /I "..\win32" /I "..\include" /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /D "LIBSSH2DEBUG" /YX /FD /GZ /c
# SUBTRACT CPP /WX /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 gdi32.lib advapi32.lib user32.lib kernel32.lib ws2_32.lib crypt32.lib bcrypt.lib /nologo /dll /incremental:no /map /debug /machine:I386 /pdbtype:sept
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "libssh2 - Win32 WinCNG LIB Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release_lib"
# PROP BASE Intermediate_Dir "Release_lib"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release_lib"
# PROP Intermediate_Dir "Release_lib"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "..\win32" /I "..\include" /D "WIN32" /D "NDEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
# ADD LIB32 /nologo /out:"Release_lib\libssh2.lib"

!ELSEIF  "$(CFG)" == "libssh2 - Win32 WinCNG LIB Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug_lib"
# PROP BASE Intermediate_Dir "Debug_lib"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug_lib"
# PROP Intermediate_Dir "Debug_lib"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /MD /W3 /Gm /GX /ZI /Od /I "..\win32" /I "..\include" /D "WIN32" /D "_DEBUG" /D "LIBSSH2_WIN32" /D "LIBSSH2_WINCNG" /D "_MBCS" /D "_LIB" /D "LIBSSH2DEBUG" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"Debug_lib\libssh2d.lib"

!ENDIF

# Begin Target

# Name "libssh2 - Win32 OpenSSL DLL Release"
# Name "libssh2 - Win32 OpenSSL DLL Debug"
# Name "libssh2 - Win32 OpenSSL LIB Release"
# Name "libssh2 - Win32 OpenSSL LIB Debug"
# Name "libssh2 - Win32 WinCNG DLL Release"
# Name "libssh2 - Win32 WinCNG DLL Debug"
# Name "libssh2 - Win32 WinCNG LIB Release"
# Name "libssh2 - Win32 WinCNG LIB Debug"

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx"
# Begin Source File

SOURCE=..\src\agent.c
# End Source File
# Begin Source File

SOURCE=..\src\agent_win.c
# End Source File
# Begin Source File

SOURCE=..\src\bcrypt_pbkdf.c
# End Source File
# Begin Source File

SOURCE=..\src\blowfish.c
# End Source File
# Begin Source File

SOURCE=..\src\channel.c
# End Source File
# Begin Source File

SOURCE=..\src\comp.c
# End Source File
# Begin Source File

SOURCE=..\src\crypt.c
# End Source File
# Begin Source File

SOURCE=..\src\global.c
# End Source File
# Begin Source File

SOURCE=..\src\hostkey.c
# End Source File
# Begin Source File

SOURCE=..\src\keepalive.c
# End Source File
# Begin Source File

SOURCE=..\src\kex.c
# End Source File
# Begin Source File

SOURCE=..\src\knownhost.c
# End Source File
# Begin Source File

SOURCE=..\src\mac.c
# End Source File
# Begin Source File

SOURCE=..\src\mbedtls.c
# End Source File
# Begin Source File

SOURCE=..\src\misc.c
# End Source File
# Begin Source File

SOURCE=..\src\openssl.c
# End Source File
# Begin Source File

SOURCE=..\src\packet.c
# End Source File
# Begin Source File

SOURCE=..\src\pem.c
# End Source File
# Begin Source File

SOURCE=..\src\publickey.c
# End Source File
# Begin Source File

SOURCE=..\src\scp.c
# End Source File
# Begin Source File

SOURCE=..\src\session.c
# End Source File
# Begin Source File

SOURCE=..\src\sftp.c
# End Source File
# Begin Source File

SOURCE=..\src\transport.c
# End Source File
# Begin Source File

SOURCE=..\src\userauth.c
# End Source File
# Begin Source File

SOURCE=..\src\version.c
# End Source File
# Begin Source File

SOURCE=..\src\wincng.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx"
# Begin Source File

SOURCE=..\src\agent.h
# End Source File
# Begin Source File

SOURCE=..\src\blf.h
# End Source File
# Begin Source File

SOURCE=..\src\channel.h
# End Source File
# Begin Source File

SOURCE=..\src\comp.h
# End Source File
# Begin Source File

SOURCE=..\src\crypto.h
# End Source File
# Begin Source File

SOURCE=.\libssh2_config.h
# End Source File
# Begin Source File

SOURCE=..\src\libssh2_priv.h
# End Source File
# Begin Source File

SOURCE=..\src\mac.h
# End Source File
# Begin Source File

SOURCE=..\src\mbedtls.h
# End Source File
# Begin Source File

SOURCE=..\src\misc.h
# End Source File
# Begin Source File

SOURCE=..\src\openssl.h
# End Source File
# Begin Source File

SOURCE=..\src\packet.h
# End Source File
# Begin Source File

SOURCE=..\src\session.h
# End Source File
# Begin Source File

SOURCE=..\src\sftp.h
# End Source File
# Begin Source File

SOURCE=..\src\transport.h
# End Source File
# Begin Source File

SOURCE=..\src\userauth.h
# End Source File
# Begin Source File

SOURCE=..\src\wincng.h
# End Source File
# End Group
# End Target
# End Project

