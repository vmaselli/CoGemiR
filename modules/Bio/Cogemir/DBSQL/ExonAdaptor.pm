#
# Module for Bio::Cogemir::DBSQL::ExonAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 
Bio::Cogemir::DBSQL::ExonAdaptor

=head1 SYNOPSIS

    $exon_adaptor = $dbadaptor->get_ExonAdaptor();

    $exon = $exon_adaptor->fetch_by_dbID();

    $exon = $exon_adaptor->fetch_by_query_id();
	
=head1 LENGTH

    This adaptor work with the exon table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::ExonAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Exon;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    $self->throw("I need a exon id") unless $dbID;

    my $query = qq {
    SELECT part_of, rank, pre_intron_id, post_intron_id, length, phase, attribute_id, type
      FROM exon 
      WHERE  exon_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($part_of, $rank, $pre_intron_id, $post_intron_id,  $length, $phase, $attribute_id, $type) = $sth->fetchrow_array();
   unless (defined $part_of){
    	$self->warn("no exon for $dbID");
    	return undef;
    }
    my $part_of_obj = $self->db->get_TranscriptAdaptor->fetch_by_dbID($part_of) if $part_of;
    my $attribute = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id);
    unless (defined $part_of_obj){
    	$self->warn("no exon for $dbID");
		my $sql = q { 
		UPDATE exon SET part_of = ? WHERE exon_id = ?};
    	my $sth = $self->prepare($sql);
    	$sth->execute('NULL', $dbID);
    	return undef;
    }
    my $exon =  Bio::Cogemir::Exon->new(  
	                            -DBID          => $dbID,
	                            -ADAPTOR     => $self,
							    -PART_OF     => $part_of_obj, 
							    -RANK         => $rank, 
							    -LENGTH                => $length,
							    -PHASE                => $phase,
							    -ATTRIBUTE => $attribute
							    );
    if ($pre_intron_id){
        my $pre_intron = $self->db->get_IntronAdaptor->fetch_by_dbID_light($pre_intron_id);
        $pre_intron->post_exon($exon);
        $exon->pre_intron($pre_intron);
    }
    if ($post_intron_id){
        my $post_intron = $self->db->get_IntronAdaptor->fetch_by_dbID_light($post_intron_id);
        $post_intron->pre_exon($exon);
        $exon->post_intron($post_intron);
    }
    my $localization = $self->db->get_LocalizationAdaptor->fetch_by_transcript($part_of);
    return $exon unless $localization;
    
    
    if ($localization->label =~ /exon/){
        my $exon_test = $self->db->get_ExonAdaptor->_test_by_part_of_rank($dbID, $localization->module_rank);
        $exon->position_relative_to_mirna('itself');
    }
    elsif ($localization->label =~ /intron/){
        my $exon_left = $self->db->get_ExonAdaptor->_test_by_part_of_rank($dbID, $localization->module_rank);
        if ($exon_left){$exon->position_relative_to_mirna('left');}
        my $exon_right = $self->db->get_ExonAdaptor->_test_by_part_of_rank($dbID, ($localization->module_rank + 1));
        if ($exon_right){$exon->position_relative_to_mirna('right');}
    }
    return $exon;
}
=head2 fetch_by_dbID_light

  Arg [1]    : internal id of Exon
  Example    : $exon = $exon_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID_light {
  my ($self, $dbID) = @_;
  
  $self->throw("I need a exon id") unless $dbID;

  my $query = qq {
  SELECT part_of, rank, pre_intron_id, post_intron_id, length, phase, attribute_id, type
    FROM exon 
    WHERE  exon_id = $dbID  
};

  my $sth = $self->prepare($query);
  $sth->execute();
my ($part_of, $rank, $pre_intron_id, $post_intron_id,  $length, $phase, $attribute_id, $type) = $sth->fetchrow_array();
 unless (defined $part_of){
    $self->warn("no exon for $dbID");
    return undef;
  }
  my $part_of_obj = $self->db->get_TranscriptAdaptor->fetch_by_dbID($part_of);
  my $attribute = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id);
    my $exon =  Bio::Cogemir::Exon->new(  
	                            -DBID          => $dbID,
	                            -ADAPTOR     => $self,
							    -PART_OF     => $part_of_obj, 
							    -RANK         => $rank, 
							    -LENGTH                => $length,
							    -PHASE                => $phase,
							    -ATTRIBUTE => $attribute,
							    -TYPE =>$type
							    );


    return $exon;
}

sub get_All{
    my ($self) = @_;
    my $jobs;
    my $sql = qq{select exon_id from exon};
    my $sth = $self->prepare($sql);
    $sth->execute;
    while (my $dbID = $sth->fetchrow_array){
        push (@{$jobs}, $self->fetch_by_dbID($dbID))
    }
    return $jobs;
}

