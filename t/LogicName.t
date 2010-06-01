# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 13;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing LogicName #####\n";

use Bio::Cogemir::LogicName;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Seq;
use CogemirTestDB;
use Data::Dumper;
use Time::localtime;
ok(1);

my $mirna_name_db_test = CogemirTestDB->new;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";

# test class
#create object
my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $logic_name;

#test field

ok $logic_name->name(), 'ens_mirna_name';
ok $logic_name->isa('Bio::Cogemir::LogicName');
# storing

my $logic_name_adaptor = $dbh->get_LogicNameAdaptor;
ok $logic_name_adaptor->isa('Bio::Cogemir::DBSQL::LogicNameAdaptor');
my $dbID = $logic_name_adaptor->store($logic_name);
ok defined $dbID;

#fetch 

ok $logic_name_adaptor->fetch_by_dbID($dbID);
ok $logic_name_adaptor->fetch_by_name($logic_name->name);
my $logic_name_new = $logic_name_adaptor->fetch_by_dbID($dbID);
ok $logic_name_new->name();
ok $logic_name_new->isa('Bio::Cogemir::LogicName');

#update

ok $logic_name_new->name('updated name');
my $logic_name_updated = $logic_name_adaptor->update($logic_name_new);
ok $logic_name_updated->name(),'updated name';
#remove

use Bio::Cogemir::Analysis;
use Time::localtime;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";
my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name_updated,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							   );
ok defined $analysis;
ok $dbh->get_AnalysisAdaptor->store($analysis);

use Bio::Cogemir::Seq;
my $seq = Bio::Cogemir::Seq->new(
				-name => "test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name_updated
				);
ok defined $seq;
ok $dbh->get_SeqAdaptor->store($seq);


ok $logic_name_adaptor->remove($logic_name_updated);
