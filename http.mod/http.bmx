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

Module Net.Http

Import BRL.Stream

Import "http_util.bmx"
Import "http_url.bmx"
Import "http_ca.bmx"
Import "http_cookie.bmx"


Interface ICompleteListener
	Method OnComplete(result:THttpResult)
End Interface

Rem
bbdoc: HTTP Result.
End Rem
Type THttpResult
	Field request:THttpRequest
	Field response:THttpResponse

	Method IsSucceeded:Int()
		Return response <> Null And response.IsSuccess()
	End Method

	Method IsFailed:Int()
		Return Not IsSucceeded()
	End Method
End Type

Rem
bbdoc: An HTTP Response.
about: Represents the response received from an HTTP request, including status code, headers, and body content.
End Rem
Type THttpResponse
	Field status:Int
	Field reason:String
	Field headers:THttpFields = New THttpFields
	Field body:Byte[]
	Field curlCode:Int
	Field curlErr:String
	Field effectiveUrl:String
	Field bytesReceived:Long

	Method IsSuccess:Int()
		Return status >= 200 And status < 300 And curlCode = 0
	End Method

	Rem
	bbdoc: Returns the response body as a string, assuming UTF-8 encoding.
	End Rem
	Method AsString:String()
		If body Then
			Return String.FromUTF8Bytes(body, body.Length)
		End If
		Return ""
	End Method

	Rem
	bbdoc: Returns the response body as a byte array.
	about: If @copy is False, the original data is returned, rather than a copy.
	End Rem
	Method AsBytes:Byte[](copy:Int = True)
		If copy Then
			Return body[..]
		End If
		Return body
	End Method

	Method ErrorMessage:String()
		If curlCode <> 0 Then Return "curl(" + curlCode + ") " + curlErr
		If status > 0 Then Return "HTTP " + status + " " + reason
		Return "Unknown error"
	End Method
End Type

