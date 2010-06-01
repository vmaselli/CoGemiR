#! /usr/bin/perl -w
=pod

=head1 NAME - cogemir_main.pl

=head1 SYNOPSIS    

=head1 DESCRIPTION

=head1 METHODS

=cut

BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"; }#settings

my $debug = 1;

use vars qw(@ISA);
use strict;
use lib $::lib{'cogemir'};

use Test;
use Data::Dumper;
use File::Spec;
use Time::localtime;

=pod

=head1 FIRST PART


- controlla che ci siano tutte le librerie che servono
- se non ci sono chiede di scrivere un path relativo e controlla
- se non ci sono esce

- controlla che ci siano i db mysql di ensembl aggiornati secondo quanto stabilito

- scarica i dati da mirbase via ftp se da aggiornare
- crea una cartella dedicata

- scarica i dati da symatlas via ftp se da aggiornare
- crea una cartella dedicata

- scarica i dati da ncbi via ftp per i genomi non presenti in ensembl se da aggiornare
- crea una cartella dedicata (da decidere con i sistemisti)

=cut

=pod

=head1 SECOND PART

- lancia i vari script che ora lancio manualmente per la creazione dei database
    - mirbase
        load_mirbase_data crea un db aggiornato (implementare la rimozione di quello precedente dopo un dump) e carica i dati nelle tabelle.
        lavora in automatico sulla cartella creata ad hoc piu' sopra in questo stesso script.
    - symatlas
    	load_symatlas_data crea un db aggiornato (implementare la rimozione di quello precedente dopo un dump) e carica i dati nelle tabelle.
        lavora in automatico sulla cartella creata ad hoc piu' sopra in questo stesso script.
    - cogemir base (prima delle analisi di predizione)


=cut

#system ("nohup perl $ENV{'HOME'}/src/cogemir-beta/scripts/pipeline/load_mirbase_data.pl &");
#sleep(3600); # un'ora di pausa
#system ("nohup perl $ENV{'HOME'}/src/cogemir-beta/scripts/pipeline/load_symatlas_data.pl &");
#sleep(86400); #un giorno di pausa

my %clade = ('Homo sapiens' => 'Primates',
            'Aedes aegypti' => 'Arthropoda',
            'Anopheles gambiae' => 'Arthropoda',
            'Bos taurus' => 'Mammalia',
            'Caenorhabditis elegans' => 'Nematoda',
            'Canis familiaris' => 'Mammalia',
            'Cavia porcellus' => 'Rodentia',
            'Ciona intestinalis' => 'Tunicates',
            'Ciona savignyi' => 'Tunicates',
            'Danio rerio' => 'Pisces',
            'Dasypus novemcinctus' => 'Mammalia',
            'Dipodomys ordii' => 'Rodentia',
            'Drosophila melanogaster' => 'Arthropoda',
            'Echinops telfairi' => 'Mammalia',
            'Equus caballus' =>'Mammalia',
            'Erinaceus europaeus' => 'Mammalia',
            'Felis catus' => 'Mammalia',
            'Gallus gallus' => 'Aves',
            'Gasterosteus aculeatus' => 'Pisces' ,
            'Gorilla gorilla' => 'Primates',
            'Loxodonta africana' => 'Mammalia',
            'Macaca mulatta' => 'Primates',
            'Microcebus murinus' => 'Primates',
            'Monodelphis domestica' =>'Marsupials',
            'Mus musculus' => 'Rodentia',
            'Myotis lucifugus' => 'Mammalia',
            'Ochotona princeps'=> 'Rodentia',
            'Ornithorhynchus anatinus' => 'Mammalia',
            'Oryctolagus cuniculus' => 'Rodentia',
            'Oryzias latipes' => 'Pisces',
            'Otolemur garnettii' => 'Primates',
            'Pan troglodytes' => 'Primates',
            'Pongo pygmaeus' =>'Primates',
            'Procavia capensis' => 'Mammalia',
            'Pteropus vampyrus' => 'Mammalia',
            'Rattus norvegicus' => 'Rodentia',
            'Saccharomyces cerevisiae' => 'Yeast',
            'Sorex araneus' => 'Mammalia',
            'Spermophilus tridecemlineatus' =>'Rodentia',
            'Takifugu rubripes' => 'Pisces',
            'Tarsius syrichta' => 'Primates',
            'Tursiops truncatus' => 'Mammalia',
            'Tetraodon nigroviridis' => 'Pisces',
            'Tupaia belangeri' => 'Rodentia',
            'Vicugna pacos' => 'Mammalia',
            'Xenopus tropicalis' => 'Amphibia'
          );
          

foreach my $species (keys %clade){
	my $clade = $clade{$species};
	system ("perl $ENV{'HOME'}/src/cogemir-beta/scripts/pipeline/load_cogemir_base.pl -d 1 -s $species -c $clade");

}


=pod

=head1 THIRD PART

- lancia i vari script di analisi e di predizione
- lancia script per tabelle preformate per web

=cut

