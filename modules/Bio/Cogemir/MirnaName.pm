#
# MicroRNA Database: 
#
# Perl Module for MirnaName.pm 
#
# Cared for by Vincenza Maselli
#
# Copyright  Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod

=head1 NAME

Bio::Cogemir::MirnaName

=head1 SYNOPSIS

	my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis_obj,
                                      -exon_conservation = > 2,
                                      -hostgene_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
	my $name = $mirna_name->name;

=head1 DESCRIPTION

 Object representing a mirna_nameuences, either nucleotide or peptide.
 inherits from Bio::PrimarySeq.

=head1 AUTOHOR

 Vincenza Maselli <maselli@tigem.it>

=cut


package Bio::Cogemir::MirnaName;
use Bio::Cogemir::DBSQL::MirnaNameAdaptor;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::PrimarySeq

use Bio::PrimarySeq;
use Data::Dumper;
@ISA = qw(Bio::PrimarySeq);

#constructor

=head2 new

 Title          : new
 Usage          : my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis_obj,
                                      -exon_conservation = > 2,
                                      -hostgene_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
 Returns        : Bio::Cogemir::MirnaName
 Args           : Takes a set of named arguments
 Exceptions     : If the obj does not have name
=cut

sub new {
    my ($class,@args) = @_;

    my $self = $class->SUPER::new(@args);
    my ($dbID,$adaptor,$name,$analysis, $exon_conservation, $description, $hostgene_conservation,$family_name,$mirnas) = $self->_rearrange([qw(  
								  DBID
								  ADAPTOR
								  NAME
								  ANALYSIS
								  EXON_CONSERVATION
								  DESCRIPTION
								  HOSTGENE_CONSERVATION
								  FAMILY_NAME
								  MIRNAS
								  )],@args);

    $dbID && $self->dbID($dbID);
    $adaptor && $self->adaptor($adaptor);
    $name && $self->name($name);
    $analysis && $self->analysis($analysis);  
    $exon_conservation && $self->exon_conservation($exon_conservation); 
    $description && $self->description($description); 
    $hostgene_conservation && $self->hostgene_conservation($hostgene_conservation);
    $mirnas && $self->mirnas($mirnas);
    $family_name && $self->family_name($family_name);
    
    #  we must have a name
    if (! ($self->name)) {
	$self->throw("The MirnaName does not have all attributes to be created. I need name");
    }
    return $self;
}


=head2 dbID

 Title    : dbID
 Usage    : $obj->dbID([$newval])
 Function : get/set method for attribute dbID 
 Returns  : value of dbID
 Args     : newval of dbID (optional)

=cut


sub dbID{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'dbID'} = $value;
    }
    return $self->{'dbID'};
}

=head2 adaptor

 Title    : adaptor
 Usage    : $obj->adaptor([Bio::Cogemir::DBSQL::MirnaNameAdaptor])
 Function : get/set method for attribute 
 Returns  : Bio::Cogemir::DBSQL::MirnaNameAdaptor 
 Args     : new value of Bio::Cogemir::DBSQL::MirnaNameAdaptor (optional)

=cut

sub adaptor{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 analysis

 Title    : analysis
 Usage    : $obj->analysis([Bio::Cogemir::DBSQL::MirnaNameAdaptor])
 Function : get/set method for attribute 
 Returns  : Bio::Cogemir::DBSQL::MirnaNameAdaptor 
 Args     : new value of Bio::Cogemir::DBSQL::MirnaNameAdaptor (optional)

=cut

sub analysis{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'analysis'} = $value;
    }
    return $self->{'analysis'};
}

=head2 name

 Title    : name
 Usage    : $obj->name([$newval])
 Function : get/set method for attribute name  
 Returns  : value of mirna_name name (string)
 Args     : new value of name (optional)

=cut

sub name {
    my ($self,$name)= @_;
    if (defined $name) {
	$self->{'name'} = $name;
    }
    return $self->{'name'};
}

