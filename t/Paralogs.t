# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;
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
use Time::localtime;
plan tests =>33;

print "##### Testing Paralogs #####\n";

use Bio::Cogemir::Paralogs;
use CogemirTestDB;
ok(1);


my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;


#create external object
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
                                      -hostmicrorna_conservation => 'partial',
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
my $microrna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE  => $attribute,
							    -SPECIFIC     => 'yes',
							    -SEED       => 'TGGCAAT',
							    -HOSTGENE   => $gene,
							    -MATURE_SEQ => $mature_seq
							   );
							   
ok defined $microrna;



use Bio::Cogemir::LogicName;
my $plogic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $logic_name;


my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";
my ($panalysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$plogic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							   );
ok defined $analysis;


#test the class
#create object

my $paralogs = Bio::Cogemir::Paralogs->new(
		-query_microrna => $microrna,
		-target_microrna => $microrna,
		-type => 'reciprocal blast',
		-analysis => $panalysis
		);
		
ok defined $paralogs;

# set all fields

ok $paralogs->query_microrna(), $microrna;
ok $paralogs->target_microrna(), $microrna;
ok $paralogs->type(),'reciprocal blast';
ok $paralogs->analysis(), $panalysis;
ok $paralogs->isa('Bio::Cogemir::Paralogs');


#store 

my $paralogs_adaptor = $dbh->get_ParalogsAdaptor($dbh);
ok $paralogs_adaptor->isa('Bio::Cogemir::DBSQL::ParalogsAdaptor');
my $dbID = $paralogs_adaptor->store($paralogs);
ok defined $dbID;

my $sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($microrna->dbID, $microrna->hostgene->dbID, 'sense');

#print STDERR "stored \n";

#fetch

ok $paralogs_adaptor->fetch_by_dbID($dbID);

my $paralogs_new = $paralogs_adaptor->fetch_by_dbID($dbID);
ok $paralogs_adaptor->fetch_by_query_microrna_id($paralogs_new->query_microrna->dbID);
ok $paralogs_adaptor->fetch_by_target_microrna_id($paralogs_new->target_microrna->dbID);
ok $paralogs_adaptor->fetch_by_analysis_id($paralogs_new->analysis->dbID);
ok $paralogs_new->query_microrna->dbID(), $microrna->dbID;
ok $paralogs_new->target_microrna->dbID(), $microrna->dbID;
ok $paralogs_new->type(), 'reciprocal blast';
ok $paralogs_new->analysis->dbID(), $panalysis->dbID;
ok $paralogs_new->isa('Bio::Cogemir::Paralogs');

#update
ok $paralogs_new->type('blast one');
my $paralogs_updated =  $paralogs_adaptor->update($paralogs_new);
ok $paralogs_updated->type,'blast one';

#remove
ok $paralogs_adaptor->remove($paralogs_new);
