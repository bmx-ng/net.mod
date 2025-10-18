' Copyright (c) 2007-2025 Bruce A Henderson
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

Const CURL_READFUNC_ABORT:Size_T = $10000000

Rem
bbdoc: Initialize SSL. No purpose since since 7.57.0
End Rem
Const CURL_GLOBAL_SSL:Int =  1 Shl 0

Rem
bbdoc: Initialize the Win32 socket libraries.
End Rem
Const CURL_GLOBAL_WIN32:Int = 1 Shl 1

Rem
bbdoc: Initialize everything possible.
about: This sets all known bits.
End Rem
Const CURL_GLOBAL_ALL:Int = CURL_GLOBAL_SSL | CURL_GLOBAL_WIN32

Rem
bbdoc: Initialise nothing extra.
about: This sets no bit.
End Rem
Const CURL_GLOBAL_NOTHING:Int = 0
Const CURL_GLOBAL_DEFAULT:Int = CURL_GLOBAL_ALL
Const CURL_GLOBAL_ACK_EINTR:Int = 1 Shl 2

Const CURLOPTTYPE_LONG:Int = 0
Const CURLOPTTYPE_VALUES:Int = CURLOPTTYPE_LONG
Const CURLOPTTYPE_OBJECTPOINT:Int = 10000
Const CURLOPTTYPE_STRINGPOINT:Int = 10000
Const CURLOPTTYPE_FUNCTIONPOINT:Int = 20000
Const CURLOPTTYPE_OFF_T:Int = 30000
Const CURLOPTTYPE_BLOB:Int = 40000
Const CURLOPTTYPE_CBPOINT:Int = CURLOPTTYPE_OBJECTPOINT

Rem
bbdoc: A reference to an object output should be written to.
End Rem
Const CURLOPT_WRITEDATA:Int = CURLOPTTYPE_OBJECTPOINT + 1

