# Module for Bio::Cogemir::Feature
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 LOGIC_NAME

Bio::GeneFeatureDB::Feature

=head1 SYNOPSIS
	ATE TABLE `feature` (
feature_id` int(10) unsigned N
logic_logic_name_id` int(10) NOT NUL
description` varchar(255) defa
note` mediumtext,
distance_from_upstream_gene` i
closest_upstream` varchar(40) 
distance_from_downstream_gene`
closest_downstream` varchar(40
analysis_id` int(10) default N

	my $feature =  Bio::Cogemir::Feature->new(  
	                -DBID                             => $dbID,
	                -ADAPTOR                       => $adaptor,
							    -LOGIC_NAME                            => $logic_name, 
							    -DESCRIPTION                => $description,
							    -NOTE                            => $note,
							    -DISTANCE_FROM_UPSTREAMGENE => 0,
							    -COLOSEST_UPSTREAMGENE         => 'ENSG0000012345'
							    -DISTANCE_FROM_DOWNSTREAMGENE => 0,
							    -COLOSEST_DOWNSTREAMGENE         => 'ENSG0000012345'
							    -ANALYSIS                      => $analysis_obj						                                                   
							    );

       $logic_name = $feature->logic_name();

=head1 DESCRIPTION

    This adaptor work with the feature table 

=head1 AUTHORS - 

 Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::Feature;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;

use Data::Dumper;

@ISA = qw(Bio::Root::Root);

#constructor
=head2 new

 Title          : new
 Usage          : my $feature =  Bio::Cogemir::Feature->new(   
							    -MEMBER => $member, 
							    -LOGIC_NAME => $logic_name, 
							    -DESCRIPTION => $description,
							    -NOTE => $note,
							    -DISTANCE_FROM_UPSTREAMGENE => 0,
							    -COLOSEST_UPSTREAMGENE=> 'ENSG0000012345'
							    -DISTANCE_FROM_DOWNSTREAMGENE => 0,
							    -COLOSEST_DOWNSTREAMGENE         => 'ENSG0000012345'
							    -ANALYSIS => $analysis_obj 						                                                   );

 Returns        : Bio::Cogemir::Feature
 Args           : Takes a set of logic_named arguments
 Exceptions     : If the obj does not have query obj, logic_name obj, type and analysis

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
          $adaptor,
          $logic_name, 
          $description,
          $note,
          $dist_from_upgene,
          $closest_upgene,
          $dist_from_downgene,
          $closest_downgene,
          $analysis_obj	

		) = $self->_rearrange([qw(
        DBID                          
        ADAPTOR                    
        LOGIC_NAME                          
        DESCRIPTION              
        NOTE                          
        DISTANCE_FROM_UPSTREAMGENE
        CLOSEST_UPSTREAMGENE 
        DISTANCE_FROM_DOWNSTREAMGENE
        CLOSEST_DOWNSTREAMGENE 
        ANALYSIS                    
		)], @args);
	$dbID && $self->dbID($dbID);
	$adaptor && $self->adaptor($adaptor);
	$logic_name && $self->logic_name($logic_name);
	$analysis_obj && $self->analysis($analysis_obj);
	$description && $self->description($description);
  $note && $self->note($note);
  $self->distance_from_upstream_gene($dist_from_upgene) if defined $dist_from_upgene;
  $closest_upgene && $self->closest_upstream_gene($closest_upgene);
  $self->distance_from_downstream_gene($dist_from_downgene) if defined $dist_from_downgene;
  $closest_downgene && $self->closest_downstream_gene($closest_downgene);        
	
	if(! $self->logic_name ){
		$self->throw("The Feature does not have all attributes to be created I need logic_name ");
	}
	elsif(! $self->description ){
		$self->throw("The Feature does not have all attributes to be created I need description ");
	}
	# elsif(! $self->closest_upstream_gene ){
# 		$self->throw("The Feature does not have all attributes to be created I need closest_upstream_gene ");
# 	}
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
 Usage    : $obj->adaptor ([Bio::MIRNABD::FeatureAdaptor])
 Function : get/set method for attribute adaptor
 Returns  : Value of Bio::MIRNABD::FeatureAdaptor
 Args     : New value of Bio::MIRNABD::FeatureAdaptor (optional)
    
=cut


sub adaptor {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 logic_name
    
 Title    : logic_name
 Usage    : $obj->logic_name ()
 Function : get/set method for attribute logic_name
 Returns  : Value of logic_name
 Args     : string
    
=cut


sub logic_name {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'logic_name'} = $value;
    }
    return $self->{'logic_name'};
}



=head2 description
    
 Title    : description
 Usage    : $obj->description ('bla bla bla')
 Function : get/set method for attribute description
 Returns  : string
 Args     : string
    
=cut


sub description {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'description'} = $value;
    }
    return $self->{'description'};
}



=head2 note
    
 Title    : note
 Usage    : $obj->note ('personal note')
 Function : get/set method for attribute note
 Returns  : string
 Args     : string
    
=cut


sub note {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'note'} = $value;
    }
    return $self->{'note'};
}

=head2 distance_from_upstream_gene
    
 Title    : distance_from_upstream_gene
 Usage    : $obj->distance_from_upstream_gene (300)
 Function : get/set method for attribute distance_from_upstream_gene
 Returns  : int
 Args     : int
    
=cut


sub distance_from_upstream_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'distance_from_upstream_gene'} = $value;
    }
    return $self->{'distance_from_upstream_gene'};
}

=head2 distance_from_upstream_gene
    
 Title    : distance_from_upstream_gene
 Usage    : $obj->distance_from_upstream_gene (300)
 Function : get/set method for attribute distance_from_upstream_gene
 Returns  : int
 Args     : int
    
=cut


sub distance_from_downstream_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'distance_from_downstream_gene'} = $value;
    }
    return $self->{'distance_from_downstream_gene'};
}

=head2 closest_upstream_gene
    
 Title    : closest_upstream_gene
 Usage    : $obj->closest_upstream_gene ('ENSG0000123456')
 Function : get/set method for attribute closest_upstream_gene
 Returns  : string
 Args     : string
    
=cut


sub closest_upstream_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'closest_upstream_gene'} = $value;
    }
    return $self->{'closest_upstream_gene'};
}

=head2 closest_downstream_gene
    
 Title    : closest_upstream_gene
 Usage    : $obj->closest_upstream_gene ('ENSG0000123456')
 Function : get/set method for attribute closest_upstream_gene
 Returns  : string
 Args     : string
    
=cut


sub closest_downstream_gene {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'closest_downstream_gene'} = $value;
    }
    return $self->{'closest_downstream_gene'};
}

=head2 analysis
    
 Title    : analysis
 Usage    : $obj->analysis (Bio::MIRNABD::Analysis)
 Function : get/set method for attribute analysis
 Returns  : Value of Bio::MIRNABD::Analysis
 Args     : New value of Bio::MIRNABD::Analysis 
    
=cut


sub analysis {
    my ($self,$value) = @_;
    if (defined $value) {
	$self->{'analysis'} = $value;
    }
    return $self->{'analysis'};
}
1;
