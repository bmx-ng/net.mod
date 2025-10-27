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

Import BRL.FileSystem
Import brl.collections
Import Brl.stringbuilder
import brl.standardio
Import "../mbedtls.mod/mbedtls/include/*.h"

?win32 or macos
Import "glue.c"
?

?macos
Import "macos_ca_glue.c"
?win32
Import "-lCrypt32 -lAdvapi32"
Import "win32_ca_glue.c"
?

Type TCAStoreProvider

	Global inited:Int = 0

	Global INSTANCE:TCAStoreProvider = New TCAStoreProvider()

	Field _stores:TArrayList<TCAStore> = New TArrayList<TCAStore>

	Method Register(store:TCAStore)
		_stores.Add(store)
	End Method

	Method Init()
		If inited Then
			Return
		End If

		Local forRemoval:TArrayList<TCAStore> = New TArrayList<TCAStore>

		' check registered stores
		For Local store:TCAStore = Eachin _stores
			If Not store.VerifyBundle() Then
				forRemoval.Add(store)
			End If
		Next

		' remove invalid stores
		For Local store:TCAStore = Eachin forRemoval
			_stores.Remove(store)
		Next

		inited = True

	End Method

	Method GetStore:TCAStore()
		Init()
		If _stores.Count() > 0 Then
			Return _stores[0]
		End If
		Return Null
	End Method
	
End Type

Type TCAStore

	Method IsAFile:Int()
		Return False
	End Method

	Method IsABlob:Int()
		Return False
	End Method

	Method CertsAsBlob:Byte[]()
		Return Null
	End Method

	Method CertsAsPath:String()
		Return ""
	End Method

	Method VerifyBundle:Int()

	End Method

End Type

Type TFileCAStore Extends TCAStore

	Field _paths:String[]
	Field _path:String
	Field _exists:Int = False

	Method New(path:String)
		_path = path
	End Method

	Method New(paths:String[])
		_paths = paths
	End Method

	Method IsAFile:Int()
		Return True
	End Method

	Method CertsAsPath:String()
		If _exists Then
			Return _path
		End If
	End Method

	Method Exists:Int()
		Return _exists
	End Method

	Method VerifyBundle:Int() Override
		If Not _path And Not _paths Then
			_exists = False
			Return False
		End If

		If _exists Then
			Return True
		End If

		If _path Then
			If FileExists(_path) Then
				_exists = True
				Return True
			Else
				_exists = False
				Return False
			End If
		End If

		For Local p:String = EachIn _paths
			If FileExists(p) Then
				_path = p
				_exists = True
				Return True
			End If
		Next

		Return True
	End Method

End Type

Type TBlobCAStore Extends TCAStore

	Field _blob:Byte[] 

	Method IsABlob:Int() Override
		Return True
	End Method

	Method CertsAsBlob:Byte[]() Override
		Return _blob
	End Method

	Method SetBlob(blob:Byte[] )
		_blob = blob
	End Method

	Method VerifyBundle:Int() Override
		Return _blob <> Null
	End Method

End Type

Type TSystemCAStore Extends TCAStore

End Type

?linux
Type TLinuxCAStore Extends TFileCAStore

	Method New()
		Super.New([..
			"/etc/ssl/certs/ca-certificates.crt",..
    		"/etc/pki/tls/certs/ca-bundle.crt",..
    		"/etc/ssl/ca-bundle.pem",..
    		"/etc/ssl/cert.pem"])
	End Method

End Type

TCAStoreProvider.INSTANCE.Register( New TLinuxCAStore() )
?

?macos
Type TMacOSBrewCAStore Extends TFileCAStore

	Method New()
		Super.New("/opt/homebrew/etc/ca-certificates/cert.pem")
	End Method

End Type

Type TMacOSCAStore Extends TSystemCAStore

	Field _bundle:String
	Field _processed:Int = False
	Field _valid:Int = False

	Method IsABlob:Int() Override
		Return True
	End Method

	Method VerifyBundle:Int()
		If Not _processed Then
			Local bundler:TMacOSCAStoreBundler = New TMacOSCAStoreBundler(Self)
			bmx_net_http_macos_build_ca_bundle(bundler)
			If bundler.HasBundle() Then
				_bundle = bundler.GetBundle()
				_valid = True
			End If
			_processed = True
		End If

		Return _valid
	End Method

	Method CertsAsBlob:Byte[]()
		If Not _valid Or Not _bundle Then
			Return Null
		End If

		Local length:Size_T = _bundle.Length
		Local buf:Byte[length]
		_bundle.ToUTF8StringBuffer(buf, length)
		Return buf
	End Method
