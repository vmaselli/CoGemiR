=head1 NAME

Bio::Cogemir::SymatlasAnnotation

=head1 SYNOPSIS

	my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
							    -GENOME_DB => $genome_obj,
							    -NAME => $name,
							    -ACCESSION => $accession,
							    -PROBSET_ID => $probset_id,
							    -REPORTERS => $reporters,
							    -LOCUS_LINK => $locus_link,
							    -REF_SEQ => $refseq,
							    -UNIGENE => $unigene,
							    -UNIPROT => $uniprot,
							    -ENSEMBL_GENE => $ensembl_gene,
							    -ENSEMBL_TRANSCRIPT => $ensembl_transcript,
							    -ENSEMBL_TRANSLATION => $ensembl_translation,
							    -ALIASES => $aliases,
							    -DESCRIPTION => $description,
							    -FUNCTION => $function,
							    -PROTEIN_FAMILIES => $protein_families
							   );

	my $name = $symatlas_annotation->name;
	
=head1 DESCRIPTION

    This module work with the symatlas_annotation object 


=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::SymatlasAnnotation;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
							    -DBID                => $dbID,
							    -ADAPTOR             => $adaptor,
							    -GENOME_DB              => $genome_obj,
							    -NAME                => $name,
							    -ACCESSION           => $accession,
							    -PROBSET_ID          => $probset_id,
							    -REPORTERS           => $reporters,
							    -LOCATION            => $location_obj,
							    -LOCUS_LINK          => $locus_link,
							    -REF_SEQ             => $refseq,
							    -UNIGENE             => $unigene,
							    -UNIPROT             => $uniprot,
							    -ENSEMBL_GENE        => $ensembl_gene,
							    -ENSEMBL_TRANSCRIPT  => $ensembl_transcript,
							    -ENSEMBL_TRANSLATION => $ensembl_translation,
							    -ALIASES             => $aliases,
							    -DESCRIPTION         => $description,
							    -FUNCTION            => $function,
							    -PROTEIN_FAMILIES      => $protein_families
							   );
 Returns        : Bio::Cogemir::SymatlasAnnotation
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
        $adaptor,
        $genome_obj,
        $name,
        $accession,
        $probset_id,
        $reporters,
        $locus_link,
        $refseq,
        $unigene,
        $uniprot,
        $ensembl_gene,
        $ensembl_transcript,
        $ensembl_translation,
        $aliases,
        $description,
        $function,
        $protein_families
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		GENOME_DB             
        NAME               
        ACCESSION          
        PROBSET_ID         
        REPORTERS          
        LOCUS_LINK         
        REF_SEQ            
        UNIGENE            
        UNIPROT            
        ENSEMBL_GENE       
        ENSEMBL_TRANSCRIPT 
        ENSEMBL_TRANSLATION
        ALIASES            
        DESCRIPTION        
        FUNCTION           
        PROTEIN_FAMILIES     
		)],@args);
	
	$dbID                && $self->dbID($dbID); 
	$adaptor             && $self->adaptor($adaptor);
	$genome_obj          && $self->genome_db($genome_obj);         
    $name                && $self->name($name);
    $accession           && $self->accession($accession);
    $probset_id          && $self->probset_id($probset_id);
    $reporters           && $self->reporters($reporters);
    $locus_link          && $self->locus_link($locus_link);
    $refseq              && $self->refseq($refseq);
    $unigene             && $self->unigene($unigene);
    $uniprot             && $self->uniprot($uniprot);
    $ensembl_gene        && $self->ensembl_gene($ensembl_gene);
    $ensembl_transcript  && $self->ensembl_transcript($ensembl_transcript);
    $ensembl_translation && $self->ensembl_translation($ensembl_translation);
    $aliases             && $self->aliases($aliases);
    $description         && $self->description($description);
    $function            && $self->function($function);
    $protein_families    && $self->protein_families($protein_families);   
    
    unless (defined $genome_obj){
		$self->throw("The SymatlasAnnotation does not have all attribute to be created: I need a genome");
	}
	  
	  unless (defined $ensembl_gene){
		$self->throw("The SymatlasAnnotation does not have all attribute to be created: I need a ensembl");
	}
	return $self;
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Function : get/set method for attribute dbID
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
 Function : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor
 Args     : New value of adaptor (optional)
    
=cut

sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 genome
    
 Title    : genome
 Usage    : $obj->genome ($newval)
 Function : get/set method for attribute genome
 Returns  : Bio::Cogemir::GenomeDB
 Args     : New value of genome (optional)
    
=cut

sub genome_db         {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'genome_db'} = $value;
    }
    return $self->{'genome_db'};
}
 
=head2 name
    
 Title    : name
 Usage    : $obj->name ($newval)
 Function : get/set method for attribute name
 Returns  : string
 Args     : New value of name (optional)
    
=cut

sub name               {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'name'} = $value;
    }
    return $self->{'name'};
}
 
=head2 accession
    
 Title    : accession
 Usage    : $obj->accession ($newval)
 Function : get/set method for attribute accession
 Returns  : string
 Args     : New value of accession (optional)
    
=cut

sub accession          {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'accession'} = $value;
    }
    return $self->{'accession'};
}
 
