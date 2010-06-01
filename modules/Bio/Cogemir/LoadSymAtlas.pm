=pod

=head1 NAME - Bio::Cogemir::LoadSymAtlas

=head1 SYNOPSIS

    

=head1 DESCRIPTION

1. Creare e caricare mirbase solo per alcune specie

=head1 METHODS

=cut


BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings

package Bio::Cogemir::LoadSymAtlas;
use vars qw(@ISA);
use strict;
use Carp;
use Data::Dumper;
use Bio::Root::IO; 
use Bio::Root::Root;
@ISA = qw(Bio::Root::Root );

use Bio::Cogemir::LoadSymAtlas;

my $debug = shift @ARGV;

sub new {
	my ($class, @args) = @_;
	
	my $self = $class->SUPER::new(@args);
	my ($dbh
		
		) = $self->_rearrange([qw(
		dbh
		
		)],@args);
	
	
	$dbh && $self->dbh($dbh);
	unless (defined $dbh){$self->throw("I need dbh\n")}

	return $self;
}

sub dbh{
	my ($self,$value) = @_;
    if (defined $value) {
	$self->{'dbh'} = $value;
    }
    return $self->{'dbh'};
	
}


sub gnf1b_anntable{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO chip_annotation SET  species = ?, name = ?, accession = ?, probeset_id = ?, reporters = ?, genome_location = ?, LocusLink = ?, RefSeq = ?, UniGene = ?, UniProt = ?, Ensembl = ?, aliases = ?, description = ?, function = ?, protein_families = ?};
	my $sth = $dbh->prepare($sql);
	my $tag = 0;
	while (my $row = <IN>){
		chomp $row;
		#skip first row
		unless ($tag){
			$tag = 1;
			next;
		}
		my ($taxon, $name, $accession, $probeset, $reporters, $genome_location, $locus_link, $refseq, $unigene, $uniprot, $ensembl, $aliases, $description, $function, $protein_families) = split /\t/, $row;
		$sth->execute($taxon, $name, $accession, $probeset, $reporters, $genome_location, $locus_link, $refseq, $unigene, $uniprot, $ensembl, $aliases, $description, $function, $protein_families);
	}
	print "$file loaded\n";
	return $self;
}  

sub gnf1m_anntable{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO chip_annotation SET  species = ?, name = ?, accession = ?, probeset_id = ?,   LocusLink = ?, RefSeq = ?, UniGene = ?,  Ensembl = ?,  description = ?, number = ?};
	my $sth = $dbh->prepare($sql);
	my $tag = 0;
	while (my $row = <IN>){
		chomp $row;
		#skip first row
		unless ($tag){
			$tag = 1;
			next;
		}
		my ($probeset, $number, $refseq, $unigene, $accession, $locus_link, $name, $description, $ensembl) = split /\t/, $row;
		$sth->execute("Mus musculus", $name, $accession, $probeset, $locus_link, $refseq, $unigene,  $ensembl,  $description, $number);
	}
	print "$file loaded\n";
	return $self;
} 

sub gnf1h_data{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	
	my $sql = qq{INSERT INTO expression_data SET tissue_id = ?, chip_annotation_id = ?, expression_level = ?, platform = ?};
	my $sth = $dbh->prepare($sql);
	
	my $tag = 'data';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
  		
		my @f = split /\t/,$row;
  		my $probeset = $f[0];
		next unless $probeset =~/gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i <scalar @tissues; $i++){
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			next unless defined $tissue_id;
			my $expression_level = $f[$i+1];
			next unless defined $expression_level;
			my $platform = 'MAS5';
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$probeset><$expression_level><$platform>\n";
			$sth->execute($tissue_id,$chip_annotation_id,$expression_level, $platform);
			return $self if $debug;
		}
	}
	print "$file loaded\n";
	return $self;
}  	

sub gnf1h_gcrma{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO expression_data SET tissue_id = ?, chip_annotation_id = ?, expression_level = ?, platform = ?};
	my $sth = $dbh->prepare($sql);
	
	my $tag = 'gcrma';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			$flag = 0;
			next;
		}
  		
		my @f = split /\t/,$row;
  		my $probeset = $f[0];
		next unless $probeset =~/gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i <scalar @tissues; $i++){
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			next unless defined $tissue_id;
			my $expression_level = $f[$i+1];
			next unless defined $expression_level;
			my $platform = 'MAS5';
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform} ++;
			print "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$expression_level><$platform>\n";
			$sth->execute($tissue_id,$chip_annotation_id,$expression_level, $platform);
			return $self if $debug;
		}
	}
	print "$file loaded\n";
	return $self;
}  	


