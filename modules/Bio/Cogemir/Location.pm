#
# Module for Bio::Cogemir::Location
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Location

=head1 SYNOPSIS

	my $location =  Bio::Cogemir::Location->new(   
							    -NAME => $name,
							    -START => $start,
							    -END => $end,
							    -STRAND => $strand
							   );

	my $name = $location->name;
	
=head1 DESCRIPTION

    This module work with the location object 


=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Location;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $location =  Bio::Cogemir::Location->new(   
							    -DBID =>$dbID,
							    -ADAPTOR => $adaptor,
							    -NAME => $name,
							    -START => $start,
							    -END => $end,
							    -STRAND => $strand
							   );
 Returns        : Bio::Cogemir::Location
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$coord,
		$name,
		$start,
		$end,
		$strand
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		COORDSYSTEM
		NAME
		START
		END
		STRAND
		)],@args);
	
	$dbID && $self->dbID($dbID); 
	$adaptor && $self->adaptor($adaptor);
	$self->start($start) if defined $start;
	$self->end($end) if defined $end;
	$strand && $self->strand($strand);
	$name && $self->name($name);
	$coord && $self->CoordSystem($coord);
	
	 if (! ($self->name) ) {
		$self->throw("The Location does not have all attributes to be created I need a name!!!");
    }
    if (! ($self->start) ) {
		$self->throw("The Location does not have all attributes to be created I need a start!!!");
    }
    if (! ($self->end) ) {
		$self->throw("The Location does not have all attributes to be created I need an end!!!");
    }
    if (! ($self->CoordSystem) ) {
		$self->throw("The Location does not have all attributes to be created I need an coordinate system!!!");
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
 Returns  : Bio::Cogemir::DBSQL::LocationAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}


=head2 start
    
 Title    : start
 Usage    : $obj->start ($newval)
 Function : get/set method for attribute start
 Returns  : Value of start
 Args     : New value of start (optional)
    
=cut


sub start {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'start'} = $value;
    }
    return $self->{'start'};
}

=head2 end
    
 Title    : end
 Usage    : $obj->end ($newval)
 Function : get/set method for attribute end
 Returns  : Value of end
 Args     : New value of end (optional)
    
=cut


sub end {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'end'} = $value;
    }
    return $self->{'end'};
}


=head2 strand
    
 Title    : strand
 Usage    : $obj->strand ($newval)
 Function : get/set method for attribute strand
 Returns  : Value of strand
 Args     : New value of nexons (optional)
    
=cut


sub strand {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'strand'} = $value;
    }
    return $self->{'strand'};
}


=head2 name
    
 Title    : name
 Usage    : $obj->name ($newval)
 Function : get/set method for attribute name
 Returns  : Value of name
 Args     : New value of name (optional)
    
=cut


sub name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'name'} = $value;
    }
    return $self->{'name'};
}

=head2 CoordSystem
    
 Title    : CoordSystem
 Usage    : $obj->CoordSystem ($newval)
 Function : get/set method for attribute CoordSystem
 Returns  : Value of CoordSystem
 Args     : New value of CoordSystem (optional)
    
=cut


sub CoordSystem {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'CoordSystem'} = $value;
    }
    return $self->{'CoordSystem'};
}

1;
