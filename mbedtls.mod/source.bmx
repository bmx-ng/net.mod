' 
' Copyright 2018-2022 Bruce A Henderson
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

Import "mbedtls/include/*.h"

Import "mbedtls/library/asn1write.c"
Import "mbedtls/library/base64.c"
Import "mbedtls/library/ctr_drbg.c"
Import "mbedtls/library/debug.c"
Import "mbedtls/library/dhm.c"
Import "mbedtls/library/ecdh.c"
Import "mbedtls/library/ecdsa.c"
Import "mbedtls/library/ecp.c"
Import "mbedtls/library/ecp_curves.c"
Import "mbedtls/library/entropy.c"
Import "mbedtls/library/entropy_poll.c"
Import "mbedtls/library/error.c"
Import "mbedtls/library/hmac_drbg.c"
Import "mbedtls/library/net_sockets.c"
Import "mbedtls/library/pem.c"
Import "mbedtls/library/pk.c"
Import "mbedtls/library/pk_wrap.c"
Import "mbedtls/library/pkcs12.c"
Import "mbedtls/library/pkparse.c"
Import "mbedtls/library/pkwrite.c"
Import "mbedtls/library/platform.c"
Import "mbedtls/library/rsa.c"
Import "mbedtls/library/rsa_alt_helpers.c"
Import "mbedtls/library/ssl_ciphersuites.c"
Import "mbedtls/library/ssl_cli.c"
Import "mbedtls/library/ssl_msg.c"
Import "mbedtls/library/ssl_srv.c"
Import "mbedtls/library/ssl_tls.c"
Import "mbedtls/library/version_features.c"
Import "mbedtls/library/version.c"
Import "mbedtls/library/x509.c"
Import "mbedtls/library/x509_crl.c"
Import "mbedtls/library/x509_crt.c"
Import "mbedtls/library/x509_csr.c"

Import "glue.c"
