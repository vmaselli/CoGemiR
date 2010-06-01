#
# Module for Bio::Cogemir::DBSQL::FeatureAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 LOGIC_NAME

Bio::Cogemir::DBSQL::FeatureAdaptor

=head1 SYNOPSIS

    $feature_adaptor = $dbadaptor->get_FeatureAdaptor();

    $feature = $feature_adaptor->fetch_by_dbID();

    $feature = $feature_adaptor->fetch_by_query_id();
	
=head1 DESCRIPTION

    This adaptor work with the feature table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::FeatureAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Feature;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a feature id") unless $dbID;

    my $query = qq {
    SELECT  logic_name_id, analysis_id, description,  note, distance_from_upstream_gene, closest_upstream_gene, distance_from_downstream_gene, closest_downstream_gene
      FROM feature 
      WHERE  feature_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ( $logic_name_id, $analysis_id, $description,  $note, $distance_from_upstream_gene, $closest_upstream_gene,$distance_from_downstream_gene, $closest_downstream_gene) = $sth->fetchrow_array();
   unless (defined $logic_name_id){
    	$self->warn("no feature for $dbID");
    	return undef;
    }

    my $analysis_obj = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id) if $analysis_id;
    my $logic_name_obj = $self->db->get_LogicNameAdaptor->fetch_by_dbID($logic_name_id);
    my $feature =  Bio::Cogemir::Feature->new(  
	                -DBID                       => $dbID,
	                -ADAPTOR                    => $self,
							    -LOGIC_NAME                 => $logic_name_obj, 
							    -DESCRIPTION                => $description,
							    -NOTE                       => $note,
							    -DISTANCE_FROM_UPSTREAMGENE => $distance_from_upstream_gene,
							    -CLOSEST_UPSTREAMGENE         => $closest_upstream_gene,
							    -DISTANCE_FROM_DOWNSTREAMGENE => $distance_from_downstream_gene,
							    -CLOSEST_DOWNSTREAMGENE         => $closest_downstream_gene,
							    -ANALYSIS                      => $analysis_obj				                                                   
							    );


    return $feature;
}

=head2 fetch_by_micro_rna

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_micro_rna($micro_rna_id);
  Description: Retrieves an feature from the database via its internal id
  Returntype : listref Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_micro_rna {
    my ($self, $value) = @_;
    $self->throw("I need a micro_rna id") unless $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM micro_rna_feature WHERE micro_rna_id = ?};
    #printf "SELECT feature_id FROM micro_rna_feature WHERE micro_rna_id = ? =%d;",$value;
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}
=head2 fetch_by_gene

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_member_id($member_id);
  Description: Retrieves an feature from the database via its internal id
  Returntype : listref Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut


