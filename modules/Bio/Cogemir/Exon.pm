# Module for Bio::Cogemir::Exon
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 RANK

Bio::GeneExonDB::Exon

=head1 SYNOPSIS
	
	my $exon =  Bio::Cogemir::Exon->new(  
                  -DBID      => $dbID,
                  -ADAPTOR   => $adaptor,
							    -PART_OF   => $part_of, 
							    -RANK  => $rank, 
							    -LENGTH => $length,
							    -PHASE   => 1,
							    -ATTRIBUTE   => $attribute,
							    -PREOST_INTRON  => $post_intron, 
							    -PRE_INTRON   => $pre_intron, post_intron, post_intron, 
							    );

       $rank = $exon->rank();

=head1 LENGTH

    This adaptor work with the exon table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Exon;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $exon =  Bio::Cogemir::Exon->new(   
							     -PART_OF   => $part_of, 
							    -RANK  => $rank, 
							    -LENGTH => $length,
							    -PHASE   => 1,
							    -ATTRIBUTE   => $attribute,
							    -PREOST_INTRON  => $post_intron, 
							    -PRE_INTRON   => $pre_intron, post_intron, post_intron, 
							     );

 Returns        : Bio::Cogemir::Exon
 Args           : Takes a set of rankd arguments
 Exceptions     : If the obj does not have query obj, rank obj, pre_intron and 

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
          $adaptor,
          $part_of, 
          $rank, 
          $length,
          $phase,
          $attribute,
          $pre_intron,
          $post_intron,
          $type
          ) = $self->_rearrange([qw(
        DBID                          
        ADAPTOR                    
        PART_OF                      
        RANK                          
        LENGTH              
        PHASE                    
        ATTRIBUTE                          
        PRE_INTRON 
        POST_INTRON
        TYPE
		)], @args);
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$part_of && $self->part_of($part_of);
	$rank && $self->rank($rank);
	$pre_intron && $self->pre_intron($pre_intron);
	$post_intron && $self->post_intron($post_intron);
	$length && $self->length($length);
  $self->phase($phase) if defined $phase;
  $attribute && $self->attribute($attribute);
  $type && $self->type($type);
  #print "==> ID $dbID PART OF ".$part_of->dbID." RANK $rank LEN $length PHASE $phase ATTRIBUTE ".$attribute->dbID." TYPE $type\n";    
	if(!$self->part_of ){
		$self->throw("The Exon does not have all attributes to be created I need part_of ");
	}
	elsif(! $self->rank ){
		$self->throw("The Exon does not have all attributes to be created I need rank ");
	}
  elsif(! $self->length ){
		$self->throw("The Exon does not have all attributes to be created I need length ");
	}
	elsif(! $self->type){
		#$self->throw("The Exon does not have all attributes to be created I need type ");
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
 Usage    : $obj->adaptor ([Bio::MIRNABD::ExonAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::ExonAdaptor
 Args     : New value of Bio::MIRNABD::ExonAdaptor (optional)
    
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

=head2 pre_intron
    
 Title    : pre_intron
 Usage    : $obj->pre_intron ($intron)
 Function : get/set method for attribute pre_intron
 Returns  : string
 Args     : string
    
=cut


sub pre_intron {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'pre_intron'} = $value;
    }
    return $self->{'pre_intron'};
}

=head2 post_intron
    
 Title    : post_intron
 Usage    : $obj->post_intron ($intron)
 Function : get/set method for attribute post_intron
 Returns  : string
 Args     : string
    
=cut


sub post_intron {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'post_intron'} = $value;
    }
    return $self->{'post_intron'};
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
    return $self->{'phase'};
}

=head2 type
    
 Title    : type
 Usage    : $obj->type (1e-4)
 Function : get/set method for attribute type
 Returns  : 1 or 0
 Args     : 1 or 0
    
=cut


sub type {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'type'} = $value;
    }
    return $self->{'type'};
}

=head2 attribute
    
 Title    : attribute
 Usage    : $obj->attribute (0)
 Function : get/set method for attribute attribute
 Returns  : string
 Args     : string
    
=cut


sub attribute {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'attribute'} = $value;
    }
    return $self->{'attribute'};
}



sub position_relative_to_mirna {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'position_relative_to_mirna'} = $value;
    }
    return $self->{'position_relative_to_mirna'};
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
