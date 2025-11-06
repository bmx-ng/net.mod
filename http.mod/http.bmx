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

Rem
bbdoc: HTTP Client
about: Provides classes and methods for making HTTP requests and handling responses.
End Rem
Module Net.Http

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/png"
ModuleInfo "Copyright: 2025 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Stream
Import BRL.Math

Import "http_util.bmx"
Import "http_url.bmx"
Import "http_ca.bmx"
Import "http_cookie.bmx"

Rem
bbdoc: Listener interface for asynchronous HTTP request completion.
End Rem
Interface ICompleteListener
	Rem
	bbdoc: Called when the HTTP request is complete.
	End Rem
	Method OnComplete(result:THttpResult)
End Interface

Rem
bbdoc: HTTP Result.
End Rem
Type THttpResult
	Field request:THttpRequest
	Field response:THttpResponse

	Rem
	bbdoc: Returns whether the HTTP request was successful.
	End Rem
	Method IsSucceeded:Int()
		Return response <> Null And response.IsSuccess()
	End Method

	Rem
	bbdoc: Returns whether the HTTP request failed.
	End Rem
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

	Rem
	bbdoc: Returns whether the HTTP request was successful.
	End Rem
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

	Rem
	bbdoc: Returns the error message for the HTTP request.
	End Rem
	Method ErrorMessage:String()
		If curlCode <> 0 Then Return "curl(" + curlCode + ") " + curlErr
		If status > 0 Then Return "HTTP " + status + " " + reason
		Return "Unknown error"
	End Method
End Type

