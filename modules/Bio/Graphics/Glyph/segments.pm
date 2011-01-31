package Bio::Graphics::Glyph::segments;
#$Id: segments.pm,v 1.31 2003/11/15 20:21:08 lstein Exp $

use strict;
use Bio::Location::Simple;
use Bio::Graphics::Glyph::generic;
use Bio::Graphics::Glyph::segmented_keyglyph;
use vars '@ISA';

use constant RAGGED_START_FUZZ => 25;  # will show ragged ends of alignments
                                       # up to this many bp.
use constant DEBUG => 0;

@ISA = qw( Bio::Graphics::Glyph::segmented_keyglyph
	   Bio::Graphics::Glyph::generic
	 );

my %complement = (g=>'c',a=>'t',t=>'a',c=>'g',n=>'n',
		  G=>'C',A=>'T',T=>'A',C=>'G',N=>'N');

sub pad_left {
  my $self = shift;
  return $self->SUPER::pad_left unless $self->option('draw_target') && $self->option('ragged_start') && $self->dna_fits;
  return $self->SUPER::pad_left unless $self->level > 0;
  my $target = eval {$self->feature->hit} or return $self->SUPER::pad_left;
  return $self->SUPER::pad_left unless $target->start<$target->end && $target->start < RAGGED_START_FUZZ;
  return ($target->start-1) * $self->scale;
}

sub pad_right {
  my $self = shift;
  return $self->SUPER::pad_right unless $self->level > 0;
  return $self->SUPER::pad_right unless $self->option('draw_target') && $self->option('ragged_start') && $self->dna_fits;
  my $target = eval {$self->feature->hit} or return $self->SUPER::pad_right;
  return $self->SUPER::pad_right unless $target->end < $target->start && $target->start < RAGGED_START_FUZZ;
  return ($target->end-1) * $self->scale;
}

# group sets connector to 'solid'
sub connector {
  my $self = shift;
  return $self->SUPER::connector(@_) if $self->all_callbacks;
  return ($self->SUPER::connector(@_) || 'solid');
}

# never allow our components to bump
sub bump {
  my $self = shift;
  return $self->SUPER::bump(@_) if $self->all_callbacks;
  return 0;
}

sub fontcolor {
  my $self = shift;
  return $self->SUPER::fontcolor unless $self->option('draw_target') || $self->option('draw_dna');
  return $self->SUPER::fontcolor unless $self->dna_fits;
  return $self->bgcolor;
}

sub draw_component {
  my $self = shift;
  my ($draw_dna,$draw_target) = ($self->option('draw_dna'),$self->option('draw_target'));
  return $self->SUPER::draw_component(@_)
    unless $draw_dna || $draw_target;
  return $self->SUPER::draw_component(@_) unless $self->dna_fits;

  my $dna = $draw_target ? eval {$self->feature->hit->seq}
                         : eval {$self->feature->seq};
  return $self->SUPER::draw_component(@_) unless length $dna > 0;  # safety

  my $show_mismatch = $draw_target && $self->option('show_mismatch');
  my $genomic       = eval {$self->feature->seq} if $show_mismatch;

  my $gd = shift;
  my ($x1,$y1,$x2,$y2) = $self->bounds(@_);

  # adjust for nonaligned left end (for ESTs...)  The size given here is roughly sufficient
  # to show a polyA end or a C. elegans trans-spliced leader.
  my $offset = 0;
  eval {  # protect against data structures that don't implement the target() method.
    if ($draw_target && $self->option('ragged_start')){
      my $target = $self->feature->hit;
      if ($target->start < $target->end && $target->start < RAGGED_START_FUZZ  
	  && $self->{partno} == 0) {
	$offset = $target->start - 1;
	if ($offset > 0) {
	  $dna       = $target->subseq(1-$offset,0)->seq        . $dna;
	  $genomic   = $self->feature->subseq(1-$offset,0)->seq . $genomic;
	  $x1        -= $offset * $self->scale;
	}
      }
      elsif ($target->end < $target->start && 
	     $target->end < RAGGED_START_FUZZ && $self->{partno} == $self->{total_parts}) {
	$offset = $target->end - 1;
	if ($offset > 0) {
	  $dna       .= $target->factory->get_dna($target,$offset,1);
	  $genomic    = $self->feature->subseq(-$offset,0)->seq . $genomic;
	  $x2        += $offset * $self->scale;
	  $offset = 0;
	}
      }
    }
  };

  $self->draw_dna($gd,$offset,lc $dna,lc $genomic,$x1,$y1,$x2,$y2);
}

