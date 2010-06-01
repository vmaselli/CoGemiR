#
# Module for Bio::Cogemir::DBSQL::GenomeDBAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::GenomeDBAdaptor

=head1 SYNOPSIS

    $genome_db_adaptor = $db->get_GenomeDBAdaptor();

    $genome_db = $genome_db_adaptor->fetch_by_dbID();

    

=head1 DESCRIPTION

    This adaptor work with the genome_db table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::GenomeDBAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";
use Bio::Cogemir::GenomeDB;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);




=head2 fetch_by_dbID

  Arg [1]    : internal id of GenomeDB
  Example    : $genome_db = $genome_db_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an genome_db from the database via its internal id
  Returntype : Bio::Cogemir::GenomeDB
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a genome_db id") unless $dbID;
    my $query = qq {
    SELECT taxon_id, organism, db_host, db_name, db_type, common_name, taxa
      FROM genome_db 
      WHERE  genome_db_id =  ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($taxon_id, $organism, $db_host, $db_name, $db_type, $common_name, $taxa) = $sth->fetchrow_array();
    unless (defined $organism){
    	#$self->warn("no genome_db for $dbID");
    	return undef;
    }

    
    my $genome_db =  Bio::Cogemir::GenomeDB->new(   
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -TAXON_ID => $taxon_id,
							    -ORGANISM => $organism,
							    -DB_HOST => $db_host,
							    -DB_NAME => $db_name,
							    -DB_TYPE => $db_type,
							    -COMMON_NAME =>$common_name,
							    -TAXA =>$taxa
							   );


    return $genome_db;
}


=head2 fetch_by_organism_type

  Arg [1]    : organism
  Arg [2]    : type 
  Example    : $genome_db = $genome_db_adaptor->fetch_by_organism_type($organism, 'core');
  Description: Retrieves an genome_db from the database via species and db type
  Returntype : Bio::Cogemir::GenomeDB
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_organism_type {
    my ($self, $organism,$type) = @_;
    
    $self->throw("I need a name of species ") unless $organism; 
    $self->throw("I need a name of db type") unless $type;

    my $query = qq {
    SELECT genome_db_id FROM genome_db WHERE  organism = ? and db_type = ?
  };
	#printf "SELECT genome_db_id FROM genome_db WHERE  organism = %s and db_type = %s\n",($organism,$type);
    my $sth = $self->prepare($query);
    $sth->execute($organism,$type);
	my ($dbID) = $sth->fetchrow_array();

    unless (defined $dbID){
    	#$self->warn("no genome_db for $organism");
    	return undef;
    }    
    return  $self->fetch_by_dbID($dbID);

}


=head2 fetch_by_db_type

  Arg [1]    : internal id of GenomeDB
  Example    : $genome_db = $genome_db_adaptor->fetch_by_db_type($db_type);
  Description: Retrieves an genome_db from the database via its internal id
  Returntype : Bio::Cogemir::GenomeDB
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_db_type {
    my ($self, $db_type) = @_;
    
    $self->throw("I need a db type") unless $db_type;

    my $query = qq {
    SELECT genome_db_id FROM genome_db WHERE  db_type = ?  
  };
	#print $query, $db_type, "\n";
    my $sth = $self->prepare($query);
    $sth->execute($db_type);
	my ($dbID) = $sth->fetchrow_array();

    unless (defined $dbID){
    	#$self->warn("no genome_db for $db_type");
    	return undef;
    }    
    return  $self->fetch_by_dbID($dbID);

}

=head2 fetch_by_db_name

  Arg [1]    : internal id of GenomeDB
  Example    : $genome_db = $genome_db_adaptor->fetch_by_db_name($db_name);
  Description: Retrieves an genome_db from the database via its internal id
  Returnname : Bio::Cogemir::GenomeDB
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_db_name {
    my ($self, $db_name) = @_;
    
    $self->throw("I need a db name") unless $db_name;

    my $query = qq {
    SELECT genome_db_id FROM genome_db WHERE  db_name = ?  
  };
	#print $query, $db_name, "\n";
    my $sth = $self->prepare($query);
    $sth->execute($db_name);
	my ($dbID) = $sth->fetchrow_array();

    unless (defined $dbID){
    	#$self->warn("no genome_db for $db_name");
    	return undef;
    }    
    return  $self->fetch_by_dbID($dbID);

}



=head2 get_all_Organism

  Arg [1]    : none
  Example    : @organisms = @{$genome_db_adaptor->get_all_Organism()};
  Description: Retrieves all organism
  Returntype : list ref of organism
  Exceptions : none
  Caller     : general

=cut

