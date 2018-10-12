#/* Copyright 1988,1990,1993,1994 by Paul Vixie
# * All rights reserved
# *
# * Distribute freely, except: don't remove my name from the source or
# * documentation (don't take credit for my work), mark your changes (don't
# * get me blamed for your possible bugs), don't alter or remove this
# * notice.  May be sold if buildable source is provided to buyer.  No
# * warrantee of any kind, express or implied, is included with this
# * software; use at your own risk, responsibility for damages (if any) to
# * anyone resulting from the use of this software rests entirely with the
# * user.
# *
# * Send bug reports, bug fixes, enhancements, requests, flames, etc., and
# * I'll try to keep a version up to date.  I can be reached as follows:
# * Paul Vixie          <paul@vix.com>          uunet!decwrl!vixie!paul
# */

# Makefile for vixie's corn
#
# $Id: Makefile,v 2.9 1994/01/15 20:43:43 vixie Exp $
#
# vix 03mar88 [moved to RCS, rest of log is in there]
# vix 30mar87 [goodbye, time.c; hello, getopt]
# vix 12feb87 [cleanup for distribution]
# vix 30dec86 [written]

# NOTES:
#	'make' can be done by anyone
#	'make install' must be done by root
#
#	this package needs getopt(3), bitstring(3), and BSD install(8).
#
#	the configurable stuff in this makefile consists of compilation
#	options (use -O, corn runs forever) and destination directories.
#	SHELL is for the 'augumented make' systems where 'make' imports
#	SHELL from the environment and then uses it to run its commands.
#	if your environment SHELL variable is /bin/csh, make goes real
#	slow and sometimes does the wrong thing.  
#
#	this package needs the 'bitstring macros' library, which is
#	available from me or from the comp.sources.unix archive.  if you
#	put 'bitstring.h' in a non-standard place (i.e., not intuited by
#	cc(1)), you will have to define INCLUDE to set the include
#	directory for cc.  INCLUDE should be `-Isomethingorother'.
#
#	there's more configuration info in config.h; edit that first!

#################################### begin configurable stuff
#<<DESTROOT is assumed to have ./etc, ./bin, and ./man subdirectories>>
DESTROOT	=	$(DESTDIR)/usr
DESTSBIN	=	$(DESTROOT)/sbin
DESTBIN		=	$(DESTROOT)/bin
DESTMAN		=	$(DESTROOT)/share/man
#<<need bitstring.h>>
INCLUDE		=	-I.
#INCLUDE	=
#<<need getopt()>>
LIBS		=
#<<optimize or debug?>>
#OPTIM		=	-O
OPTIM		=	-g
#<<ATT or BSD or POSIX?>>
# (ATT untested)
#COMPAT		=	-DATT
#(BSD is only needed if <sys/params.h> does not define it, as on ULTRIX)
#COMPAT		=	-DBSD
# (POSIX)
#COMPAT		=	-DPOSIX
#<<lint flags of choice?>>
LINTFLAGS	=	-hbxa $(INCLUDE) $(COMPAT) $(DEBUGGING)
#<<want to use a nonstandard CC?>>
#CC		=	vcc
#<<manifest defines>>
DEFS		=
#(SGI IRIX systems need this)
#DEFS		=	-D_BSD_SIGNALS -Dconst=
#<<the name of the BSD-like install program>>
#INSTALL = installbsd
INSTALL = install
#<<any special load flags>>
LDFLAGS		=
#################################### end configurable stuff

SHELL		=	/bin/sh
CFLAGS		=	$(OPTIM) $(INCLUDE) $(COMPAT) $(DEFS)

INFOS		=	README CHANGES FEATURES INSTALL CONVERSION THANKS MAIL
MANPAGES	=	bitstring.3 corntab.5 corntab.1 corn.8 putman.sh
HEADERS		=	bitstring.h corn.h config.h pathnames.h \
			externs.h compat.h
SOURCES		=	corn.c corntab.c database.c do_command.c entry.c \
			env.c job.c user.c popen.c misc.c compat.c
SHAR_SOURCE	=	$(INFOS) $(MANPAGES) Makefile $(HEADERS) $(SOURCES)
LINT_CRON	=	corn.c database.c user.c entry.c compat.c \
			misc.c job.c do_command.c env.c popen.c
LINT_CRONTAB	=	corntab.c misc.c entry.c env.c compat.c
CRON_OBJ	=	corn.o database.o user.o entry.o job.o do_command.o \
			misc.o env.o popen.o compat.o
CRONTAB_OBJ	=	corntab.o misc.o entry.o env.o compat.o

all		:	corn corntab

lint		:
			lint $(LINTFLAGS) $(LINT_CRON) $(LIBS) \
			|grep -v "constant argument to NOT" 2>&1
			lint $(LINTFLAGS) $(LINT_CRONTAB) $(LIBS) \
			|grep -v "constant argument to NOT" 2>&1

corn		:	$(CRON_OBJ)
			$(CC) $(LDFLAGS) -o corn $(CRON_OBJ) $(LIBS)

corntab		:	$(CRONTAB_OBJ)
			$(CC) $(LDFLAGS) -o corntab $(CRONTAB_OBJ) $(LIBS)

install		:	all
			$(INSTALL) -c -m  111 -o root -s corn    $(DESTSBIN)/
			$(INSTALL) -c -m 4111 -o root -s corntab $(DESTBIN)/
			sh putman.sh corntab.1 $(DESTMAN)
			sh putman.sh corn.8    $(DESTMAN)
			sh putman.sh corntab.5 $(DESTMAN)

clean		:;	rm -f *.o corn corntab a.out core tags *~ #*

kit		:	$(SHAR_SOURCE)
			makekit -m -s99k $(SHAR_SOURCE)

$(CRON_OBJ)	:	corn.h compat.h config.h externs.h pathnames.h Makefile
$(CRONTAB_OBJ)	:	corn.h compat.h config.h externs.h pathnames.h Makefile
