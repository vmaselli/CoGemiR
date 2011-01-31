# $Id: SiteMatrix.pm,v 1.7 2003/11/13 17:56:11 skirov Exp $
#---------------------------------------------------------

=head1 NAME

Bio::Matrix::PSM::SiteMatrix - SiteMatrixI implementation, holds a
position scoring matrix (or position weight matrix)

=head1 SYNOPSIS

  use Bio::Matrix::PSM::SiteMatrix;
  # Create from memory by supplying probability matrix hash
  # both as strings or arrays
  # where $a,$c,$g and $t are either arrayref or string
  my ($a,$c,$g,$t,$score,$ic, $mid)=@_; 
  #or
  my ($a,$c,$g,$t,$score,$ic,$mid)=('05a011','110550','400001',
                                    '100104',0.001,19.2,'CRE1');
  #Where a stands for all (this frequency=1), see explanation bellow
  my %param=(-pA=>$a,-pC=>$c,-pG=>$g,-pT=>$t,
             -IC=>$ic,-e_val=>$score, -id=>$mid);
  my $site=new Bio::Matrix::PSM::SiteMatrix(%param);
  #Or get it from a file:
  use Bio::Matrix::PSM::IO;
  my $psmIO= new Bio::Matrix::PSM::IO(-file=>$file, -format=>'transfac');
  while (my $psm=$psmIO->next_psm) {
    #Now we have a Bio::Matrix::PSM::Psm object, 
    # see Bio::Matrix::PSM::PsmI for details
    #This is a Bio::Matrix::PSM::SiteMatrix object now
    my $matrix=$psm->matrix;  
  }

  # Get a simple consensus, where alphabet is {A,C,G,T,N}, 
  # choosing the highest probability or N if prob is too low
  my $consensus=$site->consensus;

  #Getting/using regular expression
  my $regexp=$site->regexp;
  my $count=grep($regexp,$seq);
  my $count=($seq=~ s/$regexp/$1/eg);
  print "Motif $mid is present $count times in this sequence\n";

=head1 DESCRIPTION

SiteMatrix is designed to provide some basic methods when working with
position scoring (weight) matrices, such as transcription factor
binding sites for example.  A DNA PSM consists of four vectors with
frequencies {A,C,G,T). This is the minimum information you should
provide to construct a PSM object. The vectors can be provided as
strings with frequencies where the frequency is {0..a} and a=1. This
is the way MEME compressed representation of a matrix and it is quite
useful when working with relational DB.  If arrays are provided as an
input (references to arrays actually) they can be any number, real or
integer (frequency or count).

When creating the object the constructor will check for positions that
equal 0.  If such is found it will increase the count for all
positions by one and recalculate the frequency.  Potential bug- if you
are using frequencies and one of the positions is 0 it will change
significantly.  However, you should never have frequency that equals
0.

Throws an exception if: You mix as an input array and string (for
example A matrix is given as array, C - as string).  The position
vector is (0,0,0,0).  One of the probability vectors is shorter than
the rest.

Summary of the methods I use most frequently (details bellow):

  iupac - return IUPAC compliant consensus as a string
  score - Returns the score as a real number
  IC - information content. Returns a real number
  id - identifier. Returns a string
  accession - accession number. Returns a string
  next_pos - return the sequence probably for each letter, IUPAC
      symbol, IUPAC probability and simple sequence
  consenus letter for this position. Rewind at the end. Returns a hash.
  pos - current position get/set. Returns an integer.
  regexp - construct a regular expression based on IUPAC consensus.
      For example AGWV will be [Aa][Gg][AaTt][AaCcGg]
  width - site width
  get_string - gets the probability vector for a single base as a string.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                 - General discussion
  http://bio.perl.org/MailList.html     - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Stefan Kirov

Email skirov@utk.edu


=head1 APPENDIX

=cut


# Let the code begin...
package Bio::Matrix::PSM::SiteMatrix;
use Bio::Matrix::PSM::SiteMatrixI;
use Bio::Root::Root;
use vars qw(@ISA);
use strict;

@ISA=qw(Bio::Root::Root Bio::Matrix::PSM::SiteMatrixI);

