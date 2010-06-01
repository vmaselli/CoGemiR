#
# Module for Bio::Cogemir::Localization
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Localization

=head1 SYNOPSIS

	my ($localization) =  Bio::Cogemir::Localization->new(   
							    -LABEL => $label,  
							    -MODULE_RANK => $module_rank, 
							    -OFFSET => $offset,
							    -TRANSCRIPT =>$transcript,
							    -MICRO_RNA => $micro_rna
							   );
    
    $module_rank = $localization->label();

=head1 DESCRIPTION

  module for localization obj, from localization table, localization is a subclass of gene region  

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Localization;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use Data::Dumper;

@ISA = qw(Bio::Root::Root);
my %term = ('intron' => 1,'exon' => 1,'exon_left' => 1,'exon_right' => 1,'over exon' => 1,'out of transcript' => 1,'intergenic' => 1,'UTR' => 1,'UTR_left' => 1,'UTR_right' => 1,'over UTR' => 1);
#constructor
=head2 new

 Title          : new
 Usage          : my ($localization) =  Bio::Cogemir::Localization->new(   
							    -LABEL => $label,  
							    -MODULE_RANK => $module_rank, 
							    -OFFSET => $offset,
							    -TRANSCRIPT =>$transcript,
							    -MICRO_RNA => $micro_rna
							   );
 Returns        : Bio::Cogemir::Localization
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have gene name, genome_id and seq

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my (	$dbID,
		$adaptor,
		$label,
		$module_rank,
		$offset,
		$transcript,
		$micro_rna) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		LABEL
		MODULE_RANK
		OFFSET
		TRANSCRIPT
		MICRO_RNA
		)], @args);
	
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$label && $self->label($label);
	$module_rank && $self->module_rank($module_rank);
	$offset && $self->offset($offset);
	$transcript && $self->transcript($transcript);
	$micro_rna && $self->micro_rna($micro_rna);
	
	if (! $self->micro_rna){
	$self->throw("The Localization does not have all attributes to be created: I need micro_rna ");
    }
    if (! $self->label){
	$self->throw("The Localization does not have all attributes to be created: I need label ");
    }
    if ($self->label && !$term{$self->label}){
        $self->throw("The Localization label does not match: check ".$self->label);
    }
	return $self;
	
}

=head2 dbID
 
 Title    : dbID
 Usage    : $obj->dbID([$newval])
 Function : get/set method for attribute dbID
 Returns  : Value of dbID (integer)
 Args     : New value of dbID (optional)

=cut

sub dbID {
    my ($self, $value) = @_;
    if (defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'}
}

=head2 adaptor

 Title    : adaptor 
 Usage    : $obj->adaptor([$newval])
 Function : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::LocalizationAdaptor
 Args     : Bio::Cogemir::LocalizationAdaptor

=cut

sub adaptor {
    my ($self, $value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'}
}

=head2 label
    
 Title    : label
 Usage    : $obj->label ([$newval])
 Function : get/set method for attribute label
 Returns  : Value of label (string)
 Args     : New value of label (optional)
    
=cut


sub label {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'label'} = $value;
    }
    return $self->{'label'};
}


=head2 module_rank
    
 Title    : module_rank
 Usage    : $obj->module_rank ([$newval])
 Function : get/set method for attribute module_rank
 Returns  : Value of ensembl module_rank (string)
 Args     : New value of module_rank (optional)
    
=cut


sub module_rank {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'module_rank'} = $value;
    }
    return $self->{'module_rank'};
}


=head2 offset
    
 Title    : offset
 Usage    : $obj->offset ([$newval])
 Function : get/set method for attribute offset
 Returns  : Value of offset of the gene (string)
 Args     : New value of offset (optional)
    
=cut


sub offset {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'offset'} = $value;
    }
    return $self->{'offset'};
}


=head2 transcript
    
 Title    : transcript
 Usage    : $obj->transcript ([$newval])
 Function : get/set method for attribute transcript
 Returns  : Value of transcript (string)
 Args     : New value of transcript (optional)
    
=cut


sub transcript {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'transcript'} = $value;
    }
    return $self->{'transcript'};
}



=head2 micro_rna
    
 Title    : micro_rna_obj
 Usage    : $obj->micro_rna_obj ([$newval])
 Function : get/set method for attribute micro_rna
 Returns  : Bio::Cogemir::GenomeDB
 Args     : New value of micro_rna (optional)
    
=cut


sub micro_rna {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'micro_rna'} = $value;
    }
    return $self->{'micro_rna'};
}

1;
