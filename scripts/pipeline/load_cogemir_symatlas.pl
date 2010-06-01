#! /usr/bin/perl -w
# This script parses data from miRBase and EnsEMBL in order to load the first level of information 
# in CoGemiR database. 


# import standard libraries
use strict;
use Test;
use Data::Dumper;
use File::Spec;
use Time::localtime;

# import external libraries
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
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

# create a connection with the MySQL server, create the database and load the database scheme
# my $load_db_obj = Bio::Cogemir::LoadDB->new;
# my $dbh = $load_db_obj->get_DBAdaptor;

do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings
my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-pass => $::settings{'pass'},
								-dbname => $::settings{'dbname'},
								-verbose => 1,
								-quick => 1
								);
my $debug = 0;
my $clean = 1;
if ($clean){
	my $sth = $dbh->prepare("show tables");
	$sth->execute;
	while (my $table = $sth->fetchrow_array){
		my $truncate = $dbh->prepare("truncate $table");
		$truncate->execute;
	}
}								
my $settings = \%::settings;
my $query = Bio::GenomicInformation->new(-settings => $settings,
								                    -dbh =>$dbh);		

# define queries to load some feaures 
my $feat_sql = qq{INSERT INTO micro_rna_feature SET micro_rna_id = ?, feature_id = ?};
my $feat_sth = $dbh->prepare($feat_sql);

my $gene_feat_sql = qq{INSERT INTO gene_feature SET gene_id = ?, feature_id = ?};
my $gene_feat_sth = $dbh->prepare($gene_feat_sql);

my $dir_sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $dir_sth = $dbh->prepare($dir_sql);

my $extdb_sql = qq{INSERT INTO external_database SET micro_rna_id = ?, database_name = ?, accession_number = ?, display = ?};
my $extdb_sth = $dbh->prepare($extdb_sql);

my $mat_sql = qq{INSERT INTO micro_rna_mature_sequence SET micro_rna_id = ?, mature_seq_id = ?};
my $mat_sth = $dbh->prepare($mat_sql);

# define global variables
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)."\n";

my %clade = ('Homo sapiens' => 'Primates',
            'Aedes aegypti' => 'Arthropoda',
            'Anopheles gambiae' => 'Arthropoda',
            'Bos taurus' => 'Mammalia',
            'Caenorhabditis elegans' => 'Nematoda',
            'Canis familiaris' => 'Mammalia',
            'Cavia porcellus' => 'Rodentia',
            'Ciona intestinalis' => 'Tunicates',
            'Ciona savignyi' => 'Tunicates',
            'Danio rerio' => 'Pisces',
            'Dasypus novemcinctus' => 'Mammalia',
            'Dipodomys ordii' => 'Rodentia',
            'Drosophila melanogaster' => 'Arthropoda',
            'Echinops telfairi' => 'Mammalia',
            'Equus caballus' =>'Mammalia',
            'Erinaceus europaeus' => 'Mammalia',
            'Felis catus' => 'Mammalia',
            'Gallus gallus' => 'Aves',
            'Gasterosteus aculeatus' => 'Pisces' ,
            'Gorilla gorilla' => 'Primates',
            'Loxodonta africana' => 'Mammalia',
            'Macaca mulatta' => 'Primates',
            'Microcebus murinus' => 'Primates',
            'Monodelphis domestica' =>'Marsupials',
            'Mus musculus' => 'Rodentia',
            'Myotis lucifugus' => 'Mammalia',
            'Ochotona princeps'=> 'Rodentia',
            'Ornithorhynchus anatinus' => 'Mammalia',
            'Oryctolagus cuniculus' => 'Rodentia',
            'Oryzias latipes' => 'Pisces',
            'Otolemur garnettii' => 'Primates',
            'Pan troglodytes' => 'Primates',
            'Pongo pygmaeus' =>'Primates',
            'Procavia capensis' => 'Mammalia',
            'Pteropus vampyrus' => 'Mammalia',
            'Rattus norvegicus' => 'Rodentia',
            'Saccharomyces cerevisiae' => 'Yeast',
            'Sorex araneus' => 'Mammalia',
            'Spermophilus tridecemlineatus' =>'Rodentia',
            'Takifugu rubripes' => 'Pisces',
            'Tarsius syrichta' => 'Primates',
            'Tursiops truncatus' => 'Mammalia',
            'Tetraodon nigroviridis' => 'Pisces',
            'Tupaia belangeri' => 'Rodentia',
            'Vicugna pacos' => 'Mammalia',
            'Xenopus tropicalis' => 'Amphibia'
          );
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
  
my $genomes = &_load_genome_db;
 print "line 130 ok until now\n" if $debug;
my $log_file = "$ENV{'HOME'}/src/cogemir-beta/log/log.txt";
open (LOG, ">>$log_file") || die " $! $log_file";  
 print "line 133 ok until now\n" if $debug;


# opening the miRBase files and parsing them
my $files_dir = "$ENV{'HOME'}/Projects/cogemir/data/mirbase/";

 print "line 139 ok until now\n" if $debug;

# get external db reference
#21447	RFAM 	RF00027 	let-7
my $externaldbtxt =  File::Spec->catfile($files_dir,"mirna_database_links.txt");
open (ED, $externaldbtxt) || die " $! $externaldbtxt";
my %exdb;
while (my $row = <ED>){
	chomp $row;
	my @fields = split /\t{1,10}/,$row;
	my $mirID = $fields[0];
	my %feat = ('database'  => $fields[1],
							'accession' => $fields[2],
							'display' => $fields[3]
	           );
	
	push(@{$exdb{$mirID}},\%feat);
}  
  
