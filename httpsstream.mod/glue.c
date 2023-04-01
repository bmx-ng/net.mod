/*
  Copyright (c) 2023 Bruce A Henderson
  
  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.
  
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  
  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/ 
#include <stdio.h>
#include <stdlib.h>
#include "curl/curl.h"
#include <string.h>
#include "brl.mod/blitz.mod/blitz.h"

typedef struct {
    CURLM *multi_handle;
    CURL *easy_handle;
    char *buffer;
    size_t buffer_size;
    size_t buffer_offset;
} bmx_curl_reader;

size_t bmx_hstream_write_callback(char *ptr, size_t size, size_t nmemb, void *userdata) {
    bmx_curl_reader *reader = (bmx_curl_reader *) userdata;
    size_t realsize = size * nmemb;

    if (reader->buffer_size - reader->buffer_offset < realsize) {
        size_t new_size = reader->buffer_size * 2;
        char *new_buffer = realloc(reader->buffer, new_size);
        if (!new_buffer) {
            fprintf(stderr, "realloc() failed\n");
            return 0;
        }
        reader->buffer = new_buffer;
        reader->buffer_size = new_size;
    }

    memcpy(reader->buffer + reader->buffer_offset, ptr, realsize);
    reader->buffer_offset += realsize;

    return realsize;
}

bmx_curl_reader * bmx_hstream_curl_reader_init(CURL * curl) {
    bmx_curl_reader * reader = malloc(sizeof(bmx_curl_reader));
    if (!reader) {
        return NULL;
    }

    reader->buffer = malloc(4096);
    reader->buffer_size = 4096;
    reader->buffer_offset = 0;

    reader->easy_handle = curl;

    curl_easy_setopt(reader->easy_handle, CURLOPT_WRITEFUNCTION, bmx_hstream_write_callback);
    curl_easy_setopt(reader->easy_handle, CURLOPT_WRITEDATA, reader);

    reader->multi_handle = curl_multi_init();
    if (reader->multi_handle) {
        curl_multi_add_handle(reader->multi_handle, reader->easy_handle);
    } else {
        free(reader->buffer);
        free(reader);
        return NULL;
    }

    return reader;
}

int bmx_hstream_read_from_curl(bmx_curl_reader *reader, char *data, size_t size) {
    if (!reader) {
        return -1;
    }

    if (reader->buffer_offset == 0) {
        int still_running;
        do {
            CURLMcode res = curl_multi_perform(reader->multi_handle, &still_running);
            if (res != CURLM_OK) {
                fprintf(stderr, "curl_multi_perform() failed: %s\n", curl_multi_strerror(res));
                return -1;
            }

            CURLMsg *msg;
            int msgs_left;
            while ((msg = curl_multi_info_read(reader->multi_handle, &msgs_left))) {
                if (msg->msg == CURLMSG_DONE) {
                    // Transfer completed
                    still_running = 0;
                }
            }
        } while (still_running);
    }

    size_t bytes_to_copy = size < reader->buffer_offset ? size : reader->buffer_offset;
    memcpy(data, reader->buffer, bytes_to_copy);
    memmove(reader->buffer, reader->buffer + bytes_to_copy, reader->buffer_offset - bytes_to_copy);
    reader->buffer_offset -= bytes_to_copy;

    return bytes_to_copy;
}

void bmx_hstream_curl_reader_cleanup(bmx_curl_reader *reader) {
    if (!reader) {
        return;
    }

    curl_multi_remove_handle(reader->multi_handle, reader->easy_handle);
    curl_multi_cleanup(reader->multi_handle);

    free(reader->buffer);
    free(reader);
}
