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
Import Collections.ArrayList
Import Collections.HashMap

Rem
bbdoc: An HTTP Field/Header
about: Represents a single HTTP field/header, which can be identified either by its name (string) or by an enumeration value (EHttpHeader).
End Rem
Type THttpField
Private
	Field _header:EHttpHeader
	Field _set:Int ' header known
	Field _name:String
	Field _value:String
Public

	Rem
	bbdoc: Initializes a new #THttpField instance with the specified @header and @value.
	End Rem
	Method New(header:EHttpHeader, value:String)
		_header = header
		_set = True
		_name = THttpHelper.HttpHeaderToString( header )
		_value = value
	End Method

	Rem
	bbdoc: Initializes a new #THttpField instance with the specified @name and @value.
	about: The name can be a standard HTTP header name or a custom name.
	End Rem
	Method New(name:String, value:String)
		_set = THttpHelper._nameToHeaderCache.TryGetValue( name.ToLower(), _header )
		_name = name
		_value = value
	End Method

	Rem
	bbdoc: Checks if the header matches the specified @name.
	about: Headers with custom names can be added, so this method checks by string name.
	End Rem
	Method Is:Int(name:String)
		Return _name.ToLower() = name.ToLower()
	End Method

	Rem
	bbdoc: Returns the name of the HTTP field/header.
	End Rem
	Method GetName:String()
		Return _name
	End Method

	Rem
	bbdoc: Returns the value of the HTTP field/header.
	End Rem
	Method GetValue:String()
		Return _value
	End Method

	Rem
	bbdoc: Returns the enumeration value of the HTTP header.
	about: Throws an exception if the header was created with a custom name and does not correspond to a standard header.
	Use #TryGetHeader to safely attempt retrieval.
	End Rem
	Method GetHeader:EHttpHeader()
		If _set
			Return _header
		End If
		Throw New TInvalidOperationException("Custom header has no EHttpHeader value")
	End Method

	Rem
	bbdoc: Attempts to retrieve the name of the HTTP field/header.
	returns: #True if the name was retrieved; #False otherwise.
	about: This method is safe to use even if the header was created with a custom name.
	End Rem
	Method TryGetName:Int(name:String Var)
		If _name Then
			name = _name
			Return True
		End If
		Return False
	End Method

	Rem
	bbdoc: Attempts to retrieve the enumeration value of the HTTP header.
	returns: #True if the header corresponds to a standard header and the value was retrieved; #False otherwise.
	about: This method is safe to use even if the header was created with a custom name, and in such cases it will return #False.
	End Rem
	Method TryGetHeader:Int(header:EHttpHeader Var)
		If _set
			header = _header
			Return True
		End If
		Return False
	End Method

	Rem
	bbdoc: Returns a string representation of the HTTP field/header in the format "Name: Value".
	End Rem
	Method ToString:String()
		Return _name + ": " + _value
	End Method

End Type