# get correspondence between mature e pre from mirna_pre_mature file
# mirna internal id mature internal id
my $mirna_pre_maturetxt = File::Spec->catfile($files_dir,"mirna_pre_mature.txt");
open (MPM, $mirna_pre_maturetxt) || die "$! $mirna_pre_maturetxt";
my %pre_mat;
while (my $corr_row = <MPM>){
  chomp $corr_row;
  my ($mirID,$mat_id) = split /\t{1,10}/,$corr_row;
  push(@{$pre_mat{$mirID}},$mat_id);
}

# get mature name  and mature range from mirna_mature.txt 
# internal id name acc  start end evidence exp similarity
my $mirna_maturetxt = File::Spec->catfile($files_dir,"mirna_mature.txt");
open (MIM, $mirna_maturetxt) || die "$! $mirna_maturetxt";
my %mature;
while (my $tmp_row = <MIM>){
  chomp $tmp_row;
  my ($mat_id) = split /\t{1,10}/,$tmp_row;
  $mature{$mat_id} = $tmp_row;
}

# get coordinates from mirna_chromosome_build.txt
# mirna internal id chromosome start end strand
my $mirna_location = File::Spec->catfile($files_dir,"mirna_chromosome_build.txt");
open (MCB, $mirna_location) || die "$! $mirna_location" ;
my %build;
while (my $tmp_row = <MCB>){
  chomp $tmp_row;
  my ($pre_id) = split /\t{1,10}/,$tmp_row;
  push(@{$build{$pre_id}},$tmp_row);
}

# get correspondence between mir and fam from mirna_2_fam.txt
# auto_mirna  auto_prefam
my $mirna2fam = File::Spec->catfile($files_dir,"mirna_2_prefam.txt");
open (M2F, $mirna2fam) || die "$! $mirna2fam";
my %pre_fam;
while (my $mir_2_fam = <M2F>){
  chomp $mir_2_fam;
  my ($pre2_id,$fam_id) = split /\t{1,10}/,$mir_2_fam;
  $pre_fam{$pre2_id} = $fam_id;
}

# get mirna name from mirna_prefam.txt 
# auto_prefam prefam_acc prefam_id description
my $mirna_prefamtxt = File::Spec->catfile($files_dir,"mirna_prefam.txt");
open (MPF, $mirna_prefamtxt) || die "$! $mirna_prefamtxt";
my %fam;
while (my $tmp_row = <MPF>){
  chomp $tmp_row;
  my ($fam2_id) = split /\t{1,10}/,$tmp_row;
  $fam{$fam2_id} = $tmp_row;
}
  
