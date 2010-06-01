# Module for Bio::Cogemir::Intron
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 

Bio::GeneIntronDB::Intron

=head1 SYNOPSIS
	
	my $intron =  Bio::Cogemir::Intron->new(  
	                            -DBID                             => $dbID,
	                            -ADAPTOR                       => $adaptor,
							    -PART_OF                        => $part_of, 
							    -LENGTH                => $length,
							    -PRE_EXON                             => $pre_exon, 
							    -POST_EXON                             => $post_exon, 
							    -ATTRIBUTE => 300,
							    -SEQ          => 500
							    );

       $rank = $intron->rank();

=head1 

    This adaptor work with the intron table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Intron;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $intron =  Bio::Cogemir::Intron->new(   
							     -PART_OF                        => $part_of, 
							    -LENGTH                => $length,
							    -PRE_EXON                             => $pre_exon, 
							    -POST_EXON                             => $post_exon
							    -ATTRIBUTE => 300,
							    -SEQ          => 500
							     );

 Returns        : Bio::Cogemir::Intron
 Args           : Takes a set of rankd arguments
 Exceptions     : If the obj does not have query obj, rank obj, post_intron and 

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
          $adaptor,
          $part_of, 
          $length,
          $post_exon,
          $pre_exon,
          $attribute,
          $seq,
          $phase,
          $rank
          ) = $self->_rearrange([qw(
        DBID                          
        ADAPTOR                    
        PART_OF                      
        LENGTH              
        POST_EXON 
        PRE_EXON
        ATTRIBUTE
        SEQ
        PHASE
        RANK
		)], @args);
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$part_of && $self->part_of($part_of);
	$post_exon && $self->post_exon($post_exon);
    $pre_exon && $self->pre_exon($pre_exon);
	$length && $self->length($length);
    $self->attribute($attribute) if defined $attribute;
    $self->seq($seq) if defined $seq;
    $self->phase($phase) if defined $phase;
    $rank && $self->rank($rank);
 
	if(!$self->part_of ){
		$self->throw("The Intron does not have all attributes to be created I need part_of ");
	}

	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ([$newval])
 Function : get/set method for attribute dbID
 Returns  : Value of dbID (integer)
 Args     : New value of dbID (optional)
    
=cut


sub dbID {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'};
}

=head2 adaptor
    
 Title    : adaptor
 Usage    : $obj->adaptor ([Bio::MIRNABD::IntronAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::IntronAdaptor
 Args     : New value of Bio::MIRNABD::IntronAdaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 rank
    
 Title    : rank
 Usage    : $obj->rank ()
 Function : get/set method for attribute rank
 Returns  : Value of rank
 Args     : string
    
=cut


sub rank {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'rank'} = $value;
    }
    else{
    $self->{'rank'} = $self->pre_exon->rank if defined $self->pre_exon;
    }
    return $self->{'rank'};
}

=head2 part_of
    
 Title    : part_of
 Usage    : $obj->part_of (Bio::MIRNABD::Gene)
 Function : get/set method for attribute part_of
 Returns  : Value of Bio::MIRNABD::Gene
 Args     : New value of Bio::MIRNABD::Gene 
    
=cut


sub part_of {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'part_of'} = $value;
    }
    return $self->{'part_of'};
}

=head2 length
    
 Title    : length
 Usage    : $obj->length (25)
 Function : get/set method for attribute length
 Returns  : string
 Args     : string
    
=cut


sub length {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'length'} = $value;
    }
    return $self->{'length'};
}

=head2 post_exon
    
 Title    : post_exon
 Usage    : $obj->post_exon ($exon)
 Function : get/set method for attribute post_exon
 Returns  : string
 Args     : string
    
=cut


sub post_exon {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'post_exon'} = $value;
    }
    return $self->{'post_exon'};
}

=head2 pre_exon
    
 Title    : pre_exon
 Usage    : $obj->pre_exon ($exon)
 Function : get/set method for attribute pre_exon
 Returns  : string
 Args     : string
    
=cut


sub pre_exon {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'pre_exon'} = $value;
    }
    return $self->{'pre_exon'};
}


=head2 phase
    
 Title    : phase
 Usage    : $obj->phase (1e-4)
 Function : get/set method for attribute phase
 Returns  : 1 or 0
 Args     : 1 or 0
    
=cut


sub phase {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'phase'} = $value;
    }
    else{
    $self->pre_exon->phase;
    }
    return $self->{'phase'};
}

=head2 attribute
    
 Title    : attribute
 Usage    : $obj->attribute (300)
 Function : get/set method for attribute attribute
 Returns  : int
 Args     : int
    
=cut


sub attribute {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'attribute'} = $value;
    }
    return $self->{'attribute'};
}



sub start{
  my ($self) = @_;
  return $self->attribute->location->start;
}

sub end{
  my ($self) = @_;
  return $self->attribute->location->end;
}

1;