Rem
bbdoc: A collection of HTTP fields/headers.
End Rem
Type THttpFields

	Field _fields:TArrayList<THttpField> = New TArrayList<THttpField>

	Rem
	bbdoc: Adds a new entry with the specified name and value.
	about: The name can be a standard HTTP header name or a custom name.
	returns: The newly created #THttpField instance.
	End Rem
	Method Add:THttpField(name:String, value:String)
		Local _field:THttpField = New THttpField(name, value)
		_fields.Add( _field )
		Return _field
	End Method

	Rem
	bbdoc: Adds a new entry with the specified @header and @value.
	returns: The newly created #THttpField instance.
	End Rem
	Method Add:THttpField(header:EHttpHeader, value:String)
		Local _field:THttpField = New THttpField(header, value)
		_fields.Add( _field )
		Return _field
	End Method

	Rem
	bbdoc: Adds all fields from another #THttpFields collection.
	End Rem
	Method Add( fields:THttpFields )
		For Local f:THttpField = EachIn fields
			_fields.Add( f )
		Next
	End Method

	Rem
	bbdoc: Adds the specified #THttpField to the collection.
	returns: The added #THttpField instance.
	End Rem
	Method Add:THttpField( _field:THttpField )
		_fields.Add( _field )
		Return _field
	End Method

	Rem
	bbdoc: Retrieves the first value associated with the specified field name.
	returns: The value of the field, or #Null if not found.
	End Rem
	Method GetFirst:String(name:String)
		For Local f:THttpField = EachIn _fields
			If f.Is( name )
				Return f.GetValue()
			End If
		Next
		Return Null
	End Method

	Rem
	bbdoc: Retrieves the first value associated with the specified @header.
	returns: The value of the header, or #Null if not found.
	End Rem
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
	Method Add:THttpField( line:String )
		Local sepPos:Int = line.Find( ":" )
		If sepPos > 0
			Local name:String = line[..sepPos].Trim()
			Local value:String = line[sepPos + 1..].Trim()
			Return Add( name, value )
		End If
		' Return Self
	End Method

	Rem
	bbdoc: Checks if a header with the specified @name exists in the collection.
	about: Headers with custom names can be added, so this method checks by string name.
	End Rem
	Method HasHeader:Int(name:String)
		For Local f:THttpField = EachIn _fields
			If f.Is( name )
				Return True
			End If
		Next
		Return False
	End Method

	Rem
	bbdoc: Checks if a header with the specified @header exists in the collection.
	End Rem
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
	bbdoc: Converts the headers to a #TSList suitable for libcurl.
	End Rem
	Method ToSList:TSList()
		Local slist:TSList = New TSList
		For Local f:THttpField = EachIn _fields
			slist.Append( f.GetName() + ": " + f.GetValue() )
		Next
		Return slist
	End Method

	Rem
	bbdoc: Checks if the collection is empty.
	End Rem
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

Rem
bbdoc: HTTP methods.
End Rem
Enum EHttpMethod
	Get
	Post
	Put
	Delete
	Head
	Options
	Patch
	Trace
	Connect
	Query
End Enum

Rem
bbdoc: HTTP headers.
about: Represents standard HTTP headers that can be used in requests and responses.

