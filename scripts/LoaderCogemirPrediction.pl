# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;
use File::Spec;


use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use lib "$ENV{'HOME'}/src/mirnadb/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl_compara/modules";

use Bio::Cogemir::DBSQL::DBAdaptor;


do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings
my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-pass => $::settings{'pass'},
								-dbname => $::settings{'dbname'},
								-verbose => 1,
								-quick => 1
								);
# SETTINGS 
my $settings = \%::settings;
use Bio::DBLoader;
my $loader = Bio::DBLoader->new(-settings => $settings,
								                    -dbh =>$dbh);		

use Bio::MIRNADB::DBSQL::DBAdaptor;								                    
my $mirnadbh = Bio::MIRNADB::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-pass => $::settings{'pass'},
								-dbname => 'mirnadb42c',
								-verbose => 1,
								-quick => 1
								);

  


 
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
use Bio::Cogemir::Blast;
use Bio::Cogemir::Hsp;
use Bio::Cogemir::Hit;

use Time::localtime;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)."\n";

print "##### Testing Load #####\n";

open (OUT, ">>list_mir_blast.txt");
my $feat_sql = qq{INSERT INTO micro_rna_feature SET micro_rna_id = ?, feature_id = ?};
my $feat_sth = $dbh->prepare($feat_sql);

my $gene_feat_sql = qq{INSERT INTO gene_feature SET gene_id = ?, feature_id = ?};
my $gene_feat_sth = $dbh->prepare($gene_feat_sql);

my $dir_sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $dir_sth = $dbh->prepare($dir_sql);

my @levels;
my %mirna;
my %mature;
my %build;
my %fam;
my %pre_fam;
my %pre_mat;
my %sym;
my %species;
my %common_name = ('Homo sapiens' => 'human');
#'Primates','Rodentia','Mammalia','Marsupials','Aves','Amphibia','Pisces','Tunicates','Arthropoda','Nematoda','Yeast'
my %taxa = ('Homo sapiens' => 'Primates',
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
            'Drosophila melanogaster' => 'Arthropoda',
            'Echinops telfairi' => 'Mammalia',
            'Erinaceus europaeus' => 'Mammalia',
            'Felis catus' => 'Mammalia',
            'Gasterosteus aculeatus' => 'Pisces',
            'Gallus gallus' => 'Aves',
            'Gasterosteus aculeatus' => 'Pisces' ,
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
            'Rattus norvegicus' => 'Rodentia',
            'Saccharomyces cerevisiae' => 'Yeast',
            'Sorex araneus' => 'Mammalia',
            'Spermophilus tridecemlineatus' =>'Rodentia',
            'Takifugu rubripes' => 'Pisces',
            'Tetraodon nigroviridis' => 'Pisces',
            'Tupaia belangeri' => 'Rodentia',
            'Xenopus tropicalis' => 'Amphibia'
          );



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
my $idx = 0;
my $pred = shift @ARGV;
die unless defined $pred;

