#
# Module for Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor

=head1 SYNOPSIS

    $symatlas_annotation_adaptor = $db->get_SymatlasAnnotationAdaptor();

    $symatlas_annotation =  $symatlas_annotation_adaptor->fetch_by_dbID();


=head1 DESCRIPTION

    This adaptor work with the symatlas_annotation table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an symatlas_annotation from the database via its internal id
  Returntype : Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a symatlas_annotation id") unless $dbID;

    my $query = qq {
    SELECT  genome_db_id, name, accession, probset_id, reporters,  LocusLink, RefSeq, Unigene, Ensembl,Uniprot,  aliases, description, function, protein_families
      FROM symatlas_annotation 
      WHERE  symatlas_annotation_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ( $genome_db_id,$name,$accession,$probset_id,$reporters,$locus_link,$refseq,$unigene,$ensembl,$uniprot,$aliases,$description,$function,$protein_families) = $sth->fetchrow_array();

    unless (defined $genome_db_id){
    	#self->warn("no symatlas_annotation for $dbID in SymatlasAnnotationAdaptor line 72");
    	return undef;
    }
    
    my $genome_obj = $self->db->get_GenomeDBAdaptor->fetch_by_dbID($genome_db_id) if $genome_db_id;
    my ($ensembl_gene,$ensembl_transcript,$ensembl_translation) = split /;/,$ensembl;
   	
   	my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
							    -DBID                => $dbID,
							    -ADAPTOR             => $self,
							    -GENOME_DB              => $genome_obj,
							    -ALIASES             => $aliases,
							    -DESCRIPTION         => $description,
							    -FUNCTION            => $function,
							    -NAME                => $name,
							    -ACCESSION           => $accession,
							    -PROBSET_ID          => $probset_id,
							    -REPORTERS           => $reporters,
							    -LOCUS_LINK          => $locus_link,
							    -REF_SEQ             => $refseq,
							    -UNIGENE             => $unigene,
							    -UNIPROT             => $uniprot,
							    -ENSEMBL_GENE        => $ensembl_gene,
							    -ENSEMBL_TRANSCRIPT  => $ensembl_transcript,
							    -ENSEMBL_TRANSLATION => $ensembl_translation,
							    
							    -PROTEIN_FAMILIES    => $protein_families
							   );
    return $symatlas_annotation;
}


sub get_All{
	my ($self) = @_;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation
	             };
	my $sth = $self->prepare($sql);
	$sth->execute();
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_genome_db_id

  Arg [1]    : genome_db_id of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_genome_db_id(34);
  Description: Retrieves an symatlas_annotation from the database via its genome_db_id
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_genome_db_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation
	             WHERE genome_db_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



