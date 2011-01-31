# $Id: SimpleGOEngine.pm,v 1.24 2003/10/23 01:52:42 allenday Exp $
#
# BioPerl module for Bio::Ontology::SimpleGOEngine
#
# Cared for by Christian M. Zmasek <czmasek@gnf.org> or <cmzmasek@yahoo.com>
#
# (c) Christian M. Zmasek, czmasek@gnf.org, 2002.
# (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
#
# You may distribute this module under the same terms as perl itself.
# Refer to the Perl Artistic License (see the license accompanying this
# software package, or see http://www.perl.com/language/misc/Artistic.html)
# for the terms under which you may use, modify, and redistribute this module.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

SimpleGOEngine - a Ontology Engine for GO implementing OntologyEngineI

=head1 SYNOPSIS

  use Bio::Ontology::SimpleGOEngine;

  my $parser = Bio::Ontology::SimpleGOEngine->new
	( -defs_file => "/home/czmasek/GO/GO.defs",
	  -files     => ["/home/czmasek/GO/component.ontology",
	                 "/home/czmasek/GO/function.ontology",
	                 "/home/czmasek/GO/process.ontology"] );

  my $engine = $parser->parse();

  my $IS_A    = Bio::Ontology::RelationshipType->get_instance( "IS_A" );
  my $PART_OF = Bio::Ontology::RelationshipType->get_instance( "PART_OF" );


=head1 DESCRIPTION

Needs Graph.pm from CPAN.

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

=head1 AUTHOR

Christian M. Zmasek

Email: czmasek@gnf.org  or  cmzmasek@yahoo.com

WWW:   http://www.genetics.wustl.edu/eddy/people/zmasek/

Address:

  Genomics Institute of the Novartis Research Foundation
  10675 John Jay Hopkins Drive
  San Diego, CA 92121

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...



package Bio::Ontology::SimpleGOEngine;

use Graph::Directed;

use vars qw( @ISA );
use strict;
use Bio::Root::Root;
use Bio::Ontology::RelationshipType;
use Bio::Ontology::RelationshipFactory;
use Bio::Ontology::OntologyEngineI;
use Data::Dumper;

use constant TRUE     => 1;
use constant FALSE    => 0;
use constant IS_A     => "IS_A";
use constant PART_OF  => "PART_OF";
use constant TERM     => "TERM";
use constant TYPE     => "TYPE";
use constant ONTOLOGY => "ONTOLOGY";

@ISA = qw( Bio::Root::Root
           Bio::Ontology::OntologyEngineI );



=head2 new

 Title   : new
 Usage   : $engine = Bio::Ontology::SimpleGOEngine->new()
 Function: Creates a new SimpleGOEngine
 Returns : A new SimpleGOEngine object
 Args    :

=cut

sub new {
    my( $class, @args ) = @_;

    my $self = $class->SUPER::new( @args );

    $self->init();

    return $self;
} # new



=head2 init

 Title   : init()
 Usage   : $engine->init();
 Function: Initializes this Engine.
 Returns :
 Args    :

=cut

sub init {
    my ( $self ) = @_;

    $self->{ "_is_a_relationship" }    = Bio::Ontology::RelationshipType->get_instance( IS_A );
    $self->{ "_part_of_relationship" } = Bio::Ontology::RelationshipType->get_instance( PART_OF );

    $self->graph( Graph::Directed->new() );

    # set defaults for the factories
    $self->relationship_factory(Bio::Ontology::RelationshipFactory->new(
				     -type => "Bio::Ontology::Relationship"));

} # init



=head2 is_a_relationship

 Title   : is_a_relationship()
 Usage   : $IS_A = $engine->is_a_relationship();
 Function: Returns a Bio::Ontology::RelationshipType object for "is-a"
           relationships
 Returns : Bio::Ontology::RelationshipType set to "IS_A"
 Args    :

=cut

