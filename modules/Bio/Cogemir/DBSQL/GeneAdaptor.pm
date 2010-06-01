#
# Module for Bio::Cogemir::DBSQL::GeneAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::GeneAdaptor

=head1 SYNOPSIS

    $gene_adaptor = $db->get_GeneAdaptor();

    $gene =  $gene_adaptor->fetch_by_dbID();
=head1 DESCRIPTION

    This adaptor work with the gene table 



=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::GeneAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Gene;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of gene
  Example    : $gene = $gene_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an gene from the database via its internal id
  Returntype : Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    #print "G FETCH BY DBID\n";
    $self->throw("I need a gene id") unless $dbID;

    my $query = qq {
    SELECT  g.attribute_id, g.biotype, g.label, g.conservation_score, d.direction
      FROM gene g, direction d, micro_rna mr 
      WHERE  mr.hostgene_id = g.gene_id and d.micro_rna_id = mr.micro_rna_id  and d.gene_id = g.gene_id and g.gene_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	  my ($attribute_id, $biotype, $label, $conservation_score,$direction) = $sth->fetchrow_array();
    #print $self, " $dbID $attribute_id,  $biotype, $label, $conservation_score,$direction line 73\n";

    unless ($attribute_id ){
    	$self->warn("no gene for $dbID in GeneAdaptor line 72");
    	return undef;
    }
   
    #print $self, " $dbID line 75\n";
	 my $attribute_obj = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id) ;
   	my $gene =  Bio::Cogemir::Gene->new(   
							    -DBID =>$dbID,
							    -ADAPTOR => $self,
							    -ATTRIBUTE => $attribute_obj,
							    -BIOTYPE => $biotype,
							    -LABEL => $label,
							    -CONSERVATION_SCORE => $conservation_score,
							    -DIRECTION => $direction
							   );
    return $gene;
}

=head2 _fetch_by_dbID_light
   internal subroutine
  Arg [1]    : internal id of gene
  Example    : $gene = $gene_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an gene from the database via its internal id
  Returntype : Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub _fetch_by_dbID_light {
    my ($self, $dbID) = @_;
    #print "G FETCH BY DBID\n";
    $self->throw("I need a gene id") unless $dbID;

    my $query = qq {
    SELECT  g.attribute_id, g.biotype, g.label, g.conservation_score, d.direction
      FROM gene g, direction d, micro_rna mr 
      WHERE  mr.hostgene_id = g.gene_id and d.micro_rna_id = mr.micro_rna_id  and d.gene_id = g.gene_id and g.gene_id = $dbID 
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($attribute_id, $biotype, $label, $conservation_score, $direction) = $sth->fetchrow_array();
    unless ($attribute_id ){
    	$self->throw("no gene for $dbID in GeneAdaptor line 116");
    	return undef;
    }
    
    my $attribute_obj = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id)   if $attribute_id;
  
   	my $gene =  Bio::Cogemir::Gene->new(   
							    -DBID =>$dbID,
							    -ADAPTOR => $self,
							    -ATTRIBUTE => $attribute_obj,
							    -BIOTYPE => $biotype,
							    -LABEL => $label,
							    -CONSERVATION_SCORE => $conservation_score,
							    -DIRECTION => $direction
							   );

    return $gene;
}

=head2 get_All

  Arg [1]    : attribute_id of gene
  Example    : $gene = $gene_adaptor->get_All();
  Description: Retrieves all genes from the database 
  Returntype : listref of Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub get_All{
	my ($self) = @_;
	my $obj;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             };
	my $sth = $self->prepare($sql);
	$sth->execute();
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	return $obj;
}

=head2 get_all_dbID

  Arg [1]    : attribute_id of gene
  Example    : $gene = $gene_adaptor->get_all_dbID();
  Description: Retrieves an gene from the database via its attribute_id
  Returntype : listref of gene dbID
  Exceptions : none
  Caller     : general

=cut

sub get_all_dbID{
	my ($self) = @_;
	my $obj;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             };
	my $sth = $self->prepare($sql);
	$sth->execute();
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$dbID);
	}
	return $obj;
}

=head2 get_all_stable_id

  Arg [1]    : attribute_id of gene
  Example    : $gene = $gene_adaptor->get_all_stable_id();
  Description: Retrieves an gene from the database via its attribute_id
  Returntype : listref of gene stable_id
  Exceptions : none
  Caller     : general

=cut

sub get_all_stable_id{
	my ($self) = @_;
	my $obj;
	my $sql = qq{SELECT distinct(m.gene_stable_id)
	             FROM gene g, attribute m
	             WHERE g.attribute_id = m.attribute_id
	             };
	my $sth = $self->prepare($sql);
	$sth->execute();
	while (my $stable_id = $sth->fetchrow_array){
		push (@{$obj} ,$stable_id);
	}
	return $obj;
}

