SuperStrict

Framework Brl.Standardio
Import Net.http

Local client:THttpClient = THttpClient.Create()
client.Start()

' server will return with a Set-Cookie header
Local resp:THttpResponse = client.Get("https://httpcan.org/cookies/set/cookie-1/abcdefg").Send()
Print resp.AsString()

print "************************"

' now the cookie should be stored in the client cookie store, and sent with this request
resp = client.Get("https://httpcan.org/cookies").Send()
Print resp.AsString()

client.Shutdown()

