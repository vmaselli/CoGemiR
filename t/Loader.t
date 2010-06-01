# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Statistics::Descriptive::Discrete;
use Data::Dumper;
plan tests => 32;

use lib "$ENV{'HOME'}/src/cogemir/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v48/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v48/ensembl_compara/modules";
use CogemirTestDB;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;
do ("$ENV{'HOME'}/src/mirnadb/data/configfile.pl") or die "$!\n"; #settings

# SETTINGS 
my $settings = \%::settings;

use Bio::DBLoader;
my $loader = Bio::DBLoader->new(-settings => $settings,
								                    -dbh =>$dbh);		 
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

use Time::localtime;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)."\n";



print "##### Testing Load #####\n";

my $feat_sql = qq{INSERT INTO micro_rna_feature SET micro_rna_id = ?, feature_id = ?};
my $feat_sth = $dbh->prepare($feat_sql);
ok defined $feat_sth;

my $gene_feat_sql = qq{INSERT INTO gene_feature SET gene_id = ?, feature_id = ?};
my $gene_feat_sth = $dbh->prepare($gene_feat_sql);
ok defined $gene_feat_sth;

my $dir_sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $dir_sth = $dbh->prepare($dir_sql);
ok defined $dir_sth;



my @levels;
my %mirna;
my %mature;
my %build;
my %fam;
my %pre_fam;
my %pre_mat;
my %sym;

my %common_name = ('Homo sapiens' => 'human');
my %taxa = ('Homo sapiens' => 'Primates');
my $gene;

# get microRNA from mirna.txt
# internal_id accession name description sequence comment 

my $mir_row = qq(11981   MI0002464       hsa-mir-412     Homo sapiens miR-412 stem-loop  CUGGGGUACGGGGAUGGAUGGUCGACCAGUUGGAAAGUAAUUGUUUCUAAUGUACUUCACCUGGUCCACUAGCCGUCCGUAUCCGCUGCAG             5);
my @mirs = split /\s{2,10}/,$mir_row;
my $mir_id = $mirs[0];
my $mir_acc = $mirs[1];
my $mirna_name = $mirs[2];
my ($genere,$spec,$fam,$type) = split /\s/,$mirs[3];
my $species = $genere." ".$spec;
my $sequence = $mirs[4];
my $mirna_desc = $mirs[3].". ";
for (my $i = 5; $i <scalar @mirs; $i++){$mirna_desc .= $mirs[$i];}
ok defined $mir_id;

# get correspondence between mature e pre from mirna_pre_mature file
# mirna internal id mature internal id
my $corr_row = qq(11981   13611);
my ($pre_id,$mat_id) = split /\s{2,10}/,$corr_row;
$pre_mat{$pre_id} = $mat_id;

ok $pre_id,11981;

# get mature name  and mature range from mirna_mature.txt 
# internal id name acc  start end evidence exp similarity
my $tmp_row =qq(13611   hsa-miR-412     MIMAT0002170    54      76      not_experimental        -      MI0001164);
my ($mat_id) = split /\s{2,10}/,$tmp_row;
$mature{$mat_id} = $tmp_row;

ok $mat_id,13611;

my $mat_row = $mature{$pre_mat{$mir_id}};
my @mats = split /\s{2,10}/,$mat_row;
my $mature_name = $mats[1];
my $from = $mats[3];
my $to = $mats[4];
my $offset = $to - $from;
my $mature_acc = $mats[2];

ok $mature_acc,'MIMAT0002170';

# get coordinates from mirna_chromosome_build.txt
# mirna internal id chromosome start end strand

my $tmp_row = qq(11981   14      100601537       100601627       +);
my ($pre_id) = split /\s{2,10}/,$tmp_row;
$build{$pre_id} = $tmp_row;

ok $pre_id,11981;

my $coord_row = $build{$mir_id};
my @coords = split /\s{2,10}/,$coord_row;
my $region_name = $coords[1];
my $start = $coords[2];
my $end = $coords[3];
my $strand = $coords[4];
if ($strand eq '-'){$strand = '-1';}else{$strand = '+1';}

ok $region_name,14;

# get correspondence between mir and fam from mirna_prefam.txt
# auto_mirna  auto_prefam

my $mir_2_fam = qq(11981   1007);
my ($pre2_id,$fam_id) = split /\s{2,10}/,$mir_2_fam;
$pre_fam{$pre2_id} = $fam_id;