sub is_a_relationship {
    my ( $self, $value ) = @_;

    if ( defined $value ) {
        $self->throw( "Attempted to change immutable field" );
    }

    return $self->{ "_is_a_relationship" };
} # is_a_relationship



=head2 part_of_relationship

 Title   : part_of_relationship()
 Usage   : $PART_OF = $engine->part_of_relationship();
 Function: Returns a Bio::Ontology::RelationshipType object for "part-of"
           relationships
 Returns : Bio::Ontology::RelationshipType set to "PART_OF"
 Args    :

=cut

sub part_of_relationship {
    my ( $self, $value ) = @_;

    if ( defined $value ) {
        $self->throw( "Attempted to change immutable field" );
    }

    return $self->{ "_part_of_relationship" };
} # part_of_relationship




=head2 add_term

 Title   : add_term
 Usage   : $engine->add_term( $term_obj );
 Function: Adds a Bio::Ontology::TermI to this engine
 Returns : true if the term was added and false otherwise (e.g., if the
           term already existed in the ontology engine)
 Args    : Bio::Ontology::TermI


=cut

sub add_term {
    my ( $self, $term ) = @_;

    return FALSE if $self->has_term( $term );

    my $goid = $self->_get_id($term);

    $self->graph()->add_vertex( $goid );
    $self->graph()->set_attribute( TERM, $goid, $term );

    return TRUE;

} # add_term



=head2 has_term

 Title   : has_term
 Usage   : $engine->has_term( $term );
 Function: Checks whether this engine contains a particular term
 Returns : true or false
 Args    : Bio::Ontology::TermI
           or
           Term identifier (e.g. "GO:0012345")


=cut

sub has_term {
    my ( $self, $term ) = @_;
    $term = $self->_get_id( $term );
    if ( $self->graph()->has_vertex( $term ) ) {
        return TRUE;
    }
    else {
        return FALSE;
    }

} # has_term


=head2 add_relationship_type

 Title   : add_relationship_type
 Usage   : $engine->add_relationship_type( $type_name, $ont );
 Function: Adds a new relationship type to the engine.  User get_relationship_type($type_name) to retrieve.
 Returns : true if successfully added, false otherwise
 Args    : relationship type name to add (scalar)


=cut

sub add_relationship_type{
   my ($self,@args) = @_;

   if(scalar(@_) == 3){
	 my $type_name = $args[0];
	 my $ont = $args[1];
	 $self->{ "_extra_relationship_types" }{$type_name} = Bio::Ontology::RelationshipType->get_instance($type_name,$ont);
#warn Dumper($self->{"_extra_relationship_types"}{$type_name});
	 return 1;
   }
   return 0;
}


=head2 get_relationship_type

 Title   : get_relationship_type
 Usage   : $engine->get_relationship_type( $type_name );
 Function: Gets a Bio::Ontology::RelationshipI object corresponding to $type_name
 Returns : a Bio::Ontology::RelationshipI object
 Args    :


=cut

sub get_relationship_type{
   my ($self,$type_name) = @_;
   return $self->{ "_extra_relationship_types" }{$type_name};
}

=head2 add_relationship

 Title   : add_relationship
 Usage   : $engine->add_relationship( $relationship );
           $engine->add_relatioship( $subject_term, $predicate_term, $object_term, $ontology );
           $engine->add_relatioship( $subject_id, $predicate_id, $object_id, $ontology);
 Function: Adds a relationship to this engine
 Returns : true if successfully added, false otherwise
 Args    : term id, Bio::Ontology::TermI (rel.type), term id, ontology 
           or
           Bio::Ontology::TermI, Bio::Ontology::TermI (rel.type), Bio::Ontology::TermI, ontology
           or
           Bio::Ontology::RelationshipI

=cut

