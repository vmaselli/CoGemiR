#
# Module for Bio::Cogemir::DBSQL::LocationAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::LocationAdaptor

=head1 SYNOPSIS

    $location_adaptor = $db->get_LocationAdaptor();

    $location =  $location_adaptor->fetch_by_dbID();


=head1 DESCRIPTION

    This adaptor work with the location table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::LocationAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Location;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of location
  Example    : $location = $location_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an location from the database via its internal id
  Returntype : Bio::Cogemir::Location
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a location id") unless $dbID;

    my $query = qq {
    SELECT  CoordSystem, start, end, strand, name
      FROM location 
      WHERE  location_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ( $coord, $region_start, $region_end, $strand, $name) = $sth->fetchrow_array();
    unless (defined $name){
    	#$self->warn("no location for $dbID in LocationAdaptor line 71");
    	return undef;
    }
    
    my ($location) =  Bio::Cogemir::Location->new(   
							    -DBID 		=> $dbID,
							    -ADAPTOR 	=>$self,
							    -COORDSYSTEM => $coord,
							    -START 	=> $region_start,
							    -END 	=> $region_end,
							    -STRAND 	=> $strand,
							    -NAME	=> $name);

    return $location;
}

=head2 fetch_All

  Arg [1]    : 
  
  Example    : $location = $location_adaptor->fetch_All();
  Description: Retrieves all location from the database 
  Returntype : listreef of Bio::Cogemir::Location
  Exceptions : none
  Caller     : general

=cut

sub fetch_All{

	my ($self) = @_;
	my $region;
	my $query = qq {
		SELECT location_id	FROM location
	};
	my $sth = $self->prepare($query);
	$sth->execute( );
	while (my $dbID = $sth->fetchrow){
		push (@{$region},$self->fetch_by_dbID($dbID));
	}
	return $region;
}

=head2 fetch_by_region

  Arg [1]    : region name
  Arg [2]    : start
  Arg [3]    : end
  Arg [4]    : strand
  Example    : $location = $location_adaptor->fetch_by_region(3,16578,1763,-1);
  Description: Retrieves an location from the database via region definition
  Returntype : Bio::Cogemir::Location
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_region{

	my ($self, $name,$start,$end,$strand) = @_;
	my $region;
	my $query = qq {
		SELECT location_id	FROM location	WHERE start = ?	AND end = ?	AND strand = ? AND name = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute( $start, $end, $strand, $name);
	my $dbID = $sth->fetchrow;
	$region = $self->fetch_by_dbID($dbID) if $dbID;
	return $region;
}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $region = $self->fetch_by_region($obj->name,$obj->start,$obj->end,$obj->strand) ;
	$obj_id = $region->dbID if $region; 
	$obj->dbID($obj_id);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Location
               the location  to be stored in this database
  Example    : $location_adaptor->store($location);
 Description : Stores an location in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $location ) = @_;

    #if it is not an location dont store
    if( ! $location->isa('Bio::Cogemir::Location') ) {
	$self->throw("$location is not a Bio::Cogemir::Location object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($location->can('dbID') && $location->dbID) {return $location->dbID();}
    my $location_id = $self->_exists($location);
    if ($location_id ){return $location_id ;}
   	
    #otherwise store the information being passed
    
    my $sql = q { 
	INSERT INTO location SET  CoordSystem = ?, start = ?, end = ?, strand = ?, name = ?};
    my $sth = $self->prepare($sql);

    $sth->execute( $location->CoordSystem, $location->start(), $location->end(),  $location->strand(),$location->name);
    
   	$location_id = $sth->{'mysql_insertid'};
    $location->dbID($location_id);
    
    return $location_id;
}

=head2 update

  Arg [1]    : Bio::Cogemir::Location
               the location  to be updated in this database
  Example    : $location_adaptor->update($location);
 Description : updates an location in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $location) = @_;
    if( ! $location->isa('Bio::Cogemir::Location') ) {
	$self->throw("$location is not a Bio::Cogemir::Location object - not storing!");
    }
    my $sql = q { 
	  UPDATE location SET  CoordSystem = ?, start = ?, end = ?, strand = ?, name = ? WHERE location_id = ?};
    my $sth = $self->prepare($sql);
    #printf "UPDATE location SET  CoordSystem = %s, start = %d, end = %d, strand = %d, name = %s WHERE location_id = %d\n",( $location->CoordSystem, $location->start(), $location->end(),  $location->strand(),$location->name, $location->dbID); 
    $sth->execute( $location->CoordSystem, $location->start(), $location->end(),  $location->strand(),$location->name, $location->dbID);
    return $self->fetch_by_dbID($location->dbID);
    
}    


=head2 remove

  Arg [1]    : Bio::Cogemir::Location
               the location  to be removed from this database
  Example    : $location_adaptor->remove($location);
 Description : removes an location in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $location) = @_;
    
  if( ! defined $location->dbID() ) {
	  $self->throw("A dbID is not defined\n");
  }
  my $gene = $self->db->get_GeneAdaptor->fetch_by_location_id($location->dbID);
  $self->db->get_GeneAdaptor->_remove($gene) if $gene;
  my $micro_rna = $self->db->get_MicroRNAAdaptor->fetch_by_location_id($location->dbID);
  $self->db->get_MicroRNAAdaptor->_remove($micro_rna) if $micro_rna;
  my $symatlas_annotation = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_location_id($location->dbID) ;
  $self->db->get_SymatlasAnnotationAdaptor->_remove($symatlas_annotation) if $symatlas_annotation;
  
  my $sth= $self->prepare( "delete from location where location_id = ? " );
  $sth->execute($location->dbID());
  
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Location
               the location  to be removed from this database
  Example    : $location_adaptor->remove($location);
 Description : removes an location in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $location) = @_;
    return 0 unless $location;
    #print $self." _remove\n";
    if( ! defined $location->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }

    my $sth= $self->prepare( "delete from location where location_id = ? " );
    $sth->execute($location->dbID());
    
    return 1;

}

1;
