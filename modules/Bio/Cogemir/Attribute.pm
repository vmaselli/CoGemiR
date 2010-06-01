#
# Module for Bio::Cogemir::Attribute
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Attribute

=head1 SYNOPSIS

	my $attribute =  Bio::Cogemir::Attribute->new(   
							    -GENOME_DB => $genome_obj,
							    -SEQ => $seq_obj,
							    -MIRNA_NAME => $mirna_name_obj,
							    -SYMATLAS_ANNOTATION => $sym_obj,
							    -ANALYSIS => $analysis_obj,
							    -STATUS => $status,
							    -GENE_NAME => $gene_name,  
							    -STABLE_ID => $stable_id, 
							    -EXTERNAL_NAME => $external_name,
							    -DB_LINK =>'RefSeq',
							    -DB_ACCESSION => 'NM_XXYYZZ',
							    -ALIASES => $aliases_obj
							   );

	my $status = $attribute->status;
	
=head1 DESCRIPTION

    This module work with the attribute object 


=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Attribute;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $attribute =  Bio::Cogemir::Attribute->new(   
							    -DBID                => $dbID,
							    -ADAPTOR             => $adaptor,
							    -GENOME_DB              => $genome_obj,
							    -SEQ                 => $seq_obj,
							    -MIRNA_NAME          => $mirna_name_obj,
							    -SYMATLAS_ANNOTATION => $sym_obj,
							    -ANALYSIS            => $analysis_obj,
							    -STATUS              => $status,
							    -GENE_NAME => $gene_name,  
							    -STABLE_ID => $stable_id, 
							    -EXTERNAL_NAME => $external_name,
							    -DB_LINK =>'RefSeq',
							    -DB_ACCESSION => 'NM_XXYYZZ',
							    -ALIASES => $aliases_obj
							   );
 Returns        : Bio::Cogemir::Attribute
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$genome_obj,
		$seq_obj,
		$mirna_name_obj,
		$analysis_obj,
		$location_obj,
		$status,
		$gene_name,
		$stable_id,
		$external_name,
		$db_link,
		$db_accession,
		$aliases
		) = $self->_rearrange([qw(
		DBID               
		ADAPTOR            
		GENOME_DB             
		SEQ                
		MIRNA_NAME         
		ANALYSIS
		LOCATION
		STATUS
		GENE_NAME
		STABLE_ID
		EXTERNAL_NAME
		DB_LINK
		DB_ACCESSION
		ALIASES
		)],@args);
	
	$dbID && $self->dbID($dbID); 
	$adaptor && $self->adaptor($adaptor);
	$genome_obj && $self->genome_db($genome_obj);
	$seq_obj && $self->seq($seq_obj);
	$location_obj && $self->location($location_obj);
	$mirna_name_obj && $self->mirna_name($mirna_name_obj);
	$analysis_obj && $self->analysis($analysis_obj);
	$status && $self->status($status);
	$gene_name && $self->gene_name($gene_name);
	$stable_id && $self->stable_id($stable_id);
	$external_name && $self->external_name($external_name);
	$db_link && $self->db_link($db_link);
	$db_accession && $self->db_accession($db_accession);
	$aliases && $self->aliases($aliases);
	
	
	if (! $self->seq){
	#$self->warn("The Attribute does not have all attributes : I miss seq ");
    }
	if (! $self->location){
	#$self->throw("The Attribute does not have all attributes : I need location ");
    }
	if (! $self->gene_name){
	$self->throw("The Attribute does not have all attributes to be created: I need gene name ");
    }
	unless (defined $genome_obj){
		$self->throw("The Attribute does not have all attributes to be created: I need a genome_db");
	}

	unless (defined $mirna_name_obj){
		$self->throw("The Attribute does not have all attributes to be created: I need a mirna_name");
	}
	unless (defined $status){
		$self->throw("The Attribute does not have all attributes to be created: I need a status");
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
 Returns  : Bio::Cogemir::DBSQL::AttributeAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}


