#
# Module for Bio::Cogemir::DBSQL::ClusterAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::CSTAdaptor

=head1 SYNOPSIS

    $cluster_adaptor = $db->get_ClusterAdaptor();

    $cluster = $cluster_adaptor->fetch_by_dbID();

    $cluster = $cluster_adaptor->fetch_by_name();

=head1 DESCRIPTION

    This adaptor work with the cluster table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::ClusterAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Bio::Cogemir::Cluster;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Cluster
  Example    : $cluster = $ln_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an cluster from the database via its internal id
  Returntype : Bio::Cogemir::Cluster
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a cluster id") unless $dbID;
    my $query = qq {
    SELECT name, analysis_id
      FROM cluster 
      WHERE  cluster_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($name, $analysis_id) = $sth->fetchrow_array();
    unless (defined $name){
    	#$self->warn("no cluster for $dbID");
    	return undef;
    }
    my $analysis = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id) if $analysis_id; 
    my ($cluster) =  Bio::Cogemir::Cluster->new(   
							    -DBID => $dbID,
							    -ADAPTOR =>$self,
							    -NAME => $name,
							    -ANALYSIS => $analysis
							   );


    return $cluster;
}

=head2 fetch_by_name

  Arg [1]    : cluster name
  Example    : $cluster = $cst_adaptor->fetch_by_name($name);
  Description: Retrieves an cluster from the database via its name
  Returntype : Bio::Cogemir::Cluster
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
    my ($self, $value) = @_;
    
    $self->throw("I need a name") unless $value;

    my $query = qq {
    SELECT cluster_id
      FROM cluster 
      WHERE  name = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	my ($dbID) = $sth->fetchrow_array();
    unless (defined $dbID){return undef;} 
    my $cluster = $self->fetch_by_dbID($dbID);
    return $cluster;
}

=head2 fetch_by_analysis_id

  Arg [1]    : cluster analysis_id
  Example    : $cluster = $cst_adaptor->fetch_by_analysis_id($analysis_id);
  Description: Retrieves an cluster from the database via its analysis_id
  Returntype : Bio::Cogemir::Cluster
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id {
    my ($self, $value) = @_;
    
    $self->throw("I need a analysis_id") unless $value;

    my $query = qq {
    SELECT cluster_id
      FROM cluster 
      WHERE  analysis_id = ? 
    };
    
    my $sth = $self->prepare($query);
    $sth->execute($value);
	my ($dbID) = $sth->fetchrow_array();
    unless (defined $dbID){return undef;} 
    my $cluster = $self->fetch_by_dbID($dbID);
    return $cluster;
}

sub _exists{
	my ($self, $obj) = @_;
	my $analysis_id = $obj->analysis->dbID if defined $obj->analysis;
	my $obj_id;
	my $query = qq {
		SELECT cluster_id
		FROM cluster
		WHERE name = ? 
	};
	# print "SELECT cluster_id
# 		FROM cluster
# 		WHERE name = ",$obj->name,"\n";
	my $sth = $self->prepare($query);
	$sth->execute($obj->name);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	#print "FOUND $obj_id\n";
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Analysis
               the cluster  to be stored in this database
  Example    : $cluster_adaptor->store($cluster);
 Description : Stores an cluster in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $cluster ) = @_;


    #if it is not an cluster don't store
    if( ! $cluster->isa('Bio::Cogemir::Cluster') ) {
	$self->throw("$cluster is not a Bio::Cogemir::Cluster object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($cluster->can('dbID') && $cluster->dbID) {return $cluster->dbID();}  
    if ($self->_exists($cluster)){return $self->_exists($cluster); }
    #if name exists return without storing
    my $analysis_id;
    if (defined $cluster->analysis){
        unless ($cluster->analysis->dbID){$analysis_id = $self->db->get_AnalysisAdaptor->store($cluster->analysis); }
        else{$analysis_id = $cluster->analysis->dbID}
    }
    

    #otherwise store the information being passed
    my $sql = q {INSERT INTO cluster SET name = ?, analysis_id = ?};
    #print "INSERT INTO cluster SET name = ", $cluster->name,"\n";
    my $sth = $self->prepare($sql);

    $sth->execute($cluster->name(), $analysis_id);
    
    my $cluster_id = $sth->{'mysql_insertid'};
    $cluster->dbID($cluster_id);
    $cluster->adaptor($self);
    return $cluster_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Cluster
               the cluster  to be removed in this database
  Example    : $cluster_adaptor->remove($cluster);
 Description : removes an cluster in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $cluster) = @_;
    
    if( ! defined $cluster->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    foreach my $microrna (@{$self->db->get_MicroRNAAdaptor->fetch_by_cluster_id($cluster->dbID)}){
        $microrna->cluster->dbID(0);
        $self->db->get_MicroRNAAdaptor->update($microrna);
    }
    
    my $sth= $self->prepare( "delete from cluster where cluster_id = ? " );
    $sth->execute($cluster->dbID());
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Cluster
               the cluster  to be removed in this database
  Example    : $cluster_adaptor->remove($cluster);
 Description : removes an cluster in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $cluster) = @_;
    
    if( ! defined $cluster->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    my $sth= $self->prepare( "delete from cluster where cluster_id = ? " );
    $sth->execute($cluster->dbID());
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Cluster
               the cluster  to be updated in this database
  Example    : $cluster_adaptor->update($cluster);
 Description : updates an cluster in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    my ($self, $cluster) = @_;
        if( ! $cluster->isa('Bio::Cogemir::Cluster') ) {
	$self->throw("$cluster is not a Bio::Cogemir::Cluster object - not updating!");
    }
    my $analysis_id = $cluster->analysis->dbID if defined $cluster->analysis;
    my $sql = q {UPDATE cluster SET name = ?, analysis_id = ?  WHERE cluster_id = ? };
    my $sth = $self->prepare($sql);
    $sth->execute($cluster->name(),$analysis_id,$cluster->dbID);
    return $self->fetch_by_dbID($cluster->dbID);
}
1;
