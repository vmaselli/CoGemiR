# $Id: TreeFactoryI.pm,v 1.6 2002/10/22 07:45:14 lapp Exp $
#
# BioPerl module for Bio::Factory::TreeFactoryI
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Factory::TreeFactoryI - Factory Interface for getting and writing trees
  from/to a data stream

=head1 SYNOPSIS

  # get a $factory from somewhere Bio::TreeIO likely
  my $treeio = new Bio::TreeIO(-format => 'newick', #this is phylip/newick format
  			       -file   => 'file.tre');
  my $treeout = new Bio::TreeIO(-format => 'nexus',
  				-file   => ">file.nexus");

  # convert tree formats from newick/phylip to nexus
  while(my $tree = $treeio->next_tree) {
      $treeout->write_tree($treeout);
  }

=head1 DESCRIPTION

This interface describes the minimal functions needed to get and write
trees from a data stream.  It is implemented by the L<Bio::TreeIO> factory.

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


package Bio::Factory::TreeFactoryI;
use vars qw(@ISA);
use strict;
use Bio::Root::RootI;

@ISA = qw(Bio::Root::RootI);

=head2 next_tree

 Title   : next_tree
 Usage   : my $tree = $factory->next_tree;
 Function: Get a tree from the factory
 Returns : L<Bio::Tree::TreeI>
 Args    : none

=cut

sub next_tree{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

=head2 write_tree

 Title   : write_tree
 Usage   : $treeio->write_tree($tree);
 Function: Writes a tree onto the stream
 Returns : none
 Args    : L<Bio::Tree::TreeI>


=cut

sub write_tree{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

1;
