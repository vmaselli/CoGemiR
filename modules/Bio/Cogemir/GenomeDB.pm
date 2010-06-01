#
# Module for Bio::Cogemir::GenomeDB
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::GenomeDB

=head1 SYNOPSIS

	 
    my $genome_db =  Bio::Cogemir::GenomeDB->new(  
							    -TAXONID => $taxon_id,
							    -ORGANISM => $organism,
							    -DB_HOST => $db_host,
							    -DB_NAME => $db_name,
							    -DB_TYPE => $db_type,
							    -COMMON_NAME =>$common_name,
							    -TAXA =>$taxa
							   );
	
    $organism = $domain->organism();

=head1 DESCRIPTION

    This adaptor work with the domain table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::GenomeDB;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Data::Dumper;

@ISA = qw(Bio::Root::Root);


#constructor
=head2 new

 Title          : new
 Usage          : my $genome_db =  Bio::Cogemir::GenomeDB->new(  
							    -TAXONID => $taxon_id,
							    -ORGANISM => $organism,
							    -DB_HOST => $db_host,
							    -DB_NAME => $db_name,
							    -DB_TYPE => $db_type,
							    -COMMON_NAME =>$common_name,
							    -TAXA =>$taxa
							   );
 Returns        : Bio::Cogemir::Domain
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have organism

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$taxon_id,
		$organism,
		$db_host,
		$db_name,
		$db_type,
		$common_name,
		$taxa
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		TAXON_ID
		ORGANISM
		DB_HOST
		DB_NAME
		DB_TYPE
		COMMON_NAME
		TAXA
		)], @args);
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$taxon_id && $self->taxon_id($taxon_id);
	$organism && $self->organism($organism);
	$db_host && $self->db_host($db_host);
	$db_name && $self->db_name($db_name);
	$db_type && $self->db_type($db_type);
	$common_name && $self->common_name($common_name);
	$taxa && $self->taxa($taxa);
	# we must have an organism and an host db
    if (! ($self->organism) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need an organism!!!");
    }
     if (! ($self->db_host) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need a db host!!!");
    }
    if (! ($self->db_name) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need a db name!!!");
    }
    if (! ($self->db_type) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need a db type!!!");
    }
      if (! ($self->common_name) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need a common_name!!!");
    }
      if (! ($self->taxa) ) {
	$self->throw("The GenomeDB does not have all attributes to be created I need a taxa!!!");
    }

    
	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Function : get/set method for attribute dbID
 Returns  : Value of dbID
 Args     : New value of dbID (optional)
    
=cut


sub dbID {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'};
}

=head2 adaptor
    
 Title    : adaptor
 Usage    : $obj->adaptor ($newval)
 Function : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::DBSQL::GenomeDBAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 taxon_id
    
 Title    : taxon_id
 Usage    : $obj->taxon_id ($newval)
 Function : get/set method for attribute taxon_id
 Returns  : Value of taxon_id
 Args     : New value of taxon_id (optional)
    
=cut


sub taxon_id {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'taxon_id'} = $value;
    }
    return $self->{'taxon_id'};
}

=head2 organism
    
 Title    : organism
 Usage    : $obj->organism ($newval)
 Function : get/set method for attribute organism
 Returns  : Value of organism
 Args     : New value of organism (optional)
    
=cut


sub organism {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'organism'} = $value;
    }
    return $self->{'organism'};
}



=head2 db_host
    
 Title    : db_host
 Usage    : $obj->db_host ($newval)
 Function : get/set method for attribute db_host
 Returns  : Value of db_host
 Args     : New value of db_host (optional)
    
=cut


sub db_host {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_host'} = $value;
    }
    return $self->{'db_host'};
}

=head2 db_name
    
 Title    : db_name
 Usage    : $obj->db_name ($newval)
 Function : get/set method for attribute db_name
 Returns  : Value of db_name
 Args     : New value of db_name (optional)
    
=cut


sub db_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_name'} = $value;
    }
    return $self->{'db_name'};
}

=head2 db_type
    
 Title    : db_type
 Usage    : $obj->db_type ($newval)
 Function : get/set method for attribute db_type
 Returns  : Value of db_type
 Args     : New value of db_type (optional)
    
=cut


sub db_type {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'db_type'} = $value;
    }
    return $self->{'db_type'};
}

=head2 common_name
    
 Title    : common_name
 Usage    : $obj->common_name ($newval)
 Function : get/set method for attribute common_name
 Returns  : Value of common_name
 Args     : New value of common_name (optional)
    
=cut


sub common_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'common_name'} = $value;
    }
    return $self->{'common_name'};
}

=head2 taxa
    
 Title    : taxa
 Usage    : $obj->taxa ($newval)
 Function : get/set method for attribute taxa
 Returns  : Value of taxa
 Args     : New value of taxa (optional)
    
=cut


sub taxa {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'taxa'} = $value;
    }
    return $self->{'taxa'};
}


sub ncbi_ref{
    my ($self) = @_;
    my $ref = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=".$self->taxon_id;
    $self->{'ncbi_ref'} = $ref;
    return $self->{'ncbi_ref'};
}



1;
