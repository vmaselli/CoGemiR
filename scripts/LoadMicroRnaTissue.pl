 #! /usr/bin/perl -w


use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::Location;
do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);

my $sql = qq{INSERT INTO micro_rna_tissue SET micro_rna_id = ?, probset = ?, tissue_name = ?, expression_level = ?, platform = ?};
my $sth = $dbh->prepare($sql);

use Statistics::Descriptive::Discrete;
my $stats = new Statistics::Descriptive::Discrete;

my @levels;
my $species = shift @ARGV;

foreach my $micro_rna(@{$dbh->get_MicroRNAAdaptor->get_all_intragenic_by_organism($species)}){
  print $micro_rna->gene_name,"\t";
  my $host = $micro_rna->hostgene;
  print $host->attribute->external_name,"\t" if $host->attribute->external_name;
  foreach my $symatlas_annotation (@{$host->symatlas}){
  	next unless defined $symatlas_annotation;
  	print $symatlas_annotation->probset_id,"\t" ;
    my $average_href = $symatlas_annotation->average;
    my $standard_deviation_href = $symatlas_annotation->standard_deviation;
		foreach my $platform (keys %{$average_href}){
			foreach my $expression (@{$dbh->get_ExpressionAdaptor->get_all_by_gene_external($host->dbID,$symatlas_annotation->dbID,$platform)}){
				print $expression->tissue->name,"\t",$expression->expression_level,"\t";
				my $tot_tissues = $dbh->get_ExpressionAdaptor->count_all_tissue_by_gene_external($host->dbID,$symatlas_annotation->dbID,$platform); 
				my $count = 0;
				print "$tot_tissues\n";
				my $average = $average_href->{$platform};
				my $standard_deviation = $standard_deviation_href->{$platform};
				if ($expression->expression_level > $average + (3*$standard_deviation)){
					$count ++;
				}
				if ($count && $count/$tot_tissues <= 0.3){
					print $micro_rna->gene_name,"\t",$host->attribute->external_name,"\t",$symatlas_annotation->probset_id,"\t",$expression->tissue->name,"\t",$expression->expression_level,"\t$platform\n";
					$sth->execute($micro_rna->dbID,$symatlas_annotation->probset_id,$expression->tissue->name,$expression->expression_level,$platform);
				}
      }
    }
    print "\n";
  }
  print "\n";
}
    
