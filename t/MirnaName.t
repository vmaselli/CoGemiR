# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;
plan tests => 26;

print "##### Testing MirnaName #####\n";
use CogemirTestDB;
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

my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name_obj,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							    
							   );
				
ok defined $analysis;

#test the class
#create object

my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis,
                                      -exon_conservation => 2,
                                      -hostgene_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
ok defined $mirna_name;

ok $mirna_name->name, 'mir-204';
ok $mirna_name->analysis, $analysis;
ok $mirna_name->exon_conservation, 2;
ok $mirna_name->hostgene_conservation, 'partial';
ok $mirna_name->description,'micro rna name from miRBase';
ok $mirna_name->isa('Bio::Cogemir::MirnaName');


#store

my $mirna_name_adaptor = $dbh->get_MirnaNameAdaptor();
ok defined $mirna_name_adaptor;
ok $mirna_name_adaptor->isa('Bio::Cogemir::DBSQL::MirnaNameAdaptor');

my $dbID = $mirna_name_adaptor->store($mirna_name);
ok defined $dbID;

#fetch

ok $mirna_name_adaptor->fetch_by_dbID($dbID);
my $mirna_name_new = $mirna_name_adaptor->fetch_by_dbID($dbID);
ok $mirna_name_new->dbID, $dbID;
ok $mirna_name_new->name, 'mir-204';
ok $mirna_name_new->analysis->logic_name->name, 'test';
ok $mirna_name_new->exon_conservation, 2;
ok $mirna_name_new->hostgene_conservation, 'partial';
ok $mirna_name_new->description,'micro rna name from miRBase';

ok $mirna_name_new->isa('Bio::Cogemir::MirnaName');
ok $mirna_name_adaptor->fetch_by_name("mir-204");
ok $mirna_name_adaptor->fetch_by_analysis_id($mirna_name_new->analysis->dbID);
ok $mirna_name_adaptor->fetch_by_exon_conservation(2);
ok $mirna_name_adaptor->fetch_by_hostgene_conservation('partial');


# update
ok $mirna_name_new->name("update");
my $mirna_name_updated = $mirna_name_adaptor->update($mirna_name_new);
ok $mirna_name_updated->name, "update";
#remove

ok $mirna_name_adaptor->remove($mirna_name_updated);