Rem
bbdoc: HTTP Request.
about: Represents an HTTP request, including method, URL, headers, and body content.
End Rem
Type THttpRequest
	Field _client:THttpClient

	Field _headers:THttpFields = New THttpFields

	Field _acceptCompressed:Int = True
	Field _connectTimeoutMs:Int = 10000
	Field _totalTimeoutMs:Int = 0
	Field _idleTimeoutMs:Int = 60000

	Field _retry:TRetryPolicy

	Field _method:EHttpMethod = EHttpMethod.Get

	Field _url:TUrl
	Field _scheme:String
	Field _host:String
	Field _port:Int
	Field _path:String
	Field _query:String
	Field _params:THttpFields = New THttpFields

	Field _userAgent:String

	Field _followRedirects:Int = True
	Field _user:String
	Field _password:String
	Field _bearerToken:String
	Field _authMethod:EHttpAuthMethod = EHttpAuthMethod.None

	Field _content:TContent

	Field _verbose:Int = False
	Field _sink:TSink
	Field _cookies:TArrayList<THttpCookie> = New TArrayList<THttpCookie>

	' completion state (filled after sync send or by engine for inspection)
	Field _response:THttpResponse
	Field _listener:ICompleteListener

	Method Create:THttpRequest(client:THttpClient, _method:EHttpMethod, url:TUrl)
		_client = client
		Self._method = _method
		Self._url = url
		Return Self
	End Method

	 Method Create:THttpRequest(client:THttpClient, _method:EHttpMethod, url:String)
		_client = client
		Self._method = _method
		Self._url = New TUrl(url)
		Return Self
	End Method

	Method Create:THttpRequest(client:THttpClient, url:String)
		_client = client
		Self._url = New TUrl(url)
		Return Self
	End Method

	Method Create:THttpRequest(client:THttpClient, url:TUrl)
		_client = client
		Self._url = url
		Return Self
	End Method


	' ---- fluent config ----
	Rem
	bbdoc: Adds a header to the HTTP request.
	End Rem
	Method Header:THttpRequest(key:String, value:String)
		_headers.Add(key,value)
		Return Self
	End Method

	Rem
	bbdoc: Adds a header to the HTTP request.
	End Rem
	Method Header:THttpRequest(key:EHttpHeader, value:String)
		_headers.Add(key,value)
		Return Self
	End Method

	Rem
	bbdoc: Sets the request body for the HTTP request to the specified @text with the given content type.
	End Rem
	Method Body:THttpRequest(text:String, contentType:String = "text/plain; charset=utf-8")
		_content = New TStringContent(text, contentType)
		Return Self
	End Method

	Rem
	bbdoc: Sets the request body for the HTTP request to the specified input @stream with the given content type.
	End Rem
	Method Body:THttpRequest(stream:TStream, length:Long, contentType:String = "application/octet-stream")
		_content = New TStreamContent(stream, length, contentType)
		Return Self
	End Method

	Rem
	bbdoc: Sets the request body for the HTTP request to the specified byte array @data with the given content type.
	End Rem
	Method Body:THttpRequest(data:Byte[], contentType:String = "application/octet-stream")
		_content = New TByteArrayContent(data, contentType)
		Return Self
	End Method

	Rem
	bbdoc: Sets the request body for the HTTP request to the specified content object @content.
	End Rem
	Method Body:THttpRequest(content:TContent)
		_content = content
		Return Self
	End Method

	Rem
	bbdoc: Sets the request body for the HTTP request to the specified bank object @bank with the given content type.
	End Rem
	Method Body:THttpRequest(bank:TBank, contentType:String = "application/octet-stream")
		_content = New TBankContent(bank, contentType)
		Return Self
	End Method

	Rem
	bbdoc: Sets the authentication method for the HTTP request.
	End Rem
	Method AuthMethod:THttpRequest(auth:EHttpAuthMethod)
		_authMethod = auth
		Return Self
	End Method

	Rem
	bbdoc: Enables or disables acceptance of compressed responses. Defaults to enabled.
	End Rem
	Method AcceptCompressed:THttpRequest(enable:Int)
		_acceptCompressed = enable
		Return Self
	End Method

	Rem
	bbdoc: Sets the connection timeout for the HTTP request in milliseconds. Defaults to 10000 ms.
	about: Overrides the client-wide connection timeout setting for this specific request.
	End Rem
	Method ConnectTimeout:THttpRequest(connectMs:Int)
		_connectTimeoutMs = connectMs
		Return Self
	End Method

	Rem
	bbdoc: Sets the idle timeout for the HTTP request in milliseconds. Defaults to 60000 ms.
	about: Overrides the client-wide idle timeout setting for this specific request.
	End Rem
	Method IdleTimeout:THttpRequest(idleMs:Int)
		_idleTimeoutMs = idleMs
		Return Self
	End Method

	Rem
	bbdoc: Sets the total timeout for the HTTP request in milliseconds. Defaults to no timeout.
	about: Overrides the client-wide total timeout setting for this specific request.
	End Rem
	Method TotalTimeout:THttpRequest(totalMs:Int)
		_totalTimeoutMs = totalMs
		Return Self
	End Method

	Rem
	bbdoc: Sets the URL scheme (e.g., "http" or "https").
	End Rem
	Method Scheme:THttpRequest(scheme:String)
		_scheme = scheme
		_url = null
		Return Self
	End Method

	Rem
	bbdoc: Sets the host for the HTTP request.
	End Rem
	Method Host:THttpRequest(host:String)
		_host = host
		_url = null
		Return Self
	End Method

	Rem
	bbdoc: Sets the port for the HTTP request.
	End Rem
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

	Rem
	bbdoc: Sets the user for HTTP authentication.
	about: When using Kerberos V5 authentication with a Windows based server, you should specify the username part with the domain name in order
	for the server to successfully obtain a Kerberos Ticket. If you do not then the initial part of the authentication handshake may fail.

	When using NTLM, the username can be specified simply as the username without the domain name should the server be part of a single domain and forest.

	To specify the domain name use either Down-Level Logon Name or UPN (User Principal Name) formats. For example `EXAMPLE\user` and `user@example.com` respectively.

	Some HTTP servers (on Windows) support inclusion of the domain for Basic authentication as well.
	End Rem
	Method User:THttpRequest(user:String)
		_user = user
		Return Self
	End Method

	Rem
	bbdoc: Sets the password for HTTP authentication.
	End Rem
	Method Password:THttpRequest(password:String)
		_password = password
		Return Self
	End Method

	Rem
	bbdoc: Sets a Bearer token for OAuth 2.0 authentication.
	End Rem
	Method BearerToken:THttpRequest(token:String)
		_bearerToken = token
		Return Self
	End Method

	Method FollowRedirects:THttpRequest(follow:Int)
		_followRedirects = follow
		Return Self
	End Method

	Rem
	bbdoc: Sets the retry policy for the HTTP request.
	End Rem
	Method WithRetry:THttpRequest(policy:TRetryPolicy)
		_retry = policy
		Return Self
	End Method

	Rem
	bbdoc: Sets the User-Agent header for the HTTP request.
	End Rem
	Method UserAgent:THttpRequest(userAgent:String)
		_userAgent = userAgent
		Return Self
	End Method

	Method GetPath:String()
		Return _path
	End Method

	Method GetQuery:String()
		Return _query
	End Method

	Rem
	bbdoc: Returns the URL scheme (e.g., "http" or "https").
	End Rem
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

	Rem
	bbdoc: Adds a cookie to the request.
	End Rem
	Method Cookie:THttpRequest(cookie:THttpCookie)
		_cookies.Add(cookie)
		Return Self
	End Method

	Rem
	bbdoc: Returns the URL for the HTTP request.
	End Rem
	Method GetUrl:TUrl()
		If Not _url Then
			_url = BuildUrl(True)
		End If

		Return _url
	End Method

	Rem
	bbdoc: Returns whether the request is set to follow HTTP redirects automatically.
	End Rem
	Method IsFollowingRedirects:Int()
		Return _followRedirects
	End Method

	Rem
	bbdoc: Enables or disables verbose output for the request.
	about: Useful for debugging purposes.
	End Rem
	Method Verbose:THttpRequest(enable:Int)
		_verbose = enable
		Return Self
	End Method

	' ---- send ----
	Rem
	bbdoc: Sends the HTTP request and returns the response.
	End Rem
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

	Rem
	bbdoc: Sends the HTTP request asynchronously.
	about: The provided listener will be called upon completion of the request.
	End Rem
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

