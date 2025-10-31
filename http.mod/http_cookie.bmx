'
' Copyright (c) 2025 Bruce A Henderson
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgement in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Import BRL.Collections
Import "http_url.bmx"

Interface ICookie
	Method GetName:String()
	Method GetValue:String()
	Method GetVersion:Int()
	Method GetComment:String()
	Method GetDomain:String()
	Method GetPath:String()
	Method GetMaxAge:Long()
	Method GetSameSite:String()
	Method GetExpires:Long()
	Method IsPartitioned:Int()
	Method IsHttpOnly:Int()
	Method IsSecure:Int()
	Method isExpired:Int()
End Interface

Rem
bbdco: HTTP Cookie representation
End Rem
Type THttpCookie Implements ICookie

	Field _name:String
	Field _value:String
	Field _version:Int

	Field _attributes:TTreeMap<String, String> = New TTreeMap<String, String>(New TCaseInsensitiveStringComparator)

	Function Build:THttpCookieBuilder(name:String, value:String, version:Int = 0)
		Return New THttpCookieBuilder(name, value, version)
	End Function

	Function From:THttpCookie(name:String)
		Local cookie:THttpCookie = New THttpCookie
		cookie._name = name
		Return cookie
	End Function

	Function From:THttpCookie(name:String, value:String, version:Int = 0)
		Local cookie:THttpCookie = New THttpCookie
		cookie._name = name
		cookie._value = value
		cookie._version = version
		Return cookie
	End Function

	Rem
	bbdoc: Gets the cookie name.
	End Rem
	Method GetName:String() Override
		Return _name
	End Method

	Rem
	bbdoc: Gets the cookie value.
	End Rem
	Method GetValue:String() Override
		Return _value
	End Method

	Rem
	bbdoc: Gets the cookie version.
	End Rem
	Method GetVersion:Int() Override
		Return _version
	End Method

	Rem
	bbdoc: Gets the 'Comment' attribute value.
	End Rem
	Method GetComment:String() Override
		Return GetAttribute(ECookieAttribute.Comment)
	End Method

	Rem
	bbdoc: Gets the 'Domain' attribute value.
	End Rem
	Method GetDomain:String() Override
		Return GetAttribute(ECookieAttribute.Domain)
	End Method

	Rem
	bbdoc: Gets the 'Path' attribute value.
	End Rem
	Method GetPath:String() Override
		Return GetAttribute(ECookieAttribute.Path)
	End Method

	Rem
	bbdoc: Gets the 'Max-Age' attribute value.
	End Rem
	Method GetMaxAge:Long() Override
		Local val:String = GetAttribute(ECookieAttribute.MaxAge)
		If val Then
			Return val.ToLong() ' returns zero if invalid
		End If

		Return -1 ' not set
	End Method

	Rem
	bbdoc: Gets the 'SameSite' attribute value.
	End Rem
	Method GetSameSite:String() Override
		Return GetAttribute(ECookieAttribute.SameSite)
	End Method

	Rem
	bbdoc: Gets the 'Expires' attribute value.
	about: Returns the expiration date of the cookie as a Unix timestamp, or zero if not set or invalid.
	End Rem
	Method GetExpires:Long() Override
		Local expires:String = GetAttribute(ECookieAttribute.Expires)
		If Not expires Then
			Return 0
		End If
		Return ParseExpires(expires)
	End Method

	Rem
	bbdoc: Returns whether the 'Partitioned' attribute is set.
	End Rem
	Method IsPartitioned:Int() Override
		Return IsAttributeSetToNotFalse(ECookieAttribute.Partitioned)
	End Method

	Rem
	bbdoc: Returns whether the 'HttpOnly' attribute is set.
	End Rem
	Method IsHttpOnly:Int() Override
		Return IsAttributeSetToNotFalse(ECookieAttribute.HttpOnly)
	End Method

	Rem
	bbdoc: Returns whether the 'Secure' attribute is set.
	End Rem
	Method IsSecure:Int() Override
		Return IsAttributeSetToNotFalse(ECookieAttribute.Secure)
	End Method

	Rem
	bbdoc: Returns whether the cookie is expired.
	End Rem
	Method IsExpired:Int() Override

		If GetMaxAge() = 0 Then
			Return True
		End If

		Local expires:Long = GetExpires()
		If Not expires Then
			Return True
		End If

		Local nowSecs:ULong = CurrentUnixTime() / 1000 ' from millis		
		Return nowSecs > ULong(expires)
	End Method

	Method GetAttribute:String(attr:ECookieAttribute)
		Local found:String
		Local res:Int = _attributes.TryGetValue(attr.ToString(), found)
		If res Then
			Return found
		End If
	End Method

	Method GetAttribute:String(attr:String)
		Local found:String
		Local res:Int = _attributes.TryGetValue(attr, found)
		If res Then
			Return found
		End If
	End Method

	Method IsAttributeSetToNotFalse:Int(attr:ECookieAttribute)
		Local val:String = GetAttribute(attr)
		If val Then
			Return val.ToLower() <> "false"
		End If
		Return False
	End Method
	
	' parses date string in Expires attribute to epoch time
	Function ParseExpires:Long(expires:String)
		Local time:Long = bmx_curl_getdate(expires)
		If time = -1 Then
			Return 0
		End If
		Return time
	End Function

