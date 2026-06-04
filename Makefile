## Makefile — build FreeBSD sh on macOS/Darwin
## BSD-2-Clause.

SHDIR=		bin/sh
BLTINDIR=	bin/sh/bltin
KILLDIR=	bin/kill
TESTDIR=	bin/test
PRINTFDIR=	usr.bin/printf

CC?=	cc
CFLAGS=	-DSHELL -DNO_HISTORY \
	-I$(SHDIR) -I$(BLTINDIR) -I. \
	-Wno-deprecated-declarations \
	-include compat.h

SHSRCS=	alias.c arith_yacc.c arith_yylex.c cd.c error.c eval.c \
	exec.c expand.c histedit.c input.c jobs.c mail.c main.c \
	memalloc.c miscbltin.c mystring.c options.c output.c \
	parser.c redir.c show.c trap.c var.c

GENSRCS= builtins.c nodes.c syntax.c

SHOBJS=	$(SHSRCS:.c=.o)
GENOBJS= $(GENSRCS:.c=.o)
BLTINOBJS= bltin_echo.o
EXTOBJS= ext_kill.o ext_test.o ext_printf.o

OBJS=	$(SHOBJS) $(GENOBJS) $(BLTINOBJS) $(EXTOBJS)

PROG=	freebsd-sh

all: generate $(PROG)

$(PROG): $(OBJS)
	$(CC) -o $@ $(OBJS)

$(SHOBJS): %.o: $(SHDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(GENOBJS): %.o: $(SHDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

bltin_echo.o: $(BLTINDIR)/echo.c
	$(CC) $(CFLAGS) -c $< -o $@

ext_kill.o: $(KILLDIR)/kill.c
	$(CC) $(CFLAGS) -c $< -o $@

ext_test.o: $(TESTDIR)/test.c
	$(CC) $(CFLAGS) -c $< -o $@

ext_printf.o: $(PRINTFDIR)/printf.c
	$(CC) $(CFLAGS) -c $< -o $@

# --- generated sources ---

generate: $(SHDIR)/builtins.c $(SHDIR)/nodes.c $(SHDIR)/syntax.c $(SHDIR)/token.h

$(SHDIR)/builtins.c $(SHDIR)/builtins.h: $(SHDIR)/mkbuiltins $(SHDIR)/builtins.def
	cd $(SHDIR) && sh mkbuiltins .

$(SHDIR)/token.h: $(SHDIR)/mktokens
	cd $(SHDIR) && sh mktokens

$(SHDIR)/mksyntax: $(SHDIR)/mksyntax.c
	$(CC) -o $@ $<

$(SHDIR)/syntax.c $(SHDIR)/syntax.h: $(SHDIR)/mksyntax
	cd $(SHDIR) && ./mksyntax

$(SHDIR)/mknodes: $(SHDIR)/mknodes.c
	$(CC) -o $@ $<

$(SHDIR)/nodes.c $(SHDIR)/nodes.h: $(SHDIR)/mknodes $(SHDIR)/nodetypes $(SHDIR)/nodes.c.pat
	cd $(SHDIR) && ./mknodes nodetypes nodes.c.pat

# --- housekeeping ---

clean:
	rm -f $(OBJS) $(PROG)
	rm -f $(SHDIR)/mksyntax $(SHDIR)/mknodes
	rm -f $(SHDIR)/builtins.c $(SHDIR)/builtins.h
	rm -f $(SHDIR)/nodes.c $(SHDIR)/nodes.h
	rm -f $(SHDIR)/syntax.c $(SHDIR)/syntax.h
	rm -f $(SHDIR)/token.h

.PHONY: all clean generate