sub draw_dna {
  my $self = shift;

  my ($gd,$start_offset,$dna,$genomic,$x1,$y1,$x2,$y2) = @_;
  my $pixels_per_base = $self->scale;
  my $feature         = $self->feature;
  my $target          = $feature->target;
  my $strand          = $feature->strand;

  my @segs;

  if ($strand < 0) {
    $dna     = $self->reversec($dna);
    $genomic = $self->reversec($genomic);
    $strand  = 1;
  }
  my $complement      = $strand < 0;

  # oh dear, undoing what we just did!
  if ($self->{flip}) {
    $dna     = $self->reversec($dna);
    $genomic = $self->reversec($genomic);
    $strand            *= -1;
  }

  warn "strand = $strand, complement = $complement" if DEBUG;

  warn "feature = $feature: length(dna) = ",length($dna)," length(genomic) = ",length($genomic), 
    " target = ",$feature->target->start,'..',$feature->target->end if DEBUG;

  my $realign = !defined($self->option('realign')) || $self->option('realign');

  if ($realign && eval { require Bio::Graphics::Browser::Realign}) {
    warn "$genomic\n$dna\n" if DEBUG;
    warn "strand = $strand" if DEBUG;
    @segs = Bio::Graphics::Browser::Realign::align_segs($genomic,$dna);
    for my $seg (@segs) {
      my $src = substr($genomic,$seg->[0],$seg->[1]-$seg->[0]+1);
      my $tgt = substr($dna,    $seg->[2],$seg->[3]-$seg->[2]+1);
      warn "@$seg\n$src\n$tgt" if DEBUG;
    }
  } else {
    @segs = [0,length($genomic)-1,0,length($dna)-1];
  }

  my $color = $self->fgcolor;
  my $font  = $self->font;
  my $lineheight = $font->height;
  my $fontwidth  = $font->width;
  $y1 -= $lineheight/2 - 3;
  my $pink = $self->factory->translate_color('lightpink');
  my $panel_end = $self->panel->right;

  my $start       = $self->map_no_trunc($self->feature->start- $start_offset);
  my $end         = $self->map_no_trunc($self->feature->end  - $start_offset);
  my $true_target = $self->option('true_target');
  my $show_complement  = $true_target && $feature->strand < 0;


  my ($last,$tlast);
  for my $seg (@segs) {

    # fill in misaligned bits with dashes and bases
    if (defined $last) {
      my $delta  = $seg->[0] - $last  - 1;
      my $tdelta = $seg->[2] - $tlast - 1;
      warn "src gap [$last,$seg->[0]], tgt gap [$tlast,$seg->[2]], delta = $delta, tdelta = $tdelta\n" if DEBUG;

      my $gaps   = $delta - $tdelta;
      my @fill_in = split '',substr($dna,$tlast+1,$tdelta) if $tdelta > 0;
      unshift @fill_in,('-')x$gaps if $gaps > 0;

      warn "gaps = $gaps, fill_in = @fill_in\n" if DEBUG;

      my $distance          = $pixels_per_base * ($delta+1);
      my $pixels_per_target = $gaps >= 0 ? $pixels_per_base : $distance/(@fill_in+1);

      warn "pixels_per_base = $pixels_per_base, pixels_per_target=$pixels_per_target\n" if DEBUG;
      my $offset = $self->{flip} ?  $end + ($last-1)*$pixels_per_base : $start + $last*$pixels_per_base;

      for (my $i=0; $i<@fill_in; $i++) {

	my $x = $self->{flip} ? int($offset + ($i+1)*$pixels_per_target + 0.5)
                              : int($offset + ($i+1)*$pixels_per_target + 0.5);

	$self->filled_box($gd,$x,$y1+3,$x+$fontwidth,$y1+$lineheight-3,$pink,$pink) unless $gaps;
	$gd->char($font,$x,$y1,$show_complement ? $complement{$fill_in[$i]} : $fill_in[$i],$color);
      }
    }

    my @genomic = split '',substr($genomic,$seg->[0],$seg->[1]-$seg->[0]+1);
    my @bases   = split '',substr($dna,    $seg->[2],$seg->[3]-$seg->[2]+1);
    for (my $i = 0; $i<@bases; $i++) {
      my $x = $self->{flip} ? int($end   + ($seg->[0] + $i - 1)*$pixels_per_base + 0.5)
                            : int($start + ($seg->[0] + $i)    *$pixels_per_base + 0.5);
      next if $x+1 < $x1;
      last if $x+1 > $x2;
      if ($genomic[$i] && lc($bases[$i]) ne lc($complement ? $complement{$genomic[@genomic - $i - 1]} : $genomic[$i])) {
	$self->filled_box($gd,$x,$y1+3,$x+$fontwidth,$y1+$lineheight-3,$pink,$pink);
      }
      $gd->char($font,$x,$y1,$show_complement ? $complement{$bases[$i]} || $bases[$i] : $bases[$i],$color);
    }
    $last  = $seg->[1];
    $tlast = $seg->[3];
  }

}

