#
# Module for Bio::Cogemir::DBSQL::MirnaNameAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::MirnaNameAdaptor

=head1 SYNOPSIS

    $mirna_name_adaptor = $dbadaptor->get_MirnaNameAdaptor();

    $features = $mirna_name_adaptor->fetch_by_dbID();

    $features = $mirna_name_adaptor->fetch_by_name();

=head1 DESCRIPTION


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it


=cut

$!=1;
package Bio::Cogemir::DBSQL::MirnaNameAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";
use Bio::Cogemir::MirnaName;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBConnection;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of MirnaName
  Example    : $mirna_name = $mirna_name_adaptor->fetch_by_dbID($mirna_name_id);
  Description: Retrieves an mirna_name from the database via its internal id
  Returntype : Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID,$tag) = @_;
    $self->throw("I need a dbID") unless $dbID;
    my $query = qq {
    SELECT name, analysis_id, exon_conservation, description, hostgene_conservation, family_name
      FROM mirna_name 
      WHERE mirna_name_id = ?  
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($name, $analysis_id, $exon_conservation, $description, $hostgene_conservation, $family_name) = $sth->fetchrow_array();
	
	unless (defined $name){
    	##self->warn("no mirna_name for dbID $dbID");
    	return undef;
    }
    
	
	my $analysis = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id) if $analysis_id;
	my $mirna_name = new Bio::Cogemir::MirnaName ( 
	                                  -dbID => $dbID,
	                                  -adaptor => $self,
									  -name           => $name,
                                      -analysis       => $analysis,
                                      -exon_conservation => $exon_conservation,
                                      -hostgene_conservation => $hostgene_conservation,
                                      -description =>$description,
                                      -family_name =>$family_name
                                    );
	#my $mirnas = $self->get_all_Mirnas($dbID);
	#$mirna_name->mirnas = $mirnas;
	return $mirna_name;
	
}
=head2 fetch_All

  Arg [1]    : all MirnaName
  Example    : $mirna_all = $mirna_name_adaptor->fetch_All;
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_All {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT mirna_name_id FROM mirna_name};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($dbID) = $sth->fetchrow_array){
		push (@{$ret}, $self->fetch_by_dbID($dbID));
	}
	return $ret;

}

=head2 get_all_family_name

  Arg [1]    : 
  Example    : $mirna_all = $mirna_name_adaptor->get_all_family_name;
  Description: Retrieves all mirna from the database via family name
  Returntype : listref Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub get_all_family_name {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT distinct(family_name) FROM mirna_name};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($name) = $sth->fetchrow_array){
		push (@{$ret}, $name) if defined $name;
	}
	return $ret;

}
=head2 get_all_FamilyNames

  Arg [1]    : 
  Example    : $FamilyNames = $mirna_family_name_adaptor->get_all_FamilyNames;
  Description: Retrieves Family_Names from the database 
  Returntype : listref family_name
  Exceptions : none
  Call_Nameser     : general

=cut

sub get_all_FamilyNames {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT distinct(family_name) FROM mirna_name};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($family_name) = $sth->fetchrow_array){
		push (@{$ret}, $family_name);
	}
	return $ret;

}

=head2 fetch_all_name_by_family_name

  Arg [1]    : family_name
  Example    : $mirna_all_Names = $mirna_name_adaptor->get_all_Names;
  Description: Retrieves an mirna_all_Names from the database via its all_Names
  Returntype : listref name
  Exceptions : none
  Call_Nameser     : general

=cut

sub fetch_all_name_by_family_name {
	my ($self, $value) = @_;
	
	my $ret;
	my $query = qq{SELECT name FROM mirna_name WHERE family_name = ?};
	my $sth = $self->prepare($query);
	$sth->execute($value);
	while (my ($name) = $sth->fetchrow_array){
		push (@{$ret}, $name);
	}
	return $ret;

}


=head2 get_all_Names

  Arg [1]    : 
  Example    : $mirna_all_Names = $mirna_name_adaptor->get_all_Names;
  Description: Retrieves an mirna_all_Names from the database via its all_Names
  Returntype : listref name
  Exceptions : none
  Call_Nameser     : general

=cut

sub get_all_Names {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT name FROM mirna_name};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($name) = $sth->fetchrow_array){
		push (@{$ret}, $name);
	}
	return $ret;

}

