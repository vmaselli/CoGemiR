# $Id: MapperI.pm,v 1.5 2002/11/08 09:28:24 heikki Exp $
#
# bioperl module for Bio::Coordinate::MapperI
#
# Cared for by Heikki Lehvaslaiho <heikki@ebi.ac.uk>
#
# Copyright Heikki Lehvaslaiho
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Coordinate::MapperI - Interface describing coordinate mappers

=head1 SYNOPSIS

  # not to be used directly

=head1 DESCRIPTION

MapperI defines methods for classes capable for mapping locations
between coordinate systems.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing lists  Your participation is much appreciated.

  bioperl-l@bioperl.org                         - General discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.  Bug reports can be submitted via
 email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Heikki Lehvaslaiho

Email:  heikki@ebi.ac.uk
Address:

     EMBL Outstation, European Bioinformatics Institute
     Wellcome Trust Genome Campus, Hinxton
     Cambs. CB10 1SD, United Kingdom

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::Coordinate::MapperI;
use vars qw(@ISA );
use strict;

# Object preamble - inherits from Bio::Root::RootI
use Bio::Root::RootI;

@ISA = qw(Bio::Root::RootI);



=head2 in

 Title   : in
 Usage   : $obj->in('peptide');
 Function: Set and read the input coordinate system.
 Example :
 Returns : value of input system
 Args    : new value (optional), Bio::LocationI

=cut

sub in {
   my ($self,$value) = @_;

   $self->throw_not_implemented();

}


=head2 out

 Title   : out
 Usage   : $obj->out('peptide');
 Function: Set and read the output coordinate system.
 Example :
 Returns : value of output system
 Args    : new value (optional), Bio::LocationI

=cut

sub out {
   my ($self,$value) = @_;

   $self->throw_not_implemented();
}

=head2 swap

 Title   : swap
 Usage   : $obj->swap;
 Function: Swap the direction of mapping: input <-> output)
 Example :
 Returns : 1
 Args    : 

=cut

sub swap {
   my ($self) = @_;

   $self->throw_not_implemented();

}

=head2 test

 Title   : test
 Usage   : $obj->test;
 Function: test that both components are of same length
 Example :
 Returns : ( 1 | undef )
 Args    :

=cut

sub test {
   my ($self) = @_;

   $self->throw_not_implemented();
}


=head2 map

 Title   : map
 Usage   : $newpos = $obj->map($loc);
 Function: Map the location from the input coordinate system
           to a new value in the output coordinate system.
 Example :
 Returns : new value in the output coordiante system
 Args    : Bio::LocationI

=cut

sub map {
   my ($self,$value) = @_;

   $self->throw_not_implemented();

}

=head2 return_match

 Title   : return_match
 Usage   : $obj->return_match(1);
 Function: A flag to turn on the simplified mode of
           returning only one joined Match object or undef
 Example :
 Returns : boolean
 Args    : boolean (optional)

=cut

sub return_match {
   my ($self,$value) = @_;
   if( defined $value) {
       $value ? ( $self->{'_return_match'} = 1 ) :
                ( $self->{'_return_match'} = 0 );
   }
   return $self->{'_return_match'} || 0 ;
}

1;

