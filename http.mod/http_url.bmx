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

Rem
bbdoc: HTTP URL representation and builder.
End Rem
Type TUrl
Internal
	Field _urlPtr:Byte Ptr
Public
	Rem
	bbdoc: Initializes a new #TUrl instance.
	End Rem
	Method New()
		_urlPtr = curl_url()
	End Method

	Rem
	bbdoc: Initializes a new #TUrl instance by parsing the given URL string.
	End Rem
	Method New(url:String)
		New() ' initialize
		ParseUrl(url)
	End Method

	Rem
	bbdoc: Returns a URL builder instance for the construction of a URL.
	End Rem
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

	Rem
	bbdoc: Returns the scheme component of the URL.
	about: The scheme is the initial part of the URL that indicates the protocol to be used (e.g., "http", "https", "ftp").
	End Rem
	Method GetScheme:String()
		Local scheme:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Scheme, scheme, CURLU_URLDECODE | CURLU_DEFAULT_SCHEME) = EUrlCode.Ok Then
			Return scheme
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the user component of the URL.
	about: The user component is the username specified in the URL, typically used for authentication.
	End Rem
	Method GetUser:String()
		Local user:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.User, user, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return user
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the password component of the URL.
	about: The password component is the password specified in the URL, typically used for authentication.
	End Rem
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

	Rem
	bbdoc: Returns the host component of the URL.
	about: The host is the domain name or IP address of the server where the resource is located.
	End Rem
	Method GetHost:String()
		Local host:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Host, host, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return host
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the port component of the URL.
	about: The port is the network port number on the server where the resource is located.
	If no port is explicitly specified in the URL, the default port for the scheme is returned (e.g., 80 for HTTP, 443 for HTTPS).
	End Rem
	Method GetPort:String()
		Local port:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Port, port, CURLU_DEFAULT_PORT) = EUrlCode.Ok Then
			Return port
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the port component of the URL as an integer.
	about: The port is the network port number on the server where the resource is located.
	If no port is explicitly specified in the URL, the default port for the scheme is returned (e.g., 80 for HTTP, 443 for HTTPS).
	End Rem
	Method GetPortAsInt:Int()
		Local port:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Port, port, CURLU_DEFAULT_PORT) = EUrlCode.Ok Then
			Return port.ToInt()
		End If
		Return 0
	End Method

	Rem
	bbdoc: Returns the path component of the URL, without decoding.
	about: The path specifies the specific resource within the host that the URL is pointing to.
	End Rem
	Method GetRawPath:String()
		Local path:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Path, path, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return path
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the path component of the URL.
	about: The path specifies the specific resource within the host that the URL is pointing to.
	End Rem
	Method GetPath:String()
		Local path:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Path, path, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return path
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the query component of the URL, without decoding.
	about: The query string contains data to be sent to the server as part of the request.
	End Rem
	Method GetRawQuery:String()
		Local query:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Query, query, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return query
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the query component of the URL.
	about: The query string contains data to be sent to the server as part of the request.
	End Rem
	Method GetQuery:String()
		Local query:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Query, query, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return query
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the fragment component of the URL, without decoding.
	about: The fragment identifier is used to point to a specific section within the resource.
	End Rem
	Method GetRawFragment:String()
		Local fragment:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Fragment, fragment, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return fragment
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the fragment component of the URL.
	about: The fragment identifier is used to point to a specific section within the resource.
	End Rem
	Method GetFragment:String()
		Local fragment:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Fragment, fragment, CURLU_URLDECODE) = EUrlCode.Ok Then
			Return fragment
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns #True if the URL is absolute (i.e., has a scheme).
	End Rem
	Method IsAbsolute:Int()
		Return GetScheme() <> ""
	End Method

	Rem
	bbdoc: Returns the full URL as a string.
	End Rem
	Method ToString:String()
		Local url:String
		If bmx_curl_url_get(_urlPtr, EUrlPart.Url, url, CURLU_URLENCODE) = EUrlCode.Ok Then
			Return url
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns #True if the URL uses a secure scheme (e.g., "https" or "wss").
	End Rem
	Method IsSecureScheme:Int()
		Local scheme:String = GetScheme().ToLower()
		Return scheme = "https" Or scheme = "wss"
	End Method
	
	Method Delete()
		If _urlPtr
			curl_url_cleanup(_urlPtr)
			_urlPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: HTTP URL builder.