=head2 genome_db
    
 Title    : genome_db
 Usage    : $obj->genome_db ($newval)
 Function : get/set method for attribute genome_db
 Returns  : Value of genome_db
 Args     : New value of genome_db (optional)
    
=cut


sub genome_db {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'genome_db'} = $value;
    }
    return $self->{'genome_db'};
}

=head2 seq
    
 Title    : seq
 Usage    : $obj->seq ($newval)
 Function : get/set method for attribute seq
 Returns  : Value of seq
 Args     : New value of seq (optional)
    
=cut


sub seq {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'seq'} = $value;
    }
    return $self->{'seq'};
}


=head2 mirna_name
    
 Title    : mirna_name
 Usage    : $obj->mirna_name ($newval)
 Function : get/set method for attribute mirna_name
 Returns  : Value of mirna_name
 Args     : New value of nexons (optional)
    
=cut


sub mirna_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'mirna_name'} = $value;
    }
    return $self->{'mirna_name'};
}



=head2 analysis
    
 Title    : analysis
 Usage    : $obj->analysis ($newval)
 Function : get/set method for attribute analysis
 Returns  : Value of analysis
 Args     : New value of analysis (optional)
    
=cut


sub analysis {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'analysis'} = $value;
    }
    return $self->{'analysis'};
}

=head2 status
    
 Title    : status
 Usage    : $obj->status ($newval)
 Function : get/set method for attribute status
 Returns  : Value of status
 Args     : New value of status (optional)
    
=cut


sub status {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'status'} = $value;
    }
    return $self->{'status'};
}

=head2 location
    
 Title    : location
 Usage    : $obj->location ($newval)
 Function : get/set method for attribute location
 Returns  : Value of location
 Args     : New value of location (optional)
    
=cut


sub location {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'location'} = $value;
    }
    return $self->{'location'};
}

=head2 gene_name
    
 Title    : gene_name
 Usage    : $obj->gene_name ([$newval])
 Function : get/set method for attribute gene_name
 Returns  : Value of gene_name (string)
 Args     : New value of gene_name (optional)
    
=cut


sub gene_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'gene_name'} = $value;
    }
    return $self->{'gene_name'};
}


=head2 stable_id
    
 Title    : stable_id
 Usage    : $obj->stable_id ([$newval])
 Function : get/set method for attribute stable_id
 Returns  : Value of ensembl stable_id (string)
 Args     : New value of stable_id (optional)
    
=cut


sub stable_id {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'stable_id'} = $value;
    }
    return $self->{'stable_id'};
}


=head2 external_name
    
 Title    : external_name
 Usage    : $obj->external_name ([$newval])
 Function : get/set method for attribute external_name
 Returns  : Value of external_name of the gene (string)
 Args     : New value of external_name (optional)
    
=cut


sub external_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'external_name'} = $value;
    }
    return $self->{'external_name'};
}

sub microrna {
my ($self,$value) = @_;
    if (defined $value) {$self->{'microrna'} = $value;}
    else {$self->{'microrna'} = $self->adaptor->get_microrna($self->dbID);}
    return $self->{'microrna'};


}

=head2 db_link
    
 Title    : db_link
 Usage    : $obj->db_link ([$newval])
 Function : get/set method for attribute db_link
 Returns  : Value of db_link (string)
 Args     : New value of db_link (optional)
    
=cut


sub db_link {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_link'} = $value;
    }
    return $self->{'db_link'};
}



=head2 db_accession
    
 Title    : db_accession_obj
 Usage    : $obj->db_accession_obj ([$newval])
 Function : get/set method for attribute db_accession
 Returns  : Bio::Cogemir::GenomeDB
 Args     : New value of db_accession (optional)
    
=cut

sub db_accession {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_accession'} = $value;
    }
    return $self->{'db_accession'};
}

=head2 aliases
    
 Title    : aliases_obj
 Usage    : $obj->aliases_obj ([$newval])
 Function : get/set method for attribute aliases
 Returns  : Bio::Cogemir::GenomeDB
 Args     : New value of aliases (optional)
    
=cut

sub aliases {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'aliases'} = $value;
    }
    return $self->{'aliases'};
}