my $speciestxt = File::Spec->catfile($files_dir,"mirna_species.txt");  
open (SP, $speciestxt) || die "$! $speciestxt";
my $genome_dir = File::Spec->catfile($files_dir,"genomes");
# get species attribute from mirna_species.txt 
# 5       hsa     HSA     Homo sapiens    Metazoa;Vertebrata;Mammalia;Primates;Hominidae; NCBI36  homo_sapiens_core_47_36i
my %species;
while (my $tmp_row = <SP>){
  chomp $tmp_row;
  my @tmp = split /\t{1,10}/,$tmp_row;
  my $sp_id = $tmp[0];
  my $spid = $tmp[1];
  my $spec = $tmp[3];
  my $db = $tmp[$#tmp];
  #print $species,"\n";
  $spec = "Takifugu rubripes" if $spec =~ /rubripes/;
  next unless $clade{$spec};
  my $file = File::Spec->catfile($genome_dir,$spid.".gff");
  my $res = &_get_build($file);
  $species{$sp_id} = $res;
}

######## MAIN ###############################################
# get microRNA from mirna.txt
# internal_id accession name description sequence comment 
my $mirnatxt = File::Spec->catfile($files_dir,"mirna.txt");
open (MIR, $mirnatxt) || die "$! $mirnatxt";
while (my $mir_row = <MIR>){
  chomp $mir_row;
  my @mirs = split /\t{1,10}/,$mir_row;
  # test for ensembl species
  my $spec_id = $mirs[$#mirs];
  next unless $species{$spec_id};
  
  #init variables
  my $mir_id = $mirs[0]; #internal identifier
  my $mir_acc = $mirs[1]; #mirbase accession number
  my $mirna_name = $mirs[2];
  if ($debug){
  	next unless $mirna_name eq 'hsa-mir-155';
  }
  #test for presence in cogemir
  next if $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($mirna_name);
  print LOG "MIR: $mirna_name\n";
  
  #init species variables
  my @feat = split /\s/,$mirs[3];
  my ($genere,$spec,$fam,$type);
  if($mirs[3] =~ $mir_acc){
  	$genere = $feat[1];
  	$spec = $feat[2];
  }
  else{
  	$genere = $feat[0];
  	$spec = $feat[1];
  }
  my $species = $genere." ".$spec;
  if ($species =~ /rubripes/){ $species = "Takifugu rubripes" }
  my $spec_row = $species{$spec_id};
  
  #init precursor sequence vairables
  my $sequence = $mirs[4];
  my $mirna_desc = $mirs[3].". ";
  for (my $i = 5; $i <scalar @mirs -1; $i++){$mirna_desc .= $mirs[$i];}
  
  #init external dbg variables
  my @hashes = @{$exdb{$mir_id}} if $exdb{$mir_id};
	
	#init family variables
  my $prefam_row = $fam{$pre_fam{$mir_id}};
  my ($prefam_id,$param,$fam_name,$fam_description) = split /\t{1,10}/,$prefam_row;
  my @groups = split /\-/, $mirna_name; #hsa-mir-200b
	shift @groups;
	if (scalar @groups == 3){pop @groups}
	my $name = join ("-",(@groups)); #mir-200b
  unless($fam_name){
  	$fam_name = $name;
  	$param = 'none';$name = substr($mirna_name,4);
  }
	
	#init mature sequences variables
	my @multiple_mat;
	my %feat_mature;
	foreach my $mat_id (@{$pre_mat{$mir_id}}){
  	my $mat_row = $mature{$mat_id};
  	my @mats = split /\t{1,10}/,$mat_row;
  	my $mature_name = $mats[1];
  	my $from = $mats[3];
  	my $to = $mats[4];
  	my $offset = $to - $from;
  	my $mature_acc = $mats[2];
  	unless (defined $mature_acc){throw("no mature for $mirna_name");};
  	my $mature_sequence = substr($sequence,$from,$offset);
  
  	my $feat_desc = "mature accession number ".$mature_acc;
  	if (scalar @mats == 9){
    	my $similarity = $mats[8];
    	$feat_desc .= " similar to: $similarity"; 
  	}
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
    push(@multiple_mat, $mature_seq);
    
    my $mat_feat_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => 'mature microRNA features'
                   );
  
  
  	my $mat_analysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$mat_feat_logic_name,
                    -PARAMETERS =>'mirna_mature file parsing from miRBase 12.1 (Sept 2008)',
                    -CREATED =>$date
                   );
  
  
  	my $mat_feature =  Bio::Cogemir::Feature->new(   
                    -LOGIC_NAME => $mat_feat_logic_name, 
                    -DESCRIPTION => $feat_desc,
                    -NOTE => 'none',
                    -ANALYSIS => $mat_analysis 						                                                  
                    );
  
  
  	my $mat_feat_id = $dbh->get_FeatureAdaptor->store($mat_feature);
		$feat_mature{$mat_seq_id} = $mat_feat_id;
	}

######################## CREATE OBJECTS ####################

# PRE- SEQ        
  my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "pre-miRNA"
                   );
    
  my $mirna_seq = Bio::Cogemir::Seq->new(
          -name => $mirna_name,
          -sequence => $sequence,
          -logic_name =>$seq_logic_name
          );
  
  # MICRO RNA OBJ == FAMILY
  
  my $mirna_name_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "mirna name"
                   );

  my $mirna_name_analysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$mirna_name_logic_name,
                    -PARAMETERS =>$param,
                    -CREATED =>$date
                   );
            
  my $mirna_name_obj = new Bio::Cogemir::MirnaName (   
                                        -name           => $name,
                                        -analysis       => $mirna_name_analysis,
                                        -exon_conservation => undef, #cannot say now
                                        -hostgene_conservation => undef, #cannot say now
                                        -description =>$fam_description,
                                        -family_name =>$fam_name 
                                      );
  
  # ATTRIBUTE
  
  my $attribute_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "miRNA attributes"
                   );
  my $genome_db = $genomes->{'core'}{$species};
	
	#control on the existence of the species in the database
	unless (defined $genome_db){
		print " no genome db for $species\n";
		exit;
	}
  my @coos = @{$build{$mir_id}} if $build{$mir_id};
  my ($coord_row) = @coos if scalar @coos;
	unless ($coord_row){
		my $coord_hashref = $species{$spec_id};
		$coord_row = $coord_hashref->{$mirna_name};
	}
	unless (defined $coord_row){
		my $attribute =  Bio::Cogemir::Attribute->new(   
											-GENOME_DB              => $genome_db,
											-SEQ                 => $mirna_seq,
											-MIRNA_NAME          => $mirna_name_obj,
											-ANALYSIS            => undef,
											-STATUS              => 'PUTATIVE',
											-GENE_NAME => $mirna_name,  
											-STABLE_ID => undef, 
											-EXTERNAL_NAME => $mirna_name,
											-DB_LINK =>"miRBase",
											-DB_ACCESSION => $mir_acc,
											-LOCATION => undef
										 );  
		my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
											-ATTRIBUTE  => $attribute,
											-SPECIFIC     => undef, #you cannot say now
											-SEED       => undef, #you cannot say now
											-HOSTGENE   => undef,
										 );
										 
		my $micro_rna_id = $dbh->get_MicroRNAAdaptor->store($micro_rna);
		print "line 433 \n" if $debug;
		next;
	};