# term objs or term ids
sub add_relationship {
    my ( $self, $child, $type, $parent, $ont ) = @_;

    if ( scalar( @_ ) == 2 ) {
        $self->_check_class( $child, "Bio::Ontology::RelationshipI" );
        $type   = $child->predicate_term();
        $parent = $child->object_term();
	$ont    = $child->ontology();
        $child  = $child->subject_term();
    }


    $self->_check_class( $type, "Bio::Ontology::TermI" );

    my $parentid = $self->_get_id( $parent );
    my $childid = $self->_get_id( $child );

    my $g = $self->graph();

    $self->add_term($child) unless $g->has_vertex( $childid );
    $self->add_term($parent) unless $g->has_vertex( $parentid );

    # This prevents multi graphs.
    if ( $g->has_edge( $parentid, $childid ) ) {
        return FALSE;
    }

    $g->add_edge( $parentid, $childid );
    $g->set_attribute( TYPE, $parentid, $childid, $type );
    $g->set_attribute( ONTOLOGY, $parentid, $childid, $ont );

    return TRUE;

} # add_relationship




=head2 get_relationships


 Title   : get_relationships
 Usage   : $engine->get_relationships( $term );
 Function: Returns all relationships of a term, or all relationships in
           the graph if no term is specified.
 Returns : Relationship[]
 Args    : term id
           or
           Bio::Ontology::TermI

=cut

sub get_relationships {
    my ( $self, $term ) = @_;

    my $g = $self->graph();

    # obtain the ID if term provided
    my $termid;
    if($term) {
	$termid = $self->_get_id( $term );
	# check for presence in the graph
	if ( ! $g->has_vertex( $termid ) ) {
	    $self->throw( "no term with identifier \"$termid\" in ontology" );
	}
    }

    # now build the relationships
    my $relfact = $self->relationship_factory();
    # we'll build the relationships from edges
    my @rels = ();
    my @edges = $g->edges($termid);
    while(@edges) {
	my $startid = shift(@edges);
	my $endid = shift(@edges);
	my $rel = $relfact->create_object(
		    -subject_term   => $self->get_terms($endid),
                    -object_term    => $self->get_terms($startid),
                    -predicate_term => $g->get_attribute(TYPE, 
							 $startid, $endid),
	            -ontology       => $g->get_attribute(ONTOLOGY, 
							 $startid, $endid));
        push( @rels, $rel );
    }
    
    return @rels;

} # get_relationships

=head2 get_all_relationships


 Title   : get_all_relationships
 Usage   : @rels = $engine->get_all_relationships();
 Function: Returns all relationships in the graph.
 Returns : Relationship[]
 Args    : 

=cut

sub get_all_relationships {
    return shift->get_relationships(@_);
} # get_all_relationships



=head2 get_predicate_terms

 Title   : get_predicate_terms
 Usage   : $engine->get_predicate_terms();
 Function: Returns the types of relationships this engine contains
 Returns : Bio::Ontology::RelationshipType[]
 Args    :


=cut

sub get_predicate_terms {
    my ( $self ) = @_;

    my @a = ( $self->is_a_relationship(),
              $self->part_of_relationship() );

	foreach my $termname (keys %{$self->{ "_extra_relationship_types" }}){
	  push @a, $self->{ "_extra_relationship_types" }{ $termname };
	}

    return @a;
} # get_predicate_terms




=head2 get_child_terms

 Title   : get_child_terms
 Usage   : $engine->get_child_terms( $term_obj, @rel_types );
           $engine->get_child_terms( $term_id, @rel_types );
 Function: Returns the children of this term
 Returns : Bio::Ontology::TermI[]
 Args    : Bio::Ontology::TermI, Bio::Ontology::RelationshipType[]
           or
           term id, Bio::Ontology::RelationshipType[]

           if NO Bio::Ontology::RelationshipType[] is indicated: children
           of ALL types are returned

=cut

sub get_child_terms {
    my ( $self, $term, @types ) = @_;

    return $self->_get_child_parent_terms_helper( $term, TRUE, @types );

} # get_child_terms


