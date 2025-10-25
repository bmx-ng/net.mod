/*
 Copyright (c) 2007-2025 Bruce A Henderson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/


#include <brl.mod/blitz.mod/blitz.h>
#include <curl/curl.h>

struct curlHttpPost {
    struct curl_httppost * post;
	struct curl_httppost * last;
};


int bmx_curl_easy_setopt_int(CURL *curl, int option, int param) {
	return curl_easy_setopt(curl, option, param);
}

int bmx_curl_easy_setopt_str(CURL *curl, int option, char * param) {
	return curl_easy_setopt(curl, option, param);
}

int bmx_curl_easy_setopt_obj(CURL *curl, int option, BBObject * param) {
	return curl_easy_setopt(curl, option, param);
}

int bmx_curl_easy_setopt_ptr(CURL *curl, int option, void * param) {
	return curl_easy_setopt(curl, option, param);
}

int bmx_curl_easy_setopt_bbint64(CURL *curl, int option, BBInt64 param) {
	return curl_easy_setopt(curl, option, param);
}

int bmx_curl_easy_setopt_cainfoblob(CURL *curl, const unsigned char * data, int length) {
	struct curl_blob blob;
	blob.data = data;
    blob.len = (size_t)length;
    blob.flags = CURL_BLOB_COPY;
	return curl_easy_setopt(curl, CURLOPT_CAINFO_BLOB, &blob);
}

void bmx_curl_formadd_name_content(struct curlHttpPost * httpPost, const char * name, const char * content) {
	curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_PTRCONTENTS, content, CURLFORM_END);
}

void bmx_curl_formadd_name_content_type(struct curlHttpPost * httpPost, const char * name, const char * content, const char * type) {
	curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_PTRCONTENTS, content, CURLFORM_CONTENTTYPE, type, CURLFORM_END);
}

void bmx_curl_formadd_name_file(struct curlHttpPost * httpPost, const char * name, const char * file, int kind) {
	if (kind == 1) {
		curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_FILE, file, CURLFORM_END);
	} else {
		curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_FILECONTENT, file, CURLFORM_END);
	}
}

void bmx_curl_formadd_name_file_type(struct curlHttpPost * httpPost, const char * name, const char * file, const char * type, int kind) {
	if (kind == 1) {
		curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_FILE, file, CURLFORM_CONTENTTYPE, type, CURLFORM_END);
	} else {
		curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_FILECONTENT, file, CURLFORM_CONTENTTYPE, type, CURLFORM_END);
	}
}

void bmx_curl_formadd_name_buffer(struct curlHttpPost * httpPost, const char * name, const char * bname, void * buffer, int length) {
	curl_formadd(&httpPost->post, &httpPost->last, CURLFORM_PTRNAME, name, CURLFORM_BUFFER, bname, CURLFORM_BUFFERPTR, buffer, CURLFORM_BUFFERLENGTH, length, CURLFORM_END);
}

void bmx_curl_setopt(struct curlHttpPost * httpPost, CURL * curl) {
	curl_easy_setopt(curl, CURLOPT_HTTPPOST, httpPost->post);
}

CURLcode bmx_curl_easy_getinfo_string(CURL *curl, CURLINFO info, BBString ** s) {
	char * str = NULL;
	CURLcode res = curl_easy_getinfo(curl, info, &str);
	if (str) {
		*s = bbStringFromUTF8String((unsigned char*)str);
	} else {
		*s = &bbEmptyString;
	}
	return res;
}

CURLcode bmx_curl_easy_getinfo_int(CURL *curl, CURLINFO info, int * value) {
	long v = 0;
	CURLcode res = curl_easy_getinfo(curl, info, &v);
	*value = (int)v;
	return res;
}

CURLcode bmx_curl_easy_getinfo_double(CURL *curl, CURLINFO info, double * value) {
	return curl_easy_getinfo(curl, info, value);
}

CURLcode bmx_curl_easy_getinfo_long(CURL *curl, CURLINFO info, BBInt64 * value) {
	long v = 0;
	CURLcode res = curl_easy_getinfo(curl, info, &v);
	*value = (BBInt64)v;
	return res;
}

BBObject * bmx_curl_easy_getinfo_obj(CURL * curl, CURLINFO info, CURLcode * error) {
	void * priv = NULL;
	*error = curl_easy_getinfo(curl, info, &priv);
	if (!priv) {
		return &bbNullObject;
	}
	return (BBObject *)priv;
}

int bmx_curl_multiselect(CURLM * multi, double timeout) {
	fd_set          readfds;
	fd_set          writefds;
	fd_set          exceptfds;
	int             maxfd;
	struct timeval  to;
	long curl_timeout = -1;

	curl_multi_timeout(multi, &curl_timeout);

	if (curl_timeout >=0) {
		to.tv_sec = curl_timeout / 1000;
		if (to.tv_sec > 1) {
			to.tv_sec = 1;
		} else {
			to.tv_usec = (curl_timeout % 1000) * 1000;
		}
	} else {
		unsigned long conv = (unsigned long) (timeout * 1000000.0);
		to.tv_sec = conv / 1000000;
		to.tv_usec = conv % 1000000;
	}
		
	FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);

	curl_multi_fdset(multi, &readfds, &writefds, &exceptfds, &maxfd);
	
	if (maxfd == -1) {
#ifdef _WIN32
		Sleep(100);
		return 0;
#else
		struct timeval wait = { 0, 100 * 1000 };
		return select(0, NULL, NULL, NULL, &wait);
#endif
	} else {
		return select(maxfd + 1, &readfds, &writefds, &exceptfds, &to);
	}
}

CURLMSG bmx_curl_CURLMsg_msg(CURLMsg * message) {
	return message->msg;
}

CURLcode bmx_curl_CURLMsg_result(CURLMsg * message) {
	return message->data.result;
}

CURL * bmx_curl_CURLMsg_easy_handle(CURLMsg * message) {
	return message->easy_handle;
}

CURLcode bmx_curl_easy_getinfo_slist(CURL * curl, CURLINFO info, struct curl_slist * list) {
    return curl_easy_getinfo(curl, info, list);
}

void bmx_curl_easy_setopt_slist(CURL *curl, CURLoption option, struct curl_slist * slist) {
	curl_easy_setopt(curl, option, slist);
}

void bmx_curl_multi_setopt_int(CURLM * multi, CURLMoption option, int value) {
	curl_multi_setopt(multi, option, value);
}

CURLUcode bmx_curl_url_set(CURLU * handle, CURLUPart part, BBString * content, unsigned int flags) {
	unsigned char * c = (unsigned char*)bbStringToUTF8String(content);
	CURLUcode res = curl_url_set(handle, part, c, flags);
	bbMemFree(c);
	return res;
}

CURLUcode bmx_curl_url_get(CURLU * handle, CURLUPart part, BBString ** content, unsigned int flags) {
	char * c = NULL;
	CURLUcode res = curl_url_get(handle, part, &c, flags);
	if (c) {
		*content = bbStringFromUTF8String((unsigned char*)c);
		curl_free(c);
	} else {
		*content = &bbEmptyString;
	}
	return res;
}

BBString * bmx_curl_url_strerror(CURLUcode code) {
	const char * c = curl_url_strerror(code);
	return bbStringFromUTF8String((unsigned char*)c);
}

BBString * bmx_curl_easy_escape(BBString * txt) {
	size_t len;
	unsigned char * c = (unsigned char*)bbStringToUTF8StringLen(txt, &len);
	char * escaped = curl_easy_escape(NULL, (const char*)c, len);
	bbMemFree(c);
	if ( !escaped ) {
		return &bbEmptyString;
	}
	BBString * result = bbStringFromUTF8String((unsigned char*)escaped);
	curl_free(escaped);
	return result;
}

CURLMcode bmx_curl_multi_poll(CURLM * multi, int timeout_ms, int *numfds) {
	return curl_multi_poll(multi, NULL, 0, timeout_ms, numfds);
}

CURLMcode bmx_curl_multi_timeout(CURLM * multi, int * timeout) {
	long t;
	CURLMcode res = curl_multi_timeout(multi, &t);
	*timeout = (int)t;
	return res;
}
