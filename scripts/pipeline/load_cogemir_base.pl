#! /usr/bin/perl -w
=pod

=head1 NAME - load_cogemir_base.pl

=head1 SYNOPSIS    

=head1 DESCRIPTION

=head1 METHODS

=cut

BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings



use vars qw(@ISA);
use strict;
use lib $::lib{'cogemir'};

use Test;
use Data::Dumper;
use File::Spec;
use Time::localtime;

use lib "$ENV{'HOME'}/src/ensembl-api/v52/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v52/ensembl_compara/modules";

# import external modules to create the object
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::Seq;
use Bio::Cogemir::MicroRNA;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Feature;
use Bio::Cogemir::Gene;
use Bio::Cogemir::Transcript;
use Bio::Cogemir::Exon;
use Bio::Cogemir::Intron;
use Bio::Cogemir::Location;
use Bio::Cogemir::Localization;
use Bio::Cogemir::Aliases;
use Bio::Cogemir::GenomeDB;
use Bio::Cogemir::MirnaName;
use Bio::Cogemir::Attribute;
use Bio::GenomicInformation;

use Getopt::Std;
my %options;
getopts("d:s:c:",\%options);
my $debug = $options{'d'};

use Bio::Cogemir::LoadDB;

my $loader = &create_db;
my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::mysql_settings{'user'},
								-host => $::mysql_settings{'host'},
								-driver => $::mysql_settings{'driver'},
								-pass => $::mysql_settings{'pass'},
								-dbname => $::mysql_settings{'dbname'},
								-verbose => 1,
								-quick => 1
								);

					
my $settings = \%::settings;
my $query = Bio::GenomicInformation->new(-settings => $settings,
								                    -dbh =>$dbh);		

# define queries to load some feaures 
my $feat_sql = qq{INSERT INTO micro_rna_feature SET micro_rna_id = ?, feature_id = ?};
my $feat_sth = $dbh->prepare($feat_sql);


my $extdb_sql = qq{INSERT INTO external_database SET micro_rna_id = ?, database_name = ?, accession_number = ?, display = ?};
my $extdb_sth = $dbh->prepare($extdb_sql);

my $mat_sql = qq{INSERT INTO micro_rna_mature_sequence SET micro_rna_id = ?, mature_seq_id = ?};
my $mat_sth = $dbh->prepare($mat_sql);

# define global variables
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)."\n";


# define the species without chromosome definition 
my %sl_test =( 
          'Aedes aegypti'           =>1,
          'Ciona savignyi'          =>1,   
          'Dasypus novemcinctus'    =>1,
          'Echinops telfairi'       =>1,
          'Gasterosteus aculeatus'  =>1,
          'Loxodonta africana'      =>1,
          'Ornithorhynchus anatinus'=>1,
          'Oryctolagus cuniculus'   =>1,
          'Ciona intestinalis'      =>1,
          'Takifugu rubripes'       =>1,
          'Xenopus tropicalis'      =>1
  );
  
print "line 130 ok until now\n" if $debug;
my $log_file = "$ENV{'HOME'}/src/cogemir-beta/log/log.txt";
open (LOG, ">>$log_file") || die " $! $log_file";  
print "line 133 ok until now\n" if $debug;


my $species = $options{'s'};
my $clade = $options{'c'};
if ($species =~ /rubripes/){ $species = "Fugu rubripes" }

my $mirdbh = DBI->connect("DBI:mysql:database=mirbase12;host=$::mysql_settings{'host'};port=3306", $::mysql_settings{'user'}, $::mysql_settings{'pass'}) || die "Can't connect: ";

my $microrna_sql = qq{SELECT m.*, s.* FROM mirna m, mirna_species s WHERE m.auto_species = s.auto_id AND s.taxonomy = ?};
my $micro_rna_sth = $mirdbh->prepare($microrna_sql);
$micro_rna_sth->execute($options{'s'});

my $exetrnal_dbsql = qq{SELECT ed.* FROM mirna_database_links ed WHERE ed.auto_mirna = ?};
my $exetrnal_dbsth = $mirdbh->prepare($exetrnal_dbsql);

my $family_sql = qq{SELECT f.* FROM mirna_prefam f, mirna_2_prefam mf WHERE f.auto_prefam = mf.auto_prefam AND mf.auto_mirna = ?};
my $family_sth = $mirdbh->prepare($family_sql);

