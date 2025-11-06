SuperStrict

Framework Brl.Standardio
Import Net.http

Local client:THttpClient = THttpClient.Create()
client.Start()

Local user:String = "gary"
Local password:String = "secret"

' BASIC AUTHENTICATION
' user with no auth
Local resp:THttpResponse = client.Get("https://httpcan.org/basic-auth/" + user).Send()
Print resp.status + " : " + resp.AsString()

' user with blank password
resp = client.Get("https://httpcan.org/basic-auth/" + user).AuthMethod(EHttpAuthMethod.Any).User(user).Send()
Print resp.status + " : " + resp.AsString()

' user with correct password
resp = client.Get("https://httpcan.org/basic-auth/" + user + "/" + password).AuthMethod(EHttpAuthMethod.Any).User(user).Password(password).Send()
Print resp.status + " : " + resp.AsString()

' user with wrong password
resp = client.Get("https://httpcan.org/basic-auth/" + user + "/" + password).AuthMethod(EHttpAuthMethod.Any).User(user).Password("wrongpassword").Send()
Print resp.status + " : " + resp.AsString()

' BEARER AUTHENTICATION
Print "************************"

' no token
resp = client.Get("https://httpcan.org/bearer").AuthMethod(EHttpAuthMethod.Bearer).Send()
Print resp.status + " : " + resp.AsString()

' with token
resp = client.Get("https://httpcan.org/bearer").AuthMethod(EHttpAuthMethod.Bearer).BearerToken("acb123").Send()
Print resp.status + " : " + resp.AsString()

' DIGEST AUTHENTICATION
Print "************************"

' user with no auth
resp = client.Get("https://httpcan.org/digest-auth/auth/" + user + "/" + password).Send()
Print resp.status + " : " + resp.AsString()

' user with correct password
resp = client.Get("https://httpcan.org/digest-auth/auth/" + user + "/" + password).AuthMethod(EHttpAuthMethod.Any).User(user).Password(password).Send()
Print resp.status + " : " + resp.AsString()

' user with wrong password
resp = client.Get("https://httpcan.org/digest-auth/auth/" + user + "/" + password).AuthMethod(EHttpAuthMethod.Any).User(user).Password("wrongpassword").Send()
Print resp.status + " : " + resp.AsString()

' with SHA-256
resp = client.Get("https://httpcan.org/digest-auth/auth/" + user + "/" + password + "/SHA-256/never").AuthMethod(EHttpAuthMethod.Any).User(user).Password(password).Send()
Print resp.status + " : " + resp.AsString()

client.Shutdown()