=head2 get_descendant_terms

 Title   : get_descendant_terms
 Usage   : $engine->get_descendant_terms( $term_obj, @rel_types );
           $engine->get_descendant_terms( $term_id, @rel_types );
 Function: Returns the descendants of this term
 Returns : Bio::Ontology::TermI[]
 Args    : Bio::Ontology::TermI, Bio::Ontology::RelationshipType[]
           or
           term id, Bio::Ontology::RelationshipType[]

           if NO Bio::Ontology::RelationshipType[] is indicated: descendants
           of ALL types are returned

=cut

sub get_descendant_terms {
    my ( $self, $term, @types ) = @_;

    my %ids = ();
    my @ids = ();

    $term = $self->_get_id( $term );

    if ( ! $self->graph()->has_vertex( $term ) ) {
        $self->throw( "Ontology does not contain a term with an identifier of \"$term\"" );
    }

    $self->_get_descendant_terms_helper( $term, \%ids, \@types );

    while( ( my $id ) = each ( %ids ) ) {
        push( @ids, $id );
    }

    return $self->get_terms( @ids );

} # get_descendant_terms




=head2 get_parent_terms

 Title   : get_parent_terms
 Usage   : $engine->get_parent_terms( $term_obj, @rel_types );
           $engine->get_parent_terms( $term_id, @rel_types );
 Function: Returns the parents of this term
 Returns : Bio::Ontology::TermI[]
 Args    : Bio::Ontology::TermI, Bio::Ontology::RelationshipType[]
           or
           term id, Bio::Ontology::RelationshipType[]

           if NO Bio::Ontology::RelationshipType[] is indicated: parents
           of ALL types are returned

=cut

sub get_parent_terms {
    my ( $self, $term, @types ) = @_;

    return $self->_get_child_parent_terms_helper( $term, FALSE, @types );

} # get_parent_terms



=head2 get_ancestor_terms

 Title   : get_ancestor_terms
 Usage   : $engine->get_ancestor_terms( $term_obj, @rel_types );
           $engine->get_ancestor_terms( $term_id, @rel_types );
 Function: Returns the ancestors of this term
 Returns : Bio::Ontology::TermI[]
 Args    : Bio::Ontology::TermI, Bio::Ontology::RelationshipType[]
           or
           term id, Bio::Ontology::RelationshipType[]

           if NO Bio::Ontology::RelationshipType[] is indicated: ancestors
           of ALL types are returned

=cut

sub get_ancestor_terms {
    my ( $self, $term, @types ) = @_;

    my %ids = ();
    my @ids = ();

    $term = $self->_get_id( $term );

    if ( ! $self->graph()->has_vertex( $term ) ) {
        $self->throw( "Ontology does not contain a term with an identifier of \"$term\"" );
    }

    $self->_get_ancestor_terms_helper( $term, \%ids, \@types );

    while( ( my $id ) = each ( %ids ) ) {
        push( @ids, $id );
    }

    return $self->get_terms( @ids );

} # get_ancestor_terms





=head2 get_leaf_terms

 Title   : get_leaf_terms
 Usage   : $engine->get_leaf_terms();
 Function: Returns the leaf terms
 Returns : Bio::Ontology::TermI[]
 Args    :

=cut

sub get_leaf_terms {
    my ( $self ) = @_;

    my @a = $self->graph()->sink_vertices();

    return $self->get_terms( @a );

}



=head2 get_root_terms()

 Title   : get_root_terms
 Usage   : $engine->get_root_terms();
 Function: Returns the root terms
 Returns : Bio::Ontology::TermI[]
 Args    :

=cut

sub get_root_terms {
    my ( $self ) = @_;


    my @a = $self->graph()->source_vertices();

    return $self->get_terms( @a );

}


=head2 get_terms

 Title   : get_terms
 Usage   : @terms = $engine->get_terms( "GO:1234567", "GO:2234567" );
 Function: Returns term objects with given identifiers
 Returns : Bio::Ontology::TermI[], or the term corresponding to the
           first identifier if called in scalar context
 Args    : term ids[]


=cut