' context for each easy handle in the multi
Type TEasyContext
	Field request:THttpRequest
	Field response:THttpResponse
	Field easy:TCurlEasy
	Field waiter:IWaiter
	Field sink:TSink

	Field slist:TSlist

	Field env:TRequestEnvelope

	Method Delete()
		If slist Then
			slist.Free()
		End If
	End Method
End Type

' envelope for requests in the client queue
Type TRequestEnvelope
	Field client:THttpClient
	Field request:THttpRequest
	Field context:TEasyContext
	Field waiter:IWaiter
	Field retry:TRetryState
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
	Field _retryQueue:TMinHeap<TRequestEnvelope> = New TMinHeap<TRequestEnvelope>(new TTimeComparator)
	Field _followRedirects:Int = True

	Field _caStore:TCAStore
	Field _cookieStore:THttpCookieStore = New THttpCookieStore

	Field _connectTimeoutMs:Int = 10000
	Field _totalTimeoutMs:Int = 0
	Field _idleTimeoutMs:Int = 60000

	Field _userAgent:String

	Field _retryDefault:TRetryPolicy = New TRetryPolicy

	Rem
	bbdoc: Creates a new HTTP client instance.
	about: This function initializes a new instance of the HTTP client.
	End Rem
	Function Create:THttpClient()
		Local client:THttpClient = New THttpClient
		client._multi = TCurlMulti.Create()
		Return client
	End Function

	Rem
	bbdoc: Starts the HTTP client processing thread.
	about: This method must be called before sending any requests.
	End Rem
	Method Start()
		_running = True
		_thread = CreateThread(_ClientMain, Self)
	End Method

	Rem
	bbdoc: Shuts down the HTTP client and cleans up resources.
	End Rem
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
		Local request:THttpRequest = New THttpRequest.Create(Self, EHttpMethod.Get, url)
		InitRequest(request)
		Return request
	End Method
	
	Rem
	bbdoc: Creates a new POST request for the specified URL.
	End Rem
	Method Post:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, EHttpMethod.Post, url)
		InitRequest(request)
		Return request
	End Method

	Rem
	bbdoc: Creates a new PUT request for the specified URL.
	End Rem
	Method Put:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, EHttpMethod.Put, url)
		InitRequest(request)
		Return request
	End Method

	Rem
	bbdoc: Creates a new HTTP request with the specified URL.
	about: 
	End Rem
	Method NewRequest:THttpRequest(url:String)
		Local request:THttpRequest = New THttpRequest.Create(Self, url)
		InitRequest(request)
		Return request
	End Method

	Rem
	bbdoc: Sets whether the client should follow HTTP redirects automatically. Defaults to True.
	End Rem
	Method SetFollowRedirects(follow:Int)
		_followRedirects = follow
	End Method

	Rem
	bbdoc: Returns whether the client is set to follow HTTP redirects automatically.
	End Rem
	Method IsFollowingRedirects:Int()
		Return _followRedirects
	End Method

	Rem
	bbdoc: Sets the retry policy for the HTTP client.
	End Rem
	Method SetRetryPolicy(policy:TRetryPolicy)
		_retryDefault = policy
	End Method

	Method InitRequest(request:THttpRequest)
		' apply client-wide settings to request
		request.FollowRedirects(_followRedirects)
		request.IdleTimeout(_idleTimeoutMs)
		request.ConnectTimeout(_connectTimeoutMs)
		request.TotalTimeout(_totalTimeoutMs)
		request.UserAgent(_userAgent)
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

	Rem
	bbdoc: Sets the connection timeout in milliseconds. Defaults to 10000 ms.
	about: Specifies the maximum time in milliseconds that the connection phase is allowed to take.
	End Rem
	Method SetConnectTimeout(timeoutMs:Int)
		_connectTimeoutMs = timeoutMs
	End Method

	Rem
	bbdoc: Sets the total timeout in milliseconds. Defaults to no timeout.
	about: Specifies the maximum time in milliseconds that the entire request is allowed to take.
	End Rem
	Method SetTotalTimeout(timeoutMs:Int)
		_totalTimeoutMs = timeoutMs
	End Method

	Rem
	bbdoc: Sets the idle timeout in milliseconds. Defaults to 60000 ms.
	about: Specifies the maximum time in milliseconds that the request is allowed to remain idle.
	End Rem
	Method SetIdleTimeout(timeoutMs:Int)
		_idleTimeoutMs = timeoutMs
	End Method

	Rem
	bbdoc: Sets the User-Agent header for the HTTP client.
	about: Applies to all subsequent requests unless overridden at the request level.
	End Rem
	Method SetUserAgent(userAgent:String)
		_userAgent = userAgent
	End Method

