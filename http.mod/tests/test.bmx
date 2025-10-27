SuperStrict

Framework brl.standardio
Import BRL.MaxUnit
Import Net.Http

New TTestSuite.run()

Type TUrlTest Extends TTest

    Method Test_ParseAndParts() { test }
        Local input:String = "https://user:pa%20ss@example.com:8443/a%20b/c?x=1%202&y=%2Fz#frag%201"
        Local u:TUrl = New TUrl(input)

        ' Basic sanity and parse success
        AssertTrue( u <> Null, "url is not null" )
        AssertTrue( u.ParseUrl(input), "url parsed" ) ' should succeed (idempotent re-parse)

        ' Scheme / authority
        AssertEquals( "https", u.GetScheme() )
        AssertEquals( "user", u.GetUser() )
        AssertEquals( "pa ss", u.GetPassword() )
        AssertEquals( "example.com", u.GetHost() )
        AssertEquals( "8443", u.GetPort() )
        AssertEquals( 8443, u.GetPortAsInt() )

        ' Path (decoded vs raw)
        AssertEquals( "/a b/c", u.GetPath() )
        AssertEquals( "/a%20b/c", u.GetRawPath() )

        ' Query (decoded vs raw)
        AssertEquals( "x=1 2&y=/z", u.GetQuery() )
        AssertEquals( "x=1%202&y=%2Fz", u.GetRawQuery() )

        ' Fragment (decoded vs raw)
        AssertEquals( "frag 1", u.GetFragment() )
        AssertEquals( "frag%201", u.GetRawFragment() )

        ' Round-trip
        AssertEquals( input, u.ToString(), "matches" )
    End Method


    ' Build a URL via TUrlBuilder (string + int overloads) and validate encoding and round-trip
    Method Test_Builder_ComposeAndRoundTrip() { test }
        Local u:TUrl = TUrl.Builder() ..
            .Scheme("https") ..
            .User("user") ..
            .Password("pa ss") ..               ' will be percent-encoded
            .Host("Example.COM") ..              ' host should normalize to lowercase in URL form
            .Port(8443) ..                       ' your Port:Int overload
            .Path("/a b/c") ..                   ' will be encoded in ToString
            .Query("x=1 2&y=/z") ..              ' spaces and slash in value will be encoded
            .Fragment("frag 1") ..               ' will be encoded
            .Build()

        ' Parts (decoded accessors)
        AssertEquals( "https", u.GetScheme(), "scheme is https" )
        AssertEquals( "user", u.GetUser() )
        AssertEquals( "pa ss", u.GetPassword() )
        AssertEquals( "example.com", u.GetHost().ToLower() )
        AssertEquals( "8443", u.GetPort() )
        AssertEquals( 8443, u.GetPortAsInt() )

        AssertEquals( "/a b/c", u.GetPath() )
        AssertEquals( "x=1 2&y=/z", u.GetQuery() )
        AssertEquals( "frag 1", u.GetFragment() )

        ' Raw (encoded) accessors
        AssertEquals( "/a%20b/c", u.GetRawPath() )
        AssertEquals( "x=1%202&y=%2fz", u.GetRawQuery() )
        AssertEquals( "frag%201", u.GetRawFragment() )

        ' ToString should be a fully encoded, normalized URL
        Local s:String = u.ToString()
        AssertTrue( s.StartsWith("https://"), "url starts with https://" )
        AssertTrue( s.Contains("@"), "url contains @" )                       ' userinfo present
        AssertTrue( s.Contains(":8443"), "port is 8443" )
        AssertTrue( s.Contains("/a%20b/c") )
        AssertTrue( s.Contains("x=1%202&y=%2fz") )
        AssertTrue( s.EndsWith("#frag%201") )
    End Method

    ' Default port behavior (no explicit port) — GetPort/GetPortAsInt should return default,
    '    but the URL string typically omits it.
    Method Test_DefaultPort_Inferred_NotRendered() { test }
        Local u:TUrl = New TUrl("https://example.com/path")
        AssertEquals( "https", u.GetScheme() )

        ' Because your GetPort() uses CURLU_DEFAULT_PORT, it should return the scheme default.
        AssertEquals( "443", u.GetPort() )
        AssertEquals( 443, u.GetPortAsInt() )

        ' Usually libcurl omits the default port in the formatted URL.
        ' Don’t assert exact string; just ensure no ":443" is rendered.
        Local s:String = u.ToString()
        AssertTrue( Not s.Contains(":443") )
        AssertTrue( s.Contains("https://example.com") )
    End Method


    ' IMAP/SMTP/POP3-specific options in userinfo (e.g., ;AUTH=...)
    '    The URL API allows getting/setting this field; IMAP is a good example.
    Method Test_IMAP_UserinfoOptions() { test }
        ' Build: imap://user;AUTH=NTLM:pass@host/
        Local u:TUrl = TUrl.Builder() ..
            .Scheme("imap") ..
            .User("user") ..
            .Options("AUTH=NTLM") ..              ' special userinfo options
            .Password("pass") ..
            .Host("mail.example.com") ..
            .Path("/") ..
            .Build()

        ' Accessors
        AssertEquals( "imap", u.GetScheme(), "scheme is imap" )
        AssertEquals( "user", u.GetUser(), "user is user" )
        AssertEquals( "AUTH=NTLM", u.GetOptions(), "options is AUTH=NTLM" )
        AssertEquals( "pass", u.GetPassword(), "password is pass" )
        AssertEquals( "mail.example.com", u.GetHost(), "host is mail.example.com" )

        ' Full URL should include the ;OPTIONS in userinfo
        Local s:String = u.ToString()
        AssertTrue( s.StartsWith("imap://"), "url starts with imap://" )
        AssertTrue( s.Contains("user:pass;AUTH=NTLM@"), "userinfo contains options" )
    End Method


    ' 4) Negative parse case: invalid IPv6 literal should fail ParseUrl (and not crash)
    Method Test_Parse_InvalidUrl_Fails() { test }
        Local u:TUrl = New TUrl()
        AssertTrue( Not u.ParseUrl("http://[::1") )   ' missing closing bracket
        ' After failure, some implementations keep prior state. We only assert failure here.
    End Method
