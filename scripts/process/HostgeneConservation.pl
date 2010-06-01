#! /usr/bin/perl -w

=head1 NAME
	
LoadHomologous

=head1 DESCRIPTION 

This script search for homologus host gene, load the gene and see the conservation

=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=head2 HOW IT WORKS

  take a family_name from STDIN (Actually it is called by another script : LoadHomologousFamily)
  create a pool of micro_rna present in the family
  search for a list of homologous genes
  analyze the conservation
  
  skipping the EST and vega genes
  where the hostgene is not defined searching for flanking gene
  where the hostgene is not conserved search for other overlapping gene or flanking gene

=cut

use strict;
use vars;
use Data::Dumper;

use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl_compara/modules";

use Bio::Root::Root;
use Bio::EnsEMBL::Registry;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Homologs;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Cogemir::Feature;
use Bio::Cogemir::Localization;
use Time::localtime;
my $debug = 1;

$| = 1;		

open (LOG,">>log.txt") || die $!;

open (SC,">>score.txt") || die $!;
do ("$ENV{'HOME'}/src/cogemir/data/configfile.pl") or die "$!\n"; #settings
my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1,
								-quick => 1
								);

# SETTINGS 
my $settings = \%::settings;

use Bio::DBLoader;
my $loader = Bio::DBLoader->new(-settings => $settings,
								                    -dbh =>$dbh);		 
use Time::localtime;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)."\n";    

my $feat_sql = qq{INSERT INTO micro_rna_feature SET micro_rna_id = ?, feature_id = ?};
my $feat_sth = $dbh->prepare($feat_sql);

my $gene_feat_sql = qq{INSERT INTO gene_feature SET gene_id = ?, feature_id = ?};
my $gene_feat_sth = $dbh->prepare($gene_feat_sql);

my $dir_sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $dir_sth = $dbh->prepare($dir_sql);



my %seen_name;
my %seen_tag;
my %seen_species;
my %seen_properly_species;


my %reference_species = (
                          'Homo sapiens' => 1,
                          'Mus musculus' => 1,
                          'Rattus norvegicus' =>1,
                          'Gallus gallus' => 1,
                          'Xenopus tropicalis' => 1,
                          'Takifugu rubripes' =>1,
                          'Danio rerio' => 1
                        );


my $family_name = shift @ARGV;
open (OUT,">>".$family_name."_out.xls") || die $!;
#$micro_rna->mirna_name,$micro_rna->gene_name,$micro_rna->organism,$host_string,"-",0,$conservation, "NS";
print OUT "MIRNA\tMIR\tSPECIES\tHOST\tHOM TYPE\tTAG\tCONSERVATION TYPE\n";
my @all_name = @{$dbh->get_MirnaNameAdaptor->fetch_all_name_by_family_name($family_name)};

my %seen_conserved_species;
my %seen_pair;
my %seen_host_for_species;
my %seen_microrna;
my %seen;
my %tag_4_conservation;

my @genes;
my @micro_rnas;
my $conservation = 0; 
my $total = 0;
my $cons;

print LOG "====================== FAMILY NAME ".uc($family_name)."======================\n"; #mir-204

