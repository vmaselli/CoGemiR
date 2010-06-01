#! /usr/bin/perl -w

=head1 NAME
	
DBLoader

=head1 DESCRIPTION 

This module contains the methods to search genomics informations in genbank and ensembl

=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut

package Bio::GenomicInformation;
use strict;
use Data::Dumper;
#use Exporter;
use vars qw(@ISA); #@EXPORT @EXPORT_OK);
use Bio::Root::Root;
@ISA = qw(Bio::Root::Root);
#@EXPORT_OK = qw(search_by_genbank_by_genename search_by_ensembl_by_extids search_by_ensembl_id);


use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::DB::Query::GenBank;
use Bio::DB::GenBank;
use Bio::EnsEMBL::Registry;
my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl-config/registry_config.pl") || die $!;
my $debug = 0;
##### STETTING VARIABLES #######

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($settings, $dbh) = $self->_rearrange([qw(SETTINGS DBH )], @args);

	$settings && $self->settings($settings);
	$dbh && $self->dbh($dbh);

	return $self;
}

=head2 search_in_genbank_by_genename

 Title   : search_by_genbank_by_genename
 Usage   : search_by_genbank_by_genename($gene_name)
 Returns : listref of genbank_id
 Args    : gene name 
 
=cut

sub search_in_genbank_by_genename {
	my ($self,$gene_name) = @_;
	
	unless($gene_name){return undef;}
	my ($genbank_id, $stream);
	my @genes;
	my $query = Bio::DB::Query::GenBank->new(-query => "($gene_name AND (PROTEIN OR RNA OR CDS) NOT DNA)",
						 -db => 'nucleotide'); 
	my $gb = new Bio::DB::GenBank;
   	eval {$gb->get_Stream_by_query($query)};
   	if(!$@){
   		$stream = $gb->get_Stream_by_query($query);
   	}
	else{
		#print LOG "#No results in genbank for\n#NGB: $gene_name\n";
		##self->warn("No results in genbank for $gene_name");
		push (@genes, 'NULL');	
		return  (\@genes);
	}
	while (my $seq = $stream->next_seq) {
		$genbank_id = $seq->display_id;
		if ($genbank_id =~ 'NM_'){next;}
		push (@genes, $genbank_id);	
		
	}
	
	return  (\@genes);
}


=head2 _search_in_genbank_by_genbank_id

 Title   : _search_in_genbank_by_genbank_id
 Usage   : _search_by_genbank_id($gene_id)
 Returns : my %returnhash = ( 
					   'seq'	=> \%seq_hash,
					   'member'	=> $seq->display_id,
					   'slice'	=> undef
					 );
 Args    : genbank_id
 
=cut


sub _search_in_genbank_by_genbank_id{
	my ($self,$gene_id) = @_;
	my $gb = new Bio::DB::GenBank;
	my $stream = $gb->get_Seq_by_acc($gene_id);
	my ($seq) = $stream->next_seq;
	my $nrepeat =  $seq->seq =~ tr/N/N/;
	my $percent_masked = ($nrepeat/$seq->length)*100;
	my %seq_hash = ('name'=>$stream->display_id, 'seq'=>$seq->seq, 'p_mask'=>$percent_masked) ;
	my %returnhash = ( 
					   'seq'	=> \%seq_hash,
					   'member'	=> $seq->display_id,
					   'slice'	=> undef
					 );
	return \%returnhash,

}


=head2 search_in_ensembl_by_extids 

 Title   : search_in_ensembl_by_extids 
 Usage   : search_by_ensembl_by_extids($extids)
 Returns : list ref of ensembl gene_stable_id
 Args    : gene name or genbank id 
 
=cut

sub search_in_ensembl_by_extids {
	my ($self,$extids,$species) = @_;
	#print "EXTIDS $extids\n";
	
  my $gene_adaptor = Bio::EnsEMBL::Registry->get_adaptor( $species, 'Core', 'Gene' );
	my $gene;
    unless (defined $gene_adaptor){return}
	$gene = $gene_adaptor->fetch_by_display_label($extids);
	return unless $gene;
}


