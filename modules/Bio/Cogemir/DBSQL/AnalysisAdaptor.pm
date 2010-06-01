#
# Module for Bio::Cogemir::DBSQL::AnalysisAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::AnalysisAdaptor

=head1 SYNOPSIS
	
	$dbadaptor = Bio::Cogemir::DBSQL->new (...);

    $analysis_adaptor = $dbadaptor->get_AnalysisAdaptor();

    $analysis = $analysis_adaptor->fetch_by_dbID();

    $analysis_listref = $analysis_adaptor->fetch_by_logic_name();

=head1 DESCRIPTION

    Module to encapsulate all db access for persistent class Analysis.
    This adaptor work with the analysis table 


=head1 AUTHORS - 
s
Vincenza Maselli - maselli@tigem.it

=cut

package Bio::Cogemir::DBSQL::AnalysisAdaptor;

use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";

use Bio::Cogemir::Analysis;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of Analysis
  Example    : $analysis = $analysis_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an analysis from the database via its internal id
  Returntype : Bio::Cogemir::Analysis
  Exceptions : if argument is not defined or query doesn't give results 
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;  
    $self->throw("I need an analysis id") unless $dbID;
    
	
    my $query = qq {
    SELECT created,logic_name_id, parameters
      FROM analysis 
      WHERE  analysis_id =  ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($created, $logic_name_id, $parameters)= $sth->fetchrow_array();
	unless ($parameters){
    	$self->warn("no parameters of analysis for DBID $dbID in fetch_by_dbID");
    	return undef;
    }
    my $logic_name_obj;
	$logic_name_obj = $self->db->get_LogicNameAdaptor->fetch_by_dbID($logic_name_id) if $logic_name_id;
    

    my $analysis =  Bio::Cogemir::Analysis->new(       
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -CREATED => $created,
							    -PARAMETERS =>$parameters,
							    -LOGIC_NAME =>$logic_name_obj
							   );


    return $analysis;
}


=head2 fetch_by_created

  Arg [1]    : date of creation of Analysis
  Example    : $analysis = $analysis_adaptor->fetch_by_created($date);
  Description: Retrieves an analysis from the database via its date of creation
  Returntype : Bio::Cogemir::Analysis
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_by_created{

	my ($self, $date) = @_;
	$self->throw("I need a date") unless $date;
	my $created = "%".$date."%";
	my $query = qq{select analysis_id
				from analysis
				where created like ?};
	
	my $sth = $self->prepare($query);
	$sth->execute($created);
	my ($dbID)= $sth->fetchrow_array();

    unless (defined $dbID){
    	$self->warn("no analysis for DATE $date");
    	return undef;
    }
    return  $self->fetch_by_dbID($dbID);

}

=head2 fetch_All

  Arg [1]    : none
  Example    : $analysis = $analysis_adaptor->fetch_All();
  Description: Retrieves all analysis from the database 
  Returntype : list of Bio::Cogemir::Analysis
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_All{

	my ($self) = @_;
	
	
	my $query = qq{ select a.analysis_id
				    from analysis a};
	my $sth = $self->prepare($query);
	$sth->execute();
	my ($analysis_obj, @analysis);
	while ((my $dbID) = $sth->fetchrow_array()){
		$analysis_obj =  $self->fetch_by_dbID($dbID);
		push (@analysis, $analysis_obj);
	}
    unless (@analysis){
    	$self->warn("no analysis ");
    	return undef;
    }

    return \@analysis;

}

=head2 fetch_by_logic_name

  Arg [1]    : logic name of Analysis
  Example    : $analysis = $analysis_adaptor->fetch_by_logic_name_obj($logic_name_obj);
  Description: Retrieves an analysis from the database via its logic name
  Returntype : list of Bio::Cogemir::Analysis
  Exceptions : query doesn't give results
  Caller     : general

=cut

sub fetch_by_logic_name{

	my ($self, $logic_name_id) = @_;
	$self->throw("I need a logic name") unless $logic_name_id;
	
	my $query = qq{ select a.analysis_id
				    from analysis a
					where a.logic_name_id = ?
					};
	my $sth = $self->prepare($query);
	$sth->execute($logic_name_id);
	my ($analysis_obj, @analysis);
	while ((my $dbID) = $sth->fetchrow_array()){
		$analysis_obj =  $self->fetch_by_dbID($dbID);
		push (@analysis, $analysis_obj);
	}
    unless (@analysis){
    	$self->warn("no analysis for logic name dbID $logic_name_id \n");
    	return undef;
    }

    return \@analysis;

}

=head2 _exists

=cut

