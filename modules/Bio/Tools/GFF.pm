# $Id: GFF.pm,v 1.34 2003/12/19 15:26:26 scain Exp $
#
# BioPerl module for Bio::Tools::GFF
#
# Cared for by the Bioperl core team
#
# Copyright Matthew Pocock
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::GFF - A Bio::SeqAnalysisParserI compliant GFF format parser

=head1 SYNOPSIS

    use Bio::Tools::GFF;

    # specify input via -fh or -file
    my $gffio = Bio::Tools::GFF->new(-fh => \*STDIN, -gff_version => 2);
    my $feature;
    # loop over the input stream
    while($feature = $gffio->next_feature()) {
        # do something with feature
    }
    $gffio->close();

    # you can also obtain a GFF parser as a SeqAnalasisParserI in
    # HT analysis pipelines (see Bio::SeqAnalysisParserI and
    # Bio::Factory::SeqAnalysisParserFactory)
    my $factory = Bio::Factory::SeqAnalysisParserFactory->new();
    my $parser = $factory->get_parser(-input => \*STDIN, -method => "gff");
    while($feature = $parser->next_feature()) {
        # do something with feature
    }

=head1 DESCRIPTION

This class provides a simple GFF parser and writer. In the sense of a
SeqAnalysisParser, it parses an input file or stream into SeqFeatureI
objects, but is not in any way specific to a particular analysis
program and the output that program produces.

That is, if you can get your analysis program spit out GFF, here is
your result parser.

=head1 NOTE

While Bio::Tools::GFF supports GFF3, it does not deal with sequence data,
which is valid in GFF3. If you want to use Bio::Tools::GFF with GFF3 that
has sequence data, the sequence must be removed before analysis.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org          - General discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Matthew Pocock

Email mrp@sanger.ac.uk

=head1 CONTRIBUTORS 

Jason Stajich, jason-at-biperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::Tools::GFF;

use vars qw(@ISA $HAS_HTML_ENTITIES);
use strict;

use Bio::Root::IO;
use Bio::SeqAnalysisParserI;
use Bio::LocatableSeq;
use Bio::SeqFeature::Generic;

@ISA = qw(Bio::Root::Root Bio::SeqAnalysisParserI Bio::Root::IO);

=head2 new

 Title   : new
 Usage   : 
 Function: Creates a new instance. Recognized named parameters are -file, -fh,
           and -gff_version.

 Returns : a new object
 Args    : names parameters


=cut

sub new {
  my ($class, @args) = @_;
  my $self = $class->SUPER::new(@args);
  
  my ($gff_version) = $self->_rearrange([qw(GFF_VERSION)],@args);

  # initialize IO
  $self->_initialize_io(@args);
  
  $self->_parse_header();

  $gff_version ||= 2;
  
  if( ! $self->gff_version($gff_version) )  {
      $self->throw("Can't build a GFF object with the unknown version ".
		   $gff_version);
  }
  $self->{'_first'} = 1;
  return $self;
}

=head2 _parse_header

 Title   : _parse_header
 Usage   : $gffio->_parse_header()
 Function: used to turn parse GFF header lines.  currently
           produces Bio::LocatableSeq objects from ##sequence-region
           lines
 Example :
 Returns : 1 on success
 Args    : none


=cut

