#
# Module for Bio::Cogemir::DBSQL::BlastAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::BlastAdaptor

=head1 SYNOPSIS
	
	$dbadaptor = Bio::Cogemir::DBSQL->new (...);

    $blast_adaptor = $dbadaptor->get_BlastAdaptor();

    $blast = $blast_adaptor->fetch_by_dbID();

    $blast_listref = $blast_adaptor->fetch_by_logic_name();

=head1 DESCRIPTION

    Module to encapsulate all db access for persistent class Blast.
    This adaptor work with the blast table 


=head1 AUTHORS - 
s
Vincenza Maselli - maselli@tigem.it

=cut

package Bio::Cogemir::DBSQL::BlastAdaptor;

use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";

use Bio::Cogemir::Blast;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of Blast
  Example    : $blast = $blast_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an blast from the database via its internal id
  Returntype : Bio::Cogemir::Blast
  Exceptions : if argument is not defined or query doesn't give results 
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;  
    $self->throw("I need an blast id") unless $dbID;
    
	
    my $query = qq {
    SELECT feature_id,logic_name_id, length
      FROM blast 
      WHERE  blast_id =  ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($feature_id, $logic_name_id, $length)= $sth->fetchrow_array();
	unless ($feature_id){
    	$self->warn("no  blast for DBID $dbID in fetch_by_dbID");
    	return undef;
    }
    my $logic_name_obj;
	$logic_name_obj = $self->db->get_LogicNameAdaptor->fetch_by_dbID($logic_name_id) if $logic_name_id;
    my $feature;
	$feature = $self->db->get_FeatureAdaptor->fetch_by_dbID($feature_id) ;


    my $blast =  Bio::Cogemir::Blast->new(       
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -FEATURE => $feature,
							    -LENGTH =>$length,
							    -LOGIC_NAME =>$logic_name_obj
							   );


    return $blast;
}


=head2 fetch_by_feature_id

  Arg [1]    : feature of Blast
  Example    : $blast = $blast_adaptor->fetch_by_feature_id($value);
  Description: Retrieves an blast from the database via its value of creation
  Returntype : Bio::Cogemir::Blast
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_by_feature_id{

	my ($self, $value) = @_;
	$self->throw("I need a feature dbID") unless $value;
	my @ret;
	my $query = qq{select blast_id
				from blast
				where feature_id = ?};
	
	my $sth = $self->prepare($query);
	$sth->execute($value);
	while (my ($dbID)= $sth->fetchrow_array()){
	    push (@ret, $self->fetch_by_dbID($dbID));
	}

    return \@ret ;

}


=head2 fetch_by_logic_name

  Arg [1]    : logic name of Blast
  Example    : $blast = $blast_adaptor->fetch_by_logic_name_obj($logic_name_obj);
  Description: Retrieves an blast from the database via its logic name
  Returntype : list of Bio::Cogemir::Blast
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_by_logic_name{

	my ($self, $logic_name_id) = @_;
	$self->throw("I need a logic name") unless $logic_name_id;
	
	my $query = qq{ select a.blast_id
				    from blast a
					where a.logic_name_id =?};
	my $sth = $self->prepare($query);
	$sth->execute($logic_name_id);
	my ($blast_obj, @blast);
	while ((my $dbID) = $sth->fetchrow_array()){
		$blast_obj =  $self->fetch_by_dbID($dbID);
		push (@blast, $blast_obj);
	}
    unless (@blast){
    	$self->warn("no blast for NAME $logic_name_id ");
    	return undef;
    }

    return \@blast;

}

=head2 fetch_by_length

  Arg [1]    : logic name of Blast
  Example    : $blast = $blast_adaptor->fetch_by_length_obj($length_obj);
  Description: Retrieves an blast from the database via its logic name
  Returntype : list of Bio::Cogemir::Blast
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_by_length{

	my ($self, $length) = @_;
	$self->throw("I need a logic name") unless $length;
	
	my $query = qq{ select blast_id
				    from blast 
					where length  = ?};
	my $sth = $self->prepare($query);
	$sth->execute($length);
	my ($blast_obj, @blast);
	while ((my $dbID) = $sth->fetchrow_array()){
		$blast_obj =  $self->fetch_by_dbID($dbID);
		push (@blast, $blast_obj);
	}
    unless (@blast){
    	$self->warn("no blast for BLAST of $length length");
    	return undef;
    }

    return \@blast;

}

