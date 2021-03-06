SuperStrict

' Connect to a website via HTTPS, using a certificate bundle.
'
'

Framework Net.libcurl
Import BRL.StandardIO
Import BRL.FileSystem

Local curl:TCurlEasy = TCurlEasy.Create()

curl.setWriteString()
curl.setOptInt(CURLOPT_VERBOSE, 1)
curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1)

Print "Loading certs"
curl.setOptString(CURLOPT_CAINFO, "../certificates/cacert.pem") ' the cert bundle

curl.setOptString(CURLOPT_URL, "https://www.google.co.uk")

Local res:Int = curl.perform()

If res Then
	Print CurlError(res)
	End
End If

curl.cleanup()

Print curl.toString()