End Type

Type TCachedCookie Implements ICookie

	Field _cookie:THttpCookie
	Field _creationTime:ULong = CurrentUnixTime() / 1000 ' seconds
	Field _url:TUrl
	Field _domain:String
	Field _path:String

	Method New(cookie:THttpCookie, url:TUrl, domain:String, path:String)
		Self._cookie = cookie
		Self._url = url
		Self._domain = domain
		Self._path = path
	End Method

	Method GetName:String() Override
		Return _cookie.GetName()
	End Method

	Method GetValue:String() Override
		Return _cookie.GetValue()
	End Method

	Method GetVersion:Int() Override
		Return _cookie.GetVersion()
	End Method

	Method GetComment:String() Override
		Return _cookie.GetComment()
	End Method

	Method GetDomain:String() Override
		Return _cookie.GetDomain()
	End Method

	Method GetPath:String() Override
		Return _cookie.GetPath()
	End Method

	Method GetMaxAge:Long() Override
		Return _cookie.GetMaxAge()
	End Method

	Method GetSameSite:String() Override
		Return _cookie.GetSameSite()
	End Method

	Method GetExpires:Long() Override
		Return _cookie.GetExpires()
	End Method

	Method IsPartitioned:Int() Override
		Return _cookie.IsPartitioned()
	End Method

	Method IsHttpOnly:Int() Override
		Return _cookie.IsHttpOnly()
	End Method

	Method IsSecure:Int() Override
		Return _cookie.IsSecure()
	End Method

	Method IsExpired:Int() Override
		Local maxAge:Long = GetMaxAge()
		
		Local now:ULong = CurrentUnixTime() / 1000 ' seconds
		If maxAge >= 0 And now >= (_creationTime + ULong(maxAge)) Then
			Return True
		End If

		Local expires:Long = GetExpires()
		If expires > 0 And now >= ULong(expires) Then
			Return True
		End If
	End Method

	Method HashCode:UInt()
		Return _cookie.GetName().HashCode() ~ _domain.ToLower().HashCode() ~ _path.HashCode()
	End Method

	Method Compare:Int(other:Object)
		Local c:TCachedCookie = TCachedCookie(other)

		If Not c Then
			Return 1
		End If

		Local hc:UInt = HashCode()
		Local ohc:UInt = c.HashCode()

		If hc < ohc Then
			Return -1
		ElseIf hc > ohc Then
			Return 1
		End If

		Local res:Int = GetName().Compare( c.GetName() )
		If res <> 0 Then
			Return res
		End If

		res = _domain.ToLower().Compare( c._domain.ToLower() )
		If res <> 0 Then
			Return res
		End If

		Return _path.Compare( c._path )
	End Method

End Type

