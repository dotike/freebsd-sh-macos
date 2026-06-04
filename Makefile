## Makefile — build FreeBSD sh on macOS/Darwin
## BSD-2-Clause.

SHDIR=		bin/sh
BLTINDIR=	bin/sh/bltin
KILLDIR=	bin/kill
TESTDIR=	bin/test
PRINTFDIR=	usr.bin/printf
OBJDIR=		obj

# until further notice, this port is experimental:
PREFIX?=	$(HOME)
LIBEDIT_PREFIX?= /opt/homebrew/opt/libedit

CC?=	cc
CFLAGS=	-DSHELL \
	-I$(SHDIR) -I$(BLTINDIR) -I. -Icontrib/libedit \
	-I$(LIBEDIT_PREFIX)/include \
	-Wno-deprecated-declarations \
	-include compat.h
LDFLAGS= -L$(LIBEDIT_PREFIX)/lib -ledit -lcurses

SHSRCS=	alias.c arith_yacc.c arith_yylex.c cd.c error.c eval.c \
	exec.c expand.c histedit.c input.c jobs.c mail.c main.c \
	memalloc.c miscbltin.c mystring.c options.c output.c \
	parser.c redir.c show.c trap.c var.c

GENSRCS= builtins.c nodes.c syntax.c

SHOBJS=	$(addprefix $(OBJDIR)/,$(SHSRCS:.c=.o))
GENOBJS= $(addprefix $(OBJDIR)/,$(GENSRCS:.c=.o))
BLTINOBJS= $(OBJDIR)/bltin_echo.o
EXTOBJS= $(OBJDIR)/ext_kill.o $(OBJDIR)/ext_test.o $(OBJDIR)/ext_printf.o

OBJS=	$(SHOBJS) $(GENOBJS) $(BLTINOBJS) $(EXTOBJS)

PROG=	fsh

all: $(OBJDIR) generate $(OBJDIR)/$(PROG)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/$(PROG): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

$(SHOBJS): $(OBJDIR)/%.o: $(SHDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(GENOBJS): $(OBJDIR)/%.o: $(SHDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/bltin_echo.o: $(BLTINDIR)/echo.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/ext_kill.o: $(KILLDIR)/kill.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/ext_test.o: $(TESTDIR)/test.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/ext_printf.o: $(PRINTFDIR)/printf.c
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

# --- install ---

install: $(OBJDIR)/$(PROG)
	install -d $(PREFIX)/bin
	install -m 755 $(OBJDIR)/$(PROG) $(PREFIX)/bin/$(PROG)
	install -d $(PREFIX)/share/man/man1
	install -m 644 fsh.1 $(PREFIX)/share/man/man1/fsh.1

# --- housekeeping ---

clean:
	rm -rf $(OBJDIR)
	rm -f $(SHDIR)/mksyntax $(SHDIR)/mknodes
	rm -f $(SHDIR)/builtins.c $(SHDIR)/builtins.h
	rm -f $(SHDIR)/nodes.c $(SHDIR)/nodes.h
	rm -f $(SHDIR)/syntax.c $(SHDIR)/syntax.h
	rm -f $(SHDIR)/token.h

.PHONY: all clean generate install
