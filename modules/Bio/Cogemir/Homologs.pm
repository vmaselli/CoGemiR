#
# Module for Bio::Cogemir::Homologs
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::GeneHomologsDB::Homologs

=head1 SYNOPSIS
	
	my $homologs =  Bio::Cogemir::Homologs->new(   
							    -QUERY => $query_obj, 
							    -TARGET => $target_gene_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						                                                   );

       $target_gene_obj = $homologs->target_gene();

=head1 DESCRIPTION

    This adaptor work with the homologs table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Homologs;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $homologs =  Bio::Cogemir::Homologs->new(   
							    -QUERY => $query_obj, 
							    -TARGET => $target_gene_obj, 
							    -TYPE => $type, 
							    -ANALYSIS => $analysis_obj, 						                                                   );

 Returns        : Bio::Cogemir::Homologs
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have query obj, target_gene obj, type and analysis

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$query_gene_obj,
		$target_gene_obj,
		$type,
		$analysis_obj
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		QUERY_GENE
		TARGET_GENE
		TYPE
		ANALYSIS
		)], @args);
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$query_gene_obj && $self->query_gene($query_gene_obj);
	$target_gene_obj && $self->target_gene($target_gene_obj);
	$type && $self->type($type);
	$analysis_obj && $self->analysis($analysis_obj);
	
	if(!$self->query_gene ){
		$self->throw("The Homologs does not have all attributes to be created query_gene ");
	}
	elsif(! $self->target_gene ){
		$self->throw("The Homologs does not have all attributes to be created target_gene ");
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
 Usage    : $obj->adaptor ([Bio::MIRNABD::HomologsAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::HomologsAdaptor
 Args     : New value of Bio::MIRNABD::HomologsAdaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}


=head2 target_gene
    
 Title    : target_gene
 Usage    : $obj->target_gene ([Bio::Cogemir::Gene])
 Function : get/set method for attribute target_gene 
 Returns  : Value of Bio::Cogemir::Seq
 Args     : New value of Bio::Cogemir::Seq (optional)
 Note     : In the next version of DB target_gene will be a Bio::Cogemir::Gene obj
    
=cut


sub target_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'target_gene'} = $value;
    }
    return $self->{'target_gene'};
}

=head2 query_gene
    
 Title    : query
 Usage    : $obj->query_gene ([Bio::Cogemir::Gene])
 Function : get/set method for attribute query
 Returns  : Value of Bio::Cogemir::Seq
 Args     : New value of Bio::Cogemir::Seq (optional)
 Note     : In the next version of DB query will be a Bio::Cogemir::Gene obj
    
=cut


sub query_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'query_gene'} = $value;
    }
    return $self->{'query_gene'};
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
