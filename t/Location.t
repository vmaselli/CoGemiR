# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 27;

print "##### Testing Location #####\n";

use Bio::Cogemir::Location;
use CogemirTestDB;
use Data::Dumper;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;



#test class
#create object

my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM => 'chromosome',
                -NAME => 12,
				-START => 10345,
				-END => 19678,
				-STRAND => 1
		);

ok defined $location;
ok $location->isa('Bio::Cogemir::Location');
ok $location->CoordSystem(), 'chromosome';
ok $location->name(),12;
ok $location->start(),10345;
ok $location->end(),19678;
ok $location->strand(), 1;



#store

my $location_adaptor = $dbh->get_LocationAdaptor($dbh);
ok $location_adaptor->isa('Bio::Cogemir::DBSQL::LocationAdaptor');
my $dbID = $location_adaptor->store($location);
ok defined $dbID;

#fetch

ok $location_adaptor->fetch_by_dbID($dbID);
ok $location_adaptor->fetch_by_region(12,10345,19678,1);
my $location_new = $location_adaptor->fetch_by_dbID($dbID);
ok $location_new->CoordSystem(), 'chromosome';
ok $location_new->name(),12;
ok $location_new->start(),10345;
ok $location_new->end(),19678;
ok $location_new->strand(), 1;

#update
ok $location_new->name(15);
my $location_updated = $location_adaptor->update($location_new);
ok $location_updated->name(),15;
#remove


ok $location_adaptor->remove($location_updated);