#creo un array con tutti i micro_rna per tutte le specie che fanno parte della famiglia
foreach my $name (@all_name){
  next if $seen_name{$name};
  my @names = @{$dbh->get_MirnaNameAdaptor->fetch_by_name_like($name)};
  foreach my $mirna_name (@names){ #mir-204, mir-204a,mir-211, mir-211a
    $seen_name{$mirna_name->name} ++;
    foreach my $micro (@{$mirna_name->mirnas}){
      if ($micro->hostgene){
        $seen_properly_species{$micro->hostgene->organism} ++; #setto le specie di cui guardare gli omologhi
        if ($micro->hostgene->db->db_type eq 'core'){$total ++}
        push (@genes,$micro->hostgene);
      }
      push (@micro_rnas, $micro);
    }
  }  
}
unless($total){print LOG "$family_name is totally intergenic\n"}
else{
  foreach my $micro_rna (@micro_rnas){
    my @test_names;
    next if $seen_microrna{$micro_rna->gene_name};
    print  LOG "\n============================================ MIR ".$micro_rna->gene_name."\n";
    my $hom_list;
    my $hoststring;
    my $hostgene = $micro_rna->hostgene;
    if ($hostgene){
      next if $hostgene->db->db_type ne 'core';
      my $ensgene = $loader->genoinfo->search_in_ensembl_by_stable_id($hostgene->db,$hostgene->stable_id);
      $hom_list = &_test_homolog($ensgene); 
      unless($hom_list){ 
        #il gene hon e' omologo
        print LOG "the hostgene ".$hostgene->attribute->external_name." is not homologs\n";
        $hom_list = &_test_npd($hostgene);
        unless($hom_list){
          
          print  LOG "there are no other overlapping gene\n";
          #$hom_list = &_search_flanking_region($hostgene);
          unless ($hom_list){ 
            #non ci sono geni fiancheggianti omologhi
            #print "there are no flanking gene\n";
            &_print_in_file($micro_rna,0,"NA",$conservation);
            next;
          }
        }
      }
    }
    
    else{
      #$hom_list = &_search_flanking_region($micro_rna);
      #unless ($hom_list){
        #non ci sono geni fiancheggianti omologhi
        #print "there are no flanking gene for integenic microRNA\n";
        &_print_in_file($micro_rna,0,"Intergenic",$conservation);
        next;
      #}
    }
    print LOG "the hostgene ".$hostgene->attribute->external_name." is omologs\n";
    $conservation ++;
    my $gene_name = $hostgene->attribute->external_name;
    unless ($gene_name){$gene_name = $hostgene->stable_id}
    $gene_name = uc($gene_name);
    if ($gene_name =~ /_/){my ($tmp) = split /_/, $gene_name;$gene_name = $tmp;}
    my $name_for_pair = $micro_rna->attribute->mirna_name->name;
    $name_for_pair =~ s/(\-\d)$//;
    $name_for_pair =~ s/[a-z]$//;
    $seen_pair{$name_for_pair}{$gene_name} ++;
    &_print_in_file($micro_rna,1,"starting_one",$conservation);
    $seen_microrna{$micro_rna->gene_name} ++;
    $seen_conserved_species{$micro_rna->organism} ++;
    $seen_host_for_species{$micro_rna->organism}{$gene_name}++;
    print OUT "start homolog list $gene_name\n";
    my $starting_name = $gene_name;
    my $tagged = 0;
    foreach my $test_name (@test_names){
      print LOG "TEST is $test_name\n";
      $tagged = 1 if $starting_name =~ $test_name;
    }
    $conservation = 0 unless $tagged;
    my @gene_names;
    foreach my $all_homs(@{$hom_list}){
      my ($gene, $compara,$species) = @{$all_homs};
      my $foundgene = $dbh->get_GeneAdaptor->fetch_by_stable_id($gene->stable_id);
      $foundgene->attribute->external_name($gene->external_name);
      my $hgene_name = $foundgene->attribute->external_name;
      unless ($hgene_name){$hgene_name = $foundgene->stable_id}
      $hgene_name = uc($hgene_name);
      if ($hgene_name =~ /_/){my ($tmp) = split /_/, $hgene_name;$hgene_name = $tmp;} 
      next if $seen_host_for_species{$species}{$hgene_name};
      my $mir;
      my @mirs = @{$dbh->get_MicroRNAAdaptor->fetch_by_hostgene_organism($gene->stable_id, $species)};
      foreach my $item(@mirs){  
        $mir = $item if $item->attribute->mirna_name->family_name eq $micro_rna->attribute->mirna_name->family_name;

      }
      next unless $mir;
      next if $seen_microrna{$mir->gene_name};
      #printf "%s %s\n", substr($hgene_name,0,3),substr($starting_name,0,3);
      if (substr($hgene_name,0,3) ne substr($starting_name,0,3)){
        #print "$hgene_name cmp $starting_name --> ";
        $foundgene->attribute->external_name($starting_name."_like");
        $foundgene->attribute->adaptor->update($mir->hostgene->attribute);
        $hgene_name = $starting_name;
        #print "$hgene_name\n";
      }

      push (@gene_names, $hgene_name);
#print "$species\t$hgene_name === $gene_name\n";
      $conservation ++;
      my $name_4_pair = $mir->attribute->mirna_name->name;
      $name_4_pair =~ s/(\-\d)$//;
      $name_4_pair =~ s/[a-z]$//;
      $seen_pair{$name_4_pair}{$gene_name} = $conservation;
      
      
      &_print_in_file($mir,1,$compara->description,$conservation);
      $seen_microrna{$mir->gene_name} ++;
      $seen_conserved_species{$species} ++;
      $seen_host_for_species{$species}{$gene_name}++;
      
      my $logic_name_obj = $dbh->get_LogicNameAdaptor->fetch_by_name('ensembl homologs');
      unless ($logic_name_obj){$logic_name_obj =  Bio::Cogemir::LogicName->new(-NAME => 'ensembl homologs');}
    
      my $parameters =  $compara->print_homology;
    
      my $analysis = Bio::Cogemir::Analysis->new(
                                  -LOGIC_NAME =>$logic_name_obj,
                                  -PARAMETERS =>$parameters,
                                  -CREATED =>$date
                  );
      $dbh->get_AnalysisAdaptor->store($analysis);
      my $homologs = Bio::Cogemir::Homologs->new(
          -query_gene => $micro_rna->hostgene,
          -target_gene => $mir->hostgene,
          -type => $compara->description,
          -analysis => $analysis
          );
      $dbh->get_HomologsAdaptor->store($homologs);
      
    }  
    print OUT "end omolog list\n";
    @test_names = @gene_names;
    $conservation = 0;
  }
  foreach my $micro_name (keys %seen_pair){
    foreach my $gene_name(keys %{$seen_pair{$micro_name}}){
      my $conservation = $seen_pair{$micro_name}{$gene_name};
      my $ratio = $conservation/$total if $total;
      $ratio = 0 unless $total;
      my $spec_ref = 0;
      foreach my $species_key (keys %seen_conserved_species){if ($reference_species{$species_key}){$spec_ref ++}}
      unless ($ratio){$cons = 'none';}
      
      if ($ratio == 1){
        $cons = 'conserved' if $spec_ref == 5;
        $cons = 'miss ref spec conserved' if $spec_ref <5;
      }
      else{
        if($ratio > 0 and $ratio < 0.5){
          $cons = 'putative partially conserved' if $spec_ref == 5;
          $cons = 'highly putative partially conserved' if $spec_ref >= 3 && $spec_ref < 5;
          $cons = 'lowly putative partially conserved' if $spec_ref <3;
        }
        if($ratio >= 0.5 and $ratio < 1){
          $cons = 'putative totally conserved' if $spec_ref == 5;
          $cons = 'highly putative totally conserved' if $spec_ref >= 3 && $spec_ref < 5;
          $cons = 'lowly putative totally conserved' if $spec_ref <3;
        }
      }
      unless($ratio){$cons = 'intergenic'}
      printf OUT "%s\tpair %s %s\t#\t#\t#\tRATIO %.2f\tCONSERVATION %d\/%d %s \n",$family_name,$micro_name,$gene_name,$ratio,$conservation,$total,$cons;
      printf SC  "%s\tpair %s %s\t#\t#\t#\tRATIO %.2f\tCONSERVATION %d\/%d %s \n",$family_name,$micro_name,$gene_name,$ratio,$conservation,$total,$cons;
      printf LOG "%s\tpair %s %s\t#\t#\t#\tRATIO %.2f\tCONSERVATION %d\/%d %s \n",$family_name,$micro_name,$gene_name,$ratio,$conservation,$total,$cons;
      
      foreach my $name (@all_name){  
        my @names2 = @{$dbh->get_MirnaNameAdaptor->fetch_by_name_like($name)};
        foreach my $mirna_name (@names2){
          $mirna_name->hostgene_conservation($ratio);
          $dbh->get_MirnaNameAdaptor->update($mirna_name);
          my $mirna_feat = $mirna_name->feature('microRNA group conservation');
          $seen_tag{$mirna_feat->note}{$cons} ++ if $mirna_feat->note;
        }
      }
    }
  }
}