=head2 get_all_organism

  Arg [1]    : all organism with a same name
  Example    : $mirna_all = $mirna_all_adaptor->get_all_Mirnas($dbID);
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_organism {
    my ($self, $dbID) = @_;
    my @mirna;
    my $query = qq {
    SELECT g.genome_db_id
      FROM mirna_name mn, genome_db g, attribute a
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND g.genome_db_id = a.genome_db_id
      AND mn.mirna_name_id = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($dbID);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna, $self->db->get_GenomeDBAdaptor->fetch_by_dbID($dbID));
    }
	return \@mirna;
}

=head2 get_all_Mirnas

  Arg [1]    : all MicroRNAs with a same name
  Example    : $mirna_all = $mirna_all_adaptor->get_all_organism($dbID);
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_Mirnas {
    my ($self, $dbID) = @_;
    my @mirna;
    my $query = qq {
    SELECT mr.micro_rna_id
      FROM mirna_name mn, micro_rna mr, attribute a
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND mr.attribute_id = a.attribute_id
      AND mn.mirna_name_id = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($dbID);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna, $self->db->get_MicroRNAAdaptor->fetch_by_dbID($dbID));
    }
	return \@mirna;
}

=head2 get_all_Mirnas_in_Family

  Arg [1]    : all MicroRNAs with a same name
  Example    : $mirna_all = $mirna_all_adaptor->get_all_organism($dbID);
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_Mirnas_in_Family {
    my ($self, $name) = @_;
    my @mirna;
    my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    my $query = qq {
    SELECT mr.micro_rna_id
      FROM mirna_name mn, micro_rna mr, attribute a
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND mr.attribute_id = a.attribute_id
      AND mn.family_name = ?
    };
	
		my $sth = $self->prepare($query);
		$first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
    #print ref $self," line 303 FAMILY_NAME $family_name<br>\n";
    $sth->execute($family_name);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna, $self->db->get_MicroRNAAdaptor->fetch_by_dbID($dbID));
    }
	return \@mirna;
}

=head2 get_all_Mirnas_in_Family_by_organism

  Arg [1]    : all MicroRNAs with a same name
  Example    : $mirna_all = $mirna_all_adaptor->get_all_organism($dbID);
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_Mirnas_in_Family_by_organism {
    my ($self, $name,$organism) = @_;
    #print ref $self, " line 324 $name $organism<br>\n";
    my @mirna;
    my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
    unless (defined $family_name){$family_name = $name}
    my $query = qq {
    SELECT mr.micro_rna_id
      FROM mirna_name mn, micro_rna mr, attribute a, genome_db g
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND mr.attribute_id = a.attribute_id
      AND a.genome_db_id = g.genome_db_id
			AND g.db_type = 'core'
			AND mn.family_name = ?
      AND g.organism = ?
    };
	# printf "SELECT mr.micro_rna_id
#       FROM mirna_name mn, micro_rna mr, attribute a, genome_db g
#       WHERE mn.mirna_name_id = a.mirna_name_id
#       AND mr.attribute_id = a.attribute_id
#       AND a.genome_db_id = g.genome_db_id
# 			AND g.db_type = 'core'
# 			AND mn.family_name = %s
#       AND g.organism = %s\n",$family_name,$organism;
	my $sth = $self->prepare($query);
		
    $sth->execute($family_name,$organism);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna, $self->db->get_MicroRNAAdaptor->fetch_by_dbID($dbID));
    }
	return \@mirna;
}

=head2 get_all_Mirnas_in_Family_by_organism

  Arg [1]    : all MicroRNAs with a same name
  Example    : $mirna_all = $mirna_all_adaptor->get_all_organism($dbID);
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_Mirnas_in_Family_by_taxa {
    my ($self, $name,$taxa) = @_;
    #print "$name $taxa<br>\n";
    my @mirna;
    my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
    my $query = qq {
    SELECT mr.micro_rna_id
      FROM mirna_name mn, micro_rna mr, attribute a, genome_db g
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND mr.attribute_id = a.attribute_id
      AND a.genome_db_id = g.genome_db_id
			AND g.db_type = 'core'
			AND mn.family_name = ?
      AND g.taxa = ?
    };

	my $sth = $self->prepare($query);
    $sth->execute($family_name,$taxa);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna, $self->db->get_MicroRNAAdaptor->fetch_by_dbID($dbID));
    }
	return \@mirna;
}