sub get_all_external_name{
	my ($self) = @_;
	my $obj;
	my $sql = qq{select m.external_name from attribute m, gene g where m.attribute_id = g.attribute_id
	             };
	my $sth = $self->prepare($sql);
	$sth->execute();
	while (my $name = $sth->fetchrow_array){
	  #print ref $self, "$name line 223 <br>\n";
		push (@{$obj} ,$name);
	}
	return $obj;
}

=head2 get_all_transcripts

  Arg [1]    : attribute_id of gene
  Example    : $gene = $gene_adaptor->get_all_transcripts();
  Description: Retrieves an gene from the database via its attribute_id
  Returntype : listref of gene transcripts
  Exceptions : none
  Caller     : general

=cut

sub get_all_Transcripts{
	my ($self, $value) = @_;
	my $obj;
	my $sql = qq{SELECT t.transcript_id
	             FROM gene g, transcript t
	             WHERE g.gene_id = t.part_of
	             AND g.gene_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$self->db->get_TranscriptAdaptor->fetch_by_dbID($dbID));
	}
	return $obj;
}

=head2 fetch_by_attribute_id

  Arg [1]    : attribute_id of gene
  Example    : $gene = $gene_adaptor->fetch_by_attribute_id(34);
  Description: Retrieves an gene from the database via its attribute_id
  Returntype : Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_attribute_id{
	my ($self, $value) = @_;
	$self->throw("I need a attribute_id") unless $value;
	my $obj;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             WHERE attribute_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->_fetch_by_dbID_light($dbID) if defined $dbID;
  #print ref $self," attribute id = $dbID line 265<br>\n" if defined $dbID;

	return $obj;
}

=head2 fetch_by_stable_id

  Arg [1]    : stable_id of gene
  Example    : $gene = $gene_adaptor->fetch_by_stable_id('ENSG0000003456');
  Description: Retrieves an gene from the database via its stable_id
  Returntype : Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_stable_id{
	my ($self, $value) = @_;
	$self->throw("I need a stable_id") unless $value;
	my $obj;
	my $sql = qq{SELECT g.gene_id 
	             FROM gene g, attribute m
	             WHERE g.attribute_id = m.attribute_id
	             AND m.gene_stable_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$self->_fetch_by_dbID_light($dbID));
	}
	return $obj;
}

=head2 fetch_by_label

  Arg [1]    : label of gene
  Example    : $gene = $gene_adaptor->fetch_by_label(12);
  Description: Retrieves an gene from the database via its label
  Returntype : listref of Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_label{
	my ($self, $value) = @_;
	$self->throw("I need a label") unless $value;
	my $obj;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             WHERE label = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@$obj, $self->fetch_by_dbID($dbID));
	}
	return $obj;
}