my $mature_sql = qq{SELECT m.* FROM mirna_mature m, mirna_pre_mature mm WHERE m.auto_mature = mm.auto_mature AND mm.auto_mirna = ?};
my $mature_sth = $mirdbh->prepare($mature_sql);

my $chr_build_sql = qq{SELECT * FROM mirna_chromosome_build WHERE auto_mirna = ?};
my $chr_build_sth = $mirdbh->prepare($chr_build_sql);


my $genomes = &_load_genome_db($species,$clade);
my $genome_db = $genomes->{'core'}{$species};
print ref $genome_db;
print $genome_db->organism,"\n";

######## MAIN ###############################################


while (my $microrna_hash = $micro_rna_sth->fetchrow_hashref){
  	
  	#test for presence in cogemir
	my $mirna_name = $microrna_hash->{'mirna_id'};
  	next if $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($mirna_name);
  	my $description =  $microrna_hash->{'description'};
  	my $automirna = $microrna_hash->{'auto_mirna'};
  	my $mir_acc = $microrna_hash->{'mirna_acc'};
  	
  	#setup precursor sequences
  	my $pre_sequence = $microrna_hash->{'sequence'};
  	my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "pre-miRNA"
                   );   
  	my $mirna_seq = Bio::Cogemir::Seq->new(
          -name => $mirna_name,
          -sequence => $pre_sequence,
          -logic_name =>$seq_logic_name
          );
  	
  	
  	
  	#setup family variables
  	$family_sth->execute($automirna);
  	my ($family_href) = $family_sth->fetchrow_hashref;
  	my $mirnaname_name = $family_href->{'prefam_id'};
  	my $mirnaname_description = $family_href->{'description'};
  	my $mirnaname_family_name = $family_href->{'prefam_acc'};
  	my $tmpname;
  	unless ($mirnaname_family_name){$tmpname = substr($mirna_name,4);}
  	unless(defined $mirnaname_name){
  		my @groups = split /\-/, $mirna_name; #hsa-mir-200b
  		shift @groups;
  		if (scalar @groups == 3){pop @groups}
 		$tmpname = join ("-",(@groups)); #mir-200b
 		$tmpname =~ s/\w$//;#mir-200
  		$mirnaname_name = $tmpname;
  		$mirnaname_description = 'single member family';
  		$mirnaname_family_name = undef;
  	}	
  	my $mirna_name_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "mirna name"
                   );
	my $mirna_name_analysis =  Bio::Cogemir::Analysis->new(       
				-LOGIC_NAME =>$mirna_name_logic_name,
				-PARAMETERS =>"sql query",
				-CREATED =>$date
			   );	
	my $mirna_name_obj = new Bio::Cogemir::MirnaName (   
									-name           => $mirnaname_name,
									-analysis       => $mirna_name_analysis,
									-exon_conservation => undef, #cannot say now
									-hostgene_conservation => undef, #cannot say now
									-description =>$mirnaname_description,
									-family_name =>$mirnaname_family_name 
								  );
  	my $attribute_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "miRNA attributes"
                   );
  	 
  	
  	#setup location and store micro_rna
  	$chr_build_sth->execute($automirna);
  	my ($location, $micro_rna, $attribute);
	my ($ens_mirna, $mirna_stable_id, $mirna_external);
	my ($chr_build_href) = $chr_build_sth->fetchrow_hashref;
	my $start = $chr_build_href->{'contig_start'};
	my $end = $chr_build_href->{'contig_end'};
	my $strand = $chr_build_href->{'strand'};
	my $region_name = $chr_build_href->{'xsome'};
	
	if ($strand eq '-'){$strand = '-1';}else{$strand = '+1';}
	my $coord_sys = 'chromosome';
	if ($sl_test{$species}){$coord_sys = 'SeqLevel'}

	$location = Bio::Cogemir::Location->new(
								-COORDSYSTEM =>$coord_sys,
								-NAME => $region_name,
								-START => $start,
								-END => $end,
								-STRAND => $strand
	); 
	
	$ens_mirna = $query->search_mirna_in_ensembl_by_slice($genome_db,$location);
	$mirna_stable_id = $ens_mirna->stable_id if $ens_mirna;
	$mirna_external = $ens_mirna->external_name if $ens_mirna;
	
	my $status = "ANNOTATED";
	unless (defined $location){$status = "PUTATIVE"}
	
	my $attribute_analysis =  Bio::Cogemir::Analysis->new(       
										-LOGIC_NAME =>$attribute_logic_name,
										-PARAMETERS =>'ensembl querying, mirbase querying',
										-CREATED =>$date
										
									 );
	$attribute =  Bio::Cogemir::Attribute->new(   
										-GENOME_DB              => $genome_db,
										-SEQ                 => $mirna_seq,
										-MIRNA_NAME          => $mirna_name_obj,
										-ANALYSIS            => $attribute_analysis,
										-STATUS              => $status,
										-GENE_NAME => $mirna_name,  
										-STABLE_ID => $mirna_stable_id, 
										-EXTERNAL_NAME => $mirna_external,
										-DB_LINK =>"miRBase",
										-DB_ACCESSION => $mir_acc,
										-LOCATION => $location
									 );  
	$micro_rna =  Bio::Cogemir::MicroRNA->new(   
										-ATTRIBUTE  => $attribute,
										-SPECIFIC     => undef, #you cannot say now
										-SEED       => undef, #you cannot say now
										-HOSTGENE   => undef
									 );

	$dbh->get_MicroRNAAdaptor->store($micro_rna);
	&_load_mir_attribute($micro_rna,$description,$pre_sequence,$automirna);

}


  
	
  
################## SUBROUTINE ####################
sub _load_mir_attribute{
	my ($micro_rna,$description,$sequence,$automirna) = @_;
	
	#setup mature sequences variables	
  	$mature_sth->execute($automirna);
  	#setup external db variables
  	$exetrnal_dbsth->execute($automirna); 
  	
	while (my $extdb_hashref = $exetrnal_dbsth->fetchrow_hashref){
		$extdb_sth->execute($micro_rna->dbID, $extdb_hashref->{'db_id'}, $extdb_hashref->{'db_link'}, $extdb_hashref->{'db_link'});
	}
	
	my $mirna_desc_logic_name =  Bio::Cogemir::LogicName->new(   
				-NAME => 'microRNA comment'
			   );

	my $mirna_desc_analysis =  Bio::Cogemir::Analysis->new(       
				-LOGIC_NAME =>$mirna_desc_logic_name,
				-PARAMETERS =>'pre-microRNA description from mirna.txt file miRBase 10.1 (Dec 2007)',
				-CREATED =>$date
			   );

	my $mirna_desc_feature =  Bio::Cogemir::Feature->new(   
				-LOGIC_NAME => $mirna_desc_logic_name, 
				-DESCRIPTION => $description,
				-NOTE => 'none',
				-ANALYSIS => $mirna_desc_analysis 						                                                  
				);

	my $mirna_desc_feat_id = $dbh->get_FeatureAdaptor->store($mirna_desc_feature);
	$feat_sth->execute($micro_rna->dbID, $mirna_desc_feat_id);
	
	#store mature
	while (my $mature_href = $mature_sth->fetchrow_hashref){
		my $mature_name = $mature_href->{'mature_name'};
		my $from = $mature_href->{'mature_from'};
		my $to = $mature_href->{'mature_to'};
		my $offset = $to - $from;
		my $mature_acc = $mature_href->{'mature_acc'};
		my $mature_sequence = substr($sequence,$from,$offset);
		
		# MATURE SEQ
		my $mature_logic_name =  Bio::Cogemir::LogicName->new(   
					-NAME => "mature microRNA sequence"
				   );
  
		my $mature_seq = Bio::Cogemir::Seq->new(
			 -name => $mature_name,
			-sequence => $mature_sequence,
			-logic_name =>$mature_logic_name
		  );
		  
		my $mat_seq_id = $dbh->get_SeqAdaptor->store($mature_seq);
		$mat_sth->execute($micro_rna->dbID,$mat_seq_id);

		my $mat_acc_logic_name =  Bio::Cogemir::LogicName->new(   
					-NAME => 'mature microRNA features'
				   );
  
		my $note;
		
		if (defined $mature_href->{'evidence'}){$note .= "Evidence: $mature_href->{'evidence'}"}
		elsif (defined $mature_href->{'experiment'}){$note .= " Experiment: $mature_href->{'experiment'}"}
		elsif (defined $mature_href->{'similarity'}){$note .= " Similar to: $mature_href->{'similarity'}"}
		
		my $mat_acc_analysis =  Bio::Cogemir::Analysis->new(       
					-LOGIC_NAME =>$mat_acc_logic_name,
					-PARAMETERS =>'mirna_mature from miRBase 12.1 (Sept 2008)',
					-CREATED =>$date
				   );
  
  
		my $mat_acc_feature =  Bio::Cogemir::Feature->new(   
					-LOGIC_NAME => $mat_acc_logic_name, 
					-DESCRIPTION => $mature_acc,
					-NOTE => $note,
					-ANALYSIS => $mat_acc_analysis 						                                                  
					);
  
  
		my $mat_feat_id = $dbh->get_FeatureAdaptor->store($mat_acc_feature);
		$feat_sth->execute($micro_rna->dbID, $mat_feat_id);		
	}
  }


