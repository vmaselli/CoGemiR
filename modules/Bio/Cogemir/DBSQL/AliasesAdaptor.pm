#
# Module for Bio::Cogemir::DBSQL::AliasesAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 REFSEQDNA

Bio::Cogemir::DBSQL::AliasesAdaptor

=head1 SYNOPSIS

    $aliases_adaptor = $dbadaptor->get_AliasesAdaptor();

    $features = $aliases_adaptor->fetch_by_dbID();

    $features = $aliases_adaptor->fetch_by_RefSeq_dna();

=head1 REFSEQDNA_PREDICTED


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it


=cut

$!=1;
package Bio::Cogemir::DBSQL::AliasesAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;

use Bio::Cogemir::Aliases;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBConnection;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of Aliases
  Example    : $aliases = $aliases_adaptor->fetch_by_dbID($aliases_id);
  Description: Retrieves an aliases from the database via its internal id
  Returntype : Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID,$tag) = @_;
    $self->throw("I need a dbID") unless $dbID;
    my $query = qq {
    SELECT RefSeq_dna, ucsc, GeneSymbol, RefSeq_dna_predicted, UniGene
      FROM aliases 
      WHERE aliases_id = ?  
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($RefSeq_dna, $ucsc, $GeneSymbol, $RefSeq_dna_predicted, $UniGene) = $sth->fetchrow_array();
	
	unless (defined $RefSeq_dna){
    	##self->warn("no aliases for dbID $dbID");
    	return undef;
    }
    
	
	my $aliases = new Bio::Cogemir::Aliases ( 
	                                  -dbID => $dbID,
	                                  -adaptor => $self,
									  -RefSeq_dna           => $RefSeq_dna,
                                      -ucsc       => $ucsc,
                                      -GeneSymbol => $GeneSymbol,
                                      -UniGene => $UniGene,
                                      -RefSeq_dna_predicted =>$RefSeq_dna_predicted
                                    );
	#my $mirnas = $self->get_all_Mirnas($dbID);
	#$aliases->mirnas = $mirnas;
	return $aliases;
	
}
=head2 fetch_All

  Arg [1]    : all Aliases
  Example    : $mirna_all = $aliases_adaptor->fetch_All;
  Description: Retrieves an mirna_all from the database via its all
  Returntype : listref Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_All {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT aliases_id FROM aliases};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($dbID) = $sth->fetchrow_array){
		push (@{$ret}, $self->fetch_by_dbID($dbID));
	}
	return $ret;

}
=head2 get_all_Names

  Arg [1]    : all_Names Aliases
  Example    : $mirna_all_Names = $aliases_adaptor->get_all_Names;
  Description: Retrieves an mirna_all_Names from the database via its all_Names
  Returntype : listref RefSeq_dna
  Exceptions : none
  Call_Nameser     : general

=cut

sub get_all_RefSeq_dna {
	my ($self) = @_;
	
	my $ret;
	my $query = qq{SELECT RefSeq_dna FROM aliases};
	my $sth = $self->prepare($query);
	$sth->execute;
	while (my ($RefSeq_dna) = $sth->fetchrow_array){
		push (@{$ret}, $RefSeq_dna);
	}
	return $ret;

}