Type THttpRequest
	Field _client:THttpClient

	Field _headers:THttpFields = New THttpFields

	Field _acceptCompressed:Int = True
	Field _connectTimeoutMS:Int = 10000
	Field _totalTimeoutMS:Int = 30000

	Field _method:String

	Field _url:TUrl
	Field _scheme:String
	Field _host:String
	Field _port:Int
	Field _path:String
	Field _query:String
	Field _params:THttpFields = New THttpFields

	Field _followRedirects:Int = True
	Field _user:String
	Field _password:String
	Field _authMethod:EHttpAuthMethod = EHttpAuthMethod.None

	Field _content:TContent

	Field _sink:TSink

	' TODO Field _cookies:THttpCookies = New THttpCookies


	' completion state (filled after sync send or by engine for inspection)
	Field _response:THttpResponse
	Field _listener:ICompleteListener

	Method Create:THttpRequest(client:THttpClient, _method:String, url:TUrl)
		_client = client
		Self._method = _method
		Self._url = url
		Return Self
	End Method

	 Method Create:THttpRequest(client:THttpClient, _method:String, url:String)
		_client = client
		Self._method = _method
		Self._url = New TUrl(url)
		Return Self
	End Method

	' ---- fluent config ----
	Method Header:THttpRequest(key:String, value:String)
		_headers.Add(key,value)
		Return Self
	End Method

	Method Header:THttpRequest(key:EHttpHeader, value:String)
		_headers.Add(key,value)
		Return Self
	End Method

	Method Body:THttpRequest(text:String, contentType:String = "text/plain; charset=utf-8")
		_content = New TStringContent(text, contentType)
		Return Self
	End Method

	Method Body:THttpRequest(stream:TStream, length:Long, contentType:String = "application/octet-stream")
		_content = New TStreamContent(stream, length, contentType)
		Return Self
	End Method

	Method AuthMethod:THttpRequest(auth:EHttpAuthMethod)
		_authMethod = auth
		Return Self
	End Method

	Method AcceptCompressed:THttpRequest(enable:Int)
		_acceptCompressed = enable
		Return Self
	End Method

	Method Timeouts:THttpRequest(connectMS:Int, totalMS:Int)
		_connectTimeoutMS = connectMS
		_totalTimeoutMS = totalMS
		Return Self
	End Method

	Method Scheme:THttpRequest(scheme:String)
		_scheme = scheme
		_url = null
		Return Self
	End Method

	Method Host:THttpRequest(host:String)
		_host = host
		_url = null
		Return Self
	End Method

	Method Port:THttpRequest(port:Int)
		_port = port
		_url = null
		Return Self
	End Method

	Rem
	bbdoc: Sets the user and password for HTTP authentication.
	about: When using Kerberos V5 authentication with a Windows based server, you should specify the username part with the domain name in order
	for the server to successfully obtain a Kerberos Ticket. If you do not then the initial part of the authentication handshake may fail.

	When using NTLM, the username can be specified simply as the username without the domain name should the server be part of a single domain and forest.

	To specify the domain name use either Down-Level Logon Name or UPN (User Principal Name) formats. For example `EXAMPLE\user` and `user@example.com` respectively.

	Some HTTP servers (on Windows) support inclusion of the domain for Basic authentication as well.
	End Rem
	Method UserPassword:THttpRequest(user:String, password:String)
		_user = user
		_password = password
		Return Self
	End Method

	Method User:THttpRequest(user:String)
		_user = user
		Return Self
	End Method

	Method Password:THttpRequest(password:String)
		_password = password
		Return Self
	End Method

	Method FollowRedirects:THttpRequest(follow:Int)
		_followRedirects = follow
		Return Self
	End Method

	Method GetPath:String()
		Return _path
	End Method

	Method GetQuery:String()
		Return _query
	End Method

	Method GetScheme:String()
		Return _scheme
	End Method

	Rem
	bbdoc: Sets the output stream where the response body will be written.
	about: If not set, the response body will be stored in memory and can be accessed via the @THttpResponse object.
	End Rem
	Method OutputStream:THttpRequest(s:TStream)
		_sink = New TStreamSink(s)
		Return Self
	End Method

	Method GetUrl:TUrl()
		If Not _url Then
			_url = BuildUrl(True)
		End If

		Return _url
	End Method

	Method IsFollowingRedirects:Int()
		Return _followRedirects
	End Method

	' ---- send ----
	Method Send:THttpResponse()
		If Not _sink Then
			_sink = New TMemorySink
		End If
		Local w:TWaiter = New TWaiter
		_client.Submit(Self, w)
		Local result:THttpResult = w.Await()
		_response = result.response
		Return _response
	End Method

	Method SendAsync(listener:ICompleteListener)
		 If Not _sink Then
			_sink = New TMemorySink
		End If
		_listener = listener
		_client.Submit(Self)
	End Method

	' convenience
	Method Response:THttpResponse()
		Return _response
	End Method

	Method IsSucceeded:Int()
		If _response Then
			Return _response.IsSuccess()
		End If
		Return False
	End Method

	Method IsFailed:Int()
		Return Not IsSucceeded()
	End Method


	Private

	Method BuildUrl:TUrl(withQuery:Int)
		Local path:String = GetPath()
		Local query:String = GetQuery()

		If query And withQuery Then
			path :+ "?" + query
		End If

		Local result:TUrl = New TUrl(path)

		If result.IsAbsolute() Then
			Return result
		End If

		Local builder:TUrlBuilder = TUrl.Builder()..
			.Scheme(_scheme)..
			.Host(_host)..
			.Port(_port)..
			.Path(path)
		
		Return builder.Build()

	End Method
End Type

Type TEasyContext
	Field request:THttpRequest
	Field response:THttpResponse
	Field easy:TCurlEasy
	Field waiter:IWaiter
	Field sink:TSink

	Field slist:TSlist

	Method Delete()
		If slist Then
			slist.Free()
		End If
	End Method
End Type

Type TRequestEnvelope
	Field client:THttpClient
	Field request:THttpRequest
	Field context:TEasyContext
	Field waiter:IWaiter
End Type

Interface IWaiter
	Method Deliver(result:THttpResult)
End Interface

