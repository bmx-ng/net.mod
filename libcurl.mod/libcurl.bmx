' Copyright (c) 2007-2021 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

SuperStrict

Rem
bbdoc: libcurl with SSL
End Rem
Module Net.libcurl

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: (libcurl) 1996 - 2021, Daniel Stenberg"
ModuleInfo "Copyright: (c-ares) 1998 Massachusetts Institute of Technology, 2004 - 2021 by Daniel Stenberg et al"
ModuleInfo "Copyright: (Wrapper) 2007-2021 Bruce A Henderson"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07"
ModuleInfo "History: Update to libcurl 7.80.0"
ModuleInfo "History: Update to c-ares 1.18.1"
ModuleInfo "History: 1.06"
ModuleInfo "History: Update to libcurl 7.57.0"
ModuleInfo "History: Update to c-ares 1.13.0"
ModuleInfo "History: Changed to use mbedTLS instead of openSSL."
ModuleInfo "History: 1.05"
ModuleInfo "History: Update to libcurl 7.51.0"
ModuleInfo "History: Update to c-ares 1.12.0"
ModuleInfo "History: 1.04"
ModuleInfo "History: Update to libcurl 7.31.0"
ModuleInfo "History: Update to c-ares 1.10.0"
ModuleInfo "History: Fix for Win32 blocked select()."
ModuleInfo "History: Do not build acountry.c."
ModuleInfo "History: 1.03"
ModuleInfo "History: Update to libcurl 7.28.1"
ModuleInfo "History: Update to c-ares 1.9.1"
ModuleInfo "History: Updated Win32 SSL support to OpenSSL 1.0."
ModuleInfo "History: Added ssh support. Now requires BaH.libssh2."
ModuleInfo "History: Fixed ResponseCode() not returning correct codes."
ModuleInfo "History: ReadStream now uses Read() instead of ReadBytes()."
ModuleInfo "History: 1.02"
ModuleInfo "History: Skipped to synchronise version number with bah.libcurl."
ModuleInfo "History: 1.01"
ModuleInfo "History: Update to libcurl 7.18.0"
ModuleInfo "History: Update to c-ares 1.5.1"
ModuleInfo "History: Now nulls internal slist."
ModuleInfo "History: 1.00 Initial Release (libcurl 7.16.4, c-ares 1.4.0)"

?Not win32
ModuleInfo "CC_OPTS: -DHAVE_CONFIG_H"
?win32
ModuleInfo "CC_OPTS: -DHAVE_GETTIMEOFDAY -DCURL_DISABLE_LDAP"
?
ModuleInfo "CC_OPTS: -DCURL_STATICLIB -DCARES_STATICLIB -DCURL_STRICTER -DUSE_MBEDTLS"

' NOTES :
'
' Patched to support mbedtls 3.x (see patches/)
'
' Added extra options to config_win32.h
' Added __GNUC__ test to ares/setup.h - for GCC 4+ compilation
' Added 64-bit mingw32 setting for CARES_TYPEOF_ARES_SSIZE_T

Import "curlmain.bmx"
