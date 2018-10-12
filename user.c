/* Copyright 1988,1990,1993,1994 by Paul Vixie
 * All rights reserved
 *
 * Distribute freely, except: don't remove my name from the source or
 * documentation (don't take credit for my work), mark your changes (don't
 * get me blamed for your possible bugs), don't alter or remove this
 * notice.  May be sold if buildable source is provided to buyer.  No
 * warrantee of any kind, express or implied, is included with this
 * software; use at your own risk, responsibility for damages (if any) to
 * anyone resulting from the use of this software rests entirely with the
 * user.
 *
 * Send bug reports, bug fixes, enhancements, requests, flames, etc., and
 * I'll try to keep a version up to date.  I can be reached as follows:
 * Paul Vixie          <paul@vix.com>          uunet!decwrl!vixie!paul
 */

#if !defined(lint) && !defined(LINT)
static char rcsid[] = "$Id: user.c,v 2.8 1994/01/15 20:43:43 vixie Exp $";
#endif

/* vix 26jan87 [log is in RCS file]
 */


#include "corn.h"


void
free_user(u)
	user	*u;
{
	entry	*e, *ne;

	free(u->name);
	for (e = u->corntab;  e != NULL;  e = ne) {
		ne = e->next;
		free_entry(e);
	}
	free(u);
}


user *
load_user(corntab_fd, pw, name)
	int		corntab_fd;
	struct passwd	*pw;		/* NULL implies syscorntab */
	char		*name;
{
	char	envstr[MAX_ENVSTR];
	FILE	*file;
	user	*u;
	entry	*e;
	int	status;
	char	**envp;

	if (!(file = fdopen(corntab_fd, "r"))) {
		perror("fdopen on corntab_fd in load_user");
		return NULL;
	}

	Debug(DPARS, ("load_user()\n"))

	/* file is open.  build user entry, then read the corntab file.
	 */
	u = (user *) malloc(sizeof(user));
	u->name = strdup(name);
	u->corntab = NULL;

	/* 
	 * init environment.  this will be copied/augmented for each entry.
	 */
	envp = env_init();

	/*
	 * load the corntab
	 */
	while ((status = load_env(envstr, file)) >= OK) {
		switch (status) {
		case ERR:
			free_user(u);
			u = NULL;
			goto done;
		case FALSE:
			e = load_entry(file, NULL, pw, envp);
			if (e) {
				e->next = u->corntab;
				u->corntab = e;
			}
			break;
		case TRUE:
			envp = env_set(envp, envstr);
			break;
		}
	}

 done:
	env_free(envp);
	fclose(file);
	Debug(DPARS, ("...load_user() done\n"))
	return u;
}
