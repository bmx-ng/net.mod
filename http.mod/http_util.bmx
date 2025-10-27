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
Import brl.collections

Type THttpField
Private
	Field _header:EHttpHeader
	Field _set:Int ' header known
	Field _name:String
	Field _value:String
Public
	Method New(header:EHttpHeader, value:String)
		_header = header
		_set = True
		_name = THttpHelper.HttpHeaderToString( header )
		_value = value
	End Method

	Method New(name:String, value:String)
		_set = THttpHelper._nameToHeaderCache.TryGetValue( name.ToLower(), _header )
		_name = name
		_value = value
	End Method

	Method Is:Int(name:String)
		Return _name.ToLower() = name.ToLower()
	End Method

	Method GetName:String()
		Return _name
	End Method

	Method GetValue:String()
		Return _value
	End Method

	Method GetHeader:EHttpHeader()
		If _set
			Return _header
		End If
		' todo Throw New TIllegalStateException("Header not set")
		'Return EHttpHeader.Accept
	End Method

	Method TryGetHeader:Int(header:EHttpHeader Var)
		If _set
			header = _header
			Return True
		End If
		Return False
	End Method

End Type

Type THttpFields

	Field _fields:TArrayList<THttpField> = New TArrayList<THttpField>

	Method Add:THttpFields(name:String, value:String)
		_fields.Add( New THttpField(name, value) )
		Return Self
	End Method

	Method Add:THttpFields(header:EHttpHeader, value:String)
		_fields.Add( New THttpField(header, value) )
		Return Self
	End Method

	Method Add:THttpFields( fields:THttpFields )
		For Local f:THttpField = EachIn fields
			_fields.Add( f )
		Next
		Return Self
	End Method

	Method Add:THttpFields( _field:THttpField )
		_fields.Add( _field )
		Return Self
	End Method

	Method GetFirst:String(name:String)
		For Local f:THttpField = EachIn _fields
			If f.Is( name )
				Return f.GetValue()
			End If
		Next
		Return Null
	End Method

	Method GetFirst:String(header:EHttpHeader)
		For Local f:THttpField = EachIn _fields
			Local h:EHttpHeader
			If f.TryGetHeader(h) Then
				If h = header Then
					Return f.GetValue()
				End If
			End If
		Next
		Return Null
	End Method

	Rem
	bbdoc: Adds a header line in the format "Name: Value".
	End Rem
	Method Add:THttpFields( line:String )
		Local sepPos:Int = line.Find( ":" )
		If sepPos > 0
			Local name:String = line[..sepPos - 1].Trim()
			Local value:String = line[sepPos + 1..].Trim()
			Add( name, value )
		End If
		Return Self
	End Method

	Method HasHeader:Int(header:EHttpHeader)
		For Local f:THttpField = EachIn _fields
			Local h:EHttpHeader
			If f.TryGetHeader(h) Then
				If h = header Then
					Return True
				End If
			End If
		Next
		Return False
	End Method

	Method ObjectEnumerator:THttpFieldEnumerator()
		Local fieldEnumerator:THttpFieldEnumerator = New THttpFieldEnumerator
		fieldEnumerator._fields = Self
		fieldEnumerator._iterator = TArrayListIterator<THttpField>(_fields.GetIterator())
		fieldEnumerator._hasNext = fieldEnumerator._iterator.MoveNext()
		Return fieldEnumerator
	End Method

	Rem
	bbdoc: Converts the headers to a TSList suitable for libcurl.
	End Rem
	Method ToSList:TSList()
		Local slist:TSList = New TSList
		For Local f:THttpField = EachIn _fields
			slist.Append( f.GetName() + ": " + f.GetValue() )
		Next
		Return slist
	End Method

	Method IsEmpty:Int()
		Return _fields.IsEmpty()
	End Method

End Type

Type THttpFieldEnumerator
	Field _fields:THttpFields
	Field _iterator:TArrayListIterator<THttpField>
	Field _hasNext:Int

	Method HasNext:Int()
		Return _hasNext
	End Method

	Method NextObject:Object()
		Local current:THttpField = _iterator.Current()
		_hasNext = _iterator.MoveNext()
		Return current
	End Method
End Type

Enum EHttpMethod
	Get
	Post
	Put
	Delete
	Head
	Options
	Patch
	Trace
End Enum

