# $Id: AlignIO.pm,v 1.34 2003/12/10 22:43:25 heikki Exp $
#
# BioPerl module for Bio::AlignIO
#
#	based on the Bio::SeqIO module
#       by Ewan Birney <birney@sanger.ac.uk>
#       and Lincoln Stein  <lstein@cshl.org>
#
# Copyright Peter Schattner
#
# You may distribute this module under the same terms as perl itself
#
# _history
# October 18, 1999  SeqIO largely rewritten by Lincoln Stein
# September, 2000 AlignIO written by Peter Schattner

# POD documentation - main docs before the code

=head1 NAME

Bio::AlignIO - Handler for AlignIO Formats

=head1 SYNOPSIS

    use Bio::AlignIO;

    $inputfilename = "testaln.fasta";
    $in  = Bio::AlignIO->new(-file => $inputfilename ,
                             '-format' => 'fasta');
    $out = Bio::AlignIO->new(-file => ">out.aln.pfam" ,
                             '-format' => 'pfam');
    # note: we quote -format to keep older perl's from complaining.

    while ( my $aln = $in->next_aln() ) {
        $out->write_aln($aln);
    }

 #or

    use Bio::AlignIO;

    $inputfilename = "testaln.fasta";
    $in  = Bio::AlignIO->newFh(-file => $inputfilename ,
                               '-format' => 'fasta');
    $out = Bio::AlignIO->newFh('-format' => 'pfam');

    # World's shortest Fasta<->pfam format converter:
    print $out $_ while <$in>;

=head1 DESCRIPTION

Bio::AlignIO is a handler module for the formats in the AlignIO set
(eg, Bio::AlignIO::fasta). It is the officially sanctioned way of
getting at the alignment objects, which most people should use. The
resulting alignment is a Bio::Align::AlignI compliant object. See
L<Bio::Align::AlignI> for more information.

The idea is that you request a stream object for a particular format.
All the stream objects have a notion of an internal file that is read
from or written to. A particular AlignIO object instance is configured
for either input or output. A specific example of a stream object is
the Bio::AlignIO::fasta object.

Each stream object has functions

   $stream->next_aln();

and

   $stream->write_aln($aln);

also

   $stream->type() # returns 'INPUT' or 'OUTPUT'

As an added bonus, you can recover a filehandle that is tied to the
AlignIO object, allowing you to use the standard E<lt>E<gt> and print
operations to read and write sequence objects:

    use Bio::AlignIO;

     # read from standard input
    $stream = Bio::AlignIO->newFh(-format => 'Fasta');

    while ( $aln = <$stream> ) {
	# do something with $aln
    }

and

    print $stream $aln; # when stream is in output mode

This makes the simplest ever reformatter

    #!/usr/local/bin/perl

    $format1 = shift;
    $format2 = shift ||
        die "Usage: reformat format1 format2 < input > output";

    use Bio::AlignIO;

    $in  = Bio::AlignIO->newFh(-format => $format1 );
    $out = Bio::AlignIO->newFh(-format => $format2 );
    # note: you might want to quote -format to keep 
    #  older perl's from complaining.

    print $out $_ while <$in>;

AlignIO.pm is patterned on the module SeqIO.pm and shares most the
SeqIO.pm features.  One significant difference currently is that
AlignIO.pm usually handles IO for only a single alignment at a time
(SeqIO.pm handles IO for multiple sequences in a single stream.)  The
principal reason for this is that whereas simultaneously handling
multiple sequences is a common requirement, simultaneous handling of
multiple alignments is not. The only current exception is format
"bl2seq" which parses results of the Blast bl2seq program and which
may produce several alignment pairs.  This set of alignment pairs can
be read using multiple calls to next_aln.

Capability for IO for more than one multiple alignment - other than
for bl2seq format -(which may be of use for certain applications such
as IO for Pfam libraries) may be included in the future.  For this
reason we keep the name "next_aln()" for the alignment input routine,
even though in most cases only one alignment is read (or written) at a
time and the name "read_aln()" might be more appropriate.

=head1 CONSTRUCTORS

=head2 Bio::AlignIO-E<gt>new()

   $seqIO = Bio::AlignIO->new(-file => 'filename',   -format=>$format);
   $seqIO = Bio::AlignIO->new(-fh   => \*FILEHANDLE, -format=>$format);
   $seqIO = Bio::AlignIO->new(-format => $format);

The new() class method constructs a new Bio::AlignIO object.  The
returned object can be used to retrieve or print BioAlign
objects. new() accepts the following parameters:

=over 4

=item -file

A file path to be opened for reading or writing.  The usual Perl
conventions apply:

   'file'       # open file for reading
   '>file'      # open file for writing
   '>>file'     # open file for appending
   '+<file'     # open file read/write
   'command |'  # open a pipe from the command
   '| command'  # open a pipe to the command

