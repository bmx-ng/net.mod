SuperStrict

Framework brl.standardio
Import net.libcurl
Import BRL.MaxUnit

New TTestSuite.run()

Type TSListTest Extends TTest

	Method Test() { test }
		Local curl:TCurlEasy = TCurlEasy.Create()

		Local arr:String[] = ["one", "two", "three"]

		curl.processArray(CURLOPT_HTTPHEADER, arr)

		Local res:String[] = curlProcessSlist(curl.slists[0])

		AssertEquals(arr.Length, res.Length)

		For Local i:Int = 0 Until arr.Length
			AssertEquals(arr[i], res[i])
		Next
	End Method

End Type
