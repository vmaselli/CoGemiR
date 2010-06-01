#! /usr/bin/perl -w


use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl_compara/modules";


use Bio::Cogemir::DBSQL::DBAdaptor;


do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings

# SETTINGS 

my $dbh_hashref = &_connection;
my $dbh = $dbh_hashref->{'cogemirh'};


foreach my $mirna (@{$dbh->get_MirnaNameAdaptor->fetch_All}){
  unless (defined $mirna->family_name){$mirna->family_name($mirna->name);$mirna->adaptor->update($mirna);}
}
sub _connection{
	my ($dbname, $species) = @_;
	my %hash;
	my $cogemirh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);
	
	$hash{'cogemirh'} = $cogemirh;
	
	return (\%hash);
} 