=item -fh

You may provide new() with a previously-opened filehandle.  For
example, to read from STDIN:

   $seqIO = Bio::AlignIO->new(-fh => \*STDIN);

Note that you must pass filehandles as references to globs.

If neither a filehandle nor a filename is specified, then the module
will read from the @ARGV array or STDIN, using the familiar E<lt>E<gt>
semantics.

=item -format

Specify the format of the file.  Supported formats include:

   bl2seq      Bl2seq Blast output
   clustalw    clustalw (.aln) format
   emboss      EMBOSS water and needle format
   fasta       FASTA format
   maf         Multiple Alignment Format
   mase        mase (seaview) format
   mega        MEGA format
   meme        MEME format
   msf         msf (GCG) format
   nexus       Swofford et al NEXUS format
   pfam        Pfam sequence alignment format
   phylip      Felsenstein's PHYLIP format
   prodom      prodom (protein domain) format
   psi         PSI-BLAST format
   selex       selex (hmmer) format
   stockholm   stockholm format

Currently only those formats which were implemented in L<Bio::SimpleAlign>
have been incorporated in AlignIO.pm.  Specifically, mase, stockholm
and prodom have only been implemented for input. See the specific module
(e.g. L<Bio::AlignIO::meme>) for notes on supported versions.

If no format is specified and a filename is given, then the module
will attempt to deduce it from the filename suffix.  If this is unsuccessful,
Fasta format is assumed.

The format name is case insensitive.  'FASTA', 'Fasta' and 'fasta' are
all supported.

=back

=head2 Bio::AlignIO-E<gt>newFh()

   $fh = Bio::AlignIO->newFh(-fh   => \*FILEHANDLE, -format=>$format);
   $fh = Bio::AlignIO->newFh(-format => $format);
   # etc.

This constructor behaves like new(), but returns a tied filehandle
rather than a Bio::AlignIO object.  You can read sequences from this
object using the familiar E<lt>E<gt> operator, and write to it using print().
The usual array and $_ semantics work.  For example, you can read all
sequence objects into an array like this:

  @sequences = <$fh>;

Other operations, such as read(), sysread(), write(), close(), and printf() 
are not supported.

=over 1

=item -flush

By default, all files (or filehandles) opened for writing alignments
will be flushed after each write_aln() (making the file immediately
usable).  If you don't need this facility and would like to marginally
improve the efficiency of writing multiple sequences to the same file
(or filehandle), pass the -flush option '0' or any other value that
evaluates as defined but false:

  my $clustal = new Bio::AlignIO -file   => "<prot.aln",
                          -format => "clustalw";
  my $msf = new Bio::AlignIO -file   => ">prot.msf",
                          -format => "msf",
                          -flush  => 0; # go as fast as we can!
  while($seq = $clustal->next_aln) { $msf->write_aln($seq) }

=back

=head1 OBJECT METHODS

See below for more detailed summaries.  The main methods are:

=head2 $alignment = $AlignIO-E<gt>next_aln()

Fetch an alignment from a formatted file.

=head2 $AlignIO-E<gt>write_aln($aln)

Write the specified alignment to a file..

=head2 TIEHANDLE(), READLINE(), PRINT()

These provide the tie interface.  See L<perltie> for more details.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org               - General discussion
  http://bio.perl.org/MailList.html   - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Peter Schattner

Email: schattner@alum.mit.edu

=head1 CONTRIBUTORS

Jason Stajich, jason@bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# 'Let the code begin...

package Bio::AlignIO;

use strict;
use vars qw(@ISA);

use Bio::Root::Root;
use Bio::Seq;
use Bio::LocatableSeq;
use Bio::SimpleAlign;
use Bio::Root::IO;
use Bio::Tools::GuessSeqFormat;
@ISA = qw(Bio::Root::Root Bio::Root::IO);

=head2 new

 Title   : new
 Usage   : $stream = Bio::AlignIO->new(-file => $filename,
                                       '-format' => 'Format')
 Function: Returns a new seqstream
 Returns : A Bio::AlignIO::Handler initialised with 
           the appropriate format
 Args    : -file => $filename 
           -format => format
           -fh => filehandle to attach to

=cut