sub _parse_header{
   my ($self,@args) = @_;

   my @unhandled;
   while(my $line = $self->_readline()){
 	 my $handled = 0;

	 if($line =~ /^\#\#sequence-region\s+(\S+)\s+(\S+)\s+(\S+)\s*/){
	   my($seqid,$start,$end) = ($1,$2,$3);
	   push @{ $self->{'segments'} }, Bio::LocatableSeq->new(
															 -id    => unescape($seqid),
															 -start => $start,
															 -end   => $end,
															);
	   $handled = 1;
	 } elsif($line =~ /^(\#\#feature-ontology)/) {
	   #to be implemented
	   $self->warn("$1 header tag parsing unimplemented");
	 } elsif($line =~ /^(\#\#attribute-ontology)/) {
	   #to be implemented
	   $self->warn("$1 header tag parsing unimplemented");
	 } elsif($line =~ /^(\#\#source-ontology)/) {
	   #to be implemented
	   $self->warn("$1 header tag parsing unimplemented");
	 } elsif($line =~ /^(\#\#\#)/) {
	   #to be implemented
	   $self->warn("$1 header tag parsing unimplemented");
	 } elsif($line =~ /^(\#\#FASTA)/) {
	   #to be implemented
	   $self->warn("$1 header tag parsing unimplemented");
	 }

 	 if(!$handled){
	   push @unhandled, $line
 	 }

	 #looks like the header is over!
	 last unless $line =~ /^\#/;
   }

   foreach my $line (@unhandled){
	 $self->_pushback($line);
   }

   return 1;
}


=head2 next_segment

 Title   : next_segment
 Usage   : my $seq = $gffio->next_segment;
 Function: Returns a Bio::LocatableSeq object corresponding to a 
           GFF "##sequence-region" header line.
 Example :
 Returns : A Bio::LocatableSeq object, or undef if
           there are no more sequences.
 Args    : none


=cut

sub next_segment{
   my ($self,@args) = @_;

   return shift @{ $self->{'segments'} } if defined $self->{'segments'};
   return undef;
}

=head2 next_feature

 Title   : next_feature
 Usage   : $seqfeature = $gffio->next_feature();
 Function: Returns the next feature available in the input file or stream, or
           undef if there are no more features.
 Example :
 Returns : A Bio::SeqFeatureI implementing object, or undef if there are no
           more features.
 Args    : none    

=cut

sub next_feature {
    my ($self) = @_;
    
    my $gff_string;

    # be graceful about empty lines or comments, and make sure we return undef
    # if the input's consumed
    while(($gff_string = $self->_readline()) && defined($gff_string)) {	
	  next if($gff_string =~ /^\#/ || $gff_string =~ /^\s*$/ ||
			  $gff_string =~ /^\/\//);
	  last;
    }
    return undef unless $gff_string;

    my $feat = Bio::SeqFeature::Generic->new();
    $self->from_gff_string($feat, $gff_string);

    return $feat;
}

=head2 from_gff_string

 Title   : from_gff_string
 Usage   : $gff->from_gff_string($feature, $gff_string);
 Function: Sets properties of a SeqFeatureI object from a GFF-formatted
           string. Interpretation of the string depends on the version
           that has been specified at initialization.

           This method is used by next_feature(). It actually dispatches to
           one of the version-specific (private) methods.
 Example :
 Returns : void
 Args    : A Bio::SeqFeatureI implementing object to be initialized
           The GFF-formatted string to initialize it from

=cut

sub from_gff_string {
    my ($self, $feat, $gff_string) = @_;

    if($self->gff_version() == 1)  {
	return $self->_from_gff1_string($feat, $gff_string);
    } elsif( $self->gff_version() == 3 ) {
	return $self->_from_gff3_string($feat, $gff_string);
    } else {
	return $self->_from_gff2_string($feat, $gff_string);
    }
}

=head2 _from_gff1_string

 Title   : _from_gff1_string
 Usage   :
 Function:
 Example :
 Returns : void
 Args    : A Bio::SeqFeatureI implementing object to be initialized
           The GFF-formatted string to initialize it from

=cut

sub _from_gff1_string {
   my ($gff, $feat, $string) = @_;
   chomp $string;
   my ($seqname, $source, $primary, $start, $end, $score, 
       $strand, $frame, @group) = split(/\t/, $string);

   if ( !defined $frame ) {
       $feat->throw("[$string] does not look like GFF to me");
   }
   $frame = 0 unless( $frame =~ /^\d+$/);
   $feat->seq_id($seqname);
   $feat->source_tag($source);
   $feat->primary_tag($primary);
   $feat->start($start);
   $feat->end($end);
   $feat->frame($frame);
   if ( $score eq '.' ) {
       #$feat->score(undef);
   } else {
       $feat->score($score);
   }
   if ( $strand eq '-' ) { $feat->strand(-1); }
   if ( $strand eq '+' ) { $feat->strand(1); }
   if ( $strand eq '.' ) { $feat->strand(0); }
   foreach my $g ( @group ) {
       if ( $g =~ /(\S+)=(\S+)/ ) {
	   my $tag = $1;
	   my $value = $2;
	   $feat->add_tag_value($1, $2);
       } else {
	   $feat->add_tag_value('group', $g);
       }
   }
}

=head2 _from_gff2_string

 Title   : _from_gff2_string
 Usage   :
 Function:
 Example :
 Returns : void
 Args    : A Bio::SeqFeatureI implementing object to be initialized
           The GFF2-formatted string to initialize it from


=cut

sub _from_gff2_string {
   my ($gff, $feat, $string) = @_;
   chomp($string);

   # according to the Sanger website, GFF2 should be single-tab
   # separated elements, and the free-text at the end should contain
   # text-translated tab symbols but no "real" tabs, so splitting on
   # \t is safe, and $attribs gets the entire attributes field to be
   # parsed later

   my ($seqname, $source, $primary, $start, 
       $end, $score, $strand, $frame, @attribs) = split(/\t+/, $string);
   my $attribs = join '', @attribs;  # just in case the rule 
                                     # against tab characters has been broken
   if ( !defined $frame ) {
       $feat->throw("[$string] does not look like GFF2 to me");
   }
   $feat->seq_id($seqname);
   $feat->source_tag($source);
   $feat->primary_tag($primary);
   $feat->start($start);
   $feat->end($end);
   $feat->frame($frame);
   if ( $score eq '.' ) {
       # $feat->score(undef);
   } else {
       $feat->score($score);
   }
   if ( $strand eq '-' ) { $feat->strand(-1); }
   if ( $strand eq '+' ) { $feat->strand(1); }
   if ( $strand eq '.' ) { $feat->strand(0); }


   #  <Begin Inefficient Code from Mark Wilkinson> 
   # this routine is necessay to allow the presence of semicolons in
   # quoted text Semicolons are the delimiting character for new
   # tag/value attributes.  it is more or less a "state" machine, with
   # the "quoted" flag going up and down as we pass thorugh quotes to
   # distinguish free-text semicolon and hash symbols from GFF control
   # characters
   
   
   my $flag = 0; # this could be changed to a bit and just be twiddled
   my @parsed;

   # run through each character one at a time and check it
   # NOTE: changed to foreach loop which is more efficient in perl
   # --jasons

   for my $a ( split //, $attribs ) { 
       # flag up on entering quoted text, down on leaving it
       if( $a eq '"') { $flag = ( $flag == 0 ) ? 1:0 }
       elsif( $a eq ';' && $flag ) { $a = "INSERT_SEMICOLON_HERE"}
       elsif( $a eq '#' && ! $flag ) { last } 
       push @parsed, $a;
   }
   $attribs = join "", @parsed; # rejoin into a single string

   # <End Inefficient Code>   
   # Please feel free to fix this and make it more "perlish"

   my @key_vals = split /;/, $attribs;   # attributes are semicolon-delimited

   foreach my $pair ( @key_vals ) {
       # replace semicolons that were removed from free-text above.
       $pair =~ s/INSERT_SEMICOLON_HERE/;/g;        

       # separate the key from the value
       my ($blank, $key, $values) = split  /^\s*([\w\d]+)\s/, $pair; 


       if( defined $values ) {
	   my @values;
	   # free text is quoted, so match each free-text block
	   # and remove it from the $values string
	   while ($values =~ s/"(.*?)"//){
	       # and push it on to the list of values (tags may have
	       # more than one value... and the value may be undef)	       
	       push @values, $1;
	   }

	   # and what is left over should be space-separated
	   # non-free-text values

	   my @othervals = split /\s+/, $values;  
	   foreach my $othervalue(@othervals){
	       # get rid of any empty strings which might 
	       # result from the split
	       if (CORE::length($othervalue) > 0) {push @values, $othervalue}  
	   }

	   foreach my $value(@values){
	       $feat->add_tag_value($key, $value);
	   }
       }
   }
}


sub _from_gff3_string {
    my ($gff, $feat, $string) = @_;
    chomp($string);

    # according to the nascent GFF3 spec, it should be space
    # separated elements, spaces anywhere else should be escaped.

    my ($seqname, $source, $primary, $start, $end, 
	$score, $strand, $frame, $groups) = split(/\s+/, $string);
    
    if ( ! defined $frame ) {
	$feat->throw("[$string] does not look like GFF3 to me");
    }
    $feat->seq_id($seqname);
    $feat->source_tag($source);
    $feat->primary_tag($primary);
    $feat->start($start);
    $feat->end($end);
    $feat->frame($frame);
    if ( $score eq '.' ) {
	#$feat->score(undef);
    } else {
	$feat->score($score);
    }
    if ( $strand eq '-' ) { $feat->strand(-1); }
    if ( $strand eq '+' ) { $feat->strand(1); }
    if ( $strand eq '.' ) { $feat->strand(0); }
    my @groups = split(/\s*;\s*/, $groups);

    for my $group (@groups) {
	my ($tag,$value) = split /=/,$group;
	$tag             = unescape($tag);
	my @values       = map {unescape($_)} split /,/,$value;
	for my $v ( @values ) {  $feat->add_tag_value($tag,$v); }
    }
}

# taken from Bio::DB::GFF
sub unescape {
  my $v = shift;
  $v =~ tr/+/ /;
  $v =~ s/%([0-9a-fA-F]{2})/chr hex($1)/ge;
  return $v;
}

=head2 write_feature

 Title   : write_feature
 Usage   : $gffio->write_feature($feature);
 Function: Writes the specified SeqFeatureI object in GFF format to the stream
           associated with this instance.
 Returns : none
 Args    : An array of Bio::SeqFeatureI implementing objects to be serialized

=cut

sub write_feature {
    my ($self, @features) = @_;
    return unless @features;
    if( $self->{'_first'} && $self->gff_version() == 3 ) {
	$self->_print("##gff-version 3\n");
    }
    $self->{'_first'} = 0;
    foreach my $feature ( @features ) {
	$self->_print($self->gff_string($feature)."\n");
    }
}

=head2 gff_string

 Title   : gff_string
 Usage   : $gffstr = $gffio->gff_string($feature);
 Function: Obtain the GFF-formatted representation of a SeqFeatureI object.
           The formatting depends on the version specified at initialization.

           This method is used by write_feature(). It actually dispatches to
           one of the version-specific (private) methods.
 Example :
 Returns : A GFF-formatted string representation of the SeqFeature
 Args    : A Bio::SeqFeatureI implementing object to be GFF-stringified

=cut

sub gff_string{
    my ($self, $feature) = @_;

    if($self->gff_version() == 1) {
	return $self->_gff1_string($feature);
    } elsif( $self->gff_version() == 3 ) {
	return $self->_gff3_string($feature);
    } else {
	return $self->_gff2_string($feature);
    }
}

=head2 _gff1_string

 Title   : _gff1_string
 Usage   : $gffstr = $gffio->_gff1_string
 Function: 
 Example :
 Returns : A GFF1-formatted string representation of the SeqFeature
 Args    : A Bio::SeqFeatureI implementing object to be GFF-stringified

=cut

sub _gff1_string{
   my ($gff, $feat) = @_;
   my ($str,$score,$frame,$name,$strand);

   if( $feat->can('score') ) {
       $score = $feat->score();
   }
   $score = '.' unless defined $score;

   if( $feat->can('frame') ) {
       $frame = $feat->frame();
   }
   $frame = '.' unless defined $frame;

   $strand = $feat->strand();
   if(! $strand) {
       $strand = ".";
   } elsif( $strand == 1 ) {
       $strand = '+';
   } elsif ( $feat->strand == -1 ) {
       $strand = '-';
   }
   
   if( $feat->can('seqname') ) {
       $name = $feat->seq_id();
       $name ||= 'SEQ';
   } else {
       $name = 'SEQ';
   }


   $str = join("\t",
                 $name,
		 $feat->source_tag(),
		 $feat->primary_tag(),
		 $feat->start(),
		 $feat->end(),
		 $score,
		 $strand,
		 $frame);

   foreach my $tag ( $feat->all_tags ) {
       foreach my $value ( $feat->each_tag_value($tag) ) {
	   $str .= " $tag=$value";
       }
   }


   return $str;
}

=head2 _gff2_string

 Title   : _gff2_string
 Usage   : $gffstr = $gffio->_gff2_string
 Function: 
 Example :
 Returns : A GFF2-formatted string representation of the SeqFeature
 Args    : A Bio::SeqFeatureI implementing object to be GFF2-stringified

=cut

sub _gff2_string{
   my ($gff, $feat) = @_;
   my ($str,$score,$frame,$name,$strand);

   if( $feat->can('score') ) {
       $score = $feat->score();
   }
   $score = '.' unless defined $score;

   if( $feat->can('frame') ) {
       $frame = $feat->frame();
   }
   $frame = '.' unless defined $frame;

   $strand = $feat->strand();
   if(! $strand) {
       $strand = ".";
   } elsif( $strand == 1 ) {
       $strand = '+';
   } elsif ( $feat->strand == -1 ) {
       $strand = '-';
   }

   if( $feat->can('seqname') ) {
       $name = $feat->seq_id();
       $name ||= 'SEQ';
   } else {
       $name = 'SEQ';
   }
   $str = join("\t",
                 $name,
		 $feat->source_tag(),
		 $feat->primary_tag(),
		 $feat->start(),
		 $feat->end(),
		 $score,
		 $strand,
		 $frame);

   # the routine below is the only modification I made to the original
   # ->gff_string routine (above) as on November 17th, 2000, the
   # Sanger webpage describing GFF2 format reads: "From version 2
   # onwards, the attribute field must have a tag value structure
   # following the syntax used within objects in a .ace file,
   # flattened onto one line by semicolon separators. Tags must be
   # standard identifiers ([A-Za-z][A-Za-z0-9_]*).  Free text values
   # must be quoted with double quotes".

   # MW

   
   my @all_tags = $feat->all_tags;
   my @group;
   if (@all_tags) {  # only play this game if it is worth playing...
       foreach my $tag ( @all_tags ) {
	   my @v;
	   foreach my $value ( $feat->each_tag_value($tag) ) {
	       if ($value =~ /[^A-Za-z0-9_]/){
		   $value =~ s/\t/\\t/g; # substitute tab and newline 
		                         # characters
		   $value =~ s/\n/\\n/g; # to their UNIX equivalents
		   $value = '"' . $value . '" ';
	       }                                 # if the value contains 
	                                         # anything other than valid 
	                                         # tag/value characters, then 
	                                         # quote it
	       $value = '\""' unless defined $value; 
                                              # if it is completely empty, 
	                                      # then just make empty double 
	                                      # quotes
	       push @v, $value;
	       # for this tag (allowed in GFF2 and .ace format)
	   }
	   push @group, "$tag ".join(" ", @v);
       }
   }
   $str .= "\t" . join(' ; ', @group);
   # Add Target information for Feature Pairs
   if( ! $feat->has_tag('Target') && # This is a bad hack IMHO
       ! $feat->has_tag('Group') &&
       $feat->isa('Bio::SeqFeature::FeaturePair') ) {
       $str .= sprintf("\tTarget %s %d %d", $feat->feature2->seq_id,
		       ( $feat->feature2->strand < 0 ? 
			 ( $feat->feature2->end,
			   $feat->feature2->start) :
			 ( $feat->feature2->start,
			   $feat->feature2->end) 
			 ));
   }
   return $str;
}

=head2 _gff3_string

 Title   : _gff3_string
 Usage   : $gffstr = $gffio->_gff3_string
 Function: 
 Example :
 Returns : A GFF3-formatted string representation of the SeqFeature
 Args    : A Bio::SeqFeatureI implementing object to be GFF2-stringified

=cut

sub _gff3_string {
    my ($gff, $feat) = @_;
    my ($score,$frame,$name,$strand);

    if( $feat->can('score') ) {
	$score = $feat->score();
    }
    $score = '.' unless defined $score;

    if( $feat->can('frame') ) {
	$frame = $feat->frame();
    }
    $frame = '.' unless defined $frame;

    $strand = $feat->strand();

    if(! $strand) {
	$strand = ".";
    } elsif( $strand == 1 ) {
	$strand = '+';
    } elsif ( $feat->strand == -1 ) {
	$strand = '-';
    }

    if( $feat->can('seqname') ) {
	$name = $feat->seq_id();
	$name ||= 'SEQ';
    } else {
	$name = 'SEQ';
    }
    my @groups,
    my @all_tags = $feat->all_tags;
    for my $tag ( @all_tags ) {
	my $valuestr; # a string which will hold one or more values 
	# for this tag, with quoted free text and 
	# space-separated individual values.
	my @v;
	for my $value ( $feat->each_tag_value($tag) ) {	    
	    $value =~ tr/ /+/;
	    if ($value =~ /[^a-zA-Z0-9\,\;\=\.:\%\^\*\$\@\!\+\_\?\-]/) {
		$value =~ s/\t/\\t/g; # substitute tab and newline 
		# characters
		$value =~ s/\n/\\n/g; # to their UNIX equivalents
		$value = '"' . $value . '"';
	    }
	    if( defined $value ) { 
		$value =~ s/([\t\n\=;,])/sprintf("%%%X",ord($1))/ge;
	    } else {
		# if it is completely empty, 
		# then just make empty double 
		# quotes
		$value = "\"\"";
	    } 	    
	    push @v, $value;
	}
	push @groups, "$tag=".join(",",@v);
    }
    # Add Target information for Feature Pairs
    if( ! $feat->has_tag('Target') && 
	! $feat->has_tag('Group') &&
	$feat->isa('Bio::SeqFeature::FeaturePair') ) {
	push @groups, sprintf("Target=%s:%d..%d", 
			      $feat->feature2->seq_id,
			      ( $feat->feature2->strand < 0 ? 
				( $feat->feature2->end,
				  $feat->feature2->start) :
				( $feat->feature2->start,
				      $feat->feature2->end) 
				));
    }

    my $gff_string = "";
    if ($feat->location->isa("Bio::Location::SplitLocationI")) {
        my @locs = $feat->location->each_Location;
        foreach my $loc (@locs) {
            $gff_string .= join("\t",
                $name,
                $feat->source_tag(),
                $feat->primary_tag(),
                $loc->start(),
                $loc->end(),
                $score,
                $strand,
                $frame,
                join(';', @groups)) . "\n";
        }
        chop $gff_string;
        return $gff_string;
    } else {
        $gff_string = join("\t",
		$name,
		$feat->source_tag(),
		$feat->primary_tag(),
		$feat->start(),
		$feat->end(),
		$score,
		$strand,
		$frame, 
		join(';', @groups));
    }
    return $gff_string;
}

=head2 gff_version

 Title   : _gff_version
 Usage   : $gffversion = $gffio->gff_version
 Function: 
 Example :
 Returns : The GFF version this parser will accept and emit.
 Args    : none

=cut

sub gff_version {
  my ($self, $value) = @_;
  if(defined $value && grep {$value == $_ } ( 1, 2, 3)) {
    $self->{'GFF_VERSION'} = $value;
  }
  return $self->{'GFF_VERSION'};
}

# Make filehandles

=head2 newFh

 Title   : newFh
 Usage   : $fh = Bio::Tools::GFF->newFh(-file=>$filename,-format=>'Format')
 Function: does a new() followed by an fh()
 Example : $fh = Bio::Tools::GFF->newFh(-file=>$filename,-format=>'Format')
           $feature = <$fh>;    # read a feature object
           print $fh $feature ; # write a feature object
 Returns : filehandle tied to the Bio::Tools::GFF class
 Args    :

=cut

sub newFh {
  my $class = shift;
  return unless my $self = $class->new(@_);
  return $self->fh;
}

=head2 fh

 Title   : fh
 Usage   : $obj->fh
 Function:
 Example : $fh = $obj->fh;      # make a tied filehandle
           $feature = <$fh>;   # read a feature object
           print $fh $feature; # write a feature object
 Returns : filehandle tied to Bio::Tools::GFF class
 Args    : none

=cut


sub fh {
  my $self = shift;
  my $class = ref($self) || $self;
  my $s = Symbol::gensym;
  tie $$s,$class,$self;
  return $s;
}

sub DESTROY {
    my $self = shift;

    $self->close();
}

sub TIEHANDLE {
    my ($class,$val) = @_;
    return bless {'gffio' => $val}, $class;
}

sub READLINE {
  my $self = shift;
  return $self->{'gffio'}->next_feature() unless wantarray;
  my (@list, $obj);
  push @list, $obj while $obj = $self->{'gffio'}->next_feature();
  return @list;
}

sub PRINT {
  my $self = shift;
  $self->{'gffio'}->write_feature(@_);
}

1;