=head2 fetch_by_location_id

  Arg [1]    : location_id of gene
  Example    : $gene = $gene_adaptor->fetch_by_location_id(12);
  Description: Retrieves an gene from the database via its location_id
  Returntype : Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_location_id{
	my ($self, $value) = @_;
	$self->throw("I need a location_id") unless $value;
	my $obj;
	my $sql = qq{SELECT g.gene_id 
	             FROM gene g, attribute a
	             WHERE g.attribute_id = a.attribute_id
	             AND a.location_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if $dbID;
	
	return $obj;
}


=head2 fetch_by_biotype

  Arg [1]    : biotype of gene
  Example    : $gene = $gene_adaptor->fetch_by_biotype('ENSG0000001234');
  Description: Retrieves an gene from the database via its biotype term
  Returntype : listref of Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_biotype{
	my ($self, $value) = @_;
	$self->throw("I need a biotype") unless $value;
	my @objs;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             WHERE biotype = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 get_all_MicroRNAs

  Arg [1]    : dbID
  Example    : $gene = $gene_adaptor->get_all_MicroRNAs($dbID);
  Description: Retrieves all microRNAs which have gene as hostgene from the database 
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub get_all_MicroRNAs{
	my ($self,$dbID) = @_;
	#print "G GET ALL MIRNA\n";
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id
	             FROM micro_rna mr, gene g
	             WHERE g.gene_id =  mr.hostgene_id
	             AND g.gene_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($dbID);
	my $count = 0;
	while (my $mr_dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count micro_rna for gene\n";
		push (@objs, $self->db->get_MicroRNAAdaptor->fetch_by_dbID($mr_dbID));
	}
	return \@objs;
}

sub get_all_symatlas_annotation {
    my ($self, $dbID) = @_;
    my @genes;
    my $sql = qq{select symatlas_annotation_id from symatlas_annotation_gene where gene_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($dbID);
    while (my $gene_id = $sth->fetchrow_array){
        push (@genes, $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($gene_id));
    }
    return \@genes;
}


=head2 fetch_by_genome_db_id

  Arg [1]    : genome_db_id of gene
  Example    : $gene = $gene_adaptor->fetch_by_genome_db_id('ENSG0000001234');
  Description: Retrieves an gene from the database via its genome_db_id term
  Returntype : listref of Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_genome_db_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_db_id") unless $value;
	my $obj;
	my $sql = qq{SELECT g.gene_id 
	             FROM gene g, attribute a
	             WHERE g.attribute_id = a.attribute_id
	             AND a.genome_db_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
	    push (@{$obj}, $self->fetch_by_dbID($dbID));
	}
	return $obj;
}

=head2 fetch_by_conservation_score

  Arg [1]    : conservation_score of gene
  Example    : $gene = $gene_adaptor->fetch_by_conservation_score('ENSG0000001234');
  Description: Retrieves an gene from the database via its conservation_score term
  Returntype : listref of Bio::Cogemir::Gene
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_conservation_score{
	my ($self, $value) = @_;
	$self->throw("I need a conservation_score") unless $value;
	my @objs;
	my $sql = qq{SELECT gene_id 
	             FROM gene
	             WHERE conservation_score = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub get_all_Features{
	my ($self, $dbID) = @_;
	return $self->db->get_FeatureAdaptor->fetch_by_gene($dbID);
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $sql = q { 
	SELECT gene_id FROM gene WHERE  attribute_id = ?  and biotype = ? and label = ? and conservation_score = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($obj->attribute->dbID(),  
                  $obj->biotype,$obj->label,$obj->conservation_score);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Gene
               the gene  to be stored in this database
  Example    : $gene_adaptor->store($gene);
 Description : Stores an gene in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $gene ) = @_;


    #if it is not an gene dont store
    if( ! $gene->isa('Bio::Cogemir::Gene') ) {
	$self->throw("$gene is not a Bio::Cogemir::Gene object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($gene->can('dbID') && $gene->dbID) {return $gene->dbID();}
    if ($self->_exists($gene)){return $self->_exists($gene);}
   
   	unless($gene->attribute->dbID){$self->db->get_AttributeAdaptor->store($gene->attribute)};
  

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO gene SET  attribute_id = ?, biotype = ?, label = ?, conservation_score = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($gene->attribute->dbID(),
                  $gene->biotype,$gene->label,$gene->conservation_score);
    my $gene_id = $sth->{'mysql_insertid'};
    #print "STORED $gene_id\n";
    $gene->dbID($gene_id);
    $gene->adaptor($self);
    return $gene_id;
}

=head2 update

  Arg [1]    : Bio::Cogemir::Gene
               the gene  to be updated in this database
  Example    : $gene_adaptor->update($gene);
 Description : updates an gene in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $gene) = @_;
        if( ! $gene->isa('Bio::Cogemir::Gene') ) {
	$self->throw("$gene is not a Bio::Cogemir::Gene object - not storing!");
    }
    my $sql = q { 
	UPDATE gene SET  attribute_id = ?, location_id = ?, attribute_id = ?, biotype = ?, label = ?, conservation_score = ?,  where gene_id = ?};
    my $sth = $self->prepare($sql);
  #printf "UPDATE gene SET  attribute_id = %d, location_id = %d, attribute_id = %d, biotype = %s, label = %s, conservation_score = %s where gene_id = %d\n",($gene->attribute->dbID(), $gene->location->dbID,  $gene->attribute->dbID,
    #               $gene->biotype,$gene->label,$gene->conservation_score, $gene->dbID);
#     $sth->execute($gene->attribute->dbID(), $gene->location->dbID,  $gene->attribute->dbID,
#                   $gene->biotype,$gene->label,$gene->conservation_score, $gene->dbID);
    return $self->fetch_by_dbID($gene->dbID);
    
}    


=head2 remove

  Arg [1]    : Bio::Cogemir::Gene
               the gene  to be removed from this database
  Example    : $gene_adaptor->remove($gene);
 Description : removes an gene in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $gene) = @_;
    #print $self, " REMOVE \n";
   
    unless (defined $gene){
    	$self->throw("gene is not defined\n");
    }	
    if( ! defined $gene->dbID() ) {
		$self->throw("A dbID is not defined\n");
    }
   
    $self->db->get_AttributeAdaptor->_remove($gene->attribute) if $gene->attribute; 
    #print "attribute removed\n";
    
    #print $self, " line 627\n";
    
    my $sth = $self->prepare("update micro_rna set hostgene_id = NULL where hostgene_id = ?");
    $sth->execute($gene->dbID());
    
     
    $sth= $self->prepare( "delete from gene where gene_id = ? " );
    $sth->execute($gene->dbID());
    
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Gene
               the gene  to be removed from this database
  Example    : $gene_adaptor->remove($gene);
 Description : removes an gene in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $gene) = @_;
    #print "G REMOVE $tag\n";
    #print $self." _remove\n";
    unless (defined $gene){
    	$self->throw("gene is not defined\n");
    }	
    if( ! defined $gene->dbID() ) {
		$self->throw("A dbID is not defined\n");
    }
    
    my $sth= $self->prepare( "delete from gene where gene_id = ? " );
    $sth->execute($gene->dbID());
    
    return 1;

}


1;