sub get_terms {
    my ( $self, @ids ) = @_;

    my @terms = ();

    foreach my $id ( @ids ) {
        if ( $self->graph()->has_vertex( $id ) ) {
            push( @terms, $self->graph()->get_attribute( TERM, $id ) );
        }
    }

    return wantarray ? @terms : shift(@terms);

} # get_terms


=head2 get_all_terms

 Title   : get_all_terms
 Usage   : $engine->get_all_terms();
 Function: Returns all terms in this engine
 Returns : Bio::Ontology::TermI[]
 Args    :

=cut

sub get_all_terms {
    my ( $self ) = @_;

    return( $self->get_terms( $self->graph()->vertices() ) );

} # get_all_terms


=head2 find_terms

 Title   : find_terms
 Usage   : ($term) = $oe->find_terms(-identifier => "SO:0000263");
 Function: Find term instances matching queries for their attributes.

           This implementation can efficiently resolve queries by
           identifier.

 Example :
 Returns : an array of zero or more Bio::Ontology::TermI objects
 Args    : Named parameters. The following parameters should be recognized
           by any implementations:

              -identifier    query by the given identifier
              -name          query by the given name


=cut

sub find_terms{
    my ($self,@args) = @_;
    my @terms;

    my ($id,$name) = $self->_rearrange([qw(IDENTIFIER NAME)],@args);

    if(defined($id)) {
	@terms = $self->get_terms($id);
    } else {
	@terms = $self->get_all_terms();
    }
    if(defined($name)) {
	@terms = grep { $_->name() eq $name; } @terms;
    }
    return @terms;
}

=head2 relationship_factory

 Title   : relationship_factory
 Usage   : $fact = $obj->relationship_factory()
 Function: Get/set the object factory to be used when relationship
           objects are created by the implementation on-the-fly.

 Example : 
 Returns : value of relationship_factory (a Bio::Factory::ObjectFactoryI
           compliant object)
 Args    : on set, a Bio::Factory::ObjectFactoryI compliant object


=cut

sub relationship_factory{
    my $self = shift;

    return $self->{'relationship_factory'} = shift if @_;
    return $self->{'relationship_factory'};
}

=head2 term_factory

 Title   : term_factory
 Usage   : $fact = $obj->term_factory()
 Function: Get/set the object factory to be used when term objects are
           created by the implementation on-the-fly.

           Note that this ontology engine implementation does not
           create term objects on the fly, and therefore setting this
           attribute is meaningless.

 Example : 
 Returns : value of term_factory (a Bio::Factory::ObjectFactoryI
           compliant object)
 Args    : on set, a Bio::Factory::ObjectFactoryI compliant object


=cut

sub term_factory{
    my $self = shift;

    if(@_) {
	$self->warn("setting term factory, but ".ref($self).
		    " does not create terms on-the-fly");
	return $self->{'term_factory'} = shift;
    }
    return $self->{'term_factory'};
}

=head2 graph

 Title   : graph()
 Usage   : $engine->graph();
 Function: Returns the Graph this engine is based on
 Returns : Graph
 Args    :

=cut

sub graph {
    my ( $self, $value ) = @_;

    if ( defined $value ) {
        $self->_check_class( $value, "Graph::Directed" );
        $self->{ "_graph" } = $value;
    }

    return $self->{ "_graph" };
} # graph



# Internal methods
# ----------------


