 #! /usr/bin/perl -w


use strict;
use Data::Dumper;
use lib "$ENV{'HOME'}/src/cogemir-beta/modules";
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::Location;
do ("$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl") or die "$!\n"; #settings

my $dbh = Bio::Cogemir::DBSQL::DBAdaptor->new(
								-user => $::settings{'user'},
								-host => $::settings{'host'},
								-driver => $::settings{'driver'},
								-dbname => $::settings{'dbname'},
								-pass => $::settings{'pass'},
								-verbose => 1
								);

########### QUERY ##########

my $sql = qq{INSERT INTO symatlas_annotation_gene SET symatlas_annotation_id = ?, gene_id = ?};
my $sth = $dbh->prepare($sql);

#### RETRIEVE INFORMATION BY FILE #########
open (HANN, "$ENV{'HOME'}/Projects/cogemir/data/symatlas/chip_annotation/gnf1b-anntable.txt") || die $!;
# genome dbID 17
open (MANN, "$ENV{'HOME'}/Projects/cogemir/data/symatlas/chip_annotation/gnf1m-anntable.txt") || die $!;
#genome dbID 23
#my ($mprobeset, $np, $mrefseq, $munigene, $riken, $gene, $symbol, $link, $riken_link, $symatlas, $mname, $ensembl_transcript); 
#Chr14:22.369-22.374 (+) (NCBI35);Chr14:22.369-22.373 (-) (NCBI35)
####### load table
my $tag = 0;
my $count = 0;
while (<HANN>){
	my $row = $_;
	chomp $row;
	$count ++;
	#skip first row
	unless ($tag){
		$tag = 1;
		next;
	}
	my ($taxon, $name, $accession, $probeset, $reporters, $genome_location, $locus_link, $refseq, $unigene, $uniprot, $ensembl, $aliases, $description, $function, $protein_families) = split /\t/, $row;
  my @members;
  my ($ensembl_gene,$ensembl_transcript,$ensembl_translation);
  next unless $aliases; 
  my @names = split /;/,$aliases;
  if($ensembl){
    foreach my $item (split /;/,$ensembl){
        if ($item =~ /ENSG/){$ensembl_gene  = $item; } 
        elsif ($item =~ /ENST/){$ensembl_transcript  = $item;} 
        elsif ($item =~ /ENSP/){$ensembl_translation  = $item;}   
    }
  }
  foreach my $name (@names){
    my $list = $dbh->get_AttributeAdaptor->fetch_by_external_name($name);
    foreach my $attribute (@$list){
      next unless $attribute->genome_db->organism =~ /Homo/;
      $ensembl_gene = $attribute->stable_id unless defined $ensembl_gene;
      print "$name for ",$attribute->stable_id,"\n";
      my $gene = $dbh->get_GeneAdaptor->fetch_by_attribute_id($attribute->dbID);
      
      my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
                                  -GENOME_DB => $attribute->genome_db,
                                  -NAME => $name,
                                  -ACCESSION => $accession,
                                  -PROBSET_ID => $probeset,
                                  -REPORTERS => $reporters,
                                  -LOCUS_LINK => $locus_link,
                                  -REF_SEQ => $refseq,
                                  -UNIGENE => $unigene,
                                  -UNIPROT => $uniprot,
                                  -ENSEMBL_GENE => $ensembl_gene,
                                  -ENSEMBL_TRANSCRIPT => $ensembl_transcript,
                                  -ENSEMBL_TRANSLATION => $ensembl_translation,
                                  -DESCRIPTION => $description,
                                  -FUNCTION => $function,
                                  -PROTEIN_FAMILIES => $protein_families,
                                  -ALIASES => $aliases
                                 );
      my $symatlas_id = $dbh->get_SymatlasAnnotationAdaptor->store($symatlas_annotation);
      $sth->execute($symatlas_id, $gene->dbID);
      print "STORED $name for ",$gene->gene_name,"\n"; 
    }
  }
}
print "DONE HUMAN\n";

while (<MANN>){
	my $row = $_;
	my ($probeset, $number, $refseq, $unigene, $rik, $locus_link, $name, $description, $ensembl) = split /\t/, $row;
  next unless $name;     
  my @attributes;
  my ($ensembl_gene,$ensembl_transcript,$ensembl_translation);
  if($ensembl){
    foreach my $item (split /;/,$ensembl){
        if ($item =~ /ENSMUSG/){$ensembl_gene  = $item; } 
        elsif ($item =~ /ENSMUST/){$ensembl_transcript  = $item;} 
        elsif ($item =~ /ENSMUSP/){$ensembl_translation  = $item;}   
    }
  }
  my $list = $dbh->get_AttributeAdaptor->fetch_by_external_name($name);
  foreach my $attribute (@{$list}){
    next unless $attribute->genome_db->organism =~ /Mus/;
    $ensembl_gene = $attribute->stable_id unless defined $ensembl_gene;
    my $gene = $dbh->get_GeneAdaptor->fetch_by_attribute_id($attribute->dbID);
    print "$name for ",$attribute->stable_id,"\n";
    my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
                            -GENOME_DB => $attribute->genome_db,
                            -NAME => $name,
                            -ACCESSION => $rik,
                            -PROBSET_ID => $probeset,
                            -REPORTERS => undef,
                            -LOCUS_LINK => $locus_link,
                            -REF_SEQ => $refseq,
                            -UNIGENE => $unigene,
                            -UNIPROT =>undef,
                            -ENSEMBL_GENE => $ensembl_gene,
                            -ENSEMBL_TRANSCRIPT => $ensembl_transcript,
                            -ENSEMBL_TRANSLATION => $ensembl_translation,
                            -DESCRIPTION => $description,
                            -FUNCTION => undef,
                            -PROTEIN_FAMILIES => undef,
                            -ALIASES => undef
                           );
    my $symatlas_id = $dbh->get_SymatlasAnnotationAdaptor->store($symatlas_annotation);
    $sth->execute($symatlas_id, $gene->dbID);
    print "STORED $name for ",$attribute->gene_name,"\n"; 
  }
}
 print "DONE MOUSE\n";



