#
# Module for Bio::Cogemir::Cluster
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::GeneClusterDB::Cluster

=head1 SYNOPSIS

	  
    my ($cluster) =  Bio::Cogemir::Cluster->new(   
							    -NAME => $name,
							    -ANALYSIS =>$analysis_obj
							   );

    $name = $cluster->name();

=head1 DESCRIPTION

    This adaptor work with the cluster table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Cluster;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my ($cluster) =  Bio::Cogemir::Cluster->new(   
							    -NAME => $name,
							    -ANALYSIS =>$analysis_obj
							   );
 Returns        : Bio::Cogemir::Cluster
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have name

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$name,
		$analysis_obj
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		NAME
		ANALYSIS
		)], @args);

	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$name && $self->name($name);
    $analysis_obj && $self->analysis($analysis_obj);
    
	# we must have a name 
    if (! ($self->name) ) {
	$self->throw("The Cluster does not have all attributes to be created: I need a name");
    }
    
	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Cluster : get/set method for attribute dbID
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
 Cluster : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::ClusterAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 name
    
 Title    : name
 Usage    : $obj->name ($newval)
 Cluster : get/set method for attribute name
 Returns  : Value of name (string)
 Args     : New value of name (optional)
    
=cut


sub name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'name'} = $value;
    }
    return $self->{'name'};
}

=head2 analysis
    
 Title    : analysis
 Usage    : $obj->analysis ($newval)
 Cluster : get/set method for attribute analysis
 Returns  : Value of analysis (string)
 Args     : New value of analysis (optional)
    
=cut


sub analysis {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'analysis'} = $value;
    }
    return $self->{'analysis'};
}
1;
