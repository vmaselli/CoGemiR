#
# MicroRNA Database: 
#
# Perl Module for Seq.pm 
#
# Cared for by Vincenza Maselli
#
# Copyright  Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod

=head1 NAME

Bio::Cogemir::Seq

=head1 SYNOPSIS

	my $seq = new Bio::Cogemir::Seq (   
									  -name           => 'seq name',
                                      -sequence		  => 'ATATATATTACGCGC',
                                      -logic_name_id => 13
                                    );
	my $name = $seq->name;

=head1 DESCRIPTION

 Object representing a sequences, either nucleotide or peptide.
 inherits from Bio::PrimarySeq.

=head1 AUTOHOR

 Vincenza Maselli <maselli@tigem.it>

=cut


package Bio::Cogemir::Seq;
use Bio::Cogemir::DBSQL::SeqAdaptor;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::PrimarySeq

use Bio::PrimarySeq;
use Data::Dumper;
@ISA = qw(Bio::PrimarySeq);

#constructor

=head2 new

 Title          : new
 Usage          : my $seq = new Bio::Cogemir::Seq (   
				                 -name        => 'seq name',
                                                 -sequence        => 'ATATATATTACGCGC',
                                                 -logic_name_id  => 13
                                    );
 Returns        : Bio::Cogemir::Seq
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have sequence

=cut

sub new {
    my ($class,@args) = @_;

    my $self = $class->SUPER::new(@args);
    my ($dbID,$adaptor,$name,$sequence, $logic_name) = $self->_rearrange([qw(  
								  DBID
								  ADAPTOR
								  NAME
								  SEQUENCE
								  LOGIC_NAME
								  )],@args);

    $dbID && $self->dbID($dbID);
    $adaptor && $self->adaptor($adaptor);
    $name && $self->name($name);
    $sequence && $self->sequence($sequence);
    $logic_name && $self->logic_name($logic_name); 
    #  we must have a sequence ana type specification of sequence
    if (! ($self->sequence)) {
	$self->throw("The Seq does not have all attributes to be created. I need sequence");
    }
    return $self;
}


=head2 dbID

 Title    : dbID
 Usage    : $obj->dbID([$newval])
 Function : get/set method for attribute dbID 
 Returns  : value of dbID
 Args     : newval of dbID (optional)

=cut


sub dbID{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'};
}

=head2 adaptor

 Title    : adaptor
 Usage    : $obj->adaptor([Bio::Cogemir::DBSQL::SeqAdaptor])
 Function : get/set method for attribute 
 Returns  : Bio::Cogemir::DBSQL::SeqAdaptor 
 Args     : new value of Bio::Cogemir::DBSQL::SeqAdaptor (optional)

=cut

sub adaptor{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 name

 Title    : name
 Usage    : $obj->name([$newval])
 Function : get/set method for attribute name  
 Returns  : value of seq name (string)
 Args     : new value of name (optional)

=cut

sub name {
    my ($self,$name)= @_;
    if (defined $name) {
	$self->{'name'} = $name;
    }
    return $self->{'name'};
}

=head2 sequence

 Title    : sequence
 Usage    : $obj->sequence([$newval])
 Function : get/set method for attribute sequence 
 Returns  : value of sequence string
 Args     : new value of sequence (optional)

=cut

sub sequence{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'sequence'} = $value;
    }
    return $self->{'sequence'};
}



=head2 logic_name

 Title    : logic_name
 Usage    : $obj->logic_name([Bio::Cogemir::Ontology])
 Function : get/set method for attribute logic_name
 Returns  : value of Bio::Cogemir::Ontology
 Args     : new value Bio::Cogemir::Ontology (optional)

=cut

sub logic_name{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'logic_name'} = $value;
    }
    return $self->{'logic_name'};
}

1;