sub gnf1h_ap_calls{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO tissue SET name = ?};
	my $sth = $dbh->prepare($sql);
	
	my $sql2 = qq{INSERT INTO ap_tissue SET tissue_id = ?, chip_annotation_id = ?, tag = ?, value = ?};
	my $sth2 = $dbh->prepare($sql2);
	
	my $tag = 'ap';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
		my @fields = split /\t/,$row;
		my $probeset = shift @fields;
		next unless $probeset =~ /gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i < scalar @fields; $i += 2){
			my $tissue_name = $tissues[$i];
			next if $tissue_name eq 'Descriptions';
			next if $tissue_name =~ /_Detection/; 
			$tissue_name =~ s/_Signal//;
			my @t = split /_/, $tissue_name;
			shift @t;
			$tissue_name = join ("_",@t);
			$tissue_name =~ s/ /_/;
			if ($tissue_name eq "leukemialymphoblastic(molt4)"){$tissue_name = "leukemialymphoblastic"}
			if ($tissue_name eq "Colorectal Adenocarc"){$tissue_name = "colorectal_adenocarcinoma"}
			if ($tissue_name eq  "vomeralnasalorgan(VMO)"){$tissue_name = "vomeralnasalorgan"}
			if ($tissue_name eq  "WHOLEBLOOD(JJV)"){$tissue_name = "wholeblood"}
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			unless($tissue_id){
				$sth->execute($tissue_name);
				$tissue_id = $dbh->{'mysql_insertid'}
			}			
			next unless defined $tissue_id;
			my $tag = $fields[$i+1];
			my $value = $fields[$i];
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$value>\n";			
			$sth2->execute($tissue_id,$chip_annotation_id,$tag, $value);
			return $self if $debug;
		}	
	}
	print "$file loaded\n";
	return $self;
}  	

sub hg_u133a_apcalls{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO tissue SET name = ?};
	my $sth = $dbh->prepare($sql);
	
	my $sql2 = qq{INSERT INTO ap_tissue SET tissue_id = ?, chip_annotation_id = ?, tag = ?, value = ?};
	my $sth2 = $dbh->prepare($sql2);
	
	my $tag = 'ap';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
		my @fields = split /\t/,$row;
		my $probeset = shift @fields;
		next unless $probeset =~ /gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i < scalar @fields; $i += 2){
			my $tissue_name = $tissues[$i];
			next if $tissue_name eq 'Descriptions';
			next if $tissue_name =~ /_Detection/; 
			$tissue_name =~ s/_Signal//;
			my @t = split /_/, $tissue_name;
			shift @t;
			$tissue_name = join ("_",@t);
			$tissue_name =~ s/ /_/;
			if ($tissue_name eq "leukemialymphoblastic(molt4)"){$tissue_name = "leukemialymphoblastic"}
			if ($tissue_name eq "Colorectal Adenocarc"){$tissue_name = "colorectal_adenocarcinoma"}
			if ($tissue_name eq  "vomeralnasalorgan(VMO)"){$tissue_name = "vomeralnasalorgan"}
			if ($tissue_name eq  "WHOLEBLOOD(JJV)"){$tissue_name = "wholeblood"}
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			unless($tissue_id){
				$sth->execute($tissue_name);
				$tissue_id = $dbh->{'mysql_insertid'}
			}			
			next unless defined $tissue_id;
			my $tag = $fields[$i+1];
			my $value = $fields[$i];
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$value>\n";			
			$sth2->execute($tissue_id,$chip_annotation_id,$tag, $value);
			return $self if $debug;
		}	
	}
	print "$file loaded\n";
	return $self;
}  	