################ SUBROUTINES ########################################################################################################################################

=head2 _print_in_file
  
  arg1: micro_rna
  arg2: tag of conservation (0 or 1)
  arg3: homology string if defined
  arg4: conservation increment (0 if tag 0)
  description: write the row into the file
  return: none

=cut


sub _print_in_file{
  my ($micro_rna,$tag,$cmp_string,$conservation) = @_;
  my $host_string = 'intergenic';
  if ($micro_rna->hostgene){
    $host_string = $micro_rna->hostgene->attribute->external_name if $micro_rna->hostgene->attribute->external_name;
    $host_string .= " ".$micro_rna->hostgene->stable_id;
    $host_string .= " ".$micro_rna->hostgene->gene_name;
    $host_string .= " ".$micro_rna->hostgene->biotype;
  }
  printf OUT "%s\t%s\t%s\t%s\t%s\t%d\t%d\n",
  $micro_rna->mirna_name,$micro_rna->gene_name,$micro_rna->organism,$host_string,$cmp_string,$tag,$conservation;

}

=head2 _test_homolog

  arg: ensembl gene
  description: search homologs in ensembl and look in cogemir if it is stored
  return : a list of homologs ensembl objects

=cut


sub _test_homolog{
  my ($ensgene) = @_;
  my $checked ;
  my @homs = @{$ensgene->get_all_homologous_Genes};
  foreach my $all_homs (@homs){
    my ($gene, $compara,$species) = @{$all_homs};
    unless ($seen_properly_species{$species}){next;}
    unless (defined $gene){next;}
    unless (defined $dbh->get_MicroRNAAdaptor->fetch_by_organism($species)){next;}
    my $foundgene = $dbh->get_GeneAdaptor->fetch_by_stable_id($gene->stable_id);
    if (defined $foundgene){
      if ($family_name eq $foundgene->attribute->mirna_name->family_name){
        push (@{$checked}, $all_homs);
      }
    }
  }
  return $checked if $checked;
}



