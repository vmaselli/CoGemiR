#
# Module for Bio::Cogemir::DBSQL::ParalogsAdaptor
#
#  Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::CSTAdaptor

=head1 SYNOPSIS

    $paralogs_adaptor = $dbadaptor->get_CSTAdaptor();

    $paralogs = $paralogs_adaptor->fetch_by_dbID();

    $paralogs = $paralogs_adaptor->fetch_by_query_id();
	
=head1 DESCRIPTION

    This adaptor work with the paralogs table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::ParalogsAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::Paralogs;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;


use Data::Dumper;
use Bio::Cogemir::DBSQL::AnalysisAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Paralogs
  Example    : $paralogs = $paralogs_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an paralogs from the database via its internal id
  Returntype : Bio::Cogemir::Paralogs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a paralogs id") unless $dbID;

    my $query = qq {
    SELECT query_microrna_id, target_microrna_id, type, analysis_id
      FROM paralogs 
      WHERE  paralogs_id = $dbID  
  };

    my $sth = $self->prepare($query);
    $sth->execute();
	my ($query_microrna_id, $target_microrna_id, $type, $analysis_id) = $sth->fetchrow_array();
   unless (defined $query_microrna_id){
    	$self->warn("no paralogs for $dbID");
    	return undef;
    }
    #print "$query_microrna_id, $target_microrna_id\n";
    my $analysis_obj = $self->db->get_AnalysisAdaptor->fetch_by_dbID($analysis_id);
    my $query_microrna_obj = $self->db->get_MicroRNAAdaptor->fetch_by_dbID($query_microrna_id);
    my $target_microrna_obj = $self->db->get_MicroRNAAdaptor->fetch_by_dbID($target_microrna_id);
    #print "==>QUERY ".$query_microrna_obj->gene_name." TARGET ".$target_microrna_obj->gene_name."\n";

    my $paralogs =  Bio::Cogemir::Paralogs->new(   
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -QUERY_MICRORNA => $query_microrna_obj, 
							    -TARGET_MICRORNA => $target_microrna_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						    
							   );


    return $paralogs;
}

=head2 fetch_by_microrna_id

  Arg [1]    : external ID: query id of Paralogs
  Example    : $paralogs = $elationship_adaptor->fetch_by_query_id($query_id);
  Description: Retrieves an paralogs from the database via its external query id
  Returntype : Bio::Cogemir::Paralogs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_microrna_id {
    my ($self, $microrna_id) = @_;
    
    $self->throw("I need a query id") unless $microrna_id;
	my @relateds;
    my $query = qq {
    SELECT paralogs_id
      FROM paralogs 
      WHERE  (query_microrna_id = $microrna_id  or target_microrna_id = $microrna_id)
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no paralogs for $microrna_id") unless $dbID;
		my $paralogs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $paralogs);
	}

    return \@relateds;
}


=head2 fetch_by_query_microrna_id

  Arg [1]    : external ID: query id of Paralogs
  Example    : $paralogs = $elationship_adaptor->fetch_by_query_id($query_id);
  Description: Retrieves an paralogs from the database via its external query id
  Returntype : Bio::Cogemir::Paralogs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_query_microrna_id {
    my ($self, $microrna_id) = @_;
    
    $self->throw("I need a query id") unless $microrna_id;
	my @relateds;
    my $query = qq {
    SELECT paralogs_id
      FROM paralogs 
      WHERE  query_microrna_id = $microrna_id  
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no paralogs for $microrna_id") unless $dbID;
		my $paralogs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $paralogs);
	}

    return \@relateds;
}

=head2 fetch_by_target_microrna_id

  Arg [1]    : external ID: target_microrna id of Paralogs
  Example    : $paralogs = $paralogs_adaptor->fetch_by_target_microrna_id($target_microrna_id);
  Description: Retrieves an paralogs from the database via its internal id
  Returntype : Bio::Cogemir::Paralogs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_target_microrna_id {
    my ($self, $target_microrna_id) = @_;
    
    $self->throw("I need a target_microrna id") unless $target_microrna_id;
    my @relateds;	
    my $target_microrna = qq {
    SELECT paralogs_id
      FROM paralogs 
      WHERE  target_microrna_id = $target_microrna_id  
  };

    my $sth = $self->prepare($target_microrna);
    $sth->execute();
	while (my ($dbID) = $sth->fetchrow_array()){
		$self->warn("no paralogs for $target_microrna_id") unless $dbID;
		my $paralogs =  $self->fetch_by_dbID($dbID);
		push (@relateds, $paralogs);
	}

    return \@relateds;
}

