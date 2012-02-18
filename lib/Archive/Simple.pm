package Archive::Simple;

# Created on: 2012-02-18 19:53:08
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use IO::All;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has files => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {{}},
);
has manifest => (
    is       => 'rw',
    isa      => 'Bool',
);
has _offset => (
    is       => 'rw',
    isa      => 'Int',
);
has _processed => (
    is       => 'rw',
    isa      => 'Bool',
);

sub create {
    my ($self, @files) = @_;

    confess "You must specify a files to add to the archive\n" if !@files;

    my $archive = io $self->name;
    '' > $archive;
    $archive->close;

    @files = map {io $_} @files;

    if ( $self->manifest ) {
        my @new_files = @files;
        @files = ();

        while ( my $file = shift @new_files ) {
            if ( -d $file->name && -f $file->name . '/MANIFEST' ) {
                push @files, map {io $file->name . "/$_"} grep {$_} map {chomp; $_} @{ io($file->name . '/MANIFEST') };
            }
            else {
                push @files, $file;
            }
        }
    }

    while ( my $file = shift @files ) {
        next if $self->files->{$file};
        next if !-e $file->name;

        if ( -d $file->name ) {
            push @files, io($file)->all;
            next;
        }

        my $details = $self->files->{$file} = {};

        $details->{start} = -s $archive->name;
        io($file) >> $archive;
        $archive->close;
        $details->{end} = -s $archive->name;

        $details->{executable} = 1 if -x $file->name;
        #$details->{perms} = $file->perms;
    }

    my $header = "Archive::Simple $Archive::Simple::VERSION\n";
    for my $file (sort keys %{ $self->files } ) {
        my %data  = %{ $self->files->{$file} };
        my $start = delete $data{start};
        my $end   = delete $data{end};

        $header .= "$file\t$start\t$end";
        for my $key ( keys %data ) {
            $header .= "\t$key=$data{$key}";
        }

        $header .= "\n";
    }
    $header .= "\n";
    unshift @$archive, $header;

    $self->_offset(length $header);
    $self->_processed(1);
}

sub list {
    my ($self) = @_;
    $self->process() if !$self->_processed;

    return keys %{ $self->files };
}

sub process {
    my ($self) = @_;
    return $self if $self->_processed;

    my $archive = io $self->name;
    die "Unknown file type '".$self->name."'\n" if $archive->[0] !~ /^Archive::Simple\s(\d+[.]\d+[.]\d+)$/xms;

    my $offset = length $archive->[0];
    my $i = 1;

    while (1) {
        my $line = $archive->[$i++];
        $offset += 1 + length $line;
        last if !$line;

        my ($file,$start,$end,@data) = split /\t/, $line;
        my %data = map {/^([^=])=(.*)$/} @data;

        $self->files->{$file} = { start => $start, end => $end, %data };
    }

    $self->_offset($offset + 1);
    $self->_processed(1);

    return $self;
}

sub show {
    my ($self, @files) = @_;
    $self->process;
    my $results = '';

    for my $file (@files) {
        my $archive = io $self->name;
        $archive->seek( $self->_offset + $self->files->{$file}{start}, 0 );
        my $buffer;
        my $size = $archive->read($buffer, $self->files->{$file}{end} - $self->files->{$file}{start});
        $results .= $buffer;
    }

    return $results;
}

1;

__END__

=head1 NAME

Archive::Simple - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Archive::Simple version 0.1.


=head1 SYNOPSIS

   use Archive::Simple;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.




=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
