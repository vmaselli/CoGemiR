# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 13;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Localization #####\n";

use Bio::Cogemir::Localization;
use Bio::Cogemir::Transcript;
use Bio::Cogemir::MicroRNA;

use CogemirTestDB;
use Data::Dumper;
use Time::localtime;
ok(1);

my $mirna_pattern_db_test = CogemirTestDB->new;
my $dbh = $mirna_pattern_db_test->get_DBAdaptor;

ok defined $dbh;

#external obj
use Bio::Cogemir::Location;
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


use Bio::Cogemir::Seq;
my $mature_seq = Bio::Cogemir::Seq->new(
				-name => "mature test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $mature_seq;

use Bio::Cogemir::Gene;
my $gene =  Bio::Cogemir::Gene->new(   
							    -ATTRIBUTE              => $attribute,
							    -LOCATION          => $location,
							    -BIOTYPE =>'coding protein',
							    -LABEL            => 'host',
							    -CONSERVATION_SCORE              => 1
							   );
							   
ok defined $gene;

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
$sth->execute($micro_rna->dbID, $micro_rna->hostgene->dbID, 'sense');

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

# test class
#create object
my ($localization) =  Bio::Cogemir::Localization->new(   
							    -LABEL => 'intron',  
							    -MODULE_RANK => 1, 
							    -OFFSET => 10,
							    -TRANSCRIPT =>$transcript,
							    -MICRO_RNA => $micro_rna
							   );

ok defined $localization;

ok $localization->isa('Bio::Cogemir::Localization');
ok $localization->label,'intron';
ok $localization->module_rank,1;
ok $localization->offset,10;
ok $localization->transcript,$transcript;
ok $localization->micro_rna,$micro_rna;

#store

my $localization_adaptor = $dbh->get_LocalizationAdaptor;
ok defined $localization_adaptor;
ok $localization_adaptor->isa('Bio::Cogemir::DBSQL::LocalizationAdaptor');

my $dbID = $localization_adaptor->store($localization);
ok defined $dbID;

#fetch

my $localization_new = $localization_adaptor->fetch_by_dbID($dbID);
ok defined $localization_new;
ok $localization_adaptor->fetch_by_label('intron');
ok $localization_adaptor->fetch_by_module_rank(1);
ok $localization_adaptor->fetch_by_offset(10);
ok $localization_adaptor->fetch_by_transcript($transcript->dbID);
ok $localization_adaptor->fetch_by_micro_rna($micro_rna->dbID);

ok $localization_new->isa('Bio::Cogemir::Localization');
ok $localization_new->label,'intron';
ok $localization_new->module_rank,1;
ok $localization_new->offset,10;
ok $localization_new->transcript->dbID,$transcript->dbID;
ok $localization_new->micro_rna->dbID,$micro_rna->dbID;

#update

ok $localization->label('exon');
my $localization_updated = $localization_adaptor->update($localization);
ok $localization_updated->label,'exon';

#remove

ok $localization_adaptor->remove($localization_updated);