sub _exists{
  my ( $self, $analysis ) = @_;

  #if it is not an analysis dont store
  if( ! $analysis->isa('Bio::Cogemir::Analysis') ) {
	  $self->throw("$analysis is not a Bio::Cogemir::Analysis object - not test!");
  }
  
  my $sql = qq{SELECT analysis_id FROM analysis WHERE created = ? and parameters = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($analysis->created,$analysis->parameters);
  my $analysis_id = $sth->fetchrow;
  return $analysis_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Analysis
               the analysis  to be stored in this database
  Example    : $analysis_adaptor->store($analysis);
  Description : Stores an analysis in the database
  Returntype : integer
  Exceptions : arguments isn't a Bio::Cogemir::Analysis obj
  Caller     : general

=cut

sub store {
    my ( $self, $analysis ) = @_;

    #if it is not an analysis dont store
    if( ! $analysis->isa('Bio::Cogemir::Analysis') ) {
	$self->throw("$analysis is not a Bio::Cogemir::Analysis object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($analysis->can('dbID')) {
		if( $analysis->dbID) {
	    	return $analysis->dbID();
		}
    }  
    if (my $dbID = $self->_exists($analysis)){return $dbID}
    my $logic_name_dbID;
    
   unless($analysis->logic_name->dbID){$self->db->get_LogicNameAdaptor->store($analysis->logic_name);}
    
   
    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO analysis SET created = ?,logic_name_id = ?,  parameters =?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($analysis->created(), $analysis->logic_name->dbID,  $analysis->parameters());
    
    my $analysis_id = $sth->{'mysql_insertid'};
    $analysis->dbID($analysis_id);
    $analysis->adaptor($self);
    return $analysis_id;
}

=head2 remove

  Arg [1]     : Bio::Cogemir::Analysis
               the analysis  to be removed in this database
  Example     : $analysis_adaptor->remove($analysis);
  Description : Remove an analysis in the database
  Returntype  : boolean
  Exceptions  : arguments isn't a Bio::Cogemir::Analysis obj
  Caller      : general

=cut

sub remove {
    
    my ($self, $analysis) = @_;
    
    if( ! defined $analysis->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    my $mirna_name = $self->db->get_MirnaNameAdaptor->fetch_by_analysis_id($analysis->dbID);
    $mirna_name->analysis->dbID(0);
    $self->db->get_MirnaNameAdaptor->update($mirna_name);
    
    my $attribute = $self->db->get_AttributeAdaptor->fetch_by_analysis_id($analysis->dbID);
    if (defined $attribute){
        $attribute->analysis->dbID(0);
        $self->db->get_AttributeAdaptor->update($attribute);
    }
    
    my $cluster = $self->db->get_ClusterAdaptor->fetch_by_analysis_id($analysis->dbID);
    if (defined $cluster){
        $cluster->analysis->dbID(0);
        $self->db->get_ClusterAdaptor->update($cluster);
    }
    my $homologs ;#= $self->db->get_HomologsAdaptor->fetch_by_analysis_id($analysis->dbID);
    if (defined $homologs){
        $homologs->analysis->dbID(0);
        $self->db->get_HomologsAdaptor->update($homologs);
    }
    
    my $paralogs;#  = $self->db->get_ParalogsAdaptor->fetch_by_analysis_id($analysis->dbID);
    if (defined $paralogs){
        $paralogs->analysis->dbID(0);
        $self->db->get_ParalogsAdaptor->update($paralogs);
    }
    my $sth= $self->prepare( "delete from analysis where analysis_id = ? " );
    $sth->execute($analysis->dbID());
    
    return 1;

}

=head2 _remove

  Arg [1]     : Bio::Cogemir::Analysis
               the analysis  to be removed in this database
  Example     : $analysis_adaptor->remove($analysis);
  Description : Remove an analysis in the database
  Returntype  : boolean
  Exceptions  : arguments isn't a Bio::Cogemir::Analysis obj
  Caller      : general

=cut

sub _remove {
    
    my ($self, $analysis) = @_;
    
    $self->remove($analysis);
    
    return 1;

}

=head2 update

  Arg [1]     : Bio::Cogemir::Analysis
               the analysis  to be updated in this database
  Example     : $analysis_adaptor->update($analysis);
  Description : Update an analysis in the database
  Returntype  : Bio::Cogemir::Analysis
  Exceptions  : arguments isn't a Bio::Cogemir::Analysis obj
  Caller      : general

=cut

sub update {
    my ( $self, $analysis ) = @_;
    if( ! $analysis->isa('Bio::Cogemir::Analysis') ) {
	$self->throw("$analysis is not a Bio::Cogemir::Analysis object - not updating!");
    }
    my $sql = q {UPDATE analysis SET created = ?,logic_name_id = ?,  parameters = ? WHERE analysis_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($analysis->created, $analysis->logic_name->dbID,  $analysis->parameters, $analysis->dbID);

    return $self->fetch_by_dbID($analysis->dbID);
}

1;