sub fetch_by_gene {
    my ($self, $value) = @_;
    $self->throw("I need a gene id") unless $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM gene_feature WHERE gene_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_analysis_id

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_analysis_id($analysis_id);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id {
    my ($self, $value) = @_;
    $self->throw("I need a member id") unless $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM feature WHERE analysis_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    my ($dbID) = $sth->fetchrow_array;
    $return = $self->fetch_by_dbID($dbID);
   
    return $return;
}

=head2 fetch_by_name

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_name($name);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
    my ($self, $value) = @_;
    $self->throw("I need a name") unless $value;

    my $return;
    
    my $sql = qq{SELECT f.feature_id FROM feature f, logic_name l WHERE l.logic_name_id = f.logic_name_id and l.name like ?};
    my $sth = $self->prepare($sql);
    $sth->execute("%".$value."%");
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_distance_from_upstream_gene

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_distance_from_upstream_gene($distance_from_upstream_gene);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_distance_from_upstream_gene {
    my ($self, $value) = @_;
    $self->throw("I need a member id") unless defined $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM feature WHERE distance_from_upstream_gene = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_closest_upstream_gene

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_closest_upstream_gene($closest_upstream_gene);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_closest_upstream_gene {
    my ($self, $value) = @_;
    $self->throw("I need a member id") unless defined $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM feature WHERE closest_upstream_gene = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_distance_from_upstream_gene

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_distance_from_upstream_gene($distance_from_upstream_gene);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_distance_from_downstream_gene {
    my ($self, $value) = @_;
    $self->throw("I need a member id") unless defined $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM feature WHERE distance_from_upstream_gene = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    while (my ($dbID) = $sth->fetchrow_array){
        push (@$return, $self->fetch_by_dbID($dbID));
    }
    return $return;
}

=head2 fetch_by_closest_upstream_gene

  Arg [1]    : internal id of Feature
  Example    : $feature = $feature_adaptor->fetch_by_closest_upstream_gene($closest_upstream_gene);
  Description: Retrieves an feature from the database via its internal id
  Returntype : Bio::Cogemir::Feature
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_closest_downstream_gene {
    my ($self, $value) = @_;
    $self->throw("I need a member id") unless defined $value;

    my $return;
    
    my $sql = qq{SELECT feature_id FROM feature WHERE closest_upstream_gene = ?};
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
	my $analysis_id = $obj->analysis->dbID if defined $obj->analysis;
	my $query = qq {
		SELECT feature_id
		FROM feature
		WHERE  logic_name_id = ?  and analysis_id = ? and description = ?  and note = ? and distance_from_upstream_gene = ? and closest_upstream_gene = ? and distance_from_downstream_gene = ? and closest_downstream_gene = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->logic_name->dbID,  $analysis_id, $obj->description,  $obj->note, $obj->distance_from_upstream_gene, $obj->closest_upstream_gene,$obj->distance_from_downstream_gene, $obj->closest_downstream_gene);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Feature
               the feature  to be stored in this database
  Example    : $feature_adaptor->store($feature);
 Description : Stores an feature in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $feature ) = @_;
    #if it is not an feature dont store
    if( ! $feature->isa('Bio::Cogemir::Feature') ) {
	    $self->throw("$feature is not a Bio::Cogemir::Feature object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($feature->can('dbID') && $feature->dbID) {return $feature->dbID();}
  if ($self->_exists($feature)) {return $self->_exists($feature);} 
 	my $analysis_id;
 	if (defined $feature->analysis){
 	    unless ($feature->analysis->dbID){$analysis_id = $self->db->get_AnalysisAdaptor->store($feature->analysis)}
 	    else{$analysis_id = $feature->analysis->dbID}
 	 }
 	 unless ($feature->logic_name->dbID){$self->db->get_LogicNameAdaptor->store($feature->logic_name)}
 	

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO feature SET  logic_name_id = ?,  analysis_id = ?, description = ?,  note = ?, distance_from_upstream_gene = ?, closest_upstream_gene = ? , distance_from_downstream_gene = ?, closest_downstream_gene = ?};
    my $sth = $self->prepare($sql);

    $sth->execute( $feature->logic_name->dbID,  $analysis_id, $feature->description, $feature->note, $feature->distance_from_upstream_gene, $feature->closest_upstream_gene, $feature->distance_from_downstream_gene, $feature->closest_downstream_gene);
    
    my $feature_id = $sth->{'mysql_insertid'};
    $feature->dbID($feature_id);
    $feature->adaptor($self);
    return $feature_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Feature
               the feature  to be removed in this database
  Example    : $feature_adaptor->remove($feature);
 Description : removes an feature in the database
  Returntype : boolean
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $feature) = @_;
    
    if( ! defined $feature->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    foreach my $blast (@{$self->db->get_BlastAdaptor->fetch_by_feature_id($feature->dbID)}){
        $self->db->get_BlastAdaptor->_remove($blast);
    }
   
    my $sth= $self->prepare( "delete from feature where feature_id = ? " );
    $sth->execute($feature->dbID());
    
    my $sth2= $self->prepare( "delete from micro_rna_feature where feature_id = ? " );
    $sth2->execute($feature->dbID());
    return 1;

}


=head2 _remove

  Arg [1]    : Bio::Cogemir::Feature
               the feature  to be removed in this database
  Example    : $feature_adaptor->remove($feature);
 Description : removes an feature in the database
  Returntype : boolean
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $feature) = @_;
  #print $self." _remove\n";
  if( ! defined $feature->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  my $sth= $self->prepare( "delete from feature where feature_id = ? " );
  $sth->execute($feature->dbID());
  
  my $sth2= $self->prepare( "delete from micro_rna_feature where feature_id = ? " );
  $sth2->execute($feature->dbID());
  return 1;

}


=head2 update

  Arg [1]    : Bio::Cogemir::Feature
               the feature  to be updated in this database
  Example    : $feature_adaptor->update($feature);
 Description : updates an feature in the database
  Returntype : Bio::Cogemir::Feature
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $feature) = @_;
        if( ! $feature->isa('Bio::Cogemir::Feature') ) {
	    $self->throw("$feature is not a Bio::Cogemir::Feature object - not updating!");
    }
    my $analysis_id = $feature->analysis->dbID if defined $feature->analysis;

     my $sql = q { 
	UPDATE feature SET  logic_name_id = ?,  analysis_id = ?, description = ?,  note = ?, distance_from_upstream_gene = ?, closest_upstream_gene = ?, distance_from_downstream_gene = ?, closest_downstream_gene = ? where feature_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute( $feature->logic_name->dbID,  $analysis_id, $feature->description,  $feature->note, $feature->distance_from_upstream_gene, $feature->closest_upstream_gene,$feature->distance_from_downstream_gene, $feature->closest_downstream_gene,$feature->dbID);
    return $self->fetch_by_dbID($feature->dbID);
}    
