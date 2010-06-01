#
# Module for Bio::Cogemir::DBSQL::HitAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 BLAST

Bio::Cogemir::DBSQL::CSTAdaptor

=head1 SYNOPSIS

    $hit_adaptor = $db->get_CSTAdaptor();

    $hit = $hit_adaptor->fetch_by_dbID();

    $hit = $hit_adaptor->fetch_by_blast();

=head1 DESCRIPTION

    This adaptor work with the hit table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::HitAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Bio::Cogemir::Hit;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Hit
  Example    : $hit = $ln_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an hit from the database via its internal id
  Returntype : Bio::Cogemir::Hit
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a hit id") unless $dbID;
    my $query = qq {
    SELECT feature_id, blast_id
      FROM hit 
      WHERE  hit_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($feature_id, $blast_id) = $sth->fetchrow_array();
    unless (defined $blast_id or defined $feature_id){
    	#$self->warn("no hit for $dbID");
    	return undef;
    }
    my $blast = $self->db->get_BlastAdaptor->fetch_by_dbID($blast_id) ;
    my $feature = $self->db->get_FeatureAdaptor->fetch_by_dbID($feature_id);
    my ($hit) =  Bio::Cogemir::Hit->new(   
							    -DBID => $dbID,
							    -ADAPTOR =>$self,
							    -BLAST => $blast,
							    -FEATURE => $feature
							   );


    return $hit;
}

=head2 fetch_by_blast_id

  Arg [1]    : hit blast
  Example    : $hit = $cst_adaptor->fetch_by_blast_id(3);
  Description: Retrieves an hit from the database via its blast id
  Returntype : listref of Bio::Cogemir::Hit
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_blast_id {
    my ($self, $value) = @_;
    
    $self->throw("I need a blast id") unless $value;
    my @hit;
    my $query = qq {
    SELECT hit_id
      FROM hit 
      WHERE  blast_id = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	while(my ($dbID) = $sth->fetchrow_array()){
        push(@hit ,$self->fetch_by_dbID($dbID));
    }
    return \@hit;
}

=head2 fetch_by_feature_id

  Arg [1]    : hit feature id
  Example    : $hit = $cst_adaptor->fetch_by_feature_id(234);
  Description: Retrieves an hit from the database via its feature_id
  Returntype : listref of Bio::Cogemir::Hit
  Exceptions : none
  Caller     : general

=cut


sub fetch_by_feature {
    my ($self, $value) = @_;
    
    $self->throw("I need a feature_id") unless $value;
    my @hit;
    my $query = qq {
    SELECT hit_id
      FROM hit 
      WHERE  feature_id = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	  while(my ($dbID) = $sth->fetchrow_array()){
        push(@hit ,$self->fetch_by_dbID($dbID));
    }
    return \@hit;
}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT hit_id
		FROM hit
		WHERE feature_id = ? and blast_id = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->feature->dbID, $obj->blast->dbID);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Hit
               the hit  to be stored in this database
  Example    : $hit_adaptor->store($hit);
 Description : Stores an hit in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $hit ) = @_;


    #if it is not an hit don't store
    if( ! $hit->isa('Bio::Cogemir::Hit') ) {
	$self->throw("$hit is not a Bio::Cogemir::Hit object - not storing!");
    }
     if ($self->_exists($hit)){return $self->_exists($hit); }
    #if it has a dbID defined just return without storing
    if ($hit->can('dbID') && $hit->dbID) {return $hit->dbID();}  
    unless (defined $hit->feature->dbID){
        $self->db->get_FeatureAdaptor->store($hit->feature);
     }
     unless(defined $hit->blast->dbID){
        $self->db->get_BlastAdaptor->store($hit->blast);
     }
    #if blast exists return without storing
   

    #otherwise store the information being passed
    my $sql = q {INSERT INTO hit SET feature_id = ?, blast_id = ?};

    my $sth = $self->prepare($sql);

    $sth->execute($hit->feature->dbID, $hit->blast->dbID);
    
    my $hit_id = $sth->{'mysql_insertid'};
    $hit->dbID($hit_id);
    $hit->adaptor($self);
    return $hit_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Hit
               the hit  to be removed in this database
  Example    : $hit_adaptor->remove($hit);
 Description : removes an hit in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $hit) = @_;
    
    if( ! defined $hit->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    
    foreach my $hsp (@{$self->db->get_HspAdaptor->fetch_by_hit_id($hit->dbID)}){
        $self->db->get_HspAdaptor->remove($hsp);
    }
    $self->db->get_BlastAdaptor->_remove($hit->blast);
    my $sth= $self->prepare( "delete from hit where hit_id = ? " );
    $sth->execute($hit->dbID());
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Hit
               the hit  to be removed in this database
  Example    : $hit_adaptor->remove($hit);
 Description : removes an hit in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $hit) = @_;
    #print $self." _remove\n";
    if( ! defined $hit->dbID() ) {$self->throw("A dbID is not defined\n");}
     
    my $sth= $self->prepare( "delete from hit where hit_id = ? " );
    $sth->execute($hit->dbID());
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Hit
               the hit  to be updated in this database
  Example    : $hit_adaptor->update($hit);
 Description : updates an hit in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    my ($self, $hit) = @_;
    if( ! $hit->isa('Bio::Cogemir::Hit') ) {
	$self->throw("$hit is not a Bio::Cogemir::Hit object - not updating!");
    }

    my $sql = q {UPDATE hit SET feature_id = ?, blast_id = ?  WHERE hit_id = ? };
    my $sth = $self->prepare($sql);
    $sth->execute($hit->feature->dbID,$hit->blast->dbID,$hit->dbID);
    return $self->fetch_by_dbID($hit->dbID);
}
1;
