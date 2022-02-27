' Copyright (c) 2007-2022 Bruce A Henderson
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

Import Pub.zlib


Import "source.bmx"
Import "consts.bmx"

?linux
Import "-ldl"
?win32
Import "-ladvapi32"
Import "-lws2_32"
?macos
Import "-lresolv"
Import "-framework Security"
Import "-framework SystemConfiguration"
?


Import "libcurl/include/*.h"
Import "glue.c"

Extern

	Function curl_global_init:Int(flags:Int)
	Function curl_easy_init:Byte Ptr()
	Function curl_easy_perform:Int(handle:Byte Ptr)
	Function curl_easy_cleanup(handle:Byte Ptr)
	Function curl_easy_reset(handle:Byte Ptr)
	Function curl_easy_strerror:Byte Ptr(code:Int)
	Function curl_slist_free_all(slist:SCurlSlist Ptr)
	Function curl_easy_escape:Byte Ptr(handle:Byte Ptr, s:Byte Ptr, length:Int)
	Function curl_free(handle:Byte Ptr)
	Function curl_easy_unescape:Byte Ptr(handle:Byte Ptr, txt:Byte Ptr, inlength:Int, outlength:Int Ptr)
	Function curl_slist_append:SCurlSlist Ptr(slist:SCurlSlist Ptr, txt:Byte Ptr)
	
	Function curl_multi_init:Byte Ptr()
	Function curl_multi_cleanup(handle:Byte Ptr)
	Function curl_multi_remove_handle:Int(handle:Byte Ptr, easy:Byte Ptr)
	Function curl_multi_add_handle:Int(handle:Byte Ptr, easy:Byte Ptr)
	Function curl_multi_perform:Int(handle:Byte Ptr, running:Int Ptr)
	Function curl_multi_info_read:Byte Ptr(handle:Byte Ptr, queuesize:Int Ptr)
	
	Function bmx_curl_easy_setopt_int:Int(handle:Byte Ptr, option:Int, param:Int)
	Function bmx_curl_easy_setopt_str:Int(handle:Byte Ptr, option:Int, param:Byte Ptr)
	Function bmx_curl_easy_setopt_ptr:Int(handle:Byte Ptr, option:Int, param:Byte Ptr)
	Function bmx_curl_easy_setopt_obj:Int(handle:Byte Ptr, option:Int, param:Object)
	Function bmx_curl_easy_setopt_bbint64:Int(handle:Byte Ptr, option:Int, param:Long)
	
	Function bmx_curl_formadd_name_content(httppostPtr:SCurlHttpPost Var, name:Byte Ptr, content:Byte Ptr)
	Function bmx_curl_formadd_name_content_type(httppostPtr:SCurlHttpPost Var, name:Byte Ptr, content:Byte Ptr, t:Byte Ptr)
	Function bmx_curl_formadd_name_file(httppostPtr:SCurlHttpPost Var, name:Byte Ptr, file:Byte Ptr, kind:Int)
	Function bmx_curl_formadd_name_file_type(httppostPtr:SCurlHttpPost Var, name:Byte Ptr, file:Byte Ptr, t:Byte Ptr, kind:Int)
	Function bmx_curl_formadd_name_buffer(httppostPtr:SCurlHttpPost Var, name:Byte Ptr, bname:Byte Ptr, buffer:Byte Ptr, length:Int)

	Function curl_formfree(handle:Byte Ptr)
	
	Function bmx_curl_easy_getinfo_string:Int(handle:Byte Ptr, option:Int, b:Byte Ptr)
	Function bmx_curl_easy_getinfo_int:Int(handle:Byte Ptr, option:Int, value:Int Ptr)
	Function bmx_curl_easy_getinfo_double:Int(handle:Byte Ptr, option:Int, value:Double Ptr)
	Function bmx_curl_easy_getinfo_obj:Object(handle:Byte Ptr, option:Int, error:Int Ptr)
	Function bmx_curl_easy_getinfo_slist:Int(handle:Byte Ptr, option:Int, slist:SCurlSlist Ptr)
	Function bmx_curl_easy_getinfo_long:Int(handle:Byte Ptr, option:Int, value:Long Ptr)
	
	Function bmx_curl_multiselect:Int(handle:Byte Ptr, timeout:Double)
	
	Function bmx_curl_CURLMsg_msg:Int(handle:Byte Ptr)
	Function bmx_curl_CURLMsg_result:Int(handle:Byte Ptr)
	Function bmx_curl_CURLMsg_easy_handle:Byte Ptr(handle:Byte Ptr)
	
	Function bmx_curl_easy_setopt_slist(handle:Byte Ptr, option:Int, slist:SCurlSlist Ptr)
	
	Function bmx_curl_multi_setopt_int(handle:Byte Ptr, option:Int, param:Int)
	
End Extern

Type TSList
	Field slist:SCurlSlist Ptr
	Field count:Int
End Type

Struct SCurlSlist
	Field data:Byte Ptr
	Field nxt:SCurlSlist Ptr
End Struct

Function curlProcessSlist:String[](slist:TSList)
	If slist Then

		Local list:String[] = New String[16]
		Local count:Int
		
		Local slistPtr:SCurlSlist Ptr = slist.slist
		
		While slistPtr
		
			If count = list.Length Then
				list = list[..count * 3 / 2]
			End If

			If slistPtr.data Then
				list[count] = String.fromUTF8String(slistPtr.data)
			End If
			
			slistPtr = slistPtr.nxt
			count :+ 1

		Wend
		
		If slist.slist Then
			curl_slist_free_all(slist.slist)
		End If
		
		Return list[..count]

	End If
	Return Null
End Function

Struct SCurlHttpPost
	Field post:Byte Ptr
	Field last:Byte Ptr
End Struct
