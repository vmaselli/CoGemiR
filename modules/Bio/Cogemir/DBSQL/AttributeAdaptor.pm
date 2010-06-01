#
# Module for Bio::Cogemir::DBSQL::AttributeAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::AttributeAdaptor

=head1 SYNOPSIS

    $attribute_adaptor = $db->get_AttributeAdaptor();

    $attribute =  $attribute_adaptor->fetch_by_dbID();


=head1 DESCRIPTION

    This adaptor work with the attribute table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::AttributeAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Attribute;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an attribute from the database via its internal id
  Returntype : Bio::Cogemir::Attribute
  Exceptions : if doesn't exists
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a attribute id") unless $dbID;

    my $query = qq {
    SELECT  genome_db_id, seq_id, mirna_name_id,  analysis_id, status, gene_name, stable_id, external_name, db_link, db_accession, aliases_id, location_id
      FROM attribute 
      WHERE  attribute_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($genome_db_id, $seq_id, $mirna_name_id,  $analysis_id, $status, $gene_name, $stable_id, $external_name, $db_link, $db_accession, $aliases_id, $location_id) = $sth->fetchrow_array();

    unless (defined $genome_db_id){
    	self->throw("no attribute for $dbID in AttributeAdaptor->fetch_by_dbID line 71");
    	return undef;
    }
    
    my $genome_obj = $self->db->get_GenomeDBAdaptor->fetch_by_dbID($genome_db_id);
    my $location = $self->db->get_LocationAdaptor->fetch_by_dbID($location_id) if $location_id;
    my $seq_obj = $self->db->get_SeqAdaptor->fetch_by_dbID($seq_id) if $seq_id;
	  my $mirna_name_obj = $self->db->get_MirnaNameAdaptor->fetch_by_dbID($mirna_name_id);
	  my $analysis_obj = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id) if $analysis_id;
	  my $aliases_obj = $self->db->get_AliasesAdaptor->fetch_by_dbID($aliases_id) if $aliases_id;
	  
   	my $attribute =  Bio::Cogemir::Attribute->new(   
							    -DBID =>$dbID,
							    -ADAPTOR => $self,
							    -GENOME_DB => $genome_obj,
							    -SEQ => $seq_obj,
							    -MIRNA_NAME => $mirna_name_obj,
							    -ANALYSIS => $analysis_obj,
							    -STATUS => $status, -GENE_NAME => $gene_name,  
							    -STABLE_ID => $stable_id,  
							    -EXTERNAL_NAME => $external_name,
							    -DB_LINK => $db_link,
							    -DB_ACCESSION => $db_accession,
							    -ALIASES => $aliases_obj,
							    -LOCATION => $location
							   );
    return $attribute;
}

=head2 fetch_by_genome_db_id

  Arg [1]    : genome_db_id of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_genome_db_id(34);
  Description: Retrieves an attribute from the database via its genome_db_id
  Returntype : listref of Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_genome_db_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT attribute_id 
	             FROM attribute
	             WHERE genome_db_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_analysis_id

  Arg [1]    : analysis_id of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_analysis_id(12);
  Description: Retrieves an attribute from the database via its analysis_id
  Returntype : Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my $obj;
	my $sql = qq{SELECT attribute_id 
	             FROM attribute
	             WHERE analysis_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if defined $dbID;
	
	return $obj;
}

=head2 fetch_by_seq_id

  Arg [1]    : seq_id of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_seq_id(12);
  Description: Retrieves an attribute from the database via its seq_id
  Returntype : Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_seq_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my $obj;
	my $sql = qq{SELECT attribute_id 
	             FROM attribute
	             WHERE seq_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if defined $dbID;
	
	return $obj;
}