Private
	Function _ClientMain:Object(arg:Object)
		THttpClient(arg).Run()
		Return Null
	End Function

	Method Submit(request:THttpRequest, waiter:IWaiter = Null)

		NormalizeReqest(request)

		Local env:TRequestEnvelope = New TRequestEnvelope
		env.client = Self
		env.request = request
		env.waiter = waiter
		env.retry = New TRetryState
		env.retry.attempts = 1
		_inQueue.Push env

		_multi.multiWakeup() ' wake up the multi thread
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

			' admit scheduled retries that are due
			AdmitDueRetries()

			_multi.multiPerform(still)

			Local ms:Int
			_multi.multiTimeout(ms)

			If ms < 0 Or ms > 1000 Then
				ms = 100
			End If

			Local retryMs:Int = NextRetryDeltaMs()
			Local pollMs:Int = Min(ms, retryMs)
			If pollMs < 1 Then
				pollMs = 1   ' avoid busy loop
			End If

			Local numfds:Int
			_multi.multiPoll(pollMs, numfds)

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

					_multi.multiRemove(easy)
					
					If ctx.slist Then
						ctx.slist.Free()
					End If

					easy.cleanup()

					Local policy:TRetryPolicy
					If ctx.request._retry Then
						policy = ctx.request._retry
					Else
						policy = _retryDefault
					End If

					If policy And policy.maxAttempts > 0 Then
						env = ctx.env

						If ShouldRetry(ctx, policy) And ctx.sink.IsReplaySafe() And env.retry.attempts < policy.maxAttempts Then

							Local sleepMs:Int = ComputeRetrySleepMs(ctx, policy, env.retry.attempts)
							' Can we replay?
							If IsReplaySafe(ctx.request, policy) Then

								PrepareForReplay(ctx.request)
								ctx.sink.AbortAttempt()

								ScheduleRetry(env, sleepMs)
								Continue ' do not deliver result yet
							End If
						End If
					End If

					' success or no more retries: commit
					ctx.sink.CommitAttempt()

					' finalize sinks
					If TMemorySink(ctx.sink) Then
						ctx.response.body = TMemorySink(ctx.sink).GetData()
						ctx.response.bytesReceived = ctx.response.body.Length
					Else If TStreamSink(ctx.sink) Then
						ctx.response.bytesReceived = TStreamSink(ctx.sink).total
					End If

					' deliver result

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

	Method ScheduleRetry(env:TRequestEnvelope, sleepMs:Int)
		env.retry.attempts :+ 1
		env.context = Null
		env.retry.nextAtMS = CurrentUnixTime() + Long(Max(0, sleepMs))
		_retryQueue.Push(env)
		' wake the poller
		_multi.multiWakeup()
	End Method

	Method AdmitDueRetries()
		Local now:ULong = CurrentUnixTime()
		While Not _retryQueue.IsEmpty()
			Local peek:TRequestEnvelope = _retryQueue.Peek()
			If peek.retry.nextAtMS > now Then
				' not yet ready
				Exit
			End If
			_retryQueue.Pop()
			' ready: prepare and add handle
			Local ctx:TEasyContext = PrepareContext(peek)
			peek.context = ctx
		Wend
	End Method

	Method NextRetryDeltaMs:Int()
		If _retryQueue.IsEmpty() Then
			Return 1000000000 ' effectively “infinite”
		End If
		
		Local env:TRequestEnvelope = _retryQueue.Peek()
		Local delta:Int = Int(Max(0:Long, env.retry.nextAtMS - Long(CurrentUnixTime())))
		Return delta
	End Method

	Method PrepareContext:TEasyContext(env:TRequestEnvelope)
		Local request:THttpRequest = env.request
		Local context:TEasyContext = New TEasyContext

		context.request = request
		context.response = New THttpResponse
		context.waiter = env.waiter
		context.easy = env.client._multi.newEasy()
		context.env = env

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

		easy.setOptInt(CURLOPT_CONNECTTIMEOUT_MS, request._connectTimeoutMs)
		easy.setOptInt(CURLOPT_TIMEOUT_MS, request._totalTimeoutMs)

		If request._idleTimeoutMs > 0 Then
			Local secs:Int = (request._idleTimeoutMs + 999) / 1000
			If secs < 1 Then
				secs = 1
			End If
			easy.setOptInt(CURLOPT_LOW_SPEED_LIMIT, 1) ' 1 byte/s
			easy.setOptInt(CURLOPT_LOW_SPEED_TIME,  secs)
		End If

		If request._verbose Then
			easy.setOptInt(CURLOPT_VERBOSE, 1)
		End If

		If request._acceptCompressed Then
			easy.setOptString(CURLOPT_ACCEPT_ENCODING, "", True)
		End If

		If request._user Then
			easy.setOptString(CURLOPT_USERNAME, request._user)
		End If

		If request._password Then
			easy.setOptString(CURLOPT_PASSWORD, request._password)
		End If

		If request._bearerToken Then
			easy.setOptString(CURLOPT_XOAUTH2_BEARER, request._bearerToken)
		End If

		' user agent
		If request._userAgent Then
			easy.setOptString(CURLOPT_USERAGENT, request._userAgent)
		End If

		easy.setOptInt(CURLOPT_HTTPAUTH, request._authMethod.Ordinal())

		' Method + body handling
		Local hasBody:Int = (request._content <> Null)
		Select request._method
			Case EHttpMethod.Get, EHttpMethod.Head, EHttpMethod.Delete
				If request._method = EHttpMethod.Head Then
					easy.setOptInt(CURLOPT_NOBODY, 1)
				Else
					easy.setOptInt(CURLOPT_HTTPGET, 1)
				End If
				If hasBody Then ' uncommon but allowed for DELETE
					easy.setOptString(CURLOPT_CUSTOMREQUEST, THttpHelper.HttpMethodToString(request._method))
					easy.setOptInt(CURLOPT_UPLOAD, 1)
				End If
			Case EHttpMethod.Post
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
				easy.setOptString(CURLOPT_CUSTOMREQUEST, THttpHelper.HttpMethodToString(request._method))

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

		' response sink
		If request._sink <> Null Then
			context.sink = request._sink
		Else
		   context.sink = New TMemorySink
		End If
		context.sink.BeginAttempt()

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

		Local headerText:String = String.FromUTF8Bytes(buffer, Int(size))
		Local header:THttpField = context.response.headers.Add(headerText)

		' handle cookies
		If header And header.Is("set-cookie") Then
			Local url:TUrl = context.request.GetUrl()
			context.request._client.PutCookie(url, header)
		End If

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

	Method PutCookie(url:TUrl, header:THttpField)
		Local cookie:THttpCookie = TCookieHelper.ParseFromSetCookieHeader(header)
		If cookie Then
			_cookieStore.Add(url, cookie)
		End If
	End Method

	Method NormalizeReqest(request:THttpRequest)

		' add cookies
		Local sb:TStringBuilder = ConvertCookies(request._cookies, Null)
		
		If Not _cookieStore.IsEmpty() Then
			Local matchedCookies:TArrayList<THttpCookie> = _cookieStore.Match(request.GetUrl())
			sb = ConvertCookies(matchedCookies, sb)
		End If

		If sb <> Null Then
			request._headers.Add(EHttpHeader.Cookie, sb.ToString())
		End If

	End Method

	Method ConvertCookies:TStringBuilder(cookies:TArrayList<THttpCookie>, sb:TStringBuilder)

		For Local cookie:THttpCookie = EachIn cookies
			If sb = Null Then
				sb = New TStringBuilder
			Else
				sb.Append("; ")
			End If
			sb.Append(cookie.GetName()).Append("=").Append(cookie.GetValue())
		Next

		Return sb
	End Method

