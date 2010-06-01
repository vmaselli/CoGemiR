# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
use Data::Dumper;

use Bio::Cogemir::Gene;
use Bio::Cogemir::Location;
use Bio::Cogemir::GenomeDB;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::Seq;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::MirnaName;
use Bio::Cogemir::Attribute;
use Bio::Cogemir::Aliases;
use Bio::Cogemir::MicroRNA;

use Time::localtime;
plan tests =>33;

print "##### Testing Homologs #####\n";

use Bio::Cogemir::Homologs;
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




# create obj
# test class
my $gene =  Bio::Cogemir::Gene->new(   
							    -ATTRIBUTE              => $attribute,
							    -BIOTYPE =>'coding protein',
							    -LABEL            => 'host',
							    -CONSERVATION_SCORE              => 1
							   );
ok defined $gene;							   
my $mature_seq = Bio::Cogemir::Seq->new(
				-name => "mature test seq",
				-sequence => 'ATTGCCTTCCGA',
				-logic_name =>$logic_name
				);

ok defined $mature_seq;
my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
							    -ATTRIBUTE  => $attribute,
							    -SPECIFIC     => 'yes',
							    -SEED       => 'TGGCAAT',
							    -HOSTGENE   => $gene,
							    -MATURE_SEQ => $mature_seq
							   );
							   
ok defined $micro_rna;
ok $dbh->get_MicroRNAAdaptor->store($micro_rna);
#store

my $gene_adaptor = $dbh->get_GeneAdaptor;
my $dbID = $gene_adaptor->store($gene);
ok defined $dbID;

my $sql = qq{INSERT INTO direction SET micro_rna_id = ?, gene_id = ?, direction = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($micro_rna->dbID, $gene->dbID, 'sense');							   

use Bio::Cogemir::LogicName;
my $hlogic_name =  Bio::Cogemir::LogicName->new(   
							    -NAME => 'ens_mirna_name'
							   );
ok defined $hlogic_name;


my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";
my ($hanalysis) =  Bio::Cogemir::Analysis->new(       
							    -LOGIC_NAME =>$hlogic_name,
							    -PARAMETERS =>'mirna_name name',
							    -CREATED =>$date
							   );
ok defined $hanalysis;


#test the class
#create object

my $homologs = Bio::Cogemir::Homologs->new(
		-query_gene => $gene,
		-target_gene => $gene,
		-type => 'reciprocal blast',
		-analysis => $hanalysis
		);
		
ok defined $homologs;

# set all fields

ok $homologs->query_gene(), $gene;
ok $homologs->target_gene(), $gene;
ok $homologs->type(),'reciprocal blast';
ok $homologs->analysis(), $hanalysis;
ok $homologs->isa('Bio::Cogemir::Homologs');


#store 

my $homologs_adaptor = $dbh->get_HomologsAdaptor($dbh);
ok $homologs_adaptor->isa('Bio::Cogemir::DBSQL::HomologsAdaptor');
my $dbID = $homologs_adaptor->store($homologs);
ok defined $dbID;

#print STDERR "stored \n";

#fetch

ok $homologs_adaptor->fetch_by_dbID($dbID);

my $homologs_new = $homologs_adaptor->fetch_by_dbID($dbID);
ok $homologs_adaptor->fetch_by_query_gene_id($homologs_new->query_gene->dbID);
ok $homologs_adaptor->fetch_by_target_gene_id($homologs_new->target_gene->dbID);
ok $homologs_adaptor->fetch_by_analysis_id($homologs_new->analysis->dbID);
ok $homologs_new->query_gene->dbID(), $gene->dbID;
ok $homologs_new->target_gene->dbID(), $gene->dbID;
ok $homologs_new->type(), 'reciprocal blast';
ok $homologs_new->analysis->dbID(), $hanalysis->dbID;
ok $homologs_new->isa('Bio::Cogemir::Homologs');

#update
ok $homologs_new->type('blast one');
my $homologs_updated =  $homologs_adaptor->update($homologs_new);
ok $homologs_updated->type,'blast one';

#remove
ok $homologs_adaptor->remove($homologs_new);
