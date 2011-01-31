# $Id: psi.pm,v 1.7 2003/02/17 07:55:28 jason Exp $
#
# BioPerl module for Bio::AlignIO::psi
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::AlignIO::psi - Read/Write PSI-BLAST profile alignment files

=head1 SYNOPSIS

This module will parse PSI-BLAST output of the format seqid XXXX  

=head1 DESCRIPTION

This is for parser for a psi-blast blocks.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::AlignIO::psi;
use vars qw(@ISA $BlockLen $IdLength);
use strict;

$BlockLen = 100; 
$IdLength = 13;

# Object preamble - inherits from Bio::Root::Root

use Bio::SimpleAlign;
use Bio::AlignIO;
use Bio::LocatableSeq;

@ISA = qw(Bio::AlignIO);

=head2 new

 Title   : new
 Usage   : my $obj = new Bio::AlignIO::psi();
 Function: Builds a new Bio::AlignIO::psi object 
 Returns : Bio::AlignIO::psi
 Args    :

=cut

=head2 next_aln

 Title   : next_aln
 Usage   : $aln = $stream->next_aln()
 Function: returns the next alignment in the stream
 Returns : L<Bio::Align::AlignI> object
 Args    : NONE

=cut

sub next_aln {
    my ($self) = @_;
    my $aln;
    my %seqs;
    my @order;
    while( defined ($_ = $self->_readline ) ) {
	next if( /^\s+$/);
	if( !defined $aln ) {
	    $aln = new Bio::SimpleAlign;
	}
	my ($id,$s) = split;
	push @order, $id if( ! defined $seqs{$id});
	$seqs{$id} .= $s;
    }
    foreach my $id ( @order) {
	my $seq = new Bio::LocatableSeq(-seq => $seqs{$id},
					-id  => $id,
					-start => 1,
					-end   => length($seqs{$id}));
	$aln->add_seq($seq);
    }
    return $aln;
}

=head2 write_aln

 Title   : write_aln
 Usage   : $stream->write_aln(@aln)
 Function: writes the NCBI psi-format object (.aln) into the stream
 Returns : 1 for success and 0 for error
 Args    : L<Bio::Align::AlignI> object


=cut

sub write_aln {
    my ($self,$aln) = @_;
    unless( defined $aln && ref($aln) && 
	    $aln->isa('Bio::Align::AlignI') ) {
	$self->warn("Must provide a valid Bio::Align::AlignI to write_aln");
	return 0;
    }
    my $ct = 0;
    my @seqs = $aln->each_seq;
    my $len = 1;
    my $alnlen = $aln->length;
    my $idlen = $IdLength;
    my @ids = map { substr($_->display_id,0,$idlen) } @seqs;
    while( $len < $alnlen ) {
	my $start = $len;
	my $end   = $len + $BlockLen;
	if( $end > $alnlen ) { $end = $alnlen; }
	my $c = 0;
	foreach my $seq ( @seqs ) {
	    $self->_print(sprintf("%-".$idlen."s %s\n",
				  $ids[$c++],
				  $seq->subseq($start,$end)));
	}
	$self->_print("\n");
	$len += $BlockLen+1;
    }
    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

1;
