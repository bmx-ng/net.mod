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

Type TSetCookieParserTest Extends TTest

    ' --- Basic name/value ---

    Method testSimpleNameValue() { test }
        Local c:THttpCookie = TSetCookieParser.Parse("id=abc123")
        AssertNotNull(c, "Should parse a simple name=value cookie")
        AssertEquals("id", c.GetName(), "Name mismatch")
        AssertEquals("abc123", c.GetValue(), "Value mismatch")
    End Method

    Method testEmptyValue() { test }
        Local c:THttpCookie = TSetCookieParser.Parse("empty=")
        AssertNotNull(c, "Empty value is allowed")
        AssertEquals("empty", c.GetName())
        AssertEquals("", c.GetValue())
    End Method

    Method testQuotedValue() { test }
        Local c:THttpCookie = TSetCookieParser.Parse("q=~qhello world~q; Path=/")
        AssertNotNull(c)
        AssertEquals("q", c.GetName())
        AssertEquals("hello world", c.GetValue(), "Quoted value should be unquoted")
        AssertEquals("/", c.GetPath())
    End Method

    ' --- Attributes & flags ---

    Method testCommonAttributes() { test }
        Local sc:String = "session=xyz; Path=/app; Domain=example.com; Max-Age=3600; Secure; HttpOnly; SameSite=Strict"
        Local c:THttpCookie = TSetCookieParser.Parse(sc)
        AssertNotNull(c)
        AssertEquals("session", c.GetName())
        AssertEquals("xyz", c.GetValue())
        AssertEquals("/app", c.GetPath())
        AssertEquals("example.com", c.GetDomain())
        AssertEquals(Long(3600), c.GetMaxAge(), "Max-Age numeric parse")
        AssertTrue(c.IsSecure(), "Secure flag should be set")
        AssertTrue(c.IsHttpOnly(), "HttpOnly flag should be set")
        AssertEquals("Strict", c.GetSameSite(), "SameSite=Strict")
    End Method

    Method testAttributeCaseInsensitivity() { test }
        Local sc:String = "N=v; pAtH=/x; DoMaIn=EXAMPLE.COM; sEcUrE; hTtPoNlY; SaMeSiTe=lAx"
        Local c:THttpCookie = TSetCookieParser.Parse(sc)
        AssertNotNull(c)
        AssertEquals("/x", c.GetPath())
        AssertEquals("EXAMPLE.COM", c.GetDomain())
        AssertTrue(c.IsSecure())
        AssertTrue(c.IsHttpOnly())
        AssertEquals("Lax", c.GetSameSite(), "Parser canonicalizes SameSite to 'Lax'")
    End Method

    Method testPartitionedFlag() { test }
        Local c1:THttpCookie = TSetCookieParser.Parse("k=v; Partitioned")
        AssertNotNull(c1)
        AssertTrue(c1.IsPartitioned(), "Partitioned flag should be true when present")

        Local c2:THttpCookie = TSetCookieParser.Parse("k=v; Partitioned=true")
        AssertNotNull(c2)
        AssertTrue(c2.IsPartitioned(), "Partitioned=true should be true")

        Local c3:THttpCookie = TSetCookieParser.Parse("k=v; Partitioned=false")
        AssertNotNull(c3)
        AssertFalse(c3.IsPartitioned(), "Partitioned=false should be false")
    End Method

    ' --- Expires parsing ---

    Method testExpiresValidFuture() { test }
        ' Far-future RFC1123 date; should parse to > 0 and be considered not expired
        Local sc:String = "k=v; Expires=Wed, 31 Dec 2036 23:59:59 GMT"
        Local c:THttpCookie = TSetCookieParser.Parse(sc)
        AssertNotNull(c)
        Local ts:Long = c.GetExpires()
        AssertTrue(ts > 0, "Valid Expires should return epoch seconds > 0")
        AssertFalse(c.IsExpired(), "Future Expires should not be expired (given current time)")
    End Method

    Method testExpiresInvalid() { test }
        Local sc:String = "k=v; Expires=not a date"
        Local c:THttpCookie = TSetCookieParser.Parse(sc)
        AssertNotNull(c)
        AssertEquals(Long(0), c.GetExpires(), "Invalid Expires → 0")
        ' Given implementation, Max-Age defaults to 0 and Expires=0 → IsExpired() returns true
        AssertTrue(c.IsExpired(), "Invalid Expires should result in expired=true by current implementation")
    End Method

    ' ' --- Max-Age semantics ---

    ' Method testMaxAgeZeroMeansExpired() { test }
    '     Local sc:String = "k=v; Max-Age=0"
    '     Local c:THttpCookie = TSetCookieParser.Parse(sc)
    '     AssertNotNull(c)
    '     AssertEquals(Long(0), c.GetMaxAge())
    '     AssertTrue(c.IsExpired(), "Max-Age=0 should be treated as expired")
    ' End Method

    ' Method testMaxAgePositiveNotExpired() { test }
    '     Local sc:String = "k=v; Max-Age=120"
    '     Local c:THttpCookie = TSetCookieParser.Parse(sc)
    '     AssertNotNull(c)
    '     AssertEquals(Long(120), c.GetMaxAge())
    '     ' Implementation returns not expired only if Max-Age > 0 (or Expires future)
    '     AssertFalse(c.IsExpired(), "Positive Max-Age should not be expired at parse time")
    ' End Method

    ' Method testMaxAgeInvalidNumeric() { test }
    '     Local sc:String = "k=v; Max-Age=abc"
    '     Local c:THttpCookie = TSetCookieParser.Parse(sc)
    '     AssertNotNull(c)
    '     AssertEquals(Long(0), c.GetMaxAge(), "Invalid Max-Age parsed as 0")
    '     AssertTrue(c.IsExpired(), "Invalid Max-Age -> expired by current implementation")
    ' End Method

    ' --- SameSite variants ---

    Method testSameSiteVariants() { test }
        Local c1:THttpCookie = TSetCookieParser.Parse("a=b; SameSite=None; Secure")
        AssertNotNull(c1)
        AssertEquals("None", c1.GetSameSite())

        Local c2:THttpCookie = TSetCookieParser.Parse("a=b; SameSite=Lax")
        AssertNotNull(c2)
        AssertEquals("Lax", c2.GetSameSite())

        Local c3:THttpCookie = TSetCookieParser.Parse("a=b; SameSite=Strict")
        AssertNotNull(c3)
        AssertEquals("Strict", c3.GetSameSite())
    End Method

    ' --- Invalid/malformed inputs ---

    Method testInvalidNoName() { test }
        AssertNull(TSetCookieParser.Parse("=value"), "Missing name should be invalid → Null")
    End Method

    Method testInvalidEmptyString() { test }
        AssertNull(TSetCookieParser.Parse(""), "Empty string should be invalid → Null")
    End Method

    Method testInvalidJustAttributesNoPair() { test }
        AssertNull(TSetCookieParser.Parse("Secure; HttpOnly"), "No name=value pair → Null")
    End Method

    ' --- Whitespace robustness ---

    Method testWhitespaceRobustness() { test }
        Local c:THttpCookie = TSetCookieParser.Parse("  token   =   val  ;   Path =  /p ;  Domain = example.com  ;  HttpOnly  ")
        AssertNotNull(c)
        AssertEquals("token", c.GetName())
        AssertEquals("val", c.GetValue())
        AssertEquals("/p", c.GetPath())
        AssertEquals("example.com", c.GetDomain())
        AssertTrue(c.IsHttpOnly())
    End Method

    ' --- Unknown/custom attributes preserved ---

    Method testUnknownAttributesPreserved() { test }
        Local c:THttpCookie = TSetCookieParser.Parse("k=v; Priority=High; Foo=Bar")
        AssertNotNull(c)
        AssertEquals("High", c.GetAttribute("Priority"), "Unknown attr 'Priority' should be preserved")
        AssertEquals("Bar", c.GetAttribute("Foo"), "Arbitrary attr 'Foo' should be preserved")
    End Method

End Type