sub new {
    my ($caller,@args) = @_;
    my $class = ref($caller) || $caller;

    # or do we want to call SUPER on an object if $caller is an
    # object?
    if( $class =~ /Bio::AlignIO::(\S+)/ ) {
	my ($self) = $class->SUPER::new(@args);	
	$self->_initialize(@args);
	return $self;
    } else { 

	my %param = @args;
	@param{ map { lc $_ } keys %param } = values %param; # lowercase keys
	my $format = $param{'-format'} || 
	    $class->_guess_format( $param{-file} || $ARGV[0] );
        unless ($format) {
            if ($param{-file}) {
                $format = Bio::Tools::GuessSeqFormat->new(-file => $param{-file}||$ARGV[0] )->guess;
            }
            elsif ($param{-fh}) {
                $format = Bio::Tools::GuessSeqFormat->new(-fh => $param{-fh}||$ARGV[0] )->guess;
            }
        }
	$format = "\L$format";	# normalize capitalization to lower case
        $class->throw("Unknown format given or could not determine it [$format]")
            unless $format;

	return undef unless( $class->_load_format_module($format) );
	return "Bio::AlignIO::$format"->new(@args);
    }
}


=head2 newFh

 Title   : newFh
 Usage   : $fh = Bio::AlignIO->newFh(-file=>$filename,-format=>'Format')
 Function: does a new() followed by an fh()
 Example : $fh = Bio::AlignIO->newFh(-file=>$filename,-format=>'Format')
           $sequence = <$fh>;   # read a sequence object
           print $fh $sequence; # write a sequence object
 Returns : filehandle tied to the Bio::AlignIO::Fh class
 Args    :

=cut

sub newFh {
  my $class = shift;
  return unless my $self = $class->new(@_);
  return $self->fh;
}

=head2 fh

 Title   : fh
 Usage   : $obj->fh
 Function:
 Example : $fh = $obj->fh;      # make a tied filehandle
           $sequence = <$fh>;   # read a sequence object
           print $fh $sequence; # write a sequence object
 Returns : filehandle tied to the Bio::AlignIO::Fh class
 Args    :

=cut


sub fh {
  my $self = shift;
  my $class = ref($self) || $self;
  my $s = Symbol::gensym;
  tie $$s,$class,$self;
  return $s;
}

# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
  my($self,@args) = @_;

  $self->_initialize_io(@args);
  1;
}

=head2 _load_format_module

 Title   : _load_format_module
 Usage   : *INTERNAL AlignIO stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns : 
 Args    :

=cut

sub _load_format_module {
  my ($self,$format) = @_;
  my $module = "Bio::AlignIO::" . $format;
  my $ok;
  
  eval {
      $ok = $self->_load_module($module);
  };
  if ( $@ ) {
    print STDERR <<END;
$self: $format cannot be found
Exception $@
For more information about the AlignIO system please see the AlignIO docs.
This includes ways of checking for formats at compile time, not run time
END
  ;
    return;
  }
  return 1;
}

=head2 next_aln

 Title   : next_aln
 Usage   : $aln = stream->next_aln
 Function: reads the next $aln object from the stream
 Returns : a Bio::Align::AlignI compliant object
 Args    : 

=cut

sub next_aln {
   my ($self,$aln) = @_;
   $self->throw("Sorry, you cannot read from a generic Bio::AlignIO object.");
}

=head2 write_aln

 Title   : write_aln
 Usage   : $stream->write_aln($aln)
 Function: writes the $aln object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object

=cut

sub write_aln {
    my ($self,$aln) = @_;
    $self->throw("Sorry, you cannot write to a generic Bio::AlignIO object.");
}

=head2 _guess_format

 Title   : _guess_format
 Usage   : $obj->_guess_format($filename)
 Function: 
 Example : 
 Returns : guessed format of filename (lower case)
 Args    : 

=cut

sub _guess_format {
   my $class = shift;
   return unless $_ = shift;
   return 'fasta'   if /\.(fasta|fast|seq|fa|fsa|nt|aa)$/i;
   return 'maf'     if /\.maf/i;
   return 'msf'     if /\.(msf|pileup|gcg)$/i;
   return 'pfam'    if /\.(pfam|pfm)$/i;
   return 'selex'   if /\.(selex|slx|selx|slex|sx)$/i;
   return 'phylip'  if /\.(phylip|phlp|phyl|phy|phy|ph)$/i;
   return 'nexus'   if /\.(nexus|nex)$/i;
   return 'mega'     if( /\.(meg|mega)$/i );
   return 'clustalw' if( /\.aln$/i );
   return 'meme'     if( /\.meme$/i );
   return 'emboss'   if( /\.(water|needle)$/i );
   return 'psi'      if( /\.psi$/i );
}

sub DESTROY {
    my $self = shift;
    $self->close();
}

sub TIEHANDLE {
  my $class = shift;
  return bless {'alignio' => shift},$class;
}

sub READLINE {
  my $self = shift;
  return $self->{'alignio'}->next_aln() unless wantarray;
  my (@list,$obj);
  push @list,$obj  while $obj = $self->{'alignio'}->next_aln();
  return @list;
}

sub PRINT {
  my $self = shift;
  $self->{'alignio'}->write_aln(@_);
}

1;
