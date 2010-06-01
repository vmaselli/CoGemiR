# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 25;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Blast #####\n";
use CogemirTestDB;
use Data::Dumper;
use Bio::Cogemir::Blast;
use Bio::Cogemir::MirnaName;
use Time::localtime;
ok(1);


my $mirna_name_db_test = CogemirTestDB->new;
ok defined $mirna_name_db_test;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;


#create external obj
#ok $mirna_name_db_test->do_sql_file('sql/logic_name.dump');
use Bio::Cogemir::LogicName;
my $logic_name_obj =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'test'
							   );

ok defined $logic_name_obj;

use Bio::Cogemir::Feature;
my $feature =  Bio::Cogemir::Feature->new(   
							    -LOGIC_NAME => $logic_name_obj,
							    -DESCRIPTION => 'description'
							    );
ok defined $feature;

#test the class
#create object
my ($blast) =  Bio::Cogemir::Blast->new(       
							    -LOGIC_NAME =>$logic_name_obj,
							    -LENGTH =>32,
							    -FEATURE =>$feature
							    
							   );
				
ok defined $blast;

#set all fields

ok $blast->logic_name->name(), 'test';
ok $blast->length(),32;
ok $blast->feature, $feature;
ok $blast->isa('Bio::Cogemir::Blast');


#store blast

my $blast_adaptor = $dbh->get_BlastAdaptor($dbh);

ok $blast_adaptor->isa('Bio::Cogemir::DBSQL::BlastAdaptor');

my $dbID = $blast_adaptor->store($blast);

ok defined $dbID;

#fetch blast
ok $blast_adaptor->fetch_by_dbID($dbID);
ok $blast_adaptor->fetch_by_length(32);
ok $blast_adaptor->fetch_by_logic_name($logic_name_obj->dbID);
ok $blast_adaptor->fetch_by_feature_id($feature->dbID);
my $blast_new = $blast_adaptor->fetch_by_dbID($dbID);

ok $blast_new->adaptor();
ok $blast_new->logic_name->name(), 'test';
ok $blast_new->length(),32;
ok $blast_new->feature->dbID, $feature->dbID;
ok $blast_new->isa('Bio::Cogemir::Blast');

#update
ok $blast_new->length(56);
my $blast_updated = $blast_adaptor->update($blast_new);
ok $blast_updated->length, 56;

# 
# # remove
# HIT
# 
 ok $blast_adaptor->remove($blast_updated);