ok $pre2_id,11981;

# get mirna name from mirna_prefam.txt 
# auto_prefam prefam_acc prefam_id description
my $tmp_row = qq(1007    MIPF0000192     mir-412);
my ($fam2_id) = split /\s{2,10}/,$tmp_row;
$fam{$fam2_id} = $tmp_row;

ok $fam2_id, 1007;
my $prefam_row = $fam{$pre_fam{$mir_id}};
my ($prefam_id,$famacc,$fam_name) = split /\s{2,10}/,$prefam_row;

ok $prefam_id, 1007;

my $feat_desc = "mature accession number ".$mature_acc;
if (scalar @mats == 9){
  my $similarity = $mats[8];
  $feat_desc .= " similar to: $similarity";
}

my $mature_sequence = substr($sequence,$from,$offset);

ok defined length $mature_sequence;

#### 15 test ########



######################## CREATE OBJECTS ####################

my $mature_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "mature microRNA sequence"
							   );

ok defined $mature_logic_name;

my $mature_seq = Bio::Cogemir::Seq->new(
				-name => $mature_name,
				-sequence => $mature_sequence,
				-logic_name =>$mature_logic_name
				);

ok defined $mature_seq;


my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM =>'chromosome',
                -NAME => $region_name,
				        -START => $start,
				        -END => $end,
				        -STRAND => $strand
		);

ok defined $location;



my $genomes = &_load_genome_db;
my $genome_db = $genomes->{'core'};
ok defined $genome_db;

my $ens_mirna = $loader->genoinfo->search_mirna_in_ensembl_by_slice($genome_db,$location);
ok defined $ens_mirna;

my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "pre-miRNA"
							   );

ok defined $seq_logic_name;

my $mirna_seq = Bio::Cogemir::Seq->new(
				-name => $mirna_name,
				-sequence => $sequence,
				-logic_name =>$seq_logic_name
				);

ok defined $mirna_seq;

my $mirna_name_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "mirna name"
							   );

my $mirna_name_analysis =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$mirna_name_logic_name,
							    -PARAMETERS =>$famacc,
							    -CREATED =>$date
							    
							   );
				
ok defined $mirna_name_analysis;

my $mirna_name_obj = new Bio::Cogemir::MirnaName (   
									  -name           => $fam_name,
                                      -analysis       => $mirna_name_analysis,
                                      -exon_conservation => undef, #cannot say now
                                      -hostgene_conservation => undef, #cannot say now
                                      -description =>
                                    );
ok defined $mirna_name_obj;

my $attribute_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "miRNA attributes"
							   );

my $attribute_analysis =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$attribute_logic_name,
							    -PARAMETERS =>'ensembl querying, mirbase querying',
							    -CREATED =>$date
							    
							   );

my $attribute =  Bio::Cogemir::Attribute->new(   
							    -GENOME_DB              => $genome_db,
							    -SEQ                 => $mirna_seq,
							    -MIRNA_NAME          => $mirna_name_obj,
							    -ANALYSIS            => $attribute_analysis,
							    -STATUS              => $ens_mirna->status,
							    -GENE_NAME => $mirna_name,  
							    -STABLE_ID => $ens_mirna->stable_id, 
							    -EXTERNAL_NAME => $ens_mirna->external_name,
							    -DB_LINK =>"miRBase",
							    -DB_ACCESSION => $mir_acc,
							    -LOCATION => $location
							   );
ok defined $attribute;


my $host_genome_db = $genome_db;
my $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location);



my $flanking_gene;

unless ($host){
  $host_genome_db = $genomes->{'vega'};
  $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location);
  unless ($host){
    $host_genome_db = $genomes->{'otherfeatures'};
    $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location);
  }
}

