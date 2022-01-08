/*
 Copyright (c) 2007-2022 Bruce A Henderson
 
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

CURLcode bmx_curl_easy_getinfo_string(CURL *curl, CURLINFO info, char * s) {
	return curl_easy_getinfo(curl, info, s);

}

CURLcode bmx_curl_easy_getinfo_int(CURL *curl, CURLINFO info, int * value) {
	return curl_easy_getinfo(curl, info, value);
}

CURLcode bmx_curl_easy_getinfo_double(CURL *curl, CURLINFO info, double * value) {
	return curl_easy_getinfo(curl, info, value);
}

char * bmx_curl_easy_getinfo_obj(CURL * curl, CURLINFO info, CURLcode * error) {
	char * priv = NULL;
	*error = curl_easy_getinfo(curl, info, priv);
	return priv;
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