sub mg_u133a_apcalls{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO tissue SET name = ?};
	my $sth = $dbh->prepare($sql);
	
	my $sql2 = qq{INSERT INTO ap_tissue SET tissue_id = ?, chip_annotation_id = ?, tag = ?, value = ?};
	my $sth2 = $dbh->prepare($sql2);
	
	my $tag = 'ap';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
		my @fields = split /\t/,$row;
		my $probeset = shift @fields;
		next unless $probeset =~ /gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i < scalar @fields; $i += 2){
			my $tissue_name = $tissues[$i];
			next if $tissue_name eq 'Descriptions';
			next if $tissue_name =~ /_Detection/; 
		
			my $sub_tissue = substr($tissue_name,14);
			unless ($sub_tissue){$sub_tissue = substr($tissue_name,13);}
			$tissue_name = $sub_tissue;
			
			$tissue_name =~ s/ /_/;
			if ($tissue_name eq "leukemialymphoblastic(molt4)"){$tissue_name = "leukemialymphoblastic"}
			if ($tissue_name eq "Colorectal Adenocarc"){$tissue_name = "colorectal_adenocarcinoma"}
			if ($tissue_name eq  "vomeralnasalorgan(VMO)"){$tissue_name = "vomeralnasalorgan"}
			if ($tissue_name eq  "WHOLEBLOOD(JJV)"){$tissue_name = "wholeblood"}
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			unless($tissue_id){
				$sth->execute($tissue_name);
				$tissue_id = $dbh->{'mysql_insertid'}
			}			
			next unless defined $tissue_id;
			my $tag = $fields[$i+1];
			my $value = $fields[$i];
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$value>\n";			
			$sth2->execute($tissue_id,$chip_annotation_id,$tag, $value);
			return $self if $debug;
		}	
	}
	print "$file loaded\n";
	return $self;
}  	

sub gnf1m_data{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO expression_data SET tissue_id = ?, chip_annotation_id = ?, expression_level = ?, platform = ?};
	my $sth = $dbh->prepare($sql);
	
	my $tag = 'data';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
  		
		my @f = split /\t/,$row;
  		my $probeset = $f[0];
		next unless $probeset =~/gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i <scalar @tissues; $i++){
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			next unless defined $tissue_id;
			my $expression_level = $f[$i+1];
			next unless defined $expression_level;
			my $platform = 'MAS5';
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$expression_level><$platform>\n";
			$sth->execute($tissue_id,$chip_annotation_id,$expression_level, $platform);
			return $self if $debug;
		}
	}
	print "$file loaded\n";
	return $self;
}  	

sub gnf1m_ap_calls{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO tissue SET name = ?};
	my $sth = $dbh->prepare($sql);
	
	my $sql2 = qq{INSERT INTO ap_tissue SET tissue_id = ?, chip_annotation_id = ?, tag = ?, value = ?};
	my $sth2 = $dbh->prepare($sql2);
	
	my $tag = 'ap';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			shift @tissues;
			$flag = 0;
			next;
		}
		my @fields = split /\t/,$row;
		my $probeset = shift @fields;
		next unless $probeset =~ /gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i < scalar @fields; $i += 2){
			my $tissue_name = $tissues[$i];
			next if $tissue_name eq 'Descriptions';
			next if $tissue_name =~ /_Detection/; 
		
			my $sub_tissue = substr($tissue_name,14);
			unless ($sub_tissue){$sub_tissue = substr($tissue_name,13);}
			$tissue_name = $sub_tissue;
			
			$tissue_name =~ s/ /_/;
			if ($tissue_name eq "leukemialymphoblastic(molt4)"){$tissue_name = "leukemialymphoblastic"}
			if ($tissue_name eq "Colorectal Adenocarc"){$tissue_name = "colorectal_adenocarcinoma"}
			if ($tissue_name eq  "vomeralnasalorgan(VMO)"){$tissue_name = "vomeralnasalorgan"}
			if ($tissue_name eq  "WHOLEBLOOD(JJV)"){$tissue_name = "wholeblood"}
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			unless($tissue_id){
				$sth->execute($tissue_name);
				$tissue_id = $dbh->{'mysql_insertid'}
			}			
			next unless defined $tissue_id;
			my $tag = $fields[$i+1];
			my $value = $fields[$i];
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$value} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$value>\n";			
			$sth2->execute($tissue_id,$chip_annotation_id,$tag, $value);
		}	
	}
	print "$file loaded\n";
	return $self;
}  	

