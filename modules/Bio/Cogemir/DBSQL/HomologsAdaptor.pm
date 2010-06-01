#
# Module for Bio::Cogemir::DBSQL::HomologsAdaptor
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

    $homologs_adaptor = $dbadaptor->get_CSTAdaptor();

    $homologs = $homologs_adaptor->fetch_by_dbID();

    $homologs = $homologs_adaptor->fetch_by_query_id();
	
=head1 DESCRIPTION

    This adaptor work with the homologs table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::HomologsAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Homologs;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Homologs
  Example    : $homologs = $homologs_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an homologs from the database via its internal id
  Returntype : Bio::Cogemir::Homologs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a homologs id") unless $dbID;

    my $query = qq {
    SELECT query_gene_id, target_gene_id, type, analysis_id
      FROM homologs 
      WHERE  homologs_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($query_gene_id, $target_gene_id, $type, $analysis_id) = $sth->fetchrow_array();
   unless (defined $query_gene_id){
    	$self->warn("no homologs for $dbID");
    	return undef;
    }


    
    my $analysis_obj = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id);
    my $query_gene_obj = $self->db->get_GeneAdaptor->fetch_by_dbID($query_gene_id);
    my $target_gene_obj = $self->db->get_GeneAdaptor->fetch_by_dbID($target_gene_id);
    my $homologs =  Bio::Cogemir::Homologs->new(   
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -QUERY_GENE => $query_gene_obj, 
							    -TARGET_GENE => $target_gene_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						    
							   );


    return $homologs;
}

=head2 fetch_by_gene_id

  Arg [1]    : external ID: query id of Homologs
  Example    : $homologs = $elationship_adaptor->fetch_by_query_id($query_id);
  Description: Retrieves an homologs from the database via its external query id
  Returntype : Bio::Cogemir::Homologs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_gene_id {
    my ($self, $gene_id) = @_;
    
    $self->throw("I need a query id") unless $gene_id;
	my @relateds;
    my $query = qq {
    SELECT homologs_id
      FROM homologs 
      WHERE  (query_gene_id = $gene_id  or target_gene_id = $gene_id)
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no homologs for $gene_id") unless $dbID;
		my $homologs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $homologs);
	}

    return \@relateds;
}


=head2 fetch_by_query_gene_id

  Arg [1]    : external ID: query id of Homologs
  Example    : $homologs = $elationship_adaptor->fetch_by_query_id($query_id);
  Description: Retrieves an homologs from the database via its external query id
  Returntype : Bio::Cogemir::Homologs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_query_gene_id {
    my ($self, $gene_id) = @_;
    
    $self->throw("I need a query id") unless $gene_id;
	my @relateds;
    my $query = qq {
    SELECT homologs_id
      FROM homologs 
      WHERE  query_gene_id = $gene_id  
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no homologs for $gene_id") unless $dbID;
		my $homologs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $homologs);
	}

    return \@relateds;
}

=head2 fetch_by_target_gene_id

  Arg [1]    : external ID: target_gene id of Homologs
  Example    : $homologs = $homologs_adaptor->fetch_by_target_gene_id($target_gene_id);
  Description: Retrieves an homologs from the database via its internal id
  Returntype : Bio::Cogemir::Homologs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_target_gene_id {
    my ($self, $target_gene_id) = @_;
    
    $self->throw("I need a target_gene id") unless $target_gene_id;
    my @relateds;	
    my $target_gene = qq {
    SELECT homologs_id
      FROM homologs 
      WHERE  target_gene_id = $target_gene_id  
  };

    my $sth = $self->prepare($target_gene);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no homologs for $target_gene_id") unless $dbID;
		my $homologs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $homologs);
	}

    return \@relateds;
}

