# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;

plan tests => 32;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Hit #####\n";

use Bio::Cogemir::Hit;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Seq;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::Blast;
use CogemirTestDB;
use Time::localtime;
ok(1);

my $mirna_blast_db_test = CogemirTestDB->new;
my $dbh = $mirna_blast_db_test->get_DBAdaptor;

ok defined $dbh;

#create external obj

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

my $hfeature =  Bio::Cogemir::Feature->new(   
							    -LOGIC_NAME => $logic_name_obj,
							    -DESCRIPTION => 'hit description'
							    );
# test class
#create object
my $hit =  Bio::Cogemir::Hit->new(   
							    -BLAST =>$blast,
							    -FEATURE => $hfeature
							   );

ok defined $hit;

#test field
ok $hit->isa('Bio::Cogemir::Hit');
ok $hit->blast(),$blast;
ok $hit->feature, $hfeature;

# storing

my $hit_adaptor = $dbh->get_HitAdaptor;
ok $hit_adaptor->isa('Bio::Cogemir::DBSQL::HitAdaptor');
my $dbID = $hit_adaptor->store($hit);
ok defined $dbID;


# fetch 

ok $hit_adaptor->fetch_by_dbID($dbID);
ok $hit_adaptor->fetch_by_feature($hit->feature->dbID);
ok $hit_adaptor->fetch_by_blast_id($hit->blast->dbID);

my $hit_new = $hit_adaptor->fetch_by_dbID($dbID);
ok $hit_new->feature->dbID,$hfeature->dbID;
ok $hit_new->isa('Bio::Cogemir::Hit');
ok $hit_new->blast->dbID, $blast->dbID;

# update
$hfeature->logic_name->name('update name');
my $new_feature = $dbh->get_FeatureAdaptor->update($hfeature);
ok $hit_new->feature($new_feature);
my $hit_updated = $hit_adaptor->update($hit_new);
ok $hit_updated->feature->dbID,$new_feature->dbID;

# remove
my $seq = Bio::Cogemir::Seq->new(-name => 'test',-sequence => 'TTAGT',-logic_name => $logic_name_obj);
ok defined $seq;
use Bio::Cogemir::Hsp;
my $hsp =  Bio::Cogemir::Hsp->new(   
							    -HIT => $hit, 
							    -PERCENT_IDENTITY => 95, 
							    -LENGTH => 20,
							    -P_VALUE => 1e-5,
							    -FRAME => 2,
							    -SEQ => $seq, 
							    -START => 2,
							    -END => 15				                                                  
							    );
ok defined $hsp;
ok $dbh->get_HspAdaptor->store($hsp);
ok $hit_adaptor->remove($hit_updated);