=head2 search_in_ensembl_by_stable_id

 Title   : search_in_ensembl_by_stable_id
 Usage   : _search_by_ensembl_id($dbh,$gene_stable_id)
 Returns : %returnhash = ( 
					   'seq'	=> \%seq,
					   'member'	=> \%member,
					   'slice'	=> Bio::EnsEMBL::Slice
					 );
 Args    : Bio::EnsEMBL::DBSQL::DBAdaptor, ensembl_id
 
=cut

sub search_in_ensembl_by_stable_id{
	my ($self,$db,$stable_id,$type) = @_;
	unless (defined $type){$type = 'Gene'}
  my $gene_adaptor = Bio::EnsEMBL::Registry->get_adaptor( $db->organism, $db->db_type, $type );
	my $gene = $gene_adaptor->fetch_by_stable_id($stable_id);
	return $gene;
}

=head2 search_in_ensembl_by_slice

 Title   : search_mirna_in_ensembl_by_slice
 Usage   : search_mirna_in_ensembl_by_slice($ensdbh,$location_obj)
 Returns : Bio::EnsEMBL::Slice
 Args    :  Bio::EnsEMBL::DBSQL::DBAdaptor, Bio::Cogemir::Location
 
=cut

sub search_in_ensembl_by_slice{
	my ($self,$db,$location) = @_;
  my @genes;
  my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor($db->organism, $db->db_type, 'Slice' );
	my $slice = $slice_adaptor->fetch_by_region(lc($location->CoordSystem),$location->name,$location->start,$location->end,$location->strand);
	return $slice;
}

=head2 search_mirna_in_ensembl_by_slice

 Title   : search_mirna_in_ensembl_by_slice
 Usage   : search_mirna_in_ensembl_by_slice($ensdbh,$location_obj)
 Returns : Bio::EnsEMBL::Slice
 Args    :  Bio::EnsEMBL::DBSQL::DBAdaptor, Bio::Cogemir::Location
 
=cut

sub search_mirna_in_ensembl_by_slice{
	my ($self,$db,$location) = @_;
  my $slice = $self->search_in_ensembl_by_slice($db,$location);
	return undef unless $slice;
	my $gene = $self->_search_mirna_in_slice($db,$slice);
	return $gene;
}

sub _search_mirna_in_slice {
    my ($self,$db,$slice) = @_;
    foreach my $gene (@{$slice->get_all_Genes}){
        next if $gene->biotype ne 'miRNA';
        return $self->search_in_ensembl_by_stable_id($db,$gene->stable_id);
    }
}


=head2 search_host_in_ensembl_by_slice

 Title   : search_host_in_ensembl_by_slice
 Usage   : search_host_in_ensembl_by_slice($ensdbh,$location_obj)
 Returns : Bio::EnsEMBL::Slice
 Args    :  Bio::EnsEMBL::DBSQL::DBAdaptor, Bio::hostDB::Location
 
=cut

sub search_host_in_ensembl_by_slice{
	my ($self,$db,$location) = @_;
  my $slice = $self->search_in_ensembl_by_slice($db,$location);
	return unless $slice;
	my $gene = $self->_search_host_in_slice($db,$slice);
	return $gene;
}

sub _search_host_in_slice {
    my ($self,$db,$slice) = @_;
    foreach my $gene (@{$slice->get_all_Genes}){
        next if $gene->biotype =~ /RNA/i;
        return $self->search_in_ensembl_by_stable_id($db,$gene->stable_id);
    }
}



sub dbh{
	my ($self, $dbh) = @_;
	if( defined $dbh) {
	$self->{'dbh'} = $dbh;
    }
    return $self->{'dbh'};
	
}



sub settings{
	my ($self, $settings) = @_;
	if( defined $settings) {
	$self->{'settings'} = $settings;
    }
    return $self->{'settings'};
}

1;