if (defined $host){
  my $host_location = Bio::Cogemir::Location->new(
                  -COORDSYSTEM =>'chromosome',
                  -NAME => $location->name,
          -START => $host->start,
          -END => $host->end,
          -STRAND => $host->strand
      );
  
  ok defined $location;
  
  my ($refseq_dna,$gene_symbol,$refseq_dna_predicted,$unigene,$ucsc);
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
  
  my $aliases = Bio::Cogemir::Aliases->new(
                    -REFSEQDNA => $refseq_dna,
                    -GENESYMBOL => $gene_symbol,
                    -REFSEQDNA_PREDICTION => $refseq_dna_predicted,
                    -UNIGENE =>$unigene,
                    -UCSC => $ucsc
                  );
                  
  ok defined $aliases;
  
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
  
  ok defined $host_attribute;

  my $conservation_score;
  #$conservation_score = &_get_conservation_score($host_genome_db,$host_location);  
  ok defined $conservation_score;
 
  $gene =  Bio::Cogemir::Gene->new(   
                    -ATTRIBUTE              => $host_attribute,
                    -BIOTYPE =>$host->biotype,
                    -LABEL            => 'host',
                    -CONSERVATION_SCORE  => $conservation_score 
                   );
                   
  ok defined $gene;
}

my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE  => $attribute,
							    -SPECIFIC     => undef, #you cannot say now
							    -SEED       => undef, #you cannot say now
							    -HOSTGENE   => $gene,
							    -MATURE_SEQ => $mature_seq
							   );
							   
ok defined $micro_rna;
my $micro_rna_id = $dbh->get_MicroRNAAdaptor->store($micro_rna);
ok defined $micro_rna_id;