=head2 get_all_Hostgenes

  Arg [1]    : all hostgene of MicroRNAs with a same name
  Example    : $hostgene_all = $hostgene_all_adaptor->get_all_organism($dbID);
  Description: Retrieves an hostgene_all from the database via its all
  Returntype : listref Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub get_all_Hostgenes {
    my ($self, $dbID) = @_;
    my @hostgene;
    my $query = qq {
    SELECT g.gene_id
      FROM mirna_name mn, gene g, attribute a
      WHERE mn.mirna_name_id = a.mirna_name_id
      AND g.attribute_id = a.attribute_id
      AND mn.mirna_name_id = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($dbID);
    while (my $dbID = $sth->fetchrow_array){
        push (@hostgene, $self->db->get_GeneAdaptor->fetch_by_dbID($dbID));
    }
	return \@hostgene;
}
=head2 fetch_by_name_web

  Arg [1]    : name of MirnaName
  Example    : $mirna_name = $mirna_name_adaptor->fetch_by_name_web($name);
  Description: Retrieves an mirna_name from the database via its name
  Returntype : Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name_web {
    my ($self, $value) = @_;
    $self->throw("I need a name") unless $value;
    my $res;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE name =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while (my $dbID = $sth->fetchrow_array){
    	push (@$res, $self->fetch_by_dbID($dbID));
    }
    return $res;
	
}

=head2 fetch_by_name

  Arg [1]    : name of MirnaName
  Example    : $mirna_name = $mirna_name_adaptor->fetch_by_name($name);
  Description: Retrieves an mirna_name from the database via its name
  Returntype : Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
    my ($self, $value) = @_;
    $self->throw("I need a name") unless $value;
    my $res;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE name =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    my $dbID = $sth->fetchrow_array;
    $res = $self->fetch_by_dbID($dbID) if $dbID;
    return $res;
	
}

=head2 fetch_by_family_name

  Arg [1]    : name of family of MirnaName
  Example    : $mirna_name = $mirna_name_adaptor->fetch_by_name($name);
  Description: Retrieves an mirna_name from the database via its name
  Returntype : Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_family_name {
    my ($self, $value) = @_;
    $self->throw("I need a name") unless $value;
    my $res;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE family_name =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while(my $dbID = $sth->fetchrow_array){
    	push(@{$res},$self->fetch_by_dbID($dbID)) if $dbID;
    }
    return $res;
	
}

=head2 fetch_by_name_like

  Arg [1]    : name_like of Mirnaname_like
  Example    : $mirna_name_like = $mirna_name_like_adaptor->fetch_by_name_like($name_like);
  Description: Retrieves an mirna_name_like from the database via its name_like
  Returntype : Bio::Cogemir::Mirnaname_like
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name_like {
    my ($self, $value) = @_;
    $self->throw("I need a name_like") unless $value;
    my $res;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE name rlike ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value."(\$\|[a-z])");
    while (my $dbID = $sth->fetchrow_array){
    	push (@$res, $self->fetch_by_dbID($dbID));
    }
    return $res;
	
}

=head2 fetch_by_analysis_id

  Arg [1]    : analysis_id of MirnaName
  Example    : $mirna_analysis_id = $mirna_analysis_id_adaptor->fetch_by_analysis_id($analysis_id);
  Description: Retrieves an mirna_analysis_id from the database via its analysis_id
  Returntype : Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id {
    my ($self, $value) = @_;
    $self->throw("I need a analysis internal id") unless $value;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE analysis_id =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    my $dbID = $sth->fetchrow;
    return undef unless defined $dbID;
	return $self->fetch_by_dbID($dbID);
}

=head2 fetch_by_exon_conservation

  Arg [1]    : exon_conservation of MirnaName
  Example    : $mirna_exon_conservation = $mirna_exon_conservation_adaptor->fetch_by_exon_conservation($exon_conservation);
  Description: Retrieves an mirna_exon_conservation from the database via its exon_conservation
  Returntype : listref Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_exon_conservation {
    my ($self, $value) = @_;
    $self->throw("I need a exon conservation term") unless $value;
    my @mirna_names;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE exon_conservation = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna_names, $self->fetch_by_dbID($dbID));
    }
	return \@mirna_names;
}