End Type

Private
Function IsReplaySafe:Int(request:THttpRequest, policy:TRetryPolicy)
	If request._method = EHttpMethod.Get Or request._method = EHttpMethod.Head Then
		Return True
	End If
	If request._method = EHttpMethod.Post And policy.allowPostReplay And request._content And request._content.CanReplay() Then
		Return True
	End If
	If (request._method = EHttpMethod.Put Or request._method = EHttpMethod.Delete Or request._method = EHttpMethod.Options Or request._method = EHttpMethod.Trace) Then
		If Not request._content Then
			Return True
		End If
		Return request._content.CanReplay()
	End If
	Return False
End Function

Function PrepareForReplay(request:THttpRequest)
	If request._content Then
		If Not request._content.Rewind() Then
			Local content:TContent = request._content.Clone()
			If content Then
				request._content = content
			Else
				' cannot replay; let caller handle
			End If
		End If
	End If
End Function

Function ShouldRetry:Int(ctx:TEasyContext, policy:TRetryPolicy)
	Local req:THttpRequest = ctx.request
	Local res:THttpResponse = ctx.response

	' method allowed?
	If Not policy.allowMethods.Contains(req._method) Then
		If Not (req._method = EHttpMethod.Post And policy.allowPostReplay) Then
			Return False
		End If
	End If

	' transient curl code?
	If res.curlCode <> 0 Then
		Return policy.retryCurlCodes.Contains(res.curlCode)
	End If

	' HTTP status
	If res.status >= 400 Then
		If policy.retryStatuses.Contains(res.status) Then
			' Retry-After?
			If policy.respectRetryAfter Then
				Local h:String = ctx.response.headers.GetFirst("Retry-After")
				If h Then
					Return True ' has Retry-After header
				End If
			End If
			Return True
		End If
	End If

	Return False
