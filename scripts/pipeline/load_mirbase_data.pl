=pod

=head1 NAME - BD::LoadMirBase

=head1 SYNOPSIS

    

=head1 DESCRIPTION

1. Creare e caricare mirbase solo per alcune specie

=head1 METHODS

=cut

BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings

my $debug = 1;

use vars qw(@ISA);
use strict;
use lib $::lib{'cogemir'};

use DB::LoadMirBase;

my $datadir = $::path{'datadir'}."/mirbase/";

use File::Spec;

opendir (DIR, $datadir) || die " Cannot open dir $datadir $!";

my %files;
my $loader = &create_db;
my $dbh = $loader->db_handle;
my $mirdb = DB::LoadMirBase->new(-DBH => $dbh);
while (my $file = readdir(DIR)){
	next if $file =~ /^\./;
	next unless $file =~ /\.txt$/;
	print "processing file <$file>\n";
	my $key = $file;
	$key =~ s/\.txt//;
	my $value = File::Spec->catfile($datadir,$file);
	$files{$key}=$value;
	$mirdb->$key($value);
	
}


sub create_db {
	
	my ($self) = @_;
	my $loader =  Bio::Cogemir::LoadDB->new(   
							           -driver      => $::mysql_settings{'driver'},
							           -host        => $::mysql_settings{'host'},
							           -user        => $::mysql_settings{'user'},
							           -port        => $::mysql_settings{'port'},
							           -pass        => $::mysql_settings{'pass'},
							           -schema_sql  => "$ENV{'HOME'}/src/cogemir-beta/sql/mirbase12.sql",
							           -module      => "DBI",
							           -dbname      => "mirbase12"
							           );
	$loader->create_db;
	return $loader;
}