=head2 fetch_by_part_of

  Arg [1]    : internal id of Exon
  Example    : $exon = $exon_adaptor->fetch_by_part_of($part_of);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : listref Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_part_of {
    my ($self, $value) = @_;
    $self->throw("I need a part_of ") unless $value;

    my $return;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_type

  Arg [1]    : type of Exon
  Example    : $exon = $exon_adaptor->fetch_by_type($type);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : listref Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_type {
    my ($self, $value) = @_;
    $self->throw("I need a type ") unless $value;

    my $return;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE type = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}
=head2 fetch_by_rank

  Arg [1]    : internal id of Exon
  Example    : $exon = $exon_adaptor->fetch_by_rank($rank);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_rank {
    my ($self, $value) = @_;
    $self->throw("I need a rank") unless $value;

    my $return;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE rank = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_part_of_rank

  Arg [1]    : internal id of Transcript, exon rank
  Example    : $exon = $exon_adaptor->fetch_by_part_of_rank($part_of,$rank);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : listref Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_part_of_rank {
    my ($self, $value1, $value2) = @_;
    $self->throw("I need a part_of ") unless $value1;
    $self->throw("I need a rank ") unless $value2;
    my $return;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE part_of = ? and rank = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value1, $value2);
    my ($dbID) = $sth->fetchrow_array;
    return $self->fetch_by_dbID($dbID) if $dbID;
}

sub _test_by_part_of_rank {
    my ($self, $value1, $value2) = @_;
    $self->throw("I need a part_of ") unless $value1;
    $self->throw("I need a rank ") unless $value2;
    my $return;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE part_of = ? and rank = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value1, $value2);
    my ($dbID) = $sth->fetchrow_array;
    return $self->fetch_by_dbID_light($dbID) if $dbID;
}



