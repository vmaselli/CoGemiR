# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;
plan tests => 26;

print "##### Testing Seq #####\n";
use CogemirTestDB;
use Bio::Cogemir::Seq;
use Bio::Cogemir::LogicName;

ok(1);

my $mirna_name_db_test = CogemirTestDB->new;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;

# external object

my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'seq test'
							   );

ok defined $logic_name;


# test class
# create object
my $seq = Bio::Cogemir::Seq->new(
				-name => "test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $seq;

#set all fields
ok $seq->sequence(),'ATTGCCTTCCGA';
ok $seq->name(), "test seq";
ok $seq->logic_name(), $logic_name;
ok $seq->isa('Bio::Cogemir::Seq');


#store

my $seq_adaptor = $dbh->get_SeqAdaptor();
ok defined $seq_adaptor;
ok $seq_adaptor->isa('Bio::Cogemir::DBSQL::SeqAdaptor');

my $dbID = $seq_adaptor->store($seq);
ok defined $dbID;

#fetch

ok $seq_adaptor->fetch_by_dbID($dbID);
my $seq_new = $seq_adaptor->fetch_by_dbID($dbID);
ok $seq_adaptor->fetch_by_name("test seq");
ok $seq_adaptor->fetch_by_type("seq test");
ok $seq_adaptor->fetch_by_name_type("test seq","seq test");
ok $seq_new->name();
ok $seq_new->sequence();
ok $seq_new->logic_name();
ok $seq_new->isa('Bio::Cogemir::Seq');

# update
ok $seq_new->name("update");
my $seq_updated = $seq_adaptor->update($seq_new);
ok $seq_updated->name, "update";
#remove

ok $seq_adaptor->remove($seq_updated);
