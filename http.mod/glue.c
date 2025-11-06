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
#include <mbedtls/pem.h>
#include <mbedtls/sha256.h>
#include "brl.mod/blitz.mod/blitz.h"

int bmx_net_http_der_to_pem(const unsigned char *der, size_t der_len, BBString ** pem)
{
    const char *header = "-----BEGIN CERTIFICATE-----\n";
    const char *footer = "-----END CERTIFICATE-----\n";
    size_t olen = 0;

    // get the required buffer size
    int ret = mbedtls_pem_write_buffer(header, footer, der, der_len, 0, 0, &olen);

    size_t buf_len = olen;
    unsigned char *buf = malloc(buf_len);
    if (!buf) {
        *pem = &bbEmptyString;
        return -1;
    }

    ret = mbedtls_pem_write_buffer(header, footer, der, der_len, buf, buf_len, &olen);
    if (ret != 0) {
        *pem = &bbEmptyString;
        free(buf);
        return ret;
    }

    // exclude the null terminator from the length
    size_t text_len = (olen > 0) ? (olen - 1) : 0;
    *pem = bbStringFromBytes(buf, text_len);
    free(buf);
    return 0;
}
