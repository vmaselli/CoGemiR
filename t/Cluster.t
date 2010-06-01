# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 32;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Cluster #####\n";

use Bio::Cogemir::Cluster;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Seq;
use Bio::Cogemir::LogicName;
use CogemirTestDB;
use Data::Dumper;
use Time::localtime;
ok(1);

my $mirna_name_db_test = CogemirTestDB->new;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";


#create external obj
my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $logic_name;

my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							    
							   );
				
ok defined $analysis;



# test class
#create object
my $cluster =  Bio::Cogemir::Cluster->new(   
							    -NAME => 'ens_mirna_name',
							    -ANALYSIS => $analysis
							   );

ok defined $cluster;

#test field
ok $cluster->isa('Bio::Cogemir::Cluster');
ok $cluster->name(), 'ens_mirna_name';
ok $cluster->analysis, $analysis;

#storing

my $cluster_adaptor = $dbh->get_ClusterAdaptor;
ok $cluster_adaptor->isa('Bio::Cogemir::DBSQL::ClusterAdaptor');
my $dbID = $cluster_adaptor->store($cluster);
ok defined $dbID;


#fetch 

ok $cluster_adaptor->fetch_by_dbID($dbID);
ok $cluster_adaptor->fetch_by_name($cluster->name);
ok $cluster_adaptor->fetch_by_analysis_id($cluster->analysis->dbID);

my $cluster_new = $cluster_adaptor->fetch_by_dbID($dbID);
ok $cluster_new->name();
ok $cluster_new->isa('Bio::Cogemir::Cluster');
ok $cluster_new->analysis->dbID, $analysis->dbID;
#update

ok $cluster_new->name('updated name');
my $cluster_updated = $cluster_adaptor->update($cluster_new);
ok $cluster_updated->name(),'updated name';

#remove

ok $cluster_adaptor->remove($cluster_updated);