Type THttpCookieBuilder
	Field _name:String
	Field _value:String
	Field _version:Int
	Field _attributes:TTreeMap<String, String> = New TTreeMap<String, String>

	Method New(name:String, value:String, version:Int)
		Self._name = name
		Self._value = value
		Self._version = version
	End Method

	Method Build:THttpCookie()
		Local cookie:THttpCookie = New THttpCookie
		cookie._name = _name
		cookie._value = _value
		cookie._version = _version
		For local node:TMapNode<String,String> = Eachin _attributes
			cookie._attributes.Put( node.key, node.value )
		Next
		Return cookie
	End Method

	Method Attribute:THttpCookieBuilder(name:String, value:String)
		If Not name Then
			Return Self
		End If

		Local lower:String = name.ToLower()

		Select lower
			Case "expires"
				If value Then
					Expires(THttpCookie.ParseExpires(value))
				Else
					Expires(0)
				End If

			Case "httponly"
				HttpOnly(AsBoolean("httponly", value))

			Case "max-age"
				If value Then
					MaxAge(value.ToLong())
				Else
					MaxAge(-1)
				End If

			Case "samesite"
				SameSite(TCookieHelper.ValidateSameSite(value))

			Case "secure"
				Secure(AsBoolean("secure", value))

			Case "partitioned"
				Partitioned(AsBoolean("partitioned", value))

			Default
				If Not value Then
					_attributes.Remove(name)
				Else
					_attributes.Put(name, value)
				End If
		End Select

		Return Self
	End Method

	Method Expires:THttpCookieBuilder(expires:Long)
		If expires > 0 Then
			Local expiresStr:String = TCookieHelper.FormatExpires(expires)
			_attributes.Put( ECookieAttribute.Expires.ToString(), expiresStr )
		Else
			_attributes.Remove( ECookieAttribute.Expires.ToString() )
		End If
		Return Self
	End Method

	Method AsBoolean:Int(name:String, value:String)
		Local lower:String = value.ToLower()
		If lower = "" Or lower = "true" Then
			Return True
		End IF

		If lower = "false" Then
			Return False
		End If

		IllegalArgumentError("Invalid value for " + name)
	End Method

	Method HttpOnly:THttpCookieBuilder(httpOnly:Int)
		If httpOnly Then
			_attributes.Put( ECookieAttribute.HttpOnly.ToString(), "true" )
		Else
			_attributes.Remove( ECookieAttribute.HttpOnly.ToString() )
		End If
		Return Self
	End Method

	Method MaxAge:THttpCookieBuilder(maxAge:Long)
		If maxAge >= 0 Then
			_attributes.Put( ECookieAttribute.MaxAge.ToString(), String(maxAge) )
		Else
			_attributes.Remove( ECookieAttribute.MaxAge.ToString() )
		End If
		Return Self
	End Method

	Method Partitioned:THttpCookieBuilder(partitioned:Int)
		If partitioned Then
			_attributes.Put( ECookieAttribute.Partitioned.ToString(), "true" )
		Else
			_attributes.Remove( ECookieAttribute.Partitioned.ToString() )
		End If
		Return Self
	End Method

	Method Secure:THttpCookieBuilder(secure:Int)
		If secure Then
			_attributes.Put( ECookieAttribute.Secure.ToString(), "true" )
		Else
			_attributes.Remove( ECookieAttribute.Secure.ToString() )
		End If
		Return Self
	End Method

	Method SameSite:THttpCookieBuilder(sameSite:String)
		If sameSite Then
			_attributes.Put( ECookieAttribute.SameSite.ToString(), sameSite )
		Else
			_attributes.Remove( ECookieAttribute.SameSite.ToString() )
		End If
		Return Self
	End Method
End Type

