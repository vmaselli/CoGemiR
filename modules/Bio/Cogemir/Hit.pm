#
# Module for Bio::Cogemir::Hit
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 BLAST

Bio::GeneHitDB::Hit

=head1 SYNOPSIS

	  
    my ($hit) =  Bio::Cogemir::Hit->new(   
							    -BLAST => $blast,
							    -FEATURE =>$feature_obj
							   );

    $blast = $hit->blast();

=head1 DESCRIPTION

    This adaptor work with the hit table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Hit;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my ($hit) =  Bio::Cogemir::Hit->new(   
							    -BLAST => $blast,
							    -FEATURE =>$feature_obj
							   );
 Returns        : Bio::Cogemir::Hit
 Args           : Takes a set of blastd arguments
 Exceptions     : If the obj does not have blast

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$blast,
		$feature_obj
		) = $self->_rearrange([qw(
		DBID
		ADAPTOR
		BLAST
		FEATURE
		)], @args);

	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$blast && $self->blast($blast);
    $feature_obj && $self->feature($feature_obj);
    
	# we must have a blast and feature
    if (! ($self->blast) ) {
	$self->throw("The Hit does not have all attributes to be created: I need a blast");
    }
    if (! ($self->feature) ) {
	$self->throw("The Hit does not have all attributes to be created: I need a feature");
    }
    
	return $self;
	
}

=head2 dbID
    
 Title    : dbID
 Usage    : $obj->dbID ($newval)
 Hit : get/set method for attribute dbID
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
 Hit : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::HitAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 blast
    
 Title    : blast
 Usage    : $obj->blast ($newval)
 Hit : get/set method for attribute blast
 Returns  : Value of blast (string)
 Args     : New value of blast (optional)
    
=cut


sub blast {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'blast'} = $value;
    }
    return $self->{'blast'};
}

=head2 feature
    
 Title    : feature
 Usage    : $obj->feature ($newval)
 Hit : get/set method for attribute feature
 Returns  : Value of feature (string)
 Args     : New value of feature (optional)
    
=cut


sub feature {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'feature'} = $value;
    }
    return $self->{'feature'};
}
1;