my ($ens_tr,$ens_p);
if (defined $gene){
  my $region_start = $location->start;
	my $region_end = $location->end;	
	
	
  foreach my $transcript (@{$host->get_all_Transcripts()}){
    my $loc_flag = 0;
	  my $label;
	  my $loc_count = 0;
	  my ($loc_pre_exon, $rank, $offset);
    $ens_tr .= $transcript->stable_id.",";
    $ens_p  .= $transcript->translation->stable_id.",";
    my $tlogic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "transcript attributes"
							   );

    my $tanalysis =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$tlogic_name,
							    -PARAMETERS =>'Bio::EnsEMBL::Transcript',
							    -CREATED =>$date
							    
							   );
		
		my $tlocation = Bio::Cogemir::Location->new(
                  -COORDSYSTEM =>'chromosome',
                  -NAME => $location->name,
          -START => $transcript->start,
          -END => $transcript->end,
          -STRAND => $host->strand
      );
      
    my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "host transcript"
							   );

    ok defined $seq_logic_name;
    
    my $transcript_seq = Bio::Cogemir::Seq->new(
            -name => $transcript->stable_id,
            -sequence => $transcript->seq->seq,
            -logic_name =>$seq_logic_name
            );
    my $tattribute =  Bio::Cogemir::Attribute->new(   
                    -GENOME_DB              => $host_genome_db,
                    -SEQ                 => $transcript_seq,
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
    
    ok defined $transcript_obj;
   
    my $exon_term ;
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
    my $label;    
    if ($region_end < $transcript->start){ 
      $label = 'out of transcript';
      $offset = $transcript->start - $region_end;
    }
    if($region_start > $transcript->end){
      $label = 'out of transcript';
      $offset = $region_start - $transcript->end;
    }
    #print $transcript->stable_id,"\t",scalar @new_exons,"\n";
    #print "INIT COUNT $count\n";
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
      my $exon_start = $exon->start;
      my $exon_end = $exon->end;
      if ($coding_start){
        if ($exon_end < $coding_start){$exon_term = 'five_prime_utr'; }
        elsif ($exon_start <= $coding_start ){$exon_term = 'five_prime_exon_noncoding_region';}
        elsif ($exon_start >= $coding_start && $exon_end <= $coding_end){$exon_term ='coding_exon';}
        elsif ($exon_end >=$coding_end){$exon_term = 'three_prime_exon_noncoding_region';}
        elsif ($exon_start > $coding_end && $exon_end > $coding_end){$exon_term = 'three_prime_utr'; }
      }
      ok defined $exon_term;
    
      unless (defined $label){
       
        #printf "mS %d mE %d tS %d eS %d eE %d tE %d\n",$region_start,$region_end,$transcript->start,$exon->start,$exon->end,$transcript->end;
        if($region_start > $exon->end ){
          if($loc_count == $flag){
              $loc_pre_exon = $exon;
              $label = "intron"; 
              $offset = $region_start - $exon->end;
              print "==>1 $label,$offset\n";
              $rank = $loc_count;
              
            }
          else{
            $loc_pre_exon = $exon;
           }
        }
        elsif($region_end < $exon->start && defined $loc_pre_exon){
          if($loc_count == $flag){
              $label = "intron";
              $offset = $exon->start - $region_end;
              print "RG $region_start EE ",$exon->end,"\n";
              print "==>2 $label,$offset\n";
              $rank = $loc_count;
              
            }
          else{
            $loc_pre_exon = $exon;
           }
          
        }
                
        elsif ($region_start >= $exon->start && $region_end <= $exon->end){
          $label = "exon"; 
          unless ($exon_term =~ /exon/){$label = 'UTR'} 
          $offset = $region_start - $exon->start;
          $rank = $loc_count;

        }
        elsif ($region_start >= $exon->start  && $region_start < $exon->end){
          $label = "exon_left";
          unless ($exon_term =~ /exon/){$label = 'UTR_left'}
          $offset = $region_start - $exon->start;
          $rank = $loc_count;
          }
        elsif ($region_end >= $exon->start  && $region_end < $exon->end){
          $label = "exon_right"; 
          unless ($exon_term =~ /exon/){$label = 'UTR_right'}
          $offset = $region_start - $exon->start;
          $rank = $loc_count;
          
          }
        elsif ($region_start <= $exon->start && $region_end >= $exon->end){
          $label = "over_exon";
          unless ($exon_term =~ /exon/){$label = 'over_UTR'}
          $offset = $region_start - $exon->start;
          $rank = $loc_count;
          
          }
        
        else{$label = "intron"; 
          $loc_pre_exon = $exon;
          $label = "intron"; 
          $offset = $region_start - $exon->end;
          print "==>3 $label,$offset\n";
          $rank = $loc_count;
        }
        
        
        
      }
      
     
      my $elogic_name =  Bio::Cogemir::LogicName->new(   
                -NAME => "exon attributes"
               );

      my $eanalysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$elogic_name,
                    -PARAMETERS =>'Bio::EnsEMBL::Exon',
                    -CREATED =>$date
                    
                   );
      
      my $elocation = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>'chromosome',
                    -NAME => $location->name,
                    -START => $exon->start,
                    -END => $exon->end,
                    -STRAND => $host->strand
        );
        
      my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => "host exon"
							   );

      ok defined $seq_logic_name;
      
      my $exon_seq = Bio::Cogemir::Seq->new(
              -name => $exon->stable_id,
              -sequence => $exon->seq->seq,
              -logic_name =>$seq_logic_name
              );  
      my $eattribute =  Bio::Cogemir::Attribute->new(   
                      -GENOME_DB              => $host_genome_db,
                      -SEQ                 => $exon_seq,
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
      ok defined $exon_obj;
      if ($count == $flag){
        if ($monoexon){$dbh->get_ExonAdaptor->store($exon_obj);last;}
        $pre_intron->length($exon_obj->start-1 - $pre_exon->end -1);
        $pre_intron->end($exon_obj->start-1);
        $pre_intron->post_exon($exon_obj);
        $dbh->get_IntronAdaptor->store($pre_intron);
        $exon_obj->pre_intron($pre_intron);
        $dbh->get_ExonAdaptor->store($exon_obj);
        last;
      }
  
      
      my $ilogic_name =  Bio::Cogemir::LogicName->new(   
                -NAME => "intron attributes"
               );

      my $ianalysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$ilogic_name,
                    -PARAMETERS =>'Bio::EnsEMBL::Exon',
                    -CREATED =>$date
                    
                   );
      
      my $ilocation = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>'chromosome',
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
      ok defined $intron;
      $exon_obj->post_intron($intron);
      if ($pre_exon_flag){
          $pre_intron->length($exon_obj->start-1 - $pre_exon->end -1);
          $pre_intron->end($exon->start-1);
          $pre_intron->post_exon($exon_obj);
          $dbh->get_IntronAdaptor->update($pre_intron);
          $exon_obj->pre_intron($pre_intron);
      }
      $dbh->get_ExonAdaptor->store($exon_obj);
      $pre_exon_flag = 1;
      $pre_exon = $exon_obj; #for pre_intron
      $pre_intron = $intron; #for next exon
       
    }
    my ($localization) =  Bio::Cogemir::Localization->new(   
              -LABEL => $label,  
              -MODULE_RANK => $rank, 
              -OFFSET => $offset,
              -TRANSCRIPT =>$transcript_obj,
              -MICRO_RNA => $micro_rna
               );
      ok defined $dbh->get_LocalizationAdaptor->store($localization);
  }
 
 
}


