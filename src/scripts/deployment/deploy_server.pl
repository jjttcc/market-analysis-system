#!/usr/bin/perl -w
# Install and configure the MAS server on a customer's machine.
# date: "$Date$";
# revision: "$Revision$"

# Name of the deployment configuration file
my $config_file = "mas-deploy.cf";

# Constants
my $start_mas_script = "start_mas_server";
my $stop_mas_script = "shutdown_mas_server";
my $python_path_var = "PYTHONPATH";

# Settings tags used in config. file
@tags = ("mas_tar_file", "deployment_dir", "version", "server_port_number",
	"cl_options", "mas_dir", "data_dir");
my ($tarfile_tag, $deploy_dir_tag, $version_tag, $port_tag,
	$options_tag, $mas_directory_tag, $data_dir_tag) = @tags;
my %settings = ();

# Other global variables
my @fields = ();
my $workdir = "/tmp/mas-install" . $$;
my $remove_dir_cmd = "rm -rf";
my $origdir = $ENV{"PWD"};
open(CF, $config_file) || die "Cannot open configuration file: $config_file\n";

# Process the configuration file.
while (<CF>) {
	if (/^#/ || /^$/) {
		next;
	}
	@fields = split("\t", $_);
	chomp @fields;
	if (@fields < 2) {
		print "Wrong number of fields (@fields) at line $.\n";
		next;
	}
	$settings{$fields[0]} = $fields[1];
}

&check_config;
&setup;
&untar;
&install;
&make_driver_scripts;
&cleanup;

### Main operations

# Create and cd to the work directory, etc.
sub setup {
	if (! -d $workdir) {
		if (! -e $workdir) {
			mkdir $workdir || die "Cannot create directory $workdir\n";
		} else {
			die "Work directory $workdir cannot be created because\n" .
				"it already exists, but is not a directory.\n";
		}
	}
	if (! (-w $workdir && -r $workdir)) {
		die "Do not have permission to use directory $workdir.\n";
	}
	chdir $workdir;
	for my $sig ('INT', 'HUP', 'QUIT', 'TERM') {
		$SIG{$sig} = 'signal_handler';
	}
}

# Intall MAS into the deployment directory.
sub install {
	chdir "mas-" . &version;
system("pwd");
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

# Check that the configuration is correct.
sub check_config {
	my $ok = 1;
	for my $t (@tags) {
		if (!$settings{$t}) {
			print "$t not set in $config_file\n";
			$ok = 0;
		}
	}
	if (!$ok) {
		die "Missing configuration setting - aborting.\n";
	}
}

### Utilities for set-up, clean-up, etc.

sub cleanup {
	chdir $origdir;
	print "Removing work directory, $workdir.\n";
	! system($remove_dir_cmd . " " . $workdir) || die "Failed to remove " .
		"work directory, $workdir.\n";
}

sub signal_handler {
	&cleanup;
	exit 0;
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

### Configuration settings

# The port that the mas server will use for client connections
sub mas_port {
	return $settings{$port_tag};
}

# mas server command-line options
sub mas_options {
	return $settings{$options_tag};
}

# The mas version number
sub version {
	return $settings{$version_tag};
}

# The directory into which mas is to be deployed
sub deployment_directory {
	return $settings{$deploy_dir_tag};
}

# The tar file that contains the mas server and support files
sub tarfile {
	return $settings{$tarfile_tag};
}

# Name of the mas directory environment variable
sub mas_directory_var {
	return $settings{$mas_directory_tag};
}

# The directory in which data files will be stored
sub data_directory {
	return $settings{$data_dir_tag};
}

# Will the mas server get its data from files?
sub data_from_files {
	return &data_directory !~ /NONE/;
}
