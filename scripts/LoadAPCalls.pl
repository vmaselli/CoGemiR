# !/usr/bin/perl -w

use vars;
use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Tissue;
use File::Spec;
do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);


unless (scalar @ARGV){die "USAGE: script name <inputfile> <tag> <species> <dir>"}

my $file = shift @ARGV;
my $t = shift @ARGV;
my $species = shift @ARGV;
my $dir = shift @ARGV;
my $data_file = File::Spec->catfile("$ENV{'HOME'}/Projects/mirna/data/symatlas/expression_data/$dir",$file) || die $!;

my $sql = qq{INSERT INTO ap_tissue SET tissue_id = ?, symatlas_annotation_id = ?, tag = ?};
my $sth = $dbh->prepare($sql);

my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
open (FH,$data_file) || die $!;

my $tag = 1;
my %mat;
my $count = 0;
my %calc_ubiq;
my @tissues;
while (my $row = <FH>){
  chomp $row;
  if ($tag){
		@tissues = split /\t/,$row;
		shift @tissues;
    $tag = 0;
    next;
  }
  $count ++;
  my @fields = split /\t/,$row;
  my $probeset = shift @fields;
  next unless $probeset =~ /gnf/;
  #next unless $probeset =~ /gnf1h07276_at/;
  my $sym_obj_array = $dbh->get_SymatlasAnnotationAdaptor->fetch_by_probeset_id($probeset);
  foreach my $sym_obj (@{$sym_obj_array}){
  	my $symatlas_annotation_id = $sym_obj->dbID if $sym_obj;
		#next unless defined $symatlas_annotation_id;
		for (my $i = 0; $i < scalar @fields; $i += 2){
			my $tissue_name = $tissues[$i];
			next if $tissue_name eq 'Descriptions';
			next if $tissue_name =~ /_Detection/; 
			$tissue_name =~ s/_Signal//;
			if ($dir eq 'human'){
				my @t = split /_/, $tissue_name;
				shift @t;
				$tissue_name = join ("_",@t);
			}
			if ($dir eq 'mouse'){
				my $sub_tissue = substr($tissue_name,14);
				unless ($sub_tissue){$sub_tissue = substr($tissue_name,13);}
				$tissue_name = $sub_tissue;
			}
			print "TISSUE $tissue_name\n";
			$tissue_name =~ s/ /_/;
			if ($tissue_name eq "leukemialymphoblastic(molt4)"){$tissue_name = "leukemialymphoblastic"}
			if ($tissue_name eq "Colorectal Adenocarc"){$tissue_name = "colorectal_adenocarcinoma"}
			if ($tissue_name eq  "vomeralnasalorgan(VMO)"){$tissue_name = "vomeralnasalorgan"}
			if ($tissue_name eq  "WHOLEBLOOD(JJV)"){$tissue_name = "wholeblood"}
			my @tn;
			for (my $i=0; $i<length $tissue_name; $i++){push (@tn, substr($tissue_name,$i,(1)))}
  		
  		my $string = join("%",@tn);
			my $tissue = $dbh->get_TissueAdaptor->fetch_by_name_like(lc($string)."%");
			unless (defined $tissue){$tissue_name =~ s/_//;$tissue = $dbh->get_TissueAdaptor->fetch_by_name(lc($tissue_name));}
			my $tag = $fields[$i+1];
			print $tissue->dbID, " $symatlas_annotation_id, $tag\n";
			$sth->execute($tissue->dbID, $symatlas_annotation_id, $tag);
		}
  }
}  