sub get_all_Organism {
    my ($self) = @_;
    my @array;
    my $query = qq { SELECT distinct(organism) FROM genome_db  };

    my $sth = $self->prepare($query);
    $sth->execute();
	while (my $organism = $sth->fetchrow_array()){
		push (@array, $organism);
	}
    return \@array;
}
=head2 get_all_Groups

  Arg [1]    : none
  Example    : @taxas = @{$genome_db_adaptor->get_all_Groups()};
  Description: Retrieves all taxa
  Returntype : list ref of taxa
  Exceptions : none
  Caller     : general

=cut

sub get_all_Groups {
    my ($self) = @_;
    my @array;
    my $query = qq { SELECT distinct(taxa) FROM genome_db  };

    my $sth = $self->prepare($query);
    $sth->execute();
	while (my $taxa = $sth->fetchrow_array()){
		push (@array, $taxa);
	}
    return \@array;
}
=head2 get_all_mir_aliases

  Arg [1]    : none
  Example    : @organisms = @{$genome_db_adaptor->get_all_mir_aliases()};
  Description: Retrieves all organism
  Returntype : list ref of organism
  Exceptions : none
  Caller     : general

=cut

sub get_all_mir_aliases {
    my ($self) = @_;
    my @array;
    my $query = qq { SELECT distinct(organism) FROM genome_db  };
	my %aliases =( 
				  'Aedes aegypti'          =>'aae',
				  'Ciona savignyi'         =>'csa',   
				  'Dasypus novemcinctus'    =>'dno',
				  'Echinops telfairi'       =>'ete',
				  'Gasterosteus aculeatus' =>'gac',
				  'Loxodonta africana'     =>'laf',
				  'Ornithorhynchus anatinus'=>'oan',
				  'Oryctolagus cuniculus'  =>'ocu',
				  'Oryzias latipes'        =>'ola',
				  'Anopheles gambiae'      =>'aga',
				  'Bos taurus'             =>'bta',   
				  'Caenorhabditis elegans' =>'cel',
				  'Canis familiaris'       =>'cfa',
				  'Ciona intestinalis'     =>'cin',
				  'Danio rerio'            =>'dre',
				  'Drosophila melanogaster' =>'dme',
				  'Takifugu rubripes'      =>'fru',
				  'Gallus gallus'          =>'gga',
				  'Homo sapiens'           =>'hsa',
				  'Macaca mulatta'         =>'mml',
				  'Monodelphis domestica'  =>'mdo',
				  'Mus musculus'           =>'mmu',
				  'Pan troglodytes'        =>'ptr',
				  'Rattus norvegicus'      =>'rno',
				  'Saccharomyces cerevisiae'=>'sce',
				  'Tetraodon nigroviridis' =>'tni',
				  'Xenopus tropicalis'     =>'xtr'
	);

    my $sth = $self->prepare($query);
    $sth->execute();
	while (my $organism = $sth->fetchrow_array()){
		push (@array, $aliases{$organism});
	}
    return \@array;
}




=head2 fetch_by_organism

  Arg [1]    : $organism
  Example    : @organisms = @{$genome_db_adaptor->fetch_by_organism($organism)};
  Description: Retrieves all db for an organism
  Returntype : list ref of organism
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_organism {
    my ($self,$organism) = @_;
    my @array;
    my $query = qq { SELECT genome_db_id FROM genome_db WHERE organism = ? };

    my $sth = $self->prepare($query);
    $sth->execute($organism);
	while (my $dbID = $sth->fetchrow_array()){
		push (@array, $self->fetch_by_dbID($dbID));
	}
    return \@array;
}

=head2 fetch_by_common_name

  Arg [1]    : $common_name
  Example    : @common_names = @{$genome_db_adaptor->fetch_by_common_name($common_name)};
  Description: Retrieves all db for an common_name
  Returntype : list ref of common_name
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_common_name {
    my ($self,$common_name) = @_;
    my @array;
    my $query = qq { SELECT genome_db_id FROM genome_db WHERE common_name = ? };

    my $sth = $self->prepare($query);
    $sth->execute($common_name);
	while (my $dbID = $sth->fetchrow_array()){
		push (@array, $self->fetch_by_dbID($dbID));
	}
    return \@array;
}


=head2 fetch_by_taxa

  Arg [1]    : $taxa
  Example    : @taxas = @{$genome_db_adaptor->fetch_by_taxa($taxa)};
  Description: Retrieves all db for an taxa
  Returntype : list ref of taxa
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_taxa {
    my ($self,$taxa) = @_;
    my @array;
    my $query = qq { SELECT genome_db_id FROM genome_db WHERE taxa = ? };

    my $sth = $self->prepare($query);
    $sth->execute($taxa);
	while (my $dbID = $sth->fetchrow_array()){
		push (@array, $self->fetch_by_dbID($dbID));
	}
    return \@array;
}

=head2 fetch_All

  Arg [1]    : none
  Example    : $genome_db = $genome_db_adaptor->fetch_All();
  Description: Retrieves an genome_db from the database via its internal id
  Returntype : list ref of Bio::Cogemir::GenomeDB
  Exceptions : none
  Caller     : general

