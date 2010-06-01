# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 25;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Analysis #####\n";
use CogemirTestDB;
use Data::Dumper;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::MirnaName;
use Time::localtime;
ok(1);


my $mirna_name_db_test = CogemirTestDB->new;
ok defined $mirna_name_db_test;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;


#create external obj
#ok $mirna_name_db_test->do_sql_file('sql/logic_name.dump');
my $lna = $dbh->get_LogicNameAdaptor;
my $logic_name_obj =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'test'
							   );

ok defined $logic_name_obj;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";

#test the class
#create object
my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name_obj,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							    
							   );
				
ok defined $analysis;

#set all fields

ok $analysis->logic_name->name(), 'test';
ok $analysis->parameters(),'mirna_name name';
ok $analysis->created(), $date;
ok $analysis->isa('Bio::Cogemir::Analysis');


#store analysis

my $analysis_adaptor = $dbh->get_AnalysisAdaptor($dbh);

ok $analysis_adaptor->isa('Bio::Cogemir::DBSQL::AnalysisAdaptor');

my $dbID = $analysis_adaptor->store($analysis);

ok defined $dbID;

#fetch analysis
my $month = (localtime->mon)+1;
ok $analysis_adaptor->fetch_by_dbID($dbID);
ok $analysis_adaptor->fetch_by_created($month);
ok $analysis_adaptor->fetch_by_logic_name($logic_name_obj->dbID);
ok $analysis_adaptor->fetch_by_created($date);
my $analysis_new = $analysis_adaptor->fetch_by_dbID($dbID);

ok $analysis_new->adaptor(),$analysis_adaptor;
ok $analysis_new->logic_name->dbID(),$logic_name_obj->dbID;
ok $analysis_new->parameters(),'mirna_name name';
ok $analysis_new->isa('Bio::Cogemir::Analysis');

#update
ok $analysis_new->parameters('update');
my $analysis_updated = $analysis_adaptor->update($analysis_new);
ok $analysis_updated->parameters, 'update';


# remove
my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis_updated,
                                      -exon_conservation => 2,
                                      -hostgene_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
ok defined $mirna_name;
$dbh->get_MirnaNameAdaptor->store($mirna_name);

ok $analysis_adaptor->remove($analysis_updated);