' A simple waiter implementation using mutex/condvar
Type TWaiter Implements IWaiter
	Field _mu:TMutex = CreateMutex()
	Field _cv:TCondVar = CreateCondVar()
	Field _done:Int
	Field _res:THttpResult

	Method Deliver(result:THttpResult) Override
		LockMutex _mu
		_res = result
		_done = True
		SignalCondVar _cv
		UnlockMutex _mu
	End Method

	Method Await:THttpResult()
		LockMutex _mu
		While Not _done
			WaitCondVar _cv, _mu
		Wend
		Local r:THttpResult = _res
		UnlockMutex _mu
		Return r
	End Method
End Type

Rem
bbdoc: HTTP Client for sending requests and receiving responses.
End Rem
Type THttpClient
	Field _multi:TCurlMulti
	Field _thread:TThread
	Field _running:Int
	Field _inQueue:TConcurrentQueue<TRequestEnvelope> = New TConcurrentQueue<TRequestEnvelope>
	Field _followRedirects:Int = True

	Field _caStore:TCAStore

	Function Create:THttpClient()
		Local client:THttpClient = New THttpClient
		client._multi = TCurlMulti.Create()
		Return client
	End Function

	Method Start()
		_running = True
		_thread = CreateThread(_ClientMain, Self)
	End Method

	Method Shutdown()
		If Not _running Then
			Return
		End If
		_running = False
		_inQueue.Close()
		_thread.Wait()
		_multi.multiCleanup()
	End Method

	Rem
	bbdoc: Creates a new GET request for the specified URL.
	End Rem
	Method Get:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, "GET", url)
		request.FollowRedirects(_followRedirects)
		Return request
	End Method
	
	Rem
	bbdoc: Creates a new POST request for the specified URL.
	End Rem
	Method Post:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, "POST", url)
		request.FollowRedirects(_followRedirects)
		Return request
	End Method

	Rem
	bbdoc: Creates a new PUT request for the specified URL.
	End Rem
	Method Put:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, "PUT", url)
		request.FollowRedirects(_followRedirects)
		Return request
	End Method

	Method SetFollowRedirects(follow:Int)
		_followRedirects = follow
	End Method

	Method IsFollowingRedirects:Int()
		Return _followRedirects
	End Method

	Rem
	bbdoc: Sets the CA certificates for SSL/TLS verification from a file path.
	End Rem
	Method SetCACerts(path:String)
		_caStore = New TFileCAStore(path)
	End Method

	Rem
	bbdoc: Sets the CA certificates for SSL/TLS verification from a byte array.
	End Rem
	Method SetCACerts(certs:Byte[])
		_caStore = New TBlobCAStore()
		TBlobCAStore(_caStore).SetBlob(certs)
	End Method

	Rem
	bbdoc: Sets the CA certificates for SSL/TLS verification from a CA store.
	End Rem
	Method SetCACerts(store:TCAStore)
		_caStore = store
	End Method

	Rem
	bbdoc: Sets the CA certificates for SSL/TLS verification from a stream.
	End Rem
	Method SetCACerts(stream:TStream)
		Local bytes:Byte[] = LoadByteArray(stream)
		_caStore = New TBlobCAStore()
		TBlobCAStore(_caStore).SetBlob(bytes)
	End Method

