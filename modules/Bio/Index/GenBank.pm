#
# $Id: GenBank.pm,v 1.13 2003/06/04 08:36:40 heikki Exp $
#
# BioPerl module for Bio::Index::Abstract
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Index::GenBank - Interface for indexing (multiple) GenBank
.seq files (ie flat file GenBank format).

=head1 SYNOPSIS

    # Complete code for making an index for several
    # GenBank files
    use Bio::Index::GenBank;
    use strict;

    my $Index_File_Name = shift;
    my $inx = Bio::Index::GenBank->new('-filename' => $Index_File_Name, 
				       '-write_flag' => 'WRITE');
    $inx->make_index(@ARGV);

    # Print out several sequences present in the index
    # in gcg format
    use Bio::Index::GenBank;
    use Bio::SeqIO;
    use strict;

    my $Index_File_Name = shift;
    my $inx = Bio::Index::GenBank->new('-filename' => $Index_File_Name);
    my $seqio = new Bio::SeqIO(-format => 'gcg');
    foreach my $id (@ARGV) {
        my $seq = $inx->fetch($id); # Returns Bio::Seq object
        $seqio->write_seq($seq);
    }

    # alternatively
    my ($id, $acc);
    my $seq1 = $inx->get_Seq_by_id($id);
    my $seq2 = $inx->get_Seq_by_acc($acc);   

=head1 DESCRIPTION

Inherits functions for managing dbm files from Bio::Index::Abstract.pm,
and provides the basic funtionallity for indexing GenBank files, and
retrieving the sequence from them. Heavily snaffled from James Gilbert's
Fasta system. Note: for best results 'use strict'.

Details on configuration and additional example code are available in the
biodatabases.pod file.


=head1 FEED_BACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org             - General discussion
  http://bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via
email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Ewan Birney

Email - birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let's begin the code...


package Bio::Index::GenBank;

use vars qw(@ISA);
use strict;

use Bio::Index::AbstractSeq;
use Bio::Seq;

@ISA = qw(Bio::Index::AbstractSeq);

sub _type_stamp {
    return '__GenBank_FLAT__'; # What kind of index are we?
}

sub _version {
    return 0.1;
}

=head2 _index_file

  Title   : _index_file
  Usage   : $index->_index_file( $file_name, $i )
  Function: Specialist function to index GenBank format files.
            Is provided with a filename and an integer
            by make_index in its SUPER class.
  Example : 
  Returns : 
  Args    : 

=cut

sub _index_file {
    my( $self,
        $file, # File name
        $i     # Index-number of file being indexed
        ) = @_;
    
    my( $begin, # Offset from start of file of the start
                # of the last found record.
        $id,    # ID of last found record.
	@accs,   # accession of last record. Also put into the index
        );

    $begin = 0;

    open GenBank, $file or $self->throw("Can't open file for read : $file");

    # Main indexing loop
    $id = undef;
    @accs = ();
    while (<GenBank>) {
	if( /^\/\// ) {
	    if( ! defined $id ) {
		$self->throw("Got to a end of entry line for an GenBank flat file with no parsed ID. Considering this a problem!");
		next;
	    }
	    if( ! @accs ) {
		$self->warn("For id [$id] in GenBank flat file, got no accession number. Storing id index anyway");
	    }

	    $self->add_record($id, $i, $begin);

	    foreach my $acc (@accs) {
		if( $acc ne $id ) {
		    $self->add_record($acc, $i, $begin);
		}		
	    }
	    @accs = ();
	} elsif (/^LOCUS\s+(\S+)/) {
	    $id = $1;
	    # not sure if I like this. Assummes tell is in bytes.
	    # we could tell before each line and save it.
            $begin = tell(GenBank) - length( $_ ); 
	    
	} elsif (/^ACCESSION(.*)/) { # ignore ? if there.
	    @accs = ($1 =~ /\s*(\S+)/g);
	} elsif( /^VERSION(.*)/) {
	    my $a = $1;
	    $a =~ s/^\s+//;
	    $a =~ s/\s+$//;
	    $a =~ s/GI\://;
	    push @accs, split(/\s+/,$a);
	} else {
	    # do nothing
	}
    }

    close GenBank;
    return 1;
}

=head2 _file_format

 Title   : _file_format
 Usage   : Internal function for indexing system
 Function: Provides file format for this database
 Example :
 Returns : 
 Args    :


=cut

sub _file_format{
   my ($self,@args) = @_;

   return 'GenBank';
}

1;
