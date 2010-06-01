# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 32;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Transcript #####\n";

use Bio::Cogemir::Transcript;
use Bio::Cogemir::LogicName;
use CogemirTestDB;
use Bio::Cogemir::Location;
use Data::Dumper;
use Time::localtime;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;

#create external obj
my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM =>'chromosome',
                -NAME => 12,
				-START => 10345,
				-END => 19678,
				-STRAND => 1
		);

ok defined $location;
use Bio::Cogemir::GenomeDB;
my $genome_db = Bio::Cogemir::GenomeDB->new(
											-taxon_id => 10,
											-organism => 'Danio rerio',
											-db_host => '192.168.3.252',
											-db_name => 'danio_rerio_otherfeatures_42_6c',
											-db_type => 'otherfeatures',
											-common_name => 'zebrafish',
											-taxa =>'Fish'
											);

ok defined $genome_db;

use Bio::Cogemir::LogicName;
my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'seq test'
							   );

ok defined $logic_name;
use Bio::Cogemir::Seq;
my $seq = Bio::Cogemir::Seq->new(
				-name => "test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $seq;

my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";

use Bio::Cogemir::Analysis;
my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							    
							   );
				
ok defined $analysis;

use Bio::Cogemir::MirnaName;
my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis,
                                      -exon_conservation => 2,
                                      -hostmicro_rna_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
ok defined $mirna_name;


use Bio::Cogemir::Aliases;
my $aliases = Bio::Cogemir::Aliases->new(
                  -REFSEQDNA => 'refseq',
                  -GENESYMBOL => 'alias',
                  -REFSEQDNA_PREDICTION => 'prediction',
                  -UNIGENE =>'unigene',
                  -UCSC => 'ucsc'
                );
                
ok defined $aliases;

use Bio::Cogemir::Attribute;
my $attribute =  Bio::Cogemir::Attribute->new(   
							    -GENOME_DB              => $genome_db,
							    -SEQ                 => $seq,
							    -MIRNA_NAME          => $mirna_name,
							    -ANALYSIS            => $analysis,
							    -STATUS              => 'KNOWN',
							    -GENE_NAME => 'mir test',  
							    -STABLE_ID => 'ENSTEST00000003456', 
							    -EXTERNAL_NAME => 'test attribute',
							    -DB_LINK =>'RefSeq',
							    -DB_ACCESSION => 'NM_XXYYZZ',
							    -LOCATION => $location,
							    -ALIASES => $aliases
							   );

use Bio::Cogemir::Gene;
my $gene =  Bio::Cogemir::Gene->new(   
							    -ATTRIBUTE              => $attribute,
							    -BIOTYPE =>'coding protein',
							    -LABEL            => 'host',
							    -CONSERVATION_SCORE              => 1
							   );
							   
ok defined $gene;
ok $dbh->get_GeneAdaptor->store($gene);

use Bio::Cogemir::Seq;
my $mature_seq = Bio::Cogemir::Seq->new(
				-name => "mature test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $mature_seq;

use Bio::Cogemir::MicroRNA;
my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE  => $attribute,
							    -SPECIFIC     => 'yes',
							    -SEED       => 'TGGCAAT',
							    -HOSTGENE   => $gene,
							    -MATURE_SEQ => $mature_seq
							   );
							   
ok defined $micro_rna;
ok $dbh->get_MicroRNAAdaptor->store($micro_rna);

my $sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($micro_rna->dbID, $gene->dbID, 'sense');

use Bio::Cogemir::Attribute;
my $tattribute =  Bio::Cogemir::Attribute->new(   
							    -GENOME_DB              => $genome_db,
							    -SEQ                 => $seq,
							    -MIRNA_NAME          => $mirna_name,
							    -ANALYSIS            => $analysis,
							    -STATUS              => 'KNOWN',
							    -GENE_NAME => 'mir test',  
							    -STABLE_ID => 'ENST000001233445', 
							    -EXTERNAL_NAME => 'test attribute',
							    -DB_LINK =>'RefSeq',
							    -DB_ACCESSION => 'NM_XXYYZZ',
							    -LOCATION => $location
							   );
							   
# test class
#create object
my $transcript =  Bio::Cogemir::Transcript->new(   
							    -PART_OF => $gene,
							    -ATTRIBUTE =>$tattribute
							   );

ok defined $transcript;

#test field
ok $transcript->isa('Bio::Cogemir::Transcript');
ok $transcript->stable_id(), 'ENST000001233445';
ok $transcript->part_of, $gene;

# storing

my $transcript_adaptor = $dbh->get_TranscriptAdaptor;
ok $transcript_adaptor->isa('Bio::Cogemir::DBSQL::TranscriptAdaptor');
my $dbID = $transcript_adaptor->store($transcript);
ok defined $dbID;


# fetch 
# 
ok $transcript_adaptor->fetch_by_dbID($dbID);
ok $transcript_adaptor->fetch_by_stable_id($transcript->stable_id);
ok $transcript_adaptor->fetch_by_part_of($transcript->part_of->dbID);

my $transcript_new = $transcript_adaptor->fetch_by_dbID($dbID);
ok $transcript_new->stable_id();
ok $transcript_new->isa('Bio::Cogemir::Transcript');
ok $transcript_new->part_of->dbID, $gene->dbID;

# update



# remove
use Bio::Cogemir::Exon;
my $exon =  Bio::Cogemir::Exon->new(   
							    -PART_OF => $transcript_new, 
							    -RANK => 1, 
							    -LENGTH => 13,
							    -PHASE => 0,
							    -ATTRIBUTE => $tattribute,
							    -TYPE => 'coding'
							    );
ok defined $exon;
ok $dbh->get_ExonAdaptor->store($exon);

use Bio::Cogemir::Intron;
my $intron =  Bio::Cogemir::Intron->new(   
							    -PART_OF => $transcript_new, 
							    -LENGTH => 13,
							    -ATTRIBUTE => $tattribute		                                                  
							    );
ok defined $intron;
ok $dbh->get_IntronAdaptor->store($intron);

ok $transcript_adaptor->remove($transcript_new);
