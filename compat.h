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

/* macOS lacks strchrnul(3). */
#ifdef __APPLE__
#include <string.h>
static inline char *
strchrnul(const char *s, int c)
{
	while (*s != '\0' && *s != (char)c)
		s++;
	return ((char *)s);
}
#endif

/* macOS lacks reallocarray(3). */
#ifdef __APPLE__
#include <stdlib.h>
#include <errno.h>
static inline void *
reallocarray(void *ptr, size_t nmemb, size_t size)
{
	if (size != 0 && nmemb > (size_t)-1 / size) {
		errno = ENOMEM;
		return (NULL);
	}
	return realloc(ptr, nmemb * size);
}
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
