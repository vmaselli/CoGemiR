#
# Module for Bio::Cogemir::DBSQL::LocalizationAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::LocalizationAdaptor

=head1 SYNOPSIS

    $localization_adaptor = $db->get_LocalizationAdaptor();

    $localization = $localization_adaptor->fetch_by_dbID();

    $localization = $localization_adaptor->fetch_by_label();

=head1 DESCRIPTION

    This adaptor work with the localization table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut

$!=1;
package Bio::Cogemir::DBSQL::LocalizationAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;

use Bio::Cogemir::Localization;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

my $debug = 0;

=head2 fetch_by_dbID

  Arg [1]    : internal id of localization
  Example    : $localization = $localization_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an localization from the database via its internal id
  Returntype : Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;

    $self->throw("I need a localization id") unless $dbID;
	
    my $query = qq {
    SELECT  label, module_rank, offset, transcript_id, micro_rna_id
      FROM localization 
      WHERE localization_id = ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID );
	my ($label, $module_rank, $offset, $transcript_id, $micro_rna_id) = $sth->fetchrow_array();

     unless (defined $micro_rna_id){
    	$self->warn("no localization for $dbID");
    	return undef;
    }
    my $transcript = $self->db->get_TranscriptAdaptor->fetch_by_dbID($transcript_id) if $transcript_id;
    my $micro_rna = $self->db->get_MicroRNAAdaptor->fetch_by_dbID($micro_rna_id);
    my ($localization) =  Bio::Cogemir::Localization->new(   
							    -DBID => $dbID,
							    -ADAPTOR => $self,
							    -LABEL => $label,  
							    -MODULE_RANK => $module_rank,  
							    -OFFSET => $offset,
							    -TRANSCRIPT => $transcript,
							    -MICRO_RNA => $micro_rna
							   );


    return $localization;
}

=head2 fetch_by_label

  Arg [1]    : gene name
  Example    : $localization = $localization_adaptor->fetch_by_label($dbID);
  Description: Retrieves an localization from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_label {
    my ($self, $label) = @_;
    my ($localization, @localizations, $dbID);
    $self->throw("I need a gene name") unless $label;

    my $query = qq {
    SELECT localization_id
      FROM localization 
      WHERE  label = ?  
  };
    my $sth = $self->prepare($query);
    $sth->execute($label);
	while($dbID = $sth->fetchrow_array()){
		$localization = $self->fetch_by_dbID($dbID);
		push (@localizations, $localization);
	}
    return \@localizations;
}

=head2 get_all_Labels

  Arg [1]    :
  Example    : $localization = $localization_adaptor->get_all_Labels();
  Description: Retrieves all labels from the localization table
  Returntype : list ref of name
  Exceptions : none
  Caller     : general

=cut

sub get_all_Labels {
    my ($self) = @_;
    
    my $localization;
    my $query = qq {
    SELECT distinct(label)
      FROM localization 
  };
    my $sth = $self->prepare($query);
    $sth->execute();
	while(my ($label) = $sth->fetchrow_array()){
		push (@{$localization},$label);
	}
    return $localization;
}


=head2 fetch_by_module_rank

  Arg [1]    : ensembl gene stable id
  Example    : $localization = $localization_adaptor->fetch_by_module_rank(1);
  Description: Retrieves an localization from the database via its external gene stable id
  Returntype : Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut


