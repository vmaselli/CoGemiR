#
# Module for Bio::Cogemir::DBSQL::HspAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 
Bio::Cogemir::DBSQL::HspAdaptor

=head1 SYNOPSIS

    $hsp_adaptor = $dbadaptor->get_HspAdaptor();

    $hsp = $hsp_adaptor->fetch_by_dbID();

    $hsp = $hsp_adaptor->fetch_by_query_id();
	
=head1 LENGTH

    This adaptor work with the hsp table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::HspAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Hsp;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Hsp
  Example    : $hsp = $hsp_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an hsp from the database via its internal id
  Returnseq : Bio::Cogemir::Hsp
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a hsp id") unless $dbID;

    my $query = qq {
    SELECT hit_id, percent_identity, seq_id, length, p_value, frame, start, end
      FROM hsp 
      WHERE  hsp_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($hit_id, $percent_identity, $seq_id,  $length, $p_value, $frame, $start, $end) = $sth->fetchrow_array();
   unless (defined $hit_id){
    	$self->warn("no hsp for $dbID");
    	return undef;
    }
    my $seq_obj = $self->db->get_SeqAdaptor->fetch_by_dbID($seq_id);
    my $hit_obj = $self->db->get_HitAdaptor->fetch_by_dbID($hit_id);
    my $hsp =  Bio::Cogemir::Hsp->new(  
	                            -DBID             => $dbID,
	                            -ADAPTOR          => $self,
                              -HIT              => $hit_obj, 
                              -PERCENT_IDENTITY => $percent_identity, 
                              -LENGTH           => $length,
                              -P_VALUE          => $p_value,
                              -FRAME            => $frame,
                              -SEQ              => $seq_obj, 
                              -START            => $start,
                              -END              => $end				                                                   
							    );


    return $hsp;
}

=head2 fetch_by_hit_id

  Arg [1]    : internal id of Hsp
  Example    : $hsp = $hsp_adaptor->fetch_by_hit_id($hit_id);
  Description: Retrieves an hsp from the database via its internal id
  Returnseq : listref Bio::Cogemir::Hsp
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hit_id {
    my ($self, $value) = @_;
    $self->throw("I need a hit id") unless $value;

    my $return;
    
    my $sql = qq{SELECT hsp_id FROM hsp WHERE hit_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_percent_identity

  Arg [1]    : internal id of Hsp
  Example    : $hsp = $hsp_adaptor->fetch_by_percent_identity($percent_identity);
  Description: Retrieves an hsp from the database via its internal id
  Returnseq : Bio::Cogemir::Hsp
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_percent_identity {
    my ($self, $value) = @_;
    $self->throw("I need a hit id") unless $value;

    my $return;
    
    my $sql = qq{SELECT hsp_id FROM hsp WHERE percent_identity = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT hsp_id
		FROM hsp
		WHERE hit_id = ? and percent_identity = ? and seq_id = ?  and length = ? and p_value = ? and frame = ? and start = ? and end = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->hit->dbID, $obj->percent_identity, $obj->seq->dbID, $obj->length, $obj->p_value, $obj->frame, $obj->start, $obj->end);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Hsp
               the hsp  to be stored in this database
  Example    : $hsp_adaptor->store($hsp);
 Description : Stores an hsp in the database
  Returnseq : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $hsp ) = @_;
    #if it is not an hsp dont store
    if( ! $hsp->isa('Bio::Cogemir::Hsp') ) {
	    $self->throw("$hsp is not a Bio::Cogemir::Hsp object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($hsp->can('dbID') && $hsp->dbID) {return $hsp->dbID();}
  if ($self->_exists($hsp)) {return $self->_exists($hsp); } 
 	unless ($hsp->hit->dbID){$self->db->get_HitAdaptor->store($hsp->hit)}
 	unless ($hsp->seq->dbID){$self->db->get_SeqAdaptor->store($hsp->seq)}
 	
 	

    #otherwise store the information being passed
    my $sql = q {INSERT INTO hsp SET hit_id = ?, percent_identity = ?, seq_id = ?, length = ?, p_value = ?, frame = ?, start = ?, end = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($hsp->hit->dbID, $hsp->percent_identity, $hsp->seq->dbID,  $hsp->length, $hsp->p_value, $hsp->frame, $hsp->start, $hsp->end);
    
    my $hsp_id = $sth->{'mysql_insertid'};
    $hsp->dbID($hsp_id);
    $hsp->adaptor($self);
    return $hsp_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Hsp
               the hsp  to be removed in this database
  Example    : $hsp_adaptor->remove($hsp);
 Description : removes an hsp in the database
  Returnseq : boolean
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $hsp) = @_;
  
  if( ! defined $hsp->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  $self->db->get_HitAdaptor->_remove($hsp->hit);
  $self->db->get_BlastAdaptor->_remove($hsp->hit->blast);
  $self->db->get_SeqAdaptor->_remove($hsp->seq);
  my $sth= $self->prepare( "delete from hsp where hsp_id = ? " );
  $sth->execute($hsp->dbID());
  
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Hsp
               the hsp  to be removed in this database
  Example    : $hsp_adaptor->remove($hsp);
 Description : removes an hsp in the database
  Returnseq : boolean
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $hsp) = @_;
    
    if( ! defined $hsp->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
   
    my $sth= $self->prepare( "delete from hsp where hsp_id = ? " );
    $sth->execute($hsp->dbID());
    
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Hsp
               the hsp  to be updated in this database
  Example    : $hsp_adaptor->update($hsp);
 Description : updates an hsp in the database
  Returnseq : Bio::Cogemir::Hsp
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $hsp) = @_;
    if( ! $hsp->isa('Bio::Cogemir::Hsp') ) {
	    $self->throw("$hsp is not a Bio::Cogemir::Hsp object - not storing!");
    }
    my $sql = q { 
	UPDATE hsp SET hit_id = ?, percent_identity = ?, seq_id = ?,   length = ?, p_value = ?, frame = ?, start = ?, end = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($hsp->hit->dbID, $hsp->percent_identity, $hsp->seq->dbID, $hsp->length, $hsp->p_value, $hsp->frame, $hsp->start, $hsp->end);
    return $self->fetch_by_dbID($hsp->dbID);
}    
