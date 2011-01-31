# $Id: Scansite.pm,v 1.4 2003/12/16 00:25:26 allenday Exp $
#
# BioPerl module for Bio::Tools::Analysis::Protein::Scansite
#
# Cared for by Richard Adams <richard.adams@ed.ac.uk>
#
# Copyright Richard Adams
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::Analysis::Protein::Scansite - a wrapper around the Scansite server

=head1 SYNOPSIS

  use Bio::Tools::Analysis::Protein::Scansite;

  my $seq; # a Bio::PrimarySeqI object

  my $tool = Bio::Tools::Analysis::Protein::Scansite->new
     ( -seq => $seq->primary_seq(),
      ); 

  # run Scansite prediction on a sequence
   $tool->run();

  # alternatively you can say
  $tool->seq($seq->primary_seq)->run;

  die "Could not get a result" unless $tool->status =~ /^COMPLETED/;

  print $tool->result;     # print raw prediction to STDOUT

  foreach my $feat ( $tool->result('Bio::SeqFeatureI') ) {

      # do something to SeqFeature
      # e.g. print as GFF
      print $feat->gff_string, "\n";
      # or store within the sequence - if it is a Bio::RichSeqI
      $seq->add_SeqFeature($feat);

 }

=head1 DESCRIPTION

This class is wrapper around the Scansite 2.0 server which produces
predictions for serine, threonine and tyrosine phosphorylation sites
in eukaryotic proteins. At present this is a basic wrapper for the
"Scan protein by input sequence" functionality, which takes a sequence
and searches for motifs. Optionally you can select the search
strincency as well. At present searches for specific phosphorylation
sites isn't supported, all predicted sites are returned.

See L<http://www.scansite.mit.edu/>.

This inherits Bio::SimpleAnalysisI which hopefully
 makes it easier to write wrappers on various services. This class
uses a web resource and therefore inherits from Bio::WebAgent.

=head1 SEE ALSO

L<Bio::SimpleAnalysisI>, 
L<Bio::WebAgent>

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                       - General discussion
  http://bio.perl.org/MailList.html           - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHORS

Richard Adams, Richard.Adams@ed.ac.uk, 

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Tools::Analysis::Protein::Scansite;
use vars qw(@ISA  $FLOAT @STRINGENCY );
use strict;
use IO::String;
use Bio::SeqIO;
use HTTP::Request::Common qw (POST);
use Bio::SeqFeature::Generic;
use Bio::Tools::Analysis::SimpleAnalysisBase;

@ISA = qw(Bio::Tools::Analysis::SimpleAnalysisBase);

$FLOAT = '[+-]?\d*\.\d*';
@STRINGENCY = qw(High Medium Low);
my $URL = 'http://scansite.mit.edu/cgi-bin/motifscan_seq';


    my $ANALYSIS_SPEC =
        {
         'name'        => 'Scansite',
         'type'        => 'Protein',
         'version'     => '2.0',
         'supplier'    => 'Massachusetts Institute of Technology',
         'description' => 'Prediction of serine, threonine and tyrosine
                             phosphorylation sites in eukaryotic proteins',
        };

    my $INPUT_SPEC =
        [
         {
          'mandatory' => 'true',
          'type'      => 'Bio::PrimarySeqI',
          'name'      => 'seq',
         },
         {
          'mandatory' => 'false',
          'type'      => 'text',
          'name'      => 'protein_id',
          'default'   => 'unnamed',
         },
         {
          'mandatory' => 'false',
          'type'      => 'text',
          'name'      => 'stringency',
          'default'   => 'High',
         },
        ];

    my $RESULT_SPEC =
        {
         ''                 => 'bulk',  # same as undef
         'Bio::SeqFeatureI' => 'ARRAY of Bio::SeqFeature::Generic',
         'raw'              => 'Array of {motif=>, percentile=>, position=>,
					  protein=>, score=>, site=>, zscore=>
                                          sequence=>
	     				 }',
        };


=head2 result
 
 Name    : result
 Usage   : $job->result (...)
 Returns : a result created by running an analysis
 Args    : none (but an implementation may choose
           to add arguments for instructions how to process
           the raw result)

The method returns a scalar representing a result of an executed
job. If the job was terminated by an error the result

This implementation returns differently processed data depending on
argument:

=over 3

=item undef

Returns the raw ASCII data stream but without HTML tags

=item 'Bio::SeqFeatureI'

The argument string defined the type of bioperl objects returned in an
array.  The objects are L<Bio::SeqFeature::Generic>.

=item 'parsed'

Returns a reference to an array of hashes containing the data of one
phosphorylation site prediction. Key values are :

motif, percentile, position, protein, score, site, zscore,  sequence.


=back


=cut

