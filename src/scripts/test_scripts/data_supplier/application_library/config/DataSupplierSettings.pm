# $Revision$ $Date$

package DataSupplierSettings;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use base qw(EnvironmentSettings);
use File::Spec;


=head1 NAME

DataSupplierSettings

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Environmental settings for the 'data-supplier' application - See description
in the parent, EnvironmentSettings, for instructions on how to use
this class.

=cut


# --------------- Public features ---------------

# Access

# Status report

# Element change

# --------------- Non-public features ---------------

{

# Implementation

# Implementation - utilities

	# @INC settings for the specified 'basedir'
	sub settings_for {
		my ($self, $basedir, $dirtable) = @_;
		my $result = $$dirtable{$basedir};
	}

# Hook routine implementations

	sub dir_table {
		my ($self) = @_;
		my $srcdir = '';
		if ($::TESTAPP) {
			$srcdir = 'src';
		}
		my @appdirs = (
			File::Spec->catdir($srcdir, 'application_library', 'support'),
			File::Spec->catdir($srcdir, 'application_library',
				'main_abstractions'),
		);
		my @moddirs = $self->module_dirs;
		my %result = (
			$self->module_base_path => \@moddirs,
			$self->app_base_path => \@appdirs
		);
		return \%result;
	}

	sub app_var_name {
		my ($self) = @_;
		my $result = "DataSupplierApplication";
	}

}

1;
