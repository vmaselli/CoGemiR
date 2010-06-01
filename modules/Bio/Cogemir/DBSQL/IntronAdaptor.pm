#
# Module for Bio::Cogemir::DBSQL::IntronAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 
Bio::Cogemir::DBSQL::IntronAdaptor

=head1 SYNOPSIS

    $intron_adaptor = $dbadaptor->get_IntronAdaptor();

    $intron = $intron_adaptor->fetch_by_dbID();

    $intron = $intron_adaptor->fetch_by_query_id();
	
=head1 LENGTH

    This adaptor work with the intron table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::IntronAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Intron;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Intron
  Example    : $intron = $intron_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an intron from the database via its internal id
  Returnpost_exon : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a intron id") unless $dbID;

    my $query = qq {
    SELECT part_of,  post_exon_id, pre_exon_id, length,  attribute_id
      FROM intron 
      WHERE  intron_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($part_of, $post_exon_id, $pre_exon_id,  $length,  $attribute_id) = $sth->fetchrow_array();
   unless (defined $part_of){
    	$self->warn("no intron for $dbID");
    	return undef;
    }
    my $part_of_obj = $self->db->get_TranscriptAdaptor->fetch_by_dbID($part_of);
    my $attribute_obj = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id);
    my $intron =  Bio::Cogemir::Intron->new(  
	                            -DBID          => $dbID,
	                            -ADAPTOR     => $self,
							    -PART_OF     => $part_of_obj, 
							    -LENGTH                => $length,
							    -ATTRIBUTE          => $attribute_obj				                                                   
							    );
    if  ($pre_exon_id){ 
        my $pre_exon = $self->db->get_ExonAdaptor->fetch_by_dbID_light($pre_exon_id) ;
        $pre_exon->post_intron($intron);
        my $rank =  $pre_exon->rank;
        my $phase =  $pre_exon->phase;
        $intron->pre_exon($pre_exon);
        $intron->rank($rank);
        $intron->phase($phase);
    }
     if ($post_exon_id){
        my $post_exon = $self->db->get_ExonAdaptor->fetch_by_dbID_light($post_exon_id);
        $post_exon->pre_intron($intron);
        $intron->post_exon($post_exon);
    }    
    return $intron;
   
    
    
    
}