| Header | String | Description |
|--------|--------|-------------|
| Accept | "Accept" | Specifies the media types that are acceptable for the response. |
| AcceptCharset | "Accept-Charset" | Specifies the character sets that are acceptable for the response. |
| AcceptEncoding | "Accept-Encoding" | Specifies the content encodings that are acceptable for the response. |
| AcceptLanguage | "Accept-Language" | Specifies the preferred languages for the response. |
| AcceptRanges | "Accept-Ranges" | Indicates that the server supports range requests for the resource. |
| AccessControlAllowCredentials | "Access-Control-Allow-Credentials" | Indicates whether the response to the request can be exposed when the credentials flag is true. |
| AccessControlAllowHeaders | "Access-Control-Allow-Headers" | Specifies the headers that can be used during the actual request. |
| AccessControlAllowMethods | "Access-Control-Allow-Methods" | Specifies the methods allowed when accessing the resource in response to a preflight request. |
| AccessControlAllowOrigin | "Access-Control-Allow-Origin" | Specifies the origin that is allowed to access the resource. |
| AccessControlExposeHeaders | "Access-Control-Expose-Headers" | Indicates which headers can be exposed as part of the response by listing their names. |
| AccessControlMaxAge | "Access-Control-Max-Age" | Indicates how long the results of a preflight request can be cached. |
| AccessControlRequestHeaders | "Access-Control-Request-Headers" | Used in preflight requests to indicate which HTTP headers will be used when the actual request is made. |
| AccessControlRequestMethod | "Access-Control-Request-Method" | Used in preflight requests to indicate which HTTP method will be used when the actual request is made. |
| Age | "Age" | Indicates the age of the object in a proxy cache. |
| Allow | "Allow" | Lists the set of methods supported by the resource. |
| AltSvc | "Alt-Svc" | Indicates alternative services available for the resource. |
| Authorization | "Authorization" | Contains the credentials to authenticate a user agent with a server. |
| CAuthority | "C-Authority" | Used in HTTP CONNECT requests to specify the authority component of the target URI. |
| CMethod | "C-Method" | Used in HTTP CONNECT requests to specify the method to be used when establishing a tunnel. |
| CPath | "C-Path" | Used in HTTP CONNECT requests to specify the path component of the target URI. |
| CProtocol | "C-Protocol" | Used in HTTP CONNECT requests to specify the protocol to be used when establishing a tunnel. |
| CScheme | "C-Scheme" | Used in HTTP CONNECT requests to specify the scheme component of the target URI. |
| CStatus | "C-Status" | Used in HTTP CONNECT responses to indicate the status of the connection attempt. |
| CacheControl | "Cache-Control" | Directives for caching mechanisms in both requests and responses. |
| Connection | "Connection" | Controls whether the network connection stays open after the current transaction finishes. |
| ContentDisposition | "Content-Disposition" | Indicates if the content is expected to be displayed inline or as an attachment. |
| ContentEncoding | "Content-Encoding" | Specifies the encoding used on the data. |
| ContentLanguage | "Content-Language" | Describes the natural language(s) of the intended audience for the resource. |
| ContentLength | "Content-Length" | The size of the response body in bytes. |
| ContentLocation | "Content-Location" | Indicates an alternate location for the returned data. |
| ContentMD5 | "Content-MD5" | A base64-encoded binary MD5 sum of the content of the response. |
| ContentRange | "Content-Range" | Indicates the part of a document that the server is returning. |
| ContentTransferEncoding | "Content-Transfer-Encoding" | Specifies the encoding used to safely transfer the payload body to the user. |
| ContentType | "Content-Type" | Indicates the media type of the resource. |
| Cookie | "Cookie" | Contains stored HTTP cookies previously sent by the server with the Set-Cookie header. |
| Date | "Date" | The date and time at which the message was originated. |
| ETag | "ETag" | A unique identifier for a specific version of a resource. |
| Expect | "Expect" | Indicates that particular server behaviors are required by the client. |
| Expires | "Expires" | Gives the date/time after which the response is considered stale. |
| Forwarded | "Forwarded" | Discloses information about the client and proxy servers. |
| From | "From" | The email address of the user making the request. |
| Host | "Host" | Specifies the domain name of the server and the TCP port number on which the server is listening. |
| Http2Settings | "HTTP2-Settings" | Contains HTTP/2 settings that are to be applied to the connection. |
| Identity | "Identity" | Indicates that no encoding has been performed on the entity body. |
| IfMatch | "If-Match" | Makes the request conditional on the recipient matching one of the listed ETags. |
| IfModifiedSince | "If-Modified-Since" | Makes the request conditional on the resource being modified since the specified date. |
| IfNoneMatch | "If-None-Match" | Makes the request conditional on the recipient not matching any of the listed ETags. |
| IfRange | "If-Range" | Makes the request conditional: if the entity is unchanged, send the part(s) of the entity that are requested; otherwise, send the entire new entity. |
| IfUnmodifiedSince | "If-Unmodified-Since" | Makes the request conditional on the resource not being modified since the specified date. |
| KeepAlive | "Keep-Alive" | Used to signal that the connection should be kept alive after the current request/response. |
| LastModified | "Last-Modified" | The date and time at which the resource was last modified. |
| Link | "Link" | Used to define relationships between the current document and other resources. |
| Location | "Location" | Used in redirection or when a new resource has been created. |
| MaxForwards | "Max-Forwards" | Limits the number of times a request can be forwarded by proxies. |
| MimeVersion | "Mime-Version" | Indicates the version of MIME used in the message. |
| Negotiate | "Negotiate" | Used to initiate content negotiation. |
| Origin | "Origin" | Indicates the origin of the request, typically used in CORS requests. |
| Pragma | "Pragma" | Implementation-specific directives that might apply to any recipient along the request/response chain. |
| ProxyAuthenticate | "Proxy-Authenticate" | Request authentication to access a proxy. |
| ProxyAuthorization | "Proxy-Authorization" | Contains the credentials to authenticate a user agent with a proxy server. |
| ProxyConnection | "Proxy-Connection" | Controls whether the network connection to the proxy stays open after the current transaction finishes. |
| Range | "Range" | Requests only a portion of an entity. |
| Referer | "Referer" | The address of the previous web page from which a link to the currently requested page was followed. |
| RequestRange | "Request-Range" | Used to request a specific range of bytes from a resource. |
| RetryAfter | "Retry-After" | Indicates how long the user agent should wait before making a follow-up request. |
| SecWebsocketAccept | "Sec-WebSocket-Accept" | Used in the WebSocket handshake to confirm the server's acceptance of the connection. |
| SecWebsocketExtensions | "Sec-WebSocket-Extensions" | Lists the extensions that are used in the WebSocket connection. |
| SecWebsocketKey | "Sec-WebSocket-Key" | A base64-encoded value that is used in the WebSocket handshake to establish the connection. |
| SecWebsocketSubprotocol | "Sec-WebSocket-Subprotocol" | Lists the subprotocols that are used in the WebSocket connection. |
| SecWebsocketVersion | "Sec-WebSocket-Version" | Indicates the WebSocket protocol version that the client wishes to use. |
| Server | "Server" | Contains information about the software used by the origin server to handle the request. |
| ServletEngine | "Servlet-Engine" | Identifies the servlet engine handling the request. |
| SetCookie | "Set-Cookie" | Sends cookies from the server to the user agent. |
| SetCookie2 | "Set-Cookie2" | An updated version of the Set-Cookie header, used to send cookies from the server to the user agent. |
| StrictTransportSecurity | "Strict-Transport-Security" | Informs browsers that the site should only be accessed using HTTPS. |
| TE | "TE" | Indicates what transfer encodings the user agent is willing to accept. |
| TimingAllowOrigin | "Timing-Allow-Origin" | Indicates which origins are allowed to see the timing information for the resource. |
| Trailer | "Trailer" | Indicates that the given set of header fields is present in the trailer of a message encoded with chunked transfer coding. |
| TransferEncoding | "Transfer-Encoding" | Specifies the form of encoding used to safely transfer the payload body to the user. |
| Upgrade | "Upgrade" | Asks the server to switch to another protocol. |
| UserAgent | "User-Agent" | Contains information about the user agent originating the request. |
| Vary | "Vary" | Indicates the set of request headers that determine whether a cached response can be used rather than requesting a fresh one from the origin server. |
| Via | "Via" | Informs the server of proxies through which the request was sent. |
| Warning | "Warning" | Carries additional information about the status or transformation of a message that might not be reflected in the message itself. |
| WWWAuthenticate | "WWW-Authenticate" | Indicates the authentication scheme that should be used to access the requested resource. |
| XForwardedFor | "X-Forwarded-For" | Identifies the originating IP address of a client connecting to a web server through an HTTP proxy or load balancer. |
| XForwardedHost | "X-Forwarded-Host" | Identifies the original host requested by the client in the Host HTTP request header. |
| XForwardedPort | "X-Forwarded-Port" | Identifies the original port requested by the client. |
| XForwardedProto | "X-Forwarded-Proto" | Identifies the protocol (HTTP or HTTPS) that a client used to connect to the proxy or load balancer. |
| XForwardedServer | "X-Forwarded-Server" | Identifies the original server name requested by the client. |
| XPoweredBy | "X-Powered-By" | Indicates the technology (e.g., framework, server) used by the web server. |

