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
#include <windows.h>
#include <wincrypt.h>
#include <stdlib.h>
#include <string.h>

#include <mbedtls/pem.h>
#include <mbedtls/sha256.h>

#include "brl.mod/blitz.mod/blitz.h"

extern void net_http_http_ca_TWindowsCAStoreBundler__ProcessDer(const unsigned char *der, size_t der_len, BBString * hash, BBObject * obj);

// Returns 1 if the cert (by SHA1) exists in DISALLOWED store, else 0
static int is_disallowed(PCCERT_CONTEXT ctx, HCERTSTORE hDisallowed) {
    if (!hDisallowed) {
		return 0;
	
	}
    BYTE sha1[20];
	DWORD sz = sizeof(sha1);
	
    if (!CertGetCertificateContextProperty(ctx, CERT_SHA1_HASH_PROP_ID, sha1, &sz)) {
        return 0;
	}
	
    CRYPT_HASH_BLOB blob;
	blob.pbData = sha1;
	blob.cbData = sz;
    PCCERT_CONTEXT hit = CertFindCertificateInStore(hDisallowed, X509_ASN_ENCODING, 0,
                                                   CERT_FIND_SHA1_HASH, &blob, NULL);
    if (hit) {
		CertFreeCertificateContext(hit);
		return 1;
	}
    return 0;
}

static void process_store(HCERTSTORE hStore, HCERTSTORE hDisallowedCU, HCERTSTORE hDisallowedLM, BBObject * obj) {
    if (!hStore) {
		return;
	}
    PCCERT_CONTEXT ctx = NULL;
    while ((ctx = CertEnumCertificatesInStore(hStore, ctx)) != NULL) {
        // Use the DER bytes directly from the context
        const unsigned char *der = (const unsigned char*)ctx->pbCertEncoded;
        size_t der_len = (size_t)ctx->cbCertEncoded;
        
		if (!der || der_len == 0) {
			continue;
		}

        // Skip if present in DISALLOWED (user or machine)
        if (is_disallowed(ctx, hDisallowedCU) || is_disallowed(ctx, hDisallowedLM)) {
            continue;
		}

        unsigned char h[32]; 
		mbedtls_sha256(der, der_len, h, 0);
		
        BBString * hash = bbStringFromBytesAsHex(h, 32, 0);

        net_http_http_ca_TWindowsCAStoreBundler__ProcessDer(der, der_len, hash, obj);
    }
}

int bmx_net_http_win32_build_ca_bundle(BBObject * obj) {
    int ok = 0;

    // Open ROOT stores for CU and LM
    HCERTSTORE hRootCU = CertOpenStore(CERT_STORE_PROV_SYSTEM_W, 0, 0,
                                       CERT_SYSTEM_STORE_CURRENT_USER | CERT_STORE_OPEN_EXISTING_FLAG,
                                       L"ROOT");
    HCERTSTORE hRootLM = CertOpenStore(CERT_STORE_PROV_SYSTEM_W, 0, 0,
                                       CERT_SYSTEM_STORE_LOCAL_MACHINE | CERT_STORE_OPEN_EXISTING_FLAG,
                                       L"ROOT");
    // DISALLOWED stores (to exclude untrusted)
    HCERTSTORE hDisCU = CertOpenStore(CERT_STORE_PROV_SYSTEM_W, 0, 0,
                                      CERT_SYSTEM_STORE_CURRENT_USER | CERT_STORE_OPEN_EXISTING_FLAG,
                                      L"DISALLOWED");
    HCERTSTORE hDisLM = CertOpenStore(CERT_STORE_PROV_SYSTEM_W, 0, 0,
                                      CERT_SYSTEM_STORE_LOCAL_MACHINE | CERT_STORE_OPEN_EXISTING_FLAG,
                                      L"DISALLOWED");

    if (hRootCU || hRootLM) {
        process_store(hRootCU, hDisCU, hDisLM, obj);
        process_store(hRootLM, hDisCU, hDisLM, obj);
        ok = 1;
    }

    if (hRootCU) CertCloseStore(hRootCU, 0);
    if (hRootLM) CertCloseStore(hRootLM, 0);
    if (hDisCU) CertCloseStore(hDisCU, 0);
    if (hDisLM) CertCloseStore(hDisLM, 0);

    return ok;
}
