# $Id: WebAgent.pm,v 1.4 2003/06/04 08:36:35 heikki Exp $
#
# BioPerl module for Bio::WebAgent
#
# Cared for by Heikki Lehvaslaiho, heikki@ebi.ac.uk
# For copyright and disclaimer see below.
#

# POD documentation - main docs before the code

=head1 NAME

Bio::WebAgent - A base class for Web (any protocol) access

=head1 SYNOPSIS

  # This is a abstract superclass for bioperl modules accessing web
  # resources - normally you do not instantiate it but one of its
  # subclasess.

=head1 DESCRIPTION

This abstact superclass is a subclass of L<LWP::UserAgent> which
allows protocol independent access of accessing remote locations over
the Net.

It takes care of error handling, proxies and various net protocols.
BioPerl classes accessing net should inherit from it.  For details,
see L<LWP::UserAgent>.

The interface is still eveolving. For now, I've copied over two public
methods from Bio::DB::WebDBSeqI: delay() and delay_policy. These are
used to prevent overwhelming the server by rapidly repeated . Ideally
there should be a common abstract superclass with these. See L<delay>.

=head1 SEE ALSO

L<LWP::UserAgent>, 
L<Bio::DB::WebDBSeqI>, 

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
  http://bioperl.org/bioperl-bugs/

=head1 AUTHOR

Heikki Lehvaslaiho, heikki@ebi.ac.uk

=head1 COPYRIGHT

Copyright (c) 2003, Heikki Lehvaslaiho and EMBL-EBI.
All Rights Reserved.

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 DISCLAIMER

This software is provided "as is" without warranty of any kind.

=head1 APPENDIX

This is actually the main documentation...

=cut


# Let the code begin...

package Bio::WebAgent;
use vars qw(@ISA  $Revision $LAST_INVOCATION_TIME);
use strict;
use LWP::UserAgent;
use Bio::Root::Root;

@ISA = qw(LWP::UserAgent Bio::Root::Root);

BEGIN {
    $Revision = q$Id: WebAgent.pm,v 1.4 2003/06/04 08:36:35 heikki Exp $;
}


sub new {
    my $class = shift;

    my $self = $class->SUPER::new();
    while( @_ ) {
	my $key = shift;
        $key =~ s/^-//;
        $self->$key(shift);
    }

    return $self; # success - we hope!

}


# -----------------------------------------------------------------------------

=head2 url

 Usage   : $agent->url
 Returns : URL to reach out to Net
 Args    : string

=cut

sub url { 
   my ($self,$value) = @_;
   if( defined $value) {
       $self->{'_url'} = $value;
   }
   return $self->{'_url'};
}


=head2 delay

 Title   : delay
 Usage   : $secs = $self->delay([$secs])
 Function: get/set number of seconds to delay between fetches
 Returns : number of seconds to delay
 Args    : new value

NOTE: the default is to use the value specified by delay_policy().
This can be overridden by calling this method, or by passing the
-delay argument to new().

=cut

sub delay {
   my ($self, $value) = @_;
   if ($value) {
       $self->throw("Need a positive integer, not [$value]")
           unless $value >= 0;
       $self->{'_delay'} = int $value;
   }
   return $self->{'_delay'} || $self->delay_policy;
}

=head2 delay_policy

 Title   : delay_policy
 Usage   : $secs = $self->delay_policy
 Function: return number of seconds to delay between calls to remote db
 Returns : number of seconds to delay
 Args    : none

NOTE: The default delay policy is 3s.  Override in subclasses to
implement other delays.  The timer has only second resolution, so the delay
will actually be +/- 1s.

=cut

sub delay_policy {
   my $self = shift;
   return 3;
}


=head2 sleep

 Title   : sleep
 Usage   : $self->sleep
 Function: sleep for a number of seconds indicated by the delay policy
 Returns : none
 Args    : none

NOTE: This method keeps track of the last time it was called and only
imposes a sleep if it was called more recently than the delay_policy()
allows.

=cut

sub sleep {
   my $self = shift;
   $LAST_INVOCATION_TIME ||=  0;
   if (time - $LAST_INVOCATION_TIME < $self->delay) {
      my $delay = $self->delay - (time - $LAST_INVOCATION_TIME);
      warn "sleeping for $delay seconds\n" if $self->verbose > 0;
      sleep $delay;
   }
   $LAST_INVOCATION_TIME = time;
}

1;

__END__