Type THttpCookieStore

	Field cookies:TTreeMap<String, TArrayList<TCachedCookie>> = New TTreeMap<String, TArrayList<TCachedCookie>>

	Method Add:Int(url:TUrl, cookie:THttpCookie)

		Local domain:String = ResolveCookieDomain(url, cookie)
		If Not domain Then
			Return False
		End If

		Local path:String = ResolveCookiePath(url, cookie)

		Local cookieCache:TCachedCookie = New TCachedCookie(cookie, url, domain, path)

		Local key:String = domain.ToLower()

		Local list:TArrayList<TCachedCookie>

		If cookies.TryGetValue(key, list) Then
			' remove existing cookie with same name/path
			list.Remove(cookieCache)

		End If

		' don't add expired cookies
		If cookieCache.IsExpired() Then
			Return False
		End If

		If Not list Then
			list = New TArrayList<TCachedCookie>
			cookies.Add(key, list)
		End If

		list.Add(cookieCache)

		Return True
	End Method

	Method All:TArrayList<THttpCookie>()
		Local allCookies:TArrayList<THttpCookie> = New TArrayList<THttpCookie>

		For Local entry:TMapNode<String, TArrayList<TCachedCookie>> = Eachin cookies
			For Local cachedCookie:TCachedCookie = Eachin entry.value
				If Not cachedCookie.IsExpired() Then
					allCookies.Add( cachedCookie._cookie )
				End If
			Next
		Next

		Return allCookies
	End Method

	Method Match:TArrayList<THttpCookie>(url:TUrl)

		Local urlDomain:String = url.GetHost()
		If Not urlDomain Then
			Return New TArrayList<THttpCookie>
		End If

		Local path:String = url.GetRawPath()
		If Not path Then
			path = "/"
		End If

		Local isSecure:Int = url.IsSecureScheme()

		Local result:TArrayList<THttpCookie> = New TArrayList<THttpCookie>
		Local expired:TTreeMap<String, TArrayList<TCachedCookie>> = New TTreeMap<String, TArrayList<TCachedCookie>>
		Local domain:String = urlDomain.ToLower()

		While domain

			Local cached:TArrayList<TCachedCookie>
			If cookies.TryGetValue(domain, cached) Then

				For Local cookie:TCachedCookie = Eachin cached

					If cookie.IsExpired() Then
						' mark for removal
						Local expiredList:TArrayList<TCachedCookie>
						If Not expired.TryGetValue(domain, expiredList) Then
							expiredList = New TArrayList<TCachedCookie>
							expired.Add(domain, expiredList)
						End If
						expiredList.Add(cookie)
						Continue
					End If

					' check secure
					If cookie.IsSecure() And Not isSecure Then
						Continue
					End If

					' domain
					If Not DomainMatches(urlDomain, cookie._domain, cookie.GetDomain()) Then
						Continue
					End If

					' path
					If Not PathMatches(path, cookie._path) Then
						Continue
					End If

					result.Add( cookie._cookie )
				Next

			End If

			domain = ParentDomain(domain)

		Wend

		If Not expired.IsEmpty() Then

			For Local entry:TMapNode<String, TArrayList<TCachedCookie>> = Eachin expired
				
				Local domain:String = entry.key
				Local cached:TArrayList<TCachedCookie>
				If cookies.TryGetValue(domain, cached) Then
					For Local cookie:TCachedCookie = Eachin entry.value
						cached.Remove(cookie)
					Next
					If cached.IsEmpty() Then
						cookies.Remove(domain)
					End If
				End If
				
			Next

		End If

		Return result
	End Method

	Method Remove:Int(url:TUrl, cookie:THttpCookie)

		Local urlDomain:String = url.GetHost()
		If Not urlDomain Then
			Return False
		End If

		Local resolvedPath:String = ResolveCookiePath(url, cookie)
		Local removed:Int

		Local domain:String = urlDomain.ToLower()
		urlDomain = urlDomain.ToLower()

		While domain

			Local key:String = domain.ToLower()
			Local list:TArrayList<TCachedCookie>
			If cookies.TryGetValue(key, list) Then

				While True
					Local found:Int
					For Local i:Int = 0 Until list.Count()

						Local cachedCookie:TCachedCookie = list[i]

						If urlDomain = cachedCookie._url.GetHost().ToLower() Then

							If cachedCookie._path = resolvedPath And cachedCookie.GetName() = cookie.GetName() Then
								list.RemoveAt(i)
								removed = True
								found = True
								i :- 1
							End If
						End If
					Next
					If Not found Then
						Exit
					End If
				Wend

			End If

			domain = ParentDomain(domain)

		Wend

		Return removed

	End Method

	Method Clear:Int()
		If cookies.Count() = 0 Then
			Return False
		End If

		cookies.Clear()

		Return True
	End Method


	Method ResolveCookieDomain:String(url:TUrl, cookie:THttpCookie)
		Local urlDomain:String = url.GetHost()
		If Not urlDomain Then
			Return Null
		End If

		Local cookieDomain:String = cookie.GetDomain()
		If Not cookieDomain Then
			Return urlDomain
		End If

		Local resolvedDomain:String = cookieDomain
		If cookieDomain.StartsWith(".") Then
			' Domain attribute with leading dot means subdomains are allowed
			resolvedDomain = cookieDomain[1..]
		End If

		' ignore domain if it ends with dot (invalid)
		If resolvedDomain.EndsWith(".") Then
			resolvedDomain = urlDomain
		End If

		If Not AllowDomain(resolvedDomain) Then
			Return Null
		End If

		If Not IsSameOrSubDomain(urlDomain, resolvedDomain) Then
			Return Null
		End If

		Return resolvedDomain
	End Method

	Method IsEmpty:Int()
		Return cookies.IsEmpty()
	End Method

	Method ResolveCookiePath:String(url:TUrl, cookie:THttpCookie)
		Local resolvedPath:String = cookie.GetPath()
		
		If Not resolvedPath Or Not resolvedPath.StartsWith("/") Then
			' Default path is the directory of the request URL
			Local urlPath:String = url.GetRawPath()
			If urlPath = "" Or Not urlPath.StartsWith("/") Then
				resolvedPath = "/"
			Else
				Local lastSlash:Int = urlPath.FindLast("/")
				If lastSlash >= 0 Then
					resolvedPath = urlPath[0..lastSlash]
				Else
					resolvedPath = "/"
				End If
			End If
		End If

		Return resolvedPath
	End Method

	Method AllowDomain:Int(domain:String)
		If domain.EndsWith(".") Then
			domain = domain[0..domain.Length-1]
		End If

		If domain.Contains(".") Then
			Return True
		End If

		Return False
	End Method

	Method IsSameOrSubDomain:Int(subDomain:String, domain:String)
		Local subDomainLower:String = subDomain.ToLower()
		Local domainLower:String = domain.ToLower()

		If Not subDomainLower.Contains(domainLower) Then
			Return False
		End If

		Local beforeMatch:Int = subDomain.Length - domain.Length - 1
		If beforeMatch < 0 Then
			Return False
		End If

		Return subDomain[beforeMatch] = "."
	End Method

	Method DomainMatches:Int(urlDomain:String, domain:String, cookieDomain:String)
		If Not cookieDomain Or cookieDomain.EndsWith(".") Then
			Return urlDomain.ToLower() = domain.ToLower()
		End If

		Return IsSameOrSubDomain(urlDomain, cookieDomain)
	End Method

	Method PathMatches:Int(urlPath:String, cookiePath:String)
		If not cookiePath Then
			Return True
		End If

		If urlPath = cookiePath Then
			Return True
		End If

		If urlPath.StartsWith(cookiePath) Then
			Return cookiePath.EndsWith("/") Or urlPath[cookiePath.Length] = Asc("/")
		End if

		Return False
	End Method

	Method ParentDomain:String(domain:String)
		Local sub:Int = domain.Find(".")
		If sub < 0 Then
			Return Null
		End If

		domain = domain[sub + 1..]

		If domain.Find(".") < 0 Then
			Return Null
		End If

		Return domain
	End Method