=head2 fetch_by_ensembl

  Arg [1]    : ensembl of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_ensembl('ENSG0000001234');
  Description: Retrieves an symatlas_annotation from the database via its ensembl term
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_ensembl{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation
	             WHERE ensembl like ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute("%".$value."%");
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_ensembl_gene

  Arg [1]    : ensembl_gene of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_ensembl_gene($dbID);
  Description: Retrieves an symatlas_annotation from the database via its ensembl_gene
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_ensembl_gene{
	my ($self, $value) = @_;
	return $self->fetch_by_ensembl($value);
}

=head2 fetch_by_ensembl_transcript

  Arg [1]    : ensembl_transcript of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_ensembl_transcript($dbID);
  Description: Retrieves an symatlas_annotation from the database via its ensembl_transcript
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : transcriptral

=cut

sub fetch_by_ensembl_transcript{
	my ($self, $value) = @_;
	return $self->fetch_by_ensembl($value);
}

=head2 fetch_by_ensembl_translation

  Arg [1]    : ensembl_translation of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_ensembl_translation($dbID);
  Description: Retrieves an symatlas_annotation from the database via its ensembl_translation
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : translationral

=cut

sub fetch_by_ensembl_translation{
	my ($self, $value) = @_;
	return $self->fetch_by_ensembl($value);
}

=head2 fetch_by_refseq

  Arg [1]    : refseq of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_refseq('ENSG0000001234');
  Description: Retrieves an symatlas_annotation from the database via its refseq term
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_refseq{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation
	             WHERE RefSeq like ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute("%".$value."%");
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_all_by_tissue

  Arg [1]    : probset_id of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_all_by_tissue('ENSG0000001234');
  Description: Retrieves an symatlas_annotation from the database via its probset_id term
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_by_tissue{
	my ($self, $value) = @_;
	$self->throw("I need a tissue_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM expression 
	             WHERE tissue_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_probeset_id

  Arg [1]    : probset_id of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_probset_id('ENSG0000001234');
  Description: Retrieves an symatlas_annotation from the database via its probset_id term
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_probeset_id{
	my ($self, $value) = @_;
	$self->throw("I need a probset_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation
	             WHERE probset_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	#print ref $self, "line 299 ",scalar @objs,"\n";
	return \@objs;
}

=head2 fetch_all_by_member

  Arg [1]    : member_id of symatlas_annotation
  Example    : $symatlas_annotation = $symatlas_annotation_adaptor->fetch_by_member_id('ENSG0000001234');
  Description: Retrieves an symatlas_annotation from the database via its member_id term
  Returntype : listref of Bio::Cogemir::SymatlasAnnotation
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_by_gene{
	my ($self, $value) = @_;
	$self->throw("I need a gene_id") unless $value;
	my @objs;
	my $sql = qq{SELECT symatlas_annotation_id 
	             FROM symatlas_annotation_gene
	             WHERE gene_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub get_average{
  my ($self,$dbID) = @_;
  my %ref;
  my $sql = qq{select average, platform from expression_statistics where symatlas_annotation_id = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  while (my ($average, $platform) = $sth->fetchrow_array){
  	$ref{$platform} = $average;
  }
  return \%ref;
}

sub get_standard_deviation{
  my ($self,$dbID) = @_;
  my %ref;
  my $sql = qq{select standard_deviation, platform from expression_statistics where symatlas_annotation_id = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  while (my ($std, $platform) = $sth->fetchrow_array){
  	$ref{$platform} = $std;
  }
  return \%ref;

}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $ens_string;
	if ($obj->ensembl_gene){
	  $ens_string .= $obj->ensembl_gene.";";
	}
	if ($obj->ensembl_transcript){
	  $ens_string .= $obj->ensembl_transcript.";";
	}
	if ($obj->ensembl_translation){
	  $ens_string .= $obj->ensembl_translation;
	}
	my $sql = q { 
	SELECT symatlas_annotation_id FROM symatlas_annotation WHERE  genome_db_id = ? AND name = ? AND probset_id = ?
	             };
  my $sth = $self->prepare($sql);
  
  $sth->execute($obj->genome_db->dbID(), $obj->name, $obj->probset_id);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::SymatlasAnnotation
               the symatlas_annotation  to be stored in this database
  Example    : $symatlas_annotation_adaptor->store($symatlas_annotation);
 Description : Stores an symatlas_annotation in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $symatlas_annotation ) = @_;


    #if it is not an symatlas_annotation dont store
    if( ! $symatlas_annotation->isa('Bio::Cogemir::SymatlasAnnotation') ) {
	$self->throw("$symatlas_annotation is not a Bio::Cogemir::SymatlasAnnotation object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($symatlas_annotation->can('dbID') && $symatlas_annotation->dbID) {return $symatlas_annotation->dbID();}
    if ($self->_exists($symatlas_annotation)){return $self->_exists($symatlas_annotation);}
   
   	unless($symatlas_annotation->genome_db->dbID){$self->db->get_GenomeDBAdaptor->store($symatlas_annotation->genome_db)};
   	
    #otherwise store the information being passed
    my $ens_string;
    if ($symatlas_annotation->ensembl_gene){
	  $ens_string .= $symatlas_annotation->ensembl_gene
    }
    if ($symatlas_annotation->ensembl_transcript){
      $ens_string .= ";".$symatlas_annotation->ensembl_transcript
    }
    if ($symatlas_annotation->ensembl_translation){
      $ens_string .= ";".$symatlas_annotation->ensembl_translation
    }
    chop $ens_string;
    my $sql = q { 
	INSERT INTO symatlas_annotation SET  genome_db_id = ?, name = ?, accession = ?, probset_id = ?, reporters = ?,
	 LocusLink = ?, RefSeq = ?, Unigene = ?, Uniprot = ?, Ensembl = ?, aliases = ?, description = ?,
	function = ?, protein_families = ?
	             };
    my $sth = $self->prepare($sql);

    $sth->execute($symatlas_annotation->genome_db->dbID(), $symatlas_annotation->name,  $symatlas_annotation->accession,
                  $symatlas_annotation->probset_id,$symatlas_annotation->reporters, 
                  $symatlas_annotation->locus_link, $symatlas_annotation->refseq,$symatlas_annotation->unigene,
                  $symatlas_annotation->uniprot,$ens_string,
                  $symatlas_annotation->aliases,$symatlas_annotation->description,$symatlas_annotation->function,$symatlas_annotation->protein_families);
    my $symatlas_annotation_id = $sth->{'mysql_insertid'};
    $symatlas_annotation->dbID($symatlas_annotation_id);
    $symatlas_annotation->adaptor($self);
    return $symatlas_annotation_id;
}

=head2 update

  Arg [1]    : Bio::Cogemir::SymatlasAnnotation
               the symatlas_annotation  to be updated in this database
  Example    : $symatlas_annotation_adaptor->update($symatlas_annotation);
 Description : updates an symatlas_annotation in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $symatlas_annotation) = @_;
    if( ! $symatlas_annotation->isa('Bio::Cogemir::SymatlasAnnotation') ) {
	$self->throw("$symatlas_annotation is not a Bio::Cogemir::SymatlasAnnotation object - not updating!");
    }
    my $ens_string;
    if ($symatlas_annotation->ensembl_gene){
	  $ens_string .= $symatlas_annotation->ensembl_gene.";"
    }
    if ($symatlas_annotation->ensembl_transcript){
      $ens_string .= $symatlas_annotation->ensembl_transcript.";"
    }
    if ($symatlas_annotation->ensembl_translation){
      $ens_string .= $symatlas_annotation->ensembl_translation
    }
    my $sql = q { 
	UPDATE symatlas_annotation SET  genome_db_id = ?, name = ?, accession = ?, probset_id = ?, reporters = ?,
	, LocusLink = ?, RefSeq = ?, Unigene = ?, Uniprot = ?, Ensembl = ?, aliases = ?, description = ?,
	function = ?, protein_families = ? WHERE symatlas_annotation_id = ?
	             };
    my $sth = $self->prepare($sql);

    $sth->execute($symatlas_annotation->genome_db->dbID(), $symatlas_annotation->name,  $symatlas_annotation->accession,
                  $symatlas_annotation->probset_id,$symatlas_annotation->reporters, 
                  $symatlas_annotation->locus_link, $symatlas_annotation->refseq,$symatlas_annotation->unigene,
                  $symatlas_annotation->uniprot,$ens_string,
                  $symatlas_annotation->description,$symatlas_annotation->function,$symatlas_annotation->protein_families,$symatlas_annotation->aliases,$symatlas_annotation->dbID);
    return $self->fetch_by_dbID($symatlas_annotation->dbID);
    
}    


=head2 remove

  Arg [1]    : Bio::Cogemir::SymatlasAnnotation
               the symatlas_annotation  to be removed from this database
  Example    : $symatlas_annotation_adaptor->remove($symatlas_annotation);
 Description : removes an symatlas_annotation in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $symatlas_annotation) = @_;
  
  if( ! defined $symatlas_annotation->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  foreach my $expression (@{$self->db->get_ExpressionAdaptor->fetch_by_symatlas_annotation($symatlas_annotation->dbID)}){
    $self->db->get_ExpressionAdaptor->remove($expression);
  }
  
  my $sth= $self->prepare( "delete from symatlas_annotation where symatlas_annotation_id = ? " );
  $sth->execute($symatlas_annotation->dbID());
  
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::SymatlasAnnotation
               the symatlas_annotation  to be removed from this database
  Example    : $symatlas_annotation_adaptor->remove($symatlas_annotation);
 Description : removes an symatlas_annotation in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $symatlas_annotation) = @_;
  
  if( ! defined $symatlas_annotation->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  my $sth= $self->prepare( "delete from symatlas_annotation where symatlas_annotation_id = ? " );
  $sth->execute($symatlas_annotation->dbID());
  
  return 1;

}




1;
