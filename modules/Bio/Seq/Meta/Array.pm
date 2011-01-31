# $Id: Array.pm,v 1.5 2003/09/08 12:17:14 heikki Exp $
#
# BioPerl module for Bio::Seq::Meta::Array
#
# Cared for by Heikki Lehvaslaiho
#
# Copyright Heikki Lehvaslaiho
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Seq::Meta::Array - array-based generic implementation of a sequence class with residue-based meta information

=head1 SYNOPSIS

  use Bio::LocatableSeq;
  use Bio::Seq::Meta::Array;

  my $seq = Bio::LocatableSeq->new(-id=>'test',
                                   -seq=>'ACTGCTAGCT',
                                   -start=>2434,
                                   -start=>2443,
                                   -strand=>1,
                                   -varbose=>1, # to see warnings
                                  );
  bless $seq, Bio::Seq::Meta::Array;
  # the existing sequence object can be a Bio::PrimarySeq, too

  # to test this is a meta seq object
  $seq->isa("Bio::Seq::Meta::Array")
      || $seq->throw("$seq is not a Bio::Seq::Meta::Array");

  $seq->meta('1 2 3 4 5 6 7 8 9 10');

  # accessors
  $arrayref   = $seq->meta();
  $string     = $seq->meta_text();
  $substring  = $seq->submeta_text(2,5);
  $unique_key = $seq->accession_number();

=head1 DESCRIPTION

This class implements generic methods for sequences with residue-based
meta information. Meta sequences with meta data are Bio::LocatableSeq
objects with additional methods to store that meta information. See
L<Bio::LocatableSeq> and L<Bio::Seq::MetaI>.

The meta information in this class can be a string of variable length
and can be a complex structure.  Blank values are undef or zero.

Application specific implementations should inherit from this class to
override and add to these methods.

=head1 SEE ALSO

L<Bio::LocatableSeq>, 
L<Bio::Seq::MetaI>, 
L<Bio::Seq::Meta>, 

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                      - General discussion
  http://bio.perl.org/MailList.html          - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Heikki Lehvaslaiho

Email heikki@ebi.ac.uk

=head1 CONTRIBUTORS

Chad Matsalla, bioinformatics@dieselwurks.com
Aaron Mackey, amackey@virginia.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Seq::Meta::Array;
use vars qw(@ISA $DEFAULT_NAME $GAP $META_GAP);
use strict;
use Bio::LocatableSeq;
use Bio::Seq::MetaI;

use Data::Dumper;

#use overload '""' => \&to_string;

@ISA = qw( Bio::LocatableSeq Bio::Seq Bio::Seq::MetaI );

BEGIN {

    $DEFAULT_NAME = 'DEFAULT';
    $GAP = '-';
    $META_GAP = 0;
}

=head2 new

 Title   : new
 Usage   : $metaseq = Bio::Seq::Meta->new
	        ( -meta => 'aaaaaaaabbbbbbbb',
                  -seq =>  'TKLMILVSHIVILSRM'
	          -id  => 'human_id',
	          -accession_number => 'S000012',
	        );
 Function: Constructor for Bio::Seq::Meta class, meta data being in a
           string. Note that you can provide an empty quality string.
 Returns : a new Bio::Seq::Meta object

=cut

sub new {
    my ($class, %args) = @_;
	#defined inheritance according to stated baseclass,
	#if undefined then will be PrimarySeq
	if (defined($args{'-baseclass'})) {
		@ISA = ($args{'-baseclass'},"Bio::Seq::MetaI");
		}
	else {
		@ISA = qw( Bio::LocatableSeq Bio::Seq Bio::Seq::MetaI );
		}

    my $self = $class->SUPER::new(%args);

    my($meta) =
        $self->_rearrange([qw(META
                              )],
                          %args);

    $self->{'_meta'}->{$DEFAULT_NAME} = undef;

    $meta && $self->meta($meta);

    return $self;
}


=head2 meta

 Title   : meta
 Usage   : $meta_values  = $obj->meta($values_string);
 Function:

           Get and set method for the meta data starting from residue
           position one. Since it is dependent on the length of the
           sequence, it needs to be manipulated after the sequence.

           The length of the returned value always matches the length
           of the sequence.

 Returns : reference to an array of meta data
 Args    : new value, string or array ref, optional

=cut

sub meta {
   shift->named_meta($DEFAULT_NAME, shift);
}

=head2 meta_text

 Title   : meta_text
 Usage   : $meta_values  = $obj->meta_text($values_arrayref);
 Function: Variant of meta() guarantied to return a textual
           representation  of meta data. For details, see L<meta>.
 Returns : a string
 Args    : new value, string or array ref, optional

