# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 32;
use lib "$ENV{'HOME'}/src/cogemir/modules";
print "##### Testing Expression #####\n";

use Bio::Cogemir::Expression;
use Bio::Cogemir::Analysis;
use Bio::Cogemir::Seq;
use Bio::Cogemir::LogicName;
use CogemirTestDB;
use Data::Dumper;
use Time::localtime;
ok(1);

my $microrna_db_test = CogemirTestDB->new;
my $dbh = $microrna_db_test->get_DBAdaptor;

ok defined $dbh;
my $date = localtime->mday."/".(localtime->mon+1)."/".(localtime->year+1900)." ".localtime->hour.":".localtime->min.":".localtime->sec."\n";


#create external obj
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

use Bio::Cogemir::Location;
my $location = Bio::Cogemir::Location->new(
                -COORDSYSTEM =>'chromosome',
                -NAME => 12,
				-START => 10345,
				-END => 19678,
				-STRAND => 1
		);
ok defined $location;

use Bio::Cogemir::SymatlasAnnotation;
my $symatlas_annotation =  Bio::Cogemir::SymatlasAnnotation->new(   
							    -GENOME_DB => $genome_db,
							    -LOCATION => $location,
							    -ENSEMBL_GENE => 'ENSG00000124343',
							    -ENSEMBL_TRANSCRIPT => 'ENST00000126743',
							    -ENSEMBL_TRANSLATION => 'ENSP00000262688',
							   );

ok defined $symatlas_annotation;

use Bio::Cogemir::Tissue;
my $tissue =  Bio::Cogemir::Tissue->new(   
							    -NAME => 'liver'
							   );
ok defined $tissue;


# test class
#create object
my $expression =  Bio::Cogemir::Expression->new( 
                                -EXTERNAL => $symatlas_annotation,
							    -EXPRESSION_LEVEL => 2345,
							    -TISSUE => $tissue
							   );

ok defined $expression;

#test field
ok $expression->isa('Bio::Cogemir::Expression');
ok $expression->expression_level(),2345;
ok $expression->symatlas_annotation,$symatlas_annotation;
ok $expression->tissue, $tissue;

#storing

my $expression_adaptor = $dbh->get_ExpressionAdaptor;
ok $expression_adaptor->isa('Bio::Cogemir::DBSQL::ExpressionAdaptor');
ok $expression_adaptor->store($expression);


#fetch 

ok $expression_adaptor->fetch_by_symatlas_annotation($symatlas_annotation->dbID);
ok $expression_adaptor->fetch_by_expression_level($expression->expression_level);
ok $expression_adaptor->fetch_by_tissue_id($expression->tissue->dbID);

my ($expression_new )= @{$expression_adaptor->fetch_by_symatlas_annotation($symatlas_annotation->dbID)};
ok $expression_new->isa('Bio::Cogemir::Expression');
ok $expression_new->expression_level(),2345;
ok $expression_new->symatlas_annotation->dbID,$symatlas_annotation->dbID;
ok $expression_new->tissue->dbID, $tissue->dbID;
#update

ok $expression_new->expression_level(2356);
my ($expression_updated) = @{$expression_adaptor->update($expression_new)};
ok $expression_updated->expression_level(),2356;

#remove

ok $expression_adaptor->remove($expression_updated);
