=pod

=head1 NAME - load_symatlas_data.pl

=head1 SYNOPSIS    

=head1 DESCRIPTION


=head1 METHODS

=cut

BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings

my $debug = 1;

use vars qw(@ISA);
use strict;
use lib $::lib{'cogemir'};

use Bio::Cogemir::LoadSymAtlas;
use Bio::Cogemir::LoadDB;
my $datadir = File::Spec->catfile($::path{'datadir'},"symatlas");
my $chip_annotation_dir = File::Spec->catfile($datadir,"chip_annotation");
#chip_annotation/gnf1b-anntable.txt  chip_annotation/gnf1m-anntable.txt
my $expression_data_dir = File::Spec->catfile($datadir,"expression_data");
#expression_data/human:
#gnf1h-data.txt  gnf1h-gcrma.txt  gnf1h_ap_calls.txt  hg_u133a_apcalls.txt
#expression_data/mouse:
#gnf1m-data.txt  gnf1m-gcrma.txt  gnf1m_ap_calls.txt  mg_u133a_apcalls.txt


use File::Spec;
my $loader = &create_db;
my $dbh = $loader->db_handle;
my $symdb = Bio::Cogemir::LoadSymAtlas->new(-DBH => $dbh);


&_get_file($chip_annotation_dir);
&_get_file($expression_data_dir);


sub _get_file{
	my ($dir) = @_;
	opendir (DIR, $dir) || die " Cannot open dir $dir $!";
	while (my $item = readdir(DIR)){
		next if $item =~ /^\./;
		print "processing element <$item>\n";
		my $value = File::Spec->catfile($dir,$item);
		eval{opendir(EVDIR, $value)};
		while (my $file = readdir(EVDIR)){
			next if $file =~ /^\./;
			print "processing file <$file>\n";
			my $value = File::Spec->catfile($value,$file);
			my $key = $file;
			$key =~ s/\.txt//;
			$key =~ s/-/_/;
			$symdb->$key($value);
		}
		my $key = $item;
		$key =~ s/\.txt//;
		$key =~ s/-/_/;	
		eval{$symdb->$key($value)};
	}
}	



sub create_db {
	
	my ($self) = @_;
	my $loader =  Bio::Cogemir::LoadDB->new(   
							           -driver      => $::mysql_settings{'driver'},
							           -host        => $::mysql_settings{'host'},
							           -user        => $::mysql_settings{'user'},
							           -port        => $::mysql_settings{'port'},
							           -pass        => $::mysql_settings{'pass'},
							           -schema_sql  => "$ENV{'HOME'}/src/cogemir-beta/sql/symatlas09.sql",
							           -module      => "DBI",
							           -dbname      => "symatlas09"
							           );
	$loader->create_db;
	return $loader;
}