=head2 fetch_by_hostgene_conservation

  Arg [1]    : hostgene_conservation of MirnaName
  Example    : $mirna_hostgene_conservation = $mirna_hostgene_conservation_adaptor->fetch_by_hostgene_conservation($hostgene_conservation);
  Description: Retrieves an mirna_hostgene_conservation from the database via its hostgene_conservation
  Returntype : listref Bio::Cogemir::MirnaName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene_conservation {
    my ($self, $value) = @_;
    $self->throw("I need a hostgene conservation term") unless $value;
    my @mirna_names;
    my $query = qq {
    SELECT mirna_name_id
      FROM mirna_name
      WHERE hostgene_conservation = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while (my $dbID = $sth->fetchrow_array){
        push (@mirna_names, $self->fetch_by_dbID($dbID));
    }
	return \@mirna_names;
}


sub _exists{
	my ($self,$obj) = @_;
	my $obj_id;
	my $analysis_id = $obj->analysis->dbID if defined $obj->analysis;

	my $sql = qq{SELECT mirna_name_id FROM mirna_name WHERE name = ? };
	my $sth = $self->prepare($sql);
	$sth->execute($obj->name);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::MirnaName
               the MirnaName  to be stored in this database
  Example    : $mirna_name_adaptor->store($mirna_name);
 Description : Stores an MirnaName in the database
  Returntype : string, mirna_name_id
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $mirna_name ) = @_;
	
    # if the object being passed is a Cogemir::MirnaName store it locally with the mirna_nameuence
    if( ! $mirna_name->isa('Bio::Cogemir::MirnaName') ) {
	$self->throw("$mirna_name is not a Bio::Cogemir::MirnaName object - not storing!");
    }
   
    # if the dbID is present and if the MirnaName is already stored return the dbID 
    if ($mirna_name->can('dbID')&& $mirna_name->dbID) {return $mirna_name->dbID();}
    
    # if analysis doesn't exist store it
    my $analysis_id;
    if (defined $mirna_name->analysis){
	    unless ($mirna_name->analysis->dbID){$analysis_id = $self->db->get_AnalysisAdaptor->store($mirna_name->analysis);}
        else{$analysis_id = $mirna_name->analysis->dbID}
    }
    
    if ($self->_exists($mirna_name)){
        return $self->_exists($mirna_name);
    }

    my $sql = q { INSERT INTO mirna_name SET name = ?, exon_conservation = ? ,  analysis_id = ?, hostgene_conservation = ?, description = ?, family_name = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($mirna_name->name, $mirna_name->exon_conservation, $analysis_id, $mirna_name->hostgene_conservation, $mirna_name->description, $mirna_name->family_name);
    
    my $mirna_name_id = $sth->{'mysql_insertid'};
 	$mirna_name->dbID($mirna_name_id);
 	$mirna_name->adaptor($self);
 	
   	return $mirna_name_id;

}

=head2 remove

  Arg [1]    : Bio::Cogemir::MirnaName
               the MirnaName  to be removed from this database
  Example    : $mirna_name_adaptor->remove($mirna_name);
 Description : Delete  a mirna_name in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub remove {
    
  my ($self, $mirna_name) = @_;
  my $analysis_id = $mirna_name->analysis->dbID if defined $mirna_name->analysis;

  if( ! defined $mirna_name->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  foreach my $attribute (@{$self->db->get_AttributeAdaptor->fetch_by_mirna_name_id($mirna_name->dbID)}){
    $self->db->get_AttributeAdaptor->_remove($attribute) ;
    my $gene = $self->db->get_GeneAdaptor->fetch_by_attribute_id($attribute->dbID);
    if ($gene){
      $self->db->get_GeneAdaptor->_remove($gene);
      $self->db->get_MemberAdaptor->_remove($gene->member);
      $self->db->LocationAdaptor->_remove($gene->location);
      $self->db->SeqAdaptor->_remove($gene->attribute->seq);
      $self->db->GeneAdaptor->_remove($gene->hostgene) if $gene->hostgene;
      $self->db->AttributeAdaptor->_remove($gene->attribute) 
    }
    foreach my $homologs  (@{$self->db->get_HomologsAdaptor->fetch_by_member_id($gene->member->dbID);}){
    	$self->db->get_HomologsAdaptor->_remove($homologs);
    }
    foreach my $hit (@{$self->db->get_HitAdaptor->fetch_by_member_id($gene->member->dbID);}){
    	$self->db->get_HitAdaptor->_remove($hit);
    }
    foreach my $feature (@{$self->db->get_FeatureAdaptor->fetch_by_member_id($gene->member->dbID);}){
    	$self->db->get_FeatureAdaptor->_remove($feature);
    }
    
    foreach my $transcript (@{$gene->transcripts}){
    	$self->db->get_TranscriptAdaptor->_remove($transcript);
    	foreach my $exon (@{$transcript->All_exons}){
    	  $self->db->ExonAdaptor->_remove($exon);
    	}
    	foreach my $intron (@{$transcript->All_introns}){
    	  $self->db->IntronAdaptor->_remove($intron);
    	}
    }
    my $micro_rna = $self->db->get_MicroRNAAdaptor->fetch_by_attribute_id($attribute->dbID);
    if ($micro_rna){
      $self->db->get_MicroRNAAdaptor->_remove($micro_rna) ;
      foreach my $localization (@{$micro_rna->localization}){
        $self->db->get_LocalizationAdaptor->_remove($localization);
      }
      
      $self->db->get_MemberAdaptor->_remove($micro_rna->member);
      foreach my $feature (@{$micro_rna->features}){
        $self->db->get_FeatureAdaptor->_remove($feature);
      }
      $self->db->LocationAdaptor->_remove($micro_rna->location);
      $self->db->SeqAdaptor->_remove($micro_rna->mature_seq) if $micro_rna->mature_seq;
      $self->db->SeqAdaptor->_remove($micro_rna->attribute->seq);
      $self->db->GeneAdaptor->_remove($micro_rna->hostgene) if $micro_rna->hostgene;
      $self->db->AttributeAdaptor->_remove($micro_rna->attribute); 
      
      foreach my $paralogs  (@{$self->db->get_ParalogsAdaptor->fetch_by_member_id($micro_rna->member->dbID);}){
        $self->db->get_ParalogsAdaptor->_remove($paralogs);
      }
      foreach my $hit (@{$self->db->get_HitAdaptor->fetch_by_member_id($micro_rna->member->dbID);}){
        $self->db->get_HitAdaptor->_remove($hit);
      }
      
      foreach my $feature (@{$self->db->get_FeatureAdaptor->fetch_by_member_id($micro_rna->member->dbID);}){
        $self->db->get_FeatureAdaptor->_remove($feature);
      }
    }
    $self->db->SeqAdaptor->_remove($attribute->seq);
    $self->db->AnalysisAdaptor->_remove($attribute->analysis);
  }
  my $analysis = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id);
  $self->db->get_AnalysisAdaptor->_remove($analysis) if defined $analysis;

  my $sth= $self->prepare( "delete from mirna_name where mirna_name_id = ? " );
  $sth->execute($mirna_name->dbID());
  return 1;
}

=head2 _remove

  Arg [1]    : Bio::Cogemir::MirnaName
               the MirnaName  to be removed from this database
  Example    : $mirna_name_adaptor->remove($mirna_name);
 Description : Delete  a mirna_name in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub _remove {
    
    my ($self, $mirna_name) = @_;
    my $analysis_id = $mirna_name->analysis->dbID if defined $mirna_name->analysis;

    if( ! defined $mirna_name->dbID() ) {
	    $self->throw("A dbID is not defined\n");
    }
   
    my $sth= $self->prepare( "delete from mirna_name where mirna_name_id = ? " );
    $sth->execute($mirna_name->dbID());
    return 1;

}


=head2 update

  Arg [1]    : Bio::Cogemir::MirnaName
               the MirnaName  to be updated in this database
  Example    : $mirna_name_adaptor->update($mirna_name);
 Description : Stores an MirnaName in the database
  Returntype : Bio::Cogemir::MirnaName
  Exceptions :
  Caller     : general

=cut

sub update {
    my ( $self, $mirna_name ) = @_;
    if( ! $mirna_name->isa('Bio::Cogemir::MirnaName') ) {
	$self->throw("$mirna_name is not a Bio::Cogemir::MirnaName object - not updating!");
    }
    my $analysis_id = $mirna_name->analysis->dbID if defined $mirna_name->analysis;
    my $sql = q { UPDATE mirna_name SET name = ?, exon_conservation = ? ,  analysis_id = ?, hostgene_conservation = ?, description = ?, family_name = ? WHERE mirna_name_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($mirna_name->name, $mirna_name->exon_conservation, $analysis_id, $mirna_name->hostgene_conservation, $mirna_name->description, $mirna_name->family_name,$mirna_name->dbID);
    
    return $self->fetch_by_dbID($mirna_name->dbID);
}
1;