=head2 _test_npd
  
  arg: micro_rna
  description: look for a new gene overlapping micro_rna, test if it is an homologs and call a sub to load it into the database
  return: a list of homologs ensembl objects
  
=cut


sub _test_npd{
  my ($mir) = @_;
  
  my $newgene;
  my $hostgene;
  $hostgene = $mir if $mir->isa("Bio::Cogemir::Gene");
  $hostgene = $mir->hostgene if $mir->isa("Bio::Cogemir::MicroRNA");
  my $slice = $loader->genoinfo->search_in_ensembl_by_slice($mir->db,$mir->attribute->location);
  foreach my $gene (@{$slice->get_all_Genes}){
    print $gene->external_name,"\t",$gene->biotype,"\n";
    next if $gene->biotype eq 'miRNA';
    next if $gene->stable_id eq $hostgene->stable_id;
    $newgene = $gene;
    print "found ",$newgene->external_name,"\n";
    my $hom_list = &_test_homolog($newgene); 
    if ($hom_list){
      print "tested ",$newgene->external_name,"\n";
      my $loadedgene;
      if ($mir->isa("Bio::Cogemir::Gene")){
        my @mirs = @{$dbh->get_MicroRNAAdaptor->fetch_by_hostgene_organism($newgene->stable_id, $mir->organism)};
        foreach my $item(@mirs){  
          $loadedgene  = &_load_newgene($item,$newgene)
        }  
      }
      if ($mir->isa("Bio::Cogemir::MicroRNA")){$loadedgene  = &_load_newgene($mir,$newgene);}
      return $hom_list;
    } 
  }
  
  return 0;
}