my @coords = split /\t{1,10}/,$coord_row;
	my $region_name = $coords[1];
	my $start = $coords[2];
	my $end = $coords[3];
	my $strand = $coords[4];
	if ($strand eq '-'){$strand = '-1';}else{$strand = '+1';}
	my $coord_sys = 'chromosome';
	if ($sl_test{$species}){$coord_sys = 'SeqLevel'}
	
	my $location = Bio::Cogemir::Location->new(
									-COORDSYSTEM =>$coord_sys,
									-NAME => $region_name,
									-START => $start,
									-END => $end,
									-STRAND => $strand
	); 
  my $host_genome_db = $genome_db;
  unless (defined $host_genome_db){print "no core genome db for $species";die;}
  my $host = $query->search_host_in_ensembl_by_slice($host_genome_db,$location); 
  #unless (defined $host){warn("host for $mirna_name not defined in ensembl")} 
  my $flanking_gene;
   
  unless ($host){
    $host_genome_db = $genomes->{'vega'}{$species};
    unless (defined $host_genome_db){print "no vega genome db for $species";next;}
    $host = $query->search_host_in_ensembl_by_slice($host_genome_db,$location);
    unless ($host){
      $host_genome_db = $genomes->{'otherfeatures'}{$species};
      unless (defined $host_genome_db){print "no est genome db for $species";next;}
      $host = $query->search_host_in_ensembl_by_slice($host_genome_db,$location);
    }
  }
  my $gene;
  my $direction = 'sense';
  if ($host){
    if ($strand != $host->strand){$direction = 'antisense'}
    my $host_location = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $location->name,
            -START => $host->start,
            -END => $host->end,
            -STRAND => $host->strand
        );
    my ($refseq_dna,$gene_symbol,$refseq_dna_predicted,$unigene,$ucsc);
    unless ($host_genome_db->db_type eq 'otherfeatures'){ 
      my $dbEntries = $host->get_all_DBEntries;
      foreach my $dbEntry (@{$dbEntries}){
        my $db_name = $dbEntry->dbname;
        my $display_id = $dbEntry->display_id;
        if ($db_name eq 'RefSeq_dna'){$refseq_dna .= $display_id.", ";}
        if ($db_name eq 'HGNC'){$gene_symbol = $display_id.", ";}
        if ($db_name eq 'RefSeq_dna_predicted'){$refseq_dna_predicted .= $display_id.", ";}
        if ($db_name eq 'UniGene'){$unigene .= $display_id.", ";}
        if ($db_name eq 'UCSC'){$ucsc.= $display_id.", ";}
      }
    }
    my $aliases = Bio::Cogemir::Aliases->new(
                      -REFSEQDNA => $refseq_dna,
                      -GENESYMBOL => $gene_symbol,
                      -REFSEQDNA_PREDICTION => $refseq_dna_predicted,
                      -UNIGENE =>$unigene,
                      -UCSC => $ucsc
                    );
                        
    my $host_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "host miRNA attributes"
                   );
  
    my $host_analysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$host_logic_name,
                    -PARAMETERS =>'ensembl querying, mirbase querying',
                    -CREATED =>$date
                    
                   );
    
    my $host_attribute =  Bio::Cogemir::Attribute->new(   
                      -GENOME_DB              => $host_genome_db,
                      -MIRNA_NAME          => $mirna_name_obj,
                      -ANALYSIS            => $host_analysis,
                      -STATUS              => $host->status,
                      -GENE_NAME => $mirna_name."_host",  
                      -STABLE_ID => $host->stable_id, 
                      -EXTERNAL_NAME => $host->external_name,
                      -DB_LINK =>"EnsEMBL",
                      -DB_ACCESSION => $host->stable_id,
                      -LOCATION => $host_location,
                      -ALIASES => $aliases
                     );
      
    my $conservation_score;
    #$conservation_score = &_get_conservation_score($host_genome_db,$location);
    $gene =  Bio::Cogemir::Gene->new(   
                      -ATTRIBUTE              => $host_attribute,
                      -BIOTYPE =>$host->biotype,
                      -LABEL            => 'host',
                      -CONSERVATION_SCORE  => $conservation_score,
                      -DIRECTION => $direction
                     );
                     
  }
my @multiples;
  ####### coordinates ##########################
  
  foreach my $coord_row (@coos){
		unless ($coord_row){
			my $coord_hashref = $species{$spec_id};
			$coord_row = $coord_hashref->{$mirna_name};
		}
		unless (defined $coord_row){warn("no coordinates for $mirna_name");next;};
		my @coords = split /\t{1,10}/,$coord_row;
		my $region_name = $coords[1];
		my $start = $coords[2];
		my $end = $coords[3];
		my $strand = $coords[4];
		if ($strand eq '-'){$strand = '-1';}else{$strand = '+1';}
		my $coord_sys = 'chromosome';
		if ($sl_test{$species}){$coord_sys = 'SeqLevel'}
		
		my $location = Bio::Cogemir::Location->new(
										-COORDSYSTEM =>$coord_sys,
										-NAME => $region_name,
										-START => $start,
										-END => $end,
										-STRAND => $strand
				);
				
		my $attribute_analysis =  Bio::Cogemir::Analysis->new(       
											-LOGIC_NAME =>$attribute_logic_name,
											-PARAMETERS =>'ensembl querying, mirbase querying',
											-CREATED =>$date
											
										 );
		
		my $ens_mirna = $query->search_mirna_in_ensembl_by_slice($genome_db,$location);
		#unless (defined $ens_mirna){warn("$mirna_name not defined in ensembl")} 
		 
		#my $status = $ens_mirna->status if $ens_mirna;
		#unless ($status){$status = 'UNKNOWN'}
		my $mirna_stable_id = $ens_mirna->stable_id if $ens_mirna;
		my $mirna_external = $ens_mirna->external_name if $ens_mirna;
		
		my $attribute =  Bio::Cogemir::Attribute->new(   
											-GENOME_DB              => $genome_db,
											-SEQ                 => $mirna_seq,
											-MIRNA_NAME          => $mirna_name_obj,
											-ANALYSIS            => $attribute_analysis,
											-STATUS              => 'ANNOTATED',
											-GENE_NAME => $mirna_name,  
											-STABLE_ID => $mirna_stable_id, 
											-EXTERNAL_NAME => $mirna_external,
											-DB_LINK =>"miRBase",
											-DB_ACCESSION => $mir_acc,
											-LOCATION => $location
										 );  
		my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
											-ATTRIBUTE  => $attribute,
											-SPECIFIC     => undef, #you cannot say now
											-SEED       => undef, #you cannot say now
											-HOSTGENE   => $gene
										 );
										 
		my $micro_rna_id = $dbh->get_MicroRNAAdaptor->store($micro_rna);
		$dir_sth->execute($micro_rna->dbID, $micro_rna->hostgene->dbID,$direction) if $host;
		push (@multiples,$micro_rna);
		
		foreach my $hash (@hashes){
  		#print "$mirna_name\t".$hash->{'database'}."\t".$hash->{'accession'}."\t".$hash->{'display'}."\n";
  		#printf "INSERT INTO external_database SET micro_rna_id = %d, database = %s, accession_number = %s, display = %s\n",$micro_rna_id, $hash->{'database'},$hash->{'accession'},$hash->{'display'};
  		$extdb_sth->execute($micro_rna_id, $hash->{'database'},$hash->{'accession'},$hash->{'display'});
  	}
  }
  my ($ens_tr,$ens_p);
  if ($host){
    my $region_start = $location->start;
    my $region_end = $location->end;	
   
    foreach my $transcript (@{$host->get_all_Transcripts()}){
      my $loc_flag = 0;
      my $label;
      my $loc_count = 0;
      my ($loc_pre_exon, $rank, $offset);
      $ens_tr .= $transcript->stable_id.",";
      $ens_p  .= $transcript->translation->stable_id."," if $transcript->translation;
      my $tlogic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "transcript attributes"
                   );
  
      my $tanalysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$tlogic_name,
                    -PARAMETERS =>'Bio::EnsEMBL::Transcript',
                    -CREATED =>$date
                    
                   );
      
      my $tlocation = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $location->name,
            -START => $transcript->start,
            -END => $transcript->end,
            -STRAND => $host->strand
        );
        
      my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "host transcript"
                   );
        
      # my $transcript_seq = Bio::Cogemir::Seq->new(
