#
# Module for Bio::Cogemir::DBSQL::TissueAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::tissueAdaptor

=head1 SYNOPSIS

    $tissue_adaptor = $db->get_tissueAdaptor();

    $tissue = $tissue_adaptor->fetch_by_dbID();

    $tissue = $tissue_adaptor->fetch_by_name();

=head1 DESCRIPTION

    This adaptor work with the tissue table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::TissueAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Bio::Cogemir::Tissue;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of Tissue
  Example    : $tissue = $ln_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an tissue from the database via its internal id
  Returntype : Bio::Cogemir::Tissue
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a tissue id") unless $dbID;
    my $query = qq {
    SELECT name
      FROM tissue 
      WHERE  tissue_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($name) = $sth->fetchrow_array();
    unless (defined $name){
    	#$self->warn("no tissue for $dbID");
    	return undef;
    }
    my ($tissue) =  Bio::Cogemir::Tissue->new(   
							    -DBID => $dbID,
							    -ADAPTOR =>$self,
							    -NAME => $name
							   );


    return $tissue;
}

=head2 fetch_All

  Arg [1]    : 
  Example    : $tissue = $tissue_adaptor->fetch_All($name);
  Description: Retrieves an tissue from the database via its name
  Returntype : Bio::Cogemir::Tissue
  Exceptions : none
  Caller     : general

=cut

sub fetch_All {
    my ($self) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT tissue_id
      FROM tissue 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($dbID) = $sth->fetchrow_array()){
    	push (@{$tissue},$self->fetch_by_dbID($dbID));
    }
    return $tissue;
}


sub fetch_all_web {
    my ($self) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT distinct(tissue_name)
      FROM micro_rna_tissue 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($name) = $sth->fetchrow_array()){
    	push (@{$tissue},$self->fetch_by_name($name));
    }
    return $tissue;
}

=head2 get_all_Names

  Arg [1]    : 
  Example    : $tissue = $tissue_adaptor->get_all_Names($name);
  Description: Retrieves an tissue from the database via its name
  Returntype : Bio::Cogemir::Tissue
  Exceptions : none
  Call_Nameser     : general

=cut

sub get_all_Names {
    my ($self) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT name
      FROM tissue 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($name) = $sth->fetchrow_array()){
    	push (@{$tissue},$name);
    }
    return $tissue;
}

sub get_all_names_web {
    my ($self) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT distinct(tissue_name)
      FROM micro_rna_tissue 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($name) = $sth->fetchrow_array()){
    	push (@{$tissue},$name);
    }
    return $tissue;
}


sub get_all_names_web_organism {
    my ($self,$organism) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT distinct(mrt.tissue_name)
      FROM micro_rna_tissue mrt, micro_rna mr, attribute a, genome_db g
      WHERE mrt.micro_rna_id - mr.micro_rna_id
      AND mr.attribute_id = a.attribute_id
      AND a.genome_db_id = g.genome_db_id
      AND g.organism = ?
      AND g.db_type = 'core'
  };
    my $sth = $self->prepare($query);
    $sth->execute($organism);
	while(my ($name) = $sth->fetchrow_array()){
    	push (@{$tissue},$name);
    }
    return $tissue;
}

=head2 get_All

  Arg [1]    : 
  Example    : $tissue = $tissue_adaptor->get_all_Names($name);
  Description: Retrieves an tissue from the database via its name
  Returntype : Bio::Cogemir::Tissue
  Exceptions : none
  Call_Nameser     : general

=cut

sub get_All {
    my ($self) = @_;
    
    my $tissue;
    my $query = qq {
    SELECT tissue_id
      FROM tissue 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($tissue_id) = $sth->fetchrow_array()){
    	push (@{$tissue},$self->fetch_by_dbID($tissue_id));
    }
    return $tissue;
}

=head2 fetch_by_name

  Arg [1]    : tissue name
  Example    : $tissue = $tissue_adaptor->fetch_by_name($name);
  Description: Retrieves an tissue from the database via its name
  Returntype : Bio::Cogemir::Tissue
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
    my ($self, $name) = @_;
    
    my $tissue;
    $self->throw("I need a name") unless $name;
    my $query = qq {
    SELECT tissue_id
      FROM tissue 
      WHERE  name = ? 
  };
   
    my $sth = $self->prepare($query);
    $sth->execute($name);
	my ($dbID) = $sth->fetchrow_array();
    $tissue = $self->fetch_by_dbID($dbID) if $dbID;
    return $tissue;
}

sub fetch_by_name_like {
    my ($self, $name) = @_;
    
    my $tissue;
    $self->throw("I need a name") unless $name;
    my $query = qq {
    SELECT tissue_id
      FROM tissue 
      WHERE  name LIKE ? 
  };
   
    my $sth = $self->prepare($query);
    $sth->execute($name);
	my ($dbID) = $sth->fetchrow_array();
    $tissue = $self->fetch_by_dbID($dbID) if $dbID;
    return $tissue;
}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT tissue_id
		FROM tissue
		WHERE name = ?
	};;
	my $sth = $self->prepare($query);
	$sth->execute($obj->name);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Expression
               the tissue  to be stored in this database
  Example    : $tissue_adaptor->store($tissue);
 Description : Stores an tissue in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $tissue ) = @_;


    #if it is not an tissue don't store
    if( ! $tissue->isa('Bio::Cogemir::Tissue') ) {
	$self->throw("$tissue is not a Bio::Cogemir::Tissue object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($tissue->can('dbID') && $tissue->dbID) {return $tissue->dbID();}  
    
    #if name exists return without storing
    if ($self->_exists($tissue)){
        return $self->_exists($tissue);
    }

    #otherwise store the information being passed
    my $sql = q {INSERT INTO tissue SET name = ?};

    my $sth = $self->prepare($sql);

    $sth->execute($tissue->name());
    
    my $tissue_id = $sth->{'mysql_insertid'};
    $tissue->dbID($tissue_id);
    $tissue->adaptor($self);
    return $tissue_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Tissue
               the tissue  to be removed in this database
  Example    : $tissue_adaptor->remove($tissue);
 Description : removes an tissue in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $tissue) = @_;
    
    if( ! defined $tissue->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    foreach my $expression (@{$self->db->get_ExpressionAdaptor->fetch_by_tissue_id($tissue->dbID)}){
        $expression->tissue->dbID(0);
        $self->db->get_ExpressionAdaptor->update($expression);
    }
    
    my $sth= $self->prepare( "delete from tissue where tissue_id = ? " );
    $sth->execute($tissue->dbID());
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Tissue
               the tissue  to be removed in this database
  Example    : $tissue_adaptor->remove($tissue);
 Description : removes an tissue in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $tissue) = @_;
    
    if( ! defined $tissue->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    my $sth= $self->prepare( "delete from tissue where tissue_id = ? " );
    $sth->execute($tissue->dbID());
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Tissue
               the tissue  to be updated in this database
  Example    : $tissue_adaptor->update($tissue);
 Description : updates an tissue in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $tissue) = @_;
    if( ! $tissue->isa('Bio::Cogemir::Tissue') ) {
	$self->throw("$tissue is not a Bio::Cogemir::Tissue object - not updating!");
    }
    my $sql = q {UPDATE tissue SET name = ? where tissue_id = ? };
    my $sth = $self->prepare($sql);
    $sth->execute($tissue->name(),$tissue->dbID);
    return $self->fetch_by_dbID($tissue->dbID);
}
1;
