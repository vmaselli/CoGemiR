# $Id: Repeat_Region.pm,v 1.8 2003/06/04 08:36:40 heikki Exp $
#
# bioperl module for Bio::LiveSeq::Repeat_Region
#
# Cared for by Joseph Insana <insana@ebi.ac.uk> <jinsana@gmx.net>
#
# Copyright Joseph Insana
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=head1 NAME

Bio::LiveSeq::Repeat_Region - Repeat_Region class for LiveSeq

=head1 SYNOPSIS

  # documentation needed

=head1 DESCRIPTION

Class for REPEAT_REGION objects. They consist of a beginlabel, an endlabel (both
referring to a LiveSeq DNA object) and a strand.
The strand could be 1 (forward strand, default), -1 (reverse strand).

=head1 AUTHOR - Joseph A.L. Insana

Email:  Insana@ebi.ac.uk, jinsana@gmx.net

Address: 

     EMBL Outstation, European Bioinformatics Institute
     Wellcome Trust Genome Campus, Hinxton
     Cambs. CB10 1SD, Regioned Kingdom 

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::LiveSeq::Repeat_Region;


use strict;
use vars qw(@ISA);
use Bio::LiveSeq::Range; # uses Range, inherits from it
@ISA=qw(Bio::LiveSeq::Range);

=head2 new

  Title   : new
  Usage   : $intron1=Bio::LiveSeq::Repeat_Region->new(-seq => $objref,
					      -start => $startlabel,
					      -end => $endlabel, -strand => 1);

  Function: generates a new Bio::LiveSeq::Repeat_Region
  Returns : reference to a new object of class Repeat_Region
  Errorcode -1
  Args    : two labels and an integer

=cut

1;
