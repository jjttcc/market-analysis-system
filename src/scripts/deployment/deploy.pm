# General routines used by the deployment scripts

package deploy;

    require(Exporter);
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(config_file configure mas_port mas_options version
	deployment_directory tarfile applet_archive servlet_archive
	applet_deployment_directory servlet_deployment_directory
	mas_directory_var data_directory data_from_files process_args
	setup cleanup
);

# Constants

$config_file = "mas-deploy.cf";
$Docleanup = 0;

# Settings variables
my %settings = ();
@tags = ("mas_tar_file", "deployment_dir", "version", "server_port_number",
	"cl_options", "mas_dir", "data_dir", "mas_applet_file", "mas_servlet_file",
	"servlet_deployment_dir", "applet_deployment_dir"
);
my ($tarfile_tag, $deploy_dir_tag, $version_tag, $port_tag,
	$options_tag, $mas_directory_tag, $data_dir_tag, $applet_archive_tag,
	$servlet_archive_tag, $applet_deploy_dir_tag, $servlet_deploy_dir_tag
) = @tags;

# Other global variables
my $workdir = "/tmp/mas-install" . $$;
my $remove_dir_cmd = "rm -rf";
my $origdir = $ENV{"PWD"};

# Name of the configuration file
sub config_file {
	$config_file;
}

# Process command-line arguments
sub process_args {
	my $argcount = @ARGV;
	for (my $i = 0; $i < $argcount; ++$i) {
		$arg = $ARGV[$i];
		if ($arg =~ /^-c/) {
			$Docleanup = 1;
		} elsif ($arg =~ /^-+h/ || $arg =~ /^-+?/) {
			&usage; exit 0;
		} else {
			&usage; exit 1;
		}
	}
print "do cleanup: $Docleanup\n";
}

sub usage {
	print "Usage: $0 [-cleanup|-h]\n";
}

### Utilities for set-up, clean-up, etc.

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

# Cleanup - remove the work directory, etc.
sub cleanup {
	chdir $origdir;
	if ($Docleanup) {
		print "Removing work directory, $workdir.\n";
		! system($remove_dir_cmd . " " . $workdir) || die "Failed to remove " .
			"work directory, $workdir.\n";
	}
}

# Process the configuration file.
sub configure {
	my @fields = ();
	open(CF, $config_file) ||
		die "Cannot open configuration file: $config_file\n";
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
}

# Check that the configuration is correct.
sub check_config {
	my $ok = 1;
	for my $t (@tags) {
		if (!$settings{$t}) {
			print "$t not set in ", &config_file, "\n";
			$ok = 0;
		}
	}
	if (!$ok) {
		die "Missing configuration setting - aborting.\n";
	}
}

sub signal_handler {
	&cleanup;
	exit 0;
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

# The directory into which the applet is to be deployed
sub applet_deployment_directory {
	return $settings{$applet_deploy_dir_tag};
}

# The directory into which the servlet is to be deployed
sub servlet_deployment_directory {
	return $settings{$servlet_deploy_dir_tag};
}

# The tar file that contains the mas server and support files
sub tarfile {
	return $settings{$tarfile_tag};
}

# The tar file that contains the mas server and support files
sub applet_archive {
	return $settings{$applet_archive_tag};
}

# The tar file that contains the mas server and support files
sub servlet_archive {
	return $settings{$servlet_archive_tag};
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

return 1;
