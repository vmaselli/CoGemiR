#! /usr/bin/perl -w
use strict;

use lib "$ENV{'HOME'}/src/cogemir-49/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl/modules";
use lib "$ENV{'HOME'}/src/ensembl-api/v49/ensembl-compara/modules";
use Bio::EnsEMBL::Registry;
use Bio::AlignIO;
use Data::Dumper;
use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
my $reg = "Bio::EnsEMBL::Registry";
my $registry = Bio::EnsEMBL::Registry->load_all("$ENV{'HOME'}/src/ensembl-config/registry_config.pl");




# Get a human slice for the region of interest
my $human_slice_adaptor = $reg->get_adaptor(
    "Mus musculus", "core", "Slice");
my $human_slice = $human_slice_adaptor->fetch_by_region(
    "chromosome", "16", 25683849, 25892188);

# Get the GenomeDB for Human
my $genome_db_adaptor = $reg->get_adaptor(
    "Multi", "compara", "GenomeDB");
my $human_genome_db = $genome_db_adaptor->fetch_by_name_assembly(
    "Homo sapiens", "NCBI36");

# Get all the BLASTZ_NET alignments for Human
my $method_link_species_set_adaptor = $reg->get_adaptor(
    "Multi", "compara", "MethodLinkSpeciesSet");
my $all_mlss = $method_link_species_set_adaptor->
    fetch_by_method_link_type_registry_aliases(
        "GERP_CONSERVATION_SCORE", ["Homo sapiens", "chimp", "rhesus", "mouse", "rat", "dog", "cow", "opossum", "platypus", "chicken"]);


my $csa = $reg->get_adaptor(
    "Multi", "compara", "ConservationScore");
my $conservation_scores = $csa->fetch_all_by_MethodLinkSpeciesSet_Slice($all_mlss, $human_slice);
foreach my $cons_score (@$conservation_scores) {
  print $human_slice->start + $cons_score->position - 1, " - ", $cons_score->diff_score, "\n";
}
