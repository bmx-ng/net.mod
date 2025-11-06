SuperStrict

Framework Brl.Standardio
Import Net.http

Local retryPolicy:TRetryPolicy = New TRetryPolicy
retryPolicy.maxAttempts = 5

Local client:THttpClient = THttpClient.Create()
client.SetRetryPolicy(retryPolicy)
client.Start()

'
Local resp:THttpResponse = client.Get("https://httpcan.org/status/429?body=").Send()
Print resp.status + " : " + resp.AsString()


client.Shutdown()
