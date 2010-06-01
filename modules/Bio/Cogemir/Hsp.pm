# Module for Bio::Cogemir::Hsp
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 PERCENT_IDENTITY

Bio::GeneHspDB::Hsp

=head1 SYNOPSIS
	
	my $hsp =  Bio::Cogemir::Hsp->new(  
	               -DBID                             => $dbID,
	                -ADAPTOR                       => $adaptor,
							    -HIT                        => $hit, 
							    -PERCENT_IDENTITY                            => $percent_identity, 
							    -LENGTH                => $length,
							    -P_VALUE                      => 1e-4,
							    -FRAME                            => $frame,
							    -SEQ                             => $seq, 
							    -START => 300,
							    -END          => 500
							    );

       $percent_identity = $hsp->percent_identity();

=head1 LENGTH

    This adaptor work with the hsp table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Hsp;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $hsp =  Bio::Cogemir::Hsp->new(   
							    -HIT => $hit, 
							    -PERCENT_IDENTITY => $percent_identity, 
							    -LENGTH => $length,
							    -P_VALUE => 1e-4,
							    -FRAME => $frame,
							    -SEQ => $seq, 
							    -START => 300,
							    -END => 500
							     );

 Returns        : Bio::Cogemir::Hsp
 Args           : Takes a set of percent_identityd arguments
 Exceptions     : If the obj does not have query obj, percent_identity obj, seq and 

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
          $adaptor,
          $hit, 
          $percent_identity, 
          $length,
          $p_value,
          $frame,
          $seq, 
          $start,
          $end
          ) = $self->_rearrange([qw(
        DBID                          
        ADAPTOR                    
        HIT                      
        PERCENT_IDENTITY                          
        LENGTH              
        P_VALUE                    
        FRAME                          
        SEQ                           
        START
        END        
		)], @args);
	
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$hit && $self->hit($hit);
	$percent_identity && $self->percent_identity($percent_identity);
	$seq && $self->seq($seq);
	$length && $self->length($length);
    $self->p_value($p_value) if defined $p_value;
    $frame && $self->frame($frame);
    $self->start($start) if defined $start;
    $self->end($end) if defined $end;
          
	if(!$self->hit ){
		$self->throw("The Hsp does not have all attributes to be created I need hit ");
	}
	elsif(! $self->percent_identity ){
		$self->throw("The Hsp does not have all attributes to be created I need percent_identity ");
	}
    elsif(! $self->length ){
		$self->throw("The Hsp does not have all attributes to be created I need length ");
	}
	#elsif(! $self->p_value ){
	#	$self->throw("The Hsp does not have all attributes to be created I need p_value ");
	#}
	elsif(! $self->seq ){
		$self->throw("The Hsp does not have all attributes to be created I need seq ");
	}
	elsif(! $self->start ){
		$self->throw("The Hsp does not have all attributes to be created I need start ");
	}
	elsif(! $self->end){
		$self->throw("The Hsp does not have all attributes to be created I need end ");
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
 Usage    : $obj->adaptor ([Bio::MIRNABD::HspAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::HspAdaptor
 Args     : New value of Bio::MIRNABD::HspAdaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 percent_identity
    
 Title    : percent_identity
 Usage    : $obj->percent_identity ()
 Function : get/set method for attribute percent_identity
 Returns  : Value of percent_identity
 Args     : string
    
=cut


sub percent_identity {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'percent_identity'} = $value;
    }
    return $self->{'percent_identity'};
}

=head2 hit
    
 Title    : hit
 Usage    : $obj->hit (Bio::MIRNABD::Hit)
 Function : get/set method for attribute hit
 Returns  : Value of Bio::MIRNABD::Hit
 Args     : New value of Bio::MIRNABD::Hit 
    
=cut


sub hit {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'hit'} = $value;
    }
    return $self->{'hit'};
}

=head2 length
    
 Title    : length
 Usage    : $obj->length (25)
 Function : get/set method for attribute length
 Returns  : string
 Args     : string
    
=cut


sub length {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'length'} = $value;
    }
    return $self->{'length'};
}

=head2 seq
    
 Title    : seq
 Usage    : $obj->seq ('TTAGGCGGTA')
 Function : get/set method for attribute seq
 Returns  : string
 Args     : string
    
=cut


sub seq {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'seq'} = $value;
    }
    return $self->{'seq'};
}

=head2 p_value
    
 Title    : p_value
 Usage    : $obj->p_value (1e-4)
 Function : get/set method for attribute p_value
 Returns  : 1 or 0
 Args     : 1 or 0
    
=cut


sub p_value {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'p_value'} = $value;
    }
    return $self->{'p_value'};
}

=head2 frame
    
 Title    : frame
 Usage    : $obj->frame (0)
 Function : get/set method for attribute frame
 Returns  : string
 Args     : string
    
=cut


sub frame {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'frame'} = $value;
    }
    return $self->{'frame'};
}

=head2 start
    
 Title    : start
 Usage    : $obj->start (300)
 Function : get/set method for attribute start
 Returns  : int
 Args     : int
    
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
 Usage    : $obj->end (500)
 Function : get/set method for attribute end
 Returns  : string
 Args     : string
    
=cut


sub end {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'end'} = $value;
    }
    return $self->{'end'};
}

1;
