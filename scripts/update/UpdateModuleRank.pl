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
my $transcripts = $tr_adaptor->get_All;
foreach my $transcript (@{$transcripts}){
	my $localization = $dbh->get_LocalizationAdaptor->fetch_by_transcript($transcript->dbID);
	my $label = $localization->label;
	my $micro_rna = $localization->micro_rna;
	my $mir_start = $micro_rna->attribute->location->start;
	my $mir_end = $micro_rna->attribute->location->end;
	my $mir_strand = $micro_rna->attribute->location->strand;
	my @modules;
	if ($label =~ /intron/){@modules = @{$transcript->All_introns}}
	if ($label =~ /exon/){@modules = @{$transcript->All_exons}}
	foreach my $module (@modules){
		my $start = $module->start;
		my $end = $module->end;
		my $strand = $module->attribute->location->strand;
		if ($strand == $mir_strand){
			if ($start > $mir_start || $end < $mir_start){next;}
			if ($start < $mir_start && $end > $mir_end){
				print "MOVE ",$localization->module_rank," TO ",$module->rank," for localization ID ",$localization->dbID,"\n";
				$localization->module_rank($module->rank);
				$localization->adaptor->update($localization);
			}
		}
	}	
}