sub result {
    my ($self,$value) = @_;
	if( !exists($self->{'_result'}) || $self->status ne 'COMPLETED'){
		$self->throw("Cannot get results, analysis not run!");
		}	
    my @fts;

    if ($value ) {
		if ($value eq 'Bio::SeqFeatureI') {
			for my $hit (@{$self->{'_parsed'}}) {
				push @fts, Bio::SeqFeature::Generic->new(
					-start       => $hit->{'position'},
					-end         => $hit->{'position'},
				    -primary_tag => 'Site',
					-source      => 'Scansite',
					-tag => {
						score     => $hit->{'score'},
						zscore    => $hit->{'zscore'},
						motif     => $hit->{'motif'},
						sequence  => $hit->{'sequence'},
							},
				);
			}
			return @fts;
		}
		elsif ($value eq 'meta') {
			$self->throw("No meta sequences available in this analysis!");
			}
		## else get here
		return $self->{'_parsed'};
    }

    return $self->{'_result'};
}

=head2  stringency

 Usage   : $job->stringency(...)
 Returns  : The significance stringency of a prediction
 Args     : None (retrieves value) or 'High', 'Medium' or 'Low'.
 Purpose  : Get/setter of the stringency to be sumitted for analysis.

=cut

sub stringency {
   my ($self,$value) = @_;
   if( $value) {
       if (! grep{$_=~ /$value/i}@STRINGENCY ) {
           $self->throw("I need a stringency of [".
						join " ", @STRINGENCY    .
						"], not [$value]");
       }
       $self->{'_stringency'} = $value;
       return $self;
   }
   return $self->{'_stringency'} || $self->input_spec->[4]{'default'} ;
}

=head2  protein_id

 Usage   : $job->protein_id(...)
 Returns  : The sequence id of the protein or 'unnamed' if not set. 
 Args     : None  
 Purpose  : Getter of the seq_id. Returns the display_id of the sequence
				object. 

=cut

sub protein_id {
	my $self = shift;
	return defined ($self->seq())? $self->seq->display_id()
				     : $self->input_spec->[1]{'default'};
}

sub _init 
		{
	my $self = shift;
	$self->url($URL);
	$self->{'_ANALYSIS_SPEC'} = $ANALYSIS_SPEC;
	$self->{'_INPUT_SPEC'}    = $INPUT_SPEC;
	$self->{'_RESULT_SPEC'}   = $RESULT_SPEC;
	$self->{'_ANALYSIS_NAME'} = $ANALYSIS_SPEC->{name};
	return $self;
}

sub _run {
    my $self = shift;

    # format the sequence into fasta
	$self->delay(1);
    # delay repeated calls by default by 3 sec, set delay() to change
    $self->sleep;

    $self->status('TERMINATED_BY_ERROR');

    my $request = POST $self->url,
            Content      => [sequence     => $self->seq->seq(),
							 protein_id   => $self->protein_id(),
							 motif_option => 'all',
							 motifs       => '',
							 motif_groups => '',
							 stringency   => $self->stringency(),
						 	 domain_flag  => '',
							 submit       => "Submit Request",
							];
	## raw html report, 
    my $content = $self->request($request);
    my $text    = $content->content;

	##access result data from tag in html
	my @parsed_Results = ();
	my @unwantedParams = qw(db source class);
	my @results        = split /sitestats\.phtml\?/, $text;
	shift @results; 

	##this module generates 'parsed' output directly from html,
	## avoids having toparse twice. 

	for my $hit (@results) {
		## get results string
		my ($res) = $hit =~ /^(.+?)"/;

		#get key value pairs
		my %params = $res =~/(\w+)=([^&]+)/g;

		##remove unwanted data from hash
		map{delete $params{$_}} @unwantedParams;
		push @parsed_Results, \%params;
	}  
	
	## now generate text output in table format
	my $out_Str = '';
	$out_Str   .=  $self->_make_header(\@parsed_Results);
	$out_Str   .=  $self->_add_data(\@parsed_Results);
		

    $self->{'_result'} = $out_Str;
	$self->{'_parsed'} = \@parsed_Results;
	
	## is successssful if there are results or if there are no results and
	## this beacuse there are no matches, not because of parsing errors etc.
    $self->status('COMPLETED') if $text ne ''       &&
	(scalar @results > 0 ||	
	(scalar @results == 0 && $text =~/No sites found/));
}

sub _make_header {
	my ($self, $res) = @_;
	my $header = '';
	for my $k (sort keys %{$res->[0]} ){
		next if $k eq 'sequence';
		$header .= $k;
		$header .= ' 'x(12 -length($k));
	}
	$header .= "sequence\n\n";
	return $header;
}

sub _add_data {
	my ($self, $res) = @_;
	my $outstr = '';
	for my $hit  (@$res) {
		for my $k (sort keys %$hit ){
			next if $k eq 'sequence';
			$outstr .= $hit->{$k};
			$outstr .= ' 'x(12 - length($hit->{$k}));
			}
		$outstr .= $hit->{'sequence'}. "\n" if $hit->{'sequence'};
	}
	return $outstr;


}
	

1;