Private
	Function _ClientMain:Object(arg:Object)
		THttpClient(arg).Run()
		Return Null
	End Function

	Method Submit(request:THttpRequest, waiter:IWaiter = Null)
		Local env:TRequestEnvelope = New TRequestEnvelope
		env.client = Self
		env.request = request
		env.waiter = waiter
		_inQueue.Push env
	End Method

	Method Run()
		Local still:Int
		While _running

			Local env:TRequestEnvelope = _inQueue.TryPop()
			While True
				If env = Null Then
					Exit
				End If
				Local context:TEasyContext = PrepareContext(env)
				env.context = context

				env = _inQueue.TryPop()
			Wend

			_multi.multiPerform(still)

			Local ms:Int
			_multi.multiTimeout(ms)

			If ms < 0 Or ms > 5000 Then
				ms = 1000
			End If
			
			Local numfds:Int
			_multi.multiPoll(Int(ms), numfds)

			Local msg:TCurlMultiMsg
			Repeat
				Local messagesInQueue:Int
				msg = _multi.multiInfoRead(messagesInQueue)
				
				If Not msg Then
					Exit
				End If

				If msg.message = CURLMSG_DONE Then
					Local easy:TCurlEasy = msg.easy
					Local code:Int = msg.result
					Local ctx:TEasyContext
					Local info:TCurlInfo = easy.getInfo()

					ctx = TEasyContext(info.privateData())

					ctx.response.curlCode = code
					
					If code <> 0 Then
						ctx.response.curlErr = String.FromCString(curl_easy_strerror(code))
					End If

					ctx.response.status = info.responseCode()
					ctx.response.effectiveUrl = info.effectiveURL()

					' finalize sinks
					If TMemorySink(ctx.sink) Then
						ctx.response.body = TMemorySink(ctx.sink).GetData()
						ctx.response.bytesReceived = ctx.response.body.Length
					Else If TStreamSink(ctx.sink) Then
						ctx.response.bytesReceived = TStreamSink(ctx.sink).total
					End If

					_multi.multiRemove(easy)
					
					If ctx.slist Then
						ctx.slist.Free()
					End If

					easy.cleanup()

					Local result:THttpResult = New THttpResult
					result.request = ctx.request
					result.response = ctx.response
					ctx.request._response = ctx.response

					If ctx.waiter Then
						ctx.waiter.Deliver(result)
					End If

					If ctx.request._listener Then
						ctx.request._listener.OnComplete(result)
					End If
				End If
			Forever
		Wend
		' best-effort drain
		Local msg2:TCurlMultiMsg
		Local messagesInQueue:Int
		Repeat
			msg2 = _multi.multiInfoRead(messagesInQueue)
			If Not msg2 Then
				Exit
			End If
		Forever
	End Method

	Method PrepareContext:TEasyContext(env:TRequestEnvelope)
		Local request:THttpRequest = env.request
		Local context:TEasyContext = New TEasyContext
		context.request = request
		context.response = New THttpResponse
		context.waiter = env.waiter
		context.easy = env.client._multi.newEasy()

		If Not context.easy Then
			Local reponse:THttpResponse = New THttpResponse
			reponse.curlCode = -1
			reponse.curlErr = "Failed to create curl easy handle"

			Local result:THttpResult = New THttpResult
			result.request = request
			result.response = reponse

			If env.waiter Then
				env.waiter.Deliver(result)
			End If
			If request._listener Then
				request._listener.OnComplete(result)
			End If
			Return context
		End If

		Local easy:TCurlEasy = context.easy

		If request.GetUrl().GetScheme() = "https" Then
			ConfigureSSL(easy)
		End If

		easy.setOptString(CURLOPT_URL, request.GetUrl().ToString())

		easy.setOptInt(CURLOPT_FOLLOWLOCATION, request.IsFollowingRedirects())

		If request._user Then
			easy.setOptString(CURLOPT_USERNAME, request._user)
		End If

		If request._password Then
			easy.setOptString(CURLOPT_PASSWORD, request._password)
		End If

		easy.setOptInt(CURLOPT_HTTPAUTH, request._authMethod.Ordinal())

		'easy.setOptInt(CURLOPT_VERBOSE, 1)

		' Method + body handling
		Local hasBody:Int = (request._content <> Null)
		Select request._method
			Case "GET", "HEAD", "DELETE"
				If request._method = "HEAD" Then
					easy.setOptInt(CURLOPT_NOBODY, 1)
				Else
					easy.setOptInt(CURLOPT_HTTPGET, 1)
				End If
				If hasBody Then ' uncommon but allowed for DELETE
					easy.setOptString(CURLOPT_CUSTOMREQUEST, request._method)
					easy.setOptInt(CURLOPT_UPLOAD, 1)
				End If
			Case "POST"
				easy.setOptInt(CURLOPT_POST, 1)

				If hasBody Then
					easy.setReadCallback(_ContentRead, request._content)

					Local length:Long = request._content.GetLength()
					If length >= 0 Then
						easy.setOptLong(CURLOPT_POSTFIELDSIZE_LARGE, length)
					End If
				Else
					easy.setOptLong(CURLOPT_POSTFIELDSIZE, 0)
				End If
			Default ' PUT, PATCH, etc.
				easy.setOptString(CURLOPT_CUSTOMREQUEST, request._method)

				If hasBody Then
					easy.setOptInt(CURLOPT_UPLOAD, 1)
					easy.setReadCallback(_ContentRead, request._content)
 
					Local length:Long = request._content.GetLength()
					If length >= 0 Then
						easy.setOptLong(CURLOPT_INFILESIZE_LARGE, length)
					End If
				End If
		End Select

		' headers
		Local hasContentType:Int = False
		If request._headers.HasHeader(EHttpHeader.ContentType) Then
			hasContentType = True
		End If

		If request._content And Not hasContentType Then
			request._headers.Add(EHttpHeader.ContentType, request._content.GetContentType())
		End If

		If Not request._headers.IsEmpty() Then
			context.slist = request._headers.ToSList()

			bmx_curl_easy_setopt_slist(easy.easyHandlePtr, CURLOPT_HTTPHEADER, context.slist.slist)
		End If

		' timeouts & compression
		' curl_easy_setopt_int(ctx.easy, CURLOPT_CONNECTTIMEOUT_MS, req.connectTimeoutMS)
		' curl_easy_setopt_int(ctx.easy, CURLOPT_TIMEOUT_MS, req.totalTimeoutMS)
		' If req.acceptCompressed Then curl_easy_setopt_string(ctx.easy, CURLOPT_ACCEPT_ENCODING, "")

		' response sink
		If request._sink <> Null Then
			context.sink = request._sink
		Else
		   context.sink = New TMemorySink
		End If

		' response callback
		easy.setWriteCallback(_ResponseWrite, context)

		' header callback
		easy.setHeaderCallback(_HeaderRead, context)

		' store our context in the private backpointer
		easy.setPrivate(context)

		Return context
	End Method

	' Content read callback
	Function _ContentRead:Size_T(buffer:Byte Ptr, size:Size_T, data:Object)
		Local content:TContent = TContent(data)
		If Not content Then
			Return 0
		End If
		Return content.Read(buffer, size)
	End Function

	' Response callback
	Function _ResponseWrite:Size_T(buffer:Byte Ptr, size:Size_T, data:Object)
		Local context:TEasyContext = TEasyContext(data)

		Return context.sink.Write(buffer, size)
	End Function

	' Header callback
	Function _HeaderRead:Size_T(buffer:Byte Ptr, size:Size_T, data:Object)
		Local context:TEasyContext = TEasyContext(data)

		Local header:String = String.FromUTF8Bytes(buffer, Int(size))
		context.response.headers.Add(header)

		Return size
	End Function

	Method ConfigureSSL(easy:TCurlEasy)
		' if the user hasn't set a CA store, use our default
		If Not _caStore Then
			_caStore = TCAStoreProvider.INSTANCE.GetStore()
		End If

		If _caStore Then
			If _caStore.IsAFile()
				Local path:String = _caStore.CertsAsPath()
				If path Then
					easy.setOptString(CURLOPT_CAINFO, path)
				End If
			Else ' blob
				Local blob:Byte[] = _caStore.CertsAsBlob()
				If blob Then
					easy.setOptCAInfoBlob(blob, blob.Length)
				End If
			End If
		End If
	End Method