about: Use TUrl.Builder() to create a new builder instance.
End Rem
Type TUrlBuilder
Internal	
	Field _url:TUrl

	Method New(url:TUrl)
		_url = url
	End Method
Public
	Rem
	bbdoc: Builds and returns the constructed TUrl instance.
	End Rem
	Method Build:TUrl()
		Return _url
	End Method

	Rem
	bbdoc: Sets the scheme component of the URL.
	End Rem
	Method Scheme:TUrlBuilder(scheme:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Scheme, scheme, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the user component of the URL.
	End Rem
	Method User:TUrlBuilder(user:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.User, user, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the password component of the URL.
	End Rem
	Method Password:TUrlBuilder(password:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Password, password, CURLU_URLENCODE)
		Return Self
	End Method

	Rem
	bbdoc: Sets the options component of the URL.
	about: The options field is an optional field that might follow the password in the userinfo part.
	It is only recognized/used when parsing URLs for the following schemes: pop3, smtp and imap.
	The URL API still allows users to set and get this field independently of scheme when not parsing full URLs.
	End Rem
	Method Options:TUrlBuilder(options:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Options, options, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the host component of the URL.
	End Rem
	Method Host:TUrlBuilder(host:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Host, host, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the port component of the URL.
	End Rem
	Method Port:TUrlBuilder(port:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Port, port, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the port component of the URL.
	End Rem
	Method Port:TUrlBuilder(port:Int)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Port, String(port), 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the path component of the URL.
	End Rem
	Method Path:TUrlBuilder(path:String)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Path, path, CURLU_URLENCODE)
		Return Self
	End Method

	Rem
	bbdoc: Sets the query component of the URL.
	about: This method encodes the query string while preserving the "&" and "=" separators.
	End Rem
	Method Query:TUrlBuilder(query:String)
		Local encoded:String = EncodeQueryPreservingSeparators(query)
		bmx_curl_url_set(_url._urlPtr, EUrlPart.Query, encoded, 0)
		Return Self
	End Method

	Rem
	bbdoc: Sets the fragment component of the URL.
	End Rem
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

Public

Rem
bbdoc: URL error codes.
about: These codes are returned by URL functions to indicate success or failure reasons.

| Code | Description |
|------|-------------|
| Ok | The operation was successful. |
| BadHandle | The provided URL handle is invalid. |
| BadPartPointer | The provided part pointer is invalid. |
| MalformedInput | The input string is malformed. |
| BadPortNumber | The specified port number is invalid. |
| UnsupportedScheme | The URL scheme is unsupported. |
| UrlDecode | An error occurred during URL decoding. |
| OutOfMemory | The operation failed due to insufficient memory. |
| UserNotAllowed | The specified user is not allowed. |
| UnknownPart | The specified URL part is unknown. |
| NoScheme | The URL does not have a scheme component. |
| NoUser | The URL does not have a user component. |
| NoPassword | The URL does not have a password component. |
| NoOptions | The URL does not have an options component. |
| NoHost | The URL does not have a host component. |
| NoPort | The URL does not have a port component. |
| NoQuery | The URL does not have a query component. |
| NoFragment | The URL does not have a fragment component. |

End Rem
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

Rem
bbdoc: URL parts identifiers.
about: These identifiers are used to specify different parts of a URL when getting or setting values.
End Rem
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

Function QueryToHttpFields:THttpFields(url:TUrl)
	Return QueryToHttpFields( url.GetQuery() )
End Function

Function QueryToHttpFields:THttpFields(query:String)
	Local httpFields:THttpFields = New THttpFields
	If query = Null Or query = "" Then
		Return httpFields
	End If

	Local pairs:String[] = query.Split("&")
	For Local pair:String = EachIn pairs
		Local idx:Int = pair.Find("=")
		If idx = -1
			httpFields.Add( THttpHelper.UrlEncodeComponent(pair), "" )
		Else
			Local key:String = pair[..idx]
			Local val:String = pair[idx + 1..]
			httpFields.Add( THttpHelper.UrlEncodeComponent(key), THttpHelper.UrlEncodeComponent(val) )
		End If
	Next
	Return httpFields
End Function