=head2 fetch_by_mirna_name_id

  Arg [1]    : mirna_name_id of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_mirna_name_id('ENSG0000001234');
  Description: Retrieves an attribute from the database via its mirna_name_id term
  Returntype : listref of Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_mirna_name_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT attribute_id 
	             FROM attribute
	             WHERE mirna_name_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_status

  Arg [1]    : status of attribute
  Example    : $attribute = $attribute_adaptor->fetch_by_status('ENSG0000001234');
  Description: Retrieves an attribute from the database via its status term
  Returntype : listref of Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_status{
	my ($self, $value) = @_;
	$self->throw("I need a status") unless $value;
	my @objs;
	my $sql = qq{SELECT attribute_id 
	             FROM attribute
	             WHERE status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_gene_name

  Arg [1]    : gene name
  Example    : $attribute = $attribute_adaptor->fetch_by_gene_name($dbID);
  Description: Retrieves an attribute from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_gene_name {
    my ($self, $gene_name) = @_;
   
    $self->throw("I need a gene name") unless $gene_name;

    my $query = qq {
    SELECT attribute_id
      FROM attribute 
      WHERE  gene_name = ?  
  };
  	#print "SELECT attribute_id FROM attribute WHERE  gene_name = \'$gene_name\'\n";
    my $sth = $self->prepare($query);
    $sth->execute($gene_name);
	my $dbID = $sth->fetchrow_array();
	#print "DBID $dbID\n" if $dbID;
	my $attribute = $self->fetch_by_dbID($dbID) if $dbID;
	
    return $attribute;
}

sub get_microrna {
	my ($self, $dbID) = @_;
	my $res;
	my $sql = qq{select micro_rna_id from micro_rna where attribute_id = ?};
	my $sth = $self->db->prepare($sql);
	$sth->execute($dbID);
	my $mir_id = $sth->fetchrow;
	return $self->db->get_MicroRNAAdaptor->fetch_by_dbID($mir_id);
}

=head2 fetch_by_stable_id

  Arg [1]    : ensembl gene stable id
  Example    : $attribute = $attribute_adaptor->fetch_by_dbID('ENSG000000001234');
  Description: Retrieves an attribute from the database via its external gene stable id
  Returntype : Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut


sub fetch_by_stable_id {
    my ($self, $stable_id) = @_;
    $self->throw("I need a gene stable id") unless $stable_id;
	
    my $query = qq {
    SELECT attribute_id
      FROM attribute 
      WHERE  stable_id =  ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($stable_id );
	my $dbID = $sth->fetchrow_array();
	unless (defined $dbID){
    	#self->warn("no attribute for $stable_id") if $debug ;
    	return undef;
    }

    return  $self->fetch_by_dbID($dbID);

}

=head2 get_All

  Arg [1]    : external name
  Example    : $attribute = $attribute_adaptor->fetch_get_All('P63');
  Description: Retrieves an attribute from the database via its external (generic) name
  Returntype : list of Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub get_All {
    my ($self) = @_;
    my ($attribute, @attributes, $dbID);
    my $query = qq {
    SELECT attribute_id
      FROM attribute 
  };

  my $sth = $self->prepare($query);
  $sth->execute();
	
	while($dbID = $sth->fetchrow_array()){
		$attribute = $self->fetch_by_dbID($dbID);
		push (@attributes, $attribute);
	}
	
  return \@attributes;
}

sub get_all_by_gene_name {
    my ($self, $gene_name) = @_;
   
    $self->throw("I need a gene name") unless $gene_name;
		my @res;
    my $query = qq {
    SELECT attribute_id
      FROM attribute 
      WHERE  gene_name = ?  
  };
  	#print "SELECT attribute_id FROM attribute WHERE  gene_name = \'$gene_name\'\n";
    my $sth = $self->prepare($query);
    $sth->execute($gene_name);
		while (my $dbID = $sth->fetchrow_array()){
			push (@res,$self->fetch_by_dbID($dbID))
		}
	
    return \@res;
}

=head2 fetch_by_external_name

  Arg [1]    : external name
  Example    : $attribute = $attribute_adaptor->fetch_by_external_name('P63');
  Description: Retrieves an attribute from the database via its external (generic) name
  Returntype : list of Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_external_name {
  my ($self, $external_name) = @_;
  my $attributes;
  $self->throw("I need a external name") unless $external_name;

  my $query = qq {
  SELECT attribute_id
    FROM attribute 
    WHERE  external_name =  ? 
  };

  my $sth = $self->prepare($query);
  $sth->execute($external_name);

  while(my $dbID = $sth->fetchrow_array()){
    push (@{$attributes}, $self->fetch_by_dbID($dbID));
  }
  return $attributes;
}

=head2 fetch_by_db_link

  Arg [1]    : gene name
  Example    : $attribute = $attribute_adaptor->fetch_by_db_link($dbID);
  Description: Retrieves an attribute from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_db_link {
  my ($self, $db_link) = @_;
  my $attributes;
  $self->throw("I need a gene name") unless $db_link;

  my $query = qq {
  SELECT attribute_id
    FROM attribute 
    WHERE  db_link like ?  
  };
    my $sth = $self->prepare($query);
    my $string = 
    $sth->execute($db_link."%");
	while(my $dbID = $sth->fetchrow_array()){
    push (@{$attributes}, $self->fetch_by_dbID($dbID));
  }
  return $attributes;
}

=head2 fetch_by_db_accession

  Arg [1]    : gene name
  Example    : $attribute = $attribute_adaptor->fetch_by_db_accession($dbID);
  Description: Retrieves an attribute from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Attribute
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_db_accession {
  my ($self, $db_accession) = @_;
  my ($attributes, $dbID);
  $self->throw("I need a gene name") unless $db_accession;

  my $query = qq {
  SELECT attribute_id
    FROM attribute 
    WHERE  db_accession like ?  
  };
  my $sth = $self->prepare($query);
  $sth->execute($db_accession."%");
	while(my $dbID = $sth->fetchrow_array()){
    push (@{$attributes}, $self->fetch_by_dbID($dbID));
  }
  return $attributes;
}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $analysis_id = $obj->analysis->dbID if  defined $obj->analysis;	
	my $seq_id = $obj->seq->dbID if defined $obj->seq;
	my $aliases_id = $obj->aliases->dbID if defined $obj->aliases;
  $self->throw('no genome_db') unless defined $obj->genome_db;
  $self->throw('no mirna_name') unless defined $obj->mirna_name;
	my $sql = q { 
	SELECT attribute_id FROM attribute WHERE gene_name = ? and stable_id = ? };
    my $sth = $self->prepare($sql);

    $sth->execute($obj->gene_name, $obj->stable_id);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Attribute
               the attribute  to be stored in this database
  Example    : $attribute_adaptor->store($attribute);
 Description : Stores an attribute in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $attribute ) = @_;

	
    #if it is not an attribute dont store
    if( ! $attribute->isa('Bio::Cogemir::Attribute') ) {
	$self->throw("$attribute is not a Bio::Cogemir::Attribute object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($attribute->can('dbID') && $attribute->dbID) {return $attribute->dbID();}
    if ($self->_exists($attribute)){return $self->_exists($attribute);}
   	
   	unless($attribute->genome_db->dbID){$self->db->get_GenomeDBAdaptor->store($attribute->genome_db);}
   	unless($attribute->mirna_name->dbID){$self->db->get_MirnaNameAdaptor->store($attribute->mirna_name);}
   	
   	my $location_id;
   	if (defined $attribute->location){
   		unless($attribute->location->dbID){$location_id = $self->db->get_LocationAdaptor->store($attribute->location);}
			else{$location_id = $attribute->location->dbID}
		}
		
   	my $seq_id = 0;
   	if (defined $attribute->seq){
   		unless($attribute->seq->dbID){$seq_id = $self->db->get_SeqAdaptor->store($attribute->seq);}
   		else{$seq_id = $attribute->seq->dbID};
   	}
   	my $analysis_id;
   	if (defined $attribute->analysis){
   		unless($attribute->analysis->dbID){$analysis_id = $self->db->get_AnalysisAdaptor->store($attribute->analysis);}
   		else {$analysis_id = $attribute->analysis->dbID}
   	}
   	my $aliases_id;
   	if (defined $attribute->aliases){
   		unless($attribute->aliases->dbID){$aliases_id = $self->db->get_AliasesAdaptor->store($attribute->aliases);}
   		else {$aliases_id = $attribute->aliases->dbID}
   	}
   	
    

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO attribute SET  genome_db_id = ?, seq_id = ?, mirna_name_id = ?, analysis_id = ?, status = ?, location_id = ?,
	                           gene_name = ? ,stable_id = ?, external_name = ?, db_link = ?, db_accession = ?, aliases_id = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($attribute->genome_db->dbID(), $seq_id,  $attribute->mirna_name->dbID,$analysis_id,$attribute->status, $location_id,
                  $attribute->gene_name, $attribute->stable_id, $attribute->external_name, $attribute->db_link, $attribute->db_accession, $aliases_id);
    my $attribute_id = $sth->{'mysql_insertid'};
    $attribute->dbID($attribute_id);
    $attribute->adaptor($self);
    return $attribute_id;
}

=head2 update

  Arg [1]    : Bio::Cogemir::Attribute
               the attribute  to be updated in this database
  Example    : $attribute_adaptor->update($attribute);
 Description : updates an attribute in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $attribute) = @_;
        if( ! $attribute->isa('Bio::Cogemir::Attribute') ) {
	$self->throw("$attribute is not a Bio::Cogemir::Attribute object - not updating!");
    }
	my $analysis_id = $attribute->analysis->dbID if  defined $attribute->analysis;
	my $aliases_id = $attribute->aliases->dbID if  defined $attribute->aliases;
	my $seq_id = $attribute->seq->dbID if defined $attribute->seq;
	
	
    my $sql = q { 
	UPDATE attribute SET  genome_db_id = ?, seq_id = ?, mirna_name_id = ?, analysis_id = ?, status = ?, location_id = ?,
	                      gene_name = ? ,stable_id = ?, external_name = ?, db_link = ?, db_accession = ?, aliases_id = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($attribute->genome_db->dbID(), 
    $seq_id,  
    $attribute->mirna_name->dbID,
    $analysis_id,$attribute->status,$attribute->location->dbID,
                 $attribute->gene_name, $attribute->stable_id, $attribute->external_name, $attribute->db_link, $attribute->db_accession,  $aliases_id);
    return $self->fetch_by_dbID($attribute->dbID);
    
}    


=head2 remove

  Arg [1]    : Bio::Cogemir::Attribute
               the attribute  to be removed from this database
  Example    : $attribute_adaptor->remove($attribute);
 Description : removes an attribute in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $attribute) = @_;
  
  if( ! defined $attribute->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  
  my $gene = $self->db->get_GeneAdaptor->fetch_by_attribute_id($attribute->dbID);
  $self->db->get_GeneAdaptor->_remove($gene) if $gene;
  my $microrna = $self->db->get_MicroRNAAdaptor->fetch_by_attribute_id($attribute->dbID);
  $self->db->get_MicroRNAAdaptor->_remove($microrna) if $microrna; 
  $self->db->get_AnalysisAdaptor->_remove($attribute->analysis);
  $self->db->get_AliasesAdaptor->_remove($attribute->aliases) if defined $attribute->aliases;
  $self->db->get_SeqAdaptor->_remove($attribute->seq);
  my $sth= $self->prepare( "delete attribute a from attribute a where a.attribute_id = ? " );
  $sth->execute($attribute->dbID());
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Attribute
               the attribute  to be removed from this database
  Example    : $attribute_adaptor->remove($attribute);
 Description : removes an attribute in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $attribute) = @_;
  if( ! defined $attribute->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
 
  my $sth= $self->prepare( "delete attribute a from attribute a where a.attribute_id = ? " );
  $sth->execute($attribute->dbID());
  return 1;

}




1;
