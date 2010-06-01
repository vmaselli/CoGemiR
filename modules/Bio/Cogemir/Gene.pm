#
# Module for Bio::Cogemir::Gene
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Gene

=head1 SYNOPSIS

	my $gene =  Bio::Cogemir::Gene->new(   
							    -MEMBER => $attribute_obj,
							    -LOCATION => $location_obj,
							    -ATTRIBUTE => $attribute_obj,
							    -BIOTYPE => $biotype,
							    -LABEL => $label,
							    -CONSERVATION_SCORE => $conservation_score,
							    -DIRECTION => $direction
							   );

	my $conservation_score = $gene->conservation_score;
	
=head1 DESCRIPTION

    This module work with the gene object 


=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Gene;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);




#constructor
=head2 new

 Title          : new
 Usage          : my $gene =  Bio::Cogemir::Gene->new(   
							    -DBID                => $dbID,
							    -ADAPTOR             => $adaptor,
							    -ATTRIBUTE          => $attribute_obj,
							    -BIOTYPE => $biotype,
							    -LABEL            => $label,
							    -CONSERVATION_SCORE              => $conservation_score,
							    -DIRECTION => $direction
							   );
 Returns        : Bio::Cogemir::Gene
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	#print "G NEW\n";
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$attribute_obj,
		$biotype,
		$label,
		$conservation_score,
		$direction
		) = $self->_rearrange([qw(
		DBID               
		ADAPTOR            
		ATTRIBUTE
		BIOTYPE
		LABEL           
		CONSERVATION_SCORE
		DIRECTION
		)],@args);
	#print "DBID $dbID <br>\n";
	$dbID && $self->dbID($dbID); 
	$adaptor && $self->adaptor($adaptor);
	$attribute_obj && $self->attribute($attribute_obj);
	$biotype && $self->biotype($biotype);
	$label && $self->label($label);
	$conservation_score && $self->conservation_score($conservation_score);
	$direction && $self->direction($direction);
	
	
	#print "DIRECTION $direction ", ref $self," line 103\n<br>";
	unless (defined $direction){
		$self->throw("The Gene does not have all genes to be created: I need direction<br>\n");
	}
	unless (defined $attribute_obj){
		$self->throw("The Gene does not have all genes to be created: I need attribute<br>\n");
	}
	return $self;
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Function : get/set method for gene dbID
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
 Function : get/set method for gene adaptor
 Returns  : Bio::Cogemir::DBSQL::GeneAdaptor
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
 Function : get/set method for gene attribute
 Returns  : Value of attribute
 Args     : New value of nexons (optional)
    
=cut


sub attribute {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'attribute'} = $value;
    }
    return $self->{'attribute'};
}

=head2 direction
    
 Title    : direction
 Usage    : $obj->direction ($newval)
 Function : get/set method for gene direction
 Returns  : Value of direction
 Args     : New value of nexons (optional)
    
=cut


sub direction {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'direction'} = $value;
    }
    #print ref $self, " direction line 187 ", Dumper $self->{'direction'};
    return $self->{'direction'};
}


=head2 biotype
    
 Title    : biotype
 Usage    : $obj->biotype ($newval)
 Function : get/set method for gene biotype
 Returns  : Value of biotype
 Args     : New value of biotype (optional)
    
=cut


sub biotype {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'biotype'} = $value;
    }
    return $self->{'biotype'};
}

=head2 label
    
 Title    : label
 Usage    : $obj->label ($newval)
 Function : get/set method for gene label
 Returns  : Value of label
 Args     : New value of label (optional)
    
=cut


sub label {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'label'} = $value;
    }
    return $self->{'label'};
}

=head2 mirnas
    
 Title    : mirnas
 Usage    : $obj->micro_rna ($newval)
 Function : get/set method for gene micro_rna
 Returns  : Value of micro_rna
 Args     : New value of micro_rna (optional)
    
=cut


sub mirnas {
    my ($self,$value) = @_;
    if (defined $value) {
		$self->{'mirnas'} = $value;
    }
    else{
    	$self->{'mirnas'} = $self->adaptor->get_all_MicroRNAs($self->dbID);
    }
    return $self->{'mirnas'};
}


=head2 transcripts
    
 Title    : transcripts
 Usage    : $obj->micro_rna ($newval)
 Function : get/set method for gene micro_rna
 Returns  : Value of micro_rna
 Args     : New value of micro_rna (optional)
    
=cut


sub transcripts {
    my ($self,$value) = @_;
    if (defined $value) {
		$self->{'transcripts'} = $value;
    }
    else{
    	$self->{'transcripts'} = $self->adaptor->get_all_Transcripts($self->dbID);
    }
    return $self->{'transcripts'};
}


=head2 conservation_score
    
 Title    : conservation_score
 Usage    : $obj->conservation_score ($newval)
 Function : get/set method for gene conservation_score
 Returns  : Value of conservation_score
 Args     : New value of conservation_score (optional)
    
=cut


sub conservation_score {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'conservation_score'} = $value;
    }
    return $self->{'conservation_score'};
}


