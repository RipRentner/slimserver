package Slim::Music::VirtualLibraries;

# Logitech Media Server Copyright 2001-2014 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

=head1 NAME

Slim::Music::VirtualLibraries

=head1 DESCRIPTION

Helper class to deal with virtual libraries.

L<Slim::Music::VirtualLibraries>

=cut

use strict;

use Digest::MD5 qw(md5_hex);

use Slim::Utils::Log;
use Slim::Utils::Prefs;

my $log   = logger('server');
my $prefs = preferences('server');

my %libraries;

sub registerLibrary {
	my ($class, $args) = @_;

	if ( !$args->{id} ) {
		$log->error('Invalid parameters: you need to register with a name and a unique ID');
		return;
	}
	
	# we use a short hashed version of the real ID
	my $id  = $args->{id};
	my $id2 = substr(md5_hex($id), 0, 8);
	
	if ( $libraries{$id2} ) {
		$log->error('Duplicate library ID: ' . $id);
		return;
	}
	
	$libraries{$id2} = $args;
	$libraries{$id2}->{name} ||= $args->{id};
	
	return $id2;
}

sub getLibraries {
	return \%libraries;
}

sub hasLibraries {
	return scalar keys %libraries;
}

# because we store a hashed version of the ID we might need to look it up
sub getRealId {
	my ($class, $id) = @_;
	
	my ($id2) = grep { $libraries{$_}->{id} eq $id } keys %libraries;
	return $id2;
}

# return a library ID set for a client or globally in LMS
sub getLibraryIdForClient {
	my ($class, $client) = @_;
	
	return unless keys %libraries;
	
	my $id;
	$id   = $prefs->client($client)->get('libraryId') if $client;
	$id ||= $prefs->get('libraryId');
	
	return unless $id && $libraries{$id};
	
	return $id || '';
}

sub getNameForId {
	my ($class, $id) = @_;
	
	return '' unless $libraries{$id};
	return $libraries{$id}->{name} || '';
}


1;