End Type

Type TUrlQueryEncodeTest Extends TTest

	Method Test_Query_BasicSpacesAndSlash() { test }
		Local input:String = "x=1 2&y=/z"
		Local out:String = TUrlBuilder.EncodeQueryPreservingSeparators(input)
		AssertEquals( "x=1%202&y=%2Fz", out )

		' Integration with builder: the final ToString should contain encoded params,
		' but separators must remain intact as separate parameters.
		Local u:TUrl = TUrl.Builder() ..
			.Scheme("https") ..
			.Host("example.com") ..
			.Query(input) ..
			.Build()
		Local s:String = u.ToString()
		AssertTrue( s.Contains("?x=1%202&y=%2fz") )
	End Method

	Method Test_Query_RepeatedKeys_And_Empty() { test }
		Local input:String = "a=1&a=2&b=&c"
		Local out:String = TUrlBuilder.EncodeQueryPreservingSeparators(input)
		AssertEquals( "a=1&a=2&b=&c", out ) ' nothing to encode, but structure preserved
	End Method

	Method Test_Query_LiteralPlus_And_EqualInValue() { test }
		Local input:String = "note=2+2=4"
		Local out:String = TUrlBuilder.EncodeQueryPreservingSeparators(input)
		' plus is data => %2B ; the '=' after the first is data => %3D
		AssertEquals( "note=2%2B2%3D4", out )
	End Method

	Method Test_Query_NonAscii_UTF8() { test }
		Local input:String = "t=café&snow=☃"
		Local out:String = TUrlBuilder.EncodeQueryPreservingSeparators(input)
		' With curl_easy_escape, UTF-8 bytes are percent-encoded:
		' café -> caf%C3%A9 ; snowman -> %E2%98%83
		AssertTrue( out.Contains("t=caf%C3%A9") )
		AssertTrue( out.Contains("snow=%E2%98%83") )
	End Method

End Type
