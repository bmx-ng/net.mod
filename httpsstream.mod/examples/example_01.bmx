SuperStrict

Framework net.httpsstream
Import BRL.Standardio

Local stream:TStream = ReadStream("https::www.google.com")

While not stream.EOF()
	Local s:String = stream.ReadLine()
	Print s
Wend