=head2 probset_id
    
 Title    : probset_id
 Usage    : $obj->probset_id ($newval)
 Function : get/set method for attribute probset_id
 Returns  : string
 Args     : New value of probset_id (optional)
    
=cut

sub probset_id         {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'probset_id'} = $value;
    }
    return $self->{'probset_id'};
}
 
=head2 reporters
    
 Title    : reporters
 Usage    : $obj->reporters ($newval)
 Function : get/set method for attribute reporters
 Returns  : string
 Args     : New value of reporters (optional)
    
=cut

sub reporters          {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'reporters'} = $value;
    }
    return $self->{'reporters'};
}
 
=head2 location
    
 Title    : location
 Usage    : $obj->location ($newval)
 Function : get/set method for attribute location
 Returns  : Bio::Cogemir::Location
 Args     : New value of location (optional)
    
=cut

sub location       {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'location'} = $value;
    }
    return $self->{'location'};
}
 
=head2 locus_link
    
 Title    : locus_link
 Usage    : $obj->locus_link ($newval)
 Function : get/set method for attribute locus_link
 Returns  : string
 Args     : New value of locus_link (optional)
    
=cut

sub locus_link         {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'locus_link'} = $value;
    }
    return $self->{'locus_link'};
}
 
=head2 refseq
    
 Title    : refseq
 Usage    : $obj->refseq ($newval)
 Function : get/set method for attribute refseq
 Returns  : string
 Args     : New value of refseq (optional)
    
=cut  

sub refseq             {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'refseq'} = $value;
    }
    return $self->{'refseq'};
}
 
=head2 unigene
    
 Title    : unigene
 Usage    : $obj->unigene ($newval)
 Function : get/set method for attribute unigene
 Returns  : string
 Args     : New value of unigene (optional)
    
=cut

sub unigene            {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'unigene'} = $value;
    }
    return $self->{'unigene'};
}
 
=head2 uniprot
    
 Title    : uniprot
 Usage    : $obj->uniprot ($newval)
 Function : get/set method for attribute uniprot
 Returns  : string
 Args     : New value of uniprot (optional)
    
=cut

sub uniprot            {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'uniprot'} = $value;
    }
    return $self->{'uniprot'};
}
 
=head2 ensembl_gene
    
 Title    : ensembl_gene
 Usage    : $obj->ensembl_gene ($newval)
 Function : get/set method for attribute ensembl_gene
 Returns  : string
 Args     : New value of ensembl_gene (optional)
    
=cut

sub ensembl_gene       {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'ensembl_gene'} = $value;
    }
    return $self->{'ensembl_gene'};
}
 
=head2 ensembl_transcript
    
 Title    : ensembl_transcript
 Usage    : $obj->ensembl_transcript ($newval)
 Function : get/set method for attribute ensembl_transcript
 Returns  : string
 Args     : New value of ensembl_transcript (optional)
    
=cut

sub ensembl_transcript {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'ensembl_transcript'} = $value;
    }
    return $self->{'ensembl_transcript'};
}
 
=head2 ensembl_translation
    
 Title    : ensembl_translation
 Usage    : $obj->ensembl_translation ($newval)
 Function : get/set method for attribute ensembl_translation
 Returns  : string
 Args     : New value of ensembl_translation (optional)
    
=cut

sub ensembl_translation{
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'ensembl_translation'} = $value;
    }
    return $self->{'ensembl_translation'};
}
 
=head2 aliases
    
 Title    : aliases
 Usage    : $obj->aliases ($newval)
 Function : get/set method for attribute aliases
 Returns  : string
 Args     : New value of aliases (optional)
    
=cut

sub aliases            {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'aliases'} = $value;
    }
    return $self->{'aliases'};
}
 
=head2 aliases
    
 Title    : aliases
 Usage    : $obj->aliases ($newval)
 Function : get/set method for attribute aliases
 Returns  : string
 Args     : New value of aliases (optional)
    
=cut
sub description        {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'description'} = $value;
    }
    return $self->{'description'};
}
 
=head2 function
    
 Title    : function
 Usage    : $obj->function ($newval)
 Function : get/set method for attribute function
 Returns  : string
 Args     : New value of function (optional)
    
=cut

sub function           {
    my ($self,$value) = @_;
    if (defined $value) {
	    $self->{'function'} = $value;
    }
    return $self->{'function'};
}
 
=head2 protein_families
    
 Title    : protein_families
 Usage    : $obj->protein_families ($newval)
 Function : get/set method for attribute protein_families
 Returns  : string
 Args     : New value of protein_families (optional)
    
=cut

sub protein_families {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'protein_families'} = $value;
    }
    return $self->{'protein_families'};
} 

sub average{
  my ($self,$value) = @_;
  if (defined $value) {
	  $self->{'average'} = $value;
  }
  else{
    $self->{'average'} = $self->adaptor->get_average($self->dbID);
  }
  return $self->{'average'};
}

sub standard_deviation{
  my ($self,$value) = @_;
  if (defined $value) {
	    $self->{'standard_deviation'} = $value;
    }
  else{
    $self->{'standard_deviation'} = $self->adaptor->get_standard_deviation($self->dbID);
  }
  return $self->{'standard_deviation'};
}

1;