=head2 new

 Title   : new
 Usage   : my $site=new Bio::Matrix::PSM::SiteMatrix(-pA=>$a,-pC=>$c,
						     -pG=>$g,-pT=>$t,
						     -IC=>$ic,
						     -e_val=>$score, 
						     -id=>$mid);
 Function:  Creates a new Bio::Matrix::PSM::SiteMatrix object from memory
 Throws : If inconsistent data for all vectors (A,C,G and T) is
          provided, if you mix input types (string vs array) or if a
          position freq is 0.
 Example :
 Returns :  Bio::Matrix::PSM::SiteMatrix object
 Args    :  hash


=cut

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my $consensus;
    #Too many things to rearrange, and I am creating simultanuously >500 
    # such objects routinely, so this becomes performance issue
    my %input;
    while( @args ) {
	(my $key = shift @args) =~ s/-//gi; #deletes all dashes (only dashes)!
	$input{$key} = shift @args;
    }
    $self->{_position}   = 0;
    $self->{IC}     = $input{IC};
    $self->{e_val}  = $input{e_val};
    $self->{sites}  = $input{sites};
    $self->{width}  = $input{width};
    $self->{accession_number}=$input{accession_number};
    $self->{_correction}   =  defined($input{correction}) ? 
	$input{correction} : 1 ; # Correction might be unwanted- supply your own
    # No id provided, null for the sake of rel db
    $self->{id}= defined($input{id}) ? $input{id} : 'null'; 
	return $self unless (defined($input{pA}) && defined($input{pC}) && defined($input{pG}) && defined($input{pT}));