sub gnf1m_gcrma{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	my $sql = qq{INSERT INTO expression_data SET tissue_id = ?, chip_annotation_id = ?, expression_level = ?, platform = ?};
	my $sth = $dbh->prepare($sql);
	
	my $tag = 'gcrma';
	$self->_load_tissue($file,$tag); 
	open (IN, $file) || die "Cannot open $file $!";
	my @tissues;
	my $flag = 1;
	my %seen;
	while (my $row = <IN>){
		chomp $row;
		if ($flag){
			@tissues = split /\t/, $row;
			$flag = 0;
			next;
		}
  		
		my @f = split /\t/,$row;
  		my $probeset = $f[0];
		next unless $probeset =~/gnf/;
		my $chip_annotation_id = $self->_fetch_chip_annotation_by_probeset($probeset);
		next unless $chip_annotation_id;
		for (my $i = 0; $i <scalar @f; $i++){
			my $tissue_name = lc($tissues[$i]);
			die unless $tissue_name;
			my $tissue_id = $self->_fetch_tissue_by_name($tissue_name,$tag,$file);
			next unless defined $tissue_id;
			my $expression_level = $f[$i+1];
			next unless defined $expression_level;
			my $platform = 'MAS5';
			next if $seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform};
			$seen{$tissue_name}{$tag}{$tissue_id}{$chip_annotation_id}{$expression_level}{$platform} ++;
			print STDERR "<$tissue_name><$tag><$tissue_id><$chip_annotation_id><$expression_level><$platform>\n";
			$sth->execute($tissue_id,$chip_annotation_id,$expression_level, $platform);
			return $self if $debug;
		}
	}
	print "$file loaded\n";
	return $self;
} 

sub _fetch_tissue_by_name{
	my ($self, $value) = @_;
	my $dbh = $self->dbh;
	my $test = qq{SELECT tissue_id FROM tissue WHERE name LIKE  ?};
	my $test_sth = $dbh->prepare($test);
	$test_sth->execute($value."%");
	my $dbID = $test_sth->fetchrow;
	return $dbID;

}

sub _load_tissue{
	my ($self,$file,$tag) = @_;
	my $dbh = $self->dbh;
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO tissue SET name = ?};
	my $sth = $dbh->prepare($sql);
	
	my (@rows) = <IN>;
	my $row = shift @rows;
	chomp $row;
	my @tissues = split /\t/, $row;
	shift @tissues;
	my %seen;
	foreach my $tissue_name(@tissues){
		my $tissue_name = $self->_check_tissue_name($tissue_name,$tag,$file);
		my $test = $self->_fetch_tissue_by_name($tissue_name);
		next if defined $test;		
		$seen{$tissue_name} ++;
		$sth->execute($tissue_name);
	}
	print "tissue from $file loaded\n";
	return $self;
}

sub _fetch_chip_annotation_by_probeset{
	my ($self, $value) = @_;
	my $dbh = $self->dbh;
	my $sql = qq{SELECT chip_annotation_id FROM chip_annotation WHERE probeset_id = ?};
	my $sth = $dbh->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow;
	
	return $dbID;
}


sub _check_tissue_name{
	my ($self, $tissue_name,$tag,$file) = @_;
	my @tn;
	if ($tag eq 'ap'){
		next if $tissue_name eq 'Descriptions';
		next if $tissue_name =~ s/_detection//; 
		$tissue_name =~ s/_signal//;
		if ($file =~  /human/){
			my @t = split /_/, $tissue_name;
			shift @t;
			$tissue_name = join ("_",@t);
		}
		if ($file =~ /mouse/){
			my $sub_tissue = substr($tissue_name,14);
			unless ($sub_tissue){$sub_tissue = substr($tissue_name,13);}
			$tissue_name = $sub_tissue;
		}
	}
	$tissue_name =~ s/\s{1,30}//;
	if ($tissue_name =~ /vomeralnasalorgan/){$tissue_name = 'vomeralnasalorgan'}
	for (my $i=0; $i<length $tissue_name; $i++){push (@tn, substr($tissue_name,$i,(1)))}
	my $string = join("%",@tn);
	my $tissue_id = $self->_fetch_tissue_by_name(ucfirst(lc($string))."%");
	unless (defined $tissue_id){
		$tissue_name =~ s/_//;
		$tissue_id = $self->_fetch_tissue_by_name(ucfirst(lc($tissue_name)));
	}
	return ucfirst(lc($tissue_name));
}


1;