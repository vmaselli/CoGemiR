 #! /usr/bin/perl -w

use strict;
use Data::Dumper;
use Getopt::Long;
use File::Spec;
my $debug = 0;
use Time::localtime;

use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Location;
use Bio::SeqIO;

$| = 1;	

# SETTINGS 
BEGIN{ require("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n";}#settings


my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);

my $file_dir = "$ENV{'HOME'}/Projects/mirna/data/mirbase/";

my $mirnatxt = File::Spec->catfile($file_dir,"mirna.txt");
my $mirna_pre_maturetxt = File::Spec->catfile($file_dir,"mirna_pre_mature.txt");
my $mirna_maturetxt = File::Spec->catfile($file_dir,"mirna_mature.txt");
open (MIR, $mirnatxt) || die $!;
open (MPM, $mirna_pre_maturetxt) || die $!;
open (MIM, $mirna_maturetxt) || die $!;

my %mirna;
my %mature;
my %pre_mat;

# get correspondence between mature e pre from mirna_pre_mature file
# mirna internal id mature internal id
while (my $corr_row = <MPM>){
  chomp $corr_row;
  my ($pre_id,$mat_id) = split /\t{1,10}/,$corr_row;
  $pre_mat{$pre_id} = $mat_id;
}

# get mature name  and mature range from mirna_mature.txt 
# internal id name acc  start end evidence exp similarity
while (my $tmp_row = <MIM>){
  chomp $tmp_row;
  my ($mat_id) = split /\t{1,10}/,$tmp_row;
  $mature{$mat_id} = $tmp_row;
}

while (my $mir_row = <MIR>){
  chomp $mir_row;
  my @mirs = split /\t{1,10}/,$mir_row;
  my $mir_acc = $mirs[1];
  #print "line 63 $mir_acc \n";
  $mirna{$mir_acc} = $mir_row;
	
}

foreach my $micro_rna (@{$dbh->get_MicroRNAAdaptor->fetch_by_status("PUTATIVE")}){
	next if $micro_rna->attribute->seq;
	my $accession = $micro_rna->attribute->db_accession;
	print "line 70 $accession ".$micro_rna->attribute->genome_db->organism."\n";
	my $row = $mirna{$accession};
	print "line 72 $row";
  my @mirs = split /\t{1,10}/,$row;    
  my $mir_id = $mirs[0];
  my $sequence = $mirs[4];     
  print "line 75 $mir_id $sequence\n";
	my $mat_id = $pre_mat{$mir_id};
  my $mat_row = $mature{$mat_id};
  my @mats = split /\t{1,10}/,$mat_row;
  my $mature_name = $mats[1];
  my $from = $mats[3];
  my $to = $mats[4];
  my $offset = $to - $from;
  my $mature_acc = $mats[2];
  my $mature_sequence = substr($sequence,$from,$offset);
	my $mature_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "mature microRNA sequence"
                   );
  
  my $mature_seq = Bio::Cogemir::Seq->new(
          -name => $mature_name,
          -sequence => $mature_sequence,
          -logic_name =>$mature_logic_name
          );
  my $mature_id = $dbh->get_SeqAdaptor->store($mature_seq);
  $micro_rna->mature_seq($mature_seq);
  $dbh->get_MicroRNAAdaptor->update($micro_rna);
  print "DONE MATURE $mature_id\n";      
  my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "pre-miRNA"
                   );
  my $mirna_seq = Bio::Cogemir::Seq->new(
          -name => $micro_rna->gene_name,
          -sequence => $sequence,
          -logic_name =>$seq_logic_name
          );
  my $seq_id = $dbh->get_SeqAdaptor->store($mirna_seq); 
  $micro_rna->attribute->seq($mirna_seq);
  $dbh->get_AttributeAdaptor->update($micro_rna->attribute);
  print "DONE SEQ $seq_id\n";
}




   
