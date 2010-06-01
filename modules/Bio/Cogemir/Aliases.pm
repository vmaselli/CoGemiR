#
# MicroRNA Database: 
#
# Perl Module for Aliases.pm 
#
# Cared for by Vincenza Maselli
#
# Copyright  Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod

=head1 REFSEQDNA

Bio::Cogemir::Aliases

=head1 SYNOPSIS

	my $aliases = new Bio::Cogemir::Aliases (   
									  -RefSeq_dna           => 'mir-204',
                                      -ucsc       => $ucsc_obj,
                                      -GeneSymbol = > 2,
                                      -UniGene => 'partial',
                                      -RefSeq_dna_predicted =>'micro rna RefSeq_dna from miRBase'
                                    );
	my $RefSeq_dna = $aliases->RefSeq_dna;

=head1 REFSEQDNA_PREDICTED

 Object representing a aliasesuences, either nucleotide or peptide.
 inherits from Bio::PrimarySeq.

=head1 AUTOHOR

 Vincenza Maselli <maselli@tigem.it>

=cut


package Bio::Cogemir::Aliases;
use Bio::Cogemir::DBSQL::AliasesAdaptor;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::PrimarySeq

use Bio::PrimarySeq;
use Data::Dumper;
@ISA = qw(Bio::PrimarySeq);

#constructor

=head2 new

 Title          : new
 Usage          : my $aliases = new Bio::Cogemir::Aliases (   
									  -RefSeq_dna           => 'mir-204',
                                      -ucsc       => $ucsc_obj,
                                      -GeneSymbol = > 2,
                                      -UniGene => 'partial',
                                      -RefSeq_dna_predicted =>'micro rna RefSeq_dna from miRBase'
                                    );
 Returns        : Bio::Cogemir::Aliases
 Args           : Takes a set of RefSeq_dnad arguments
 Exceptions     : If the obj does not have RefSeq_dna
=cut

sub new {
    my ($class,@args) = @_;

    my $self = $class->SUPER::new(@args);
    my ($dbID,$adaptor,$RefSeq_dna, $GeneSymbol, $RefSeq_dna_predicted, $UniGene,$ucsc) = $self->_rearrange([qw(  
								  DBID
								  ADAPTOR
								  REFSEQDNA
								  GENESYMBOL
								  REFSEQDNA_PREDICTED
								  UNIGENE
								  UCSC
								  )],@args);

    $dbID && $self->dbID($dbID);
    $adaptor && $self->adaptor($adaptor);
    $RefSeq_dna && $self->RefSeq_dna($RefSeq_dna);
    $ucsc && $self->ucsc($ucsc);  
    $GeneSymbol && $self->GeneSymbol($GeneSymbol); 
    $RefSeq_dna_predicted && $self->RefSeq_dna_predicted($RefSeq_dna_predicted); 
    $UniGene && $self->UniGene($UniGene);
    
   
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
 Usage    : $obj->adaptor([Bio::Cogemir::DBSQL::AliasesAdaptor])
 Function : get/set method for attribute 
 Returns  : Bio::Cogemir::DBSQL::AliasesAdaptor 
 Args     : new value of Bio::Cogemir::DBSQL::AliasesAdaptor (optional)

=cut

sub adaptor{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'adaptor'} = $value;
    }
    return $self->{'adaptor'};
}

=head2 ucsc

 Title    : ucsc
 Usage    : $obj->ucsc([Bio::Cogemir::DBSQL::AliasesAdaptor])
 Function : get/set method for attribute 
 Returns  : Bio::Cogemir::DBSQL::AliasesAdaptor 
 Args     : new value of Bio::Cogemir::DBSQL::AliasesAdaptor (optional)

=cut

sub ucsc{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'ucsc'} = $value;
    }
    return $self->{'ucsc'};
}

=head2 RefSeq_dna

 Title    : RefSeq_dna
 Usage    : $obj->RefSeq_dna([$newval])
 Function : get/set method for attribute RefSeq_dna  
 Returns  : value of aliases RefSeq_dna (string)
 Args     : new value of RefSeq_dna (optional)

=cut

sub RefSeq_dna {
    my ($self,$RefSeq_dna)= @_;
    if (defined $RefSeq_dna) {
	$self->{'RefSeq_dna'} = $RefSeq_dna;
    }
    return $self->{'RefSeq_dna'};
}

=head2 RefSeq_dna_predicted

 Title    : RefSeq_dna_predicted
 Usage    : $obj->RefSeq_dna_predicted([$newval])
 Function : get/set method for attribute RefSeq_dna_predicted  
 Returns  : value of mirna_RefSeq_dna_predicted RefSeq_dna_predicted (string)
 Args     : new value of RefSeq_dna_predicted (optional)

=cut

sub RefSeq_dna_predicted {
    my ($self,$RefSeq_dna_predicted)= @_;
    if (defined $RefSeq_dna_predicted) {
	$self->{'RefSeq_dna_predicted'} = $RefSeq_dna_predicted;
    }
    return $self->{'RefSeq_dna_predicted'};
}

=head2 GeneSymbol

 Title    : GeneSymbol
 Usage    : $obj->GeneSymbol([$newval])
 Function : get/set method for attribute GeneSymbol  
 Returns  : value of mirna_GeneSymbol GeneSymbol (string)
 Args     : new value of GeneSymbol (optional)

=cut

sub GeneSymbol {
    my ($self,$GeneSymbol)= @_;
    if (defined $GeneSymbol) {
	$self->{'GeneSymbol'} = $GeneSymbol;
    }
    return $self->{'GeneSymbol'};
}

=head2 UniGene

 Title    : UniGene
 Usage    : $obj->UniGene([$newval])
 Function : get/set method for attribute UniGene  
 Returns  : value of mirna_UniGene UniGene (string)
 Args     : new value of UniGene (optional)

=cut

sub UniGene {
    my ($self,$UniGene)= @_;
    if (defined $UniGene) {
	$self->{'UniGene'} = $UniGene;
    }
    return $self->{'UniGene'};
}


1;