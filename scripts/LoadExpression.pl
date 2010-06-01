 #! /usr/bin/perl -w

use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Expression;
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
my $sql = qq{INSERT INTO ap_tissue SET tissue_id = ?, symatlas_annotation_id = ?, tag = ?};
my $sth = $dbh->prepare($sql);

unless (scalar @ARGV){die "USAGE: script name <inputfile> <tag> <species> "}
my $file = shift @ARGV;
my $tag = shift @ARGV;
my $species = shift @ARGV;

my $data_file = $file || die $!;
print "TAG $tag\n";
my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
open (DATA, "$data_file") || die;
my $flag = 1;
my @tissues;
my %seen;
while (my $row = <DATA>){
  chomp $row;
  
  if ($flag){
    @tissues = split /\t/, $row;
		shift @tissues if $tag eq 'ap';
		shift @tissues if $tag eq 'data';
    $flag = 0;
    
    next;
  }
  
  my @f = split /\t/,$row;
  my $probeset = $f[0];
  
  next unless $probeset =~/gnf/;
  my $symatlas_annotation_arrayref = $dbh->get_SymatlasAnnotationAdaptor->fetch_by_probeset_id($probeset);
		foreach my $symatlas_annotation (@{$symatlas_annotation_arrayref}){
		print "PROBESET ",$symatlas_annotation->probset_id."\n";
		for (my $i = 0; $i <scalar @f; $i++){
			my $tissue_name = lc($tissues[$i]);
			my @tn;
			if ($tag eq 'ap'){
				next if $tissue_name eq 'Descriptions';
				next if $tissue_name =~ s/_detection//; 
				$tissue_name =~ s/_signal//;
				if ($file =~  /human/){
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
			if ($tissue_name =~ /vomeralnasalorgan/){$tissue_name = 'vomeralnasalorgan'}
			next if $seen{$tissue_name};
			for (my $i=0; $i<length $tissue_name; $i++){push (@tn, substr($tissue_name,$i,(1)))}
  		my $string = join("%",@tn);
  		my $tissue = $dbh->get_TissueAdaptor->fetch_by_name_like(lc($string)."%");
			unless (defined $tissue){$tissue_name =~ s/_//;$tissue = $dbh->get_TissueAdaptor->fetch_by_name(lc($tissue_name));}
			
			print "$tissue_name\n"  unless defined $tissue;
			
			exit unless defined $tissue;
			my $expression_level = $f[$i+1];
			next unless defined $expression_level;
			my $platform;
			if ($tag eq 'data'){$platform = 'MAS5';}
			elsif ($tag eq 'gcrma'){$platform = 'GCRMA';}
			
			#print "RES $platform $tissues[$i]\t",lc($tissue_name),"\n ";
			if ($tag eq 'ap'){$sth->execute($tissue->dbID, $symatlas_annotation->dbID, $expression_level);}
			else{
				my $expression =  Bio::Cogemir::Expression->new( 
													-EXTERNAL => $symatlas_annotation,
													-EXPRESSION_LEVEL => $expression_level,
													-TISSUE => $tissue,
													-PLATFORM => $platform
												 );
				$dbh->get_ExpressionAdaptor->store($expression);
			}
			print "$probeset\t"; 
			print "$platform\t"; 
			print "$tissue_name\t"; 
			print "$expression_level\n";
		}
  }
}

