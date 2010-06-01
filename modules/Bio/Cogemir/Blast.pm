#
# Module for Bio::Cogemir::Blast
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Blast -  Stores details of an blast run

=head1 SYNOPSIS

	my $blast =  Bio::Cogemir::Blast->new(       
							    -FEATURE => $feature,
							    -LOGIC_NAME =>$logic_name_obj
							    -LENGTH =>$length	    
							   );

=head1 DESCRIPTION

	Object to store details of an blast run

=head1 AUTHORS - 
	
	Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Blast;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);


#constructor

=head2 new
    
 Title      : new
 Usage      : my $blast =  Bio::Cogemir::Blast->new(       
							    -FEATURE => $feature,
							    -LOGIC_NAME =>$logic_name_obj,
							    -LENGTH =>$length	    
							   );
 Function   : Creates a new Blast object
 Returns    : Bio::Cogemir:Blast
 Args       : Takes a set of named arguments
 Exceptions : If the obj does not have logic name and length
    
=cut

sub new {
    my($class,@args) = @_;
    my $self = $class->SUPER::new(@args);# not sure what this does but seems necessary for the _rearrange!!!
    my (
		$dbID,
		$adaptor,
        $feature,
        $length,
        $logic_name_obj,
        
         ) = $self->_rearrange([qw( 
					   DBID
					   ADAPTOR
					   FEATURE
					   LENGTH
					   LOGIC_NAME
					    )],@args);
    
    
    $dbID && $self->dbID($dbID);
    $adaptor && $self->adaptor($adaptor);
    $feature && $self->feature($feature);
    $logic_name_obj && $self->logic_name($logic_name_obj);
    $length && $self->length($length);
    
    # we must have a logic_name_obj, date of creation and length
    if (! ($self->length)) {$self->throw("The Blast does not have all attributes to be feature_id: I need # LENGTH # ");}
    if (!($self->feature)) {$self->throw("The Blast does not have all attributes to be feature_id: I need # FEATURE # ");}

    return $self;
}

    
=head2 dbID
    
 	Title    	: dbID
	Usage    	: $obj->dbID ([$newval])
 	Function 	: get/set method for attribute dbID (intrernal database ID)
 	Returns  	: value of dbID (integer)
 	Args     	: New value of dbID (optional)
    
=cut


sub dbID {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'};
}

=head2 adaptor
    	
	Title    	: adaptor
	Usage    	: $obj->adaptor ([Bio::Cogemir::DBSQL::BlastAdaptor])
	Function 	: Get/Set  method for attribute adaptor object
	Returns  	: Bio::Cogemir::DBSQL::BlastAdaptor
	Args     	: New value of BlastAdaptor obj (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 feature
    
    Title       : feature
    Usage       : $obj->feature ($feature)
    Function    : get/set method for attribute feature_id time
    Returns     : string
    Args        : New value of feature (optional)

=cut

    
sub feature {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'feature'} = $value;
    }
    return $self->{'feature'};
}



=head2 logic_name
    
    Title       : logic_name
    Usage       : $obj->logic_name ([$newval])
    Function    : Get/set method for the logic_name, the name under 
                  which this typical blast is known
    Returns     : string
    Args        : New value of logic_name (optional)
 
=cut
    
sub logic_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'logic_name'} = $value;
    }
    return $self->{'logic_name'};
}




=head2 length

 	Title    	: length
	Usage    	: $obj->length ([$newval])
	Function 	: get/set method for attribute length. This should be evaluated
				  by the module if given or the program that is specified.
	Returns  	: string
	Args     	: New value of length (optional)

=cut

sub length {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'length'} = $value;
    }
    return $self->{'length'};
}


1;
