#! /usr/bin/perl -w


use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-49/modules";

use Bio::Cogemir::LogicName;
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Paralogs;
use Bio::Cogemir::LogicName;
use Time::localtime;
my $debug = 1;

$| = 1;		
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec;

do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings

# SETTINGS 

my $dbh_hashref = &_connection;
my $dbh = $dbh_hashref->{'cogemirh'};
#my $genome_db_id = shift @ARGV;

my $term = shift @ARGV;
my $logic_name_obj;

if ($term eq 'share'){
	foreach my $gene (@{$dbh->get_GeneAdaptor->get_All}){
		print $gene->attribute->gene_name,"\n",$gene->attribute->stable_id;
		print "\t",$gene->attribute->external_name if $gene->attribute->external_name;
		print "\n";
		my @micro_rnas = @{$gene->mirnas}; 
		my $share;
		if (scalar @micro_rnas >1){
			$share = 'yes'; 
		}
		else{
			$share = 'no';  
		}	
		foreach my $mir (@micro_rnas){
			$mir->share($share);
			$dbh->get_MicroRNAAdaptor->update($mir);
		}
		print " TOT ",scalar @micro_rnas, " $share\n";
	}
}


#UPDATE PARALOGS FIELD
# paralogs are mirna wiht one or two different bases

my %seen;

if ($term eq 'paralogs'){ 
	my $logic_name_obj;
	my $logic_name = 'paralogs';
	$logic_name_obj = $dbh->get_LogicNameAdaptor->fetch_by_name($logic_name);
	unless (defined $logic_name_obj){
		$logic_name_obj =  Bio::Cogemir::LogicName->new(   
									-NAME => $logic_name
								   );
		}
	my $parameters = "microRNA of same species with one or two different bases";
	my $analysis = Bio::Cogemir::Analysis->new(
									-LOGIC_NAME =>$logic_name_obj,
									-PARAMETERS =>$parameters,
									-CREATED =>$date
					);
	my $analysis_id = $dbh->get_AnalysisAdaptor->store($analysis);
	foreach my $mirna (@{$dbh->get_MirnaNameAdaptor->get_all_Names}){
		my %seen;
		foreach my $species (@{$dbh->get_GenomeDBAdaptor->get_all_mir_aliases}){
			my $name = $species."-".$mirna;
			if ($name =~/[a-z]$/){$name =~ s/[a-z]$//;}
			next if $seen{$name};
			$seen{$name} ++;
			print $name,"\n";
			my $genes = $dbh->get_MicroRNAAdaptor->fetch_by_gene_name_like($name);
			my @genes = @{$genes} if $genes;
			next if scalar @genes == 1;
    		foreach my $query (@genes){        
				foreach my $target (@genes){
					next if $query eq $target;
            		my $paralogs = Bio::Cogemir::Paralogs->new(
																		-query_member => $query,
																		-target_member => $target,
																		-type => 'point mutation',
																		-analysis => $analysis
																		);
            		$dbh->get_ParalogsAdaptor->store($paralogs);
        		}
    		}
		}
	}
}
#UPDATE SPECIFIC FIELD
#mirna present only in one species

if ($term eq 'specific'){
	my $specific;
	foreach my $mirna (@{$dbh->get_MirnaNameAdaptor->fetch_All}){
		print $mirna->name,"\t";
		my @genes = @{$mirna->mirnas};
		if (scalar @genes ==1){
			$specific = 'YES'; 
   			foreach my $gene (@genes){
   				$gene->specific($specific);
   				$dbh->get_MicroRNAAdaptor->update($gene);
   			}
   		}
   		else{
   			$specific = 'NO'; 
   			foreach my $gene (@genes){
   				$gene->specific($specific);
   				$dbh->get_MicroRNAAdaptor->update($gene);
   			}
   		}
   		print scalar @genes, " $specific\n";
    }
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

