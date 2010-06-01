 #! /usr/bin/perl -w

use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Tissue;
use File::Spec;
do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);

########### QUERY ##########
unless (scalar @ARGV){die "USAGE: script name <inputfile> <tag> <species> <dir>"}
my $file = shift @ARGV;
my $tag = shift @ARGV;
my $species = shift @ARGV;
my $dir = shift @ARGV;
my $data_file = $file || die "$! $file";


my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
open (DATA, "$data_file") || die;
my @tissues;
my (@rows) = <DATA>;
my $row = shift @rows;
chomp $row;
@tissues = split /\t/, $row;
shift @tissues;
my %seen;
foreach my $tissue_name(@tissues){
	#print "TISSUE $tissue_name\n";
  my @tn;
  if ($tag eq 'ap'){
    next if $tissue_name eq 'Descriptions';
    next if $tissue_name =~ s/_Detection//; 
    $tissue_name =~ s/_Signal//;
    print "TISSUE $tissue_name\n";
    if ($file =~ /human/){
      my @t = split /_/, $tissue_name;
      shift @t;
      $tissue_name = join ("_",@t);
    }
    if ($file =~ /mouse/){
      my $sub_tissue = substr($tissue_name,14);
      unless ($sub_tissue){$sub_tissue = substr($tissue_name,13);}
      $tissue_name = $sub_tissue;
    }
    
  }
  $tissue_name =~ s/\s{1,30}//;
  if ($tissue_name eq "WHOLEBLOOD(JJV)"){ $tissue_name = "wholeblood";}
 	
 	next if $seen{$tissue_name};
  for (my $i=0; $i<length $tissue_name; $i++){push (@tn, substr($tissue_name,$i,(1)))}
  my $string = join("%",@tn);
  next if defined $dbh->get_TissueAdaptor->fetch_by_name_like($string."%");
  print "TISSUE $tissue_name\n";
  $seen{$tissue_name} ++;
  my $tissue =  Bio::Cogemir::Tissue->new(
    -NAME =>lc($tissue_name),
    -GENOME_DB =>$genome_db);
  $dbh->get_TissueAdaptor->store($tissue);
}
