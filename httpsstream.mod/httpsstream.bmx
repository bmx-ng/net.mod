' Copyright (c) 2023 Bruce A Henderson
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Module Net.HttpsStream

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2023 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release"

Import Net.Libcurl

Import "../libcurl.mod/libcurl/include/*.h"
Import "glue.c"

Type THTTPSStreamFactory Extends TStreamFactory

	Method CreateStream:TStream( url:Object,proto$,path$,readable:Int,writeMode:Int ) Override
		If proto="https"
			Local i:Int=path.Find( "/",0 ),server$,file$
			If i<>-1
				server=path[..i]
				file=path[i..]
			Else
				server=path
				file="/"
			EndIf
			
			Local curl:TCurlEasy = TCurlEasy.Create()
			curl.setOptString(CURLOPT_URL, "https://" + path)

			Return New TCurlStream(curl)
		EndIf
	End Method

End Type

Type TCurlStream Extends TStream

	Field curl:TCurlEasy
	Field curlReaderPtr:Byte Ptr
	FIeld isEOF:Int

	Method New(curl:TCurlEasy)
		self.curl = curl
		curlReaderPtr = bmx_hstream_curl_reader_init(curl.easyHandlePtr)
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		Local c:Int = bmx_hstream_read_from_curl(curlReaderPtr, buf, Size_T(count))
		If c = 0 Then
			isEOF = True
		End IF
		Return c
	End Method

	Method Eof:Int() Override
		Return isEOF
	End Method

	Method Close() Override
		bmx_hstream_curl_reader_cleanup(curlReaderPtr)
		curl.cleanup()
	End Method

End Type

New THTTPSStreamFactory

Private
Extern
	Function bmx_hstream_curl_reader_init:Byte Ptr(curl:Byte Ptr)
	Function bmx_hstream_read_from_curl:Int(reader:Byte Ptr, data:Byte Ptr, size:Size_T)
	Function bmx_hstream_curl_reader_cleanup(reader:Byte Ptr)
End Extern