Rem
bbdoc: The actual URL to deal with.
about: If the given URL lacks the protocol part ("http://" or "ftp://" etc), it will attempt to guess which
protocol to use based on the given host name. If the given protocol of the set URL is not supported,
libcurl will return on error (#CURLE_UNSUPPORTED_PROTOCOL) when you call #perform.<br>
Use #VersionInfo for detailed info on which protocols that are supported.
End Rem
Const CURLOPT_URL:Int =  CURLOPTTYPE_STRINGPOINT + 2

Rem
bbdoc: Port number to connect, if other than default.
about: A number representing the proxy port to connect to unless it is specified in the proxy string #CURLOPT_PROXY.
End Rem
Const CURLOPT_PORT:Int = CURLOPTTYPE_LONG + 3

Rem
bbdoc: Set HTTP proxy to use.
about: The parameter should be a string holding the host name or dotted IP address. To specify port number in this
string, append :[port] to the end of the host name. The proxy string may be prefixed with [protocol]:// since
any such prefix will be ignored. The proxy's port number may optionally be specified with the separate
option #CURLOPT_PROXYPORT.
<p>
When you tell the library to use an HTTP proxy, libcurl will transparently convert operations to HTTP even
if you specify an FTP URL etc. This may have an impact on what other features of the library you can use,
such as #quote and similar FTP specifics that don't work unless you tunnel through the HTTP proxy.
Such tunneling is activated with #CURLOPT_HTTPPROXYTUNNEL.
</p>
<p>
libcurl respects the environment variables <b>http_proxy</b>, <b>ftp_proxy</b>, <b>all_proxy</b> etc, if any of those
is set. The #CURLOPT_PROXY option does however override any possibly set environment variables.
</p>
<p>
Setting the proxy string to "" (an empty string) will explicitly disable the use of a proxy, even if there is
an environment variable set for it.
</p>
<p>
The proxy host string given in environment variables can be specified the exact same way as the proxy
can be set with #CURLOPT_PROXY, include protocol prefix (http://) and embedded user + password.
</p>
End Rem
Const CURLOPT_PROXY:Int = CURLOPTTYPE_STRINGPOINT + 4

Rem
bbdoc: A String which should be [user name]:[password] to use for the connection.
about: Use #CURLOPT_HTTPAUTH to decide authentication method.
<p>
When using NTLM, you can set domain by prepending it to the user name and separating the domain and name with
a forward (/) or backward slash (). Like this: "domain/user:password" or "domainuser:password". Some HTTP
servers (on Windows) support this style even for Basic authentication.
</p>
<p>
When using HTTP and #CURLOPT_FOLLOWLOCATION, libcurl might perform several requests to possibly different hosts.
libcurl will only send this user and password information to hosts using the initial host name
(unless #CURLOPT_UNRESTRICTED_AUTH is set), so if libcurl follows locations to other hosts it will
not send the user and password to those. This is enforced to prevent accidental information leakage.
</p>
End Rem
Const CURLOPT_USERPWD:Int = CURLOPTTYPE_STRINGPOINT + 5

Rem
bbdoc: A String which should be [user name]:[password] to use for the connection to the HTTP proxy.
about: Use #CURLOPT_PROXYAUTH to decide authentication method.
End Rem
Const CURLOPT_PROXYUSERPWD:Int = CURLOPTTYPE_STRINGPOINT + 6

Rem
bbdoc: A String which should contain the specified range you want.
about: It should be in the format "X-Y", where X or Y may be left out. HTTP transfers also support several intervals,
separated with commas as in "X-Y,N-M". Using this kind of multiple intervals will cause the HTTP
server to send the response document in pieces (using standard MIME separation techniques).
Pass a Null to this option to disable the use of ranges.
End Rem
Const CURLOPT_RANGE:Int = CURLOPTTYPE_STRINGPOINT + 7

Rem
bbdoc: Specified file stream to upload from (use as Input).
End Rem
Const CURLOPT_READDATA:Int = CURLOPTTYPE_OBJECTPOINT + 9

Rem
bbdoc: See instead #setDebugCallback.
End Rem
Const CURLOPT_ERRORBUFFER:Int = CURLOPTTYPE_OBJECTPOINT + 10

Rem
bbdoc: See instead #setWriteCallback.
End Rem
Const CURLOPT_WRITEFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 11

Rem
bbdoc: See instead #setReadCallback.
End Rem
Const CURLOPT_READFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 12

Rem
bbdoc: The maximum time in seconds that you allow the libcurl transfer operation to take.
about: Normally, name lookups can take a considerable time and limiting operations to less than a few minutes risk
aborting perfectly normal operations. This option will cause curl to use the SIGALRM to enable time-outing
system calls.
<p>
In unix-like systems, this might cause signals to be used unless #CURLOPT_NOSIGNAL is set. 
</p>
End Rem
Const CURLOPT_TIMEOUT:Int = CURLOPTTYPE_LONG + 13

Rem
bbdoc: When uploading a file to a remote site, this option should be used to tell libcurl what the expected size of the infile is.
about: See also #CURLOPT_INFILESIZE_LARGE.
<p>
For uploading using SCP, this option or #CURLOPT_INFILESIZE_LARGE is mandatory.
</p>
<p>
Note that this option does not limit how much data libcurl will actually send, as that is controlled entirely
by what the read callback returns.
</p>
End Rem
Const CURLOPT_INFILESIZE:Int = CURLOPTTYPE_LONG + 14

Rem
bbdoc: A String, which should be the full data to post in an HTTP POST operation.
about: You must make sure that the data is formatted the way you want the server to receive it.
libcurl will not convert or encode it for you. Most web servers will assume this data to be url-encoded.
Take note.
<p>
This POST is a normal application/x-www-form-urlencoded kind (and libcurl will set that Content-Type
by default when this option is used), which is the most commonly used one by HTML forms.
See also the #CURLOPT_POST. Using #CURLOPT_POSTFIELDS implies #CURLOPT_POST.
</p>
<p>
Using POST with HTTP 1.1 implies the use of a "Expect: 100-continue" header. You can disable this
header with #httpHeader as usual.
</p>
<p>
To make multipart/formdata posts (aka rfc1867-posts), check out the #CURLOPT_HTTPPOST option. 
</p>
End Rem
Const CURLOPT_POSTFIELDS:Int = CURLOPTTYPE_OBJECTPOINT + 15

Rem
bbdoc: A String used to set the Referer: header in the http request sent to the remote server.
about: This can be used to fool servers or scripts. You can also set any custom header with
#httpHeader.
End Rem
Const CURLOPT_REFERER:Int = CURLOPTTYPE_OBJECTPOINT + 16

Rem
bbdoc: A String used to get the IP address to use for the ftp PORT instruction.
The PORT instruction tells the remote server to connect to our specified IP address. The string may be a plain
IP address, a host name, an network interface name (under Unix) or just a '-' letter to let the library use your
systems default IP address. Default FTP operations are passive, and thus won't use PORT.
<p>
You disable PORT again and go back to using the passive version by setting this option to Null. 
</p>
End Rem
Const CURLOPT_FTPPORT:Int = CURLOPTTYPE_OBJECTPOINT + 17

Rem
bbdoc: A String used to set the User-Agent: header in the http request sent to the remote server.
about: This can be used to fool servers or scripts. You can also set any custom header
with #httpHeader.
End Rem
Const CURLOPT_USERAGENT:Int = CURLOPTTYPE_OBJECTPOINT + 18

Rem
bbdoc: A number, which contains the transfer speed in bytes per second that the transfer should be below during #CURLOPT_LOW_SPEED_TIME seconds for the library to consider it too slow and abort.
End Rem
Const CURLOPT_LOW_SPEED_LIMIT:Int = CURLOPTTYPE_LONG + 19

Rem
bbdoc: A number, which contains the time in seconds that the transfer should be below the #CURLOPT_LOW_SPEED_LIMIT for the library to consider it too slow and abort.
End Rem
Const CURLOPT_LOW_SPEED_TIME:Int = CURLOPTTYPE_LONG + 20

Rem
bbdoc: A number, which contains the offset in number of bytes that you want the transfer to start from.
about: Set this option to 0 to make the transfer start from the beginning (effectively disabling resume).
For FTP, set this option to -1 to make the transfer start from the end of the target file (useful to continue
an interrupted upload).
End Rem
Const CURLOPT_RESUME_FROM:Int = CURLOPTTYPE_LONG + 21

Rem
bbdoc: A String, which will be used to set a cookie in the http request.
about: The format of the string should be NAME=CONTENTS, where NAME is the cookie name and CONTENTS is what the
cookie should contain.
<p>
If you need to set multiple cookies, you need to set them all using a single option and thus you need to
concatenate them all in one single string. Set multiple cookies in one string like this: 
"name1=content1; name2=content2;" etc.
</p>
<p>
Using this option multiple times will only make the latest string override the previously ones.
</p>
End Rem
Const CURLOPT_COOKIE:Int = CURLOPTTYPE_OBJECTPOINT + 22

Rem
bbdoc: See the #httpHeader method for details.
End Rem
Const CURLOPT_HTTPHEADER:Int = CURLOPTTYPE_OBJECTPOINT + 23

' Rem
' bbdoc: See the #httpPost method for details.
' End Rem
' Const CURLOPT_HTTPPOST:Int = CURLOPTTYPE_OBJECTPOINT + 24

Rem
bbdoc: The file name of your certificate.
about: The default format is "PEM" and can be changed with #CURLOPT_SSLCERTTYPE.
<p>
With NSS this is the nickname of the certificate you wish to authenticate with. 
</p>
End Rem
Const CURLOPT_SSLCERT:Int = CURLOPTTYPE_STRINGPOINT + 25

Rem
bbdoc: Password for the SSL or SSH private key.
End Rem
Const CURLOPT_KEYPASSWD:Int = CURLOPTTYPE_STRINGPOINT + 26

Rem
bbdoc: Convert Unix newlines to CRLF newlines on transfers.
End Rem
Const CURLOPT_CRLF:Int = CURLOPTTYPE_LONG + 27

Rem
bbdoc: See the #quote method for details.
End Rem
Const CURLOPT_QUOTE:Int = CURLOPTTYPE_OBJECTPOINT + 28

' see setHeaderCallback()
Const CURLOPT_HEADERDATA:Int = CURLOPTTYPE_OBJECTPOINT + 29

' see setWriteCallback()
'Const CURLOPT_WRITEDATA:Int = CURLOPT_FILE

' see setReadCallback()
'Const CURLOPT_READDATA:Int = CURLOPT_READDATA

' see setHeaderCallback()
'Const CURLOPT_HEADERDATA:Int = CURLOPT_WRITEHEADER

Rem
bbdoc: A String containing the name of your file holding cookie data to read.
about: The cookie data may be in Netscape / Mozilla cookie data format or just regular HTTP-style
headers dumped to a file.
<p>
Given an empty or non-existing file or by passing the empty string (""), this option will <b>enable cookies</b>
for this curl handle, making it understand and parse received cookies and then use matching cookies
in future request.
</p>
<p>
If you use this option multiple times, you just add more files to read. Subsequent files will add more
cookies.
</p>
End Rem
Const CURLOPT_COOKIEFILE:Int = CURLOPTTYPE_STRINGPOINT + 31

Rem
bbdoc: An option to control what version of SSL/TLS to attempt to use.
The available options are:
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURL_SSLVERSION_DEFAULT</td><td>The default action. This will attempt to figure out the remote SSL protocol version..</td></tr>
<tr><td>CURL_SSLVERSION_TLSv1</td><td>TLSv1.x</td></tr>
<tr><td>CURL_SSLVERSION_SSLv2</td><td>SSLv2</td></tr>
<tr><td>CURL_SSLVERSION_SSLv3</td><td>SSLv3</td></tr>
<tr><td>CURL_SSLVERSION_TLSv1_0</td><td>TLSv1.0</td></tr>
<tr><td>CURL_SSLVERSION_TLSv1_1</td><td>TLSv1.1</td></tr>
<tr><td>CURL_SSLVERSION_TLSv1_2</td><td>TLSv1.2</td></tr>
<tr><td>CURL_SSLVERSION_TLSv1_3</td><td>TLSv1.3</td></tr>
</table>
End Rem
Const CURLOPT_SSLVERSION:Int = CURLOPTTYPE_LONG + 32

Rem
bbdoc: This defines how the #CURLOPT_TIMEVALUE time value is treated.
about: You can set this parameter to CURL_TIMECOND_IFMODSINCE or CURL_TIMECOND_IFUNMODSINCE.
This feature applies to HTTP and FTP.
<p>
The last modification time of a file is not always known and in such instances this feature will have
no effect even if the given time condition would have not been met. 
</p>
End Rem
Const CURLOPT_TIMECONDITION:Int = CURLOPTTYPE_LONG + 33

Rem
bbdoc: This should be the time in seconds since 1 jan 1970, and the time will be used in a condition as specified with #CURLOPT_TIMECONDITION.
End Rem
Const CURLOPT_TIMEVALUE:Int = CURLOPTTYPE_LONG + 34

Rem
bbdoc: Custom request, for customizing the get command.
about: A String to be used instead of GET or HEAD when doing an HTTP request, or instead of LIST or NLST when doing
an ftp directory listing. This is useful for doing DELETE or other more or less obscure HTTP requests.
Don't do this at will, make sure your server supports the command first.
<p>
Restore to the internal default by setting this to NULL.
</p>
Many people have wrongly used this option to replace the entire request with their own, including multiple
headers and POST contents. While that might work in many cases, it will cause libcurl to send invalid requests
and it could possibly confuse the remote server badly. Use #CURLOPT_POST and #CURLOPT_POSTFIELDS to set POST
data. Use #httpHeader to replace or extend the set of headers sent by libcurl. Use #CURLOPT_HTTP_VERSION
to change HTTP version.
</p>
End Rem
Const CURLOPT_CUSTOMREQUEST:Int = CURLOPTTYPE_OBJECTPOINT + 36

'
Const CURLOPT_STDERR:Int = CURLOPTTYPE_OBJECTPOINT + 37

Rem
bbdoc: For details see #postQuote.
End Rem
Const CURLOPT_POSTQUOTE:Int = CURLOPTTYPE_OBJECTPOINT + 39

'
'Const CURLOPT_WRITEINFO:Int = CURLOPTTYPE_OBJECTPOINT + 40

Rem
bbdoc: Set to non-zero to get the library to display a lot of verbose information about its operations.
about: Very useful for libcurl and/or protocol debugging and understanding. The verbose information will
be sent to stderr, unless you setup a callback with #setDebugCallback.
<p>
You hardly ever want this set in production use, you will almost always want this when you
debug/report problems.
</p>
End Rem
Const CURLOPT_VERBOSE:Int = CURLOPTTYPE_LONG + 41

Rem
bbdoc: A non-zero value tells the library to include the header in the body output.
about: This is only relevant for protocols that actually have headers preceding the data (like HTTP).
End Rem
Const CURLOPT_HEADER:Int = CURLOPTTYPE_LONG + 42

' see setProgressCallback
Const CURLOPT_NOPROGRESS:Int = CURLOPTTYPE_LONG + 43

Rem
bbdoc: A non-zero value tells the library to not include the body-part in the output.
about: This is only relevant for protocols that have separate header and body parts. On HTTP(S) servers,
this will make libcurl do a HEAD request.
<p>
To change request to GET, you should use #CURLOPT_HTTPGET. Change request to POST with #CURLOPT_POST etc. 
</p>
End Rem
Const CURLOPT_NOBODY:Int = CURLOPTTYPE_LONG + 44

Rem
bbdoc: A non-zero value tells the library to fail silently if the HTTP code returned is equal to or larger than 400.
about: The default action would be to return the page normally, ignoring that code.
<p>
This method is not fail-safe and there are occasions where non-successful response codes will slip
through, especially when authentication is involved (response codes 401 and 407).
</p>
<p>
You might get some amounts of headers transferred before this situation is detected, like for when a
"100-continue" is received as a response to a POST/PUT and a 401 or 407 is received immediately afterwards.
</p>
End Rem
Const CURLOPT_FAILONERROR:Int = CURLOPTTYPE_LONG + 45

Rem
bbdoc: A non-zero value tells the library to prepare for an upload.
about: The #CURLOPT_INFILESIZE or #CURLOPT_INFILESIZE_LARGE options are also
interesting for uploads. If the protocol is HTTP, uploading means using the PUT request unless you tell
libcurl otherwise.
<p>
Using PUT with HTTP 1.1 implies the use of a "Expect: 100-continue" header. You can disable this header
with #httpHeader as usual.
</p>
<p>
If you use PUT to a HTTP 1.1 server, you can upload data without knowing the size before starting the
transfer if you use chunked encoding. You enable this by adding a header like "Transfer-Encoding: chunked"
with #httpHeader. With HTTP 1.0 or without chunked transfer, you must specify the size. 
</p>
End Rem
Const CURLOPT_UPLOAD:Int = CURLOPTTYPE_LONG + 46

Rem
bbdoc: A non-zero value tells the library to do a regular HTTP post.
about: This will also make the library use the a "Content-Type: application/x-www-form-urlencoded" header.
(This is by far the most commonly used POST method).
<p>
Use the #CURLOPT_POSTFIELDS option to specify what data to post and #CURLOPT_POSTFIELDSIZE to set the
data size.
</p>
<p>
Optionally, you can provide data to POST using #readStreamCallback options
but then you must make sure to not set #CURLOPT_POSTFIELDS to anything but Null. When providing
data with a callback, you must transmit it using chunked transfer-encoding or you must set the
size of the data with the #CURLOPT_POSTFIELDSIZE option.
</p>
<p>
You can override the default POST Content-Type: header by setting your own with #httpHeader.
</p>
<p>
Using POST with HTTP 1.1 implies the use of a "Expect: 100-continue" header. You can disable this
header with #httpHeader as usual.
</p>
<p>
If you use POST to a HTTP 1.1 server, you can send data without knowing the size before starting
the POST if you use chunked encoding. You enable this by adding a header like "Transfer-Encoding: chunked"
with #httpHeader. With HTTP 1.0 or without chunked transfer, you must specify the size in
the request.
</p>
<p>
When setting #CURLOPT_POST to a non-zero value, it will automatically set #CURLOPT_NOBODY to 0.
</p>
<p>
If you issue a POST request and then want to make a HEAD or GET using the same re-used handle,
you must explicitly set the new request type using #CURLOPT_NOBODY or #CURLOPT_HTTPGET or similar. 
</p>
End Rem
Const CURLOPT_POST:Int = CURLOPTTYPE_LONG + 47

Rem
bbdoc: A non-zero value tells the library to just list the names of an ftp directory, instead of doing a full directory listing that would include file sizes, dates etc.
about:  This causes an FTP NLST command to be sent. Beware that some FTP servers list only files in their
response to NLST; they might not include subdirectories and symbolic links.
End Rem
Const CURLOPT_FTPLISTONLY:Int = CURLOPTTYPE_LONG + 48

Rem
bbdoc: A non-zero value tells the library to append to the remote file instead of overwrite it.
about: This is only useful when uploading to an ftp site.
End Rem
Const CURLOPT_APPEND:Int = CURLOPTTYPE_LONG + 50

Rem
bbdoc: This value controls the preference of libcurl between using user names and passwords from your ~/.netrc file, relative to user names and passwords in the URL supplied with #CURLOPT_URL.
about: libcurl uses a user name (and supplied or prompted password) supplied with #CURLOPT_USERPWD in
preference to any of the options controlled by this parameter.
<p>Pass a value, set to one of #CURL_NETRC_OPTIONAL, #CURL_NETRC_IGNORED or #CURL_NETRC_REQUIRED.
</p>
End Rem
Const CURLOPT_NETRC:Int = CURLOPTTYPE_LONG + 51

Rem
bbdoc: A non-zero value tells the library to follow any Location: header that the server sends as part of an HTTP header.
about: This means that the library will re-send the same request on the new location and follow new
Location: headers all the way until no more such headers are returned. #CURLOPT_MAXREDIRS can be used
to limit the number of redirects libcurl will follow. 
End Rem
Const CURLOPT_FOLLOWLOCATION:Int = CURLOPTTYPE_LONG + 52

Rem
bbdoc: A non-zero value tells the library to use ASCII mode for ftp transfers, instead of the default binary transfer.
about: For win32 systems it does not set the stdout to binary mode. This option can be usable when
transferring text data between systems with different views on certain characters, such as newlines or
similar.
<p>
libcurl does not do a complete ASCII conversion when doing ASCII transfers over FTP. This is a known
limitation/flaw that nobody has rectified. libcurl simply sets the mode to ascii and performs a standard
transfer. 
</p>
End Rem
Const CURLOPT_TRANSFERTEXT:Int = CURLOPTTYPE_LONG + 53

' deprecated : use CURLOPT_UPLOAD instead !
'Const CURLOPT_PUT:Int = CURLOPTTYPE_LONG + 54




'Rem
'bbdoc: For details see #setProgressCallback
'End Rem
'Const CURLOPT_PROGRESSFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 56

Rem
bbdoc: For details see #setProgressCallback
End Rem
Const CURLOPT_XFERINFODATA:Int = CURLOPTTYPE_OBJECTPOINT + 57

Rem
bbdoc: Pass a non-zero parameter to enable this. 
about: When enabled, libcurl will automatically set the Referer: field in requests where it
follows a Location: redirect.
End Rem
Const CURLOPT_AUTOREFERER:Int = CURLOPTTYPE_LONG + 58

Rem
bbdoc: Use this option to set the proxy port to connect to unless it is specified in the proxy string #CURLOPT_PROXY.
End Rem
Const CURLOPT_PROXYPORT:Int = CURLOPTTYPE_LONG + 59

Rem
bbdoc: If you want to post data to the server without letting libcurl do a strlen() to measure the data size, this option must be used.
about: When this option is used you can post fully binary data, which otherwise is likely to fail.
If this size is set to -1, the library will use strlen() to get the size.
End Rem
Const CURLOPT_POSTFIELDSIZE:Int = CURLOPTTYPE_LONG + 60

Rem
bbdoc: Set the value to non-zero to get the library to tunnel all operations through a given HTTP proxy.
about: There is a big difference between using a proxy and to tunnel through it. If you don't know what
this means, you probably don't want this tunneling option.
End Rem
Const CURLOPT_HTTPPROXYTUNNEL:Int = CURLOPTTYPE_LONG + 61

Rem
bbdoc: This sets the interface name to use as outgoing network interface.
about: The name can be an interface name, an IP address or a host name.
End Rem
Const CURLOPT_INTERFACE:Int = CURLOPTTYPE_OBJECTPOINT + 62

Rem
bbdoc: Set the kerberos security level for FTP; this also enables kerberos awareness.
anout: This is a string, 'clear', 'safe', 'confidential' or 'private'. If the string is set but doesn't
match one of these, 'private' will be used. Set the string to Null to disable kerberos support for FTP.
End Rem
Const CURLOPT_KRBLEVEL:Int = CURLOPTTYPE_OBJECTPOINT + 63

Rem
bbdoc: This option determines whether curl verifies the authenticity of the peer's certificate.
about: A nonzero value means curl verifies; zero means it doesn't. The default is nonzero.
<p>
When negotiating an SSL connection, the server sends a certificate indicating its identity.
Curl verifies whether the certificate is authentic, i.e. that you can trust that the server is who
the certificate says it is. This trust is based on a chain of digital signatures, rooted in certification
authority (CA) certificates you supply. Curl installs a default bundle of CA certificates and you can
specify alternate certificates with the #CURLOPT_CAINFO option or the #CURLOPT_CAPATH option.
</p>
<p>
When #CURLOPT_SSL_VERIFYPEER is nonzero, and the verification fails to prove that the certificate is
authentic, the connection fails. When the option is zero, the connection succeeds regardless.
</p>
<p>
Authenticating the certificate is not by itself very useful. You typically want to ensure that the
server, as authentically identified by its certificate, is the server you mean to be talking to.
Use #CURLOPT_SSL_VERIFYHOST to control that. 
</p>
End Rem
Const CURLOPT_SSL_VERIFYPEER:Int = CURLOPTTYPE_LONG + 64

Rem
bbdoc: A String naming a file holding one or more certificates to verify the peer with.
about: This makes sense only when used in combination with the #CURLOPT_SSL_VERIFYPEER option.
If #CURLOPT_SSL_VERIFYPEER is zero, #CURLOPT_CAINFO need not even indicate an accessible file.
<p>
Note that option is by default set to the system path where libcurl's cacert bundle is assumed to be stored,
as established at build time.
</p>
End Rem
Const CURLOPT_CAINFO:Int = CURLOPTTYPE_OBJECTPOINT + 65

Rem
bbdoc: The set number will be the redirection limit.
about: If that many redirections have been followed, the next redirect will cause an error
( #CURLE_TOO_MANY_REDIRECTS ). This option only makes sense if the #CURLOPT_FOLLOWLOCATION is used
at the same time.<br>
Setting the limit to 0 will make libcurl refuse any redirect.<br>
Set it to -1 for an infinite number of redirects (which is the default).
End Rem
Const CURLOPT_MAXREDIRS:Int = CURLOPTTYPE_LONG + 68

Rem
bbdoc: If it is a non-zero value, libcurl will attempt to get the modification date of the remote document in this operation.
about: This requires that the remote server sends the time or replies to a time querying command.
The getInfo method with the #CURLINFO_FILETIME argument can be used after a transfer to extract the received time (if any).
End Rem
Const CURLOPT_FILETIME:Int = CURLOPTTYPE_LONG + 69

Rem
bbdoc: For details see #telnetOptions
End Rem
Const CURLOPT_TELNETOPTIONS:Int = CURLOPTTYPE_OBJECTPOINT + 70

Rem
bbdoc: The set amount will be the maximum amount of simultaneously open connections that libcurl may cache in this easy handle.
about: The set number will be the persistent connection cache size. Default is 5, and there isn't much
point in changing this value unless you are perfectly aware of how this work and changes libcurl's
behaviour. This concerns connection using any of the protocols that support persistent connections.
<p>
When reaching the maximum limit, curl closes the oldest one in the cache to prevent the number of
open connections to increase.
</p>
<p>
If you already have performed transfers with this curl handle, setting a smaller MAXCONNECTS than
before may cause open connections to get closed unnecessarily.
</p>
<p>
Note that if you add this easy handle to a multi handle, this setting is not being acknowledged,
but you must instead use #multiSetOptInt and the #CURLMOPT_MAXCONNECTS option. 
</p>
End Rem
Const CURLOPT_MAXCONNECTS:Int = CURLOPTTYPE_LONG + 71

Rem
bbdoc: Set to non-zero to make the next transfer use a new (fresh) connection by force.
about: If the connection cache is full before this connection, one of the existing connections will
be closed as according to the selected or default policy. This option should be used with caution
and only if you understand what it does. Set this to 0 to have libcurl attempt re-using an existing
connection (default behavior).
End Rem
Const CURLOPT_FRESH_CONNECT:Int = CURLOPTTYPE_LONG + 74

Rem
bbdoc: Set to non-zero to make the next transfer explicitly close the connection when done.
about: Normally, libcurl keep all connections alive when done with one transfer in case there comes a
succeeding one that can re-use them. This option should be used with caution and only if you understand
what it does. Set to 0 to have libcurl keep the connection open for possibly later re-use (default behavior).
End Rem
Const CURLOPT_FORBID_REUSE:Int = CURLOPTTYPE_LONG + 75

' Rem
' bbdoc: Set to a file name that contains random data.
' about: The file will be used to read from to seed the random engine for SSL. The more random the specified
' file is, the more secure the SSL connection will become.
' End Rem
' Const CURLOPT_RANDOM_FILE:Int = CURLOPTTYPE_OBJECTPOINT + 76

' Rem
' bbdoc: A path name to the Entropy Gathering Daemon socket.
' about: It will be used to seed the random engine for SSL.
' End Rem
' Const CURLOPT_EGDSOCKET:Int = CURLOPTTYPE_OBJECTPOINT + 77

Rem
bbdoc: It should contain the maximum time in seconds that you allow the connection to the server to take.
about: This only limits the connection phase, once it has connected, this option is of no more use.
Set to zero to disable connection timeout (it will then only timeout on the system's internal timeouts).
See also the #CURLOPT_TIMEOUT option.
<p>
In unix-like systems, this might cause signals to be used unless #CURLOPT_NOSIGNAL is set. 
</p>
End Rem
Const CURLOPT_CONNECTTIMEOUT:Int = CURLOPTTYPE_LONG + 78

Rem
bbdoc: For details see #setHeaderCallback
End Rem
Const CURLOPT_HEADERFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 79

Rem
bbdoc: A number for changing the HTTP request back to get.
about: If the number is non-zero, this forces the HTTP request to get back to GET. Usable if a
POST, HEAD, PUT or a custom request have been used previously using the same curl handle.
<p>
When setting #CURLOPT_HTTPGET to a non-zero value, it will automatically set #CURLOPT_NOBODY to 0
</p> 
End Rem
Const CURLOPT_HTTPGET:Int = CURLOPTTYPE_LONG + 80

Rem
bbdoc: This number option determines whether libcurl verifies that the server cert is for the server it is known as.
about: When negotiating an SSL connection, the server sends a certificate indicating its identity.
<p>
When #CURLOPT_SSL_VERIFYHOST is 2, that certificate must indicate that the server is the server to which you meant
to connect, or the connection fails.
</p>
<p>
Curl considers the server the intended one when the Common Name field or a Subject Alternate Name field in the
certificate matches the host name in the URL to which you told Curl to connect.
</p>
<p>
When the value is 1, the certificate must contain a Common Name field, but it doesn't matter what name it says.
(This is not ordinarily a useful setting).
</p>
<p>
When the value is 0, the connection succeeds regardless of the names in the certificate.
</p>
<p>
The default is 2.
</p>
<p>
The checking this option controls is of the identity that the server claims. The server could be lying.
To control lying, see #CURLOPT_SSL_VERIFYPEER. 
</p>
End Rem
Const CURLOPT_SSL_VERIFYHOST:Int = CURLOPTTYPE_LONG + 81

Rem
bbdoc: A filename, which will make libcurl write all internally known cookies to the specified file when #cleanup is called.
about: If no cookies are known, no file will be created. Specify "-" to instead have the cookies written to stdout.
Using this option also enables cookies for this session, so if you for example follow a location it will make
matching cookies get sent accordingly.
<p>
If the cookie jar file can't be created or written to (when the #cleanup is called), libcurl will not and cannot
report an error for this. Using #CURLOPT_VERBOSE or #setDebugCallback will get a warning to display, but that
is the only visible feedback you get about this possibly lethal situation. 
</p>
End Rem
Const CURLOPT_COOKIEJAR:Int = CURLOPTTYPE_OBJECTPOINT + 82

Rem
bbdoc: A String holding the list of ciphers to use for the SSL connection.
about: The list must be syntactically correct, it consists of one or more cipher strings separated by colons.
Commas or spaces are also acceptable separators but colons are normally used, !, - and + can be used as operators.
<p>
For OpenSSL and GnuTLS valid examples of cipher lists include 'RC4-SHA', ´SHA1+DES´, 'TLSv1' and 'DEFAULT'.
The default list is normally set when you compile OpenSSL.
</p>
<p>
You'll find more details about cipher lists on this URL: http://www.openssl.org/docs/apps/ciphers.html
</p>
End Rem
Const CURLOPT_SSL_CIPHER_LIST:Int = CURLOPTTYPE_OBJECTPOINT + 83

Rem
bbdoc: A number set to one of the values described below to force libcurl to use the specific HTTP versions.
about: This is not sensible to do unless you have a good reason.
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>#CURL_HTTP_VERSION_NONE</td><td>We don't care about what version the library uses. libcurl will use whatever it thinks fit.</td></tr>
<tr><td>#CURL_HTTP_VERSION_1_0</td><td>Please use HTTP 1.0 in the request.</td></tr>
<tr><td>#CURL_HTTP_VERSION_1_1</td><td>Please use HTTP 1.1 in the request.</td></tr>
<tr><td>#CURL_HTTP_VERSION_2_0</td><td>Please use HTTP 2 in the request.</td></tr>
<tr><td>#CURL_HTTP_VERSION_2TLS</td><td>Use version 2 for HTTPS, version 1.1 for HTTP.</td></tr>
<tr><td>#CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE</td><td>Please use HTTP 2 without HTTP/1.1 upgrade.</td></tr>
</table>
End Rem
Const CURLOPT_HTTP_VERSION:Int = CURLOPTTYPE_LONG + 84

Rem
bbdoc: If the value is non-zero, it tells curl to use the EPSV command when doing passive FTP downloads (which it always does by default).
about: Using EPSV means that it will first attempt to use EPSV before using PASV, but if you pass FALSE (zero) to
this option, it will not try using EPSV, only plain PASV.
<p>
If the server is an IPv6 host, this option will have no effect.
</p>
End Rem
Const CURLOPT_FTP_USE_EPSV:Int = CURLOPTTYPE_LONG + 85

Rem
bbdoc: A String in the format of your certificate.
about: Supported formats are "PEM" and "DER".
End Rem
Const CURLOPT_SSLCERTTYPE:Int = CURLOPTTYPE_OBJECTPOINT + 86

Rem
bbdoc: The String should be the file name of your private key.
about: The default format is "PEM" and can be changed with #CURLOPT_SSLKEYTYPE.
End Rem
Const CURLOPT_SSLKEY:Int = CURLOPTTYPE_OBJECTPOINT + 87

Rem
bbdoc: The String should be the format of your private key.
about: Supported formats are "PEM", "DER" and "ENG".
<p>
The format "ENG" enables you to load the private key from a crypto engine. In this case #CURLOPT_SSLKEY is used
as an identifier passed to the engine. You have to set the crypto engine with #CURLOPT_SSLENGINE. "DER" format key
file currently does not work because of a bug in OpenSSL. 
</p>
End Rem
Const CURLOPT_SSLKEYTYPE:Int = CURLOPTTYPE_OBJECTPOINT + 88

Rem
bbdoc: A String to be used as the identifier for the crypto engine you want to use for your private key.
about: If the crypto device cannot be loaded, #CURLE_SSL_ENGINE_NOTFOUND is returned. 
End Rem
Const CURLOPT_SSLENGINE:Int = CURLOPTTYPE_OBJECTPOINT + 89

Rem
bbdoc: A String which sets the actual crypto engine as the default for (asymmetric) crypto operations.
about: If the crypto device cannot be set, #CURLE_SSL_ENGINE_SETFAILED is returned.
End Rem
Const CURLOPT_SSLENGINE_DEFAULT:Int = CURLOPTTYPE_LONG + 90

Rem
bbdoc: This sets the timeout in seconds.
about: Name resolves will be kept in memory for this number of seconds. Set to zero (0) to completely
disable caching, or set to -1 to make the cached entries remain forever. By default, libcurl
caches this info for 60 seconds.
End Rem
Const CURLOPT_DNS_CACHE_TIMEOUT:Int = CURLOPTTYPE_LONG + 92

Rem
bbdoc: See the #preQuote method for details.
End Rem
Const CURLOPT_PREQUOTE:Int = CURLOPTTYPE_OBJECTPOINT + 93

Rem
bbdoc: For details see #setDebugCallback
End Rem
Const CURLOPT_DEBUGFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 94

' used with #setDebugCallback
Const CURLOPT_DEBUGDATA:Int = CURLOPTTYPE_OBJECTPOINT + 95

Rem
bbdoc: Set to non-zero to mark this as a new cookie "session".
about: It will force libcurl to ignore all cookies it is about to load that are "session cookies" from
the previous session. By default, libcurl always stores and loads all cookies, independent if they
are session cookies are not. Session cookies are cookies without expiry date and they are meant
to be alive and existing for this "session" only.
End Rem
Const CURLOPT_COOKIESESSION:Int = CURLOPTTYPE_LONG + 96

Rem
bbdoc: The CApath directory used To validate the peer certificate
about: This option is used only If #SSL_VERIFYPEER is True
End Rem
Const CURLOPT_CAPATH:Int = CURLOPTTYPE_STRINGPOINT + 97

Rem
bbdoc: Specifies your preferred size (in bytes) for the receive buffer in libcurl.
about: The main point of this would be that the write callback gets called more often and with smaller
chunks. This is just treated as a request, not an order. You cannot be guaranteed to actually
get the given size.
<p>
This size is by default set as big as possible (CURL_MAX_WRITE_SIZE), so it only makes sense to use
this option if you want it smaller.
</p>
End Rem
Const CURLOPT_BUFFERSIZE:Int = CURLOPTTYPE_LONG + 98

Rem
bbdoc: If it is non-zero, libcurl will not use any functions that install signal handlers or any functions that cause signals to be sent to the process.
about: This option is mainly here to allow multi-threaded unix applications to still set/use all timeout
options etc, without risking getting signals.
<p>
Consider building libcurl with ares support to enable asynchronous DNS lookups. It enables nice timeouts
for name resolves without signals.
</p>
End Rem
Const CURLOPT_NOSIGNAL:Int = CURLOPTTYPE_LONG + 99

' not required for the module
Const CURLOPT_SHARE:Int = CURLOPTTYPE_OBJECTPOINT + 100

Rem
bbdoc: Indicates yype of proxy.
about: Accepted values are #CURLPROXY_HTTP (default), #CURLPROXY_SOCKS4 And #CURLPROXY_SOCKS5.
End Rem
Const CURLOPT_PROXYTYPE:Int = CURLOPTTYPE_VALUES + 101

Rem
bbdoc: Sets the contents of the Accept-Encoding: header sent in an HTTP request, and enables decoding of a response when a Content-Encoding: header is received.
about: Three encodings are supported: identity, which does nothing, deflate which requests the server
to compress its response using the zlib algorithm, and gzip which requests the gzip algorithm. If a
zero-length string is set, then an Accept-Encoding: header containing all supported encodings is sent.
<p>
This is a request, not an order; the server may or may not do it. This option must be set
(to any non-NULL value) or else any unsolicited encoding done by the server is ignored.
</p>
<p>
<i>
HTTP/1.1 [RFC 2616] specifies that a client may request that a server encode
its response. This is usually used to compress a response using one of a set
of commonly available compression techniques. These schemes are 'deflate' (the
zlib algorithm), 'gzip' and 'compress' [sec 3.5, RFC 2616]. A client requests
that the sever perform an encoding by including an Accept-Encoding header in
the request document. The value of the header should be one of the recognized
tokens 'deflate', ... (there's a way to register new schemes/tokens, see sec
3.5 of the spec). A server MAY honor the client's encoding request. When a
response is encoded, the server includes a Content-Encoding header in the
response. The value of the Content-Encoding header indicates which scheme was
used to encode the data.
<br>
A client may tell a server that it can understand several different encoding
schemes. In this case the server may choose any one of those and use it to
encode the response (indicating which one using the Content-Encoding header).
It's also possible for a client to attach priorities to different schemes so
that the server knows which it prefers. See sec 14.3 of RFC 2616 for more
information on the Accept-Encoding header.
</i>
</p>
<p>
Currently, libcurl only understands how to process responses that use the
"deflate" or "gzip" Content-Encoding, so the only values for #CURLOPT_ENCODING
that will work (besides "<b>identity</b>", which does nothing) are "<b>deflate</b>" and
"<b>gzip</b>". If a response is encoded using the "compress" or other methods, libcurl will
return an error indicating that the response could not be decoded.  If
the string is Null no Accept-Encoding header is generated.  If the String is a
zero-length string, then an Accept-Encoding header containing all supported
encodings will be generated.
</p>
<p>
The #CURLOPT_ENCODING must be set to any non-NULL value for content to be
automatically decoded.  If it is not set and the server still sends encoded
content (despite not having been asked), the data is returned in its raw form
and the Content-Encoding type is not checked.
</p>
End Rem
Const CURLOPT_ENCODING:Int = CURLOPTTYPE_STRINGPOINT + 102

Rem
bbdoc: See the #setPrivate method for details.
End Rem
Const CURLOPT_PRIVATE:Int = CURLOPTTYPE_OBJECTPOINT + 103

Rem
bbdoc: See the #http200Aliases method for details.
End Rem
Const CURLOPT_HTTP200ALIASES:Int = CURLOPTTYPE_OBJECTPOINT + 104

Rem
bbdoc: A non-zero value tells the library it can continue to send authentication (user+password) when following locations, even when hostname changed.
about: This option is meaningful only when setting #CURLOPT_FOLLOWLOCATION.
End Rem
Const CURLOPT_UNRESTRICTED_AUTH:Int = CURLOPTTYPE_LONG + 105

Rem
bbdoc: If the value is non-zero, it tells curl to use the EPRT (and LPRT) command when doing active FTP downloads (which is enabled by #CURLOPT_FTPPORT).
about: Using EPRT means that it will first attempt to use EPRT and then LPRT before using PORT, but if you pass
False (zero) to this option, it will not try using EPRT or LPRT, only plain PORT.
<p>
If the server is an IPv6 host, this option will have no effect.
</p>
End Rem
Const CURLOPT_FTP_USE_EPRT:Int = CURLOPTTYPE_LONG + 106

Rem
bbdoc: A number which is set to a bitmask, to tell libcurl what authentication method(s) you want it to use.
about: The available bits, which can be or'd (|) together are listed below. If more than one bit is set, libcurl
will first query the site to see what authentication methods it supports and then pick the best one you allow it
to use. For some methods, this will induce an extra network round-trip. Set the actual name and password with
the #CURLOPT_USERPWD option.<br>
Options are #CURLAUTH_BASIC, #CURLAUTH_DIGEST, #CURLAUTH_NTLM, #CURLAUTH_ANY and #CURLAUTH_ANYSAFE.
End Rem
Const CURLOPT_HTTPAUTH:Int = CURLOPTTYPE_LONG + 107

' not using this... yet.
Const CURLOPT_SSL_CTX_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 108

' not using this... yet.
Const CURLOPT_SSL_CTX_DATA:Int = CURLOPTTYPE_OBJECTPOINT + 109

Rem
bbdoc: If the value is non-zero, curl will attempt to create any remote directory that it fails to CWD into.
about: CWD is the command that changes working directory.
<p>
This setting also applies to SFTP-connections. curl will attempt to create the remote directory if it can't obtain
a handle to the target-location. The creation will fail if a file of the same name as the directory to create
already exists or lack of permissions prevents creation.
</p>
End Rem
Const CURLOPT_FTP_CREATE_MISSING_DIRS:Int = CURLOPTTYPE_LONG + 110

Rem
bbdoc: A number, which is set to a bitmask, to tell libcurl what authentication method(s) you want it to use for your proxy authentication.
about: If more than one bit is set, libcurl will first query the site to see what authentication methods
it supports and then pick the best one you allow it to use. For some methods, this will induce an extra
network round-trip. Set the actual name and password with the #CURLOPT_PROXYUSERPWD option. The bitmask
can be constructed by or'ing together the bits listed in the #CURLOPT_HTTPAUTH option. As of this writing,
only #CURLAUTH_BASIC, #CURLAUTH_DIGEST, #CURLAUTH_NTLM work. 
End Rem
Const CURLOPT_PROXYAUTH:Int = CURLOPTTYPE_LONG + 111

Rem
bbdoc: Causes curl to set a timeout period (in seconds) on the amount of time that the server is allowed to take in order to generate a response message for a command before the session is considered hung.
about: While curl is waiting for a response, this value overrides #CURLOPT_TIMEOUT. It is recommended that if used
in conjunction with #CURLOPT_TIMEOUT, you set #CURLOPT_FTP_RESPONSE_TIMEOUT to a value smaller than #CURLOPT_TIMEOUT.
End Rem
Const CURLOPT_FTP_RESPONSE_TIMEOUT:Int = CURLOPTTYPE_LONG + 112

Rem
bbdoc: Allows an application to select what kind of IP addresses to use when resolving host names.
about: This is only interesting when using host names that resolve addresses using more than one version of IP.
The allowed values are:
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURL_IPRESOLVE_WHATEVER</td><td>Default, resolves addresses to all IP versions that your system allows.</td></tr>
<tr><td>CURL_IPRESOLVE_V4</td><td>Resolve to ipv4 addresses.</td></tr>
<tr><td>CURL_IPRESOLVE_V6</td><td>Resolve to ipv6 addresses.</td></tr>
</table>
End Rem
Const CURLOPT_IPRESOLVE:Int = CURLOPTTYPE_LONG + 113

Rem
bbdoc: An Int value which allows you to specify the maximum size (in bytes) of a file to download.
about: If the file requested is larger than this value, the transfer will not start and 
#CURLE_FILESIZE_EXCEEDED will be returned.
<p>
The file size is not always known prior to download, and for such files this option has no effect even
if the file transfer ends up being larger than this given limit. This concerns both FTP and HTTP transfers.
</p>
End Rem
Const CURLOPT_MAXFILESIZE:Int = CURLOPTTYPE_LONG + 114

Rem
bbdoc: When uploading a file to a remote site, this option should be used to pass a Long value to tell libcurl what the expected size of the infile is.
about: For uploading using SCP, this option or #CURLOPT_INFILESIZE is mandatory.
<p>
Note that this option does not limit how much data libcurl will actually send, as that is controlled entirely
by what the read callback returns. 
</p>
End Rem
Const CURLOPT_INFILESIZE_LARGE:Int = CURLOPTTYPE_OFF_T + 115

Rem
bbdoc: It contains the offset in number of bytes that you want the transfer to start from.
about: This is a Long value.
End Rem
Const CURLOPT_RESUME_FROM_LARGE:Int = CURLOPTTYPE_OFF_T + 116

Rem
bbdoc: This allows you to specify a Long value for the maximum size (in bytes) of a file to download.
about: If the file requested is larger than this value, the transfer will not start and 
#CURLE_FILESIZE_EXCEEDED will be returned.
<p>
The file size is not always known prior to download, and for such files this option has no effect
even if the file transfer ends up being larger than this given limit. This concerns both FTP and HTTP
transfers. 
</p>
End Rem
Const CURLOPT_MAXFILESIZE_LARGE:Int = CURLOPTTYPE_OFF_T + 117

Rem
bbdoc: A string containing the full path name to the file you want libcurl to use as .netrc file.
about: If this option is omitted, and #CURLOPT_NETRC is set, libcurl will attempt to find the a .netrc
file in the current user's home directory.
End Rem
Const CURLOPT_NETRC_FILE:Int = CURLOPTTYPE_OBJECTPOINT + 118

Rem
bbdoc: If enabled, this option makes libcurl use CCC (Clear Command Channel).
about: It shuts down the SSL/TLS layer after authenticating. The rest of the control channel communication will
be unencrypted. This allows NAT routers to follow the FTP transaction. Pass a long using one of the values below.
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURLFTPSSL_CCC_NONE</td><td>Don't attempt to use CCC.</td></tr>
<tr><td>CURLFTPSSL_CCC_PASSIVE</td><td>Do not initiate the shutdown, but wait for the server to do it. Do not send a reply.</td></tr>
<tr><td>CURLFTPSSL_CCC_ACTIVE</td><td>Initiate the shutdown and wait for a reply.</td></tr>
</table>
End Rem
Const CURLOPT_FTP_SSL:Int = CURLOPTTYPE_LONG + 119

Rem
bbdoc: The large-file version of the standard #CURLOPT_POSTFIELDSIZE option.
End Rem
Const CURLOPT_POSTFIELDSIZE_LARGE:Int = CURLOPTTYPE_OFF_T + 120

Rem
bbdoc: A number specifying whether the TCP_NODELAY option should be set or cleared (1 = set, 0 = clear).
about: The option is cleared by default. This will have no effect after the connection has been established.
<p>
Setting this option will disable TCP's Nagle algorithm. The purpose of this algorithm is to try to
minimize the number of small packets on the network (where "small packets" means TCP segments less than
the Maximum Segment Size (MSS) for the network).
</p>
<p>
Maximizing the amount of data sent per TCP segment is good because it amortizes the overhead of the send.
However, in some cases (most notably telnet or rlogin) small segments may need to be sent without delay.
This is less efficient than sending larger amounts of data at a time, and can contribute to congestion
on the network if overdone.
</p>
End Rem
Const CURLOPT_TCP_NODELAY:Int = CURLOPTTYPE_LONG + 121

Rem
bbdoc: Use one of the values from below, to alter how libcurl issues "AUTH TLS" or "AUTH SSL" when FTP over SSL is activated.
about: See also #CURLOPT_FTP_SSL.
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURLFTPAUTH_DEFAULT</td><td>Allow libcurl to decide</td></tr>
<tr><td>CURLFTPAUTH_SSL</td><td>Try "AUTH SSL" first, and only if that fails try "AUTH TLS"</td></tr>
<tr><td>CURLFTPAUTH_TLS</td><td>Try "AUTH TLS" first, and only if that fails try "AUTH SSL"</td></tr>
</table>
End Rem
Const CURLOPT_FTPSSLAUTH:Int = CURLOPTTYPE_LONG + 129

' Const CURLOPT_IOCTLFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 130
' Const CURLOPT_IOCTLDATA:Int = CURLOPTTYPE_OBJECTPOINT + 131

Rem
bbdoc: A String, or Null to disable.
about: When an FTP server asks for "account data" after user name and password has been provided,
this data is sent off using the ACCT command.
End Rem
Const CURLOPT_FTP_ACCOUNT:Int = CURLOPTTYPE_OBJECTPOINT + 134

Rem
bbdoc: Add a cookie String.
about: Cookie can be either in Netscape / Mozilla format or just regular HTTP-style header (Set-Cookie: ...)
format. If cURL cookie engine was not enabled it will enable its cookie engine. Passing a magic
string "ALL" will erase all cookies known by cURL. Passing the special string "SESS" will only erase
all session cookies known by cURL.
End Rem
Const CURLOPT_COOKIELIST:Int = CURLOPTTYPE_OBJECTPOINT + 135

Rem
bbdoc: Ignore the Content-Length header.
about: This is useful for Apache 1.x (and similar servers) which will report incorrect content length for files
over 2 gigabytes. If this option is used, curl will not be able to accurately report progress, and will
simply stop the download when the server ends the connection.
End Rem
Const CURLOPT_IGNORE_CONTENT_LENGTH:Int = CURLOPTTYPE_LONG + 136

Rem
bbdoc: If set to a non-zero value, it instructs libcurl to not use the IP address the server suggests in its 227-response to libcurl's PASV command when libcurl connects the data connection.
about: Instead libcurl will re-use the same IP address it already uses for the control connection. But it will
use the port number from the 227-response.
<p>
This option has no effect if PORT, EPRT or EPSV is used instead of PASV. 
</p>
End Rem
Const CURLOPT_FTP_SKIP_PASV_IP:Int = CURLOPTTYPE_LONG + 137

Rem
bbdoc: This option controls what method libcurl should use to reach a file on a FTP(S) server.
about: The argument should be one of the following alternatives:
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURLFTPMETHOD_MULTICWD</td><td>libcurl does a single CWD operation for each path part in the given URL.
For deep hierarchies this means very many commands. This is how RFC1738 says it should be done. This is the
default but the slowest behavior.</td></tr>
<tr><td>CURLFTPMETHOD_NOCWD</td><td>libcurl does no CWD at all. libcurl will do SIZE, RETR, STOR etc and give a
full path to the server for all these commands. This is the fastest behavior.</td></tr>
<tr><td>CURLFTPMETHOD_SINGLECWD</td><td>libcurl does one CWD with the full target directory and then operates
on the file "normally" (like in the multicwd case). This is somewhat more standards compliant than 'nocwd'
but without the full penalty of 'multicwd'.</td></tr>
</table>
End Rem
Const CURLOPT_FTP_FILEMETHOD:Int = CURLOPTTYPE_LONG + 138

Rem
bbdoc: This sets the local port number of the socket used for connection.
about: This can be used in combination with #CURLOPT_INTERFACE and you are recommended to use
#CURLOPT_LOCALPORTRANGE as well when this is set. Note that port numbers are only valid 1 - 65535.
End Rem
Const CURLOPT_LOCALPORT:Int = CURLOPTTYPE_LONG + 139

Rem
bbdoc: This is the number of attempts libcurl should do to find a working local port number.
about: It starts with the given #CURLOPT_LOCALPORT and adds one to the number for each retry.
Setting this value to 1 or below will make libcurl do only one try for exact port number.
Note that port numbers by nature is a scarce resource that will be busy at times so setting this value
to something too low might cause unnecessary connection setup failures.
End Rem
Const CURLOPT_LOCALPORTRANGE:Int = CURLOPTTYPE_LONG + 140

Rem
bbdoc: A non-zero parameter tells the library to perform any required proxy authentication and connection setup, but no data transfer.
about: This option is useful with the #lastSocket option of #TCurlInfo. The library can set up the connection
and then the application can obtain the most recently used socket for special data transfers.
End Rem
Const CURLOPT_CONNECT_ONLY:Int = CURLOPTTYPE_LONG + 141

' Rem
' bbdoc: Function that will be called To convert from the network encoding (instead of using the iconv calls in libcurl)
' End Rem
' Const CURLOPT_CONV_FROM_NETWORK_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 142

' Rem
' bbdoc: Function that will be called To convert To the network encoding (instead of using the iconv calls in libcurl)
' End Rem
' Const CURLOPT_CONV_TO_NETWORK_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 143

' Rem
' bbdoc: Function that will be called To convert from UTF8
' about: (instead of using the iconv calls in libcurl) Note that this is used only For SSL certificate processing
' End Rem
' Const CURLOPT_CONV_FROM_UTF8_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 144

Rem
bbdoc: If an upload exceeds this speed on cumulative average during the transfer, the transfer will pause to keep the average rate less than or equal to this Long value.
about: Defaults to unlimited speed.
End Rem
Const CURLOPT_MAX_SEND_SPEED_LARGE:Int = CURLOPTTYPE_OFF_T + 145

Rem
bbdoc: If a download exceeds this speed on cumulative average during the transfer, the transfer will pause to keep the average rate less than or equal to this Long value.
about: Defaults to unlimited speed.
End Rem
Const CURLOPT_MAX_RECV_SPEED_LARGE:Int = CURLOPTTYPE_OFF_T + 146

Rem
bbdoc: A string which will be used to authenticate if the usual FTP "USER user" and "PASS password" negotiation fails.
about: This is currently only known to be required when connecting to Tumbleweed's Secure Transport
FTPS server using client certificates for authentication.
End Rem
Const CURLOPT_FTP_ALTERNATIVE_TO_USER:Int = CURLOPTTYPE_OBJECTPOINT + 147

' 
Const CURLOPT_SOCKOPTFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 148
' 
Const CURLOPT_SOCKOPTDATA:Int = CURLOPTTYPE_OBJECTPOINT + 149

Rem
bbdoc: Set to 0 to disable libcurl's use of SSL session-ID caching.
about: Set this to 1 to enable it. By default all transfers are done using the cache. Note that while
nothing ever should get hurt by attempting to reuse SSL session-IDs, there seem to be broken SSL
implementations in the wild that may require you to disable this in order for you to succeed.
End Rem
Const CURLOPT_SSL_SESSIONID_CACHE:Int = CURLOPTTYPE_LONG + 150

Rem
bbdoc: Set to a bitmask consisting of one or more of #CURLSSH_AUTH_PUBLICKEY, #CURLSSH_AUTH_PASSWORD, #CURLSSH_AUTH_HOST, #CURLSSH_AUTH_KEYBOARD.
about: Set #CURLSSH_AUTH_ANY to let libcurl pick one.
End Rem
Const CURLOPT_SSH_AUTH_TYPES:Int = CURLOPTTYPE_LONG + 151

Rem
bbdoc: A file name for your public key.
about: If not used, libcurl defaults to using ~/.ssh/id_dsa.pub.
End Rem
Const CURLOPT_SSH_PUBLIC_KEYFILE:Int = CURLOPTTYPE_OBJECTPOINT + 152

Rem
bbdoc: A file name for your private key.
about: If not used, libcurl defaults to using ~/.ssh/id_dsa. If the file is password-protected,
set the password with #CURLOPT_SSLKEYPASSWD.
End Rem
Const CURLOPT_SSH_PRIVATE_KEYFILE:Int = CURLOPTTYPE_OBJECTPOINT + 153

Rem
bbdoc: If enabled, this option makes libcurl use CCC (Clear Command Channel).
about: It shuts down the SSL/TLS layer after authenticating. The rest of the control channel
communication will be unencrypted. This allows NAT routers to follow the FTP transaction. Use one of the 
following values:
<table>
<tr><th>Constant</th><th>Meaning</th></tr>
<tr><td>CURLFTPSSL_CCC_NONE</td><td>Don't attempt to use CCC.</td></tr>
<tr><td>CURLFTPSSL_CCC_PASSIVE</td><td>Do not initiate the shutdown, but wait for the server to do it.
Do not send a reply.</td></tr>
<tr><td>CURLFTPSSL_CCC_ACTIVE</td><td>Initiate the shutdown and wait for a reply.</td></tr>
</table>
End Rem
Const CURLOPT_FTP_SSL_CCC:Int = CURLOPTTYPE_LONG + 154

Rem
bbdoc: Like #CURLOPT_TIMEOUT but takes number of milliseconds instead.
about: If libcurl is built to use the standard system name resolver, that part will still use full-second
resolution for timeouts.
End Rem
Const CURLOPT_TIMEOUT_MS:Int = CURLOPTTYPE_LONG + 155

Rem
bbdoc: Like #CURLOPT_CONNECTTIMEOUT but takes number of milliseconds instead.
about: If libcurl is built to use the standard system name resolver, that part will still use full-second
resolution for timeouts.
End Rem
Const CURLOPT_CONNECTTIMEOUT_MS:Int = CURLOPTTYPE_LONG + 156

Rem
bbdoc: Tell libcurl how to act on transfer decoding.
about: If set to zero, transfer decoding will be disabled, if set to 1 it is enabled (default).
libcurl does chunked transfer decoding by default unless this option is set to zero.
End Rem
Const CURLOPT_HTTP_TRANSFER_DECODING:Int = CURLOPTTYPE_LONG + 157

Rem
bbdoc: Tell libcurl how to act on content decoding.
about: If set to zero, content decoding will be disabled. If set to 1 it is enabled. Note however that
libcurl has no default content decoding but requires you to use #CURLOPT_ENCODING for that.
End Rem
Const CURLOPT_HTTP_CONTENT_DECODING:Int = CURLOPTTYPE_LONG + 158

Rem
bbdoc: A value containing the value of the permissions that will be assigned to newly created files on the remote server.
about: The default value is 0644, but any valid value can be used. The only protocols that can use this
are sftp://, scp:// and file://.
End Rem
Const CURLOPT_NEW_FILE_PERMS:Int = CURLOPTTYPE_LONG + 159

Rem
bbdoc: A value containing the value of the permissions that will be assigned to newly created directories on the remote server.
about: The default value is 0755, but any valid value can be used. The only protocols that can use this
are sftp://, scp:// and file://.
End Rem
Const CURLOPT_NEW_DIRECTORY_PERMS:Int = CURLOPTTYPE_LONG + 160

Rem
bbdoc: Set the behaviour of POST when redirecting.
about: Values must be set to one of CURL_REDIR* defines below. This used to be called CURLOPT_POST301 
End Rem
Const CURLOPT_POSTREDIR:Int = CURLOPTTYPE_LONG + 161

Rem
bbdoc: used by scp/sftp to verify the host's public key 
End Rem
Const CURLOPT_SSH_HOST_PUBLIC_KEY_MD5:Int = CURLOPTTYPE_OBJECTPOINT + 162

Rem
bbdoc: Callback function for opening socket (instead of socket(2)).
about: Optionally, callback is able change the address or refuse to connect returning CURL_SOCKET_BAD.
The callback should have type curl_opensocket_callback 
End Rem
Const CURLOPT_OPENSOCKETFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 163
Const CURLOPT_OPENSOCKETDATA:Int = CURLOPTTYPE_OBJECTPOINT + 164

Rem
bbdoc: POST volatile input fields. 
End Rem
Const CURLOPT_COPYPOSTFIELDS:Int = CURLOPTTYPE_OBJECTPOINT + 165

Rem
bbdoc: Set transfer mode (;type=&lt;a|i&gt;) when doing FTP via an HTTP proxy 
End Rem
Const CURLOPT_PROXY_TRANSFER_MODE:Int = CURLOPTTYPE_LONG + 166

Rem
bbdoc: Callback function for seeking in the input stream 
End Rem
Const CURLOPT_SEEKFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 167
Const CURLOPT_SEEKDATA:Int = CURLOPTTYPE_OBJECTPOINT + 168

Rem
bbdoc: CRL file 
End Rem
Const CURLOPT_CRLFILE:Int = CURLOPTTYPE_OBJECTPOINT + 169

Rem
bbdoc: Issuer certificate 
End Rem
Const CURLOPT_ISSUERCERT:Int = CURLOPTTYPE_OBJECTPOINT + 170

Rem
bbdoc: (IPv6) Address scope 
End Rem
Const CURLOPT_ADDRESS_SCOPE:Int = CURLOPTTYPE_LONG + 171

Rem
bbdoc: Collect certificate chain info and allow it to get retrievable with CURLINFO_CERTINFO after the transfer is complete.
about: (Unfortunately) only working with OpenSSL-powered builds. 
End Rem
Const CURLOPT_CERTINFO:Int = CURLOPTTYPE_LONG + 172

Rem
bbdoc: "name" and "pwd" to use when fetching. 
End Rem
Const CURLOPT_USERNAME:Int = CURLOPTTYPE_OBJECTPOINT + 173
Const CURLOPT_PASSWORD:Int = CURLOPTTYPE_OBJECTPOINT + 174

Rem
bbdoc: "name" and "pwd" to use with Proxy when fetching. 
End Rem
Const CURLOPT_PROXYUSERNAME:Int = CURLOPTTYPE_OBJECTPOINT + 175
Const CURLOPT_PROXYPASSWORD:Int = CURLOPTTYPE_OBJECTPOINT + 176

Rem
bbdoc: Comma separated list of hostnames defining no-proxy zones.
about: These should match both hostnames directly, and hostnames within a domain. For example, local.com will match local.com and www.local.com, but NOT
notlocal.com or www.notlocal.com. For compatibility with other implementations of this, .local.com will be considered to be the same as
local.com. A single * is the only valid wildcard, and effectively disables the use of proxy. 
End Rem
Const CURLOPT_NOPROXY:Int = CURLOPTTYPE_OBJECTPOINT + 177

Rem
bbdoc: block size for TFTP transfers 
End Rem
Const CURLOPT_TFTP_BLKSIZE:Int = CURLOPTTYPE_LONG + 178

Rem
bbdoc: Socks Service 
End Rem
Const CURLOPT_SOCKS5_GSSAPI_SERVICE:Int = CURLOPTTYPE_OBJECTPOINT + 179

Rem
bbdoc: Socks Service 
End Rem
Const CURLOPT_SOCKS5_GSSAPI_NEC:Int = CURLOPTTYPE_LONG + 180

Rem
bbdoc: Set the bitmask for the protocols that are allowed to be used for the transfer, which thus helps the app which takes URLs from users or other external inputs and want to restrict what protocol(s) to deal with.
about: Defaults to CURLPROTO_ALL. 
End Rem
Const CURLOPT_PROTOCOLS:Int = CURLOPTTYPE_LONG + 181

Rem
bbdoc: Set the bitmask for the protocols that libcurl is allowed to follow to, as a subset of the CURLOPT_PROTOCOLS ones.
about: That means the protocol needs to be set in both bitmasks to be allowed to get redirected to. Defaults to all protocols except FILE and SCP. 
End Rem
Const CURLOPT_REDIR_PROTOCOLS:Int = CURLOPTTYPE_LONG + 182

Rem
bbdoc: set the SSH knownhost file name to use 
End Rem
Const CURLOPT_SSH_KNOWNHOSTS:Int = CURLOPTTYPE_OBJECTPOINT + 183

Rem
bbdoc: set the SSH host key callback, must point to a curl_sshkeycallback function 
End Rem
Const CURLOPT_SSH_KEYFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 184

Rem
bbdoc: set the SSH host key callback custom pointer 
End Rem
Const CURLOPT_SSH_KEYDATA:Int = CURLOPTTYPE_OBJECTPOINT + 185

Rem
bbdoc: set the SMTP mail originator 
End Rem
Const CURLOPT_MAIL_FROM:Int = CURLOPTTYPE_OBJECTPOINT + 186

Rem
bbdoc: set the SMTP mail receiver(s) 
End Rem
Const CURLOPT_MAIL_RCPT:Int = CURLOPTTYPE_OBJECTPOINT + 187

Rem
bbdoc: FTP: send PRET before PASV 
End Rem
Const CURLOPT_FTP_USE_PRET:Int = CURLOPTTYPE_LONG + 188

Rem
bbdoc: RTSP request method (OPTIONS, SETUP, PLAY, etc...) 
End Rem
Const CURLOPT_RTSP_REQUEST:Int = CURLOPTTYPE_LONG + 189

Rem
bbdoc: The RTSP session identifier 
End Rem
Const CURLOPT_RTSP_SESSION_ID:Int = CURLOPTTYPE_OBJECTPOINT + 190

Rem
bbdoc: The RTSP stream URI 
End Rem
Const CURLOPT_RTSP_STREAM_URI:Int = CURLOPTTYPE_OBJECTPOINT + 191

Rem
bbdoc: The Transport: header to use in RTSP requests 
End Rem
Const CURLOPT_RTSP_TRANSPORT:Int = CURLOPTTYPE_OBJECTPOINT + 192

Rem
bbdoc: Manually initialize the client RTSP CSeq for this handle 
End Rem
Const CURLOPT_RTSP_CLIENT_CSEQ:Int = CURLOPTTYPE_LONG + 193

Rem
bbdoc: Manually initialize the server RTSP CSeq for this handle 
End Rem
Const CURLOPT_RTSP_SERVER_CSEQ:Int = CURLOPTTYPE_LONG + 194

Rem
bbdoc: The stream to pass to INTERLEAVEFUNCTION. 
End Rem
Const CURLOPT_INTERLEAVEDATA:Int = CURLOPTTYPE_OBJECTPOINT + 195

Rem
bbdoc: Let the application define a custom write method for RTP data 
End Rem
Const CURLOPT_INTERLEAVEFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 196

Rem
bbdoc: Turn on wildcard matching 
End Rem
Const CURLOPT_WILDCARDMATCH:Int = CURLOPTTYPE_LONG + 197

Rem
bbdoc: Directory matching callback called before downloading of an individual file (chunk) started 
End Rem
Const CURLOPT_CHUNK_BGN_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 198

Rem
bbdoc: Directory matching callback called after the file (chunk)
     was downloaded, or skipped 
End Rem
Const CURLOPT_CHUNK_END_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 199

Rem
bbdoc: Change match (fnmatch-like) callback for wildcard matching 
End Rem
Const CURLOPT_FNMATCH_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 200

Rem
bbdoc: Let the application define custom chunk data pointer 
End Rem
Const CURLOPT_CHUNK_DATA:Int = CURLOPTTYPE_OBJECTPOINT + 201

Rem
bbdoc: FNMATCH_FUNCTION user pointer 
End Rem
Const CURLOPT_FNMATCH_DATA:Int = CURLOPTTYPE_OBJECTPOINT + 202

Rem
bbdoc: send linked-list of name:port:address sets 
End Rem
Const CURLOPT_RESOLVE:Int = CURLOPTTYPE_OBJECTPOINT + 203

Rem
bbdoc: Set a username for authenticated TLS 
End Rem
Const CURLOPT_TLSAUTH_USERNAME:Int = CURLOPTTYPE_OBJECTPOINT + 204

Rem
bbdoc: Set a password for authenticated TLS 
End Rem
Const CURLOPT_TLSAUTH_PASSWORD:Int = CURLOPTTYPE_OBJECTPOINT + 205

Rem
bbdoc: Set authentication type for authenticated TLS 
End Rem
Const CURLOPT_TLSAUTH_TYPE:Int = CURLOPTTYPE_OBJECTPOINT + 206

Rem
bbdoc: Set to 1 to enable the "TE:" header in HTTP requests to ask for compressed transfer-encoded responses. Set to 0 to disable the use of TE: in outgoing requests.
about: The current default is 0, but it might change in a future libcurl release.
     libcurl will ask for the compressed methods it knows of, and if that
     isn't any, it will not ask for transfer-encoding at all even if this
     option is set to 1.
End Rem
Const CURLOPT_TRANSFER_ENCODING:Int = CURLOPTTYPE_LONG + 207

Rem
bbdoc: Callback function for closing socket (instead of close(2)).
about: The callback should have type curl_closesocket_callback 
End Rem
Const CURLOPT_CLOSESOCKETFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 208
Const CURLOPT_CLOSESOCKETDATA:Int = CURLOPTTYPE_OBJECTPOINT + 209

Rem
bbdoc: allow GSSAPI credential delegation
End Rem
Const CURLOPT_GSSAPI_DELEGATION:Int = CURLOPTTYPE_LONG + 210

Rem
bbdoc: Set the name servers to use for DNS resolution
End Rem
Const CURLOPT_DNS_SERVERS:Int = CURLOPTTYPE_STRINGPOINT + 211

Rem
bbdoc: Time-out accept operations (currently for FTP only) after this amount of miliseconds.
End Rem
Const CURLOPT_ACCEPTTIMEOUT_MS:Int = CURLOPTTYPE_LONG + 212

Rem
bbdoc: Set TCP keepalive
End Rem
Const CURLOPT_TCP_KEEPALIVE:Int = CURLOPTTYPE_LONG + 213

Rem
bbdoc: non-universal keepalive knobs (Linux, AIX, HP-UX, more)
End Rem
Const CURLOPT_TCP_KEEPIDLE:Int = CURLOPTTYPE_LONG + 214
Const CURLOPT_TCP_KEEPINTVL:Int = CURLOPTTYPE_LONG + 215

Rem
bbdoc: Enable/disable specific SSL features with a bitmask, see CURLSSLOPT_*
End Rem
Const CURLOPT_SSL_OPTIONS:Int = CURLOPTTYPE_LONG + 216

Rem
bbdoc: Set the SMTP auth originator
End Rem
Const CURLOPT_MAIL_AUTH:Int = CURLOPTTYPE_STRINGPOINT + 217

Rem
bbdoc: Enable/disable SASL initial response
End Rem
Const CURLOPT_SASL_IR:Int = CURLOPTTYPE_LONG + 218

Rem
bbdoc: Function that will be called instead of the internal progress display function.
about: This function should be defined as the curl_xferinfo_callback prototype defines. (Deprecates CURLOPT_PROGRESSFUNCTION)
End Rem
Const CURLOPT_XFERINFOFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 219
'Rem
'bbdoc: A synonym for #CURLOPT_PROGRESSDATA
'End Rem
'Const CURLOPT_XFERINFODATA:Int = CURLOPT_PROGRESSDATA

Rem
bbdoc: The XOAUTH2 bearer token
End Rem
Const CURLOPT_XOAUTH2_BEARER:Int = CURLOPTTYPE_STRINGPOINT + 220

Rem
bbdoc: Set the interface string to use as outgoing network interface for DNS requests.
about: Only supported by the c-ares DNS backend
End Rem
Const CURLOPT_DNS_INTERFACE:Int = CURLOPTTYPE_STRINGPOINT + 221

Rem
bbdoc: Set the local IPv4 address to use for outgoing DNS requests.
about: Only supported by the c-ares DNS backend
End Rem
Const CURLOPT_DNS_LOCAL_IP4:Int = CURLOPTTYPE_STRINGPOINT + 222

Rem
bbdoc: Set the local IPv4 address to use for outgoing DNS requests.
about: Only supported by the c-ares DNS backend
End Rem
Const CURLOPT_DNS_LOCAL_IP6:Int = CURLOPTTYPE_STRINGPOINT + 223

Rem
bbdoc: Set authentication options directly
End Rem
Const CURLOPT_LOGIN_OPTIONS:Int = CURLOPTTYPE_STRINGPOINT + 224

Rem
bbdoc: Enable/disable TLS NPN extension (http2 over ssl might fail without)
End Rem
Const CURLOPT_SSL_ENABLE_NPN:Int = CURLOPTTYPE_LONG + 225

Rem
bbdoc: Enable/disable TLS ALPN extension (http2 over ssl might fail without)
End Rem
Const CURLOPT_SSL_ENABLE_ALPN:Int = CURLOPTTYPE_LONG + 226

Rem
bbdoc: Time to wait for a response to a HTTP request containing an Expect: 100-continue header before sending the data anyway.
End Rem
Const CURLOPT_EXPECT_100_TIMEOUT_MS:Int = CURLOPTTYPE_LONG + 227

Rem
bbdoc: This points to a linked list of headers used for proxy requests only, struct curl_slist kind
End Rem
Const CURLOPT_PROXYHEADER:Int = CURLOPTTYPE_OBJECTPOINT + 228

Rem
bbdoc: Pass in a bitmask of "header options"
End Rem
Const CURLOPT_HEADEROPT:Int = CURLOPTTYPE_LONG + 229

Rem
bbdoc: The public key in DER form used to validate the peer public key this option is used only if SSL_VERIFYPEER is true
End Rem
Const CURLOPT_PINNEDPUBLICKEY:Int = CURLOPTTYPE_STRINGPOINT + 230

Rem
bbdoc: Path to Unix domain socket
End Rem
Const CURLOPT_UNIX_SOCKET_PATH:Int = CURLOPTTYPE_STRINGPOINT + 231

Rem
bbdoc: Set if we should verify the certificate status.
End Rem
Const CURLOPT_SSL_VERIFYSTATUS:Int = CURLOPTTYPE_LONG + 232

' Rem
' bbdoc: Set if we should enable TLS false start.
' End Rem
' Const CURLOPT_SSL_FALSESTART:Int = CURLOPTTYPE_LONG + 233

Rem
bbdoc: Do not squash dot-dot sequences
End Rem
Const CURLOPT_PATH_AS_IS:Int = CURLOPTTYPE_LONG + 234

Rem
bbdoc: Proxy Service Name
End Rem
Const CURLOPT_PROXY_SERVICE_NAME:Int = CURLOPTTYPE_STRINGPOINT + 235

Rem
bbdoc: Service Name
End Rem
Const CURLOPT_SERVICE_NAME:Int = CURLOPTTYPE_STRINGPOINT + 236

Rem
bbdoc: Wait/don't wait for pipe/mutex to clarify
End Rem
Const CURLOPT_PIPEWAIT:Int = CURLOPTTYPE_LONG + 237

Rem
bbdoc: Set the protocol used when curl is given a URL without a protocol
End Rem
Const CURLOPT_DEFAULT_PROTOCOL:Int = CURLOPTTYPE_STRINGPOINT + 238

Rem
bbdoc: Set stream weight, 1 - 256 (default is 16)
End Rem
Const CURLOPT_STREAM_WEIGHT:Int = CURLOPTTYPE_LONG + 239

Rem
bbdoc: Set stream dependency on another CURL handle
End Rem
Const CURLOPT_STREAM_DEPENDS:Int = CURLOPTTYPE_OBJECTPOINT + 240

Rem
bbdoc: Set E-xclusive stream dependency on another CURL handle
End Rem
Const CURLOPT_STREAM_DEPENDS_E:Int = CURLOPTTYPE_OBJECTPOINT + 241

Rem
bbdoc: Do not send any tftp option requests to the server
End Rem
Const CURLOPT_TFTP_NO_OPTIONS:Int = CURLOPTTYPE_LONG + 242

Rem
bbdoc: Linked-list of host:port:connect-to-host:connect-to-port, overrides the URL's host:port (only for the network layer)
End Rem
Const CURLOPT_CONNECT_TO:Int = CURLOPTTYPE_OBJECTPOINT + 243

Rem
bbdoc: Set TCP Fast Open
End Rem
Const CURLOPT_TCP_FASTOPEN:Int = CURLOPTTYPE_LONG + 244

Rem
bbdoc: Continue to send data if the server responds early with an HTTP status code >= 300
End Rem
Const CURLOPT_KEEP_SENDING_ON_ERROR:Int = CURLOPTTYPE_LONG + 245

Rem
bbdoc: The CApath or CAfile used to validate the proxy certificate this option is used only if PROXY_SSL_VERIFYPEER is true
End Rem
Const CURLOPT_PROXY_CAINFO:Int = CURLOPTTYPE_STRINGPOINT + 246

Rem
bbdoc: The CApath directory used to validate the proxy certificate this option is used only if PROXY_SSL_VERIFYPEER is true
End Rem
Const CURLOPT_PROXY_CAPATH:Int = CURLOPTTYPE_STRINGPOINT + 247

Rem
bbdoc: Set if we should verify the proxy in ssl handshake, set 1 to verify.
End Rem
Const CURLOPT_PROXY_SSL_VERIFYPEER:Int = CURLOPTTYPE_LONG + 248

Rem
bbdoc: Set if we should verify the Common name from the proxy certificate in ssl handshake, set 1 to check existence, 2 to ensure that it matches the provided hostname.
End Rem
Const CURLOPT_PROXY_SSL_VERIFYHOST:Int = CURLOPTTYPE_LONG + 249

Rem
bbdoc: What version to specifically try to use for proxy. See CURL_SSLVERSION defines below.
End Rem
Const CURLOPT_PROXY_SSLVERSION:Int = CURLOPTTYPE_LONG + 250

Rem
bbdoc: Set a username for authenticated TLS for proxy
End Rem
Const CURLOPT_PROXY_TLSAUTH_USERNAME:Int = CURLOPTTYPE_STRINGPOINT + 251

Rem
bbdoc: Set a password for authenticated TLS for proxy
End Rem
Const CURLOPT_PROXY_TLSAUTH_PASSWORD:Int = CURLOPTTYPE_STRINGPOINT + 252

Rem
bbdoc: Set authentication type for authenticated TLS for proxy
End Rem
Const CURLOPT_PROXY_TLSAUTH_TYPE:Int = CURLOPTTYPE_STRINGPOINT + 253

Rem
bbdoc: name of the file keeping your private SSL-certificate for proxy
End Rem
Const CURLOPT_PROXY_SSLCERT:Int = CURLOPTTYPE_STRINGPOINT + 254

Rem
bbdoc: type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") for proxy
End Rem
Const CURLOPT_PROXY_SSLCERTTYPE:Int = CURLOPTTYPE_STRINGPOINT + 255

Rem
bbdoc: name of the file keeping your private SSL-key for proxy
End Rem
Const CURLOPT_PROXY_SSLKEY:Int = CURLOPTTYPE_STRINGPOINT + 256

Rem
bbdoc: type of the file keeping your private SSL-key ("DER", "PEM", "ENG") for proxy
End Rem
Const CURLOPT_PROXY_SSLKEYTYPE:Int = CURLOPTTYPE_STRINGPOINT + 257

Rem
bbdoc: password for the SSL private key for proxy
End Rem
Const CURLOPT_PROXY_KEYPASSWD:Int = CURLOPTTYPE_STRINGPOINT + 258

Rem
bbdoc: Specify which SSL ciphers to use for proxy
End Rem
Const CURLOPT_PROXY_SSL_CIPHER_LIST:Int = CURLOPTTYPE_STRINGPOINT + 259

Rem
bbdoc: CRL file for proxy
End Rem
Const CURLOPT_PROXY_CRLFILE:Int = CURLOPTTYPE_STRINGPOINT + 260

Rem
bbdoc: Enable/disable specific SSL features with a bitmask for proxy, see CURLSSLOPT_*
End Rem
Const CURLOPT_PROXY_SSL_OPTIONS:Int = CURLOPTTYPE_LONG + 261

Rem
bbdoc: Name of pre proxy to use.
End Rem
Const CURLOPT_PRE_PROXY:Int = CURLOPTTYPE_STRINGPOINT + 262

Rem
bbdoc: The public key in DER form used to validate the proxy public key this option is used only if PROXY_SSL_VERIFYPEER is true
End Rem
Const CURLOPT_PROXY_PINNEDPUBLICKEY:Int = CURLOPTTYPE_STRINGPOINT + 263

Rem
bbdoc: Path to an abstract Unix domain socket
End Rem
Const CURLOPT_ABSTRACT_UNIX_SOCKET:Int = CURLOPTTYPE_STRINGPOINT + 264

Rem
bbdoc: Suppress proxy CONNECT response headers from user callbacks
End Rem
Const CURLOPT_SUPPRESS_CONNECT_HEADERS:Int = CURLOPTTYPE_LONG + 265

Rem
bbdoc: The request target, instead of extracted from the URL
End Rem
Const CURLOPT_REQUEST_TARGET:Int = CURLOPTTYPE_STRINGPOINT + 266

Rem
bbdoc: bitmask of allowed auth methods for connections to SOCKS5 proxies
End Rem
Const CURLOPT_SOCKS5_AUTH:Int = CURLOPTTYPE_LONG + 267

Rem
bbdoc: Enable/disable SSH compression
End Rem
Const CURLOPT_SSH_COMPRESSION:Int = CURLOPTTYPE_LONG + 268

Rem
bbdoc: Post MIME data.
End Rem
Const CURLOPT_MIMEPOST:Int = CURLOPTTYPE_OBJECTPOINT + 269

Rem
bbdoc:  Time to use with the CURLOPT_TIMECONDITION. Specified in number of seconds since 1 Jan 1970. 
End Rem
Const CURLOPT_TIMEVALUE_LARGE:Int = CURLOPTTYPE_OFF_T + 270

Rem
bbdoc:  Head start in milliseconds to give happy eyeballs. 
End Rem
Const CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS:Int = CURLOPTTYPE_LONG + 271

Rem
bbdoc:  Function that will be called before a resolver request is made 
End Rem
Const CURLOPT_RESOLVER_START_FUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 272

Rem
bbdoc:  User data to pass to the resolver start callback. 
End Rem
Const CURLOPT_RESOLVER_START_DATA:Int = CURLOPTTYPE_CBPOINT + 273

Rem
bbdoc:  send HAProxy PROXY protocol header? 
End Rem
Const CURLOPT_HAPROXYPROTOCOL:Int = CURLOPTTYPE_LONG + 274

Rem
bbdoc:  shuffle addresses before use when DNS returns multiple 
End Rem
Const CURLOPT_DNS_SHUFFLE_ADDRESSES:Int = CURLOPTTYPE_LONG + 275

Rem
bbdoc:  Specify which TLS 1.3 ciphers suites to use 
End Rem
Const CURLOPT_TLS13_CIPHERS:Int = CURLOPTTYPE_STRINGPOINT + 276
Const CURLOPT_PROXY_TLS13_CIPHERS:Int = CURLOPTTYPE_STRINGPOINT + 277

Rem
bbdoc:  Disallow specifying username/login in URL. 
End Rem
Const CURLOPT_DISALLOW_USERNAME_IN_URL:Int = CURLOPTTYPE_LONG + 278

Rem
bbdoc:  DNS-over-HTTPS URL 
End Rem
Const CURLOPT_DOH_URL:Int = CURLOPTTYPE_STRINGPOINT + 279

Rem
bbdoc:  Preferred buffer size to use for uploads 
End Rem
Const CURLOPT_UPLOAD_BUFFERSIZE:Int = CURLOPTTYPE_LONG + 280

Rem
bbdoc:  Time in ms between connection upkeep calls for long-lived connections. 
End Rem
Const CURLOPT_UPKEEP_INTERVAL_MS:Int = CURLOPTTYPE_LONG + 281

Rem
bbdoc:  Specify URL using CURL URL API. 
End Rem
Const CURLOPT_CURLU:Int = CURLOPTTYPE_OBJECTPOINT + 282

Rem
bbdoc:  add trailing data just after no more data is available 
End Rem
Const CURLOPT_TRAILERFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 283

Rem
bbdoc:  pointer to be passed to HTTP_TRAILER_FUNCTION 
End Rem
Const CURLOPT_TRAILERDATA:Int = CURLOPTTYPE_CBPOINT + 284

Rem
bbdoc:  set this to 1L to allow HTTP/0.9 responses or 0L to disallow 
End Rem
Const CURLOPT_HTTP09_ALLOWED:Int = CURLOPTTYPE_LONG + 285

Rem
bbdoc:  alt-svc control bitmask 
End Rem
Const CURLOPT_ALTSVC_CTRL:Int = CURLOPTTYPE_LONG + 286

Rem
bbdoc:  alt-svc cache file name to possibly read from/write to 
End Rem
Const CURLOPT_ALTSVC:Int = CURLOPTTYPE_STRINGPOINT + 287

Rem
bbdoc:  maximum age (idle time) of a connection to consider it for reuse (in seconds) 
End Rem
Const CURLOPT_MAXAGE_CONN:Int = CURLOPTTYPE_LONG + 288

Rem
bbdoc:  SASL authorisation identity 
End Rem
Const CURLOPT_SASL_AUTHZID:Int = CURLOPTTYPE_STRINGPOINT + 289

Rem
bbdoc:  allow RCPT TO command to fail for some recipients 
End Rem
Const CURLOPT_MAIL_RCPT_ALLLOWFAILS:Int = CURLOPTTYPE_LONG + 290

Rem
bbdoc:  the private SSL-certificate as a "blob" 
End Rem
Const CURLOPT_SSLCERT_BLOB:Int = CURLOPTTYPE_BLOB + 291
Const CURLOPT_SSLKEY_BLOB:Int = CURLOPTTYPE_BLOB + 292
Const CURLOPT_PROXY_SSLCERT_BLOB:Int = CURLOPTTYPE_BLOB + 293
Const CURLOPT_PROXY_SSLKEY_BLOB:Int = CURLOPTTYPE_BLOB + 294
Const CURLOPT_ISSUERCERT_BLOB:Int = CURLOPTTYPE_BLOB + 295

Rem
bbdoc:  Issuer certificate for proxy 
End Rem
Const CURLOPT_PROXY_ISSUERCERT:Int = CURLOPTTYPE_STRINGPOINT + 296
Const CURLOPT_PROXY_ISSUERCERT_BLOB:Int = CURLOPTTYPE_BLOB + 297

Rem
bbdoc: the EC curves requested by the TLS client (RFC 8422, 5.1);
about: OpenSSL support via 'set_groups'/'set_curves':
https://www.openssl.org/docs/manmaster/man3/SSL_CTX_set1_groups.html
End Rem
Const CURLOPT_SSL_EC_CURVES:Int = CURLOPTTYPE_STRINGPOINT + 298

Rem
bbdoc:  HSTS bitmask 
End Rem
Const CURLOPT_HSTS_CTRL:Int = CURLOPTTYPE_LONG + 299
Rem
bbdoc:  HSTS file name 
End Rem
Const CURLOPT_HSTS:Int = CURLOPTTYPE_STRINGPOINT + 300

Rem
bbdoc:  HSTS read callback 
End Rem
Const CURLOPT_HSTSREADFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 301
Const CURLOPT_HSTSREADDATA:Int = CURLOPTTYPE_CBPOINT + 302

Rem
bbdoc:  HSTS write callback 
End Rem
Const CURLOPT_HSTSWRITEFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 303
Const CURLOPT_HSTSWRITEDATA:Int = CURLOPTTYPE_CBPOINT + 304

Rem
bbdoc:  Parameters for V4 signature 
End Rem
Const CURLOPT_AWS_SIGV4:Int = CURLOPTTYPE_STRINGPOINT + 305

Rem
bbdoc:  Same as CURLOPT_SSL_VERIFYPEER but for DoH (DNS-over-HTTPS) servers. 
End Rem
Const CURLOPT_DOH_SSL_VERIFYPEER:Int = CURLOPTTYPE_LONG + 306

Rem
bbdoc:  Same as CURLOPT_SSL_VERIFYHOST but for DoH (DNS-over-HTTPS) servers. 
End Rem
Const CURLOPT_DOH_SSL_VERIFYHOST:Int = CURLOPTTYPE_LONG + 307

Rem
bbdoc:  Same as CURLOPT_SSL_VERIFYSTATUS but for DoH (DNS-over-HTTPS) servers. 
End Rem
Const CURLOPT_DOH_SSL_VERIFYSTATUS:Int = CURLOPTTYPE_LONG + 308

Rem
bbdoc:  The CA certificates as "blob" used to validate the peer certificate this option is used only if SSL_VERIFYPEER is true 
End Rem
Const CURLOPT_CAINFO_BLOB:Int = CURLOPTTYPE_BLOB + 309

Rem
bbdoc:  The CA certificates as "blob" used to validate the proxy certificate this option is used only if PROXY_SSL_VERIFYPEER is true 
End Rem
Const CURLOPT_PROXY_CAINFO_BLOB:Int = CURLOPTTYPE_BLOB + 310

Rem
bbdoc:  used by scp/sftp to verify the host's public key 
End Rem
Const CURLOPT_SSH_HOST_PUBLIC_KEY_SHA256:Int = CURLOPTTYPE_STRINGPOINT + 311

Rem
bbdoc:  Function that will be called immediately before the initial request is made on a connection (after any protocol negotiation step).  
End Rem
Const CURLOPT_PREREQFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 312

Rem
bbdoc:  Data passed to the CURLOPT_PREREQFUNCTION callback 
End Rem
Const CURLOPT_PREREQDATA:Int = CURLOPTTYPE_CBPOINT + 313

Rem
bbdoc:  maximum age (since creation) of a connection to consider it for reuse (in seconds) 
End Rem
Const CURLOPT_MAXLIFETIME_CONN:Int = CURLOPTTYPE_LONG + 314

Const CURLOPT_MIME_OPTIONS:Int = CURLOPTTYPE_LONG + 315
Const CURLOPT_SSH_HOSTKEYFUNCTION:Int = CURLOPTTYPE_FUNCTIONPOINT + 316
Const CURLOPT_SSH_HOSTKEYDATA:Int = CURLOPTTYPE_OBJECTPOINT + 317
Const CURLOPT_PROTOCOLS_STR:Int = CURLOPTTYPE_STRINGPOINT + 318
Const CURLOPT_REDIR_PROTOCOLS_STR:Int = CURLOPTTYPE_STRINGPOINT + 319
Const CURLOPT_WS_OPTIONS:Int = CURLOPTTYPE_LONG + 320
Const CURLOPT_CA_CACHE_TIMEOUT:Int = CURLOPTTYPE_LONG + 321
Const CURLOPT_QUICK_EXIT:Int = CURLOPTTYPE_LONG + 322
Const CURLOPT_HAPROXY_CLIENT_IP:Int = CURLOPTTYPE_STRINGPOINT + 323
Const CURLOPT_SERVER_RESPONSE_TIMEOUT_MS:Int = CURLOPTTYPE_LONG + 324
Const CURLOPT_ECH:Int = CURLOPTTYPE_LONG + 325
Const CURLOPT_TCP_KEEPCNT:Int = CURLOPTTYPE_LONG + 326
Const CURLOPT_UPLOAD_FLAGS:Int = CURLOPTTYPE_LONG + 327
Const CURLOPT_SSL_SIGNATURE_ALGORITHMS:Int = CURLOPTTYPE_STRINGPOINT + 328

Rem
bbdoc: No authentication
End Rem
Const CURLAUTH_NONE:Int = 0

Rem
bbdoc: HTTP Basic authentication.
about: This is the default choice, and the only method that is in wide-spread use and supported virtually everywhere.
This is sending the user name and password over the network in plain text, easily captured by others.
End Rem
Const CURLAUTH_BASIC:Int = 1 Shl 0

Rem
bbdoc: HTTP Digest authentication.
about: Digest authentication is defined in RFC2617 and is a more secure way to do authentication over public
networks than the regular old-fashioned Basic method.
End Rem
Const CURLAUTH_DIGEST:Int = 1 Shl 1

Rem
bbdoc: HTTP Negotiate (SPNEGO) authentication.
End Rem
Const CURLAUTH_NEGOTIATE:Int = 1 Shl 2

Rem
bbdoc: HTTP NTLM authentication.
about: A proprietary protocol invented and used by Microsoft. It uses a challenge-response and hash concept
similar to Digest, to prevent the password from being eavesdropped.
<p>
You need to use libcurlssl for this option to work, or use libcurl on Windows. 
</p>
End Rem
Const CURLAUTH_NTLM:Int = 1 Shl 3

Const CURLAUTH_DIGEST_IE:Int = 1 Shl 4

Rem
bbdoc: HTTP Bearer token authentication
End Rem
Const CURLAUTH_BEARER:Int = 1 Shl 6
Const CURLAUTH_AWS_SIGV4:Int = 1 Shl 7

Rem
bbdoc: Use together with a single other type to force no authentication or just that single type
End Rem
Const CURLAUTH_ONLY:Int = 1 Shl 31

Rem
bbdoc: This is a convenience setting that sets all bits and thus makes libcurl pick any it finds suitable.
about: libcurl will automatically select the one it finds most secure.
End Rem
Const CURLAUTH_ANY:Int = ~CURLAUTH_DIGEST_IE

Rem
bbdoc: This is a convenience setting that sets all bits except Basic and thus makes libcurl pick any it finds suitable.
about: libcurl will automatically select the one it finds most secure.
End Rem
Const CURLAUTH_ANYSAFE:Int = ~(CURLAUTH_BASIC|CURLAUTH_DIGEST_IE)


Rem
bbdoc: all types supported by the server
End Rem
Const CURLSSH_AUTH_ANY:Int = ~0

Rem
bbdoc: none allowed, silly but complete
End Rem
Const CURLSSH_AUTH_NONE:Int = 0

Rem
bbdoc: public/private key files
End Rem
Const CURLSSH_AUTH_PUBLICKEY:Int = 1 Shl 0

Rem
bbdoc: password
End Rem
Const CURLSSH_AUTH_PASSWORD:Int = 1 Shl 1

Rem
bbdoc: host key files
End Rem
Const CURLSSH_AUTH_HOST:Int = 1 Shl 2

Rem
bbdoc: keyboard interactive
End Rem
Const CURLSSH_AUTH_KEYBOARD:Int = 1 Shl 3

Rem
bbdoc: agent (ssh-agent, pageant...)
End Rem
Const CURLSSH_AUTH_AGENT:Int = 1 Shl 4

Rem
bbdoc: 
End Rem
Const CURLSSH_AUTH_DEFAULT:Int = CURLSSH_AUTH_ANY


Rem
bbdoc: Debug Info - The data is informational text.
End Rem
Const CURLINFO_TEXT:Int = 0
Rem
bbdoc: Debug Info - The data is header (or header-like) data received from the peer.
End Rem
Const CURLINFO_HEADER_IN:Int = 1
Rem
bbdoc: Debug Info - The data is header (or header-like) data sent to the peer.
End Rem
Const CURLINFO_HEADER_OUT:Int = 2
Rem
bbdoc: Debug Info - The data is protocol data received from the peer.
End Rem
Const CURLINFO_DATA_IN:Int = 3
Rem
bbdoc: Debug Info - The data is protocol data sent to the peer.
End Rem
Const CURLINFO_DATA_OUT:Int = 4
Rem
bbdoc: Debug Info - 
End Rem
Const CURLINFO_SSL_DATA_IN:Int = 5
Rem
bbdoc: Debug Info - 
End Rem
Const CURLINFO_SSL_DATA_OUT:Int = 6


' ERROR CODES .....

Rem
bbdoc: Error code - Success
End Rem
Const CURLE_OK:Int = 0
Rem
bbdoc: Error code - The URL you passed to libcurl used a protocol that this libcurl does not support.
about: The support might be a compile-time option that you didn't use, it can be a misspelled protocol string
or just a protocol libcurl has no code for.
End Rem
Const CURLE_UNSUPPORTED_PROTOCOL:Int = 1
Rem
bbdoc: Error code - Very early initialization code failed.
about: This is likely to be an internal error or problem.
End Rem
Const CURLE_FAILED_INIT:Int = 2
Rem
bbdoc: Error code - The URL was not properly formatted.
End Rem
Const CURLE_URL_MALFORMAT:Int = 3
Rem
bbdoc: 
End Rem
Const CURLE_NOT_BUILT_IN:Int = 4
Rem
bbdoc: Error code - Couldn't resolve proxy.
about: The given proxy host could not be resolved.
End Rem
Const CURLE_COULDNT_RESOLVE_PROXY:Int = 5
Rem
bbdoc: Error code - Couldn't resolve host.
about: The given remote host was not resolved.
End Rem
Const CURLE_COULDNT_RESOLVE_HOST:Int = 6
Rem
bbdoc: Error code - Failed to connect() to host or proxy.
End Rem
Const CURLE_COULDNT_CONNECT:Int = 7
Rem
bbdoc: Error code - After connecting to an FTP server, libcurl expects to get a certain reply back.
about: This error code implies that it got a strange or bad reply. The given remote server is probably not an
OK FTP server.
End Rem
Const CURLE_FTP_WEIRD_SERVER_REPLY:Int = 8
Rem
bbdoc: Error code - We were denied access when trying to login to an FTP server or when trying to change
working directory to the one given in the URL.
End Rem
Const CURLE_FTP_ACCESS_DENIED:Int = 9
Rem
bbdoc: 
End Rem
Const CURLE_FTP_ACCEPT_FAILED:Int = 10
Rem
bbdoc: Error code - After having sent the FTP password to the server, libcurl expects a proper reply.
about: This error code indicates that an unexpected code was returned.
End Rem
Const CURLE_FTP_WEIRD_PASS_REPLY:Int = 11
Rem
bbdoc: 
End Rem
Const CURLE_FTP_ACCEPT_TIMEOUT:Int = 12
Rem
bbdoc: Error code - libcurl failed to get a sensible result back from the server as a response to either a PASV or a EPSV command.
about: The server is flawed.
End Rem
Const CURLE_FTP_WEIRD_PASV_REPLY:Int = 13
Rem
bbdoc: Error code - FTP servers return a 227-line as a response to a PASV command.
about: If libcurl fails to parse that line, this return code is passed back.
End Rem
Const CURLE_FTP_WEIRD_227_FORMAT:Int = 14
Rem
bbdoc: Error code - An internal failure to lookup the host used for the new connection.
End Rem
Const CURLE_FTP_CANT_GET_HOST:Int = 15
Rem
bbdoc: 
End Rem
Const CURLE_HTTP2:Int = 16
Rem
bbdoc: Error code - Received an error when trying to set the transfer mode to binary.
End Rem
Const CURLE_FTP_COULDNT_SET_BINARY:Int = 17
Rem
bbdoc: Error code - A file transfer was shorter or larger than expected.
about: This happens when the server first reports an expected transfer size, and then delivers data that doesn't match the previously given size.
End Rem
Const CURLE_PARTIAL_FILE:Int = 18
Rem
bbdoc: Error code - This was either a weird reply to a 'RETR' command or a zero byte transfer complete.
End Rem
Const CURLE_FTP_COULDNT_RETR_FILE:Int = 19
Rem
bbdoc: Error code - When sending custom "QUOTE" commands to the remote server, one of the commands returned an error code that was 400 or higher.
End Rem
Const CURLE_FTP_QUOTE_ERROR:Int = 21
Rem
bbdoc: Error code - This is returned if #CURLOPT_FAILONERROR is set True and the HTTP server returns an error code that is >= 400.
End Rem
Const CURLE_HTTP_RETURNED_ERROR:Int = 22
Rem
bbdoc: Error code - An error occurred when writing received data to a local file, or an error was returned to libcurl from a write callback.
End Rem
Const CURLE_WRITE_ERROR:Int = 23
Rem
bbdoc: Error code - Failed starting the upload.
about: For FTP, the server typcially denied the STOR command. The error buffer usually contains the
server's explanation to this.
End Rem
Const CURLE_UPLOAD_FAILED:Int = 25
Rem
bbdoc: Error code - There was a problem reading a local file or an error returned by the read callback.
End Rem
Const CURLE_READ_ERROR:Int = 26
Rem
bbdoc: Error code - Out of memory.
about: A memory allocation request failed. This is serious badness and things are severely screwed
up if this ever occur.
End Rem
Const CURLE_OUT_OF_MEMORY:Int = 27

Rem
bbdoc: Error code - Operation timeout.
about: The specified time-out period was reached according to the conditions.
End Rem
Const CURLE_OPERATION_TIMEOUTED:Int = 28
Rem
bbdoc: Error code - The FTP PORT command returned error.
about: This mostly happen when you haven't specified a good enough address for libcurl to use.
See #CURLOPT_FTPPORT.
End Rem
Const CURLE_FTP_PORT_FAILED:Int = 30
Rem
bbdoc: Error code - The FTP REST command returned error.
about: This should never happen if the server is sane.
End Rem
Const CURLE_FTP_COULDNT_USE_REST:Int = 31
Rem
bbdoc: Error code - The HTTP server does not support or accept range requests.
End Rem
Const CURLE_HTTP_RANGE_ERROR:Int = 33
Rem
bbdoc: Error code - This is an odd error that mainly occurs due to internal confusion.
End Rem
Const CURLE_HTTP_POST_ERROR:Int = 34
Rem
bbdoc: Error code - A problem occurred somewhere in the SSL/TLS handshake.
about: You really want the error buffer and read the message there as it pinpoints the problem
slightly more. Could be certificates (file formats, paths, permissions), passwords, and others.
End Rem
Const CURLE_SSL_CONNECT_ERROR:Int = 35
Rem
bbdoc: Error code - Attempting FTP resume beyond file size.
End Rem
Const CURLE_BAD_DOWNLOAD_RESUME:Int = 36
Rem
bbdoc: Error code - A file given with FILE:// couldn't be opened.
about: Most likely because the file path doesn't identify an existing file. Did you check file permissions?
End Rem
Const CURLE_FILE_COULDNT_READ_FILE:Int = 37
Rem
bbdoc: Error code - LDAP cannot bind.
about: LDAP bind operation failed.
End Rem
Const CURLE_LDAP_CANNOT_BIND:Int = 38
Rem
bbdoc: Error code - LDAP search failed.
End Rem
Const CURLE_LDAP_SEARCH_FAILED:Int = 39
Rem
bbdoc: Error code - Function not found.
about: A required LDAP function was not found.
End Rem
Const CURLE_FUNCTION_NOT_FOUND:Int = 41
Rem
bbdoc: Error code - Aborted by callback.
about: A callback returned "abort" to libcurl.
End Rem
Const CURLE_ABORTED_BY_CALLBACK:Int = 42
Rem
bbdoc: Error code - Internal error.
about: A function was called with a bad parameter.
End Rem
Const CURLE_BAD_FUNCTION_ARGUMENT:Int = 43

Rem
bbdoc: Error code - Interface error.
about: A specified outgoing interface could not be used. Set which interface to use for
outgoing connections' source IP address with #CURLOPT_INTERFACE.
End Rem
Const CURLE_INTERFACE_FAILED:Int = 45
Rem
bbdoc: Error code - Too many redirects.
about: When following redirects, libcurl hit the maximum amount. Set your limit with #CURLOPT_MAXREDIRS.
End Rem
Const CURLE_TOO_MANY_REDIRECTS :Int = 47
Rem
bbdoc: Error code - An option set with #CURLOPT_TELNETOPTIONS was not recognized/known.
about: Refer to the appropriate documentation.
End Rem
Const CURLE_UNKNOWN_TELNET_OPTION:Int = 48
Rem
bbdoc: Error code - A telnet option string was Illegally formatted.
End Rem
Const CURLE_TELNET_OPTION_SYNTAX :Int = 49
Rem
bbdoc: Error code - The remote server's SSL certificate was deemed not OK.
End Rem
Const CURLE_SSL_PEER_CERTIFICATE:Int = 51
Rem
bbdoc: Error code - Nothing was returned from the server, and under the circumstances, getting nothing is considered an error.
End Rem
Const CURLE_GOT_NOTHING:Int = 52
Rem
bbdoc: Error code - The specified crypto engine wasn't found.
End Rem
Const CURLE_SSL_ENGINE_NOTFOUND:Int = 53
Rem
bbdoc: Error code - Failed setting the selected SSL crypto engine as default!
End Rem
Const CURLE_SSL_ENGINE_SETFAILED:Int = 54
Rem
bbdoc: Error code - Failed sending network data.
End Rem
Const CURLE_SEND_ERROR:Int = 55
Rem
bbdoc: Error code - Failure with receiving network data.
End Rem
Const CURLE_RECV_ERROR:Int = 56
Rem
bbdoc: Error code - Problem with the local client certificate
End Rem
Const CURLE_SSL_CERTPROBLEM:Int = 58
Rem
bbdoc: Error code - Couldn't use specified cipher.
End Rem
Const CURLE_SSL_CIPHER:Int = 59
Rem
bbdoc: Error code - Peer certificate cannot be authenticated with known CA certificates.
End Rem
Const CURLE_SSL_CACERT:Int = 60
Rem
bbdoc: Error code - Unrecognized transfer encoding.
End Rem
Const CURLE_BAD_CONTENT_ENCODING:Int = 61
Rem
bbdoc: Error code - Invalid LDAP URL.
End Rem
Const CURLE_LDAP_INVALID_URL:Int = 62
Rem
bbdoc: Error code - Maximum file size exceeded
End Rem
Const CURLE_FILESIZE_EXCEEDED:Int = 63
Rem
bbdoc: Error code - Requested FTP SSL level failed
End Rem
Const CURLE_FTP_SSL_FAILED:Int = 64
Rem
bbdoc: Error code - When doing a send operation curl had to rewind the data to retransmit, but the rewinding operation failed.
End Rem
Const CURLE_SEND_FAIL_REWIND:Int = 65
Rem
bbdoc: Error code - Initiating the SSL Engine failed.
End Rem
Const CURLE_SSL_ENGINE_INITFAILED:Int = 66
Rem
bbdoc: Error code - The remote server denied curl to login.
End Rem
Const CURLE_LOGIN_DENIED:Int = 67
Rem
bbdoc: Error code - File not found on TFTP server
End Rem
Const CURLE_TFTP_NOTFOUND:Int = 68
Rem
bbdoc: Error code - Permission problem on TFTP server
End Rem
Const CURLE_TFTP_PERM:Int = 69
Rem
bbdoc: Error code - Out of disk space on TFTP server
End Rem
Const CURLE_TFTP_DISKFULL:Int = 70
Rem
bbdoc: Error code - Illegal TFTP operation
End Rem
Const CURLE_TFTP_ILLEGAL:Int = 71
Rem
bbdoc: Error code - Unknown TFTP transfer ID
End Rem
Const CURLE_TFTP_UNKNOWNID:Int = 72
Rem
bbdoc: Error code - TFTP File already exists
End Rem
Const CURLE_TFTP_EXISTS:Int = 73
Rem
bbdoc: Error code - No such TFTP user
End Rem
Const CURLE_TFTP_NOSUCHUSER:Int = 74
Rem
bbdoc: Error code - Character conversion failed
End Rem
Const CURLE_CONV_FAILED:Int = 75
Rem
bbdoc: Error code - Caller must register conversion callbacks using setopt options #CURLOPT_CONV_FROM_NETWORK_FUNCTION, #CURLOPT_CONV_TO_NETWORK_FUNCTION, and #CURLOPT_CONV_FROM_UTF8_FUNCTION
End Rem
Const CURLE_CONV_REQD:Int = 76
Rem
bbdoc: Error code - Problem with reading the SSL CA cert (path? access rights?)
End Rem
Const CURLE_SSL_CACERT_BADFILE:Int = 77
Rem
bbdoc: Error code - Remote file not found.
End Rem
Const CURLE_REMOTE_FILE_NOT_FOUND:Int = 78
Rem
bbdoc: Error code - Error from the SSH layer
about: Somewhat generic so the error message will be of interest when this has happened.
End Rem
Const CURLE_SSH:Int = 79
Rem
bbdoc: Error code - Failed to shut down the SSL connection.
End Rem
Const CURLE_SSL_SHUTDOWN_FAILED:Int = 80
Rem
bbdoc: Error code - Socket is not ready for send/recv, wait till it's ready and try again.
End Rem
Const CURLE_AGAIN:Int = 81
Rem
bbdoc: Error code - Could not load CRL file, missing or wrong format.
End Rem
Const CURLE_SSL_CRL_BADFILE:Int = 82
Rem
bbdoc: Error code - Issuer check failed.
End Rem
Const CURLE_SSL_ISSUER_ERROR:Int = 83
Rem
bbdoc: Error code - A PRET command failed.
End Rem
Const CURLE_FTP_PRET_FAILED:Int = 84
Rem
bbdoc: Error code - Mismatch of RTSP CSeq numbers.
End Rem
Const CURLE_RTSP_CSEQ_ERROR:Int = 85
Rem
bbdoc: Error code - Mismatch of RTSP Session Ids.
End Rem
Const CURLE_RTSP_SESSION_ERROR:Int = 86
Rem
bbdoc: Error code - Unable to parse FTP file list.
End Rem
Const CURLE_FTP_BAD_FILE_LIST:Int = 87
Rem
bbdoc: Error code - Chunk callback reported error.
End Rem
Const CURLE_CHUNK_FAILED:Int = 88
Rem
bbdoc: Error code - No connection available, the session will be queued.
End Rem
Const CURLE_NO_CONNECTION_AVAILABLE:Int = 89
Rem
bbdoc: Error code - Specified pinned public key did not match.
End Rem
Const CURLE_SSL_PINNEDPUBKEYNOTMATCH:Int = 90
Rem
bbdoc: Error code - Invalid certificate status.
End Rem
Const CURLE_SSL_INVALIDCERTSTATUS:Int = 91
Rem
bbdoc: Error code - Stream error in HTTP/2 framing layer.
End Rem
Const CURLE_HTTP2_STREAM:Int = 92

Rem
bbdoc: The library will ignore the file and use only the information in the URL.
about: This is the default. 
End Rem
Const CURL_NETRC_IGNORED:Int = 0

Rem
bbdoc: The use of your ~/.netrc file is optional, and information in the URL is to be preferred.
about: The file will be scanned with the host and user name (to find the password only) or with the
host only, to find the first user name and password after that machine, which ever information is
not specified in the URL.
<p>
Undefined values of the option will have this effect.
</p>
End Rem
Const CURL_NETRC_OPTIONAL:Int = 1

Rem
bbdoc: This value tells the library that use of the file is required, to ignore the information in the URL, and to search the file with the host only.
about: Only machine name, user name and password are taken into account (init macros and similar things
aren't supported).
<p>
libcurl does not verify that the file has the correct properties set (as the standard Unix ftp client
does). It should only be readable by user.
</p>
End Rem
Const CURL_NETRC_REQUIRED:Int = 2


Const CURLFORM_COPYNAME:Int = 1
Const CURLFORM_PTRNAME:Int = 2
Const CURLFORM_NAMELENGTH:Int = 3
Const CURLFORM_COPYCONTENTS:Int = 4
Const CURLFORM_PTRCONTENTS:Int = 5
Const CURLFORM_CONTENTSLENGTH:Int = 6
Const CURLFORM_FILECONTENT:Int = 7
Const CURLFORM_ARRAY:Int = 8
Const CURLFORM_FILE:Int = 10
Const CURLFORM_BUFFER:Int = 11
Const CURLFORM_BUFFERPTR:Int = 12
Const CURLFORM_BUFFERLENGTH:Int = 13
Const CURLFORM_CONTENTTYPE:Int = 14
Const CURLFORM_CONTENTHEADER:Int = 15
Const CURLFORM_FILENAME:Int = 16
Const CURLFORM_END:Int = 17
'Const CURLFORM_OBSOLETE2:Int = 18
Const CURLFORM_STREAM:Int = 19
Const CURLFORM_CONTENTLEN:Int = 20


Const CURLINFO_STRING:Int = $100000
Const CURLINFO_LONG:Int = $200000
Const CURLINFO_DOUBLE:Int = $300000
Const CURLINFO_SLIST:Int = $400000
Const CURLINFO_PTR:Int = $400000 ' same as SLIST
Const CURLINFO_SOCKET:Int = $500000
Const CURLINFO_OFF_T:Int = $600000
Const CURLINFO_MASK:Int = $0fffff
Const CURLINFO_TYPEMASK:Int = $f00000

Const CURLINFO_NONE:Int = 0 ' First, never use this
Const CURLINFO_EFFECTIVE_URL:Int = CURLINFO_STRING + 1
Const CURLINFO_RESPONSE_CODE:Int = CURLINFO_LONG   + 2
Const CURLINFO_TOTAL_TIME:Int = CURLINFO_DOUBLE + 3
Const CURLINFO_NAMELOOKUP_TIME:Int = CURLINFO_DOUBLE + 4
Const CURLINFO_CONNECT_TIME:Int = CURLINFO_DOUBLE + 5
Const CURLINFO_PRETRANSFER_TIME:Int = CURLINFO_DOUBLE + 6
Const CURLINFO_SIZE_UPLOAD:Int = CURLINFO_DOUBLE + 7
Const CURLINFO_SIZE_UPLOAD_T:Int = CURLINFO_OFF_T + 7
Const CURLINFO_SIZE_DOWNLOAD:Int = CURLINFO_DOUBLE + 8
Const CURLINFO_SIZE_DOWNLOAD_T:Int = CURLINFO_OFF_T + 8
Const CURLINFO_SPEED_DOWNLOAD:Int = CURLINFO_DOUBLE + 9
Const CURLINFO_SPEED_DOWNLOAD_T:Int = CURLINFO_OFF_T + 9
Const CURLINFO_SPEED_UPLOAD:Int = CURLINFO_DOUBLE + 10
Const CURLINFO_SPEED_UPLOAD_T:Int = CURLINFO_OFF_T + 10
Const CURLINFO_HEADER_SIZE:Int = CURLINFO_LONG + 11
Const CURLINFO_REQUEST_SIZE:Int = CURLINFO_LONG + 12
Const CURLINFO_SSL_VERIFYRESULT:Int = CURLINFO_LONG + 13
Const CURLINFO_FILETIME:Int = CURLINFO_LONG + 14
Const CURLINFO_CONTENT_LENGTH_DOWNLOAD:Int = CURLINFO_DOUBLE + 15
Const CURLINFO_CONTENT_LENGTH_DOWNLOAD_T:Int = CURLINFO_OFF_T + 15
Const CURLINFO_CONTENT_LENGTH_UPLOAD:Int = CURLINFO_DOUBLE + 16
Const CURLINFO_CONTENT_LENGTH_UPLOAD_T:Int = CURLINFO_OFF_T + 16
Const CURLINFO_STARTTRANSFER_TIME:Int = CURLINFO_DOUBLE + 17
Const CURLINFO_CONTENT_TYPE:Int = CURLINFO_STRING + 18
Const CURLINFO_REDIRECT_TIME:Int = CURLINFO_DOUBLE + 19
Const CURLINFO_REDIRECT_COUNT:Int = CURLINFO_LONG + 20
Const CURLINFO_PRIVATE:Int = CURLINFO_STRING + 21
Const CURLINFO_HTTP_CONNECTCODE:Int = CURLINFO_LONG + 22
Const CURLINFO_HTTPAUTH_AVAIL:Int = CURLINFO_LONG + 23
Const CURLINFO_PROXYAUTH_AVAIL:Int = CURLINFO_LONG + 24
Const CURLINFO_OS_ERRNO:Int = CURLINFO_LONG + 25
Const CURLINFO_NUM_CONNECTS:Int = CURLINFO_LONG + 26
Const CURLINFO_SSL_ENGINES:Int = CURLINFO_SLIST + 27
Const CURLINFO_COOKIELIST:Int = CURLINFO_SLIST + 28
Const CURLINFO_LASTSOCKET:Int = CURLINFO_LONG + 29
Const CURLINFO_FTP_ENTRY_PATH:Int = CURLINFO_STRING + 30
Const CURLINFO_REDIRECT_URL:Int = CURLINFO_STRING + 31
Const CURLINFO_PRIMARY_IP:Int = CURLINFO_STRING + 32
Const CURLINFO_APPCONNECT_TIME:Int = CURLINFO_DOUBLE + 33
Const CURLINFO_CERTINFO:Int = CURLINFO_SLIST + 34
Const CURLINFO_CONDITION_UNMET:Int = CURLINFO_LONG + 35
Const CURLINFO_RTSP_SESSION_ID:Int = CURLINFO_STRING + 36
Const CURLINFO_RTSP_CLIENT_CSEQ:Int = CURLINFO_LONG + 37
Const CURLINFO_RTSP_SERVER_CSEQ:Int = CURLINFO_LONG + 38
Const CURLINFO_RTSP_CSEQ_RECV:Int = CURLINFO_LONG + 39
Const CURLINFO_PRIMARY_PORT:Int = CURLINFO_LONG + 40
Const CURLINFO_LOCAL_IP:Int = CURLINFO_STRING + 41
Const CURLINFO_LOCAL_PORT:Int = CURLINFO_LONG + 42
Const CURLINFO_TLS_SESSION:Int = CURLINFO_SLIST + 43
Const CURLINFO_ACTIVESOCKET:Int = CURLINFO_SOCKET + 44
Const CURLINFO_TLS_SSL_PTR:Int = CURLINFO_SLIST + 45
Const CURLINFO_HTTP_VERSION:Int = CURLINFO_LONG + 46
Const CURLINFO_PROXY_SSL_VERIFYRESULT:Int = CURLINFO_LONG + 47
Const CURLINFO_PROTOCOL:Int = CURLINFO_LONG + 48
Const CURLINFO_SCHEME:Int = CURLINFO_STRING + 49
Const CURLINFO_TOTAL_TIME_T:Int = CURLINFO_OFF_T + 50
Const CURLINFO_NAMELOOKUP_TIME_T:Int = CURLINFO_OFF_T + 51
Const CURLINFO_CONNECT_TIME_T:Int = CURLINFO_OFF_T + 52
Const CURLINFO_PRETRANSFER_TIME_T:Int = CURLINFO_OFF_T + 53
Const CURLINFO_STARTTRANSFER_TIME_T:Int = CURLINFO_OFF_T + 54
Const CURLINFO_REDIRECT_TIME_T:Int = CURLINFO_OFF_T + 55
Const CURLINFO_APPCONNECT_TIME_T:Int = CURLINFO_OFF_T + 56
Const CURLINFO_RETRY_AFTER:Int = CURLINFO_OFF_T + 57
Const CURLINFO_EFFECTIVE_METHOD:Int = CURLINFO_STRING + 58
Const CURLINFO_PROXY_ERROR:Int = CURLINFO_LONG + 59
Const CURLINFO_REFERER:Int = CURLINFO_STRING + 60

Const CURLCLOSEPOLICY_NONE:Int = 0 ' first, never use this
Const CURLCLOSEPOLICY_OLDEST:Int = 1
Const CURLCLOSEPOLICY_LEAST_RECENTLY_USED:Int = 2
Const CURLCLOSEPOLICY_LEAST_TRAFFIC:Int = 3
Const CURLCLOSEPOLICY_SLOWEST:Int = 4
Const CURLCLOSEPOLICY_CALLBACK:Int = 5

Rem
bbdoc: #CURLOPT_FTP_SSL_CCC option - Do not send CCC.
End Rem
Const CURLFTPSSL_CCC_NONE:Int = 0
Rem
bbdoc: #CURLOPT_FTP_SSL_CCC option - Let the server initiate the shutdown.
End Rem
Const CURLFTPSSL_CCC_PASSIVE:Int = 1
Rem
bbdoc: #CURLOPT_FTP_SSL_CCC option - Initiate the shutdown.
End Rem
Const CURLFTPSSL_CCC_ACTIVE:Int = 2

Rem
bbdoc: CURLOPT_FTPSSLAUTH option - Let libcurl decide.
End Rem
Const CURLFTPAUTH_DEFAULT:Int = 0
Rem
bbdoc: CURLOPT_FTPSSLAUTH option - Use "AUTH SSL".
End Rem
Const CURLFTPAUTH_SSL:Int = 1
Rem
bbdoc: CURLOPT_FTPSSLAUTH option - Use "AUTH TLS".
End Rem
Const CURLFTPAUTH_TLS:Int = 2

Rem
bbdoc:do NOT create missing dirs!
End Rem
Const CURLFTP_CREATE_DIR_NONE:Int = 0
Rem
bbdoc:(FTP/SFTP) if CWD fails, try MKD and then CWD again if MKD succeeded, for SFTP this does similar magic
End Rem
Const CURLFTP_CREATE_DIR:Int = 1
Rem
bbdoc:(FTP only) if CWD fails, try MKD and then CWD again even if MKD failed!
End Rem
Const CURLFTP_CREATE_DIR_RETRY:Int = 2

Rem
bbdoc: CURLOPT_FTP_FILEMETHOD option - let libcurl pick.
End Rem
Const CURLFTPMETHOD_DEFAULT:Int = 0
Rem
bbdoc: CURLOPT_FTP_FILEMETHOD option - single CWD operation for each path part.
End Rem
Const CURLFTPMETHOD_MULTICWD:Int = 1
Rem
bbdoc: CURLOPT_FTP_FILEMETHOD option - no CWD at all.
End Rem
Const CURLFTPMETHOD_NOCWD:Int = 2
Rem
bbdoc: CURLOPT_FTP_FILEMETHOD option - one CWD to full dir, then work on file.
End Rem
Const CURLFTPMETHOD_SINGLECWD:Int = 3

Rem
bbdoc: CURLOPT_IPRESOLVE option - default, resolves addresses to all IP versions that your system allows.
End Rem
Const CURL_IPRESOLVE_WHATEVER:Int = 0
Rem
bbdoc: CURLOPT_IPRESOLVE option - resolve to IPv4 addresses.
End Rem
Const CURL_IPRESOLVE_V4:Int = 1
Rem
bbdoc: CURLOPT_IPRESOLVE option - resolve to IPv6 addresses.
End Rem
Const CURL_IPRESOLVE_V6:Int = 2

Rem
bbdoc: CURLOPT_HTTP_VERSION option - setting this means we don't care, and that we'd like the library to choose the best possible for us.
End Rem
Const CURL_HTTP_VERSION_NONE:Int = 0
Rem
bbdoc: CURLOPT_HTTP_VERSION option - please use HTTP 1.0 in the request.
End Rem
Const CURL_HTTP_VERSION_1_0:Int = 1
Rem
bbdoc: CURLOPT_HTTP_VERSION option - please use HTTP 1.1 in the request.
End Rem
Const CURL_HTTP_VERSION_1_1:Int = 2
Rem
bbdoc: CURLOPT_HTTP_VERSION option - please use HTTP 2 in the request.
End Rem
Const CURL_HTTP_VERSION_2_0:Int = 3
Rem
bbdoc: CURLOPT_HTTP_VERSION option - please use HTTP 2 in the request.
about: Same as #CURL_HTTP_VERSION_2_0.
End Rem
Const CURL_HTTP_VERSION_2:Int = CURL_HTTP_VERSION_2_0
Rem
bbdoc: CURLOPT_HTTP_VERSION option - use version 2 for HTTPS, version 1.1 for HTTP.
End Rem
Const CURL_HTTP_VERSION_2TLS:Int = 4
Rem
bbdoc: CURLOPT_HTTP_VERSION option - please use HTTP 2 without HTTP/1.1  Upgrade.
End Rem
Const CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE:Int = 5

Rem
bbdoc:  This easy handle has completed.
about: 'result' contains the CURLcode of the transfer.
End Rem
Const CURLMSG_DONE:Int = 1

Rem
bbdoc: please call #multiPerform soon
End Rem
Const CURLM_CALL_MULTI_PERFORM:Int = -1
Rem
bbdoc: 
End Rem
Const CURLM_OK:Int = 0
Rem
bbdoc: the handle is Not a valid CURLM handle
End Rem
Const CURLM_BAD_HANDLE:Int = 1
Rem
bbdoc: an easy handle was Not good/valid
End Rem
Const CURLM_BAD_EASY_HANDLE:Int = 2
Rem
bbdoc: If you ever get this, you're in deep sh*t
End Rem
Const CURLM_OUT_OF_MEMORY:Int = 3
Rem
bbdoc: this is a libcurl bug
End Rem
Const CURLM_INTERNAL_ERROR:Int = 4
Rem
bbdoc: the passed in socket argument did not match
End Rem
Const CURLM_BAD_SOCKET:Int = 5
Rem
bbdoc: curl_multi_setopt() with unsupported option
End Rem
Const CURLM_UNKNOWN_OPTION:Int = 6
Rem
bbdoc: an easy handle already added to a multi handle was attempted to get added - again
End Rem
Const CURLM_ADDED_ALREADY:Int = 7

Rem
bbdoc: just to make code nicer when using curl_multi_socket() you can now check for CURLM_CALL_MULTI_SOCKET too in the same style it works for curl_multi_perform() and CURLM_CALL_MULTI_PERFORM
End Rem
Const CURLM_CALL_MULTI_SOCKET:Int = CURLM_CALL_MULTI_PERFORM

Const CURL_SSLVERSION_DEFAULT:Int = 0
Const CURL_SSLVERSION_TLSv1:Int = 1 ' TLS 1.x
Const CURL_SSLVERSION_SSLv2:Int = 2
Const CURL_SSLVERSION_SSLv3:Int = 3
Const CURL_SSLVERSION_TLSv1_0:Int = 4
Const CURL_SSLVERSION_TLSv1_1:Int = 5
Const CURL_SSLVERSION_TLSv1_2:Int = 6
Const CURL_SSLVERSION_TLSv1_3:Int = 7

Const CURL_SSLVERSION_MAX_NONE:Int = 0
Const CURL_SSLVERSION_MAX_DEFAULT:Int = CURL_SSLVERSION_TLSv1   Shl 16
Const CURL_SSLVERSION_MAX_TLSv1_0:Int = CURL_SSLVERSION_TLSv1_0 Shl 16
Const CURL_SSLVERSION_MAX_TLSv1_1:Int = CURL_SSLVERSION_TLSv1_1 Shl 16
Const CURL_SSLVERSION_MAX_TLSv1_2:Int = CURL_SSLVERSION_TLSv1_2 Shl 16
Const CURL_SSLVERSION_MAX_TLSv1_3:Int = CURL_SSLVERSION_TLSv1_3 Shl 16

Const CURL_TLSAUTH_NONE:Int = 0
Const CURL_TLSAUTH_SRP:Int = 1

Const CURL_TIMECOND_NONE:Int = 0
Const CURL_TIMECOND_IFMODSINCE:Int = 1
Const CURL_TIMECOND_IFUNMODSINCE:Int = 2
Const CURL_TIMECOND_LASTMOD:Int = 3

Rem
bbdoc: Set to 1 to enable or 0 to disable.
about: Enabling pipelining on a multi handle will make it attempt to perform HTTP Pipelining as far as
possible for transfers using this handle. This means that if you add a second request that can use an
already existing connection, the second request will be "piped" on the same connection rather than being
executed in parallell.
End Rem
Const CURLMOPT_PIPELINING:Int = 3

Rem
bbdoc: The set number will be used as the maximum amount of simultaneously open connections that libcurl may cache.
about: Default is 10, and libcurl will enlarge the size for each added easy handle to make it fit 4
times the number of added easy handles.
<p>
By setting this option, you can prevent the cache size to grow beyond the limit set by you.
</p>
<p>
When the cache is full, curl closes the oldest one in the cache to prevent the number of open connections
to increase.
</p>
<p>
This option is for the multi handle's use only, when using the easy interface you should instead use the
#CURLOPT_MAXCONNECTS option. 
</p>
End Rem
Const CURLMOPT_MAXCONNECTS:Int = 6

Rem
bbdoc: do not attempt to use SSL
End Rem
Const CURLUSESSL_NONE:Int = 0
Rem
bbdoc: try using SSL, proceed anyway otherwise
End Rem
Const CURLUSESSL_TRY:Int = 1
Rem
bbdoc: SSL for the control connection or fail
End Rem
Const CURLUSESSL_CONTROL:Int = 2
Rem
bbdoc: SSL for all communication or fail
End Rem
Const CURLUSESSL_ALL:Int = 3
