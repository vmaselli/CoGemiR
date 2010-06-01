# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 27;
use Time::localtime;
print "##### Testing MicroRNA #####\n";

use Bio::Cogemir::MicroRNA;
use Bio::Cogemir::Location;
use Bio::Cogemir::GenomeDB;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::Seq;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::MirnaName;
use Bio::Cogemir::Attribute;
use Bio::Cogemir::Cluster;
use Bio::Cogemir::Gene;
use Bio::Cogemir::Aliases;
use CogemirTestDB;

use Data::Dumper;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;

# external object
my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM =>'chromosome',
                -NAME => 12,
				-START => 10345,
				-END => 19678,
				-STRAND => 1
		);

ok defined $location;

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


my $logic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'seq test'
							   );

ok defined $logic_name;

my $seq = Bio::Cogemir::Seq->new(
				-name => "test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $seq;

my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";

my ($analysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$logic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							    
							   );
				
ok defined $analysis;


my $mirna_name = new Bio::Cogemir::MirnaName (   
									  -name           => 'mir-204',
                                      -analysis       => $analysis,
                                      -exon_conservation => 2,
                                      -hostmicro_rna_conservation => 'partial',
                                      -description =>'micro rna name from miRBase'
                                    );
ok defined $mirna_name;



my $aliases = Bio::Cogemir::Aliases->new(
                  -REFSEQDNA => 'refseq',
                  -GENESYMBOL => 'alias',
                  -REFSEQDNA_PREDICTION => 'prediction',
                  -UNIGENE =>'unigene',
                  -UCSC => 'ucsc'
                );
                
ok defined $aliases;

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



my $mature_seq = Bio::Cogemir::Seq->new(
				-name => "mature test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $mature_seq;

my $gene =  Bio::Cogemir::Gene->new(   
							    -ATTRIBUTE              => $attribute,
							    -LOCATION          => $location,
							    -BIOTYPE =>'coding protein',
							    -LABEL            => 'host',
							    -CONSERVATION_SCORE              => 1
							   );
							   
ok defined $gene;


# create obj
# test class
my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE  => $attribute,
							    -SPECIFIC     => 'yes',
							    -SEED       => 'TGGCAAT',
							    -HOSTGENE   => $gene,
							    -MATURE_SEQ => $mature_seq
							   );
							   
ok defined $micro_rna;
ok $micro_rna->isa('Bio::Cogemir::MicroRNA');
ok $micro_rna->attribute, $attribute;
ok $micro_rna->seed,'TGGCAAT';
ok $micro_rna->hostgene, $gene;
ok $micro_rna->mature_seq, $mature_seq;

# store

my $micro_rna_adaptor = $dbh->get_MicroRNAAdaptor;
ok defined $micro_rna_adaptor;
ok $micro_rna_adaptor->isa('Bio::Cogemir::DBSQL::MicroRNAAdaptor');
 
my $dbID = $micro_rna_adaptor->store($micro_rna);
ok defined $dbID;

my $sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($micro_rna->dbID, $micro_rna->hostgene->dbID, 'sense');

# fetch
ok $micro_rna_adaptor->fetch_by_attribute_id($micro_rna->attribute->dbID);
ok $micro_rna_adaptor->fetch_by_specific('yes');
ok $micro_rna_adaptor->fetch_by_seed($micro_rna->seed);
ok $micro_rna_adaptor->fetch_by_hostgene_id($micro_rna->hostgene->dbID);
ok $micro_rna_adaptor->fetch_by_mature_seq_id($micro_rna->mature_seq->dbID);

my $micro_rna_new = $micro_rna_adaptor->fetch_by_dbID($dbID);
ok defined $micro_rna_new;
ok $micro_rna_new->isa('Bio::Cogemir::MicroRNA');
ok $micro_rna_new->attribute->dbID, $attribute->dbID;
ok $micro_rna_new->seed,'TGGCAAT';
ok $micro_rna_new->hostgene;
ok $micro_rna_new->mature_seq->dbID, $mature_seq->dbID;
# update
ok $micro_rna_new->specific('no');
my $micro_rna_updated = $micro_rna_adaptor->update($micro_rna_new);
ok defined $micro_rna_updated;
ok $micro_rna_new->specific,'no';
# 
# remove

#LOCALIZATION
ok $micro_rna_adaptor->remove($micro_rna_updated);