=cut

sub meta_text {
    return join ' ',  @{shift->meta(shift)};
}

=head2 named_meta

 Title   : named_meta()
 Usage   : $meta_values  = $obj->named_meta($name, $values_arrayref);
 Function: A more general version of meta(). Each meta data set needs
           to be named. See also L<meta_names>.
 Returns : reference to an array of meta data
 Args    : scalar, name of the meta data set
           new value, string or array ref, optional

=cut

sub named_meta {
   my ($self, $name, $value) = @_;

   $name ||= $DEFAULT_NAME;

   if (defined $value) {
       my ($arrayref);

       if (ref $value eq 'ARRAY' ) { # array ref
           $arrayref = $value;
       }
       elsif (not ref($value)) { # scalar
           $arrayref = [split /\s+/, $value];
       } else {
           $self->throw("I need a scalar or array ref, not [". ref($value). "]");
       }

       # test for length
       my $diff = $self->length - @{$arrayref};
       if ($diff > 0) {
           foreach (1..$diff) { push @{$arrayref}, 0;}
       }

       $self->{'_meta'}->{$name} = $arrayref;

       #$self->_test_gap_positions($name) if $self->verbose > 0;
   }

   if (defined $self->{'_meta'}->{$name} and
       scalar @{$self->{'_meta'}->{$name}} > $self->length ) {
       return [@{$self->{'_meta'}->{$name}}[0..($self->length-1)]];
   } else {
       return $self->{'_meta'}->{$name} || (" " x $self->length);
   }
}

=head2 _test_gap_positions

 Title   : _test_gap_positions
 Usage   : $meta_values  = $obj->_test_gap_positions($name);
 Function: Internal test for correct position of gap characters.
           Gap being only '-' this time.

           This method is called from named_meta() when setting meta
           data but only if verbose is positive as this can be an
           expensive process on very long sequences. Set verbose(1) to
           see warnings when gaps do not align in sequence and meta
           data and turn them into errors by setting verbose(2).

 Returns : true on success, prints warnings
 Args    : none

=cut

sub _test_gap_positions {
    my $self = shift;
    my $name = shift;
    my $success = 1;

    $self->seq || return $success;
    my $len = CORE::length($self->seq);
    for (my $i=0; $i < $len; $i++) {
        my $s = substr $self->{seq}, $i, 1;
        my $m = substr $self->{_meta}->{$name}, $i, 1;
        $self->warn("Gap mismatch in column [". ($i+1). "] of [$name] meta data in seq [". $self->id. "]")
            and $success = 0
                #if ($s eq '-' || $m eq '-') && $s ne $m;
                if ($m eq '-') && $s ne $m;
    }
    return $success;
}

=head2 named_meta_text

 Title   : named_meta_text()
 Usage   : $meta_values  = $obj->named_meta_text($name, $values_arrayref);
 Function: Variant of named_meta() guarantied to return a textual
           representation  of the named meta data.
           For details, see L<meta>.
 Returns : a string
 Args    : scalar, name of the meta data set
           new value, string or array ref, optional

=cut

sub named_meta_text {
    return join ' ', @{shift->named_meta(@_)};

}

=head2 submeta

 Title   : submeta
 Usage   : $subset_of_meta_values = $obj->submeta(10, 20, $value_string);
           $subset_of_meta_values = $obj->submeta(10, undef, $value_string);
 Function:

           Get and set method for meta data for subsequences.

           Numbering starts from 1 and the number is inclusive, ie 1-2
           are the first two residue of the sequence. Start cannot be
           larger than end but can be equal.

           If the second argument is missing the returned values
           should extend to the end of the sequence.

           The return value may be a string or an array reference,
           depending on the implentation. If in doubt, use
           submeta_text() which is a variant guarantied to return a
           string.  See L<submeta_text>.

 Returns : A reference to an array or a string
 Args    : integer, start position
           integer, end position, optional when a third argument present
           new value, string or array ref, optional

=cut

sub submeta {
   shift->named_submeta($DEFAULT_NAME, @_);
}

=head2 submeta_text

 Title   : submeta_text
 Usage   : $meta_values  = $obj->submeta_text(20, $value_string);
 Function: Variant of submeta() guarantied to return a textual
           representation  of meta data. For details, see L<meta>.
 Returns : a string
 Args    : new value, string or array ref, optional


=cut

sub submeta_text {
    return join ' ', @{shift->submeta(@_)};
}