#               -name => $transcript->stable_id,
#               -sequence => $transcript->seq->seq,
#               -logic_name =>$seq_logic_name
#               );
      my $tattribute =  Bio::Cogemir::Attribute->new(   
                      -GENOME_DB              => $host_genome_db,
                      #-SEQ                 => $transcript_seq,
                      -MIRNA_NAME          => $mirna_name_obj,
                      -ANALYSIS            => $tanalysis,
                      -STATUS              => $transcript->status,
                      -GENE_NAME => $mirna_name."_transcript",  
                      -STABLE_ID => $transcript->stable_id, 
                      -EXTERNAL_NAME => $transcript->external_name,
                      -DB_LINK =>"EnsEMBL",
                      -DB_ACCESSION => $transcript->dbID,
                      -LOCATION => $tlocation
                     );
                     
      my $transcript_obj =  Bio::Cogemir::Transcript->new(   
                        -PART_OF => $gene,
                        -ATTRIBUTE =>$tattribute
                       );
      $dbh->get_TranscriptAdaptor->store($transcript_obj); 
      print $transcript_obj->dbID," ",$transcript_obj->stable_id,"\n";
      my $exon_term = 'undef';
      my $count = 0;
      my $flag = 0;
      my $pre_exon_flag = 0;
      my $pre_exon;
      my $pre_intron;
      
      my @exons = @{$transcript->get_all_Exons()};
      my @new_exons = @exons;
      @new_exons = sort ({$a->start <=> $b->start} @exons);
      if ($host->strand == -1){
          $count = (scalar @new_exons) + 1;
          $loc_count = $count;
      }
      my $monoexon = 0;
      if (scalar @exons == 1){$monoexon = 1};
      if ($host->biotype  =~ /processed_transcript/){$exon_term ='noncoding_exon'}
      elsif ($host->biotype  =~ /processed_pseudogene/){$exon_term ='pseudocoding_exon'}
      elsif($host->biotype =~ /coding/){$exon_term ='coding_exon'}
      my $coding_start = $transcript->coding_region_start;
      my $coding_end = $transcript->coding_region_end;	
    
      printf "TS %d TE %d\n",$transcript->start,$transcript->end;
      if ($region_end < $transcript->start){ 
        print " RE $region_end < TS ".$transcript->start." !!!";
        next;
      }
      if($region_start > $transcript->end){
       	print " RE $region_end < TS ".$transcript->end." !!!";
       	next;
      }

      my $tag =0;
      foreach my $exon (@new_exons){
        if ($host->strand == -1){
            $count --;
            $loc_count --;
            $flag = 1;
        }
        else{
            $count ++;
            $loc_count ++;
            $flag = scalar @new_exons;
        }
        print "EXON RANK = $count\n";
        my $exon_start = $exon->start;
        my $exon_end = $exon->end;
        if ($coding_start){
          if ($exon_end < $coding_start){$exon_term = 'five_prime_utr'; }
          elsif ($exon_start <= $coding_start ){$exon_term = 'five_prime_exon_noncoding_region';}
          elsif ($exon_start >= $coding_start && $exon_end <= $coding_end){$exon_term ='coding_exon';}
          elsif ($exon_end >=$coding_end){$exon_term = 'three_prime_exon_noncoding_region';}
          elsif ($exon_start > $coding_end && $exon_end > $coding_end){$exon_term = 'three_prime_utr'; }
        	else{print "ERROR HERE line 719";die;}
        }
        else{$exon_term ='noncoding_exon'}
        unless (defined $exon_term){
          printf "CS %d CE %d ES %d EE %d\n",$coding_start,$coding_end,$exon_start,$exon_end;
          exit;
        }
        print "EXON TERM $exon_term\n";
        my $elogic_name =  Bio::Cogemir::LogicName->new(   
                  -NAME => "exon attributes"
                 );
  
        my $eanalysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$elogic_name,
                      -PARAMETERS =>'Bio::EnsEMBL::Exon',
                      -CREATED =>$date
                      
                     );
        
        my $elocation = Bio::Cogemir::Location->new(
                      -COORDSYSTEM =>$coord_sys,
                      -NAME => $location->name,
                      -START => $exon->start,
                      -END => $exon->end,
                      -STRAND => $host->strand
          );
          
        my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "host exon"
                   );
          
        # my $exon_seq = Bio::Cogemir::Seq->new(