# Override _subseq() method to make it appear that a top-level feature that
# has no subfeatures appears as a feature that has a single subfeature.
# Otherwise at high mags gaps will be drawn as components rather than
# as connectors.  Because of differing representations of split features
# in Bio::DB::GFF::Feature and Bio::SeqFeature::Generic, there is
# some breakage of encapsulation here.
sub _subseq {
  my $self    = shift;
  my $feature = shift;
  my @subseq  = $self->SUPER::_subseq($feature);
  return @subseq if @subseq;
  if ($self->level == 0 && !@subseq && !eval{$feature->compound}) {
    # my($start,$end) = ($feature->start,$feature->end);
    # ($start,$end) = ($end,$start) if $start > $end; # to keep Bio::Location::Simple from bitching
    # return Bio::Location::Simple->new(-start=>$start,-end=>$end);
    return $self->feature;
  } else {
    return;
  }
}

1;

__END__

=head1 NAME

Bio::Graphics::Glyph::segments - The "segments" glyph

=head1 SYNOPSIS

  See L<Bio::Graphics::Panel> and L<Bio::Graphics::Glyph>.

=head1 DESCRIPTION

This glyph is used for drawing features that consist of discontinuous
segments.  Unlike "graded_segments" or "alignment", the segments are a
uniform color and not dependent on the score of the segment.

=head2 OPTIONS

The following options are standard among all Glyphs.  See
L<Bio::Graphics::Glyph> for a full explanation.

  Option      Description                      Default
  ------      -----------                      -------

  -fgcolor      Foreground color	       black

  -outlinecolor	Synonym for -fgcolor

  -bgcolor      Background color               turquoise

  -fillcolor    Synonym for -bgcolor

  -linewidth    Line width                     1

  -height       Height of glyph		       10

  -font         Glyph font		       gdSmallFont

  -connector    Connector type                 0 (false)

  -connector_color
                Connector color                black

  -label        Whether to draw a label	       0 (false)

  -description  Whether to draw a description  0 (false)

  -strand_arrow Whether to indicate            0 (false)
                 strandedness

  -hilite       Highlight color                undef (no color)

In addition, the following glyph-specific options are recognized:

  -draw_dna     If true, draw the dna residues 0 (false)
                 when magnification level
                 allows.

  -draw_target  If true, draw the dna residues 0 (false)
                 of the TARGET sequence when
                 magnification level allows.
                 See "Displaying Alignments".

  -ragged_start When combined with -draw_target, 0 (false)
                 draw a few bases beyond the end
                 of the alignment. See "Displaying Alignments".

  -show_mismatch When combined with -draw_target, 0 (false)
                 highlights mismatched bases in
                 pink.  See "Displaying Alignments".

  -true_target   Show the true sequence of the    0 (false)
                 matched DNA, even if the match
                 is on the minus strand. See "Displaying Alignments".

  -realign       Attempt to realign sequences at  1 (true)
                 high mag to account for indels. See "Displaying Alignments".

