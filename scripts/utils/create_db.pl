#! /usr/bin/perl -w

use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";

use Bio::SeqIO;
use Bio::Cogemir::DBSQL::DBAdaptor;

$| = 1;		

do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings

# SETTINGS 

my $user   = $::settings{'user'};
my $host   = $::settings{'host'};
my $driver = $::settings{'driver'};
my $dbname = $::settings{'dbname'};
my $pass   = $::settings{'pass'};

print STDOUT "DROPPING DB if is necessary\n";
system "mysqladmin -u$user -h$host -p$pass drop $dbname";
print STDOUT "DONE\n";


print STDOUT "CREATING a new db\n";
system "mysqladmin -u$user -h$host -p$pass create $dbname";
print STDOUT "DONE\n";


print STDOUT "inserting DB SCHEME\n";
system "mysql -u$user -h$host -p$pass $dbname < $ENV{'HOME'}/src/cogemir-beta/sql/$dbname.sql";
print STDOUT "DONE\n";


