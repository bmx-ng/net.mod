/*
 Copyright (c) 2025 Bruce A Henderson
 
 This software is provided 'as-is', without any express or implied
 warranty. In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgement in the product documentation would be
    appreciated but is not required.
 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
*/ 
#include <Security/Security.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <mbedtls/pem.h>
#include <mbedtls/sha256.h>
#include "brl.mod/blitz.mod/blitz.h"

extern void net_http_http_ca_TMacOSCAStoreBundler__ProcessDer(const unsigned char *der, size_t der_len, BBString * hash, BBObject * obj);

int bmx_net_http_macos_build_ca_bundle(BBObject * obj) {

    CFArrayRef anchors = NULL;
    OSStatus st = SecTrustCopyAnchorCertificates(&anchors);
    if (st != errSecSuccess || anchors == NULL) {
        if (anchors) CFRelease(anchors);
        return 0;
    }
    
    CFIndex n = CFArrayGetCount(anchors);
    for (CFIndex i = 0; i < n; ++i) {
        SecCertificateRef cert = (SecCertificateRef)CFArrayGetValueAtIndex(anchors, i);
        if (!cert) continue;

        CFDataRef der = SecCertificateCopyData(cert);
        if (!der) continue;

        const UInt8 *bytes = CFDataGetBytePtr(der);
        CFIndex len = CFDataGetLength(der);

        if (bytes == NULL || len == 0) {
            CFRelease(der);
            continue;
        }

        // hash the DER to avoid duplicates
        unsigned char h[32];
        mbedtls_sha256(bytes, (size_t)len, h, 0);

        BBString * hash = bbStringFromBytesAsHex(h, 32, 0);

        net_http_http_ca_TMacOSCAStoreBundler__ProcessDer(bytes, (size_t)len, hash, obj);

        CFRelease(der);
    }

    CFRelease(anchors);

    return 1;
}
