' Copyright (c) 2009-2025 Bruce A Henderson
' All rights reserved.
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
'     * Redistributions of source code must retain the above copyright
'       notice, this list of conditions and the following disclaimer.
'     * Redistributions in binary form must reproduce the above copyright
'       notice, this list of conditions and the following disclaimer in the
'       documentation and/or other materials provided with the distribution.
'     * Neither the auther nor the names of its contributors may be used to 
'       endorse or promote products derived from this software without specific
'       prior written permission.
'
' THIS SOFTWARE IS PROVIDED BY Bruce A Henderson ``AS IS'' AND ANY
' EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL Bruce A Henderson BE LIABLE FOR ANY
' DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
' (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
' ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
' (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
' SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
SuperStrict

Import BRL.Blitz
Import Pub.zlib
Import Net.mbedtls

Import "../mbedtls.mod/mbedtls/include/*.h"
Import "../../archive.mod/zlib.mod/zlib/*.h"

?win32
Import "include_win32/*.h"
?Not win32
Import "include_unix/*.h"
?
Import "libssh2/src/*.h"
Import "libssh2/include/*.h"

Import "libssh2/src/agent.c"
Import "libssh2/src/bcrypt_pbkdf.c"
Import "libssh2/src/blowfish.c"
Import "libssh2/src/chacha.c"
Import "libssh2/src/channel.c"
Import "libssh2/src/cipher-chachapoly.c"
Import "libssh2/src/comp.c"
Import "libssh2/src/crypt.c"
Import "libssh2/src/crypto.c"
Import "libssh2/src/global.c"
Import "libssh2/src/hostkey.c"
Import "libssh2/src/keepalive.c"
Import "libssh2/src/kex.c"
Import "libssh2/src/knownhost.c"
Import "libssh2/src/libgcrypt.c"
Import "libssh2/src/mac.c"
Import "libssh2/src/misc.c"
Import "libssh2/src/openssl.c"
Import "libssh2/src/packet.c"
Import "libssh2/src/pem.c"
Import "libssh2/src/poly1305.c"
Import "libssh2/src/publickey.c"
Import "libssh2/src/scp.c"
Import "libssh2/src/session.c"
Import "libssh2/src/sftp.c"
Import "libssh2/src/transport.c"
Import "libssh2/src/userauth.c"
Import "libssh2/src/userauth_kbd_packet.c"
Import "libssh2/src/version.c"
Import "libssh2/src/wincng.c"

Import "glue.cpp"
