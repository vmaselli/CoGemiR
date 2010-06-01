# -*-Perl-*-
## Cogemir Test Harness Script
##

use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::Location;
do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);
my $tr_adaptor = $dbh->get_TranscriptAdaptor;
#print ref $tr_adaptor,"\n";
my $transcripts = $tr_adaptor->get_All;
print Dumper $transcripts,"\n";
foreach my $transcript (@{$transcripts}){
	foreach my $intron(@{$transcript->introns}){
		my $dbID = $intron->dbID + 1;
		my $old_intron = $intron;
		my $next_intron = $intron->adaptor->fetch_by_dbID($dbID);
		$intron->post_exon($next_intron->pre_exon);
		$intron->adaptor->update($intron);
		printf "UPDATE post_exon_if from %d to %d\n", $old_intron->post_exon->dbID,  $intron->post_exon->dbID;
	}
}
