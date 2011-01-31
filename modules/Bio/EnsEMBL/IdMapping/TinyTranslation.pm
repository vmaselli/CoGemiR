package Bio::EnsEMBL::IdMapping::TinyTranslation;

=head1 NAME


=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS


=head1 LICENCE

This code is distributed under an Apache style licence. Please see
http://www.ensembl.org/info/about/code_licence.html for details.

=head1 AUTHOR

Patrick Meidl <meidl@ebi.ac.uk>, Ensembl core API team

=head1 CONTACT

Please post comments/questions to the Ensembl development list
<ensembl-dev@ebi.ac.uk>

=cut


use strict;
use warnings;
no warnings 'uninitialized';

use Bio::EnsEMBL::IdMapping::TinyFeature;
our @ISA = qw(Bio::EnsEMBL::IdMapping::TinyFeature);

use Bio::EnsEMBL::Utils::Exception qw(throw warning);


sub transcript_id {
  my $self = shift;
  $self->[5] = shift if (@_);
  return $self->[5];
}


sub seq {
  my $self = shift;
  $self->[6] = shift if (@_);
  return $self->[6];
}


sub is_known {
  my $self = shift;
  $self->[7] = shift if (@_);
  return $self->[7];
}


1;