=cut

sub fetch_All {
    my ($self) = @_;
    my @array;
    my $query = qq { SELECT genome_db_id FROM genome_db  };

    my $sth = $self->prepare($query);
    $sth->execute();
	while (my $dbID = $sth->fetchrow_array()){
		my $genome_db =  $self->fetch_by_dbID($dbID);
		push (@array, $genome_db);
	}
    unless (scalar @array){
    	#$self->warn("no genome_db for $organism");
    	return undef;
    }
	
    return \@array;
}
sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT genome_db_id
		FROM genome_db
		WHERE taxon_id = ? and organism = ? and db_host = ? and db_name = ? and db_type = ? 
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->taxon_id(), $obj->organism(), $obj->db_host(), $obj->db_name(), $obj->db_type());
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;

}



=head2 store

  Arg [1]    : Bio::Cogemir::GenomeDB
               the genome_db  to be stored in this database
  Example    : $genome_db_adaptor->store($genome_db);
 Description : Stores an genome_db in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $genome_db ) = @_;
    #if it is not an genome_db dont store
    if( ! $genome_db->isa('Bio::Cogemir::GenomeDB') ) {
	    $self->throw("$genome_db is not a Bio::Cogemir::GenomeDB object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($genome_db->can('dbID') && $genome_db->dbID) {return $genome_db->dbID();}
    
 	my $genome_db_id;
 	if ($self->_exists($genome_db)) {
 		return $self->_exists($genome_db);
 	}

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO genome_db SET taxon_id = ?, organism = ? , db_host = ?, db_name = ?, db_type = ?, common_name = ?, taxa = ?};
	#printf "INSERT INTO genome_db SET taxon_id = %d, organism = \'%s\' , db_host = \'%s\', db_name = \'%s\', db_type = \'%s\', common_name = \'%s\', taxa = \'%s\'\n", ($genome_db->taxon_id(), $genome_db->organism(), $genome_db->db_host(), $genome_db->db_name(), $genome_db->db_type(),$genome_db->common_name,$genome_db->taxa);
    my $sth = $self->prepare($sql);

    $sth->execute($genome_db->taxon_id(), $genome_db->organism(), $genome_db->db_host(), $genome_db->db_name(), $genome_db->db_type(), $genome_db->common_name,$genome_db->taxa);
    
    $genome_db_id = $sth->{'mysql_insertid'};
    $genome_db->dbID($genome_db_id);
    $genome_db->adaptor($self);
    return $genome_db_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::GenomeDB
               the genome_db  to be removed in this database
  Example    : $genome_db_adaptor->remove($genome_db);
 Description : removes an genome_db in the database
  Returntype : boolean
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $genome_db) = @_;
  
  if( ! defined $genome_db->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  foreach my $attribute (@{$self->db->get_AttributeAdaptor->fetch_by_genome_db_id($genome_db->dbID)}){
      $self->db->get_AttributeAdaptor->remove($attribute);
  }
  foreach my $symatlas_annotation (@{$self->db->get_SymatlasAnnotationAdaptor->fetch_by_genome_db_id($genome_db->dbID)}){
      $self->db->get_symatlas_annotationAdaptor->remove($symatlas_annotation);
  }
  my $sth= $self->prepare( "delete from genome_db where genome_db_id = ? " );
  $sth->execute($genome_db->dbID());
  
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::GenomeDB
               the genome_db  to be removed in this database
  Example    : $genome_db_adaptor->remove($genome_db);
 Description : removes an genome_db in the database
  Returntype : boolean
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
  my ($self, $genome_db) = @_;
  
  if( ! defined $genome_db->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  
  my $sth= $self->prepare( "delete from genome_db where genome_db_id = ? " );
  $sth->execute($genome_db->dbID());
  
  return 1;

}


=head2 update

  Arg [1]    : Bio::Cogemir::GenomeDB
               the genome_db  to be updated in this database
  Example    : $genome_db_adaptor->update($genome_db);
 Description : updates an genome_db in the database
  Returntype : Bio::Cogemir::GenomeDB
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $genome_db) = @_;
    if( ! $genome_db->isa('Bio::Cogemir::GenomeDB') ) {
	    $self->throw("$genome_db is not a Bio::Cogemir::GenomeDB object - not storing!");
    }
    my $sql = q { 
	UPDATE genome_db SET taxon_id = ?, organism = ? , db_host = ?, db_name = ?, db_type = ? where genome_db_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($genome_db->taxon_id(), $genome_db->organism(), $genome_db->db_host(), $genome_db->db_name(), $genome_db->db_type, $genome_db->dbID);
    return $self->fetch_by_dbID($genome_db->dbID);
}    
1;
