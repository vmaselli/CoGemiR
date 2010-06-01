# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;
plan tests => 19;
use lib "$ENV{'HOME'}/src/cogemir/modules";

print "##### Testing GenomeDB #####\n";


use Bio::Cogemir::GenomeDB;
use CogemirTestDB;


ok(1);

my $mirna_name_db_test = CogemirTestDB->new;
my $dbh = $mirna_name_db_test->get_DBAdaptor;

ok defined $dbh;


#test the class
#create object

my $genome_db = Bio::Cogemir::GenomeDB->new(
											-taxon_id => 10,
											-organism => 'Danio rerio',
											-db_host => '192.168.3.252',
											-db_name => 'danio_rerio_otherfeatures_42_6c',
											-db_type => 'otherfeatures',
											-common_name => 'zebrafish',
											-taxa => 'Fish'
											);

ok defined $genome_db;

#set all fields
ok $genome_db->taxon_id(), 10;
ok $genome_db->organism(), 'Danio rerio';
ok $genome_db->db_host(), '192.168.3.252';
ok $genome_db->db_name(), 'danio_rerio_otherfeatures_42_6c';
ok $genome_db->db_type(), 'otherfeatures';
ok $genome_db->common_name(),'zebrafish';
ok $genome_db->taxa(),'Fish';
ok $genome_db->isa('Bio::Cogemir::GenomeDB');

#print STDERR "here ok\n";


#store 

#print STDERR "trying to store \n";

my $genome_adaptor = $dbh->get_GenomeDBAdaptor($dbh);
##print Dumper $genome_db;
ok $genome_adaptor->isa('Bio::Cogemir::DBSQL::GenomeDBAdaptor');

my $dbID = $genome_adaptor->store($genome_db);
ok defined $dbID;

#fetch
ok $genome_adaptor->fetch_by_dbID($dbID);
my $genome_db_new = $genome_adaptor->fetch_by_dbID($dbID);

ok $genome_adaptor->fetch_by_taxa('Fish');
##print Dumper $genome_db;
ok $genome_db_new->taxon_id(10);
ok $genome_db_new->organism();
ok $genome_db_new->db_host();
ok $genome_db_new->db_name();
ok $genome_db_new->db_type();
ok $genome_db->common_name(),'zebrafish';
ok $genome_db->taxa(),'Fish';
ok $genome_db_new->isa('Bio::Cogemir::GenomeDB');

# update
ok $genome_db_new->taxon_id(12);
my $genome_db_updated = $genome_adaptor->update($genome_db_new);
ok $genome_db_updated->taxon_id, 12;

#remove
use Bio::Cogemir::LogicName;
my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $logic_name;
ok $dbh->get_LogicNameAdaptor->store($logic_name);
use Bio::Cogemir::Seq;
my $seq = Bio::Cogemir::Seq->new(
				-name => "test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $seq;
ok $dbh->get_SeqAdaptor->store($seq);
use Bio::Cogemir::MirnaName;
my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                    );
ok defined $mirna_name;
ok $dbh->get_MirnaNameAdaptor->store($mirna_name);



ok $genome_adaptor->remove($genome_db_updated);