=head2 family_name

 Title    : family_name
 Usage    : $obj->family_name([$newval])
 Function : get/set method for attribute family_name  
 Returns  : value of mirna_family_name family_name (string)
 Args     : new value of family_name (optional)

=cut

sub family_name {
    my ($self,$family_name)= @_;
    if (defined $family_name) {
	$self->{'family_name'} = $family_name;
    }
    return $self->{'family_name'};
}

=head2 description

 Title    : description
 Usage    : $obj->description([$newval])
 Function : get/set method for attribute description  
 Returns  : value of mirna_description description (string)
 Args     : new value of description (optional)

=cut

sub description {
    my ($self,$description)= @_;
    if (defined $description) {
	$self->{'description'} = $description;
    }
    return $self->{'description'};
}

=head2 exon_conservation

 Title    : exon_conservation
 Usage    : $obj->exon_conservation([$newval])
 Function : get/set method for attribute exon_conservation  
 Returns  : value of mirna_exon_conservation exon_conservation (string)
 Args     : new value of exon_conservation (optional)

=cut

sub exon_conservation {
    my ($self,$exon_conservation)= @_;
    if (defined $exon_conservation) {
	$self->{'exon_conservation'} = $exon_conservation;
    }
    return $self->{'exon_conservation'};
}

=head2 hostgene_conservation

 Title    : hostgene_conservation
 Usage    : $obj->hostgene_conservation([$newval])
 Function : get/set method for attribute hostgene_conservation  
 Returns  : value of mirna_hostgene_conservation hostgene_conservation (string)
 Args     : new value of hostgene_conservation (optional)

=cut

sub hostgene_conservation {
    my ($self,$hostgene_conservation)= @_;
    if (defined $hostgene_conservation) {
	$self->{'hostgene_conservation'} = $hostgene_conservation;
    }
    return $self->{'hostgene_conservation'};
}

=head2 mirnas

 Title    : mirnas
 Usage    : $obj->mirnas([$newval])
 Function : get/set method for attribute mirnas  
 Returns  : value of mirna_mirnas mirnas (string)
 Args     : new value of mirnas (optional)

=cut

sub mirnas {
    my ($self,$mirnas)= @_;
    if (defined $mirnas) {
	$self->{'mirnas'} = $mirnas;
    }
    else{
    $self->{'mirnas'} =  $self->adaptor->get_all_Mirnas($self->dbID);}
    return $self->{'mirnas'};
}

=head2 hostgenes

 Title    : hostgenes
 Usage    : $obj->hostgenes([$newval])
 Function : get/set method for attribute hostgenes  
 Returns  : value of mirna_hostgenes hostgenes (string)
 Args     : new value of hostgenes (optional)

=cut

sub hostgenes {
    my ($self,$hostgenes)= @_;
    if (defined $hostgenes) {
	$self->{'hostgenes'} = $hostgenes;
    }
    else{
    $self->{'hostgenes'} =  $self->adaptor->get_all_Hostgenes($self->dbID);}
    return $self->{'hostgenes'};
}


=head2 organism

 Title    : organism
 Usage    : $obj->organism([$newval])
 Function : get/set method for attribute organism  
 Returns  : value of mirna_organism organism (string)
 Args     : new value of organism (optional)

=cut

sub organism {
    my ($self,$organism)= @_;
    if (defined $organism) {
	$self->{'organism'} = $organism;
    }
    else{
    $self->{'organism'} =  $self->adaptor->get_all_organism($self->dbID);}
    return $self->{'organism'};
}

sub feature {
  my ($self,$value) = @_;
  
  if ($value){
    my $feat = $self->adaptor->db->get_FeatureAdaptor->fetch_by_mirna_name_id_name($self->dbID,$value);
    $self->{'feature'} = $feat;
  }
  else{
    my $feats = $self->adaptor->db->get_FeatureAdaptor->fetch_by_mirna_name_id($self->dbID);
    $self->{'feature'} = $feats;
  }
  return $self->{'feature'};
}  

1;