Enum EHttpHeader
	Accept
	AcceptCharset
	AcceptEncoding
	AcceptLanguage
	AcceptRanges
	AccessControlAllowCredentials
	AccessControlAllowHeaders
	AccessControlAllowMethods
	AccessControlAllowOrigin
	AccessControlExposeHeaders
	AccessControlMaxAge
	AccessControlRequestHeaders
	AccessControlRequestMethod
	Age
	Allow
	AltSvc
	Authorization
	CAuthority
	CMethod
	CPath
	CProtocol
	CScheme
	CStatus
	CacheControl
	Connection
	ContentDisposition
	ContentEncoding
	ContentLanguage
	ContentLength
	ContentLocation
	ContentMD5
	ContentRange
	ContentTransferEncoding
	ContentType
	Cookie
	Date
	ETag
	Expect
	Expires
	Forwarded
	From
	Host
	Http2Settings
	Identity
	IfMatch
	IfModifiedSince
	IfNoneMatch
	IfRange
	IfUnmodifiedSince
	KeepAlive
	LastModified
	Link
	Location
	MaxForwards
	MimeVersion
	Negotiate
	Origin
	Pragma
	ProxyAuthenticate
	ProxyAuthorization
	ProxyConnection
	Range
	Referer
	RequestRange
	RetryAfter
	SecWebsocketAccept
	SecWebsocketExtensions
	SecWebsocketKey
	SecWebsocketSubprotocol
	SecWebsocketVersion
	Server
	ServletEngine
	SetCookie
	SetCookie2
	StrictTransportSecurity
	TE
	TimingAllowOrigin
	Trailer
	TransferEncoding
	Upgrade
	UserAgent
	Vary
	Via
	Warning
	WWWAuthenticate
	XForwardedFor
	XForwardedHost
	XForwardedPort
	XForwardedProto
	XForwardedServer
	XPoweredBy
End Enum

Rem
bbdoc: Authentication methods for HTTP requests.
End Rem
Enum EHttpAuthMethod:Int Flags
	None = 0
	Basic = 1 Shl 0
	Digest = 1 Shl 1
	Negotiate = 1 Shl 2
	NtLm = 1 Shl 3
	DigestIE = 1 Shl 4
	Bearer = 1 Shl 6
	AwsSigV4 = 1 Shl 7
	Only = 1 Shl 31
	Any = Basic | Digest | Negotiate | NtLm | Bearer | AwsSigV4
	AnySafe = Digest | Negotiate | NtLm | Bearer | AwsSigV4
End Enum

