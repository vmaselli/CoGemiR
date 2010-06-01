#! /usr/bin/perl -w

use vars;
use strict;
use DBI;

my $data_source ="dbi:mysql:cogemir_4_49:localhost";
my $dbh = DBI->connect($data_source, 'root');

my $sth = $dbh->prepare('show databases');
$sth->execute;
while (my $dbname = $sth->fetchrow_array){
	if ($dbname =~ /^_test_cogemir_db/){
		print "drop $dbname\n";
		my $sth2 = $dbh->prepare("drop database $dbname");
		$sth2->execute;	
	}
}