my $direction = 'sense';
if ($host){
  if ($ens_mirna->strand != $host->strand){$direction = 'antisense'}
  $dir_sth->execute($micro_rna->dbID, $micro_rna->hostgene->dbID,$direction);
}

unless($host){
    $flanking_gene = &_search_flanking_region($genome_db,$location);
    my ($localization) =  Bio::Cogemir::Localization->new(   
                -LABEL => "intergenic",  
                -MICRO_RNA => $micro_rna
                 );
    ok defined $dbh->get_LocalizationAdaptor->store($localization);
  }
  

####################### FEATURES #################################################

my $mat_feat_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'mature microRNA features'
							   );

ok defined $mat_feat_logic_name;

my $mat_analysis =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$mat_feat_logic_name,
							    -PARAMETERS =>'mirna_mature file parsing from miRBase 10.1 (Dec 2007)',
							    -CREATED =>$date
							   );

ok defined $mat_analysis;

my $mat_feature =  Bio::Cogemir::Feature->new(   
							    -LOGIC_NAME => $mat_feat_logic_name, 
							    -DESCRIPTION => $feat_desc,
							    -NOTE => 'none',
							    -ANALYSIS => $mat_analysis 						                                                  
							    );

ok defined $mat_feature;

my $mat_feat_id = $dbh->get_FeatureAdaptor->store($mat_feature);
ok defined $mat_feat_id;

$feat_sth->execute($micro_rna_id, $mat_feat_id);


my $mirna_desc_logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'microRNA comment'
							   );
ok defined $mirna_desc_logic_name;

my $mirna_desc_analysis =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$mirna_desc_logic_name,
							    -PARAMETERS =>'pre-microRNA description from mirna.txt file miRBase 10.1 (Dec 2007)',
							    -CREATED =>$date
							   );
ok defined $mirna_desc_analysis;

my $mirna_desc_feature =  Bio::Cogemir::Feature->new(   
							    -LOGIC_NAME => $mirna_desc_logic_name, 
							    -DESCRIPTION => $mirna_desc,
							    -NOTE => 'none',
							    -ANALYSIS => $mirna_desc_analysis 						                                                  
							    );
ok defined $mirna_desc_feature;

my $mirna_desc_feat_id = $dbh->get_FeatureAdaptor->store($mirna_desc_feature);
ok defined $mirna_desc_feat_id;

$feat_sth->execute($micro_rna_id, $mirna_desc_feat_id);