# Checks the correct format of a GOBO-formatted id
# Gets the id out of a term or id string
sub _get_id {
    my ( $self, $term ) = @_;
    my $id = $term;

    if(ref($term)) {
	# use TermI standard API
	$self->throw("Object doesn't implement Bio::Ontology::TermI. ".
		     "Bummer.")
	    unless $term->isa("Bio::Ontology::TermI");
	$id = $term->identifier();
	# if there is no ID, we need to fake one from ontology name and name
	# in order to achieve uniqueness
	if(!$id) {
	    $id = $term->ontology->name() if $term->ontology();
	    $id = $id ? $id.'|' : '';
	    $id .= $term->name();
	}
    }
    # don't fuss if it looks remotely standard, and we trust GO terms
    return $id
#	if $term->isa("Bio::Ontology::GOterm")||($id =~ /^[A-Z_]{1,8}:\d{1,}$/);
	if $term->isa("Bio::Ontology::GOterm")||($id =~ /^\w+:\w+$/);
    # prefix with something if only numbers
    if($id =~ /^\d+$/) {
	$self->warn(ref($self).": identifier [$id] is only numbers - ".
		    "prefixing with 'GO:'");
	return "GO:" . $id;
    } 
    # we shouldn't have gotten here if it's at least a remotely decent ID
    $self->throw(ref($self).": non-standard identifier '$id'\n")
	unless $id =~ /\|/;
    return $id;
} # _get_id


# Helper for getting children and parent terms
sub _get_child_parent_terms_helper {
    my ( $self, $term, $do_get_child_terms, @types ) = @_;

    foreach my $type ( @types ) {
        $self->_check_class( $type, "Bio::Ontology::TermI" );
    }

    my @relative_terms = ();

    $term = $self->_get_id( $term );
    if ( ! $self->graph()->has_vertex( $term ) ) {
        $self->throw( "Ontology does not contain a term with an identifier of \"$term\"" );
    }

    my @all_relative_terms = ();
    if ( $do_get_child_terms ) {
        @all_relative_terms = $self->graph()->successors( $term );
    }
    else {
        @all_relative_terms = $self->graph()->predecessors( $term );
    }

    foreach my $relative ( @all_relative_terms ) {
        if ( scalar( @types ) > 0 ) {
            foreach my $type ( @types ) {
                my $relative_type;
                if ( $do_get_child_terms ) {
                    $relative_type = $self->graph()->get_attribute( TYPE, $term, $relative );
                }
                else {
                    $relative_type = $self->graph()->get_attribute( TYPE, $relative, $term );
                }
                if ( $relative_type->equals( $type ) ) {
                    push( @relative_terms, $relative );
                }
            }
        }
        else {
            push( @relative_terms, $relative );
        }
    }

    return $self->get_terms( @relative_terms );

} # get_child_terms


# Recursive helper
sub _get_descendant_terms_helper {
    my ( $self, $term, $ids_ref, $types_ref ) = @_;

    my @child_terms = $self->get_child_terms( $term, @$types_ref );

    if ( scalar( @child_terms ) < 1 ) {
        return;
    }

    foreach my $child_term ( @child_terms ) {
        my $child_term_id = $self->_get_id($child_term->identifier());
        $ids_ref->{ $child_term_id } = 0;
        $self->_get_descendant_terms_helper( $child_term_id, $ids_ref, $types_ref );
    }

} # _get_descendant_terms_helper


# Recursive helper
sub _get_ancestor_terms_helper {
    my ( $self, $term, $ids_ref, $types_ref ) = @_;

    my @parent_terms = $self->get_parent_terms( $term, @$types_ref );

    if ( scalar( @parent_terms ) < 1 ) {
        return;
    }

    foreach my $parent_term ( @parent_terms ) {
        my $parent_term_id = $self->_get_id($parent_term->identifier());
        $ids_ref->{ $parent_term_id } = 0;
        $self->_get_ancestor_terms_helper( $parent_term_id, $ids_ref, $types_ref );
    }

} # get_ancestor_terms_helper



sub _check_class {
    my ( $self, $value, $expected_class ) = @_;

    if ( ! defined( $value ) ) {
        $self->throw( "Found [undef] where [$expected_class] expected" );
    }
    elsif ( ! ref( $value ) ) {
        $self->throw( "Found [scalar] where [$expected_class] expected" );
    }
    elsif ( ! $value->isa( $expected_class ) ) {
        $self->throw( "Found [" . ref( $value ) . "] where [$expected_class] expected" );
    }

} # _check_class


#################################################################
# aliases
#################################################################

*get_relationship_types = \&get_predicate_terms;


1;