End Rem
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
about: These flags can be used to specify the authentication methods to be used for HTTP requests.
Can be combined using bitwise `|` operator.

| Flag | Description |
|------|-------------|
| None | No authentication. |
| Basic | Basic authentication. |
| Digest | Digest authentication. |
| Negotiate | Negotiate authentication (SPNEGO/Kerberos). |
| NtLm | NTLM authentication. |
| DigestIE | Digest authentication for Internet Explorer. |
| Bearer | Bearer token authentication (e.g., OAuth). |
| AwsSigV4 | AWS Signature Version 4 authentication. |
| Only | This is a meta symbol. OR this value together with a single specific auth value to force it to probe for unrestricted auth and if not, only that single auth algorithm is acceptable. |
| Any | Allows any authentication method. Uses the one it finds most secure. |
| AnySafe | Allows any safe authentication method (excludes Basic). Uses the one it finds most secure. |

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

	Global _nameToHeaderCache:THashMap<String,EHttpHeader> = New THashMap<String,EHttpHeader>
	Global _headerToNameCache:THashMap<EHttpHeader,String> = New THashMap<EHttpHeader,String>

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

	' Encodes a string component for safe inclusion in a URL.
	Function UrlEncodeComponent:String(s:String)
		Return bmx_curl_easy_escape(s)
	End Function

End Type

Rem
bbdoc: An exception representing an HTTP client error.
End Rem
Type THttpClientException Extends TRuntimeException

	Field status:Int

	Method New(status:Int, message:String)
		Super.New(message)
		Self.status = status
	End Method

End Type


THttpHelper.Init()
