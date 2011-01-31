# POD documentation - main docs before the code

# $Id: Failover.pm,v 1.6 2003/02/17 06:48:29 shawnh Exp $


=head1 NAME

Bio::DB::Failover - A Bio::DB::RandomAccessI compliant class which wraps a priority list of DBs

=head1 SYNOPSIS

    $failover = Bio::DB::Failover->new();

    $failover->add_database($db);

    # fail over Bio::DB::RandomAccessI.pm

    # this will check each database in priority, returning when
    # the first one succeeds

    $seq = $failover->get_Seq_by_id($id);

=head1 DESCRIPTION

This module provides fail over access to a set of Bio::DB::RandomAccessI objects


=head1 CONTACT

Ewan Birney originally wrote this class.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution. Bug reports can be submitted via email
or the web:

    bioperl-bugs@bio.perl.org                   
    http://bugzilla.bioperl.org/           

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::DB::Failover;

use vars qw(@ISA);
use strict;

use Bio::Root::Root;
use Bio::DB::RandomAccessI;
@ISA = qw(Bio::Root::Root Bio::DB::RandomAccessI );

sub new {
    my ($class,@args) = @_;

    my $self = $class->SUPER::new(@args);

    $self->{'_database'} = [];
    return $self;
}

=head2 add_database

 Title   : add_database
 Usage   : add_database(%db)
 Function: Adds a database to the 
 Returns : count of number of databases
 Args    : hash of db resource name to Bio::DB::SeqI object

=cut

sub add_database {
    my ($self,@db) = @_;
    foreach my $db ( @db ) {
	if( !ref $db || !$db->isa('Bio::DB::RandomAccessI') ) {
	    $self->throw("Database objects $db is a not a Bio::DB::RandomAccessI");
	    next;
	}

	push(@{$self->{'_database'}},$db);
    }    
}


=head2 get_Seq_by_id

 Title   : get_Seq_by_id
 Usage   : $seq = $db->get_Seq_by_id('ROA1_HUMAN')
 Function: Gets a Bio::Seq object by its name
 Returns : a Bio::Seq object
 Args    : the id (as a string) of a sequence
 Throws  : "id does not exist" exception


=cut

sub get_Seq_by_id {
    my ($self,$id) = @_;

    if( !defined $id ) {
	$self->throw("no id is given!");
    }

    foreach my $db ( @{$self->{'_database'}} ) {
	my $seq;

	eval {
	    $seq = $db->get_Seq_by_id($id);
	};
	if( defined $seq ) {
	    return $seq;
	}
    }

    return undef;
}

=head2 get_Seq_by_acc

 Title   : get_Seq_by_acc
 Usage   : $seq = $db->get_Seq_by_acc('X77802');
 Function: Gets a Bio::Seq object by accession number
 Returns : A Bio::Seq object
 Args    : accession number (as a string)
 Throws  : "acc does not exist" exception


=cut

sub get_Seq_by_acc {
    my ($self,$id) = @_;

    if( !defined $id ) {
	$self->throw("no id is given!");
    }

    foreach my $db ( @{$self->{'_database'}} ) {
	my $seq;
	eval {
	    $seq = $db->get_Seq_by_acc($id);
	};
	if( defined $seq ) {
	    return $seq;
	}
    }
    return undef;
}


## End of Package

1;

__END__

