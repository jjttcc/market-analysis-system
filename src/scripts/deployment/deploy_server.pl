#!/usr/bin/perl -w
# Install and configure the MAS server on a customer's machine.

# Name of the deployment configuration file
my $config_file = "mas-deploy.cf";

# Settings tags used in config. file
my $tarfile_tag = "mas_tar_file";
my $deploy_dir_tag = "deployment_dir";
my $version_tag = "version";

# Values set by processing the configuration file
my $tarfile = "";
my $deployment_directory = "";
my $version = "";

# Other global variables
my @fields = ();
my $workdir = "/tmp/mas-install";
my $remove_dir_cmd = "rm -rf";
my $origdir = $ENV{"PWD"};
open(CF, $config_file) || die "Cannot open configuration file: $config_file\n";

# Process the configuration file.
while (<CF>) {
	if (/^#/) {
		next;
	}
	@fields = split("\t", $_);
	chomp @fields;
	if ($fields[0] eq $tarfile_tag) {
		$tarfile = $fields[1];
	} elsif ($fields[0] eq $deploy_dir_tag) {
		$deployment_directory = $fields[1];
	} elsif ($fields[0] eq $version_tag) {
		$version = $fields[1];
	}
}

&check_config;
open(TAR, $tarfile) || die "Cannot open file: $tarfile for reading.\n";
print "Opened $tarfile\n";
close(TAR);
&setup;
&untar;
&install;
&cleanup;

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

# Intall MAS into $deployment_directory.
sub install {
	chdir "mas-" . $version;
system("pwd");
	! system(&install_cmd) || die "Failed to install MAS into " .
		$deployment_directory . ".\n";
}

sub untar {
system("echo tar zxf $tarfile");
	! system("tar zxf $tarfile") || die "Failed to untar $tarfile";
}

sub cleanup {
	chdir $origdir;
	print "Removing work directory, $workdir.\n";
	! system($remove_dir_cmd . " " . $workdir) || die "Failed to remove " .
		"work directory, $workdir.\n";
}

# Check that the configuration is correct.
sub check_config {
#!!!!Stub
}

sub install_cmd {
	return "./install --rootdir $deployment_directory";
}

sub signal_handler {
	&cleanup;
	exit 0;
}