The -draw_target and -ragged_start options only work with seqfeatures
that implement the hit() method (Bio::SeqFeature::SimilarityPair).
The -ragged_start option is mostly useful for looking for polyAs and
cloning sites at the beginning of ESTs and cDNAs.  Currently there is
no way of activating ragged ends.  The length of the ragged starts is
hard-coded at 25 bp, and the color of mismatches is hard-coded as
light pink.

At high magnifications, minus strand matches will automatically be
shown as their reverse complement (so that the match has the same
sequence as the plus strand of the source dna).  If you prefer to see
the actual sequence of the target as it appears on the minus strand,
then set -true_target to true.

=head2 Displaying Alignments

When the B<-draw_target> option is true, this glyph can be used to
display nucleotide alignments such as BLAST, FASTA or BLAT
similarities.  At high magnification, this glyph will attempt to show
how the sequence of the source (query) DNA matches the sequence of the
target (the hit).  For this to work, the feature must implement the
hit() method, and both the source and the target DNA must be
available.  If you pass the glyph a series of
Bio::SeqFeature::SimilarityPair objects, then these criteria will be
satisified.

Without additional help, this glyph cannot display gapped alignments
correctly.  To display gapped alignments, you can use the
Bio::Graphics::Brower::Realign module, which is part of the Generic
Genome Browser package (http://www.gmod.org).  If you wish to install
the Realign module and not the rest of the package, here is the
recipe:

  cd Generic-Genome-Browser-1.XX
  perl Makefile.PL DO_XS=1
  make
  make install_site

If possible, build the gbrowse package with the DO_XS=1 option.  This
compiles a C-based DP algorithm that both gbrowse and gbrowse_details
will use if they can.  If DO_XS is not set, then the scripts will use
a Perl-based version of the algorithm that is 10-100 times slower.

The display of alignments can be tweaked using the -ragged_start,
-show_mismatch, -true_target and -realign options.  See the options
section for further details.

=head1 BUGS

Please report them.

=head1 SEE ALSO


L<Bio::Graphics::Panel>,
L<Bio::Graphics::Glyph>,
L<Bio::Graphics::Glyph::arrow>,
L<Bio::Graphics::Glyph::cds>,
L<Bio::Graphics::Glyph::crossbox>,
L<Bio::Graphics::Glyph::diamond>,
L<Bio::Graphics::Glyph::dna>,
L<Bio::Graphics::Glyph::dot>,
L<Bio::Graphics::Glyph::ellipse>,
L<Bio::Graphics::Glyph::extending_arrow>,
L<Bio::Graphics::Glyph::generic>,
L<Bio::Graphics::Glyph::graded_segments>,
L<Bio::Graphics::Glyph::heterogeneous_segments>,
L<Bio::Graphics::Glyph::line>,
L<Bio::Graphics::Glyph::pinsertion>,
L<Bio::Graphics::Glyph::primers>,
L<Bio::Graphics::Glyph::rndrect>,
L<Bio::Graphics::Glyph::segments>,
L<Bio::Graphics::Glyph::ruler_arrow>,
L<Bio::Graphics::Glyph::toomany>,
L<Bio::Graphics::Glyph::transcript>,
L<Bio::Graphics::Glyph::transcript2>,
L<Bio::Graphics::Glyph::translation>,
L<Bio::Graphics::Glyph::triangle>,
L<Bio::DB::GFF>,
L<Bio::SeqI>,
L<Bio::SeqFeatureI>,
L<Bio::Das>,
L<GD>

=head1 AUTHOR

Lincoln Stein E<lt>lstein@cshl.orgE<gt>

Copyright (c) 2001 Cold Spring Harbor Laboratory

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=cut
