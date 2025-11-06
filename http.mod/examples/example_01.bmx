SuperStrict

Framework Brl.Standardio
Import Net.http

Local client:THttpClient = THttpClient.Create()
client.Start()

' Async GET to memory
client.Get("https://httpcan.org/get").SendAsync(New PrintListener)

' Sync POST with string content to memory
Local resp:THttpResponse = client.Post("https://httpcan.org/post").Body("name=Ada&role=admin", "application/x-www-form-urlencoded").Send()
Print "SYNC POST status=" + resp.status
Print resp.AsString()

Delay 5000
client.Shutdown()


Type PrintListener Implements ICompleteListener
    Method OnComplete(result:THttpResult)
        Print "ASYNC: " + result.request._method + " " + result.request.GetUrl().ToString() + " -> status=" + result.response.status + ", bytes=" + result.response.bytesReceived
		Print result.response.AsString()
    End Method
End Type
