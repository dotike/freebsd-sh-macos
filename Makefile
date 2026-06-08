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

# Detect functions the system already provides.
COMPAT_DEFS := $(shell echo 'int main(){char *p = strchrnul("x",0);return 0;}' | \
	$(CC) -x c -include string.h -o /dev/null - 2>/dev/null && echo -DHAVE_STRCHRNUL)
COMPAT_DEFS += $(shell echo 'int main(){void *p = reallocarray(0,1,1);return 0;}' | \
	$(CC) -x c -include stdlib.h -o /dev/null - 2>/dev/null && echo -DHAVE_REALLOCARRAY)

CFLAGS=	-DSHELL $(COMPAT_DEFS) \
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

# Generated headers — must exist before any .o compiles.
GENHDRS= $(SHDIR)/builtins.h $(SHDIR)/nodes.h $(SHDIR)/syntax.h $(SHDIR)/token.h

all: $(OBJDIR) generate $(OBJDIR)/$(PROG)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/$(PROG): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

# All objects depend on generated headers (parallel-safe).
$(SHOBJS) $(GENOBJS) $(BLTINOBJS) $(EXTOBJS): $(GENHDRS)

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
# Stamp files ensure each generator runs exactly once under -j8.

generate: .stamp-builtins .stamp-nodes .stamp-syntax .stamp-token

.stamp-builtins: $(SHDIR)/mkbuiltins $(SHDIR)/builtins.def
	cd $(SHDIR) && sh mkbuiltins .
	@touch $@

.stamp-token: $(SHDIR)/mktokens
	cd $(SHDIR) && sh mktokens
	@touch $@

$(SHDIR)/mksyntax: $(SHDIR)/mksyntax.c
	$(CC) -o $@ $<

.stamp-syntax: $(SHDIR)/mksyntax
	cd $(SHDIR) && ./mksyntax
	@touch $@

$(SHDIR)/mknodes: $(SHDIR)/mknodes.c
	$(CC) -o $@ $<

.stamp-nodes: $(SHDIR)/mknodes $(SHDIR)/nodetypes $(SHDIR)/nodes.c.pat
	cd $(SHDIR) && ./mknodes nodetypes nodes.c.pat
	@touch $@

# Generated headers depend on stamps.
$(SHDIR)/builtins.h $(SHDIR)/builtins.c: .stamp-builtins
$(SHDIR)/nodes.h $(SHDIR)/nodes.c: .stamp-nodes
$(SHDIR)/syntax.h $(SHDIR)/syntax.c: .stamp-syntax
$(SHDIR)/token.h: .stamp-token

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
	rm -f .stamp-builtins .stamp-nodes .stamp-syntax .stamp-token

.PHONY: all clean generate install