=head2 fetch_by_dbID_light

  Arg [1]    : internal id of Intron
  Example    : $intron = $intron_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an intron from the database via its internal id
  Returnpost_exon : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID_light {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a intron id") unless $dbID;

    my $query = qq {
    SELECT part_of,  post_exon_id, pre_exon_id, length,  attribute_id
      FROM intron 
      WHERE  intron_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($part_of, $post_exon_id, $pre_exon_id,  $length,  $attribute_id) = $sth->fetchrow_array();
   unless (defined $part_of){
    	$self->warn("no intron for $dbID");
    	return undef;
    }
        my $attribute_obj = $self->db->get_LocationAdaptor->fetch_by_dbID($attribute_id);

    my $part_of_obj = $self->db->get_TranscriptAdaptor->fetch_by_dbID($part_of);
    my $intron =  Bio::Cogemir::Intron->new(  
	                            -DBID          => $dbID,
	                            -ADAPTOR     => $self,
							    -PART_OF     => $part_of_obj, 
							    -LENGTH                => $length,
							    -ATTRIBUTE          => $attribute_obj				                                                   
							    );


    return $intron;
}


=head2 fetch_by_part_of

  Arg [1]    : internal id of Intron
  Example    : $intron = $intron_adaptor->fetch_by_part_of($part_of);
  Description: Retrieves an intron from the database via its internal id
  Returnpost_exon : listref Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_part_of {
    my ($self, $value) = @_;
    $self->throw("I need a part_of ") unless $value;

    my $return;
    
    my $sql = qq{SELECT intron_id FROM intron WHERE part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_pre_exon

  Arg [1]    : previous exon id of Intron
  Arg [2]    : part of
  Example    : $intron = $intron_adaptor->fetch_by_pre_exon(2);
  Description: Retrieves an intron from the database via exon id
  Return : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_pre_exon {
    my ($self, $pre_exon,$part_of) = @_;
    $self->throw("I need a exon id and part of") unless $pre_exon || $part_of;
    
    my $sql = qq{SELECT intron_id FROM intron WHERE  pre_exon_id = ? and part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($pre_exon,$part_of);
    my ($dbID) = $sth->fetchrow_array;
    my $exon =  $self->fetch_by_dbID($dbID) if $dbID;
    return $exon;
}

=head2 fetch_by_post_exon

  Arg [1]    : postvious exon id of Intron
  Arg [2]    : part of
  Example    : $intron = $intron_adaptor->fetch_by_post_exon(2);
  Description: Retrieves an intron from the database via exon id
  Return : Bio::Cogemir::Intron
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_post_exon {
    my ($self, $post_exon,$part_of) = @_;
    $self->throw("I need a exon id and part of") unless $post_exon || $part_of;
    
    my $sql = qq{SELECT intron_id FROM intron WHERE  post_exon_id = ? and part_of = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($post_exon,$part_of);
    my ($dbID) = $sth->fetchrow_array;
    my $exon =  $self->fetch_by_dbID($dbID) if $dbID;
    return $exon;
   
}


sub _exists{
	my ($self, $obj) = @_;
	if( ! $obj->isa('Bio::Cogemir::Intron') ) {
	    $self->throw("$obj is not a Bio::Cogemir::Intron object - not test!");
    }
	my $obj_id;
	my $post_exon_id = $obj->post_exon->dbID if $obj->post_exon;
	my $pre_exon_id = $obj->pre_exon->dbID if $obj->pre_exon;

	my $query = qq {
		SELECT intron_id
		FROM intron
		WHERE part_of = ? and post_exon_id = ? and pre_exon_id = ?  and length = ? and attribute_id = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->part_of->dbID,  $post_exon_id, $pre_exon_id, $obj->length,  $obj->attribute->dbID);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Intron
               the intron  to be stored in this database
  Example    : $intron_adaptor->store($intron);
 Description : Stores an intron in the database
  Returnpost_exon : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $intron, $tag ) = @_;
    #if it is not an intron dont store
    if( ! $intron->isa('Bio::Cogemir::Intron') ) {
	    $self->throw("$intron is not a Bio::Cogemir::Intron object - not storing!");
    }
    #if it has a dbID defined just return without storing
    if ($intron->can('dbID') && $intron->dbID) {return $intron->dbID();}
        
    unless($intron->part_of->dbID){$self->db->get_TranscriptAdaptor->store($intron->part_of);}
     unless($intron->attribute->dbID){$self->db->get_AttributeAdaptor->store($intron->attribute);}
    my $pre_exon_id;
    if (defined $intron->pre_exon && !$tag){
        unless($intron->pre_exon->dbID){$pre_exon_id = $self->db->get_ExonAdaptor->store($intron->pre_exon);}
	    else{$pre_exon_id = $intron->pre_exon->dbID}
	}
	my $post_exon_id;
    if (defined $intron->post_exon && !$tag){
        unless($intron->post_exon->dbID){$post_exon_id = $self->db->get_ExonAdaptor->store($intron->post_exon);}
	    else{$post_exon_id = $intron->post_exon->dbID}
	}
 	if ($self->_exists($intron)) {return $self->_exists($intron);
 	}

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO intron SET part_of = ?,   post_exon_id = ?,pre_exon_id = ?, length = ?, attribute_id = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($intron->part_of->dbID, $post_exon_id, $pre_exon_id,  $intron->length, $intron->attribute->dbID);
    
    my $intron_id = $sth->{'mysql_insertid'};
    $intron->dbID($intron_id);

    $intron->adaptor($self);
    return $intron_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Intron
               the intron  to be removed in this database
  Example    : $intron_adaptor->remove($intron);
 Description : removes an intron in the database
  Returnpost_exon : boolean
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $intron) = @_;
    
    if( ! defined $intron->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    if ($intron->post_exon){
        $intron->post_exon->pre_intron->dbID(0);
        $self->db->get_ExonAdaptor->update($intron->post_exon);
    }
    
    if ($intron->pre_exon){
        $intron->pre_exon->post_intron->dbID(0);
        $self->db->get_ExonAdaptor->update($intron->pre_exon);
    }
    
    $self->db->get_LocationAdaptor->_remove($intron->attribute);

    my $sth= $self->prepare( "delete from intron where intron_id = ? " );
    $sth->execute($intron->dbID());
    
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Intron
               the intron  to be removed in this database
  Example    : $intron_adaptor->remove($intron);
 Description : removes an intron in the database
  Returnpost_exon : boolean
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $intron) = @_;
    
    if( ! defined $intron->dbID() ) {
	    $self->throw("A dbID is not defined\n");
    }
    my $sth= $self->prepare( "delete from intron where intron_id = ? " );
    $sth->execute($intron->dbID());
    
    return 1;

}



=head2 update

  Arg [1]    : Bio::Cogemir::Intron
               the intron  to be updated in this database
  Example    : $intron_adaptor->update($intron);
 Description : updates an intron in the database
  Returnpost_exon : Bio::Cogemir::Intron
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $intron) = @_;
        if( ! $intron->isa('Bio::Cogemir::Intron') ) {
	    $self->throw("$intron is not a Bio::Cogemir::Intron object - not updating!");
    }
    return $intron if $self->_exists($intron);
    my $post_exon_id = $intron->post_exon->dbID if $intron->post_exon;
	my $pre_exon_id = $intron->pre_exon->dbID if $intron->pre_exon;
	
    my $sql = q { 
	UPDATE intron SET part_of = ?,  post_exon_id = ?,   pre_exon_id = ?, length = ?,   attribute_id = ? WHERE intron_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($intron->part_of->dbID, $post_exon_id, $pre_exon_id, $intron->length, $intron->attribute->dbID, $intron->dbID);
    return $self->fetch_by_dbID($intron->dbID);
}    
