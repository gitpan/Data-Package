package Data::Package::Simple;

=pod

=head1 NAME

Data::Package::Simple - Implement simple data packages based on freeze/thaw formats

=head1 SYNOPSIS

  # A basic class that loads a structure stored as
  # a YAML document from the __DATA__ section.
  package My::Data;
  
  use YAML 'thaw';
  
  use base 'Data::Package::Simple';
  
  1;
  
  __DATA__
  foo: bar
  this: that
  children:
    - one
    - two
    - three
    - four

=head1 DESCRIPTION

Data::Package::Simple is designed to add a DWIM layer on top of
L<Data::Package> to allow you to create basic but proper data packages
quickly and easily.

The intention is that it will provide a "first implementation" which
may or may not migrate to a more complex package at a later date.

You can use a ::Simple data package in your initial implementations,
and then upgrade it at any point in the future without having to change
the code that uses it.

The ::Simple class is designed to take advantage of the standard
freeze/thaw module used for data serialization by modules such as
L<Storable> or L<YAML>.

etc etc...

=head1 METHODS

=cut

use strict;
use UNIVERSAL 'isa';
use base 'Data::Package';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.03';
}





#####################################################################
# Main Methods






#####################################################################
# Support Methods

# Determine the loading class
sub _loader {
	my $class = shift;

	# Have they explicitly defined the $LOADER global
	if ( defined ${"${class}::LOADER"} ) {
		return ${"${class}::LOADER"};
	}

	# Have the imported a thaw method
	if ( $class->can('thaw') ) {
		return $class;
	}

	# Otherwise, we have no idea
	undef;
}

# Determine the data source
sub _source {
	my $class = shift;

	# Have they explicitly defined the $SOURCE global
	if ( defined ${"${class}::SOURCE"} ) {
		return ${"${class}::SOURCE"};
	}

	# Do they have a __DATA__ section
	die 'CODE INCOMPLETE';
}

1;

=pod

=head1 SUPPORT

Bugs should always be submitted via the CPAN bug tracker

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Package>

For other issues, contact the maintainer

=head1 AUTHOR

Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 COPYRIGHT

Copyright (c) 2005 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