my $sql = qq{select attribute_id from attribute where gene_name = ?};
my $sth = $dbh->prepare($sql);
foreach my $pred_mirna (@{$mirnadbh->get_MicroRNAAdaptor->fetch_all_by_status($pred)}){
  $idx ++;
  print $idx." ".$pred_mirna->gene_name."\n";
  $sth->execute($pred_mirna->gene_name);
  my $id = $sth->fetchrow;
  next if defined $id;
  next if $pred_mirna->gene_name eq 'cfa-mir-599';
#   next if $pred_mirna->gene_name eq 'bta-mir-31';
#   next if $pred_mirna->gene_name eq 'bta-mir-210';
  #my $ext_mir = $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($pred_mirna->gene_name);
  #if ($ext_mir){
    #$dbh->get_MicroRNAAdaptor->remove($ext_mir);
   # next ;
  #}
  my $mirna = $pred_mirna->mirna_name;
  my $mirna_name = $pred_mirna->gene_name;
  #next if $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($mirna_name);
  my $species = $pred_mirna->organism;
  my $coord_sys = 'chromosome';
  if ($sl_test{$species}){$coord_sys = 'SeqLevel'}
  print "MIR $mirna_name\n";
  my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
  my $location = Bio::Cogemir::Location->new(
                  -COORDSYSTEM =>$coord_sys,
                  -NAME => $pred_mirna->location->name,
                  -START => $pred_mirna->location->start,
                  -END => $pred_mirna->location->end,
                  -STRAND => $pred_mirna->location->strand
      );
  my $mirna_name_obj = $dbh->get_MirnaNameAdaptor->fetch_by_name($mirna);
  unless (defined $mirna_name_obj){

    my $mirna_name_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => "mirna name"
                     );
    my $mirna_name_like = $mirna;
    $mirna_name_like =~ s/[a-z]$//;
    print "$mirna_name_like\n";

    my $mirna_like = $dbh->get_MirnaNameAdaptor->fetch_by_name($mirna_name_like); 
    my ($param, $family_name);
    if ($mirna_like){
      $param = $mirna_like->analysis->parameters;
      $family_name = $mirna_like->family_name }
    else{$param = 'none';}

        
    my $mirna_name_analysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$mirna_name_logic_name,
                      -PARAMETERS =>$param,
                      -CREATED =>$date
                      
                     );
              
    $mirna_name_obj = new Bio::Cogemir::MirnaName (   
                                          -name           => $mirna,
                                          -analysis       => $mirna_name_analysis,
                                          -exon_conservation => undef, #cannot say now
                                          -hostgene_conservation => undef, #cannot say now
                                          -description =>undef,
                                          -family_name =>$family_name
                                        );
  }
  print "$mirna\n";
  my $ens_mirna = $loader->genoinfo->search_mirna_in_ensembl_by_slice($genome_db,$location);
  my $status;
  my ($mirna_stable_id, $mirna_external, $sequence,$attribute,$parameters,$accession);
  my ($start, $end,$strand);
  my ($seqlevel,$release,$region_name,$tag);
  if($ens_mirna){
    $status = 'E PREDICTION';
    $mirna_stable_id = $ens_mirna->stable_id;
    $mirna_external = $ens_mirna->external_name;
    printf "$mirna_stable_id\t$mirna_external\t%s\n",$ens_mirna->seq;
    $sequence = $ens_mirna->seq;
    $attribute = "EnseEMBL predicted miRNA attributes";
    $parameters = 'ensembl querying';
    $start = $ens_mirna->start;
    $end = $ens_mirna->end;
    $strand = $ens_mirna->strand;
    $accession = $ens_mirna->dbID;
    ($seqlevel,$release,$region_name,$tag)  = split /:/, $ens_mirna->slice->name; 
  }
  else{
  	
  	$status = $pred;
    $mirna_stable_id = $pred_mirna->stable_id;
    $mirna_external = $pred_mirna->member->external_name;
    $sequence = $pred_mirna->attribute->seq->sequence;
    $attribute = "Cogemir predicted"; 
    $parameters = 'best reciprocal blast ';
    $start = $pred_mirna->location->start;
    $end = $pred_mirna->location->end;
    $strand = $pred_mirna->location->strand;
    $accession = $pred_mirna->dbID;
    $region_name = $pred_mirna->location->name;
  }
  my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "pre-miRNA"
                   );
    
  my $mirna_seq = Bio::Cogemir::Seq->new(
          -name => $mirna_name,
          -sequence => $sequence,
          -logic_name =>$seq_logic_name
          );
  my $attribute_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => $attribute
                   );
  
  my $attribute_analysis =  Bio::Cogemir::Analysis->new(       
                    -LOGIC_NAME =>$attribute_logic_name,
                    -PARAMETERS =>$parameters,
                    -CREATED =>$date
                    
                   );
 
  
   
  
  my $location = Bio::Cogemir::Location->new(
                  -COORDSYSTEM =>$coord_sys,
                  -NAME => $region_name,
                  -START =>$start ,
                  -END => $end,
                  -STRAND => $strand
      );
 
  my $attribute =  Bio::Cogemir::Attribute->new(   
                    -GENOME_DB              => $genome_db,
                    -SEQ                 => $mirna_seq,
                    -MIRNA_NAME          => $mirna_name_obj,
                    -ANALYSIS            => $attribute_analysis,
                    -STATUS              => $status,
                    -GENE_NAME => $mirna_name,  
                    -STABLE_ID => $mirna_stable_id, 
                    -EXTERNAL_NAME => $mirna_external,
                    -DB_LINK =>"EnsEMBL",
                    -DB_ACCESSION => $accession,
                    -LOCATION => $location
                   );  
  
  my $host_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
  unless (defined $host_genome_db){throw("no genome db for $species");next;}
  my $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location); 
  #unless (defined $host){warn("host for $mirna_name not defined in ensembl")} 
  my $flanking_gene;
   
  unless ($host){
    $host_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'vega');
    $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location);
    unless ($host){
      $host_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'otherfeatures');
      $host = $loader->genoinfo->search_host_in_ensembl_by_slice($host_genome_db,$location);
    }
  }
  my $gene;
  my $direction = 'sense';
  if ($host){
    if ($strand != $host->strand){$direction = 'antisense'}
  }
  if ($host){
    my $host_location = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $location->name,
            -START => $host->start,
            -END => $host->end,
            -STRAND => $host->strand
        );
    $dbh->get_LocationAdaptor->store($host_location);
    print "H LOC ",$host_location->dbID,"\n";
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
  my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
                    -ATTRIBUTE  => $attribute,
                    -SPECIFIC     => undef, #you cannot say now
                    -SEED       => undef, #you cannot say now
                    -HOSTGENE   => $gene,
                    -MATURE_SEQ => undef
                   );
                   
  my $micro_rna_id = $dbh->get_MicroRNAAdaptor->store($micro_rna);
  $dir_sth->execute($micro_rna->dbID, $micro_rna->hostgene->dbID,$direction) if $host;
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
       $dbh->get_LocationAdaptor->store($tlocation); 
      my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "host transcript"
                   );
        
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
      $dbh->get_AttributeAdaptor->store($tattribute);               
      my $transcript_obj =  Bio::Cogemir::Transcript->new(   
                        -PART_OF => $gene,
                        -ATTRIBUTE =>$tattribute
                       );
      $dbh->get_TranscriptAdaptor->store($transcript_obj); 
      #print "TRAN LOC ID ",$tlocation->dbID,"\n";
      print $transcript_obj->dbID," ",$transcript_obj->stable_id,"\n";
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
        my $exon_start = $exon->start;
        my $exon_end = $exon->end;
        if ($coding_start){
          if ($exon_end < $coding_start){$exon_term = 'five_prime_utr'; }
          elsif ($exon_start <= $coding_start ){$exon_term = 'five_prime_exon_noncoding_region';}
          elsif ($exon_start >= $coding_start && $exon_end <= $coding_end){$exon_term ='coding_exon';}
          elsif ($exon_end >=$coding_end){$exon_term = 'three_prime_exon_noncoding_region';}
          elsif ($exon_start > $coding_end && $exon_end > $coding_end){$exon_term = 'three_prime_utr'; }
        }
        else{$exon_term ='noncoding_exon'}
        unless (defined $exon_term){
          printf "CS %d CE %d ES %d EE %d\n",$coding_start,$coding_end,$exon_start,$exon_end;
          exit;
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
                      -COORDSYSTEM =>$coord_sys,
                      -NAME => $location->name,
                      -START => $exon->start,
                      -END => $exon->end,
                      -STRAND => $host->strand
          );
        $dbh->get_LocationAdaptor->store($elocation);  
        my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                    -NAME => "host exon"
                   );
          
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
              $dbh->get_AttributeAdaptor->store($eattribute);               

        my $exon_obj =  Bio::Cogemir::Exon->new(   
                          -PART_OF => $transcript_obj, 
                          -RANK => $count, 
                          -LENGTH => ($exon_end - $exon_start + 1),
                          -PHASE => $exon->phase,
                          -ATTRIBUTE => $eattribute,
                          -TYPE => $exon_term
                          );
        $dbh->get_ExonAdaptor->store($exon_obj);
        #print "E LOC ",$elocation->dbID,"\n";
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
        $dbh->get_LocationAdaptor->store($ilocation);
        my $iattribute =  Bio::Cogemir::Attribute->new(   
                        -GENOME_DB              => $host_genome_db,
                        -MIRNA_NAME          => $mirna_name_obj,
                        -ANALYSIS            => $ianalysis,
                        -GENE_NAME => $mirna_name."_intron",  
                        -DB_LINK =>"EnsEMBL",
                        -LOCATION => $ilocation,
                        -STATUS =>$tattribute->status
                       );
              $dbh->get_AttributeAdaptor->store($iattribute);               

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
  unless($host){
    $flanking_gene = &_search_flanking_region($genome_db,$location);
    print "LABEL intergenic\n";
    
		my ($localization) =  Bio::Cogemir::Localization->new(   
							 -LABEL => "intergenic",  
							 -MICRO_RNA => $micro_rna
								);
		$dbh->get_LocalizationAdaptor->store($localization);
    
  }
  
  
  ####################### FEATURES #################################################    
    
  if (defined $gene){
    my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'vega');
    my $vega = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$location);
    
    my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'otherfeatures');
    my $est = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$location);
    
    if (defined $vega  && $vega->strand == $strand){
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
                        -DESCRIPTION => "evidence of vega overlapping gene for microRNA with a core hostgene",
                        -NOTE => $vega->stable_id.", ".$vega->external_name.", ".$vega->slice->name,
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
                        -DESCRIPTION => "evidence of est overlapping gene for microRNA with a core hostgene",
                        -NOTE => $est->stable_id.", ".$est->slice->name,
                        -ANALYSIS => $est_analysis 						                                                  
                        );
      
      my $est_feat_id = $dbh->get_FeatureAdaptor->store($est_feature);
      
      $gene_feat_sth->execute($gene->dbID, $est_feat_id);
    }
    
    if ($direction eq 'sense'){
      my $rev_location = $location;
      $rev_location->strand(-1 * ($location->strand));
      my $reverse_gene = $loader->genoinfo->search_host_in_ensembl_by_slice($genome_db,$rev_location);
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
                          -DESCRIPTION => "evidence of reverse overlapping gene for microRNA with a core hostgene",
                          -NOTE => $reverse_gene->stable_id.", ".$reverse_gene->external_name.", ".$reverse_gene->slice->name,
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
    
      $feat_sth->execute($micro_rna_id, $fg_feat_id);
    }
  }
  
  my @hits = @{$pred_mirna->member->hit} if $pred_mirna->member->hit;
	foreach my $hit (@hits){
		my $blast = $hit->blast;
		my $blast_logic_name =  Bio::Cogemir::LogicName->new(   
                      -NAME => 'blastn'
                     );
    my $ln;
		if ($pred =~ /HC/){$ln = 'high confidence prediction'}
		if ($pred =~ /LC/){$ln = 'low confidence prediction'}
		if ($pred =~ /E PRE/){$ln = 'ensembl prediction'}
		my $f_logic_name =  Bio::Cogemir::LogicName->new(   
										-NAME => $ln
									 );
						
		my $blast_analysis =  Bio::Cogemir::Analysis->new(       
											-LOGIC_NAME =>$blast_logic_name,
											-PARAMETERS =>"blastn -mformat 3 -E 10 -W 15 -M 1 -N -3 -Q 3 -R 3 -filter dust warnings cpus 2 sort_by_totalscore",
											-CREATED =>$date
										 );
		
		my $blast_feature =  Bio::Cogemir::Feature->new(   
										-LOGIC_NAME => $f_logic_name, 
										-DESCRIPTION => $hit->blast->feature->description,
										-NOTE => 'from previous cogemir release',
										-ANALYSIS => $blast_analysis 						                                                  
										);
		$dbh->get_FeatureAdaptor->store($blast_feature);
		#print Dumper $blast_feature;
		my $new_blast = Bio::Cogemir::Blast->new(
																	-feature => $blast_feature,
																	-logic_name_id => $blast_logic_name,
																	-length => $hit->blast->length
																	);
		my $blast_id = $dbh->get_BlastAdaptor->store($new_blast);
		print OUT $micro_rna->gene_name." $blast_id \n";
		my $new_hit = Bio::Cogemir::Hit->new(
												-blast =>$new_blast,
												-feature => $blast_feature
										);
		$dbh->get_HitAdaptor->store($new_hit);
		
		my @hsps = @{$mirnadbh->get_HspAdaptor->fetch_by_hit_id($hit->dbID)};
		foreach my $hsp(@hsps){
			
			my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
												-NAME => "pre-miRNA"
											 );
			
			my $hseq = $micro_rna->attribute->seq;
			$dbh->get_SeqAdaptor->store($hseq);
			
			my $new_hsp = Bio::Cogemir::Hsp->new(
													-hit => $hit,
													-percent_identity => $hsp->percent_identity,
													-length => $hsp->length,
													-p_value => $hsp->p_value,
													-seq => $hseq,
													-start => $hsp->start,
													-end => $hsp->end
											);
			$dbh->get_HspAdaptor->store($new_hsp);
		}
		
		$feat_sth->execute($micro_rna_id, $blast_feature->dbID);
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
  my $tquery = qq{SELECT distinct(n.name) as common, g.taxon_id,g.name, n.name_class FROM genome_db g, ncbi_taxa_name n WHERE n.taxon_id = g.taxon_id AND n.name_class like ?};
  my $enssth = $ensdbh->prepare($tquery) || die $ensdbh->errstr; 
  use Bio::Cogemir::GenomeDB;
  my $db_ref;
  while (my $db = $sth->fetchrow_array){ 
    next unless (( $db =~ /core/ || $db =~ /vega/ || $db =~ /otherfeatures/) && $db =~ /48_/);
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
                               -TAXA =>$taxa{$organism}
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
    #print "UP PLUS $up_plus\n";
  }
  #print "UP ",$upgene->external_name."\n" if $upgene;
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
    #print "DOWN PLUS $down_plus\n";
  }
  #print "DOWN ",$downgene->external_name."\n" if $downgene;
  $ret{'downgene'} = $downgene;
  $ret{'down'} = ($downgene->slice->start - $end) if $downgene;
  
  return \%ret;
} 


sub _get_build {
  my ($file) = @_;
  my %gen;
  while (my $row = <FH>){
		chomp $row;
		if ($row =~ /^#/){next;}
		#1	.	miRNA	1092347	1092441	.	+	.	ACC="MI0000342"; ID="hsa-mir-200b";
		my ($region,$dot,$type,$start,$end,$dot2,$strand,$dot3,$identifier) = split /\t/, $row;
		my $identifier = shift @_;
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