#                 -name => $exon->stable_id,
#                 -sequence => $exon->seq->seq,
#                 -logic_name =>$seq_logic_name
#                 );  
        my $eattribute =  Bio::Cogemir::Attribute->new(   
                        -GENOME_DB              => $host_genome_db,
                        #-SEQ                 => $exon_seq,
                        -MIRNA_NAME          => $mirna_name_obj,
                        -ANALYSIS            => $eanalysis,
                        -GENE_NAME => $mirna_name."_exon",  
                        -STABLE_ID => $exon->stable_id, 
                        -DB_LINK =>"EnsEMBL",
                        -DB_ACCESSION => $exon->dbID,
                        -LOCATION => $elocation,
                        -STATUS => $tattribute->status
                       );
        
        my $exon_obj =  Bio::Cogemir::Exon->new(   
                          -PART_OF => $transcript_obj, 
                          -RANK => $count, 
                          -LENGTH => ($exon_end - $exon_start + 1),
                          -PHASE => $exon->phase,
                          -ATTRIBUTE => $eattribute,
                          -TYPE => $exon_term
                          );
        $dbh->get_ExonAdaptor->store($exon_obj);
        
        my $ilogic_name =  Bio::Cogemir::LogicName->new(   
                  -NAME => "intron attributes"
                 );
  
        my $ianalysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$ilogic_name,
                      -PARAMETERS =>'Bio::EnsEMBL::Exon',
                      -CREATED =>$date
                      
                     );
        
        my $ilocation = Bio::Cogemir::Location->new(
                      -COORDSYSTEM =>$coord_sys,
                      -NAME => $location->name,
                      -START => $exon->end + 1,
                      -END => $exon->end,
                      -STRAND => $host->strand
          );
        my $iattribute =  Bio::Cogemir::Attribute->new(   
                        -GENOME_DB              => $host_genome_db,
                        -MIRNA_NAME          => $mirna_name_obj,
                        -ANALYSIS            => $ianalysis,
                        -GENE_NAME => $mirna_name."_intron",  
                        -DB_LINK =>"EnsEMBL",
                        -LOCATION => $ilocation,
                        -STATUS =>$tattribute->status
                       );
        
        my $intron =  Bio::Cogemir::Intron->new(   
                          -PART_OF => $transcript_obj, 
                          -LENGTH => undef,
                          -ATTRIBUTE => $iattribute,
                          -PRE_EXON => $exon_obj
                          );
        
        
        
        if ($pre_exon_flag){
            $pre_intron->length($exon_obj->start-1 - $pre_exon->end -1);
            $pre_intron->attribute->location->end($exon->start-1);
            $pre_intron->post_exon($exon_obj);
            $dbh->get_IntronAdaptor->store($pre_intron);
            $dbh->get_LocationAdaptor->update($pre_intron->attribute->location);
            $exon_obj->pre_intron($pre_intron);
            print "TERM ".$exon_obj->type."\n";
            $dbh->get_ExonAdaptor->update($exon_obj);
            $pre_exon->post_intron($pre_intron);
        		$dbh->get_ExonAdaptor->update($pre_exon);
            if ($count == $flag){last;}
        }
        
        $pre_exon_flag = 1;
        $pre_exon = $exon_obj; #for pre_intron
        $pre_intron = $intron; #for next exon
        
      }
      print "RS $region_start RE $region_end\n";
      my @modules = @{$transcript_obj->All_introns} if $transcript_obj->All_introns;
			foreach my $module (@modules){
				print ref $module."\n";
				my $start = $module->start;
				my $end = $module->end;
				print "IS $start IE $end IR".$module->rank." ".($start - $region_start)."\n"; 
				if ($region_start >= $start && $region_end <= $end){
					$label = "intron"; 
          $offset = $start - $region_start;
          $rank = $module->rank;
         	last;
        }
      }
			unless (defined $label){		
				@modules = @{$transcript_obj->All_exons};	
				foreach my $module (@modules){
					my $start = $module->start;
					my $end = $module->end;
					my $type = $module->type;
					print "ES $start EE $end ET $type ER".$module->rank."\n";
					if ($region_start >= $start && $region_end <= $end){
						$label = "exon"; 
						unless ($type =~ /exon/){$label = 'UTR'}
					}
					elsif ($region_start >= $start  && $region_start < $end){
						$label = "exon_left";
						unless ($type =~ /exon/){$label = 'UTR_left'}
					}
					elsif ($region_end >= $start  && $region_end < $end){
						$label = "exon_right"; 
						unless ($type =~ /exon/){$label = 'UTR_right'} 
					}
					elsif ($region_start <= $start && $region_end >= $end){
						$label = "over exon";
						unless ($type =~ /exon/){$label = 'over UTR'}
					}
					if ($module->rank == 1 && ($region_end <= $start || $region_start >= $end)){
						$label = "UTR";
					}
					if ($label){
						$offset = $start - $region_start;
						$rank = $module->rank;
						last;
					}
				}
			}              
      unless (defined $label){die " no label"}
      foreach my $micro_rna (@multiples){
				my ($localization) =  Bio::Cogemir::Localization->new( 
									-LABEL => $label,  
									-MODULE_RANK => $rank, 
									-OFFSET => $offset,
									-TRANSCRIPT =>$transcript_obj,
									-MICRO_RNA => $micro_rna
									 );
				
				$dbh->get_LocalizationAdaptor->store($localization);
      }
    }
  }
  unless($host){
    $flanking_gene = &_search_flanking_region($genome_db,$location);
    print "LABEL intergenic\n";
    foreach my $micro_rna (@multiples){
			my ($localization) =  Bio::Cogemir::Localization->new(   
								 -LABEL => "intergenic",  
								 -MICRO_RNA => $micro_rna
									);
			$dbh->get_LocalizationAdaptor->store($localization);
    }
  }
  
  
  ####################### FEATURES #################################################
  
  
  
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
                    -DESCRIPTION => $mirna_desc,
                    -NOTE => 'none',
                    -ANALYSIS => $mirna_desc_analysis 						                                                  
                    );
  
  my $mirna_desc_feat_id = $dbh->get_FeatureAdaptor->store($mirna_desc_feature);
  foreach my $micro_rna (@multiples){
  	$feat_sth->execute($micro_rna->dbID, $mirna_desc_feat_id);
  }
  foreach my $micro_rna (@multiples){
  	foreach my $mat_seq (@multiple_mat){
  		print "mature seq ".$micro_rna->dbID."\t".$mat_seq->dbID."\n";
  		$mat_sth->execute($micro_rna->dbID,$mat_seq->dbID);
  		$feat_sth->execute($micro_rna->dbID, $feat_mature{$mat_seq->dbID});
  	}
	}
	
  if (defined $gene){
  	my $genome_db = $genomes->{'core'}{$species};
  	unless (defined $genome_db){print "no core genome db for $species";die;}

    my $slice = $query->search_in_ensembl_by_slice($genome_db,$location);
  	foreach my $ensgene (@{$slice->get_all_Genes}){
  		next if $ensgene->stable_id eq $gene->stable_id;
  		my $logic_name =  Bio::Cogemir::LogicName->new(   
                -NAME => 'additional core overlapping'
               );

			my $analysis =  Bio::Cogemir::Analysis->new(       
												-LOGIC_NAME =>$logic_name,
												-PARAMETERS =>'core overlapping gene',
												-CREATED =>$date
											 );
			
			my $feature =  Bio::Cogemir::Feature->new(   
												-LOGIC_NAME => $logic_name, 
												-DESCRIPTION => $ensgene->stable_id.", ".$ensgene->external_name.", ".$ensgene->slice->name,
												-NOTE => "evidence of core overlapping gene for microRNA with a core hostgene",
												-ANALYSIS => $analysis 						                                                  
												);
			
			my $feat_id = $dbh->get_FeatureAdaptor->store($feature);
			
			$gene_feat_sth->execute($gene->dbID, $feat_id);

  	}
    my $vega_genome_db = $genomes->{'vega'}{$species};
    unless (defined $vega_genome_db){print "no vega genome db for $species";next;}

    my $vega = $query->search_host_in_ensembl_by_slice($vega_genome_db,$location);
    
    my $est_genome_db = $genomes->{'otherfeatures'}{$species};
    unless (defined $est_genome_db){print "no est genome db for $species";next;}

    my $est = $query->search_host_in_ensembl_by_slice($est_genome_db,$location);
    
    if (defined $vega && $vega->strand == $strand){
      my $vega_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => 'additional vega overlapping'
                     );
      
      my $vega_analysis =  Bio::Cogemir::Analysis->new(       
                        -LOGIC_NAME =>$vega_logic_name,
                        -PARAMETERS =>'vega overlapping gene',
                        -CREATED =>$date
                       );
      
      my $vega_feature =  Bio::Cogemir::Feature->new(   
                        -LOGIC_NAME => $vega_logic_name, 
                        -DESCRIPTION => $vega->stable_id.", ".$vega->external_name.", ".$vega->slice->name,
                        -NOTE => "evidence of vega overlapping gene for microRNA with a core hostgene",
                        -ANALYSIS => $vega_analysis 						                                                  
                        );
      
      my $vega_feat_id = $dbh->get_FeatureAdaptor->store($vega_feature);
      
      $gene_feat_sth->execute($gene->dbID, $vega_feat_id);
    }
    
    if (defined $est && $est->strand == $strand){
      my $est_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => 'additional est overlapping'
                     );
      
      my $est_analysis =  Bio::Cogemir::Analysis->new(       
                        -LOGIC_NAME =>$est_logic_name,
                        -PARAMETERS =>'est overlapping gene',
                        -CREATED =>$date
                       );
      
      my $est_feature =  Bio::Cogemir::Feature->new(   
                        -LOGIC_NAME => $est_logic_name, 
                        -DESCRIPTION => $est->stable_id.", ".$est->slice->name,
                        -NOTE =>"evidence of est overlapping gene for microRNA with a core hostgene" ,
                        -ANALYSIS => $est_analysis 						                                                  
                        );
      
      my $est_feat_id = $dbh->get_FeatureAdaptor->store($est_feature);
      
      $gene_feat_sth->execute($gene->dbID, $est_feat_id);
    }
    
    if ($direction eq 'sense'){
      my $rev_location = $location;
      $rev_location->strand(-1 * ($location->strand));
      my $reverse_gene = $query->search_host_in_ensembl_by_slice($genome_db,$rev_location);
      if ($reverse_gene && $reverse_gene->strand != $strand){
        my $rev_logic_name =  Bio::Cogemir::LogicName->new(   
                        -NAME => 'additional reverse overlapping'
                       );
        
        my $rev_analysis =  Bio::Cogemir::Analysis->new(       
                          -LOGIC_NAME =>$rev_logic_name,
                          -PARAMETERS =>'reverse overlapping gene',
                          -CREATED =>$date
                         );
        
        my $rev_feature =  Bio::Cogemir::Feature->new(   
                          -LOGIC_NAME => $rev_logic_name, 
                          -DESCRIPTION => $reverse_gene->stable_id.", ".$reverse_gene->external_name.", ".$reverse_gene->slice->name,
                          -NOTE => "evidence of reverse overlapping gene for microRNA with a core hostgene",
                          -ANALYSIS => $rev_analysis 						                                                  
                          );
        
        my $rev_feat_id = $dbh->get_FeatureAdaptor->store($rev_feature);
        
        $gene_feat_sth->execute($gene->dbID, $rev_feat_id);
      }
    }
  }
  
  if (defined $flanking_gene){
    my $down = $flanking_gene->{"down"};
    my $up = $flanking_gene->{"up"};
    my $downgene = $flanking_gene->{"downgene"};
    my $upgene = $flanking_gene->{"upgene"};
    if ($downgene || $upgene){
      my $downstable = $downgene->stable_id if $downgene;
      my $upstable = $upgene->stable_id if $upgene;
      
      my $fg_feat_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => 'flanking gene'
                     );
          
      my $fg_analysis =  Bio::Cogemir::Analysis->new(       
                        -LOGIC_NAME =>$fg_feat_logic_name,
                        -PARAMETERS =>$up." bp upstream and ".$down." downstream microRNA regions",
                        -CREATED =>$date
                       );
      
      my $fg_feature =  Bio::Cogemir::Feature->new(   
                      -LOGIC_NAME => $fg_feat_logic_name, 
                      -DESCRIPTION => 'flanking region of microRNA',
                      -NOTE => 'up distance from end of gene max 100000, down distance from start of gene max 100000',
                      -DISTANCE_FROM_DOWNSTREAMGENE => $down,
                      -CLOSEST_DOWNSTREAMGENE => $downstable,
                      -DISTANCE_FROM_UPSTREAMGENE => $up,
                      -CLOSEST_UPSTREAMGENE => $upstable,
                      -ANALYSIS => $fg_analysis 						                                                  
                      );
      
      my $fg_feat_id = $dbh->get_FeatureAdaptor->store($fg_feature);
    	foreach my $micro_rna (@multiples){
      	$feat_sth->execute($micro_rna->dbID, $fg_feat_id);
      }
    }
  }

}
################## SUBROUTINE ####################

