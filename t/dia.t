#!/usr/bin/perl

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use Test::More tests => 4;

my $module = 'Archive::Simple';
use_ok( $module );


my $obj = $module->new();

ok( defined $obj, "Check that the class method new returns something" );
ok( $obj->isa('Archive::Simple'), " and that it is a Archive::Simple" );

can_ok( $obj, 'method',  " check object can execute method()" );
ok( $obj->method(),      " check object method method()" );
is( $obj->method(), '?', " check object method method()" );

ok( $Archive::Simple::func(),      " check method func()" );
is( $Archive::Simple::func(), '?', " check method func()" );
