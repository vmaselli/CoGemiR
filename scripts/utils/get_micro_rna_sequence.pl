#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use vars;

use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl/modules";
use lib "$ENV{'HOME'}/src/bioperl-live";
use Bio::SeqIO;
use Bio::Seq;
use Bio::Cogemir::DBSQL::DBAdaptor;

do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings
my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-pass => $::settings{'pass'},
								-dbname => $::settings{'dbname'},
								-verbose => 1,
								-quick => 1
								);

my $db = "MicroRNASequenceDB.fa";
my $dball = Bio::SeqIO->new(-file => ">>$db" , '-format' => 'Fasta');
foreach my $microrna (@{$dbh->get_MicroRNAAdaptor->get_All}){
	my $species = $microrna->organism;
	$species =~ s/ /_/;
	my $seq = $microrna->attribute->seq->sequence;
	my $name = $microrna->gene_name;
	my $file = $species.".fa";
  my $out = Bio::SeqIO->new(-file => ">>$file" , '-format' => 'Fasta');
  my $seq_obj = Bio::Seq->new( -display_id => $name,
                       -seq => $seq);
  $out->write_seq($seq_obj);
	$dball->write_seq($seq_obj);
}