=head2 fetch_by_stable_id

  Arg [1]    : internal id of Exon
  Example    : $exon = $exon_adaptor->fetch_by_stable_id($stable_id);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_stable_id {
    my ($self, $value) = @_;
    $self->throw("I need a stable_id") unless $value;

    my $obj;
    
    my $sql = qq{SELECT e.exon_id FROM exon e, attribute a WHERE e.attribute_id = a.attribute_id AND a.stable_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    my ($dbID) = $sth->fetchrow_array;
    $obj = $self->fetch_by_dbID($dbID) if $dbID;
    return $obj;
}

=head2 fetch_by_stable_id_part_of

  Arg [1]    : internal id of Exon
  Example    : $exon = $exon_adaptor->fetch_by_stable_id_part_of($stable_id_part_of);
  Description: Retrieves an exon from the database via its internal id
  Returnpre_intron : Bio::Cogemir::Exon
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_stable_id_part_of {
    my ($self, $stable_id,$part_of) = @_;
    $self->throw("I need a stable_id and part_of") unless $stable_id;

    my $obj;
    
    my $sql = qq{SELECT e.exon_id FROM exon e, attribute a WHERE e.attribute_id = a.attribute_id AND a.stable_id = ? and e.part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($stable_id,$part_of);
    my ($dbID) = $sth->fetchrow_array;
    $obj = $self->fetch_by_dbID($dbID) if $dbID;
    return $obj;
}


=head2 fetch_by_pre_intron

  Arg [1]    : previous exon id of Intron
  Arg [2]    : part of
  Example    : $intron = $exon_adaptor->fetch_by_pre_intron(2);
  Description: Retrieves an intron from the database via exon id
  Return : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_pre_intron {
    my ($self, $pre_intron,$part_of) = @_;
    $self->throw("I need a intron id and part of") unless $pre_intron || $part_of;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE  pre_intron_id = ? and part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($pre_intron,$part_of);
    my ($dbID) = $sth->fetchrow_array;
    my $intron =  $self->fetch_by_dbID($dbID) if $dbID;
    return $intron;
   
}

=head2 fetch_by_post_intron

  Arg [1]    : postvious exon id of Intron
  Arg [2]    : part of
  Example    : $intron = $exon_adaptor->fetch_by_post_intron(2);
  Description: Retrieves an intron from the database via exon id
  Return : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_post_intron {
    my ($self, $post_intron,$part_of) = @_;
    $self->throw("I need a intron id and part of") unless $post_intron || $part_of;
    
    my $sql = qq{SELECT exon_id FROM exon WHERE  post_intron_id = ? and part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($post_intron,$part_of);
    my ($dbID) = $sth->fetchrow_array;
    my $intron =  $self->fetch_by_dbID($dbID) if $dbID;
    return $intron;
   
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	

	my $query = qq {
		SELECT exon_id
		FROM exon
		WHERE part_of = ?  and attribute_id = ? 
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->part_of->dbID,  $obj->attribute->dbID);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Exon
               the exon  to be stored in this database
  Example    : $exon_adaptor->store($exon);
 Description : Stores an exon in the database
  Returnpre_intron : none
  Exceptions :
  Caller     : general

=cut

sub store {
  my ( $self, $exon ) = @_;
  #if it is not an exon dont store=
  if( ! $exon->isa('Bio::Cogemir::Exon') ) {
    $self->throw("$exon is not a Bio::Cogemir::Exon object - not storing!");
  }

  #if it has a dbID defined just return without storing
  if ($exon->can('dbID') && $exon->dbID) {return $exon->dbID();}
   
  if ($self->_exists($exon)) {return $self->_exists($exon);}
   
  unless($exon->part_of->dbID){$self->db->get_TranscriptAdaptor->store($exon->part_of);}
  my $pre_intron_id;
 if ($exon->pre_intron){
    if ($exon->pre_intron->dbID){$pre_intron_id = $exon->pre_intron->dbID}
    else{$pre_intron_id = $self->db->get_IntronAdaptor->store($exon->pre_intron,1);}
  }
  my $post_intron_id;
  if ($exon->post_intron){
    if ($exon->post_intron->dbID){$post_intron_id = $exon->post_intron->dbID}
    else{$post_intron_id = $self->db->get_IntronAdaptor->store($exon->post_intron,1);}
  }
	
 	unless ($exon->attribute->dbID){$self->db->get_AttributeAdaptor->store($exon->attribute)}
 	
 	
    
    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO exon SET part_of = ?, rank = ?, pre_intron_id = ?,post_intron_id = ?, length = ?, phase = ?, attribute_id = ?, type = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($exon->part_of->dbID, $exon->rank, $pre_intron_id, $post_intron_id,  $exon->length, $exon->phase, $exon->attribute->dbID, $exon->type);
    my $exon_id = $sth->{'mysql_insertid'};
    $exon->dbID($exon_id);
    $exon->adaptor($self);
    return $exon_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Exon
               the exon  to be removed in this database
  Example    : $exon_adaptor->remove($exon);
 Description : removes an exon in the database
  Returnpre_intron : boolean
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $exon) = @_;
  if( ! $exon->isa('Bio::Cogemir::Exon') ) {
    $self->throw("$exon is not a Bio::Cogemir::Exon object - not updating!");
  }
  
  if( ! defined $exon->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  if ($exon->pre_intron ){
      $exon->pre_intron->post_exon->dbID(0);
      $self->db->get_IntronAdaptor->update($exon->pre_intron);
  }
  
  if ($exon->post_intron){
      $exon->post_intron->pre_exon->dbID(0);
      $self->db->get_IntronAdaptor->update($exon->post_intron);
  }

  my $sth= $self->prepare( "delete from exon where exon_id = ? " );
  $sth->execute($exon->dbID());
  
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Exon
               the exon  to be removed in this database
  Example    : $exon_adaptor->remove($exon);
 Description : removes an exon in the database
  Returnpre_intron : boolean
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $exon) = @_;
  if( ! $exon->isa('Bio::Cogemir::Exon') ) {
    $self->throw("$exon is not a Bio::Cogemir::Exon object - not updating!");
  }
  
  if( ! defined $exon->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  my $sth= $self->prepare( "delete from exon where exon_id = ? " );
  $sth->execute($exon->dbID());
  
  return 1;

}



=head2 update

  Arg [1]    : Bio::Cogemir::Exon
               the exon  to be updated in this database
  Example    : $exon_adaptor->update($exon);
 Description : updates an exon in the database
  Returnpre_intron : Bio::Cogemir::Exon
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $exon) = @_;
    my $pre_intron_id = $exon->pre_intron->dbID if $exon->pre_intron;
	my $post_intron_id = $exon->post_intron->dbID if $exon->post_intron;

    my $sql = q { 
	UPDATE exon SET part_of = ?, rank = ?, pre_intron_id = ?,   post_intron_id = ?,length = ?, phase = ?, attribute_id = ?, type = ? WHERE exon_id = ?};
  
    my $sth = $self->prepare($sql);
    $sth->execute($exon->part_of->dbID, $exon->rank, $pre_intron_id, $post_intron_id, $exon->length, $exon->phase, $exon->attribute->dbID, $exon->type, $exon->dbID);
    return $self->fetch_by_dbID($exon->dbID);
}    