End Type

Type TMacOSCAStoreBundler

	Field store:TMacOSCAStore
	Field bundles:TTreeMap<String, String> = New TTreeMap<String, String>

	Method New(store:TMacOSCAStore)
		self.store = store
	End Method

	Method HasBundle:Int()
		Return Not bundles.IsEmpty()
	End Method

	Method GetBundle:String()
		Local sb:TStringBuilder = New TStringBuilder
		For Local pem:String = EachIn bundles.Values()
			sb.Append(pem)
		Next
		Return sb.ToString()
	End Method

	Method ProcessDer(data:Byte Ptr, length:Size_T, hash:String)
		If Not bundles.ContainsKey(hash) Then
			Local pem:String
			If bmx_net_http_der_to_pem(data, length, pem) = 0 Then
				bundles.Add(hash, pem)
			End If
		End If
	End Method

	Function _ProcessDer(data:Byte Ptr, length:Size_T, hash:String, bundler:TMacOSCAStoreBundler) { nomangle }
		bundler.ProcessDer(data, length, hash)
	End Function

End Type

'TCAStoreProvider.INSTANCE.Register( New TBrewBlobCAStore() )
TCAStoreProvider.INSTANCE.Register( New TMacOSBrewCAStore() )
TCAStoreProvider.INSTANCE.Register( New TMacOSCAStore() )

Extern
	Function bmx_net_http_macos_build_ca_bundle:Int(bundler:TMacOSCAStoreBundler)
	Function bmx_net_http_der_to_pem:Int(der:Byte Ptr, der_len:Size_T, pem:String Var)
End Extern
?

?win32
Type TWindowsCAStore Extends TSystemCAStore
    Field _bundle:String
    Field _processed:Int
    Field _valid:Int

    Method IsABlob:Int() Override Return True End Method

    Method VerifyBundle:Int() Override
        If Not _processed Then
            Local bundler:TWindowsCAStoreBundler = New TWindowsCAStoreBundler(Self)
            bmx_net_http_win32_build_ca_bundle(bundler)
            If bundler.HasBundle() Then
                _bundle = bundler.GetBundle()
                _valid = True
            End If
            _processed = True
        End If
        Return _valid
    End Method

    Method CertsAsBlob:Byte[]() Override
        If Not _valid Or Not _bundle Then Return Null
        Local length:Size_T = _bundle.Length
        Local buf:Byte[length]
        _bundle.ToUTF8StringBuffer(buf, length)
        Return buf
    End Method
End Type

Type TWindowsCAStoreBundler
    Field store:TWindowsCAStore
    Field bundles:TTreeMap<String, String> = New TTreeMap<String, String>

    Method New(store:TWindowsCAStore)
        Self.store = store
    End Method

    Method HasBundle:Int()
		Return Not bundles.IsEmpty()
	End Method

    Method GetBundle:String()
        Local sb:TStringBuilder = New TStringBuilder
        For Local pem:String = EachIn bundles.Values()
            sb.Append(pem)
        Next
        Return sb.ToString()
    End Method

    Method ProcessDer(data:Byte Ptr, length:Size_T, hash:String)
        If Not bundles.ContainsKey(hash) Then
            Local pem:String
            If bmx_net_http_der_to_pem(data, length, pem) = 0 Then
                bundles.Add(hash, pem)
            End If
        End If
    End Method

    Function _ProcessDer(data:Byte Ptr, length:Size_T, hash:String, bundler:TWindowsCAStoreBundler) { nomangle }
        bundler.ProcessDer(data, length, hash)
    End Function
End Type

TCAStoreProvider.INSTANCE.Register( New TWindowsCAStore() )

Extern
	Function bmx_net_http_win32_build_ca_bundle:Int(bundler:TWindowsCAStoreBundler)
	Function bmx_net_http_der_to_pem:Int(der:Byte Ptr, der_len:Size_T, pem:String Var)
End Extern
?