End Function

Function ComputeRetrySleepMs:Int(context:TEasyContext, policy:TRetryPolicy, attempt:Int)
	' Retry-After first
	If policy.respectRetryAfter And context.response And context.response.headers Then
		Local ra:String = context.response.headers.GetFirst("Retry-After")
		If ra Then
			Local secs:Float
			Local raVal:Int = Int(ra.Trim())
			If raVal > 0 Then
				secs = Float(raVal)
			Else
				Local t:Long = bmx_curl_getdate(ra) ' returns epoch seconds or -1
				If t > 0 Then
					secs = Max(0.0, Float(t - (CurrentUnixTime()/1000)))
				End If
			End If
			If secs > 0 Then
				Return Int(Min(secs, policy.maxBackoffSec) * 1000.0)
			End If
		End If
	End If

	' Exponential backoff with jitter
	Local base:Float = policy.backoffFactor
	If base <= 0.0 Then Return 0
	Local exp:Float = base * (2.0 ^ (attempt - 1))
	Local cap:Float = Min(exp, policy.maxBackoffSec)
	Local jitter:Float = (Sin(Float(CurrentUnixTime() Mod 1000) / 1000.0 * 3.14159 * 2.0) + 1.0) / 2.0 * cap
	Return Int(jitter * 1000.0)
