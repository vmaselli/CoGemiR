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

my $sql = qq{INSERT INTO expression_statistics SET symatlas_annotation_id = ?, gene_id = ?, average = ?, standard_deviation = ?, platform = ?};
my $sth = $dbh->prepare($sql);

use Statistics::Descriptive::Discrete;


my @levels;

# foreach my tissue
foreach my $gene (@{$dbh->get_GeneAdaptor->get_All}){
  foreach my $symatlas_annotation (@{$dbh->get_SymatlasAnnotationAdaptor->fetch_all_by_gene($gene->dbID)}){
    my %expr;
    my @exprs = @{$dbh->get_ExpressionAdaptor->fetch_all_by_external($symatlas_annotation->dbID)};
    foreach my $expression (@exprs){
      push (@{$expr{$expression->platform}}, $expression->expression_level);
    }
    foreach my $key (keys %expr){
    	my @values = @{$expr{$key}};
			unless (scalar @values){next}
			my $stats = new Statistics::Descriptive::Discrete;
			$stats->add_data(@values);
			my $average = $stats->mean;
			my $standard_deviation = $stats->standard_deviation;
				 
			print $gene->gene_name."\t".$symatlas_annotation->probset_id."\t$average ± $standard_deviation tot ".$stats->count()."\n";
			$sth->execute($symatlas_annotation->dbID,$gene->dbID,$average,$standard_deviation,$key);
			$stats->add_data(@values);
			@values = ();
		}
  }
}
    
