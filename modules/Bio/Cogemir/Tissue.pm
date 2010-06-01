#
# Module for Bio::Cogemir::Tissue
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::GeneTissueDB::Tissue

=head1 SYNOPSIS

	  
    my ($tissue) =  Bio::Cogemir::Tissue->new(   
							    -NAME => $name
							   );

    $name = $tissue->name();

=head1 DESCRIPTION

    This adaptor work with the tissue table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Tissue;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my ($tissue) =  Bio::Cogemir::Tissue->new(   
							    -NAME => $name
							   );
 Returns        : Bio::Cogemir::Tissue
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have name

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$name
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		NAME
		)], @args);
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$name && $self->name($name);
	# we must have a name 
    if (! ($self->name) ) {
	$self->throw("The Tissue does not have all attributes to be created: I need a name");
    }
    
	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Tissue : get/set method for attribute dbID
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
 Tissue : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::TissueAdaptor
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
 Tissue : get/set method for attribute name
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

1;
