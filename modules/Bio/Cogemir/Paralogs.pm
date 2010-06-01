#
# Module for Bio::Cogemir::Paralogs
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::GeneParalogsDB::Paralogs

=head1 SYNOPSIS
	
	my $paralogs =  Bio::Cogemir::Paralogs->new(   
							    -QUERY => $query_obj, 
							    -TARGET => $target_microrna_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						                                                   );

       $target_microrna_obj = $paralogs->target_microrna();

=head1 DESCRIPTION

    This adaptor work with the paralogs table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Paralogs;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $paralogs =  Bio::Cogemir::Paralogs->new(   
							    -QUERY => $query_obj, 
							    -TARGET => $target_microrna_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						                                                   );

 Returns        : Bio::Cogemir::Paralogs
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have query obj, target_microrna obj, type and analysis

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$query_microrna_obj,
		$target_microrna_obj,
		$type,
		$analysis_obj
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		QUERY_MICRORNA
		TARGET_MICRORNA
		TYPE
		ANALYSIS
		)], @args);
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$query_microrna_obj && $self->query_microrna($query_microrna_obj);
	$target_microrna_obj && $self->target_microrna($target_microrna_obj);
	$type && $self->type($type);
	$analysis_obj && $self->analysis($analysis_obj);
	
	if(!$self->query_microrna ){
		$self->throw("The Paralogs does not have all attributes to be created: I need query_microrna ");
	}
	elsif(! $self->target_microrna ){
		$self->throw("The Paralogs does not have all attributes to be created: I need target_microrna ");
	}
	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ([$newval])
 Function : get/set method for attribute dbID
 Returns  : Value of dbID (integer)
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
 Usage    : $obj->adaptor ([Bio::MIRNABD::ParalogsAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::ParalogsAdaptor
 Args     : New value of Bio::MIRNABD::ParalogsAdaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}


=head2 target_microrna
    
 Title    : target_microrna
 Usage    : $obj->target_microrna ([Bio::Cogemir::MicroRNA])
 Function : get/set method for attribute target_microrna 
 Returns  : Value of Bio::Cogemir::Seq
 Args     : New value of Bio::Cogemir::Seq (optional)
 Note     : In the next version of DB target_microrna will be a Bio::Cogemir::MicroRNA obj
    
=cut


sub target_microrna {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'target_microrna'} = $value;
    }
    return $self->{'target_microrna'};
}

=head2 query_microrna
    
 Title    : query
 Usage    : $obj->query_microrna ([Bio::Cogemir::MicroRNA])
 Function : get/set method for attribute query
 Returns  : Value of Bio::Cogemir::Seq
 Args     : New value of Bio::Cogemir::Seq (optional)
 Note     : In the next version of DB query will be a Bio::Cogemir::MicroRNA obj
    
=cut


sub query_microrna {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'query_microrna'} = $value;
    }
    return $self->{'query_microrna'};
}

=head2 type
    
 Title    : type
 Usage    : $obj->type ([$newval])
 Function : get/set method for attribute type
 Returns  : Value of type (string)
 Args     : New value of type (optional)
    
=cut


sub type {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'type'} = $value;
    }
    return $self->{'type'};
}

=head2 analysis
    
 Title    : analysis
 Usage    : $obj->analysis_obj ([Bio::Cogemir::Analysis])
 Function : get/set method for attribute analysis
 Returns  : Value of Bio::Cogemir::Analysis
 Args     : New value of Bio::Cogemir::Analysis (optional)
    
=cut


sub analysis {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'analysis'} = $value;
    }
    return $self->{'analysis'};
}

1;