#Check for input type- no mixing alllowed, throw ex
    if (ref($input{pA}) =~ /ARRAY/i ) {
	$self->throw("Mixing matrix data types not allowed: C is not reference") unless(ref($input{pC}));
	$self->throw("Mixing matrix data types not allowed: G is not reference") unless (ref($input{pG}));
	$self->throw("Mixing matrix data types not allowed: T is not reference") unless (ref($input{pT}));
	$self->{probA}   = $input{pA};
	$self->{probC}   = $input{pC};
	$self->{probG}   = $input{pG};
	$self->{probT}   = $input{pT};
    }
    else {
	$self->throw("Mixing matrix data types not allowed: C is reference") if (ref($input{pC}));
	$self->throw("Mixing matrix data types not allowed: G is reference") if (ref($input{pG}));
	$self->throw("Mixing matrix data types not allowed: T is reference") if (ref($input{pT}));
	$self->{probA}   = [split(//,$input{pA})];
	$self->{probC}   = [split(//,$input{pC})];
	$self->{probG}   = [split(//,$input{pG})];
	$self->{probT}   = [split(//,$input{pT})];
	for (my $i=0; $i<@{$self->{probA}}+1; $i++) {
	    ${$self->{probA}}[$i]='10' if ( ${$self->{probA}}[$i] and ${$self->{probA}}[$i] eq 'a');
	    ${$self->{probC}}[$i]='10' if ( ${$self->{probC}}[$i] and ${$self->{probC}}[$i] eq 'a');
	    ${$self->{probG}}[$i]='10' if ( ${$self->{probG}}[$i] and ${$self->{probG}}[$i] eq 'a');
	    ${$self->{probT}}[$i]='10' if ( ${$self->{probT}}[$i] and ${$self->{probT}}[$i] eq 'a');
	}
#If this is MEME like output(probabilities, rather than count) here is the place for a check
    }
#Check for position with 0 for all bases, throw exception if so
#Correct 0 positions- inc by 1
    for (my $i=0;$i<$#{$self->{probA}}+1;$i++) {
	$self->throw("Position meaningless-all frequencies are 0") if ((${$self->{probA}}[$i]+${$self->{probC}}[$i]+${$self->{probG}}[$i]+${$self->{probT}}[$i])==0);
	$self->{_corrected}= ((${$self->{probA}}[$i]==0) || 
			      (${$self->{probG}}[$i]==0) || 
			      (${$self->{probC}}[$i]==0) || 
			      (${$self->{probT}}[$i]==0));
	if ($self->{_corrected}) {
	    ${$self->{probA}}[$i] += $self->{_correction};
	    ${$self->{probC}}[$i] += $self->{_correction};
	    ${$self->{probG}}[$i] += $self->{_correction};
	    ${$self->{probT}}[$i] += $self->{_correction};
	}
	my $div= ${$self->{probA}}[$i]+ ${$self->{probC}}[$i]+ ${$self->{probG}}[$i]+ ${$self->{probT}}[$i];
	${$self->{probA}}[$i]=${$self->{probA}}[$i]/$div;
	${$self->{probC}}[$i]=${$self->{probC}}[$i]/$div;
	${$self->{probG}}[$i]=${$self->{probG}}[$i]/$div;
	${$self->{probT}}[$i]=${$self->{probT}}[$i]/$div;
    }
#Make consensus, throw if any one of the vectors is shorter
    $self=_calculate_consensus($self);
    return $self;
}

=head2 _calculate_consensus

 Title   : _calculate_consensus
 Usage   :
 Function: Internal stuff
 Throws  :
 Example :
 Returns :
 Args    :

=cut

sub _calculate_consensus {
    my $self=shift;
    my ($lc,$lt,$lg)=($#{$self->{probC}},$#{$self->{probT}},$#{$self->{probG}});
    my $len=$#{$self->{probA}};
    $self->throw("Probability matrix is damaged for C: $len vs $lc") if ($len != $lc);
    $self->throw("Probability matrix is damaged for T: $len vs $lt") if ($len != $lt);
    $self->throw("Probability matrix is damaged for G: $len vs $lg") if ($len != $lg);
    for (my $i=0; $i<$len+1; $i++) {
	(${$self->{IUPAC}}[$i],${$self->{IUPACp}}[$i])=_to_IUPAC(${$self->{probA}}[$i],${$self->{probC}}[$i],${$self->{probG}}[$i],${$self->{probT}}[$i]);
	(${$self->{seq}}[$i],${$self->{seqp}}[$i])=_to_cons(${$self->{probA}}[$i],${$self->{probC}}[$i],${$self->{probG}}[$i],${$self->{probT}}[$i]);
    }
    return $self;
}

=head2 next_pos

 Title   : next_pos
 Usage   :
 Function: Retrives the next position features: frequencies for A,C,G,T, the main
            letter (as in consensus) and the probabilty for this letter to occur at this position
            and the current position
 Throws  :
 Example :
 Returns : hash (pA,pC,pG,pT,base,prob,rel)
 Args    : none


=cut

sub next_pos {
    my $self = shift;
    die "instance method called on class" unless ref $self;
    my $len=@{$self->{seq}};
    my $pos=$self->{_position};
    # End reached?
    if ($self->{_position}<$len) {
	my $pA=${$self->{probA}}[$pos];
	my $pC=${$self->{probC}}[$pos];
	my $pG=${$self->{probG}}[$pos];
	my $pT=${$self->{probT}}[$pos];
	my $base=${$self->{seq}}[$pos];
	my $prob=${$self->{seqp}}[$pos];
	$self->{_position}++;
	my %seq=(pA=>$pA,pT=>$pT,pC=>$pC,pG=>$pG, base=>$base,rel=>$pos, prob=>$prob);
	return %seq;
    }
    else {$self->{_position}=0; return undef;}
}


=head2 curpos

 Title   : curpos
 Usage   :
 Function: Gets/sets the current position. Converts to 0 if argument is minus and
            to width if greater than width
 Throws  :
 Example :
 Returns : integer
 Args    : integer

=cut

sub curpos {
    my $self = shift;
    my $prev = $self->{_position};
    if (@_) { $self->{_position} = shift; }
    return $prev;
}


=head2 e_val

 Title   : e_val
 Usage   :
 Function: Gets/sets the e-value
 Throws  :
 Example :
 Returns : real number
 Args    : real number

=cut

sub e_val {
    my $self = shift;
    my $prev = $self->{e_val};
    if (@_) { $self->{e_val} = shift; }
    return $prev;
}


=head2 IC

 Title   : IC
 Usage   :
 Function: Information content
 Throws  :
 Example :
 Returns : real number
 Args    : none

=cut

sub IC {
    my $self = shift;
    my $prev = $self->{IC};
    if (@_) { $self->{IC} = shift; }
    return $prev;
}

=head2 accession_number

 Title   : accession_number
 Usage   :
 Function: accession number, this will be unique id for the SiteMatrix object as
 			well for any other object, inheriting from SiteMatrix
 Throws  :
 Example :
 Returns : string
 Args    : string

=cut

sub accession_number {
    my $self = shift;
    my $prev = $self->{accession_number};
    if (@_) { $self->{accession_number} = shift; }
    return $prev;
}

=head2 consensus

 Title   : consensus
 Usage   :
 Function: Returns the consensus
 Throws  :
 Example :
 Returns : string
 Args    :

=cut

sub consensus {
  my $self = shift;
  my $consensus='';
  foreach my $letter (@{$self->{seq}}) {
     $consensus .= $letter;
  }
  return $consensus;
}


=head2 width

 Title   : width
 Usage   :
 Function: Returns the length of the site
 Throws  :
 Example :
 Returns : number
 Args    :

=cut

sub width {
  my $self = shift;
  my $width=@{$self->{probA}};
  return $width;
}

=head2 IUPAC

 Title   : IUPAC
 Usage   :
 Function: Returns IUPAC compliant consensus
 Throws  :
 Example :
 Returns : string
 Args    :

=cut

sub IUPAC {
	my $self = shift;
	my $iu=$self->{IUPAC};
	my $iupac='';
	foreach my $let (@{$iu}) {
		$iupac .= $let;
	}
return $iupac;
}

=head2 _to_IUPAC

 Title   : _to_IUPAC
 Usage   :
 Function: Converts a single position to IUPAC compliant symbol and returns its probability.
            For rules see the implementation
 Throws  :
 Example :
 Returns : char, real number
 Args    : real numbers for A,C,G,T (positional)

=cut

sub _to_IUPAC {
	my $A=shift;
	my $C=shift;
	my $G=shift;
	my $T=shift;
	my $all=$A+$G+$C+$T;
	my $a=$A/$all;
	my $g=$G/$all;
	my $c=$C/$all;
	my $t=$T/$all;
	my $single=0.7*$all;
	my $double=0.8*$all;
	my $triple=0.9*$all;
	return 'A',$a if ($a>$single);
	return 'G',$g if ($g>$single);
	return 'C',$c if ($c>$single);
	return 'T',$t if ($t>$single);
	my $r=$g+$a;
	return 'R',$r if ($r>$double);
	my $y=$t+$c;
	return 'Y',$y if ($y>$double);
	my $m=$a+$c;
	return 'M',$m if ($m>$double);
	my $k=$g+$t;
	return 'K',$k if ($k>$double);
	my $s=$g+$c;
	return 'S',$s if ($s>$double);
	my $w=$a+$t;
	return 'W',$w if ($w>$double);
	my $d=$r+$t;
	return 'D',$d if ($d>$triple);
	my $v=$r+$c;
	return 'V',$v if ($v>$triple);
	my $b=$y+$g;
	return 'B',$b if ($b>$triple);
	my $h=$y+$a;
	return 'H',$h if ($h>$triple);
	return 'N',0;
}

=head2 _to_cons

 Title   : _to_cons
 Usage   :
 Function: Converts a single position to simple consensus character and returns its probability.
            For rules see the implementation
 Throws  :
 Example :
 Returns : char, real number
 Args    : real numbers for A,C,G,T (positional)

=cut

sub _to_cons {
	my $A=shift;
	my $C=shift;
	my $G=shift;
	my $T=shift;
	my $all=$A+$G+$C+$T;
	my $a=$A*10/$all;
	my $g=$G*10/$all;
	my $c=$C*10/$all;
	my $t=$T*10/$all;
	return 'A',$a if ($a>5);
	return 'G',$g if ($g>5);
	return 'C',$c if ($c>5);
	return 'T',$t if ($t>5);
	return 'N',10 if (($a==$t) && ($a==$c) && ($a==$g));
	return 'A',$a if (($a>$t) &&($a>$c) && ($a>$g));
	return 'C',$c if (($c>$t) &&($c>$a) && ($c>$g));
	return 'G',$g if (($g>$t) &&($g>$c) && ($g>$a));
	return 'N',10;
}

=head2 get_string

 Title   : get_string
 Usage   :
 Function: Returns given probability vector as a string. Useful if you want to
            store things in a rel database, where arrays are not first choice
 Throws  : If the argument is outside {A,C,G,T}
 Example :
 Returns : string
 Args    : character {A,C,G,T}

=cut

sub get_string {
	my $self=shift;
	my $base=shift;
	my $string='';
	my @prob;
	BASE: {
		if ($base eq 'A') {@prob= @{$self->{probA}}; last BASE; }
		if ($base eq 'C') {@prob= @{$self->{probC}}; last BASE; }
		if ($base eq 'G') {@prob= @{$self->{probG}}; last BASE; }
		if ($base eq 'T') {@prob= @{$self->{probT}}; last BASE; }
		$self->throw ("No such base: $base!\n");
	}
foreach  my $prob (@prob) {
	my $corrected=$prob*10;
	my $next=sprintf("%.0f",$corrected);
	$next='a' if ($next eq '10');
	$string .= $next;
}
return $string;
}


=head2 get_array

 Title   : get_array
 Usage   :
 Function: Returns an array with frequencies for a specified base
 Throws  :
 Example :
 Returns : array
 Args    : char

=cut

sub get_array {
	my $self=shift;
	my $base=uc(shift);
	return  @{$self->{probA}} if ($base eq 'A');
	return  @{$self->{probC}} if ($base eq 'C');
	return  @{$self->{probG}} if ($base eq 'G');
	return  @{$self->{probT}} if ($base eq 'T');
	$self->throw ("No such base: $base!\n");
}


=head2 id

 Title   : id
 Usage   :
 Function: Gets/sets the site id
 Throws  :
 Example :
 Returns : string
 Args    : string

=cut

sub id {
    my $self = shift;
    my $prev = $self->{id};
    if (@_) { $self->{id} = shift; }
    return $prev;
}


=head2 regexp

 Title   : regexp
 Usage   :
 Function: Returns a regular expression which matches the IUPAC convention.
            N will match X, N, - and .
 Throws  :
 Example :
 Returns : string
 Args    :

=cut

sub regexp {
	my $self=shift;
	my $regexp;
	foreach my $letter (@{$self->{IUPAC}}) {
		my $reg;
		LETTER: {
			if ($letter eq 'A') { $reg='Aa'; last LETTER; }
			if ($letter eq 'C') { $reg='Cc'; last LETTER; }
			if ($letter eq 'G') { $reg='Gg'; last LETTER; }
			if ($letter eq 'T') { $reg='Tt'; last LETTER; }
			if ($letter eq 'M') { $reg='AaCc'; last LETTER; }
			if ($letter eq 'R') { $reg='AaGg'; last LETTER; }
			if ($letter eq 'W') { $reg='AaTt'; last LETTER; }
			if ($letter eq 'S') { $reg='CcGg'; last LETTER; }
			if ($letter eq 'Y') { $reg='CcTt'; last LETTER; }
			if ($letter eq 'K') { $reg='GgTt'; last LETTER; }
			if ($letter eq 'V') { $reg='AaCcGg'; last LETTER; }
			if ($letter eq 'H') { $reg='AaCcTt'; last LETTER; }
			if ($letter eq 'D') { $reg='AaGgTt'; last LETTER; }
			if ($letter eq 'B') { $reg='CcGgTt'; last LETTER; }
			if ($letter=~"AGCT-XN\.")  { $reg="\."; last LETTER; }
		}
		$regexp .= "[$reg]";
	}
return $regexp;
}


=head2 regexp_array

 Title   : regexp_array
 Usage   :
 Function: Returns a regular expression which matches the IUPAC convention.
            N will match X, N, - and .
 Throws  :
 Example :
 Returns : array
 Args    :
 To do   : I have separated regexp and regexp_array, but
           maybe they can be rewritten as one - just check what should be returned

=cut

sub regexp_array {
	my $self=shift;
	my @regexp;
	foreach my $letter (@{$self->{IUPAC}}) {
		my $reg;
		LETTER: {
			if ($letter eq 'A') { $reg='Aa'; last LETTER; }
			if ($letter eq 'C') { $reg='Cc'; last LETTER; }
			if ($letter eq 'G') { $reg='Gg'; last LETTER; }
			if ($letter eq 'T') { $reg='Tt'; last LETTER; }
			if ($letter eq 'M') { $reg='AaCc'; last LETTER; }
			if ($letter eq 'R') { $reg='AaGg'; last LETTER; }
			if ($letter eq 'W') { $reg='AaTt'; last LETTER; }
			if ($letter eq 'S') { $reg='CcGg'; last LETTER; }
			if ($letter eq 'Y') { $reg='CcTt'; last LETTER; }
			if ($letter eq 'K') { $reg='GgTt'; last LETTER; }
			if ($letter eq 'V') { $reg='AaCcGg'; last LETTER; }
			if ($letter eq 'H') { $reg='AaCcTt'; last LETTER; }
			if ($letter eq 'D') { $reg='AaGgTt'; last LETTER; }
			if ($letter eq 'B') { $reg='CcGgTt'; last LETTER; }
			if ($letter=~"-XN\.")  { $reg="\."; last LETTER; }
		}
		push @regexp,$reg;
	}
return @regexp;
}

1;