Type THttpHelper

	Global _nameToHeaderCache:TTreeMap<String,EHttpHeader> = New TTreeMap<String,EHttpHeader>
	Global _headerToNameCache:TTreeMap<EHttpHeader,String> = New TTreeMap<EHttpHeader,String>

	Private
	Function Init()
		' Populate cache
		' pairs of enum/string
		Local headers:String[] = [..
			"Accept", "Accept",..
			"AcceptCharset", "Accept-Charset",..
			"AcceptEncoding", "Accept-Encoding",..
			"AcceptLanguage", "Accept-Language",..
			"AcceptRanges", "Accept-Ranges",..
			"AccessControlAllowCredentials", "Access-Control-Allow-Credentials",..
			"AccessControlAllowHeaders", "Access-Control-Allow-Headers",..
			"AccessControlAllowMethods", "Access-Control-Allow-Methods",..
			"AccessControlAllowOrigin", "Access-Control-Allow-Origin",..
			"AccessControlExposeHeaders", "Access-Control-Expose-Headers",..
			"AccessControlMaxAge", "Access-Control-Max-Age",..
			"AccessControlRequestHeaders", "Access-Control-Request-Headers",..
			"AccessControlRequestMethod", "Access-Control-Request-Method",..
			"Age", "Age",..
			"Allow", "Allow",..
			"AltSvc", "Alt-Svc",..
			"Authorization", "Authorization",..
			"CAuthority", "C-Authority",..
			"CMethod", "C-Method",..
			"CPath", "C-Path",..
			"CProtocol", "C-Protocol",..
			"CScheme", "C-Scheme",..
			"CStatus", "C-Status",..
			"CacheControl", "Cache-Control",..
			"Connection", "Connection",..
			"ContentDisposition", "Content-Disposition",..
			"ContentEncoding", "Content-Encoding",..
			"ContentLanguage", "Content-Language",..
			"ContentLength", "Content-Length",..
			"ContentLocation", "Content-Location",..
			"ContentMD5", "Content-MD5",..
			"ContentRange", "Content-Range",..
			"ContentTransferEncoding", "Content-Transfer-Encoding",..
			"ContentType", "Content-Type",..
			"Cookie", "Cookie",..
			"Date", "Date",..
			"ETag", "ETag",..
			"Expect", "Expect",..
			"Expires", "Expires",..
			"Forwarded", "Forwarded",..
			"From", "From",..
			"Host", "Host",..
			"Http2Settings", "HTTP2-Settings",..
			"Identity", "Identity",..
			"IfMatch", "If-Match",..
			"IfModifiedSince", "If-Modified-Since",..
			"IfNoneMatch", "If-None-Match",..
			"IfRange", "If-Range",..
			"IfUnmodifiedSince", "If-Unmodified-Since",..
			"KeepAlive", "Keep-Alive",..
			"LastModified", "Last-Modified",..
			"Link", "Link",..
			"Location", "Location",..
			"MaxForwards", "Max-Forwards",..
			"MimeVersion", "Mime-Version",..
			"Negotiate", "Negotiate",..
			"Origin", "Origin",..
			"Pragma", "Pragma",..
			"ProxyAuthenticate", "Proxy-Authenticate",..
			"ProxyAuthorization", "Proxy-Authorization",..
			"ProxyConnection", "Proxy-Connection",..
			"Range", "Range",..
			"Referer", "Referer",..
			"RequestRange", "Request-Range",..
			"RetryAfter", "Retry-After",..
			"SecWebsocketAccept", "Sec-WebSocket-Accept",..
			"SecWebsocketExtensions", "Sec-WebSocket-Extensions",..
			"SecWebsocketKey", "Sec-WebSocket-Key",..
			"SecWebsocketSubprotocol", "Sec-WebSocket-Subprotocol",..
			"SecWebsocketVersion", "Sec-WebSocket-Version",..
			"Server", "Server",..
			"ServletEngine", "Servlet-Engine",..
			"SetCookie", "Set-Cookie",..
			"SetCookie2", "Set-Cookie2",..
			"StrictTransportSecurity", "Strict-Transport-Security",..
			"TE", "TE",..
			"TimingAllowOrigin", "Timing-Allow-Origin",..
			"Trailer", "Trailer",..
			"TransferEncoding", "Transfer-Encoding",..
			"Upgrade", "Upgrade",..
			"UserAgent", "User-Agent",..
			"Vary", "Vary",..
			"Via", "Via",..
			"Warning", "Warning",..
			"WWWAuthenticate", "WWW-Authenticate",..
			"XForwardedFor", "X-Forwarded-For",..
			"XForwardedHost", "X-Forwarded-Host",..
			"XForwardedPort", "X-Forwarded-Port",..
			"XForwardedProto", "X-Forwarded-Proto",..
			"XForwardedServer", "X-Forwarded-Server",..
			"XPoweredBy", "X-Powered-By"..
		]

		For Local i:Int = 0 Until headers.Length Step 2
			_nameToHeaderCache.Add( headers[i+1].ToLower(), EHttpHeader.FromString( headers[i] ) )
			_headerToNameCache.Add( EHttpHeader.FromString( headers[i] ), headers[i+1] )
		Next

	End Function

	Public

	Function HttpMethodToString:String( httpMethod:EHttpMethod )
		Return httpMethod.ToString().ToUpper()
	End Function

	Function StringToHttpMethod:EHttpMethod( httpMethod:String )
		Try
			Return EHttpMethod.FromString( httpMethod )
		Catch ex:Object
			Return EHttpMethod.Get
		End Try
	End Function

	Function HttpHeaderToString:String( header:EHttpHeader )
		Return _headerToNameCache[ header ]
	End Function

	Function StringToHttpHeader:EHttpHeader( header:String )

		Local _header:EHttpHeader
		If _nameToHeaderCache.TryGetValue( header.ToLower(), _header )
			Return _header
		End If

		Throw New TIllegalArgumentException("Unknown HTTP header: " + header)

	End Function

	Rem
	bbdoc: Encodes a string component for safe inclusion in a URL.
	End Rem
	Function UrlEncodeComponent:String(s:String)
		Return bmx_curl_easy_escape(s)
	End Function
End Type


THttpHelper.Init()
