package Data::Package;

=pod

=head1 NAME

Data::Package - Base class for packages that are purely data

=head1 SYNOPSIS
  
  ### Using a Data::Package
  
  use Global::Config;
  
  # Get the data in the default or a prefered format
  Global::Config->get;
  Global::Config->get('Config::Tiny');
  
  # Can we get the data in a particular format?
  Global::Config->provides('Config::Tiny');
  
  ### Creating a data package
  
  package Global::Config;
  
  use strict;
  use base 'Data::Package';
  use Config::Tiny ();
  
  # Load and return the data as a Config::Tiny object.
  sub __as_Config_Tiny {
  	local $/;
  	Config::Tiny->read_string(<DATA>);
  }
  
  1;
  
  __DATA__
  
  [section]
  foo=1
  bar=2

=head1 INTRODUCTION

In the CPAN, a variety of different mechanisms are used by a variety
of different authors in order to provide medium to large amounts of
data to support the functionality contained in various modules.

Some of these mechanism are, in this author's opinion, highly inelegant
and often quite ugly, such as converting the Arial font into a
2.7meg perl module.

Why exactly the authors are having to resort to these measures is often
unclear, although convenience or to an ability to leverage the ease with
which which modules can be found (compared to data files) one thing is
very clear.

There is B<no> obvious, easy and universal way in which to create and
deliver a "Data Product" via CPAN. A Data Product is a package in where
there is little or no functionality and all of the value is contained in
the data itself.

Within the global and unique package namespace of perl, most of the
packages represent code, in the form of APIs, but this does not mean
that code is the B<only> thing that reserve a package name.

=head1 DESCRIPTION

Data::Package provides the core of a highly scalable and extendable API
that allows data packages and data products to be delivered via CPAN.

It provides a minimal API that separates getting the data from the
methods by which the data is obtained, installed, accessed and loaded.

The intent is that the consumer of the data should not have to care
B<how> the data is obtained, just that you can always obtain the data
you need in the format that you want.

It allows the author or provider of the data to assign the data a unique
name within the package namespace, while change or improve the
underlying install, storage and loading mechanism without the need for
anything that accesses the data to have to be changed.

=head2 API Overview

The core API requires that only only two static methods be defined,
and probably only one matters if you wrote both the data package,
B<and> code that is using it.

In the simplest and (probably) most common case, where the data package
returns only a single known object type, you should need only to load
the module and then get the data from it.

  use Some::Data::Package;
  
  $Data = Some::Data::Package->get;

For more complex cases capable of providing the data in several
formats, you can use the C<provides> method to find out what types
of object the data package is capable of providing.

  @classes = Some::Data::Package->provides;

etc... etc...

=head1 STATUS

The current implementation is considered to be a proof of concept only.

It should work, and I do want to know about bugs, but it's a little
early to be relying on it yet for production work. It does not have
a sufficiently complete unit test library for starters.

About half the implementation is done by pulling in functionality from
other dependant modules, which are not completely production-standard
themselves (in the case of L<Param::Coerce>. For a proper production
grade version, we probably shouldn't have any dependencies.

However, the API itself is stable and final, and you can write code
that uses this package safely, and any upgrades down the line should
not affect it.

=head1 METHODS

=cut

use strict;
use UNIVERSAL 'isa';
use Class::Inspector ();
use Param::Coerce    ();

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.01';
}





#####################################################################
# Constructor

=pod

=head2 new

The C<new> constructor is provided mainly as a convenience, and to let
you create handles to the data that can be passed around easily.

Takes new arguments, and returns a new blessed object of the same class
that you called it for.

=cut

sub new {
	my $class = ref($_[0]) || "$_[0]";
	my $self  = \$class;
	bless $self, $class;
}





#####################################################################
# Main Methods

=pod

=head2 provides [ $class ]

The C<provides> method is used to find the list of formats the data
package is capable of providing the data in, although typically it
is just going to be one.

When called without an argument, the method returns a list of all of
the classes that the data can be provides as instantiated objects of.

In this first version, it is assumed you are providing the data as some
form of object.

If provided an argument, the list will be filtered to list only those
that are of the object type you specificied. This can be used to either
limit the list, or check for a specific class you want.

In both cases, the first class returned by C<provides> is the same that
will be returned by the C<get> method when called with the same (or without
an) argument.

And either way, the method returns the classes in list context, or the
number of classes in scalar context. This also lets you do things like:

  if ( Data::Thingy->provides('Big::Thing') ) {
  	die "Data::Thing cannot provide a Big::Thing";
  }

=cut

sub provides {
	my $class = ref $_[0] ? ref shift : shift;

	# Get the raw list of classes
	my @provides = $class->_provides;

	# Return the full list unless we were given a filter
	my $want = shift or return @provides;

	grep { isa($_, $want) } @provides;
}

sub _provides {
	my $class = shift;

	# If the class has a @PROVIDES array, we'll use that directly.
	no strict 'refs';
	if ( defined @{"${class}::PROVIDES"} ) {
		return @{"${class}::PROVIDES"};
	}

	# Scan the class for __as_Foo_Bar methods
	my $methods = Class::Inspector->methods($class)
		or die "Error while looking for providor method in $class";

	# Filter to just provider methods
	grep { /^__as(?:_[^\W\d]\w*)+$/ } @$methods;
}

=pod

=head2 get [ $class ]

The C<get> method does whatever is necesary to access and load the data
product, and returns it as an object.

If the data package is capable of providing the data in more than one
format, you can optionally provide an object of the class that you want
it in.

Returns an object (possibly of a class you specify) or C<undef> if it
is unable to load the data, or it cannot provide the data in the format
that you have requested.

=cut

sub get {
	my $class = ref $_[0] ? ref shift : shift;

	# Given that they our subclass did not write it's own version
	# of the ->get method, they must be using coercion provider
	# methods.
	#
	# So lets find what we need to deliver, and then call it.
	my @classes = $class->provides(@_) or return undef;
	my $want = shift @classes;

	# Leverage coerce to do the actual loading
	Param::Coerce::_coerce( $want, $class->new );
}

1;

=pod

=head1 SUPPORT

Bugs should always be submitted via the CPAN bug tracker

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data%3A%3APackage>

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
