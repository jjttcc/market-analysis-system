#!/usr/bin/perl -w
# Install and configure the MAS web application - servlet and applet -
# on a customer's machine.
# date: "$Date$";
# revision: "$Revision$"

use deploy ('configure', 'process_args', 'setup', 'cleanup',
	'applet_archive', 'servlet_archive', 'applet_deployment_path',
	'servlet_deployment_directory', 'mas_port', 'abort'
);

# Constants

&process_args;
&configure;
&install_applet;
&install_servlet;
&configure_servlet;
&cleanup;

### Main operations

# Intall the applet into the location specified by the configuration file.
sub install_applet {
	print "Installing applet.\n";
	# Make sure the archive file exists and is readable.
	open(F, &applet_archive) || &abort("Cannot open file: " .
		&applet_archive .  " for reading.\n");
	close(F);
	print "Unpacking " . &applet_archive. "\n";
	! system("cp " . &applet_archive . " " . &applet_deployment_path) ||
		&abort("Failed to copy " . &applet_archive . " to " .
		&applet_deployment_path . "\n");
}

# Intall the servlet into the location specified by the configuration file.
sub install_servlet {
	print "Installing servlet.\n";
	chdir &servlet_deployment_directory ||
		&abort("Could not cd to ", &servlet_deployment_directory, "\n");
	# Make sure the archive file exists and is readable.
	open(F, &servlet_archive) || &abort("Cannot open file: " .
		&servlet_archive . " for reading.\n");
	close(F);
	print "Unpacking " . &servlet_archive. "\n";
	! system("jar xvf " . &servlet_archive) || &abort("Failed to unpack " .
		&servlet_archive . "\n");
}

# Configure settings for the servlet.
sub configure_servlet {
	my $config_file = &servlet_deployment_directory . "/WEB-INF/web.xml";
	my $port_tag = "mas-server-port";
	my $port = &mas_port;
	open(F, $config_file) || &abort("Cannot open file: " .
		$config_file . " for reading.\n");
	my @contents = <F>;
	my @new_contents = ();
	my $port_changed = 0;
	my $i = 0;
	while ($i < @contents) {
		if ($contents[$i] =~ /<param-name>$port_tag<\/param-name>$/) {
			push(@new_contents, $contents[$i]);
			++$i;
			if ($contents[$i] =~ /<param-value>[0-9]+<\/param-value>/) {
				$contents[$i] =~
					s/(<param-value>)[0-9]+(<\/param-value>)/$1$port$2/;
				$port_changed = 1;
			}
		}
		push(@new_contents, $contents[$i]);
		++$i;
	}
	if (! $port_changed) {
		print "Warning: $port_tag parameter not found in:\n$config_file.\n";
	}
	close(F);
	open(F, "> " . $config_file) || &abort("Cannot open file: " .
		$config_file . " for writing.\n");
	print F @new_contents;
}
