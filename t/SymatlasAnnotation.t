# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 27;

print "##### Testing SymatlasAnnotation #####\n";

use Bio::Cogemir::Location;
use Bio::Cogemir::SymatlasAnnotation;
use Bio::Cogemir::GenomeDB;
use CogemirTestDB;
use Data::Dumper;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;

# external object

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

my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM =>'chromosome',
                -NAME => 12,
				-START => 10345,
				-END => 19678,
				-STRAND => 1
		);

ok defined $location;

#test class
#create object

my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
							    -GENOME_DB => $genome_db,
							    -NAME => 'XG',
							    -ACCESSION => 7499,
							    -PROBSET_ID => 'gnf1h08239_s_at',
							    -REPORTERS => 'gnf1h02393_at (gnGNF1Ba)',
							    -LOCUS_LINK => 7499,
							    -REF_SEQ => 'NM_175569',
							    -UNIGENE => 'Hs.179675',
							    -UNIPROT => 'P55808',
							    -ENSEMBL_GENE => 'ENSG00000124343',
							    -ENSEMBL_TRANSCRIPT => 'ENST00000126743',
							    -ENSEMBL_TRANSLATION => 'ENSP00000262688',
							    -DESCRIPTION => 'Xg blood group',
							    -FUNCTION => 'biological process unknown',
							    -PROTEIN_FAMILIES => 'Proline-rich',
							    -ALIASES => 'BC1881_E07'
							   );

ok defined $symatlas_annotation;

ok $symatlas_annotation->genome_db, $genome_db;
ok $symatlas_annotation->name,'XG';
ok $symatlas_annotation->accession,7499;
ok $symatlas_annotation->probset_id,'gnf1h08239_s_at';
ok $symatlas_annotation->reporters,'gnf1h02393_at (gnGNF1Ba)';
ok $symatlas_annotation->location, $location;
ok $symatlas_annotation->locus_link,7499;
ok $symatlas_annotation->refseq,'NM_175569';
ok $symatlas_annotation->unigene,'Hs.179675';
ok $symatlas_annotation->uniprot,'P55808';
ok $symatlas_annotation->ensembl_gene,'ENSG00000124343';
ok $symatlas_annotation->ensembl_transcript,'ENST00000126743';
ok $symatlas_annotation->ensembl_translation,'ENSP00000262688';
ok $symatlas_annotation->aliases,'BC1881_E07';
ok $symatlas_annotation->description,'Xg blood group';
ok $symatlas_annotation->function,'biological process unknown';
ok $symatlas_annotation->protein_families,'Proline-rich';
ok $symatlas_annotation->isa('Bio::Cogemir::SymatlasAnnotation');

#store

my $sym_adaptor = $dbh->get_SymatlasAnnotationAdaptor;
ok defined $sym_adaptor;
ok $sym_adaptor->isa('Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor');
my $dbID = $sym_adaptor->store($symatlas_annotation);
ok defined $dbID;   

#fetch
my $symatlas_annotation_new = $sym_adaptor->fetch_by_dbID($dbID);
ok $symatlas_annotation_new->genome_db->dbID, $genome_db->dbID;
ok $symatlas_annotation_new->name,'XG';
ok $symatlas_annotation_new->accession,7499;
ok $symatlas_annotation_new->probset_id,'gnf1h08239_s_at';
ok $symatlas_annotation_new->reporters,'gnf1h02393_at (gnGNF1Ba)';
ok $symatlas_annotation_new->location->dbID, $location->dbID;
ok $symatlas_annotation_new->locus_link,7499;
ok $symatlas_annotation_new->refseq,'NM_175569';
ok $symatlas_annotation_new->unigene,'Hs.179675';
ok $symatlas_annotation_new->uniprot,'P55808';
ok $symatlas_annotation_new->ensembl_gene,'ENSG00000124343';
ok $symatlas_annotation_new->ensembl_transcript,'ENST00000126743';
ok $symatlas_annotation_new->ensembl_translation,'ENSP00000262688';
ok $symatlas_annotation_new->aliases,'BC1881_E07';
ok $symatlas_annotation_new->description,'Xg blood group';
ok $symatlas_annotation_new->function,'biological process unknown';
ok $symatlas_annotation_new->protein_families,'Proline-rich';
ok $symatlas_annotation_new->isa('Bio::Cogemir::SymatlasAnnotation');

# update
ok $symatlas_annotation_new->name('PG');
my $symatlas_annotation_updated = $sym_adaptor->update($symatlas_annotation_new);
ok $symatlas_annotation_updated->name, 'PG';

# remove
ok $sym_adaptor->remove($symatlas_annotation_updated);

