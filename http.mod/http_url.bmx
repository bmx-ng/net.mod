'
' Copyright (c) 2025 Bruce A Henderson
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
'    in a product, an acknowledgement in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Import Net.libcurl
Import BRL.StringBuilder

Import "http_util.bmx"

Type TUrl
Private
	Field _urlPtr:Byte Ptr
Public
	Method New()
		_urlPtr = curl_url()
	End Method

	Method New(url:String)
		New() ' initialize
		ParseUrl(url)
	End Method

	Function Builder:TUrlBuilder()
		Return New TUrlBuilder(New TUrl())
	End Function

	Rem
	bbdoc: Parses the given URL string, replacing any existing URL data.
	returns: #True if the URL was parsed successfully, False otherwise.
	End Rem
	Method ParseUrl:Int(url:String)
		Local res:EUrlCode = bmx_curl_url_set(_urlPtr, EUrlPart.Url, url, 0)
		If res <> EUrlCode.Ok Then
			Return False
		End If
		Return True
	End Method

	Method GetScheme:String()
		Local scheme:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Scheme, scheme, CURLU_URLDECODE | CURLU_DEFAULT_SCHEME) = EUrlCode.Ok Then
			Return scheme
		End If
		Return ""
	End Method

	Method GetUser:String()
		Local user:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.User, user, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return user
		End If
		Return ""
	End Method

	Method GetPassword:String()
		Local password:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Password, password, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return password
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns any options specified in the URL.
	about: The options field is an optional field that might follow the password in the userinfo part.
	It is only recognized/used when parsing URLs for the following schemes: pop3, smtp and imap.
	The URL API still allows users to set and get this field independently of scheme when not parsing full URLs.
	End Rem
	Method GetOptions:String()
		Local options:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Options, options, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return options
		End If
		Return ""
	End Method

	Method GetHost:String()
		Local host:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Host, host, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return host
		End If
		Return ""
	End Method

	Method GetPort:String()
		Local port:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Port, port, CURLU_DEFAULT_PORT) = EUrlCode.Ok Then
			Return port
		End If
		Return ""
	End Method

	Method GetPortAsInt:Int()
		Local port:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Port, port, CURLU_DEFAULT_PORT) = EUrlCode.Ok Then
			Return port.ToInt()
		End If
		Return 0
	End Method

	Method GetRawPath:String()
		Local path:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Path, path, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return path
		End If
		Return ""
	End Method

	Method GetPath:String()
		Local path:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Path, path, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return path
		End If
		Return ""
	End Method

	Method GetRawQuery:String()
		Local query:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Query, query, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return query
		End If
		Return ""
	End Method

	Method GetQuery:String()
		Local query:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Query, query, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return query
		End If
		Return ""
	End Method

	Method GetRawFragment:String()
		Local fragment:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Fragment, fragment, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return fragment
		End If
		Return ""
	End Method

	Method GetFragment:String()
		Local fragment:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Fragment, fragment, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return fragment
		End If
		Return ""
	End Method

	Method IsAbsolute:Int()
		Return GetScheme() <> ""
	End Method

	Method ToString:String()
		Local url:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Url, url, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return url
		End If
		Return ""
	End Method
	
	Method Delete()
		If _urlPtr
			curl_url_cleanup(_urlPtr)
			_urlPtr = Null
		End If
	End Method

End Type

Type TUrlBuilder
Private	
	Field _url:TUrl

	Method New(url:TUrl)
		_url = url
	End Method
Public
	Method Build:TUrl()
		Return _url
	End Method

	Method Scheme:TUrlBuilder(scheme:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Scheme, scheme, 0)
		Return Self
	End Method

	Method User:TUrlBuilder(user:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.User, user, 0)
		Return Self
	End Method

	Method Password:TUrlBuilder(password:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Password, password, CURLU_URLENCODE)
		Return Self
	End Method

	Method Options:TUrlBuilder(options:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Options, options, 0)
		Return Self
	End Method

	Method Host:TUrlBuilder(host:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Host, host, 0)
		Return Self
	End Method

	Method Port:TUrlBuilder(port:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Port, port, 0)
		Return Self
	End Method

	Method Port:TUrlBuilder(port:Int)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Port, String(port), 0)
		Return Self
	End Method

	Method Path:TUrlBuilder(path:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Path, path, CURLU_URLENCODE)
		Return Self
	End Method

	Method Query:TUrlBuilder(query:String)
		Local encoded:String = EncodeQueryPreservingSeparators(query)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Query, encoded, 0)
		Return Self
		' bmx_curl_url_set(_url._urlPtr, EUrlPart.Query, query, CURLU_URLENCODE)
		' Return Self
	End Method

	Method Fragment:TUrlBuilder(fragment:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Fragment, fragment, CURLU_URLENCODE)
		Return Self
	End Method

	Function SplitOnceEquals:String[](pair:String)
		Local idx:Int = pair.Find("=")
		If idx = -1 Then
			Return [pair, "", "0"]
		Else
			Return [pair[..idx], pair[idx + 1..], "1"]
		EndIf
	End Function

	' Main helper: encodes key/value components but keeps "&" and "=" intact.
	Function EncodeQueryPreservingSeparators:String(q:String)
		If Not q Then
			Return ""
		End If

		Local segments:String[] = q.Split("&")
		For Local i:Int = 0 Until segments.Length
			Local seg:String = segments[i]

			' Keep empty segments as-is (allows "a=1&&b=2")
			If seg = "" Then
				Continue
			EndIf

			Local parts:String[] = SplitOnceEquals(seg)
			Local key:String = parts[0]
			Local val:String = parts[1]
			Local hadEq:Int = Int(parts[2])

			Local ek:String = THttpHelper.UrlEncodeComponent(key)
			If hadEq Then
				Local ev:String = THttpHelper.UrlEncodeComponent(val)
				segments[i] = ek + "=" + ev
			Else
				segments[i] = ek  ' key-only param
			EndIf
		Next

		Local sb:TStringBuilder = New TStringBuilder
		sb.JoinStrings(segments, "&")
		Return sb.ToString()
	End Function
End Type

Private

Extern
	Function curl_url:Byte Ptr()
	Function curl_url_cleanup(handle:Byte Ptr)
	
	Function bmx_curl_url_set:EUrlCode(handle:Byte Ptr, part:EUrlPart, content:String, flags:UInt)
	Function bmx_curl_url_get:EUrlCode(handle:Byte Ptr, part:EUrlPart, content:String Var, flags:UInt)
	
	Function bmx_curl_url_strerror:String(code:EUrlCode)

End Extern


Enum EUrlCode
	Ok = 0
	BadHandle
	BadPartPointer
	MalformedInput
	BadPortNumber
	UnsupportedScheme
	UrlDecode
	OutOfMemory
	UserNotAllowed
	UnknownPart
	NoScheme
	NoUser
	NoPassword
	NoOptions
	NoHost
	NoPort
	NoQuery
	NoFragment
End Enum

Enum EUrlPart
	Url = 0
	Scheme
	User
	Password
	Options
	Host
	Port
	Path
	Query
	Fragment
	ZoneId
End Enum