=head2 fetch_by_analysis_id

  Arg [1]    : external ID: analysis id of Paralogs
  Example    : $paralogs = $paralogs_adaptor->fetch_by_analysis_id($analysis_id);
  Description: Retrieves an paralogs from the database via its internal id
  Returntype : Bio::Cogemir::Paralogs
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_analysis_id {
    my ($self, $analysis_id) = @_;
    
    $self->throw("I need a analysis id") unless $analysis_id;	
    my $analysis = qq {
    SELECT paralogs_id
      FROM paralogs 
      WHERE  analysis_id = $analysis_id  
  };

    my $sth = $self->prepare($analysis);
    $sth->execute();
    my ($dbID) = $sth->fetchrow_array();
	my $paralogs =  $self->fetch_by_dbID($dbID);

    return $paralogs;
}

sub _exists{
	my ($self, $obj) = @_;
	
	my $query = qq {
		SELECT paralogs_id
		FROM paralogs
		WHERE query_microrna_id = ?
		AND target_microrna_id = ?
		AND type = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->query_microrna->dbID, $obj->target_microrna->dbID, $obj->type);
	return ($sth->fetchrow_array());

}


=head2 store

  Arg [1]    : Bio::Cogemir::Paralogs
               the paralogs  to be stored in this database
  Example    : $paralogs_adaptor->store($paralogs);
 Description : Stores an paralogs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $paralogs ) = @_;
   
	#if it is not an paralogs dont store
    if( ! $paralogs->isa('Bio::Cogemir::Paralogs') ) {
	$self->throw("$paralogs is not a Bio::Cogemir::Paralogs object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($paralogs->can('dbID') && $paralogs->dbID) {return $paralogs->dbID();}
    
    my $analysis_dbID;
    if( $paralogs->analysis){
    	unless($paralogs->analysis->dbID){$analysis_dbID = $self->db->get_AnalysisAdaptor->store($paralogs->analysis);}
    	else{$analysis_dbID = $paralogs->analysis->dbID;}
   	}
   	my $query_microrna_dbID;
   	unless($paralogs->query_microrna->dbID){$query_microrna_dbID = $self->db->get_MicroRNAAdaptor->store($paralogs->query_microrna);}
    else{$query_microrna_dbID = $paralogs->query_microrna->dbID;}
    my $target_microrna_dbID;
   	unless($paralogs->target_microrna->dbID){$target_microrna_dbID = $self->db->get_MicroRNAAdaptor->store($paralogs->target_microrna);}
    else{$target_microrna_dbID = $paralogs->target_microrna->dbID;}
    
    if ($self->_exists($paralogs)){return $self->_exists($paralogs);}
   
    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO paralogs SET query_microrna_id = ?, target_microrna_id = ?, type = ?, analysis_id = ?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($query_microrna_dbID, $target_microrna_dbID, $paralogs->type(), $analysis_dbID);
    
    my $paralogs_id = $sth->{'mysql_insertid'};
    $paralogs->dbID($paralogs_id);
    return $paralogs_id;


}

=head2 update

  Arg [1]    : Bio::Cogemir::Paralogs
               the paralogs  to be updated in this database
  Example    : $paralogs_adaptor->update($paralogs);
 Description : Updates an paralogs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
	 my ($self, $paralogs) = @_;
	 if( ! $paralogs->isa('Bio::Cogemir::Paralogs') ) {
	$self->throw("$paralogs is not a Bio::Cogemir::Paralogs object - not updating!");
    }
	 my $analysis_dbID = $paralogs->analysis->dbID if defined  $paralogs->analysis;
	 my $sql = q { 
	UPDATE paralogs SET query_microrna_id = ?, target_microrna_id = ?, type = ?, analysis_id = ? WHERE paralogs_id = ?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($paralogs->query_microrna->dbID, $paralogs->target_microrna->dbID, $paralogs->type(), $analysis_dbID,$paralogs->dbID);
    return $paralogs;

}

=head2 remove

  Arg [1]    : Bio::Cogemir::Paralogs
               the paralogs  to be removed in this database
  Example    : $paralogs_adaptor->remove($paralogs);
 Description : Removes an paralogs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $paralogs) = @_;
    #print $self." _remove\n";
    if( ! defined $paralogs->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    
    my $sth= $self->prepare( "delete from paralogs where paralogs_id = ? " );
    $sth->execute($paralogs->dbID());
    
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Paralogs
               the paralogs  to be removed in this database
  Example    : $paralogs_adaptor->remove($paralogs);
 Description : Removes an paralogs in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $paralogs) = @_;  
  return $self->remove($paralogs);
}


1;
