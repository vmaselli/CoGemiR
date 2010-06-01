=pod

=head1 NAME - Bio::Cogemir::LoadMirBase

=head1 SYNOPSIS

    

=head1 DESCRIPTION

1. Creare e caricare mirbase solo per alcune specie

=head1 METHODS

=cut


BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings

package Bio::Cogemir::LoadMirBase;
use vars qw(@ISA);
use strict;
use Carp;
use Data::Dumper;
use Bio::Root::IO; 
use Bio::Root::Root;
@ISA = qw(Bio::Root::Root );

use Bio::Cogemir::LoadDB;


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

sub dead_mirna {
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO dead_mirna SET mirna_acc = ?, mirna_id = ?, previous_id = ?, forward_to = ?, comment = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($mirna_acc,$mirna_id,$previous_id, $forward_to,$comment) = split /\t/, $row;
		$sth->execute($mirna_acc,$mirna_id,$previous_id, $forward_to,$comment);
	}
	return $self;
	
}
sub literature_references{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO literature_references SET auto_lit = ?, medline = ?, title = ?, author = ?, journal = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($autolit,$medline,$title, $author,$journal) = split /\t/, $row;
		$sth->execute($autolit,$medline,$title, $author,$journal);
	}
	return $self;
}
sub mirna{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna SET auto_mirna = ?, mirna_acc = ?, mirna_id = ?, description = ?, sequence = ?, comment = ?, auto_species = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$mirnaacc,$mirna_id, $description,$seqeunce, $comment, $auto_species) = split /\t/, $row;	
		$sth->execute($automirna,$mirnaacc,$mirna_id, $description,$seqeunce, $comment, $auto_species);
	}
	return $self;
}
sub mirna_2_prefam{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_2_prefam SET auto_mirna = ?, auto_prefam = ?};
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($auto_mirna,$auto_prefam) = split /\t/, $row;	
		$sth->execute($auto_mirna,$auto_prefam);
	}
	return $self;
}
sub mirna_chromosome_build{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_chromosome_build SET auto_mirna = ?, xsome = ?, contig_start = ?, contig_end = ?, strand = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$xsome,$contigstart, $contigend,$strand) = split /\t/, $row;	
		$sth->execute($automirna,$xsome,$contigstart, $contigend,$strand);
	}
	return $self;
}
sub mirna_context{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_context SET auto_mirna = ?, transcript_id = ?, overlap_sense = ?, overlap_type = ?, number = ?, transcript_source = ?, transcript_name = ?  };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$transcript_id,$overlap_sense, $overlap_type,$number,$transcript_source, $transcript_name) = split /\t/, $row;
		$sth->execute($automirna,$transcript_id,$overlap_sense, $overlap_type,$number,$transcript_source, $transcript_name);
	}
	return $self;
}
sub mirna_database_links{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_database_links SET auto_mirna = ?, db_id = ?, comment = ?, db_link = ?, db_secondary = ?, other_params = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$dbid,$comment, $dblink,$dbsecondary, $other) = split /\t/, $row;	
		$sth->execute($automirna,$dbid,$comment, $dblink,$dbsecondary, $other);
	}
	return $self;
}
sub mirna_literature_references{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_literature_references SET auto_mirna = ?, auto_lit = ?, comment = ?, order_added = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$autolit,$comment, $orderadded) = split /\t/, $row;	
		$sth->execute($automirna,$autolit,$comment, $orderadded);
	}
	return $self;
}
sub mirna_mature{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_mature SET auto_mature = ?, mature_name = ?, mature_acc = ?, mature_from = ?, mature_to = ?, evidence = ?, experiment = ?, similarity = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($auto_mature,$mature_name,$mature_acc, $mature_from,$mature_to,$evidence, $experiment,$similarity) = split /\t/, $row;
		$sth->execute($auto_mature,$mature_name,$mature_acc, $mature_from,$mature_to,$evidence, $experiment,$similarity);
	}
	return $self;
}
sub mirna_pre_mature{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_pre_mature SET auto_mirna = ?, auto_mature = ?};
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automirna,$automature) = split /\t/, $row;
		$sth->execute($automirna,$automature);
	}
	return $self;
}
sub mirna_prefam{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_prefam SET auto_prefam = ?, prefam_acc = ?, prefam_id = ?, description = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($autoprefam,$prefamacc,$prefamid, $description) = split /\t/, $row;
		$sth->execute($autoprefam,$prefamacc,$prefamid, $description);
	}
	return $self;
}
sub mirna_species{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_species SET auto_id = ?, division = ?, name = ?, taxonomy = ?, genome_assembly = ?, ensembl_db =? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($autoid,$division, $name,$taxonomy,$genomeassembly, $ensembldb) = split /\t/, $row;
		$sth->execute($autoid,$division, $name,$taxonomy,$genomeassembly, $ensembldb);
	}
	return $self;
}
sub mirna_target_links{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_target_links SET auto_mature = ?, auto_db = ?, display_name = ?, field1 = ?, field2 = ? };
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($automature,$autodb,$displayname, $field1,$field2) = split /\t/, $row;
	
		$sth->execute($automature,$autodb,$displayname, $field1,$field2);
	}
	return $self;
}
sub mirna_target_url{
	my ($self,$file) = @_;
	my $dbh = $self->dbh;
	print "Loading <$file>;\n"; 
	open (IN, $file) || die "Cannot open $file $!";
	
	my $sql = qq{INSERT INTO mirna_target_url SET auto_db = ?, display_name = ?, url = ?};
	my $sth = $dbh->prepare($sql);
	
	while (my $row = <IN>){
		chomp $row;
		my ($autodb,$displayname,$url) = split /\t/, $row;
	
		$sth->execute($autodb,$displayname,$url);
	}
	return $self;
}  


1;