if (defined $gene){
  my $genome_db = $genomes->{'vega'};
  my $vega = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$location);
  
  my $genome_db = $genomes->{'otherfeatures'};
  my $est = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$location);
  
  if (defined $vega && $vega->strand == $strand){
    my $vega_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => 'additional vega overlapping'
                   );
    ok defined $vega_logic_name;
    
    my $vega_analysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$vega_logic_name,
                      -PARAMETERS =>'vega overlapping gene',
                      -CREATED =>$date
                     );
    ok defined $vega_analysis;
    
    my $vega_feature =  Bio::Cogemir::Feature->new(   
                      -LOGIC_NAME => $vega_logic_name, 
                      -DESCRIPTION => "evidence of vega overlapping gene for microRNA with a core hostgene",
                      -NOTE => $vega->stable_id.", ".$vega->external_name.", ".$vega->slice->name,
                      -ANALYSIS => $vega_analysis 						                                                  
                      );
    ok defined $vega_feature;
    
    my $vega_feat_id = $dbh->get_FeatureAdaptor->store($vega_feature);
    ok defined $vega_feat_id;
    
    $gene_feat_sth->execute($gene->dbID, $vega_feat_id);
  }
  
  if (defined $est && $est->strand == $strand){
    my $est_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => 'additional est overlapping'
                   );
    ok defined $est_logic_name;
    
    my $est_analysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$est_logic_name,
                      -PARAMETERS =>'est overlapping gene',
                      -CREATED =>$date
                     );
    ok defined $est_analysis;
    
    my $est_feature =  Bio::Cogemir::Feature->new(   
                      -LOGIC_NAME => $est_logic_name, 
                      -DESCRIPTION => "evidence of est overlapping gene for microRNA with a core hostgene",
                      -NOTE => $est->stable_id.", ".$est->slice->name,
                      -ANALYSIS => $est_analysis 						                                                  
                      );
    ok defined $est_feature;
    
    my $est_feat_id = $dbh->get_FeatureAdaptor->store($est_feature);
    ok defined $est_feat_id;
    
    $gene_feat_sth->execute($gene->dbID, $est_feat_id);
  }
  
  if ($direction eq 'sense'){
    my $rev_location = $location;
    $rev_location->strand(-1 * ($location->strand));
    my $reverse_gene = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$rev_location);
    if ($reverse_gene->strand != $strand){
      my $rev_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => 'additional reverse overlapping'
                     );
      ok defined $rev_logic_name;
      
      my $rev_analysis =  Bio::Cogemir::Analysis->new(       
                        -LOGIC_NAME =>$rev_logic_name,
                        -PARAMETERS =>'reverse overlapping gene',
                        -CREATED =>$date
                       );
      ok defined $rev_analysis;
      
      my $rev_feature =  Bio::Cogemir::Feature->new(   
                        -LOGIC_NAME => $rev_logic_name, 
                        -DESCRIPTION => "evidence of reverse overlapping gene for microRNA with a core hostgene",
                        -NOTE => $reverse_gene->stable_id.", ".$reverse_gene->external_name.", ".$reverse_gene->slice->name,
                        -ANALYSIS => $rev_analysis 						                                                  
                        );
      ok defined $rev_feature;
      
      my $rev_feat_id = $dbh->get_FeatureAdaptor->store($rev_feature);
      ok defined $rev_feat_id;
      
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
  
    ok defined $fg_feat_logic_name;
    
    my $fg_analysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$fg_feat_logic_name,
                      -PARAMETERS =>$up." bp upstream and ".$down." downstream microRNA regions",
                      -CREATED =>$date
                     );
    
    ok defined $mat_analysis;
    
    
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
    ok defined $fg_feature;
    
    my $fg_feat_id = $dbh->get_FeatureAdaptor->store($fg_feature);
    ok defined $fg_feat_id;
  
    $feat_sth->execute($micro_rna_id, $fg_feat_id);
  }
}
########################## SUBROUTINE #######################################################

sub _load_genome_db {
  
  my $user = 'ens';
  my $pass = undef;
  my $ensdbh = DBI->connect("DBI:mysql:database=ensembl_compara_48;host=192.168.3.252;port=3306", $user, $pass) || die "Can't connect: ";
  my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl_config/registry_config.pl");
  my $query = qq{show databases};
  my $sth = $ensdbh->prepare($query);
  $sth->execute;
  my $tquery = qq{SELECT taxon_id, name FROM genome_db};
  my $enssth = $ensdbh->prepare($tquery) || die $ensdbh->errstr; 
  use Bio::Cogemir::GenomeDB;
  my $db_ref;
  while (my $db = $sth->fetchrow_array){ 
    next unless ($db =~ /homo/ &&( $db =~ /core/ || $db =~ /vega/ || $db =~ /otherfeatures/) && $db =~ /48_/);
    my ($genere, $species,$db_type,$rel,$ass) = split /_/,$db;
    next unless $genere =~ /homo/;
    $enssth->execute() || die $sth->errstr;
    while(my $fetch = $enssth->fetchrow_hashref){
      my $organism = $fetch->{'name'};
      my $taxon_id = $fetch->{'taxon_id'};
      next unless $fetch->{'name'} =~ /$species/; 
      my $genome_adaptor = $dbh->get_GenomeDBAdaptor;
      my $db_host = '192.168.3.252';
      my $genome_obj = Bio::Cogemir::GenomeDB->new(
                               -TAXON_ID => $taxon_id,
                               -ORGANISM => $organism,
                               -DB_HOST => $db_host,
                               -DB_NAME => $db,
                               -DB_TYPE => $db_type,
                               -COMMON_NAME =>$common_name{$organism},
                               -TAXA =>$taxa{$organism}
                              );		
      my $genome_dbID = $genome_adaptor->store($genome_obj);
      $db_ref->{$db_type} = $genome_obj;
    }
   
  }
  return $db_ref;
}