End Type

Enum ECookieAttribute
	Comment
	Domain
	Expires
	HttpOnly
	MaxAge
	Path
	SameSite
	Secure
	Partitioned
End Enum

Type TSetCookieParser

	Global CONTROL_CHARS:Int[] = [..
			1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1,..
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,..
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]

	Function Parse:THttpCookie(value:String)

		Local length:Int = value.Length
		Local state:ECookieParseState = ECookieParseState.Name
		Local offset:Int
		Local name:String
		Local quoted:Int
		Local cookieBuilder:THttpCookieBuilder

		For Local i:Int = 0 Until length

			Local char:Int = value[i]

			Select state
				
				Case ECookieParseState.Name
					' parse cookie name
					If char > $FF Then
						' invalid char in name
						Return Null
					End If

					If char = Asc("=") Then

						name = value[offset..i].Trim()

						If name = "" Then
							' invalid empty name
							Return Null
						End If

						offset = i + 1
						state = ECookieParseState.ValueStart

					End If

				Case ECookieParseState.ValueStart
					' parse start of cookie value

					' whitespace
					If char = Asc(" ") Or char = Asc("~t") Then
						Continue
					End If

					If char = Asc("~q") Then
						quoted = True
					Else
						i :- 1
					End If

					offset = i + 1
					state = ECookieParseState.Value

				Case ECookieParseState.Value
					' parse cookie value

					If quoted And char = Asc("~q") Then
						' end of quoted value
						quoted = False
						Local cookieValue:String = value[offset..i].Trim()

						cookieBuilder = THttpCookie.Build(name, cookieValue)
						offset = i + 1
						state = ECookieParseState.Attribute
					Else If char = Asc(";") Then
						' end of value
						Local cookieValue:String = value[offset..i].Trim()

						cookieBuilder = THttpCookie.Build(name, cookieValue)
						offset = i + 1
						state = ECookieParseState.AttributeName

					End If
				Case ECookieParseState.Attribute
					' parse attribute

					' whitespace
					If char = Asc(" ") Or char = Asc("~t") Then
						Continue
					End If

					If char <> Asc(";") Then
						Return Null
					End If

					offset = i + 1
					state = ECookieParseState.AttributeName

				Case ECookieParseState.AttributeName
					' parse attribute name

					If IsControlChar(char) Then
						' invalid char in attribute name
						Return Null
					End If

					If char = Asc("=") Then
						name = value[offset..i].Trim()

						offset = i + 1
						state = ECookieParseState.AttributeValueStart
					Else If char = Asc(";") Then
						' attribute with no value
						name = value[offset..i].Trim()

						If Not SetAttribute(cookieBuilder, name, "") Then
							Return Null
						End If

						offset = i + 1
						'state = ECookieParseState.AttributeName
					End If


				Case ECookieParseState.AttributeValueStart
					' parse start of attribute value

					' whitespace
					If char = Asc(" ") Or char = Asc("~t") Then
						Continue
					End If

					If char = Asc("~q") Then
						quoted = True
					Else
						i :- 1
					End If

					offset = i + 1
					state = ECookieParseState.AttributeValue

				Case ECookieParseState.AttributeValue
					' parse attribute value

					If quoted And char = Asc("~q") Then
						' end of quoted value
						quoted = False
						Local attrValue:String = value[offset..i].Trim()

						If Not SetAttribute(cookieBuilder, name, attrValue) Then
							Return Null
						End If

						offset = i + 1
						state = ECookieParseState.Attribute

					Else If char = Asc(";") Then
						' end of value
						Local attrValue:String = value[offset..i].Trim()

						If Not SetAttribute(cookieBuilder, name, attrValue) Then
							Return Null
						End If

						offset = i + 1
						state = ECookieParseState.AttributeName

					End If

			End Select
		Next

		' final state processing
		Select state
			Case ECookieParseState.Name
				' incomplete cookie
				Return Null
			
			Case ECookieParseState.ValueStart
				' incomplete cookie
				Return THttpCookie.From(name, "")

			Case ECookieParseState.Value

				Local cookieValue:String = value[offset..length].Trim()
				Return THttpCookie.From(name, cookieValue)
			
			Case ECookieParseState.Attribute
				' trailing semicolon
				Return cookieBuilder.Build()

			Case ECookieParseState.AttributeName
				' attribute with no value
				Local attrName:String = value[offset..length].Trim()
				
				If Not SetAttribute(cookieBuilder, attrName, "") Then
					Return Null
				End If

				Return cookieBuilder.Build()

			Case ECookieParseState.AttributeValueStart

				If Not SetAttribute(cookieBuilder, name, "") Then
					Return Null
				End If

				Return cookieBuilder.Build()

			Case ECookieParseState.AttributeValue
				' final attribute value
				Local attrValue:String = value[offset..length].Trim()

				If Not SetAttribute(cookieBuilder, name, attrValue) Then
					Return Null
				End If

				Return cookieBuilder.Build()
		End Select
	End Function

	Function SetAttribute:Int(cookieBuilder:THttpCookieBuilder, name:String, value:String)
		cookieBuilder.Attribute(name, value)
		Return True
	End Function

	Function IsControlChar:Int(char:Int)
		If char < 0 Or char > 127 Then
			Return False
		End If
		Return CONTROL_CHARS[char]
	End Function
