#!/usr/bin/perl -w
# Install and configure the MAS web application - servlet and applet -
# on a customer's machine.
# date: "$Date$";
# revision: "$Revision$"

use deploy ('configure', 'process_args', 'setup', 'cleanup',
	'applet_archive', 'servlet_archive', 'applet_deployment_directory',
	'servlet_deployment_directory'
);

# Constants

&process_args;
&configure;
&setup;
&install_applet;
exit;
&install_servlet;
# No cleanup needed.

### Main operations

# Intall the applet into the location specified by the configuration file.
sub install_applet {
	print "Installing applet.\n";
}

# Intall the servlet into the location specified by the configuration file.
sub install_servlet {
	print "Installing servlet.\n";
	# Make sure the archive file exists and is readable.
	open(F, &servlet_archive) || die "Cannot open file: " .
		&servlet_archive .  "for reading.\n";
	close(F);
	print "Untarring " . &servlet_archive. "\n";
	! system("jar zxf " . &servlet_archive) || die "Failed to untar " .
		&servlet_archive . "\n";
}

### General utilities