=head2 dbh
    
 Title    : dbh
 Usage    : $obj->dbh ($newval)
 Function : get/set method for micro_rna dbh
 Returns  : Value of dbh
 Args     : New value of dbh (optional)
    
=cut


sub db {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db'} = $value;
    }
    else{
    $self->{'db'} = $self->attribute->genome_db;
    }
    return $self->{'db'};
}

=head2 organism
    
 Title    : organism
 Usage    : $obj->organism ($newval)
 Function : get/set method for micro_rna organism
 Returns  : Value of organism
 Args     : New value of organism (optional)
    
=cut


sub organism {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'organism'} = $value;
    }
    else{
    $self->{'organism'} = $self->attribute->genome_db->organism;
    }
    return $self->{'organism'};
}


=head2 stable_id
    
 Title    : stable_id
 Usage    : $obj->stable_id ($newval)
 Function : get/set method for micro_rna stable_id
 Returns  : Value of stable_id
 Args     : New value of stable_id (optional)
    
=cut


sub stable_id {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'stable_id'} = $value;
    }
    else{
    $self->{'stable_id'} = $self->attribute->stable_id if $self->attribute;
    }
    return $self->{'stable_id'};
}

=head2 gene_name
    
 Title    : gene_name
 Usage    : $obj->gene_name ($newval)
 Function : get/set method for micro_rna gene_name
 Returns  : Value of gene_name
 Args     : New value of gene_name (optional)
    
=cut


sub gene_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'gene_name'} = $value;
    }
    else{
    $self->{'gene_name'} = $self->attribute->gene_name if $self->attribute;
    }
    return $self->{'gene_name'};
}





=head2 mirna_name
    
 Title    : mirna_name
 Usage    : $obj->mirna_name ($newval)
 Function : get/set method for micro_rna mirna_name
 Returns  : Value of mirna_name
 Args     : New value of mirna_name (optional)
    
=cut


sub mirna_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'mirna_name'} = $value;
    }
    else{
    $self->{'mirna_name'} = $self->attribute->mirna_name->name;
    }
    return $self->{'mirna_name'};
}


=head2 status
    
 Title    : status
 Usage    : $obj->status ($newval)
 Function : get/set method for micro_rna status
 Returns  : Value of status
 Args     : New value of status (optional)
    
=cut


sub status {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'status'} = $value;
    }
    else{
    $self->{'status'} = $self->attribute->status;
    }
    return $self->{'status'};
}
sub symatlas {
	my ($self) = @_;
	my $sym_array = $self->adaptor->get_all_symatlas_annotation($self->dbID);
	return $self->{'symatlas'} = $sym_array;
	
}
=head2 refseqref
    
 Title    : refseqref
 Usage    : $obj->refseqref ($newval)
 Function : get/set method for micro_rna refseqref
 Returns  : Value of refseqref
 Args     : New value of refseqref (optional)
    
=cut


sub refseqref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'refseqref'} = $value;
    }
    else{
    $self->{'refseqref'} = $self->attribute->refseqref;
    }
    return $self->{'refseqref'};
}

=head2 ensref
    
 Title    : ensref
 Usage    : $obj->ensref ($newval)
 Function : get/set method for micro_rna ensref
 Returns  : Value of ensref
 Args     : New value of ensref (optional)
    
=cut


sub ensref {
    my ($self,$value) = @_;
    if (defined $value) {
	  $self->{'ensref'} = $value;
    }
    else{
   $self->{'ensref'} = $self->attribute->ensref;
    }
    return $self->{'ensref'};
}

=head2 enscontigref
    
 Title    : enscontigref
 Usage    : $obj->enscontigref ($newval)
 Function : get/set method for micro_rna enscontigref
 Returns  : Value of enscontigref
 Args     : New value of enscontigref (optional)
    
=cut


sub enscontigref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'enscontigref'} = $value;
    }
    else{
     $self->{'enscontigref'} = $self->attribute->enscontigref;
    }
    return $self->{'enscontigref'};
}

=head2 symatlasref
    
 Title    : symatlasref
 Usage    : $obj->symatlasref ($newval)
 Function : get/set method for micro_rna symatlasref
 Returns  : Value of symatlasref
 Args     : New value of symatlasref (optional)
    
=cut


sub symatlasref {
  my ($self,$value) = @_;
  if (defined $value) {
    $self->{'symatlasref'} = $value;
  }
  else{
    $self->{'symatlasref'} = $self->attribute->symatlasref;
  }
  return $self->{'symatlasref'};
}

sub ucscref {
  my ($self,$value) = @_;
  if (defined $value) {
	$self->{'ucscref'} = $value;
    }
  else{$self->{'ucscref'} = $self->attribute->ucscref;  
  }
  return $self->{'ucscref'};
}

sub feature {
  my ($self,$value) = @_;
  
  if ($value){
  	$self->{'feature'} = $value;
  }
  else{
    my $feat = $self->adaptor->get_all_Features($self->dbID);
    $self->{'feature'} = $feat;
  }
  
  return $self->{'feature'};
}  


1;