=head2 named_submeta

 Title   : named_submeta
 Usage   : $subset_of_meta_values = $obj->named_submeta($name, 10, 20, $value_string);
           $subset_of_meta_values = $obj->named_submeta($name, 10);
 Function: Variant of submeta() guarantied to return a textual
           representation  of meta data. For details, see L<meta>.
 Returns : A reference to an array or a string
 Args    : scalar, name of the meta data set
           integer, start position
           integer, end position, optional when a third argument present
           new value, string or array ref, optional

=cut


sub named_submeta {
    my ($self, $name, $start, $end, $value) = @_;

    $name ||= $DEFAULT_NAME;
    $start ||=1;
    $start =~ /^[+]?\d+$/ and $start > 0 or
        $self->throw("Need at least a positive integer start value");
    $start--;

    my $metaref = $self->{_meta}->{$name};

    if (defined $value) {
        my $arrayref;

        $self->warn("You are setting meta values beyond the length of the sequence\n".
                    "[$start > ". length($self->seq)."] in sequence ". $self->id)
            if $start > $self->length;

        if (ref $value eq 'ARRAY' ) { # array ref
            $arrayref = $value;
        }
        elsif (not ref($value)) { # scalar
            $arrayref = [split /\s+/, $value];
        } else {
            $self->throw("I need a scalar or array ref, not [". ref($value). "]");
        }



        $end or $end = @{$arrayref}  + $start;
        #$end = length @{$arrayref} + $start if $end > (length (@{$arrayref}) + $start);
        $end--;

        # test for length; pad if needed
        my $diff = $end - $start - scalar @{$arrayref};
        if ($diff > 0) {
            foreach (1..$diff) { push @{$arrayref}, $META_GAP}
        }

        @{$metaref}[$start..$end] = @{$arrayref};
        return $arrayref;

    } else {

        $end or $end = $self->length;
        $end = $self->length if $end > $self->length;
        $end--;
        return [@{$metaref}[$start..$end]];

    }
}


=head2 named_submeta_text

 Title   : named_submeta_text
 Usage   : $meta_values  = $obj->named_submeta_text($name, 20, $value_string);
 Function: Variant of submeta() guarantied to return a textual
           representation  of meta data. For details, see L<meta>.
 Returns : a string
 Args    : scalar, name of the meta data
 Args    : integer, start position, optional
           integer, end position, optional
           new value, string or array ref, optional

=cut

sub named_submeta_text {
    return join ' ', @{shift->named_submeta(@_)};
}

=head2 meta_names

 Title   : meta_names
 Usage   : @meta_names  = $obj->meta_names()
 Function: Retrives an array of meta data set names. The default
           (unnamed) set name is guarantied to be the first name if it
           contains any data.
 Returns : an array of names
 Args    : none

=cut

sub meta_names {
    my ($self) = @_;

    my @r;
    foreach  ( sort keys %{$self->{'_meta'}} ) {
        push (@r, $_) unless $_ eq $DEFAULT_NAME;
    }
    unshift @r, $DEFAULT_NAME if $self->{'_meta'}->{$DEFAULT_NAME};
    return @r;
 }


=head1 Bio::PrimarySeqI methods

=head2 revcom

 Title   : revcom
 Usage   : $newseq = $seq->revcom();
 Function: Produces a new Bio::Seq::MetaI implementing object where
           the order of residues and their meta information is reversed.
 Returns : A new (fresh) Bio::Seq::Meta object
 Args    : none

=cut

sub revcom {
    my $self = shift;

    my $new = $self->SUPER::revcom;
    my $end = $self->length - 1;
    map {
        $new->{_meta}->{$_} = [ reverse @{$self->{_meta}->{$_}}[0..$end]]
    } keys %{$self->{_meta}};

    return $new;
}

=head2 trunc

 Title   : trunc
 Usage   : $subseq = $seq->trunc(10,100);
 Function: Provides a truncation of a sequence together with meta data
 Returns : a fresh Bio::Seq::Meta implementing object
 Args    : Two integers denoting first and last residue of the sub-sequence.

=cut

sub trunc {
    my ($self, $start, $end) = @_;

    # test arguments
    $start =~ /^[+]?\d+$/ and $start > 0 or
        $self->throw("Need at least a positive integer start value as start");
    $end =~ /^[+]?\d+$/ and $end > 0 or
        $self->throw("Need at least a positive integer start value as end");
    $end >= $start or
        $self->throw("End position has to be larger or equal to start");
    $end <= $self->length or
        $self->throw("End position can not be larger than sequence length");


    my $new = $self->SUPER::trunc($start, $end);
    $start--;
    map {
        $new->{_meta}->{$_} = [@{$self->{_meta}->{$_}}[$start..$end]]
    } keys %{$self->{_meta}};
    return $new;
}

1;
