# $Id: ObjectFactoryI.pm,v 1.3 2002/10/22 07:45:14 lapp Exp $
#
# BioPerl module for Bio::Factory::ObjectFactoryI
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Factory::ObjectFactoryI - A General object creator factory

=head1 SYNOPSIS

# see the implementations of this interface for details but
# basically

    my $obj = $factory->create(%args);

=head1 DESCRIPTION

This interface is the basic structure for a factory which creates new
objects.  In this case it is up to the implementer to check arguments
and initialize whatever new object the implementing class is designed for.

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


package Bio::Factory::ObjectFactoryI;
use vars qw(@ISA);
use strict;
use Carp;
use Bio::Root::RootI;

@ISA = qw( Bio::Root::RootI );

=head2 create

 Title   : create
 Usage   : $factory->create(%args)
 Function: Create a new object  
 Returns : a new object
 Args    : hash of initialization parameters


=cut

sub create{
   my ($self,@args) = @_;
   $self->throw_not_implemented();
}

=head2 create_object

 Title   : create_object
 Usage   : $obj = $factory->create_object(%args)
 Function: Create a new object.

           This is supposed to supercede create(). Right now it only delegates
           to create().
 Returns : a new object
 Args    : hash of initialization parameters


=cut

sub create_object{
   my ($self,@args) = @_;
   return $self->create(@args);
}

1;
