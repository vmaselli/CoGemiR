# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 40;
print "##### Testing Feature #####\n";

use Bio::Cogemir::Feature;
use CogemirTestDB;
use Data::Dumper;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;

# external object


use Bio::Cogemir::LogicName;
my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $logic_name;

use Bio::Cogemir::Analysis;
use Time::localtime;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";
my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							   );
ok defined $analysis;

# test class
#create object
my $feature =  Bio::Cogemir::Feature->new(   
							    -LOGIC_NAME => $logic_name, 
							    -DESCRIPTION => 'test for feature',
							    -NOTE => 'none',
							    -DISTANCE_FROM_DOWNSTREAMGENE => 10000,
							    -CLOSEST_DOWNSTREAMGENE => 'ENSG0000012346',
							    -DISTANCE_FROM_UPSTREAMGENE => 120000,
							    -CLOSEST_UPSTREAMGENE => 'ENSG0000012345',
							    -ANALYSIS => $analysis 						                                                  
							    );
ok defined $feature;
# print Dumper $feature;
#test field
ok $feature->isa('Bio::Cogemir::Feature');
ok $feature->logic_name, $logic_name;
ok $feature->description,'test for feature';
ok $feature->note,'none';
ok $feature->distance_from_upstream_gene,120000;
ok $feature->closest_upstream_gene,'ENSG0000012345';
ok $feature->distance_from_downstream_gene,10000;
ok $feature->closest_downstream_gene,'ENSG0000012346';
ok $feature->analysis,$analysis;

#storing
my $feature_adaptor = $dbh->get_FeatureAdaptor;
ok defined $feature_adaptor;
my $dbID = $feature_adaptor->store($feature);

#fetching
my $feature_new = $feature_adaptor->fetch_by_dbID($dbID);
ok defined $feature_new;
ok $feature_adaptor->fetch_by_name('ens_mirna_name');
ok $feature_adaptor->fetch_by_analysis_id($feature->analysis->dbID);
ok $feature_adaptor->fetch_by_distance_from_upstream_gene(120000);
ok $feature_adaptor->fetch_by_closest_upstream_gene('ENSG0000012345');

ok $feature_new->isa('Bio::Cogemir::Feature');
ok $feature_new->logic_name->name, 'ens_mirna_name';
ok $feature_new->description,'test for feature';
ok $feature_new->note,'none';
ok $feature_new->distance_from_upstream_gene,120000;
ok $feature_new->closest_upstream_gene,'ENSG0000012345';
ok $feature_new->distance_from_downstream_gene,10000;
ok $feature_new->closest_downstream_gene,'ENSG0000012346';
ok $feature_new->analysis->dbID,$analysis->dbID;

#update
ok $feature_new->note('updating');
my $feature_updated = $feature_adaptor->update($feature_new);
ok defined $feature_updated;

#remove

ok $feature_adaptor->remove($feature_updated);