End Type

' Response sinks
Type TSink Abstract
	' returns bytes written (should equal size); returning less signals error to curl
	Method Write:Size_T(buffer:Byte Ptr, size:Size_T) Abstract
	Method Close()
	End Method
End Type

Type TMemorySink Extends TSink
	Field data:Byte[1024]
	Field size:Size_T

	Method Write:Size_T(buffer:Byte Ptr, count:Size_T) Override

		If count = 0 Then
			Return 0
		End If

		If size + count > data.Length Then
			Local newSize:Size_T = data.Length * 3/2 + count
			data = data[..newSize] ' preserve existing data
		End If

		' append new data
		Local buf:Byte Ptr = data
		MemCopy(buf + size, buffer, count)
		size :+ count

		Return count
	End Method

	Method GetData:Byte[]()
		If size Then
			' trim to size
			Return data[..size]
		End If
		Return Null
	End Method
End Type

Type TStreamSink Extends TSink
	Field stream:TStream
	Field total:Long

	Method New(s:TStream)
		stream = s
	End Method

	Method Write:Size_T(buffer:Byte Ptr, count:Size_T) Override
		If count = 0 Then
			Return 0
		End If
		Local wrote:Int = stream.Write(buffer, Int(count))
		total :+ wrote
		Return wrote
	End Method
