# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 40;
print "##### Testing Hsp #####\n";

use Bio::Cogemir::Hsp;
use CogemirTestDB;
use Data::Dumper;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;

# external object
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
use Bio::Cogemir::Blast;
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
use Bio::Cogemir::Hit;
my $hit =  Bio::Cogemir::Hit->new(   
							    -BLAST =>$blast,
							    -FEATURE => $hfeature
							   );

ok defined $hit;
use Bio::Cogemir::Seq;
my $seq = Bio::Cogemir::Seq->new(-name => 'hsp',-sequence => 'TTAGT',-logic_name => $logic_name_obj);
ok defined $seq;

# test class
#create object
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
#test field
ok $hsp->isa('Bio::Cogemir::Hsp');
ok $hsp->hit, $hit;
ok $hsp->percent_identity, 95;
ok $hsp->length,20;
ok $hsp->p_value,1e-5;
ok $hsp->frame,2;
ok $hsp->seq,$seq;
ok $hsp->start,2;
ok $hsp->end,15;

# storing
my $hsp_adaptor = $dbh->get_HspAdaptor;
ok defined $hsp_adaptor;
my $dbID = $hsp_adaptor->store($hsp);

# fetching
my $hsp_new = $hsp_adaptor->fetch_by_dbID($dbID);
ok defined $hsp_new;
ok $hsp_adaptor->fetch_by_hit_id($hsp->hit->dbID);
ok $hsp_adaptor->fetch_by_percent_identity(95);

ok $hsp_new->isa('Bio::Cogemir::Hsp');
ok $hsp_new->hit->dbID, $hit->dbID;
ok $hsp_new->percent_identity, 95;
ok $hsp_new->length,20;
ok $hsp_new->p_value,1e-5;
ok $hsp_new->frame,2;
ok $hsp_new->seq->name,$seq->name;
ok $hsp_new->start,2;
ok $hsp_new->end,15;

# update
ok $hsp_new->seq->sequence('utgtta');
my $hsp_updated = $hsp_adaptor->update($hsp_new);
ok defined $hsp_updated;
 
# remove
ok $hsp_adaptor->remove($hsp_updated);