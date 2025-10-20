' 
' Copyright 2018-2025 Bruce A Henderson
' 
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
' 
'     http://www.apache.org/licenses/LICENSE-2.0
' 
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
' 
SuperStrict

Import "../mbedtls.mod/mbedtls/include/*.h"

Import "../mbedtls.mod/mbedtls/library/aes.c"
Import "../mbedtls.mod/mbedtls/library/aesni.c"
Import "../mbedtls.mod/mbedtls/library/aesce.c"
Import "../mbedtls.mod/mbedtls/library/aria.c"
Import "../mbedtls.mod/mbedtls/library/asn1parse.c"
Import "../mbedtls.mod/mbedtls/library/bignum.c"
Import "../mbedtls.mod/mbedtls/library/bignum_core.c"
Import "../mbedtls.mod/mbedtls/library/bignum_mod.c"
Import "../mbedtls.mod/mbedtls/library/bignum_mod_raw.c"
Import "../mbedtls.mod/mbedtls/library/block_cipher.c"
Import "../mbedtls.mod/mbedtls/library/camellia.c"
Import "../mbedtls.mod/mbedtls/library/ccm.c"
Import "../mbedtls.mod/mbedtls/library/cmac.c"
Import "../mbedtls.mod/mbedtls/library/chacha20.c"
Import "../mbedtls.mod/mbedtls/library/chachapoly.c"
Import "../mbedtls.mod/mbedtls/library/cipher.c"
Import "../mbedtls.mod/mbedtls/library/cipher_wrap.c"
Import "../mbedtls.mod/mbedtls/library/constant_time.c"
Import "../mbedtls.mod/mbedtls/library/des.c"
Import "../mbedtls.mod/mbedtls/library/ecjpake.c"
Import "../mbedtls.mod/mbedtls/library/gcm.c"
Import "../mbedtls.mod/mbedtls/library/lmots.c"
Import "../mbedtls.mod/mbedtls/library/lms.c"
Import "../mbedtls.mod/mbedtls/library/md.c"
Import "../mbedtls.mod/mbedtls/library/md5.c"
Import "../mbedtls.mod/mbedtls/library/nist_kw.c"
Import "../mbedtls.mod/mbedtls/library/oid.c"
Import "../mbedtls.mod/mbedtls/library/padlock.c"
Import "../mbedtls.mod/mbedtls/library/pkcs5.c"
Import "../mbedtls.mod/mbedtls/library/platform.c"
Import "../mbedtls.mod/mbedtls/library/platform_util.c"
Import "../mbedtls.mod/mbedtls/library/poly1305.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_aead.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_cipher.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_client.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_driver_wrappers_no_static.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_ecp.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_ffdh.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_hash.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_mac.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_pake.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_rsa.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_se.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_slot_management.c"
Import "../mbedtls.mod/mbedtls/library/psa_crypto_storage.c"
Import "../mbedtls.mod/mbedtls/library/psa_its_file.c"
Import "../mbedtls.mod/mbedtls/library/psa_util.c"
Import "../mbedtls.mod/mbedtls/library/ripemd160.c"
Import "../mbedtls.mod/mbedtls/library/sha1.c"
Import "../mbedtls.mod/mbedtls/library/sha256.c"
Import "../mbedtls.mod/mbedtls/library/sha3.c"
Import "../mbedtls.mod/mbedtls/library/sha512.c"