sub _load_genome_db {
	my ($org,$clade) = @_;
	my $user = 'ens';
	my $pass = undef;
	my $ensdbh = DBI->connect("DBI:mysql:database=ensembl_compara_52;host=192.168.3.252;port=3306", $user, $pass) || die "Can't connect: ";
	my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl_config/registry_config.pl");
	my $query = qq{show databases};
	my $sth = $ensdbh->prepare($query);
	$sth->execute;
	my $tquery = qq{SELECT distinct(n.name) as common, g.taxon_id,g.name, n.name_class FROM genome_db g, ncbi_taxa_name n WHERE n.taxon_id = g.taxon_id AND g.name = ? AND n.name_class like ?};
	my $enssth = $ensdbh->prepare($tquery) || die $ensdbh->errstr; 
	my $db_ref;
		while (my $db = $sth->fetchrow_array){ 
			next unless (( $db =~ /core/ || $db =~ /vega/ || $db =~ /otherfeatures/) && $db =~ /52_/);
			my ($genere, $species,$db_type,$rel,$ass) = split /_/,$db;
			$enssth->execute($org,"%ensembl alias%") || die $sth->errstr;
		 
			while(my $fetch = $enssth->fetchrow_hashref){
				my ($common_name,$alias);
				my $name = $fetch->{'common'};
				my $name_class = $fetch->{'name_class'};
				if ($name_class =~ /alias/){$alias = $name}
				my ($common) = split /\s/,$common_name if $common_name;
				my $taxon_id = $fetch->{'taxon_id'};
				next unless $fetch->{'name'} =~ /$species/; 
				my $organism = $fetch->{'name'};
				
				my $genome_adaptor = $dbh->get_GenomeDBAdaptor;
				my $db_host = '192.168.3.252';
				my $genome_obj = Bio::Cogemir::GenomeDB->new(
																 -TAXON_ID => $taxon_id,
																 -ORGANISM => $organism,
																 -DB_HOST => $db_host,
																 -DB_NAME => $db,
																 -DB_TYPE => $db_type,
																 -COMMON_NAME =>$alias,
																 -TAXA =>$clade
																);		
				my $genome_dbID = $genome_adaptor->store($genome_obj);
				$db_ref->{$db_type}{$organism} = $genome_obj;
			}
		 
		}
	return $db_ref;
}


