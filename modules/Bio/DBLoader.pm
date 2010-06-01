#! /usr/bin/perl -w

=head1 NAME
	
DBLoader

=head1 DESCRIPTION 

This module contains the methods to load the gene_mirna_name_db

=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut

package Bio::DBLoader;
use strict;
use Time::localtime;
use Data::Dumper;
use lib "/www/cogemir.tigem.it/htdocs/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v48/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v48/ensembl-compara/modules";

use Bio::SeqIO;
use Bio::EnsEMBL::Registry;
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::MirnaName;
use Bio::Cogemir::Attribute;
use Bio::Cogemir::Location;
use Bio::Cogemir::MicroRNA;
use Bio::Cogemir::Gene;
use Bio::Cogemir::Transcript;
use Bio::Cogemir::Exon;
use Bio::Cogemir::Intron;

use vars qw(@ISA); 
use Bio::Root::Root;
@ISA = qw(Bio::Root::Root );

$| =1;
##### STETTING VARIABLES #######

my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec;

#constructor

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($settings,  $dbh, $genoinfo) = $self->_rearrange([qw(SETTINGS DBH GENOINFO)], @args);
	use Bio::GenomicInformation;
  $genoinfo = Bio::GenomicInformation->new(-settings => $settings,
								                    -dbh =>$dbh);	
	$settings && $self->settings($settings);
	$dbh && $self->dbh($dbh);
	$genoinfo && $self->genoinfo($genoinfo);
	return $self;
}


#### public subroutine #####

sub genoinfo{
	my ($self, $genoinfo) = @_;
	if( defined $genoinfo) {
	$self->{'genoinfo'} = $genoinfo;
    }
    return $self->{'genoinfo'};

}


sub load_micro_rna{
	my ($self, $filling) = @_;
	
  return $filling; 
}


sub load_gene{
	my ($self,$filling) = @_;
	
	
	return $filling;
}	
	


#### internal subroutine #####
sub dbh{
	my ($self, $dbh) = @_;
	if( defined $dbh) {
	$self->{'dbh'} = $dbh;
    }
    return $self->{'dbh'};
}

sub settings{
	my ($self, $settings) = @_;
	if( defined $settings) {
	$self->{'settings'} = $settings;
    }
    return $self->{'settings'};
}

1;