End Function

Public

' Response sinks
Type TSink Abstract
	' returns bytes written (should equal size); returning less signals error to curl
	Method Write:Size_T(buffer:Byte Ptr, size:Size_T) Abstract
	Method Close()
	End Method

	Method BeginAttempt() ' prepare to receive a new response
	End Method

	Method AbortAttempt()  ' discard partial data from this attempt
	End Method

	Method CommitAttempt() ' finalize (rename temp file, etc.)
	End Method

	Method IsReplaySafe:Int()
		Return True
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

	Method BeginAttempt() Override
		size = 0
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

	Method IsReplaySafe:Int() Override
		Return False
	End Method

	Method BeginAttempt() Override
		total = 0
	End Method
End Type

Type TMinHeap<T>
	Field _data:TArrayList<T> = New TArrayList<T>
	Field _comparer:IComparator<T>

	Method New(comparer:IComparator<T>)
		Self._comparer = comparer
	End Method

	Method Push(item:T)
		_data.Add(item)
		_SiftUp(_data.Count() - 1)
	End Method

	Method Pop:T()

		If _data.IsEmpty() Then
			Return Null
		End If
		Local result:T = _data[0]
		_data[0] = _data[_data.Count() - 1]
		_data.RemoveLast()
		_SiftDown(0)
		Return result
	End Method

	Method Peek:T()
		If _data.IsEmpty() Then
			Return Null
		End If
		Return _data[0]
	End Method

	Method IsEmpty:Int()
		Return _data.IsEmpty()
	End Method

	Private

	Method _SiftUp(index:Int)
		While index > 0
			Local parent:Int = (index - 1) / 2
			If _comparer.Compare(_data[index], _data[parent]) < 0 Then
				Local temp:T = _data[index]
				_data[index] = _data[parent]
				_data[parent] = temp
				index = parent
			Else
				Exit
			End If
		Wend
	End Method

	Method _SiftDown(index:Int)
		Local length:Int = _data.Count()
		While True
			Local left:Int = index * 2 + 1
			Local right:Int = index * 2 + 2
			Local smallest:Int = index

			If left < length And _comparer.Compare(_data[left], _data[smallest]) < 0 Then
				smallest = left
			End If
			If right < length And _comparer.Compare(_data[right], _data[smallest]) < 0 Then
				smallest = right
			End If

			If smallest <> index Then
				Local temp:T = _data[index]
				_data[index] = _data[smallest]
				_data[smallest] = temp
				index = smallest
			Else
				Exit
			End If
		Wend
	End Method
End Type

Type TTimeComparator Implements IComparator<TRequestEnvelope>
	Method Compare:Int(a:TRequestEnvelope, b:TRequestEnvelope) Override
		Return a.retry.nextAtMS - b.retry.nextAtMS
	End Method
End Type