End Type

Enum ECookieParseState
	Name
	ValueStart
	Value
	Attribute
	AttributeName
	AttributeValueStart
	AttributeValue
EndEnum

Type TCaseInsensitiveStringComparator Implements IComparator<String>

	Method Compare:Int(a:String, b:String)
		If Not a Or Not b Then
			If a And Not b Then
				Return 1
			ElseIf Not a And b Then
				Return -1
			Else
				Return 0
			End If
		End If

		Return a.ToLower().Compare( b.ToLower() )
	End Method

End Type

Type TCookieHelper
	Global _nameToCookieAttributeCache:TTreeMap<String,ECookieAttribute> = New TTreeMap<String,ECookieAttribute>
	Global _cookieAttributeToNameCache:TTreeMap<ECookieAttribute,String> = New TTreeMap<ECookieAttribute,String>
	Global _months:String[] = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

	Private
	Function Init()
		' Populate cache
		' pairs of enum/string
		Local attributes:String[] = [..
			"Comment", "Comment",..
			"Domain", "Domain",..
			"Expires", "Expires",..
			"HttpOnly", "HttpOnly",..
			"MaxAge", "Max-Age",..
			"Path", "Path",..
			"SameSite", "Same-Site",..
			"Secure", "Secure",..
			"Partitioned", "Partitioned"..
		]

		For Local i:Int = 0 Until attributes.Length Step 2
			_nameToCookieAttributeCache.Add( attributes[i+1].ToLower(), ECookieAttribute.FromString( attributes[i] ) )
			_cookieAttributeToNameCache.Add( ECookieAttribute.FromString( attributes[i] ), attributes[i+1] )
		Next
	End Function

	Function CookieAttributeToString:String( cookieAttribute:ECookieAttribute )
		Return cookieAttribute.ToString().ToUpper()
	End Function

	Function StringToCookieAttribute:ECookieAttribute( attribute:String )
		Try
			Return ECookieAttribute.FromString( attribute )
		Catch ex:Object
			Return ECookieAttribute.Comment
		End Try
	End Function

	Function FormatExpires:String( expires:Long )
		Local dateTime:SDateTime = SDateTime.FromEpoch(expires)

		Local sb:TStringBuilder = New TStringBuilder
		sb.Append( WeekDayToShortWeekday( dateTime.DayOfWeek() ).ToString() )
		sb.Append( ", " )
		sb.Format( "%02d", dateTime.day )
		sb.Append( " " )
		sb.Append( _months[dateTime.month - 1] )
		sb.Append( " " )
		sb.Format( "%04d", dateTime.year )
		sb.Append( " " )
		sb.Format( "%02d", dateTime.hour )
		sb.Append( ":" )
		sb.Format( "%02d", dateTime.minute )
		sb.Append( ":" )
		sb.Format( "%02d", dateTime.second )
		sb.Append( " GMT" )

		Return sb.ToString()
	End Function

	Function ValidateSameSite:String(sameSite:String)
		Local lower:String = sameSite.ToLower()
		Select lower
			Case "none"
				Return "None"
			Case "lax"
				Return "Lax"
			Case "strict"
				Return "Strict"
			Default
				Return ""
		End Select
	End Function

Public
	Function ParseFromSetCookieHeader:THttpCookie( header:THttpField )
		
		Return TSetCookieParser.Parse( header.GetValue() )

	End Function

End Type

TCookieHelper.Init()
