/*
 * compat.h — portability shims for building FreeBSD sh on non-FreeBSD
 *
 * BSD-3-Clause.  See individual source files for their own licenses.
 */
#ifndef _COMPAT_H_
#define _COMPAT_H_

#ifndef __FBSDID
#define __FBSDID(x)
#endif

#ifndef O_VERIFY
#define O_VERIFY 0
#endif

/* macOS lacks eaccess(2); use access(2) instead. */
#ifdef __APPLE__
#include <unistd.h>
#define eaccess(path, mode) access(path, mode)
#endif

/* strchrnul: provided by macOS 26+, absent before. */
#if defined(__APPLE__) && !defined(HAVE_STRCHRNUL)
#include <string.h>
static inline char *
compat_strchrnul(const char *s, int c)
{
	while (*s != '\0' && *s != (char)c)
		s++;
	return ((char *)s);
}
#define strchrnul compat_strchrnul
#endif

/* reallocarray: provided by macOS 26+, absent before. */
#if defined(__APPLE__) && !defined(HAVE_REALLOCARRAY)
#include <stdlib.h>
#include <errno.h>
static inline void *
compat_reallocarray(void *ptr, size_t nmemb, size_t size)
{
	if (size != 0 && nmemb > (size_t)-1 / size) {
		errno = ENOMEM;
		return (NULL);
	}
	return realloc(ptr, nmemb * size);
}
#define reallocarray compat_reallocarray
#endif

/* macOS uses NSIG; FreeBSD uses sys_nsig. */
#ifdef __APPLE__
#include <signal.h>
#define sys_nsig NSIG
#endif

/* macOS lacks qsort_s; use qsort_r with swapped args. */
#ifdef __APPLE__
#define qsort_s(base, nmemb, size, compar, thunk) \
	qsort_r(base, nmemb, size, thunk, \
		(int (*)(void *, const void *, const void *))(compar))
#endif

/* macOS uses st_mtimespec; FreeBSD uses st_mtim. */
#ifdef __APPLE__
#define st_mtim st_mtimespec
#endif

#endif /* _COMPAT_H_ */
