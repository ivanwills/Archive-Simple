#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'Archive::Simple' );
}

diag( "Testing Archive::Simple $Archive::Simple::VERSION, Perl $], $^X" );
