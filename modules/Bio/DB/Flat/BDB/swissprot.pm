#
# $Id: swissprot.pm,v 1.1 2003/02/20 02:45:14 lstein Exp $
#
# BioPerl module for Bio::DB::Flat::BDB::swissprot
#
# Cared for by Lincoln Stein <lstein@cshl.org>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::DB::Flat::BDB::swissprot - swissprot adaptor for Open-bio standard BDB-indexed flat file

=head1 SYNOPSIS

See Bio::DB::Flat.

=head1 DESCRIPTION

This module allows swissprot files to be stored in Berkeley DB flat files
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

package Bio::DB::Flat::BDB::swissprot;

use strict;
use Bio::DB::Flat::BDB;
use vars '@ISA';

@ISA = qw(Bio::DB::Flat::BDB);

sub default_file_format { "swiss" }

sub default_primary_namespace {
  return "ID";
}

sub default_secondary_namespaces {
  return qw(ACC VERSION);
}

sub seq_to_ids {
  my $self = shift;
  my $seq  = shift;

  my $display_id = $seq->display_id;
  my $accession  = $seq->accession_number;
  my $version    = $seq->seq_version;
  my $gi         = $seq->primary_id;
  my %ids;
  $ids{ID}       = $display_id;
  $ids{ACC}      = $accession            if defined $accession;
  $ids{VERSION}  = $accession            if defined $accession;
  return \%ids;
}


1;
