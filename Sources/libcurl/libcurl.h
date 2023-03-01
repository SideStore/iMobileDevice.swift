#include <stdbool.h>
#include <curl/curl.h>

typedef size_t (*curl_func)(void * ptr, size_t size, size_t num, void * ud);

CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
	return curl_easy_setopt(curl, option, param);
}

CURLcode curl_easy_setopt_func(CURL *handle, CURLoption option, curl_func param) {
	return curl_easy_setopt(handle, option, param);
}

CURLcode curl_easy_setopt_pointer(CURL *handle, CURLoption option, void* param) {
	return curl_easy_setopt(handle, option, param);
}