sub _load_genome_db {

my $user = 'ens';
my $pass = undef;
my $ensdbh = DBI->connect("DBI:mysql:database=ensembl_compara_52;host=192.168.3.252;port=3306", $user, $pass) || die "Can't connect: ";
my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl_config/registry_config.pl");
my $query = qq{show databases};
my $sth = $ensdbh->prepare($query);
$sth->execute;
my $tquery = qq{SELECT distinct(n.name) as common, g.taxon_id,g.name, n.name_class FROM genome_db g, ncbi_taxa_name n WHERE n.taxon_id = g.taxon_id AND n.name_class like ?};
my $enssth = $ensdbh->prepare($tquery) || die $ensdbh->errstr; 
my $db_ref;
	while (my $db = $sth->fetchrow_array){ 
		next unless (( $db =~ /core/ || $db =~ /vega/ || $db =~ /otherfeatures/) && $db =~ /52_/);
		my ($genere, $species,$db_type,$rel,$ass) = split /_/,$db;
		$enssth->execute("%ensembl alias%") || die $sth->errstr;
	 
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
															 -TAXA =>$clade{$organism}
															);		
			my $genome_dbID = $genome_adaptor->store($genome_obj);
			$db_ref->{$db_type}{$organism} = $genome_obj;
		}
	 
	}
