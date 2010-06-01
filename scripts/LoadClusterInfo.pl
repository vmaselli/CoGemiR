#! /usr/bin/perl -w

use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-52/modules";
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Cluster;
use Bio::Cogemir::Paralogs;
use Time::localtime;
my $debug = 1;

$| = 1;		
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec;

do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);

my $logic_name = 'cluster of miRNA';
my $logic_name_obj = $dbh->get_LogicNameAdaptor->fetch_by_name($logic_name);
unless (defined $logic_name_obj){
    $logic_name_obj =  Bio::Cogemir::LogicName->new(   
                                -NAME => $logic_name
                               );
    }
my $parameters = "group of miRNA wich fall in 18000 bp";
my $analysis = Bio::Cogemir::Analysis->new(
                                -LOGIC_NAME =>$logic_name_obj,
                                -PARAMETERS =>$parameters,
                                -CREATED =>$date
                );
                
my $query = qq{select a.gene_name, l.name, l.start, l.end 
from micro_rna mr, location l, attribute a, genome_db g  
where a.location_id = l.location_id 
and mr.attribute_id = a.attribute_id 
and a.genome_db_id = g.genome_db_id 
and g.organism = ? order by l.name, l.start};
my $sth = $dbh->prepare($query);

foreach my $organism (@{$dbh->get_GenomeDBAdaptor->get_all_Organism}){
  print $organism,"\n";
  $sth->execute($organism);
  my %rep;
  while (my ($gene_name, $name, $start, $end) = $sth->fetchrow_array){
    #if ($start == 14626186 && $end == 14626243){print "**** \n"}
    $rep{$name}{$start}{$end} = $gene_name;
    
  }
  my $cluster_obj = undef;
  my @clusters;
  my $i = -1;
  foreach my $chr (sort keys %rep){
    if (defined $cluster_obj && $i>0){
      print "===> ".$cluster_obj->name,"\n";
      $dbh->get_ClusterAdaptor->store($cluster_obj);
      foreach my $mir (@clusters){
        print "GENE NAME $mir\n";
        my $micro_rna = $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($mir);
        $micro_rna->cluster($cluster_obj);
        $micro_rna->adaptor->update($micro_rna);
      }
      print "===== ".$cluster_obj->name." ", join (", ",@clusters),"\n"  if scalar @clusters;
    }
    @clusters = ();
    my $cluster_name;
    
    my %cluster;
    my %seen;
    my $newstart = 0;
    my $newend = 0;  
    
    my $cluster_start = 0;
    my $cluster_end;
    foreach my $start (sort keys %{$rep{$chr}}){
      my ($end) = keys %{$rep{$chr}{$start}};
      print $rep{$chr}{$start}{$end},"\n";
      my $diff = $start - $newend;
      print "$chr $start $end\n";
      if ($diff <= 18000){
        
        $i ++;
        if ($end > $newend){$cluster_end = $end}
        if ($newstart < $cluster_start){$cluster_start = $newstart}
        $cluster_name = $chr."_".$cluster_start."_".$cluster_end;
        print "CLUSTER NAME STEP $i $cluster_name\n";
        my $prev_micro_name = $rep{$chr}{$start}{$end};
        push (@clusters,$prev_micro_name) unless $seen{$prev_micro_name};
        $seen{$prev_micro_name} ++;
        my $micro_name = $rep{$chr}{$newstart}{$newend} ;
        if ($micro_name){
          push (@clusters,$micro_name) unless $seen{$micro_name} ;
          $seen{$micro_name} ++ if $micro_name; 
        }
        $cluster_obj =  Bio::Cogemir::Cluster->new(   
                                                  -NAME => $cluster_name,
                                                  -ANALYSIS => $analysis
                                                  );
      }
      else{
        if ($i > 0){
          $dbh->get_ClusterAdaptor->store($cluster_obj);
          foreach my $mir (@clusters){
            print "GENE NAME $mir\n";
            my $micro_rna = $dbh->get_MicroRNAAdaptor->fetch_by_specific_gene_name($mir);
            $micro_rna->cluster($cluster_obj);
            $micro_rna->adaptor->update($micro_rna);
          }
          print "===== I = $i CLUSTERN NAME = $cluster_name MIRNA = ",join (", ",@clusters),"\n"  if scalar @clusters;
          @clusters = ();
          $cluster_name = $chr."_".$start."_".$end;
          $cluster_start = $start;
          $cluster_end = $end;
          $i = 1;
        }
        else{
          $cluster_name = $chr."_".$start."_".$end;
          $cluster_start = $start;
          $cluster_end = $end;
        }
      }
      $newstart = $start;
      $newend = $end;
    }
    
  }
}
