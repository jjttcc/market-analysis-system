#!/usr/bin/perl -w
# Install and configure the MAS server on a customer's machine.
# date: "$Date$";
# revision: "$Revision$"

# Name of the deployment configuration file
my $config_file = "mas-deploy.cf";

my $start_mas_script = "start_server";
# Settings tags used in config. file
@tags = ("mas_tar_file", "deployment_dir", "version", "server_port_number",
	"cl_options");
my ($tarfile_tag, $deploy_dir_tag, $version_tag, $port_tag,
	$options_tag) = @tags;
my %settings = ();

# Other global variables
my @fields = ();
my $workdir = "/tmp/mas-install";
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
print "mas cmd: ", &mas_startup_command, "\n";
&setup;
&untar;
&install;
&make_startup_script;
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

# Intall MAS into the deployment directory.
sub install {
	chdir "mas-" . $settings{$version_tag};
system("pwd");
	! system(&install_cmd) || die "Failed to install MAS into " .
		$settings{$deploy_dir_tag} . ".\n";
}

sub untar {
	# Make sure the tar file exists and is readable.
	my $tarfile = $settings{$tarfile_tag};
	open(TAR, $tarfile) || die "Cannot open file: $tarfile for reading.\n";
	close(TAR);
	print "Untarring $tarfile\n";
	! system("tar zxf $tarfile") || die "Failed to untar $tarfile";
}

sub make_startup_script {
	$f = $settings{$deploy_dir_tag} . "/bin/" . $start_mas_script;
	open(F, "> " . $f) || die "Cannot create startup file $f";
	print F &mas_startup_command . "\n";
}

sub mas_startup_command {
	return "mas $settings{$port_tag} $settings{$options_tag}";
}

sub cleanup {
	chdir $origdir;
	print "Removing work directory, $workdir.\n";
	! system($remove_dir_cmd . " " . $workdir) || die "Failed to remove " .
		"work directory, $workdir.\n";
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

sub install_cmd {
	return "./install --rootdir $settings{$deploy_dir_tag}";
}

sub signal_handler {
	&cleanup;
	exit 0;
}