return $db_ref;
}

sub _search_flanking_region{
  my ($genome_db,$location) = @_;
  
  my %ret;
  my @tested;
  my $start = $location->start;
  my $end = $location->end;
  my $window = 10000;
  
  ####### SEARCHING UPSTREAM
  my $up_location = $location;
  my $newstart = $start - $window;
  my $newend = $end - $window;

  $up_location->start($newstart);
  $up_location->end($newend);
  my $upgene;
  while ($window < 30001){
    if ($newstart < 0 || $newend < 0){last}
    my $upslice = $query->search_in_ensembl_by_slice($genome_db,$up_location);
    unless (defined $upslice){
      $window += 10000;
      $newend = $newstart -1;
      $newstart = $newstart - $window;
      $up_location->start($newstart);
      $up_location->end($newend);
      next;
    }
    foreach my $gene (@{$upslice->get_all_Genes}){
      next if $gene->biotype eq 'miRNA';
      #print "UP ",$upgene->external_name."\n" if $upgene;
      $ret{'upgene'} = $gene;
      $ret{'up'} = ($start - $gene->slice->end);
      last;
    }
  
    $window += 10000;
    $newend = $newstart -1;
    $newstart = $newstart - $window;
    $up_location->start($newstart);
    $up_location->end($newend);
  }
  $window = 10000;
  ##### SEARCHING DOWNSTREAM
 
  my $down_location = $location;
  $newstart = $start + $window;
  $newend = $end + $window;
  $down_location->start($newstart);
  $down_location->end($newend);
  my $downgene;
  while ($window < 30001){
    if ($newstart < 0 || $newend < 0){last}
    my $downslice = $query->search_in_ensembl_by_slice($genome_db,$down_location);
    unless (defined $downslice){
      $window += 10000;
      $newstart = $newstart + $window;
      $newend += $window;
      $down_location->start($newstart);
      $down_location->end($newend);
      next;
    }
    foreach my $gene (@{$downslice->get_all_Genes}){
      next if $gene->biotype eq 'miRNA';
      $ret{'downgene'} = $gene;
      $ret{'down'} = ($gene->slice->start - $end);
      last;
    }
    $window += 10000;
    $newstart = $newstart + $window;
    $newend += $window;
    $down_location->start($newstart);
    $down_location->end($newend);
  }
  
  return \%ret;
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
