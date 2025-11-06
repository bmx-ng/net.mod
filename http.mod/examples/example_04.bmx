SuperStrict

Framework Brl.Standardio
Import Net.http

Local client:THttpClient = THttpClient.Create()
client.Start()

' UTF-8 ENCODING
Local resp:THttpResponse = client.Get("https://httpcan.org/encoding/utf8").Send()
Print resp.status + " : " + resp.AsString()

' GZIP ENCODING
resp = client.Get("https://httpcan.org/gzip").Send()
Print resp.status + " : " + resp.AsString()

' BROTLI ENCODING
resp = client.Get("https://httpcan.org/brotli").Send()
Print resp.status + " : " + resp.AsString()

client.Shutdown()