End Type

Type TConcurrentQueue<T>
	Field _lock:TMutex = CreateMutex()
	Field _cv:TCondVar = CreateCondVar()
	Field _q:TList = New TList
	Field _closed:Int

	Method Push(item:T)
		LockMutex _lock
		If _closed Then
			UnlockMutex _lock
			Throw "closed"'New TBlitzException("Queue closed")
		End If
		_q.AddLast(item)
		SignalCondVar _cv
		UnlockMutex _lock
	End Method

	Method Close()
		LockMutex _lock
		_closed = True
		BroadcastCondVar _cv
		UnlockMutex _lock
	End Method

	Method PopWait:T()
		LockMutex _lock
		While _q.IsEmpty() And Not _closed
			WaitCondVar _cv, _lock
		Wend
		Local v:T
		If Not _q.IsEmpty() Then
			v = T(_q.RemoveFirst())
		End If
		UnlockMutex _lock
		Return v
	End Method

	Method TryPop:T()
		LockMutex _lock
		Local v:T
		If Not _q.IsEmpty() Then
			v = T(_q.RemoveFirst())
		End If
		UnlockMutex _lock
		Return v
	End Method

	Method IsClosed:Int()
		LockMutex _lock
		Local c:Int = _closed
		UnlockMutex _lock
		Return c
	End Method
End Type

Type TContent Abstract

	Field _contentType:String = "application/octet-stream"

	Method GetContentType:String()
		Return _contentType
	End Method

	Method GetLength:Long()
		Return -1
	End Method

	' returns number of bytes read, or 0 on EOF
	Method Read:Size_T(buffer:Byte Ptr, size:Size_T) Abstract

End Type

Type TStringContent Extends TContent
	Field _data:Byte Ptr
	Field _size:Size_T
	Field _pos:Size_T
	Field data:String

	Method New(data:String, contentType:String = Null)
		Self.data = data
		If contentType Then
			_contentType = contentType
		Else
			_contentType = "text/plain; charset=utf-8"
		End If
		_pos = 0
		_data = data.ToUTF8String(_size)
	End Method

	Method GetLength:Long() Override
		Return _size
	End Method

	Method Read:Size_T(buffer:Byte Ptr, size:Size_T) Override
		If _pos >= _size Then Return 0

		Local toRead:Size_T = size
		If _pos + toRead > _size Then
			toRead = _size - _pos
		End If

		MemCopy(buffer, _data + _pos, toRead)
		_pos :+ toRead
		Return toRead
	End Method

	Method Delete()
		If _data Then
			MemFree(_data)
			_data = Null
		End If
	End Method
End Type

Type TStreamContent Extends TContent
	Field _stream:TStream
	Field _length:Long

	Method New(stream:TStream, length:Long, contentType:String)
		Self._stream = stream
		Self._length = length
		If contentType Then
			_contentType = contentType
		End If
	End Method

	Method GetLength:Long() Override
		Return _length
	End Method

	Method Read:Size_T(buffer:Byte Ptr, size:Size_T) Override
		Return _stream.Read(buffer, size)
	End Method
End Type

Type TBytePtrContent Extends TContent
	Field _data:Byte Ptr
	Field _size:Size_T
	Field _pos:Size_T

	Method New(data:Byte Ptr, size:Size_T, contentType:String = Null)
		Self._data = data
		Self._size = size
		Self._pos = 0
		If contentType Then
			_contentType = contentType
		End If
	End Method

	Method GetLength:Long() Override
		Return _size
	End Method

	Method Read:Size_T(buffer:Byte Ptr, size:Size_T) Override
		If _pos >= _size Then
			Return 0
		End If

		Local toRead:Size_T = size
		If _pos + toRead > _size Then
			toRead = _size - _pos
		End If

		MemCopy(buffer, _data + _pos, toRead)
		_pos :+ toRead
		Return toRead
	End Method
End Type
