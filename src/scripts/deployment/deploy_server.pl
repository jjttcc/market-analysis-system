#!/usr/bin/perl -w
# Install and configure the MAS server on a customer's machine.
# date: "$Date$";
# revision: "$Revision$"

use deploy('configure', 'mas_port', 'mas_options', 'version',
	'deployment_directory', 'tarfile', 'mas_directory_var', 'data_directory',
	'data_from_files', 'process_args', 'setup', 'cleanup'
);

# Constants
my $start_mas_script = "start_mas_server";
my $stop_mas_script = "shutdown_mas_server";
my $python_path_var = "PYTHONPATH";

&process_args;
&configure;
&setup;
&untar;
&install;
&make_driver_scripts;
&cleanup;

### Main operations

# Intall MAS into the deployment directory.
sub install {
	chdir "mas-" . &version;
	! system(&install_cmd) || die "Failed to install MAS into " .
		&deployment_directory . ".\n";
}

sub untar {
	# Make sure the tar file exists and is readable.
	open(TAR, &tarfile) || die "Cannot open file: " . &tarfile .
		"for reading.\n";
	close(TAR);
	print "Untarring " . &tarfile. "\n";
	! system("tar zxf " . &tarfile) || die "Failed to untar " . &tarfile . "\n";
}

sub make_driver_scripts {
	$f = &deployment_directory . "/bin/" . $start_mas_script;
	open(F, "> " . $f) || die "Cannot create startup script $f";
	print F &mas_startup_command . "\n";
	chmod 0500, $f;
	$f = &deployment_directory . "/bin/" . $stop_mas_script;
	open(F, "> " . $f) || die "Cannot create shutdown script $f";
	print F &mas_shutdown_command . "\n";
	chmod 0500, $f;
}

### General utilities

sub mas_startup_command {
	my $env = &script_environment . "\n";
	my $cd_dir = &cd_data_command . "\n";
	return $env . $cd_dir . &deployment_directory . "/bin/mas " . &mas_port .
		" " . &mas_options;
}

sub mas_shutdown_command {
	my $python_path = &script_python_path . "\n";
	my $echo = "echo |";
	return $python_path . $echo . &deployment_directory .
		"/bin/macl " . &mas_port;
}

sub script_environment {
	return "export " . &mas_directory_var . "=" .
		&deployment_directory . "/lib";
}

sub script_python_path {
	return "export " . $python_path_var . "=" .
		&deployment_directory . "/lib/python";
}

sub cd_data_command {
	my $result = "";
	if (&data_from_files) {
		$result = "cd " . &data_directory;
	}
	$result;
}

sub install_cmd {
	return "./install --rootdir " . &deployment_directory;
}
