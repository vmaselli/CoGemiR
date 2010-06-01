# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 40;
use Time::localtime;
print "##### Testing Attribute #####\n";

use Bio::Cogemir::Attribute;
use Bio::Cogemir::Location;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::GenomeDB;
use Bio::Cogemir::LogicName;
use Bio::Cogemir::Seq;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::MirnaName;
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
											-taxa => 'Fish'
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
                                      -hostgene_conservation => 'partial',
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
# create obj
# test class
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
ok defined $attribute;
ok $attribute->isa('Bio::Cogemir::Attribute');
ok $attribute->genome_db, $genome_db;
ok $attribute->seq, $seq;
ok $attribute->mirna_name, $mirna_name;
ok $attribute->analysis, $analysis;
ok $attribute->status, 'KNOWN';
ok $attribute->location, $location;
ok $attribute->gene_name(), 'mir test';
ok $attribute->stable_id(),'ENSTEST00000003456' ;
ok $attribute->external_name(),'test attribute';
ok $attribute->db_link(),'RefSeq',
ok $attribute->db_accession(),'NM_XXYYZZ';
ok $attribute->aliases(), $aliases;
#store

my $attribute_adaptor = $dbh->get_AttributeAdaptor;
ok defined $attribute_adaptor;
ok $attribute_adaptor->isa('Bio::Cogemir::DBSQL::AttributeAdaptor');

my $dbID = $attribute_adaptor->store($attribute);
ok defined $dbID;

#fetch
ok $attribute_adaptor->fetch_by_genome_db_id($attribute->genome_db->dbID);
ok $attribute_adaptor->fetch_by_seq_id($attribute->seq->dbID);
ok $attribute_adaptor->fetch_by_mirna_name_id($attribute->mirna_name->dbID);
ok $attribute_adaptor->fetch_by_analysis_id($attribute->analysis->dbID);
ok $attribute_adaptor->fetch_by_status('KNOWN');
ok $attribute_adaptor->fetch_by_gene_name('mir test');
ok $attribute_adaptor->fetch_by_stable_id('ENSTEST00000003456');
ok $attribute_adaptor->fetch_by_external_name('test attribute');
ok $attribute_adaptor->fetch_by_db_link('RefSeq');
ok $attribute_adaptor->fetch_by_db_accession('NM_XXYYZZ');

my $attribute_new = $attribute_adaptor->fetch_by_dbID($dbID);
ok defined $attribute_new;
ok $attribute_new->isa('Bio::Cogemir::Attribute');
ok $attribute_new->genome_db->dbID, $genome_db->dbID;
ok $attribute_new->seq->dbID, $seq->dbID;
ok $attribute_new->mirna_name->dbID, $mirna_name->dbID;
ok $attribute_new->analysis->dbID, $analysis->dbID;
ok $attribute_new->status, 'KNOWN';
ok $attribute_new->stable_id(),'ENSTEST00000003456' ;
ok $attribute_new->external_name(),'test attribute';
ok $attribute_new->db_link(),'RefSeq',
ok $attribute_new->db_accession(),'NM_XXYYZZ';
ok $attribute_new->gene_name(), 'mir test';
ok $attribute_new->aliases->ucsc,'ucsc';


#update
ok $attribute_new->status('PREDICTED');
my $attribute_updated = $attribute_adaptor->update($attribute_new);
ok defined $attribute_updated;
ok $attribute_updated->status,'PREDICTED';
ok $attribute_updated->seq->dbID, $seq->dbID;

ok $attribute_updated->gene_name('update name');
my $attribute_updated_new = $attribute_adaptor->update($attribute_updated);
ok $attribute_updated->gene_name(),'update name';
ok $attribute_updated->seq->dbID, $seq->dbID;

#remove
ok $attribute_adaptor->remove($attribute_updated_new);