sub fetch_by_module_rank {
    my ($self, $module_rank) = @_;
    $self->throw("I need a gene stable id") unless $module_rank;
	
    my $query = qq {
    SELECT localization_id
      FROM localization 
      WHERE  module_rank =  ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($module_rank );
	my $dbID = $sth->fetchrow_array();
	unless (defined $dbID){
    	$self->warn("no localization for $module_rank") if $debug ;
    	return undef;
    }
    return  $self->fetch_by_dbID($dbID);
}


=head2 fetch_by_offset

  Arg [1]    : external name
  Example    : $localization = $localization_adaptor->fetch_by_offset('P63');
  Description: Retrieves an localization from the database via its external (generic) name
  Returntype : list of Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_offset {
    my ($self, $offset) = @_;
    my ($localization, @localizations, $dbID);
    $self->throw("I need a external name") unless $offset;

    my $query = qq {
    SELECT localization_id
      FROM localization 
      WHERE  offset =  ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($offset);
	
	while($dbID = $sth->fetchrow_array()){
		$localization = $self->fetch_by_dbID($dbID);
		push (@localizations, $localization);
	}
	
	unless (@localizations){
    		#$self->warn("no localization for $label");
    		return undef;
    	}
	##print Dumper @localizations;
    return \@localizations;
}

=head2 fetch_by_transcript

  Arg [1]    : gene name
  Example    : $localization = $localization_adaptor->fetch_by_transcript($dbID);
  Description: Retrieves an localization from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_transcript {
    my ($self, $transcript) = @_;
    
    $self->throw("I need a gene name") unless $transcript;

    my $query = qq {
    SELECT localization_id
      FROM localization 
      WHERE  transcript_id = ? 
  };
	#print "$query ", $transcript,"\n";;
    my $sth = $self->prepare($query);
    my $string = 
    $sth->execute($transcript);
	my $dbID = $sth->fetchrow_array;
	my $localization = $self->fetch_by_dbID($dbID) if $dbID;

    return $localization;
}

=head2 fetch_by_micro_rna

  Arg [1]    : gene name
  Example    : $localization = $localization_adaptor->fetch_by_micro_rna($dbID);
  Description: Retrieves an localization from the database via its gene name
  Returntype : list of ref to Bio::Cogemir::Localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_micro_rna {
    my ($self, $micro_rna) = @_;
    my ($localization, @localizations, $dbID);
    $self->throw("I need a gene name") unless $micro_rna;

    my $query = qq {
    SELECT localization_id
      FROM localization 
      WHERE  micro_rna_id = ? 
  };
    my $sth = $self->prepare($query);
    my $string = 
    $sth->execute($micro_rna);
	while($dbID = $sth->fetchrow_array()){
		$localization = $self->fetch_by_dbID($dbID);
		push (@localizations, $localization);
	}
	
	
    return \@localizations;
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $transcript_id = $obj->transcript->dbID if $obj->transcript;
	my $query = qq {
		SELECT localization_id
		FROM localization
		WHERE transcript_id = ? and micro_rna_id = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($transcript_id, $obj->micro_rna->dbID );
	$obj_id = $sth->fetchrow_array();
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}



=head2 store

  Arg [1]    : Bio::Cogemir::Localization
               the localization  to be stored in this database
  Example    : $localization_adaptor->store($localization);
 Description : Stores an localization in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $localization ) = @_;
	
    #if it is not an localization dont store
    if( ! $localization->isa('Bio::Cogemir::Localization') ) {
	$self->throw("$localization is not a Bio::Cogemir::Localization object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($localization->can('dbID') && $localization->dbID) {return $localization->dbID();}  
    my $transcript_id;
    if ($localization->transcript){
        unless ($localization->transcript->dbID){$transcript_id = $self->db->get_TranscriptAdaptor->store($localization->transcript);}
        else{$transcript_id = $localization->transcript->dbID}
    }
    unless ($localization->micro_rna->dbID){$self->db->get_MicroRNAAdaptor->store($localization->micro_rna);}
	if ($self->_exists($localization)){return $self->_exists($localization);}
	
	#otherwise store the information being passed
    my $sql = q { 
	INSERT INTO localization SET  label = ? ,module_rank = ?, offset = ?, transcript_id = ?, micro_rna_id = ?
    };

    my $sth = $self->prepare($sql);

    $sth->execute($localization->label, $localization->module_rank, $localization->offset, $transcript_id, $localization->micro_rna->dbID);
    my $localization_id = $sth->{'mysql_insertid'};
    $localization->dbID($localization_id);
    $localization->adaptor($self);
    return $localization_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Localization
               the localization  to be removed in this database
  Example    : $localization_adaptor->remove($localization);
 Description : Remove a localization and relative objectsin the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $localization) = @_;
    
    if( ! defined $localization->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    my $sth= $self->prepare( "delete from localization where localization_id = ? " );
    $sth->execute($localization->dbID());
    
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Localization
               the localization  to be removed in this database
  Example    : $localization_adaptor->remove($localization);
 Description : Remove a localization and relative objectsin the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $localization) = @_;
    #print $self." _remove\n";
    if( ! defined $localization->dbID() ) {
	$self->throw("A dbID is not defined\n");
    }
    
    my $sth= $self->prepare( "delete from localization where localization_id = ? " );
    $sth->execute($localization->dbID());
    
    return 1;

}


=head2 

  Arg [1]    : Bio::Cogemir::Localization
               the localization  to be removed in this database
  Example    : $localization_adaptor->remove($localization);
 Description : Stores an localization in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update{
	my ($self, $localization) = @_;
	    if( ! $localization->isa('Bio::Cogemir::Localization') ) {
	$self->throw("$localization is not a Bio::Cogemir::Localization object - not updating!");
    }

	my $transcript_id = $localization->transcript->dbID if $localization->transcript;
	my $sql = q { 
	UPDATE localization SET  label = ? ,module_rank = ?, offset = ?, transcript_id = ?, micro_rna_id = ?
	WHERE localization_id = ?
    };

    my $sth = $self->prepare($sql);
    $sth->execute($localization->label, $localization->module_rank, $localization->offset, $transcript_id, $localization->micro_rna->dbID, $localization->dbID);
    return $self->fetch_by_dbID($localization->dbID);
}

1;