sub _get_build {
  my ($file) = @_;
  my %gen;
  open (FH, $file) || return;
  while (my $row = <FH>){
		chomp $row;
		if ($row =~ /^#/){next;}
		#1	.	miRNA	1092347	1092441	.	+	.	ACC="MI0000342"; ID="hsa-mir-200b";
		my ($region,$dot,$type,$start,$end,$dot2,$strand,$dot3,$identifier) = split /\t/, $row;
	  $identifier =~ s/\"//g; 
    $identifier =~ s/ID=//g;
    $identifier =~ s/ACC=//g; 
    my @res = split /\;/, $identifier;
    $res[1] =~ s/ //g;
    my ($mirbase_acc, $gene_name) = @res;
    #10393   14      100601688       100601757       +
    my $my_row = "$dot\t$region\t$start\t$end\t$strand";
    $gen{$gene_name} = $my_row;
  }
  return \%gen;
}

sub create_db {
	
	my ($self) = @_;
	my $loader =  Bio::Cogemir::LoadDB->new(   
							           -driver      => $::mysql_settings{'driver'},
							           -host        => $::mysql_settings{'host'},
							           -user        => $::mysql_settings{'user'},
							           -port        => $::mysql_settings{'port'},
							           -pass        => $::mysql_settings{'pass'},
							           -schema_sql  => $::mysql_settings{'schema_sql'},
							           -module      => $::mysql_settings{'module'},
							           -dbname      => $::mysql_settings{'dbname'}
							           );
	$loader->create_db;
	return $loader;
}

