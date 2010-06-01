#
# Module for Bio::Cogemir::Analysis
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::Analysis -  Stores details of an analysis run

=head1 SYNOPSIS

	my $analysis =  Bio::Cogemir::Analysis->new(       
							    -CREATED => $created,
							    -LOGIC_NAME =>$logic_name_obj
							    -PARAMETERS =>$parameters	    
							   );

=head1 DESCRIPTION

	Object to store details of an analysis run

=head1 AUTHORS - 
	
	Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Analysis;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);


#constructor

=head2 new
    
 Title      : new
 Usage      : my $analysis =  Bio::Cogemir::Analysis->new(       
							    -CREATED => $created,
							    -LOGIC_NAME =>$logic_name_obj,
							    -PARAMETERS =>$parameters	    
							   );
 Function   : Creates a new Analysis object
 Returns    : Bio::Cogemir:Analysis
 Args       : Takes a set of named arguments
 Exceptions : If the obj does not have logic name and parameters
    
=cut

sub new {
    my($class,@args) = @_;
    my $self = $class->SUPER::new(@args);# not sure what this does but seems necessary for the _rearrange!!!
    my (
		$dbID,
		$adaptor,
    $created,
    $parameters,
    $logic_name_obj,
    
     ) = $self->_rearrange([qw( 
         DBID
         ADAPTOR
         CREATED
         PARAMETERS
         LOGIC_NAME
          )],@args);
    
    
    $dbID && $self->dbID($dbID);
    $adaptor && $self->adaptor($adaptor);
    $created && $self->created($created);
    $logic_name_obj && $self->logic_name($logic_name_obj);
    $parameters && $self->parameters($parameters);
    
    # we must have a logic_name_obj, date of creation and parameters
    if (! ($self->parameters)) {$self->throw("The Analysis does not have all attributes to be created: I need # PARAMETERS # ");}
    if (!($self->created)) {$self->throw("The Analysis does not have all attributes to be created: I need # DATE OF CREATION # ");}

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
	Usage    	: $obj->adaptor ([Bio::Cogemir::DBSQL::AnalysisAdaptor])
	Function 	: Get/Set  method for attribute adaptor object
	Returns  	: Bio::Cogemir::DBSQL::AnalysisAdaptor
	Args     	: New value of AnalysisAdaptor obj (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 created
    
    Title       : created
    Usage       : $obj->created ($created)
    Function    : get/set method for attribute created time
    Returns     : string
    Args        : New value of created (optional)

=cut

    
sub created {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'created'} = $value;
    }
    return $self->{'created'};
}



=head2 logic_name
    
    Title       : logic_name
    Usage       : $obj->logic_name ([$newval])
    Function    : Get/set method for the logic_name, the name under 
                  which this typical analysis is known
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




=head2 parameters

 	Title    	: parameters
	Usage    	: $obj->parameters ([$newval])
	Function 	: get/set method for attribute parameters. This should be evaluated
				  by the module if given or the program that is specified.
	Returns  	: string
	Args     	: New value of parameters (optional)

=cut

sub parameters {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'parameters'} = $value;
    }
    return $self->{'parameters'};
}


1;
