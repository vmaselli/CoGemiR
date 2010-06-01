#
# Module for Bio::Cogemir::Expression
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 EXPRESSION_LEVEL

Bio::GeneExpressionDB::Expression

=head1 SYNOPSIS

	  
    my ($expression) =  Bio::Cogemir::Expression->new( 
                                -EXTERNAL => $external,
							    -EXPRESSION_LEVEL => $expression_level,
							    -TISSUE =>$tissue_obj
							   );

    $expression_level = $expression->expression_level();

=head1 DESCRIPTION

    This adaptor work with the expression table 

=head1 AUTHORS - 

Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Expression;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my ($expression) =  Bio::Cogemir::Expression->new( 
                                -EXTERNAL =>$external;
							    -EXPRESSION_LEVEL => $expression_level,
							    -TISSUE =>$tissue_obj
							   );
 Returns        : Bio::Cogemir::Expression
 Args           : Takes a set of expression_leveld arguments
 Exceptions     : If the obj does not have expression_level

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($external,
		$adaptor,
		$expression_level,
		$tissue_obj,
		$platform
		) = $self->_rearrange([qw(
		EXTERNAL
		ADAPTOR
		EXPRESSION_LEVEL
		TISSUE
		PLATFORM
		)], @args);

	$external && $self->external($external);
	$adaptor && $self->adaptor($adaptor);
	$self->expression_level($expression_level) if defined $expression_level;
    $tissue_obj && $self->tissue($tissue_obj);
  $platform && $self->platform($platform);
    
	# we must have a expression_level 
    if (! defined ($self->expression_level) ) {
	$self->throw("The Expression does not have all attributes to be created: I need a expression_level");
    }
    	# we must have a external 
    if (! ($self->external) ) {
	$self->throw("The Expression does not have all attributes to be created: I need a external");
    }
  
    # if (! ($self->platform) ) {
# 	$self->throw("The Expression does not have all attributes to be created: I need a platform");
#     }
    if (! ($self->tissue) ) {
	$self->throw("The Expression does not have all attributes to be created: I need a tissue");
    }

	return $self;
	
}


sub symatlas_annotation{
  my ($self,$value) = @_;
    if (defined $value) {
      $self->external($value);
    }  
  return $self->external;

}

=head2 external
    
 Title    : external
 Usage    : $obj->external ($newval)
 Expression : get/set method for attribute external
 Returns  : Value of external
 Args     : New value of external (optional)
    
=cut


sub external {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'external'} = $value;
    }
    return $self->{'external'};
}

=head2 adaptor
    
 Title    : adaptor
 Usage    : $obj->adaptor ($newval)
 Expression : get/set method for attribute adaptor
 Returns  : Bio::Cogemir::ExpressionAdaptor
 Args     : New value of adaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 expression_level
    
 Title    : expression_level
 Usage    : $obj->expression_level ($newval)
 Expression : get/set method for attribute expression_level
 Returns  : Value of expression_level (string)
 Args     : New value of expression_level (optional)
    
=cut


sub expression_level {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'expression_level'} = $value;
    }
    return $self->{'expression_level'};
}

=head2 tissue
    
 Title    : tissue
 Usage    : $obj->tissue ($newval)
 Expression : get/set method for attribute tissue
 Returns  : Value of tissue (string)
 Args     : New value of tissue (optional)
    
=cut


sub tissue {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'tissue'} = $value;
    }
    return $self->{'tissue'};
}

=head2 platform
    
 Title    : platform
 Usage    : $obj->platform ($newval)
 Expression : get/set method for attribute platform
 Returns  : Value of platform (string)
 Args     : New value of platform (optional)
    
=cut


sub platform {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'platform'} = $value;
    }
    return $self->{'platform'};
}

1;