sub _get_conservation_score{
  my ($db,$location) = @_;
  use Bio::EnsEMBL::Registry;
  use Bio::EnsEMBL::Utils::Exception qw(throw);
  use Statistics::Descriptive::Discrete;
  my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl-config/registry_config.pl") || die $!;
  my $species = $db->organism;
  my $seq_region = $location->name;
  my $seq_region_start = $location->start;
  my $seq_region_end =  $location->end;
  
  my $species = "Homo sapiens";
  
  #get slice adaptor for $species
  my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor($species, $db->db_type, 'Slice');
  throw("Registry configuration file has no data for connecting to <$species>") if (!$slice_adaptor);
  ok defined $slice_adaptor;
  
  #create slice 
  my $slice = $slice_adaptor->fetch_by_region('toplevel', $seq_region, $seq_region_start, $seq_region_end);
  throw("No Slice can be created with coordinates $seq_region:$seq_region_start-$seq_region_end") if (!$slice);
  ok defined $slice;
 
  #get method_link_species_set adaptor
  my $mlss_adaptor = Bio::EnsEMBL::Registry->get_adaptor("Multi", "compara", "MethodLinkSpeciesSet");
  throw("no Adaptor for \"Multi\", \"compara\", \"MethodLinkSpeciesSet\"") if (!$mlss_adaptor);
  ok defined $mlss_adaptor;  
  
  #get the method_link_species_set object for GERP_CONSERVATION_SCORE for 10 species
  my $mlss = $mlss_adaptor->fetch_by_method_link_type_registry_aliases("GERP_CONSERVATION_SCORE", ["human", "chimpanzee", "rhesus", "cow", "dog", "mouse", "rat", "opossum", "platypus", "chicken"]);
  ok defined $mlss;  
 
  #get conservation score adaptor
  my $cs_adaptor = Bio::EnsEMBL::Registry->get_adaptor("Multi", 'compara', 'ConservationScore');	
  ok defined $cs_adaptor;  #To get one score per base in the slice, must set display_size to the size of
  #the slice.
  my $display_size = $slice->end - $slice->start + 1; 
  my $scores = $cs_adaptor->fetch_all_by_MethodLinkSpeciesSet_Slice($mlss, $slice, $display_size);
  print "number of scores " . @$scores . "\n";
  
  #print out the position, observed, expected and difference scores.
  my ($cons,$ncons);
  my @cons;
  my @mat_cons_values;
  foreach my $score (@$scores) {
    #print Dumper $score;
    if (defined $score->diff_score) {
      $cons ++ if $score->observed_score < $score->expected_score;
      $ncons ++ if $score->observed_score > $score->expected_score;
      push (@cons, $score->position) if $score->observed_score < $score->expected_score;
    }
  }
  
  my $cons = "NP $display_size,CP $cons, NCP $ncons";
  print $cons,"\n";
  return $cons;
}


sub _search_flanking_region{
  ($genome_db,$location) = @_;
  
  my %ret;
  my $start = $location->start;
  my $end = $location->end;
  
  my $up_location = $location;
  my $up_plus = 1;
  $up_location->start($start - $up_plus);
  $up_location->end($start);
  my $upgene = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$up_location);
  while ($up_plus < 100000){
    unless ($upgene){
      $up_plus += 10000;
      $up_location->start($start - $up_plus);
      $up_location->end($start);
      $upgene = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$up_location);
    }
    else {
      last;
    }
    print "UP PLUS $up_plus\n";
  }
  print "UP ",$upgene->external_name."\n";
  $ret{'upgene'} = $upgene;
  $ret{'up'} = ($start - $upgene->slice->end) if $upgene;
  
  my $down_location = $location;
  my $down_plus = 1;
  
  $down_location->start($start + ($end - $start) + 1);
  $down_location->end($end + $down_plus);
  my $downgene =  $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$down_location);
  while ($down_plus < 100000){
    unless ($downgene){
      $down_plus += 10000;
      $down_location->start($start + ($end - $start) + 1);
      $down_location->end($end + $down_plus);
      $downgene = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$up_location);
    }
    else {
      last;
    }
    print "DOWN PLUS $down_plus\n";
  }
  print "DOWN ",$downgene->external_name."\n" if $downgene;
  $ret{'downgene'} = $downgene;
  $ret{'down'} = ($downgene->slice->start - $end) if $downgene;
  
  return \%ret;
}  