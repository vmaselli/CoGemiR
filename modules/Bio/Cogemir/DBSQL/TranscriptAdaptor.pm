#
# Module for Bio::Cogemir::DBSQL::TranscriptAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 STABLE_ID

Bio::Cogemir::DBSQL::CSTAdaptor

=head1 SYNOPSIS

    $transcript_adaptor = $db->get_TranscriptAdaptor();

    $transcript = $transcript_adaptor->fetch_by_dbID();

    $transcript = $transcript_adaptor->fetch_by_stable_id();

=head1 DESCRIPTION

    This adaptor work with the transcript table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::TranscriptAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Bio::Cogemir::Transcript;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Transcript
  Example    : $transcript = $ln_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an transcript from the database via its internal id
  Returntype : Bio::Cogemir::Transcript
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a transcript id") unless $dbID;
    my $query = qq {
    SELECT part_of, attribute_id
      FROM transcript 
      WHERE  transcript_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($gene_id, $attribute_id) = $sth->fetchrow_array();
    unless (defined $attribute_id){
    	$self->warn("no transcript for $dbID");
    	return undef;
    }
    my $gene = $self->db->get_GeneAdaptor->_fetch_by_dbID_light($gene_id) ;
    my $attribute = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id) ;
    #my $exons = $self->get_all_exons($dbID);
    #my $introns = $self->get_all_introns($dbID);
    
    my ($transcript) =  Bio::Cogemir::Transcript->new(   
							    -DBID => $dbID,
							    -ADAPTOR =>$self,
							    -PART_OF => $gene,
							    -ATTRIBUTE => $attribute
							   );


    return $transcript;
}

=head2 get_All

  Arg [1]    : none
  Example    : $transcript = $cst_adaptor->get_All;
  Description: Retrieves an transcript from the database via its stable_id
  Returntype : Bio::Cogemir::Transcript
  Exceptions : none
  Caller     : general

=cut

sub get_All {
    my ($self) = @_;
    
    my $transcript;
    my $query = qq {
    SELECT transcript_id
      FROM transcript 
     };
    
    my $sth = $self->prepare($query);
    $sth->execute();
	while (my $dbID = $sth->fetchrow_array()){ 
        push (@{$transcript}, $self->fetch_by_dbID($dbID));
    }
    return $transcript;
}