sub _exists {
    my ($self, $obj) = @_;
    my $logic_name_id = $obj->logic_name->dbID if defined $obj->logic_name;
    my $sql = qq{SELECT blast_id FROM blast WHERE feature_id = ? and logic_name_id = ? and  length =?};
    my $sth = $self->prepare($sql);
    $sth->execute($obj->feature->dbID, $logic_name_id, $obj->length);
    my $obj_id;
    $obj_id = $sth->fetchrow;
    return $obj_id;

}


=head2 store

  Arg [1]    : Bio::Cogemir::Blast
               the blast  to be stored in this database
  Example    : $blast_adaptor->store($blast);
  Description : Stores an blast in the database
  Returntype : integer
  Exceptions : arguments isn't a Bio::Cogemir::Blast obj
  Caller     : general

=cut

sub store {
    my ( $self, $blast ) = @_;

    #if it is not an blast dont store
    if( ! $blast->isa('Bio::Cogemir::Blast') ) {
	$self->throw("$blast is not a Bio::Cogemir::Blast object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($blast->can('dbID')) {
		if( $blast->dbID) {
	    	return $blast->dbID();
		}
    }  
    
    my $logic_name_dbID;
    if ($blast->logic_name){
        unless($blast->logic_name->dbID){$logic_name_dbID = $self->db->get_LogicNameAdaptor->store($blast->logic_name);}
        else{$logic_name_dbID = $blast->logic_name->dbID}
    }
    
    unless($blast->feature->dbID){$self->db->get_FeatureAdaptor->store($blast->feature);}

    if ($self->_exists($blast)){return $self->_exists($blast)}
   
    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO blast SET feature_id = ?,logic_name_id = ?,  length =?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($blast->feature->dbID, $logic_name_dbID,  $blast->length());
    
    my $blast_id = $sth->{'mysql_insertid'};
    $blast->dbID($blast_id);
    $blast->adaptor($self);
    return $blast_id;
}

=head2 remove

  Arg [1]     : Bio::Cogemir::Blast
               the blast  to be removed in this database
  Example     : $blast_adaptor->remove($blast);
  Description : Remove an blast in the database
  Returntype  : boolean
  Exceptions  : arguments isn't a Bio::Cogemir::Blast obj
  Caller      : general

=cut

sub remove {
    
  my ($self, $blast) = @_;
  if( ! defined $blast->dbID() ) {$self->throw("A dbID is not defined\n");}
  foreach my $hit (@{$self->db->get_HitAdaptor->fetch_by_blast_id($blast->dbID)}){
      $self->db->get_HitAdaptor->_remove($hit);
      foreach my $hsp (@{$self->db->get_HspAdaptor->fetch_by_hit_id($hit->dbID)}){
        $self->db->get_HspAdaptor->_remove($hsp);
      }
  }
  my $sth= $self->prepare( "delete from blast where blast_id = ? " );
  $sth->execute($blast->dbID());
  return 1;
}


=head2 _remove

  Arg [1]     : Bio::Cogemir::Blast
               the blast  to be removed in this database
  Example     : $blast_adaptor->remove($blast);
  Description : Remove an blast in the database
  Returntype  : boolean
  Exceptions  : arguments isn't a Bio::Cogemir::Blast obj
  Caller      : general

=cut

sub _remove {
    
    my ($self, $blast) = @_;
    
    if( ! defined $blast->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    my $sth= $self->prepare( "delete from blast where blast_id = ? " );
    $sth->execute($blast->dbID());
    
    return 1;

}

=head2 update

  Arg [1]     : Bio::Cogemir::Blast
               the blast  to be updated in this database
  Example     : $blast_adaptor->update($blast);
  Description : Update an blast in the database
  Returntype  : Bio::Cogemir::Blast
  Exceptions  : arguments isn't a Bio::Cogemir::Blast obj
  Caller      : general

=cut

sub update {
    my ( $self, $blast ) = @_;
        if( ! $blast->isa('Bio::Cogemir::Blast') ) {
	$self->throw("$blast is not a Bio::Cogemir::Blast object - not updating!");
    }

    if( ! defined $blast->dbID() ) {$self->throw("A dbID is not defined\n");}

    my $logic_name_id = $blast->logic_name->dbID if defined $blast->logic_name;
    my $sql = q {UPDATE blast SET feature_id = ?,logic_name_id = ?,  length = ? WHERE blast_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($blast->feature->dbID, $logic_name_id,  $blast->length, $blast->dbID);

    return $self->fetch_by_dbID($blast->dbID);
}

1;

