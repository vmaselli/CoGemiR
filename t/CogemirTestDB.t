# -*-Perl-*-
## Cogemir Test Harness Script
##

use lib 't';
use strict;
use Test;
plan tests => 13;
use lib "$ENV{'HOME'}/src/cogemir/modules";
use CogemirTestDB;
use Bio::Cogemir::DBLoader;

use Data::Dumper;
ok (1);

# Database will be dropped when this
# object goes out of scope
my $mirna_name_db_test = CogemirTestDB->new;

ok $mirna_name_db_test->driver;
ok $mirna_name_db_test->host;
ok $mirna_name_db_test->user;
ok $mirna_name_db_test->port;
ok $mirna_name_db_test->pass;
ok $mirna_name_db_test->schema_sql;
ok $mirna_name_db_test->dbname;
#ok $mirna_name_db_test->pause;
ok $mirna_name_db_test->module;
#ok $mirna_name_db_test->create_db;
ok $mirna_name_db_test->db_handle;
ok $mirna_name_db_test->test_locator;
ok $mirna_name_db_test->mirna_name_db_locator;
ok $mirna_name_db_test->get_DBAdaptor;
#Qui aggiungere il file da "doare"
#ok $mirna_name_db_test->do_sql_file;
#ok $mirna_name_db_test->validate_sql;