=head2 fetch_by_analysis_id

  Arg [1]    : external ID: analysis id of Homologs
  Example    : $homologs = $homologs_adaptor->fetch_by_analysis_id($analysis_id);
  Description: Retrieves an homologs from the database via its internal id
  Returntype : Bio::Cogemir::Homologs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id {
    my ($self, $analysis_id) = @_;
    
    $self->throw("I need a analysis id") unless $analysis_id;	
    my $analysis = qq {
    SELECT homologs_id
      FROM homologs 
      WHERE  analysis_id = $analysis_id  
  };

    my $sth = $self->prepare($analysis);
    $sth->execute();
    my ($dbID) = $sth->fetchrow_array();
	my $homologs =  $self->fetch_by_dbID($dbID);

    return $homologs;
}


sub _exists{
	my ($self, $obj) = @_;
	
	my $query = qq {
		SELECT homologs_id
		FROM homologs
		WHERE query_gene_id = ?
		AND target_gene_id = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->query_gene->dbID, $obj->target_gene->dbID);
	return ($sth->fetchrow_array());

}


=head2 store

  Arg [1]    : Bio::Cogemir::Homologs
               the homologs  to be stored in this database
  Example    : $homologs_adaptor->store($homologs);
 Description : Stores an homologs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $homologs ) = @_;
   
	#if it is not an homologs dont store
    if( ! $homologs->isa('Bio::Cogemir::Homologs') ) {
	$self->throw("$homologs is not a Bio::Cogemir::Homologs object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($homologs->can('dbID') && $homologs->dbID) {return $homologs->dbID();}
    
    my $analysis_dbID;
    if( $homologs->analysis){
    	unless($homologs->analysis->dbID){$analysis_dbID = $self->db->get_AnalysisAdaptor->store($homologs->analysis);}
    	else{$analysis_dbID = $homologs->analysis->dbID;}
   	}
   	my $query_gene_dbID;
   	unless($homologs->query_gene->dbID){$query_gene_dbID = $self->db->get_GeneAdaptor->store($homologs->query_gene);}
    else{$query_gene_dbID = $homologs->query_gene->dbID;}
    my $target_gene_dbID;
   	unless($homologs->target_gene->dbID){$target_gene_dbID = $self->db->get_GeneAdaptor->store($homologs->target_gene);}
    else{$target_gene_dbID = $homologs->target_gene->dbID;}
    
    if ($self->_exists($homologs)){return $self->_exists($homologs);}
   
    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO homologs SET query_gene_id = ?, target_gene_id = ?, type = ?, analysis_id = ?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($query_gene_dbID, $target_gene_dbID, $homologs->type(), $analysis_dbID);
    
    my $homologs_id = $sth->{'mysql_insertid'};
    $homologs->dbID($homologs_id);
    return $homologs_id;


}

=head2 update

  Arg [1]    : Bio::Cogemir::Homologs
               the homologs  to be updated in this database
  Example    : $homologs_adaptor->update($homologs);
 Description : Updates an homologs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
	 my ($self, $homologs) = @_;
	 if( ! $homologs->isa('Bio::Cogemir::Homologs') ) {
	$self->throw("$homologs is not a Bio::Cogemir::Homologs object - not storing!");
    }
	 my $analysis_dbID = $homologs->analysis->dbID if defined  $homologs->analysis;
	 my $sql = q { 
	UPDATE homologs SET query_gene_id = ?, target_gene_id = ?, type = ?, analysis_id = ? WHERE homologs_id = ?
    };

    my $sth = $self->prepare($sql);
    $sth->execute($homologs->query_gene->dbID, $homologs->target_gene->dbID, $homologs->type(), $analysis_dbID,$homologs->dbID);
	return $homologs;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Homologs
               the homologs  to be removed in this database
  Example    : $homologs_adaptor->remove($homologs);
 Description : Removes an homologs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $homologs) = @_;
    
    if( ! defined $homologs->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    
    my $sth= $self->prepare( "delete from homologs where homologs_id = ? " );
    $sth->execute($homologs->dbID());
    
    return 1;

}


=head2 _remove

  Arg [1]    : Bio::Cogemir::Homologs
               the homologs  to be removed in this database
  Example    : $homologs_adaptor->remove($homologs);
 Description : Removes an homologs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $homologs) = @_;
    $self->remove($homologs);
   
    return 1;
}
1;
