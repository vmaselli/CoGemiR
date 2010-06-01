#
# Module for Bio::Cogemir::MicroRNA
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::MicroRNA

=head1 SYNOPSIS

	my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE => $attribute_obj,
							    -SPECIFIC => $specific,
							    -SEED => $seed_obj,
							    -CLUSTER => $cluster,
							    -HOSTGENE => $hostgene_obj,
							    );

	my $cluster = $micro_rna->cluster;
	
=head1 DESCRIPTION

    This module work with the micro_rna object 


=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::MicroRNA;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -DBID       => $dbID,
							    -ADAPTOR    => $adaptor,
							    -ATTRIBUTE  => $attribute_obj,
							    -SPECIFIC   => $specific,
							    -SEED       => $seed_obj,
							    -CLUSTER    => $cluster,
							    -HOSTGENE   => $hostgene_obj
							   );
 Returns        : Bio::Cogemir::MicroRNA
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$attribute_obj,
		$specific,
		$share,
		$seed_obj,
		$cluster,
		$hostgene_obj
		) = $self->_rearrange([qw(
		DBID               
		ADAPTOR            
		ATTRIBUTE         
		SPECIFIC
		SHARE
		SEED           
		CLUSTER
		HOSTGENE  
		)],@args);
	
	$dbID && $self->dbID($dbID); 
	$adaptor && $self->adaptor($adaptor);
	$attribute_obj && $self->attribute($attribute_obj);
	$specific && $self->specific($specific);
	$share && $self->share($share);
	$seed_obj && $self->seed($seed_obj);
	$cluster && $self->cluster($cluster);
	$hostgene_obj && $self->hostgene($hostgene_obj);



	unless (defined $attribute_obj){
		$self->throw("The MicroRNA does not have all micro_rnas to be created: I need a attribute");
	}


	
	return $self;
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Function : get/set method for micro_rna dbID
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
 Function : get/set method for micro_rna adaptor
 Returns  : Bio::Cogemir::DBSQL::MicroRNAAdaptor
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
 Function : get/set method for micro_rna attribute
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


=head2 specific
    
 Title    : specific
 Usage    : $obj->specific ($newval)
 Function : get/set method for micro_rna specific
 Returns  : Value of specific
 Args     : New value of specific (optional)
    
=cut


sub specific {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'specific'} = $value;
    }
    return $self->{'specific'};
}

=head2 seed
    
 Title    : seed_id
 Usage    : $obj->seed($newval)
 Function : get/set method for micro_rna seed_id
 Returns  : Value of seed_id
 Args     : New value of seed_id (optional)
    
=cut


sub seed {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'seed'} = $value;
    }
    return $self->{'seed'};
}


=head2 share
    
 Title    : share
 Usage    : $obj->share($newval)
 Function : get/set method for micro_rna share_id
 Returns  : Value of share_id
 Args     : New value of share_id (optional)
    
=cut


sub share {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'share'} = $value;
    }
    return $self->{'share'};
}

=head2 shared
           
 Title    : share
 Usage    : $obj->share($newval)
 Function : get/set method for micro_rna share_id
 Returns  : Value of share_id 
 Args     : New value of share_id (optional)
    
=cut


sub shared {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'shared'} = $value;
    }
    else{$self->{'shared'} = $self->adaptor->db->get_MicroRNAAdaptor->fetch_by_hoststable_id($self->hostgene->stable_id);}
    return $self->{'shared'};
}

=head2 cluster
    
 Title    : cluster
 Usage    : $obj->cluster ($newval)
 Function : get/set method for micro_rna cluster
 Returns  : Value of cluster
 Args     : New value of cluster (optional)
    
=cut


sub cluster {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'cluster'} = $value;
    }
    return $self->{'cluster'};
}

=head2 hostgene
    
 Title    : hostgene
 Usage    : $obj->hostgene ($newval)
 Function : get/set method for micro_rna hostgene
 Returns  : Value of hostgene
 Args     : New value of hostgene (optional)
    
=cut


sub hostgene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'hostgene'} = $value;
    }
    return $self->{'hostgene'};
}



=head2 mature_seq
    
 Title    : mature_seq
 Usage    : $obj->mature_seq ($newval)
 Function : get/set method for micro_rna mature_seq
 Returns  : Value of mature_seq
 Args     : New value of mature_seq (optional)
    
=cut


sub mature_seq {
    my ($self,$value) = @_;
    if (defined $value) {
		$self->{'mature_seq'} = $value;
    }
    else{
    $self->{'mature_seq'} = $self->adaptor->get_mature_seq($self->dbID);
    }
    return $self->{'mature_seq'};
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
    $self->{'stable_id'} = $self->attribute->stable_id;
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
    $self->{'gene_name'} = $self->attribute->gene_name;
    }
    return $self->{'gene_name'};
}


=head2 db_accession
    
 Title    : db_accession
 Usage    : $obj->db_accession ($newval)
 Function : get/set method for micro_rna db_accession
 Returns  : Value of db_accession
 Args     : New value of db_accession (optional)
    
=cut


sub db_accession {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_accession'} = $value;
    }
    else{
    $self->{'db_accession'} = $self->attribute->db_accession;
    }
    return $self->{'db_accession'};
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

=head2 mirna
    
 Title    : mirna
 Usage    : $obj->mirna_name ($newval)
 Function : get/set method for micro_rna mirna_name
 Returns  : Value of mirna_name
 Args     : New value of mirna_name (optional)
    
=cut


sub mirna {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'mirna'} = $value;
    }
    else{
    $self->{'mirna'} = $self->attribute->mirna_name;
    }
    return $self->{'mirna'};
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


=head2 mirbaseref
    
 Title    : mirbaseref
 Usage    : $obj->mirbaseref ($newval)
 Function : get/set method for micro_rna mirbaseref
 Returns  : Value of mirbaseref
 Args     : New value of mirbaseref (optional)
    
=cut


sub mirbaseref {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'mirbaseref'} = $value;
    }
    else{
    my $ref = "http://microrna.sanger.ac.uk/cgi-bin/sequences/mirna_entry.pl?acc=".$self->db_accession;
    $self->{'mirbaseref'} = $ref;
    }
    return $self->{'mirbaseref'};
}


=head2 localization
    
 Title    : localization
 Usage    : $obj->localization ($newval)
 Function : get/set method for micro_rna localization
 Returns  : Value of localization
 Args     : New value of localization (optional)
    
=cut


sub localization {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'localization'} = $value;
    }
    else{
    my $loc = $self->adaptor->get_all_Localization($self->dbID);
    $self->{'localization'} = $loc;
    }
    return $self->{'localization'};
}

sub flanking_region {
    my ($self, $value) = @_;
    my @res;
    if (defined $value) {
        $self->{'flanking_region'} = $value;
    }
    else{
        foreach my $transcript (@{$self->hostgene->transcripts}) {
            next unless $transcript->localization;
            foreach my $exon (@{$transcript->localization}){
                push (@res, $exon);
            }
        }
        $self->{'flanking_region'} = \@res;
    }
    return $self->{'flanking_region'};
    
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

sub tissues{
	my ($self, $value) = @_;
	
	my $tissues = $self->adaptor->fetch_by_tissue($value,$self->dbID);
	$self->{'tissues'} = $tissues;
	
	return $self->{'tissues'};
}

sub external_database{
	my ($self) = @_;
	return $self->{'external_database'} = $self->adaptor->get_all_ExternalDatabase($self->dbID);
}

sub hit{
	my ($self) = @_;
	return $self->{'hit'} = $self->adaptor->get_all_Hits($self->dbID)
}

1;
