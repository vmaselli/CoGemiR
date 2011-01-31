# $Id: pfam.pm,v 1.10 2002/10/22 07:38:26 lapp Exp $
#
# BioPerl module for Bio::AlignIO::pfam

#	based on the Bio::SeqIO:: modules
#       by Ewan Birney <birney@sanger.ac.uk>
#       and Lincoln Stein  <lstein@cshl.org>
#
#       and the SimpleAlign.pm module of Ewan Birney
#
# Copyright Peter Schattner
#
# You may distribute this module under the same terms as perl itself
# _history
# September 5, 2000
# POD documentation - main docs before the code

=head1 NAME

Bio::AlignIO::pfam - pfam sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::AlignIO> class.

=head1 DESCRIPTION

This object can transform Bio::SimpleAlign objects to and from pfam flat
file databases.

=head1 FEEDBACK

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHORS - Peter Schattner

Email: schattner@alum.mit.edu


=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::AlignIO::pfam;
use vars qw(@ISA);
use strict;

use Bio::AlignIO;
use Bio::SimpleAlign;
@ISA = qw(Bio::AlignIO);

=head2 next_aln

 Title   : next_aln
 Usage   : $aln = $stream->next_aln()
 Function: returns the next alignment in the stream
 Returns : L<Bio::Align::AlignI> object
 Args    : NONE

=cut

sub next_aln {
    my $self = shift;
    my $entry;
    my $name;
    my $start;
    my $end;
    my $seq;
    my $add;
    my $acc;
    my %names;

    my $aln =  Bio::SimpleAlign->new(-source => 'pfam');

    while( $entry = $self->_readline) {
	chomp $entry;
	$entry =~ /^\/\// && last;
	if($entry !~ /^(\S+)\/(\d+)-(\d+)\s+(\S+)\s*/ ) {
	    $self->throw("Found a bad line [$_] in the pfam format alignment");
	    next;
	}

	$name = $1;
	$start = $2;
	$end = $3;
	$seq = $4;


	$add = new Bio::LocatableSeq('-seq'=>$seq,
			    '-id'=>$name,
			    '-start'=>$start,
			    '-end'=>$end,
			    );

	$aln->add_seq($add);
	
    }

#  If $end <= 0, we have either reached the end of
#  file in <> or we have encountered some other error
#
   if ($end <= 0) { undef $aln;}

      return $aln;
}



=head2 write_aln

 Title   : write_aln
 Usage   : $stream->write_aln(@aln)
 Function: writes the $aln object into the stream
 Returns : 1 for success and 0 for error
 Args    : L<Bio::Align::AlignI> object


=cut

sub write_aln {
   my ($self,@aln) = @_;
   if( @aln > 1 ) { $self->warn("Only the 1st pfam alignment will be output since the format does not support multiple alignments in the same file"); }
   my $aln = shift @aln;
   if( ! $aln || ! $aln->isa('Bio::Align::AlignI')  ) { 
       $self->warn("Must provide a Bio::Align::AlignI object when calling write_aln");
       next;
   }
   my ($namestr,$seq,$add);
   my ($maxn);
   $maxn = $aln->maxdisplayname_length();
   
   foreach $seq ( $aln->each_seq() ) {
       $namestr = $aln->displayname($seq->get_nse());
       $add = $maxn - length($namestr) + 2;
       $namestr .= " " x $add;
	  $self->_print (sprintf("%s  %s\n",$namestr,$seq->seq())) or return;
   }
   $self->flush() if $self->_flush_on_write && defined $self->_fh;
   return 1;
}

1;