=head2 fetch_by_RefSeq_dna_predicted

  Arg [1]    : RefSeq_dna of Aliases
  Example    : $aliases = $aliases_adaptor->fetch_by_RefSeq_dna($RefSeq_dna);
  Description: Retrieves an aliases from the database via its RefSeq_dna
  Returntype : Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_RefSeq_dna_predicted {
    my ($self, $value) = @_;
    $self->throw("I need a RefSeq_dna_predicted") unless $value;
    my $res;
    my $query = qq {
    SELECT aliases_id
      FROM aliases
      WHERE RefSeq_dna_predicted =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    my $dbID = $sth->fetchrow_array;
    $res = $self->fetch_by_dbID($dbID) if $dbID;
    return $res;
	
}


=head2 fetch_by_ucsc

  Arg [1]    : ucsc of Aliases
  Example    : $mirna_ucsc = $mirna_ucsc_adaptor->fetch_by_ucsc($ucsc);
  Description: Retrieves an mirna_ucsc from the database via its ucsc
  Returntype : Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_ucsc {
    my ($self, $value) = @_;
    $self->throw("I need a ucsc internal id") unless $value;
    my $query = qq {
    SELECT aliases_id
      FROM aliases
      WHERE ucsc =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    my $dbID = $sth->fetchrow;
    return undef unless defined $dbID;
	return $self->fetch_by_dbID($dbID);
}

=head2 fetch_by_GeneSymbol

  Arg [1]    : GeneSymbol of Aliases
  Example    : $mirna_GeneSymbol = $mirna_GeneSymbol_adaptor->fetch_by_GeneSymbol($GeneSymbol);
  Description: Retrieves an mirna_GeneSymbol from the database via its GeneSymbol
  Returntype : listref Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_GeneSymbol {
    my ($self, $value) = @_;
    $self->throw("I need a exon conservation term") unless $value;
    my @aliasess;
    my $query = qq {
    SELECT aliases_id
      FROM aliases
      WHERE GeneSymbol = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while (my $dbID = $sth->fetchrow_array){
        push (@aliasess, $self->fetch_by_dbID($dbID));
    }
	return \@aliasess;
}

=head2 fetch_by_UniGene

  Arg [1]    : UniGene of Aliases
  Example    : $mirna_UniGene = $mirna_UniGene_adaptor->fetch_by_UniGene($UniGene);
  Description: Retrieves an mirna_UniGene from the database via its UniGene
  Returntype : listref Bio::Cogemir::Aliases
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_UniGene {
    my ($self, $value) = @_;
    $self->throw("I need a hostgene conservation term") unless $value;
    my @aliasess;
    my $query = qq {
    SELECT aliases_id
      FROM aliases
      WHERE UniGene = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while (my $dbID = $sth->fetchrow_array){
        push (@aliasess, $self->fetch_by_dbID($dbID));
    }
	return \@aliasess;
}


sub _exists{
	my ($self,$obj) = @_;
	my $obj_id;

	my $sql = qq{SELECT aliases_id FROM aliases WHERE RefSeq_dna = ?  and GeneSymbol = ? and  ucsc = ? and UniGene = ? and RefSeq_dna_predicted = ?};
	my $sth = $self->prepare($sql);
	$sth->execute($obj->RefSeq_dna, $obj->GeneSymbol, $obj->ucsc, $obj->UniGene, $obj->RefSeq_dna_predicted);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Aliases
               the Aliases  to be stored in this database
  Example    : $aliases_adaptor->store($aliases);
 Description : Stores an Aliases in the database
  Returntype : string, aliases_id
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $aliases ) = @_;
	
    # if the object being passed is a Cogemir::Aliases store it locally with the aliasesuence
    if( ! $aliases->isa('Bio::Cogemir::Aliases') ) {
	$self->throw("$aliases is not a Bio::Cogemir::Aliases object - not storing!");
    }
   
    # if the dbID is present and if the Aliases is already stored return the dbID 
    if ($aliases->can('dbID')&& $aliases->dbID) {return $aliases->dbID();}
    
    # if ucsc doesn't exist store it
    
    if ($self->_exists($aliases)){
        return $self->_exists($aliases);
    }

    my $sql = q { INSERT INTO aliases SET RefSeq_dna = ?, GeneSymbol = ? ,  ucsc = ?, UniGene = ?, RefSeq_dna_predicted = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($aliases->RefSeq_dna, $aliases->GeneSymbol, $aliases->ucsc, $aliases->UniGene, $aliases->RefSeq_dna_predicted);
    
    my $aliases_id = $sth->{'mysql_insertid'};
 	$aliases->dbID($aliases_id);
 	$aliases->adaptor($self);
 	
   	return $aliases_id;

}

=head2 remove

  Arg [1]    : Bio::Cogemir::Aliases
               the Aliases  to be removed from this database
  Example    : $aliases_adaptor->remove($aliases);
 Description : Delete  a aliases in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub remove {
    
  my ($self, $aliases) = @_;

  if( ! defined $aliases->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
 
  my $sth= $self->prepare( "delete from aliases where aliases_id = ? " );
  $sth->execute($aliases->dbID());
  return 1;
}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Aliases
               the Aliases  to be removed from this database
  Example    : $aliases_adaptor->remove($aliases);
 Description : Delete  a aliases in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub _remove {
    
    my ($self, $aliases) = @_;

    if( ! defined $aliases->dbID() ) {
	    $self->throw("A dbID is not defined\n");
    }
   
    my $sth= $self->prepare( "delete from aliases where aliases_id = ? " );
    $sth->execute($aliases->dbID());
    return 1;

}


=head2 update

  Arg [1]    : Bio::Cogemir::Aliases
               the Aliases  to be updated in this database
  Example    : $aliases_adaptor->update($aliases);
 Description : Stores an Aliases in the database
  Returntype : Bio::Cogemir::Aliases
  Exceptions :
  Caller     : general

=cut

sub update {
    my ( $self, $aliases ) = @_;
    if( ! $aliases->isa('Bio::Cogemir::Aliases') ) {
	$self->throw("$aliases is not a Bio::Cogemir::Aliases object - not updating!");
    }
   
    my $sql = q { UPDATE aliases SET RefSeq_dna = ?, GeneSymbol = ? ,  ucsc = ?, UniGene = ?, RefSeq_dna_predicted = ? WHERE aliases_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($aliases->RefSeq_dna, $aliases->GeneSymbol, $aliases->ucsc, $aliases->UniGene, $aliases->RefSeq_dna_predicted, $aliases->dbID);
    
    return $self->fetch_by_dbID($aliases->dbID);
}
1;