Type TConcurrentQueue<T>
	Field _lock:TMutex = CreateMutex()
	Field _cv:TCondVar = CreateCondVar()
	Field _q:TLinkedList<T> = New TLinkedList<T>
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
			v = _q.RemoveFirst()
		End If
		UnlockMutex _lock
		Return v
	End Method

	Method TryPop:T()
		LockMutex _lock
		Local v:T
		If Not _q.IsEmpty() Then
			v = _q.RemoveFirst()
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

	Method CanReplay:Int()
		Return False
	End Method

	Method Rewind:Int()
		Return False
	End Method

	Method Clone:TContent()
		Return Null
	End Method

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

	Method CanReplay:Int() Override
		Return True
	End Method

	Method Rewind:Int() Override
		_pos = 0
		Return True
	End Method

	Method Clone:TContent() Override
		Return New TStringContent(data, _contentType)
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

	Method CanReplay:Int() Override
		Return _stream.Size() <> -1
	End Method

	Method Rewind:Int() Override
		_stream.Seek(0, SEEK_SET_)
		Return True
	End Method

	Method Clone:TContent() Override
		Return New TStreamContent(_stream, _length, _contentType)
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

	Method CanReplay:Int() Override
		Return True
	End Method

	Method Rewind:Int() Override
		_pos = 0
		Return True
	End Method

	Method Clone:TContent() Override
		Return New TBytePtrContent(_data, _size, _contentType)
	End Method

End Type

Type TByteArrayContent Extends TBytePtrContent
	Field _dataArray:Byte[]

	Method New(data:Byte[], contentType:String = Null)
		Super.New(data, Size_T(data.Length), contentType)
		_dataArray = data
	End Method

	Method Clone:TContent() Override
		Return New TByteArrayContent(_dataArray, _contentType)
	End Method

End Type

Type TBankContent Extends TBytePtrContent
	Field _bank:TBank

	Method New(bank:TBank, contentType:String = Null)
		Super.New(bank.Buf(), Size_T(bank.Size()), contentType)
		_bank = bank
	End Method

	Method Clone:TContent() Override
		Return New TBankContent(_bank, _contentType)
	End Method

End Type

Rem
bbdoc: Retry policy configuration for HTTP requests.
about: Defines the parameters for retrying HTTP requests in case of transient failures.
End Rem
Type TRetryPolicy
	Rem
	bbdoc: Maximum number of attempts for a request. A value of 0 disables retries.
	about: This includes the initial attempt. For example, a value of 3 allows for 2 retries after the first attempt.
	End rem
	Field maxAttempts:Int = 0
	Rem
	bbdoc: Base backoff factor in seconds for exponential backoff calculation.
	about: The backoff time for each retry is calculated as backoffFactor * (2 ^ (attempt - 1)), capped by maxBackoffSec.
	End Rem
	Field backoffFactor:Float = 0.25
	Rem
	bbdoc: Maximum backoff time in seconds between retries.
	about: This caps the exponential backoff time to avoid excessively long waits.
	End Rem
	Field maxBackoffSec:Float = 30.0
	Rem
	bbdoc: Whether to respect the Retry-After header from server responses.
	about: If set to True, the client will wait for the duration specified in the Retry-After header before retrying.
	End Rem
	Field respectRetryAfter:Int = True
	Rem
	bbdoc: Whether to allow retries for POST requests if the request body is replayable.
	about: If set to True, POST requests with replayable bodies can be retried according to transient failures.
	End Rem
	Field allowPostReplay:Int = False

	' which methods/statuses/curlcodes are retryable
	Field allowMethods:TSet<EHttpMethod> = New TSet<EHttpMethod>.FromArray([EHttpMethod.Get, EHttpMethod.Head, EHttpMethod.Put, EHttpMethod.Delete, EHttpMethod.Options, EHttpMethod.Trace])
	Field retryStatuses:TSet<Int> = New TSet<Int>.FromArray([429,502,503,504])
	Field retryCurlCodes:TSet<Int> = New TSet<Int>.FromArray([ ..
		CURLE_OPERATION_TIMEDOUT, CURLE_COULDNT_CONNECT,
		CURLE_RECV_ERROR, CURLE_SEND_ERROR, CURLE_GOT_NOTHING,
		CURLE_PARTIAL_FILE ])
End Type

Type TRetryState
	Field attempts:Int          ' starts at 1 for first try
	Field nextAtMS:Long         ' scheduled retry time (ms since MilliSecs base)
End Type