=head2 _search_flanking_region

  arg: the starting cogemir gene
  description: look around starting gene to find an homolog gene and call a sub t run the flanking
  return: a list of homologs

=cut


sub _search_flanking_region{
  my ($starting_gene) = @_;
  
  my $location = $starting_gene->attribute->location;
  my $genome_db = $starting_gene->db;
  
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
    my $upslice = $loader->genoinfo->search_in_ensembl_by_slice($genome_db,$up_location);
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
      if ($gene){
        if($gene->stable_id){  
          if($gene->stable_id eq $gene->stable_id){next;}
          print "found upgene ",$gene->external_name,"\n";
          my $uptest = &_test_homolog($gene);
          if ($uptest && scalar @{$uptest}){
            $upgene = $gene;
            print "tested upgene ",$gene->external_name,"\n";
            $ret{'upgene'} = $upgene;
            $ret{'up'} = ($start - $upgene->slice->end) ;
            foreach my $item(@{$uptest}){push(@tested,$item);}
            last;
          } 
        }
      }
    }
    last if $upgene;
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
    my $downslice = $loader->genoinfo->search_in_ensembl_by_slice($genome_db,$down_location);
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
      if ($gene){
        if ($gene->stable_id){
          if($gene->stable_id eq $gene->stable_id){next;}
          print "found downgene ",$gene->external_name,"\n";
          my $downtest = &_test_homolog($gene) ;
          if ($downtest && scalar @{$downtest}){ 
            $downgene = $gene;
            print "test downgene ",$gene->external_name,"\n";
            $ret{'downgene'} = $downgene;
            $ret{'down'} = ($downgene->slice->start - $end);
            foreach my $item(@{$downtest}){push(@tested,$item);}
            last;
          }
        }
      }
    }
    last if $downgene;
    $window += 10000;
    $newstart = $newstart + $window;
    $newend += $window;
    $down_location->start($newstart);
    $down_location->end($newend);
  }
  
  if (scalar @tested){
    &_load_flanking_feature($starting_gene,\%ret);
    return \@tested;
  }
  return 0;
} 

=head2 _load_flanking_feature
  
  arg1 : reference gene
  arg2: array of flanking gene
  description: loading flanking gene feature into the database
  return: none

=cut

sub _load_flanking_feature{
  my ($gene,$flanking_gene) = @_;
  my $tag = 'micro_rna';
  if ($gene->isa("Bio::Cogemir::Gene")){$tag = 'gene'}
  my $down = $flanking_gene->{"down"};
  my $up = $flanking_gene->{"up"};
  my $downgene = $flanking_gene->{"downgene"};
  my $upgene = $flanking_gene->{"upgene"};
  my $downstable = 'NA';
  my $upstable = 'NA';
  if ($downgene || $upgene){
    
    $downstable = $downgene->stable_id if $downgene;
    $upstable = $upgene->stable_id if $upgene;
    
    my $fg_feat_logic_name =  $dbh->get_LogicNameAdaptor->fetch_by_name('flanking gene');
        
    my $fg_analysis =  Bio::Cogemir::Analysis->new(       
                      -LOGIC_NAME =>$fg_feat_logic_name,
                      -PARAMETERS =>$upstable." bp upstream and ".$downstable." downstream $tag regions",
                      -CREATED =>$date
                     );
    
    my $fg_feature =  Bio::Cogemir::Feature->new(   
                    -LOGIC_NAME => $fg_feat_logic_name, 
                    -DESCRIPTION => "flanking region of $tag",
                    -NOTE => 'up distance from end of gene max 30000, down distance from start of gene max 30000 window size 10000',
                    -DISTANCE_FROM_DOWNSTREAMGENE => $down,
                    -CLOSEST_DOWNSTREAMGENE => $downstable,
                    -DISTANCE_FROM_UPSTREAMGENE => $up,
                    -CLOSEST_UPSTREAMGENE => $upstable,
                    -ANALYSIS => $fg_analysis 						                                                  
                    );
    
    my $fg_feat_id = $dbh->get_FeatureAdaptor->store($fg_feature);
    
    if ($tag eq 'gene'){$gene_feat_sth->execute($gene->dbID, $fg_feat_id);}
    if ($tag eq 'micro_rna'){$feat_sth->execute($gene->dbID, $fg_feat_id);}
  }
}