=head2 refseqref
    
 Title    : refseqref
 Usage    : $obj->refseqref ($newval)
 Function : get/set method for refseqref
 Returns  : Value of refseqref
 Args     : New value of refseqref (optional)
    
=cut


sub refseqref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'refseqref'} = $value;
    }
    else{
    my $ref = "http://srs.ebi.ac.uk/srsbin/cgi-bin/wgetz?-e+[REFSEQ-alltext:".$self->db_accession."]";
    $self->{'refseqref'} = $ref;
    }
    return $self->{'refseqref'};
}

=head2 ensref
    
 Title    : ensref
 Usage    : $obj->ensref ($newval)
 Function : get/set method for ensref
 Returns  : Value of ensref
 Args     : New value of ensref (optional)
    
=cut


sub ensref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'ensref'} = $value;
    }
    else{
    my $organism = $self->genome_db->organism;
    $organism =~ s/ /_/;
    my $ref = "http://dec2007.archive.ensembl.org/".$organism."/geneview?gene=".$self->stable_id.";db=".$self->genome_db->db_type;
    $self->{'ensref'} = $ref;
    }
    return $self->{'ensref'};
}

=head2 enscontigref
    
 Title    : enscontigref
 Usage    : $obj->enscontigref ($newval)
 Function : get/set method for enscontigref
 Returns  : Value of enscontigref
 Args     : New value of enscontigref (optional)
    
=cut


sub enscontigref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'enscontigref'} = $value;
    }
    else{
    return undef unless $self->location;
    my $organism = $self->genome_db->organism;
    $organism =~ s/ /_/;
    my $ref = "http://dec2007.archive.ensembl.org/".$organism."/contigview?l=".$self->location->name.":".$self->location->start."-".$self->location->end;
    $self->{'enscontigref'} = $ref;
    }
    return $self->{'enscontigref'};
}

=head2 symatlasref
    
 Title    : symatlasref
 Usage    : $obj->symatlasref ($newval)
 Function : get/set method for symatlasref
 Returns  : Value of symatlasref
 Args     : New value of symatlasref (optional)
    
=cut


sub symatlasref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'symatlasref'} = $value;
    }
    else{
    my $name = $self->external_name;
   	if ($name){
   	 	my $ref = "http://symatlas.gnf.org/SymAtlas/symquery?q=".$self->external_name;
    	$self->{'symatlasref'} = $ref;
    	}
    }
    return $self->{'symatlasref'};
}

=head2 ucscref
    
 Title    : ucscref
 Usage    : $obj->ucscref ($newval)
 Function : get/set method for ucscref
 Returns  : Value of enscontigref
 Args     : New value of enscontigref (optional)
    
=cut

sub ucscref {
  my ($self,$value) = @_;
  my %ucsc_dbkey = ('Mouse'=>'mm4','Rat'=>'rn4','X.tropicalis'=>'xenTro2',
                    'Zebrafish'=>'danRer4','Opossum'=>'monDom4','Tetraodon'=>'tetNig1',
                    'Chicken'=>'galGal2','Cow'=>'bosTau2','Dog'=>'canFam1',
                    'Rhesus'=>'rheMac2','A.gambiae' =>'anoGam1','C.elegans'=>'ce2',
                    'S.cerevisiae'=>'sacCer1','Chimp'=>'panTro1','Platypus'=>'ornAna1',
                    'Fugu'=>'fr2','Stickleback'=>'gasAcu1','Medaka'=>'oryLat1',
                    'C.intestinalis'=>'ci2','Fruitfly'=>'dm3','Human' => 'hg18');
  if (defined $value) {
	$self->{'ucscref'} = $value;
    }
  else{
    my ($organism) = $self->genome_db->common_name;
    my $ref = "http://genome.ucsc.edu/cgi-bin/hgTracks?org=$organism&db=".$ucsc_dbkey{$organism}."&position=chr".$self->location->name.":".$self->location->start."-".$self->location->end if $self->location;
    $self->{'ucscref'} = $ref;  
  }
  return $self->{'ucscref'};
}

1;
