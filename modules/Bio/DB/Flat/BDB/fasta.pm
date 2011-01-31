#
# $Id: fasta.pm,v 1.4 2003/02/20 02:45:14 lstein Exp $
#
# BioPerl module for Bio::DB::Flat::BDB
#
# Cared for by Lincoln Stein <lstein@cshl.org>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::DB::Flat::BDB::fasta - fasta adaptor for Open-bio standard BDB-indexed flat file

=head1 SYNOPSIS

See Bio::DB::Flat.

=head1 DESCRIPTION

This module allows fasta files to be stored in Berkeley DB flat files
using the Open-Bio standard BDB-indexed flat file scheme.  You should
not be using this directly, but instead use it via Bio::DB::Flat.

=head1 FEEDBACK

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

=head1 SEE ALSO

L<Bio::DB::Flat>,

=head1 AUTHOR - Lincoln Stein

Email - lstein@cshl.org

=cut

package Bio::DB::Flat::BDB::fasta;

use strict;
use Bio::DB::Flat::BDB;
use vars '@ISA';

@ISA = qw(Bio::DB::Flat::BDB);

sub default_file_format { "fasta" }

sub seq_to_ids {
  my $self = shift;
  my $seq  = shift;
  my %ids;
  $ids{$self->primary_namespace} = $seq->primary_id;
  \%ids;
}


1;