=head2 _load_newgene

  arg1: micro_rna
  arg2: new overlapping ensembl gene
  description: store new gene and update micro_Rna hostgene definition
  return: new cogemir gene

=cut


sub _load_newgene{
  my ($micro_rna,$host) = @_;
  $host->adaptor->remove($host);
  my $direction = 'sense';
  my $gene;
  if ($micro_rna->attribute->location->strand != $host->strand){$direction = 'antisense'}
  my $genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($micro_rna->organism,$host->adaptor->db->group); 
  my $coord_sys = $micro_rna->hostgene->attribute->location->CoordSystem;
  my @tmps = split /:/,$host->slice->name;
  my $region_name = $tmps[2];
  my $host_location = Bio::Cogemir::Location->new(
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $region_name,
                    -START => $host->start,
                    -END => $host->end,
                    -STRAND => $host->strand
        );
  my ($refseq_dna,$gene_symbol,$refseq_dna_predicted,$unigene,$ucsc);
  unless ($host->adaptor->db->group eq 'otherfeatures'){ 
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
                      
  my $host_logic_name =  $dbh->get_LogicNameAdaptor->fetch_by_name("host miRNA attributes");

  my $host_analysis =  Bio::Cogemir::Analysis->new(       
                  -LOGIC_NAME =>$host_logic_name,
                  -PARAMETERS =>'hostgene update',
                  -CREATED =>$date
                  
                 );
  
  my $host_attribute =  Bio::Cogemir::Attribute->new(   
                    -GENOME_DB              => $genome_db,
                    -MIRNA_NAME          => $micro_rna->attribute->mirna_name,
                    -ANALYSIS            => $host_analysis,
                    -STATUS              => $host->status,
                    -GENE_NAME => $micro_rna->gene_name."_host",  
                    -STABLE_ID => $host->stable_id, 
                    -EXTERNAL_NAME => $host->external_name,
                    -DB_LINK =>"EnsEMBL",
                    -DB_ACCESSION => $host->stable_id,
                    -LOCATION => $host_location,
                    -ALIASES => $aliases
                   );
    
  my $conservation_score;
  $gene =  Bio::Cogemir::Gene->new(
                    -ATTRIBUTE              => $host_attribute,
                    -BIOTYPE =>$host->biotype,
                    -LABEL            => 'host',
                    -CONSERVATION_SCORE  => $conservation_score,
                    -DIRECTION => $direction
                   );
  my $new_dbID = $dbh->get_GeneAdaptor->store($gene);
  print $gene->dbID,"\t$new_dbID\n";
  $micro_rna->hostgene($gene);
  $micro_rna->adaptor->update($micro_rna);
  my $region_start = $micro_rna->attribute->location->start;
  my $region_end = $micro_rna->attribute->location->end;	
  
  
  foreach my $transcript (@{$host->get_all_Transcripts()}){
    my $loc_flag = 0;
    my $label;
    my $loc_count = 0;
    my ($loc_pre_exon, $rank, $offset);
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
                  -NAME => $region_name,
                  -START => $transcript->start,
                  -END => $transcript->end,
                  -STRAND => $host->strand
      );
      
    my $seq_logic_name =  $dbh->get_LogicNameAdaptor->fetch_by_name("host transcript");
      
    my $transcript_seq = Bio::Cogemir::Seq->new(
            -name => $transcript->stable_id,
            -sequence => $transcript->seq->seq,
            -logic_name =>$seq_logic_name
            );
    my $tattribute =  Bio::Cogemir::Attribute->new(   
                    -GENOME_DB              => $genome_db,
                    -SEQ                 => $transcript_seq,
                    -MIRNA_NAME          => $micro_rna->attribute->mirna_name,
                    -ANALYSIS            => $tanalysis,
                    -STATUS              => $transcript->status,
                    -GENE_NAME => $micro_rna->gene_name."_transcript",  
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
    if ($region_end < $transcript->start){ 
      $label = 'out of transcript';
      $offset = $transcript->start - $region_end;
    }
    if($region_start > $transcript->end){
      $label = 'out of transcript';
      $offset = $region_start - $transcript->end;
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
        exit;
      }
      unless (defined $label){
       
        if($region_start > $exon->end ){
          if($loc_count == $flag){
              $loc_pre_exon = $exon;
              $label = "intron"; 
              $offset = $region_start - $exon->end;
              #print "==>1 $label,$offset\n";
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
              #print "RG $region_start EE ",$exon->end,"\n";
              #print "==>2 $label,$offset\n";
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
          $label = "over exon";
          unless ($exon_term =~ /exon/){$label = 'over UTR'}
          $offset = $region_start - $exon->start;
          $rank = $loc_count;
          
          }          
        else{$label = "intron"; 
          $loc_pre_exon = $exon;
          $label = "intron"; 
          $offset = $region_start - $exon->end;
          #print "==>3 $label,$offset\n";
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
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $region_name,
                    -START => $exon->start,
                    -END => $exon->end,
                    -STRAND => $host->strand
        );
        
      my $seq_logic_name =  Bio::Cogemir::LogicName->new(   
                  -NAME => "host exon"
                 );
        
      my $exon_seq = Bio::Cogemir::Seq->new(
              -name => $exon->stable_id,
              -sequence => $exon->seq->seq,
              -logic_name =>$seq_logic_name
              );  
      my $eattribute =  Bio::Cogemir::Attribute->new(   
                      -GENOME_DB              => $genome_db,
                      -SEQ                 => $exon_seq,
                      -MIRNA_NAME          => $micro_rna->attribute->mirna_name,
                      -ANALYSIS            => $eanalysis,
                      -GENE_NAME => $micro_rna->gene_name."_exon",  
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
                    -COORDSYSTEM =>$coord_sys,
                    -NAME => $region_name,
                    -START => $exon->end + 1,
                    -END => $exon->end,
                    -STRAND => $host->strand
        );
      my $iattribute =  Bio::Cogemir::Attribute->new(   
                      -GENOME_DB              => $genome_db,
                      -MIRNA_NAME          => $micro_rna->attribute->mirna_name,
                      -ANALYSIS            => $ianalysis,
                      -GENE_NAME => $micro_rna->gene_name."_intron",  
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
    unless (defined $label){die " no label\n";}

    my ($localization) =  Bio::Cogemir::Localization->new( 
              -LABEL => $label,  
              -MODULE_RANK => $rank, 
              -OFFSET => $offset,
              -TRANSCRIPT =>$transcript_obj,
              -MICRO_RNA => $micro_rna
               );
    
    $dbh->get_LocalizationAdaptor->store($localization);
  }
  my $species = $micro_rna->organism;
  my $vega_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'vega');
  my $vega = $loader->genoinfo->search_host_in_ensembl_by_slice($vega_genome_db,$gene->attribute->location);
  
  my $est_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'otherfeatures');;
  my $est = $loader->genoinfo->search_host_in_ensembl_by_slice($est_genome_db,$gene->attribute->location) if $est_genome_db;
  
  if (defined $vega && $vega->strand == $micro_rna->attribute->location->strand){
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
  
  if (defined $est && $est->strand == $micro_rna->attribute->location->strand){
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
    my $rev_location = $micro_rna->attribute->location;
    my $rev_genome_db = $dbh->get_GenomeDBAdaptor->fetch_by_organism_type($species,'core');
    $rev_location->strand(-1 * ($micro_rna->attribute->location->strand));
    my $reverse_gene = $loader->genoinfo->search_host_in_ensembl_by_slice($rev_genome_db,$rev_location);
    if ($reverse_gene && $reverse_gene->strand != $micro_rna->attribute->location->strand){
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
  
  return $gene;
}  







































