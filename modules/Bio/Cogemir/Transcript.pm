#
# Module for Bio::Cogemir::Transcript
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 STABLE_ID

Bio::GeneTranscriptDB::Transcript

=head1 SYNOPSIS

	  
    my ($transcript) =  Bio::Cogemir::Transcript->new(   
							    -STABLE_ID => $stable_id,
							    -PART_OF =>$gene
							   );

    $stable_id = $transcript->stable_id();

=head1 DESCRIPTION

    This adaptor work with the transcript table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Transcript;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my ($transcript) =  Bio::Cogemir::Transcript->new(   
							    -STABLE_ID => $stable_id,
							    -PART_OF =>$gene
							   );
 Returns        : Bio::Cogemir::Transcript
 Args           : Takes a set of stable_idd arguments
 Exceptions     : If the obj does not have stable_id

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$gene,
		$all_introns,
		$all_exons,
		$attribute
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		PART_OF
		ALL_INTRONS
		ALL_EXONS
		ATTRIBUTE
		)], @args);

	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$attribute && $self->attribute($attribute);
  $gene && $self->part_of($gene);
  $all_introns && $self->all_introns($all_introns);
  $all_exons && $self->all_exons($all_exons);
	# we must have a gene and stable_id 
    if (! ($self->attribute) ) {
	$self->throw("The Transcript does not have all attributes to be created: I need a attribute");
    }
     

	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Transcript : get/set method for attribute dbID
 Returns  : Value of dbID
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
 Usage    : $obj->adaptor ($newval)
 Transcript : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::TranscriptAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}



=head2 attribute
    
 Title    : attribute
 Usage    : $obj->attribute ($newval)
 Transcript : get/set method for attribute attribute
 Returns  : Value of attribute (string)
 Args     : New value of attribute (optional)
    
=cut


sub attribute {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'attribute'} = $value;
    }
    return $self->{'attribute'};
}

=head2 stable_id
    
 Title    : stable_id
 Usage    : $obj->stable_id ($newval)
 Transcript : get/set method for attribute stable_id
 Returns  : Value of stable_id (string)
 Args     : New value of stable_id (optional)
    
=cut


sub stable_id {
    my ($self,$value) = @_;
    if (defined $value) {
	    $self->{'stable_id'} = $value;
    }
    else{
      $self->{'stable_id'} = $self->attribute->stable_id;
    }
    return $self->{'stable_id'}  ;
}

=head2 end
    
 Title    : end
 Usage    : $obj->end ($newval)
 Transcript : get/set method for attribute end
 Returns  : Value of end (string)
 Args     : New value of end (optional)
    
=cut


sub end {
    my ($self,$value) = @_;
    if (defined $value) {
	    $self->{'end'} = $value;
    }
    else{
      $self->{'end'} = $self->attribute->location->end
    }
    return $self->{'end'};
}

=head2 strand
    
 Title    : strand
 Usage    : $obj->strand ($newval)
 Transcript : get/set method for attribute strand
 Returns  : Value of strand (string)
 Args     : New value of strand (optional)
    
=cut


sub strand {
    my ($self,$value) = @_;
    if (defined $value) {
	    $self->{'strand'} = $value;
    }
    else{
      $self->{'strand'} = $self->attribute->location->strand;
    }
    return $self->{'strand'};
}

=head2 attribute_name
    
 Title    : attribute_name
 Usage    : $obj->attribute_name ($newval)
 Transcript : get/set method for attribute attribute_name
 Returns  : Value of attribute_name (string)
 Args     : New value of attribute_name (optional)
    
=cut


sub location_name {
    my ($self,$value) = @_;
    if (defined $value) {
	 $self->{'attribute_name'} = $value;
    }
    return $self->attribute->attribute->location->name;
}

=head2 part_of
    
 Title    : part_of
 Usage    : $obj->part_of ($newval)
 Transcript : get/set method for attribute part_of
 Returns  : Value of part_of (string)
 Args     : New value of part_of (optional)
    
=cut


sub part_of {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'part_of'} = $value;
    }
    return $self->{'part_of'};
}

=head2 All_exons
    
 Title    : All_exons
 Usage    : $obj->All_exons ($newval)
 Transcript : get/set method for attribute All_exons
 Returns  : Value of All_exons (string)
 Args     : New value of All_exons (optional)
    
=cut

sub All_exons{
    my ($self,$value) = @_;
    if (defined $value) {
		$self->{'All_exons'} = $value;
    }
    else{
    	$self->{'All_exons'} = $self->adaptor->get_all_exons($self->dbID)
    }
    #print ref $self, " line 298 ",Dumper $self->{'All_exons'};
    return $self->{'All_exons'};
}
    
  

=head2 All_introns
    
 Title    : All_introns
 Usage    : $obj->All_introns ($newval)
 Transcript : get/set method for attribute All_introns
 Returns  : Value of All_introns (string)
 Args     : New value of All_introns (optional)
    
=cut

sub All_introns{
      my ($self,$value) = @_;
    if (defined $value) {
		$self->{'All_introns'} = $value;
    }
    else{
    	$self->{'All_introns'} = $self->adaptor->get_all_introns($self->dbID)
    }
    return $self->{'All_introns'};
}


1;