=head2 fetch_by_stable_id

  Arg [1]    : transcript stable_id
  Example    : $transcript = $cst_adaptor->fetch_by_stable_id($stable_id);
  Description: Retrieves an transcript from the database via its stable_id
  Returntype : Bio::Cogemir::Transcript
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_stable_id {
    my ($self, $value) = @_;
    
    $self->throw("I need a stable_id") unless $value;
    my $transcript;
    my $query = qq {
    SELECT t.transcript_id
      FROM transcript t, attribute a
      WHERE  t.attribute_id = a.attribute_id and a.stable_id = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	while (my $dbID = $sth->fetchrow_array()){ 
        push (@{$transcript}, $self->fetch_by_dbID($dbID));
    }
    return $transcript;
}

=head2 fetch_by_gene_id

  Arg [1]    : transcript gene_id
  Example    : $transcript = $cst_adaptor->fetch_by_gene_id($gene_id);
  Description: Retrieves an transcript from the database via its gene_id
  Returntype : Bio::Cogemir::Transcript
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_part_of {
    my ($self, $value) = @_;
    
    $self->throw("I need a part_of") unless $value;

    my $query = qq {
    SELECT transcript_id
      FROM transcript 
      WHERE  part_of = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	my ($dbID) = $sth->fetchrow_array();
    unless (defined $dbID){return undef;} 
    my $transcript = $self->fetch_by_dbID($dbID);
    return $transcript;
}

=head2 get_all_exons
    
 Title    : All_exons
 Usage    : $obj->All_exons ($newval)
 Transcript : get/set method for attribute All_exons
 Returns  : Value of All_exons (string)
 Args     : New value of All_exons (optional)
    
=cut

sub get_all_exons{
    my ($self,$dbID) = @_;
    return unless $dbID;
    my $exons = $self->db->get_ExonAdaptor->fetch_by_part_of($dbID);
    return $exons;
}

=head2 get_all_introns
    
 Title    : All_introns
 Usage    : $obj->All_introns ($newval)
 Transcript : get/set method for attribute All_introns
 Returns  : Value of All_introns (string)
 Args     : New value of All_introns (optional)
    
=cut

sub get_all_introns{
    my ($self,$dbID) = @_;
    return unless $dbID;
    my $introns = $self->db->get_IntronAdaptor->fetch_by_part_of($dbID);
    return $introns;
}

=head2 get_localization

  Arg [1]    : transcript id
  Example    : $transcript = $transcript_adaptor->get_localization;
  Description: Retrieves an transcript from the database via its internal id
  Returnpre_intron : listref Bio::Cogemir::Transcript
  Exceptions : none
  Caller     : general

=cut

sub get_localization {
    my ($self,$dbID) = @_;
    $self->throw("I need a trascript id ") unless $dbID;
    my @tmp;
    my $localization = $self->db->get_LocalizationAdaptor->fetch_by_transcript($dbID);
    return unless $localization;
    unless ($localization->module_rank){
        #print "check for ".$localization->transcript->stable_id."\n";
        return;
    }
    if ($localization->label =~ /exon/){
        my $exon = $self->db->get_ExonAdaptor->fetch_by_part_of_rank($dbID, $localization->module_rank);
        $exon->position_relative_to_mirna('itself');
        push (@tmp, $exon);
    }
    elsif ($localization->label =~ /intron/){
        my $exon_left = $self->db->get_ExonAdaptor->fetch_by_part_of_rank($dbID, $localization->module_rank);
        if ($exon_left){
        $exon_left->position_relative_to_mirna('left');
        push (@tmp, $exon_left);
        }
        my $exon_right = $self->db->get_ExonAdaptor->fetch_by_part_of_rank($dbID, ($localization->module_rank + 1));
        if ($exon_right){
        $exon_right->position_relative_to_mirna('right');
        push (@tmp, $exon_right);
        }
    }
    return \@tmp;
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT transcript_id
		FROM transcript
		WHERE attribute_id = ? and part_of = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->attribute->dbID, $obj->part_of->dbID);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Gene
               the transcript  to be stored in this database
  Example    : $transcript_adaptor->store($transcript);
 Description : Stores an transcript in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $transcript ) = @_;
    #if it is not an transcript don't store
    if( ! $transcript->isa('Bio::Cogemir::Transcript') ) {
	$self->throw("$transcript is not a Bio::Cogemir::Transcript object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($transcript->can('dbID') && $transcript->dbID) {return $transcript->dbID();}  
    
    #if stable_id exists return without storing

    unless ($transcript->part_of->dbID){$self->db->get_GeneAdaptor->store($transcript->part_of); }

    if ($self->_exists($transcript)){return $self->_exists($transcript); }
    unless ($transcript->attribute->dbID){$self->db->get_AttributeAdaptor->store($transcript->attribute);}
    #otherwise store the information being passed
    my $sql = q {INSERT INTO transcript SET  part_of = ?, attribute_id = ?};

    my $sth = $self->prepare($sql);

    $sth->execute( $transcript->part_of->dbID, $transcript->attribute->dbID);
    
    my $transcript_id = $sth->{'mysql_insertid'};
    $transcript->dbID($transcript_id);
    $transcript->adaptor($self);
    return $transcript_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Transcript
               the transcript  to be removed in this database
  Example    : $transcript_adaptor->remove($transcript);
 Description : removes an transcript in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $transcript) = @_;
    
    if( ! defined $transcript->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    if (defined $self->get_all_exons){
    	foreach my $exon (@{$self->get_all_exons($transcript->dbID)}){
        	$self->db->get_ExonAdaptor->remove($exon);
    	}
    }
    if (defined $self->get_all_introns){
    	foreach my $intron (@{$self->get_all_introns($transcript->dbID)}){
        	$self->db->get_IntronAdaptor->remove($intron);
    	}
    }

    
    my $sth= $self->prepare( "delete from transcript where transcript_id = ? " );
    $sth->execute($transcript->dbID());
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Transcript
               the transcript  to be removed in this database
  Example    : $transcript_adaptor->remove($transcript);
 Description : removes an transcript in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $transcript) = @_;
    
    if( ! defined $transcript->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    my $sth= $self->prepare( "delete from transcript where transcript_id = ? " );
    $sth->execute($transcript->dbID());
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Transcript
               the transcript  to be updated in this database
  Example    : $transcript_adaptor->update($transcript);
 Description : updates an transcript in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    my ($self, $transcript) = @_;
    if( ! $transcript->isa('Bio::Cogemir::Transcript') ) {
	$self->throw("$transcript is not a Bio::Cogemir::Transcript object - not updating!");
    }
    my $sql = q {UPDATE transcript SET  part_of = ?, attribute_id = ?  WHERE transcript_id = ? };
    my $sth = $self->prepare($sql);
    #printf "UPDATE transcript SET stable_id = %s, part_of = %d, attribute_id = %d WHERE transcript_id = %d",$transcript->stable_id(),$transcript->part_of->dbID,$transcript->attribute->dbID,$transcript->dbID;
    $sth->execute($transcript->part_of->dbID,$transcript->attribute->dbID,$transcript->dbID);
    return $self->fetch_by_dbID($transcript->dbID);
}
1;
