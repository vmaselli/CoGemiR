
#
# Module for Bio::Cogemir::DBSQL::BaseAdaptor
#
# Cared for by Elia Stupka <elia@tigem.it>
#
# Copyright Elia Stupka - adapted from Ensembl
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::BaseAdaptor - Base Adaptor for DBSQL adaptors

=head1 SYNOPSIS

    # base adaptor provides
    
    # SQL prepare function
    $adaptor->prepare("sql statement");

    # get of root DBAdaptor object
    $adaptor->db();

    # delete memory cycles, called automatically
    $adaptor->deleteObj();

    # constructor, ok for inheritence
    $adaptor = Bio::Cogemir::DBSQL::SubClassOfBaseAdaptor->new($dbobj)

=head1 DESCRIPTION

This is a true base class for Adaptors in the Cogemir DBSQL
system. Original idea from Arne Stabenau

Adaptors are expected to have the following functions

    $obj = $adaptor->fetch_by_dbID($internal_id);

which builds the object from the primary key of the object. This
function is crucial because it allows adaptors to collaborate
relatively independently of each other - in other words, we can change
the schema under one adaptor without too many knock on changes through
the other adaptors.

Most adaptors will also have

    $dbid = $adaptor->store($obj);

which stores the object. 

Other fetch functions go by the convention of

    @object_array = @{$adaptor->fetch_all_by_XXXX($arguments_for_XXXX)};

sometimes it returns an array ref denoted by the 'all' in the name of the 
method, sometimes an individual object. For example

    $hsp = $hsp_adaptor->fetch_by_dbID($id);

or

    @hsps  = @{$hsp_adaptor->fetch_all_by_target_member_seq($seq)};

Occassionally adaptors need to provide access to lists of ids. In this case the
convention is to go list_XXXX, such as

    @target_member_seq_ids = @{$hsp_adaptor->list_target_member_seq_ids()};

=head1 CONTACT

Elia Stupka - elia@tigem.it

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Cogemir::DBSQL::BaseAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";
@ISA = qw(Bio::Root::Root);


=head2 new

  Arg [1]    : Bio::Cogemir::DBSQL::DBConnection $dbobj
  Example    : $adaptor = new AdaptorInheritedFromBaseAdaptor($dbobj);
  Description: Creates a new BaseAdaptor object.  The intent is that this
               constructor would be called by an inherited superclass either
               automatically or through $self->SUPER::new in an overridden 
               new method.
  Returntype : Bio::Cogemir::DBSQL::BaseAdaptor
  Exceptions : none
  Caller     : Bio::Cogemir::DBSQL::DBConnection

=cut

sub new {
    my ($class,$dbobj) = @_;
    my $self = {};
    bless $self,$class;

    if( !defined $dbobj || !ref $dbobj ) {
        $self->throw("Don't have a db [$dbobj] for new adaptor");
    }

    if($dbobj->isa('Bio::Cogemir::Container')) {
      #avoid a circular reference loop!
      $self->db($dbobj->_obj);
    } else {
      $self->db($dbobj);
    }
    return $self;
}


=head2 prepare

  Arg [1]    : string $string
               a SQL query to be prepared by this adaptors database
  Example    : $sth = $adaptor->prepare("select yadda from blabla")
  Description: provides a DBI statement handle from the adaptor. A convenience
               function so you dont have to write $adaptor->db->prepare all the
               time
  Returntype : DBI::StatementHandle
  Exceptions : none
  Caller     : Adaptors inherited from BaseAdaptor

=cut

sub prepare{
   my ($self,$string) = @_;
   return $self->db->prepare($string);
}


=head2 db

  Arg [1]    : (optional) Bio::Cogemir::DBSQL::DBConnection $obj 
               the database this adaptor is using.
  Example    : $db = $adaptor->db();
  Description: Getter/Setter for the DatabaseConnection that this adaptor is 
               using.
  Returntype : Bio::Cogemir::DBSQL::DBConnection
  Exceptions : none
  Caller     : Adaptors inherited fro BaseAdaptor

=cut

sub db{
   my $obj = shift;
   if( @_ ) {
      my $value = shift;
      $obj->{'db'} = $value;
    }
    return $obj->{'db'};

}

=head2 update

  Arg [1]    : column name, value to update
               the value to be updated in this database
  Example    : $obj_adaptor->update('table','column name',$obj);
 Description : Update a member in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update{
	 
	 my ($self,$table,$field,$obj,$id) = @_;
	 my $value = $obj->$field;
  	 unless ($id){$id = $table."_id"};
	$self->throw("I need a dbID for $obj") unless $obj->dbID;
	my $update_sql = "
		 UPDATE $table
			SET $field = ?
		  WHERE  $id= ?";
 
	#if ($table eq 'functional_region_gene_region'){print "$update_sql ",$obj->$field, " ",$obj->dbID,"\n";}
	
	my $sth = $self->prepare( $update_sql );
	$sth->execute( $obj->$field, $obj->dbID() );
	return $obj->dbID; 

}

=head2 deleteObj

  Arg [1]    : none
  Example    : none
  Description: Cleans up this objects references to other objects so that
               proper garbage collection can occur
  Returntype : none
  Exceptions : none
  Caller     : Bio::Cogemir::DBConnection

=cut

sub deleteObj {
  my $self = shift;

  #print STDERR "\t\tBaseAdaptor::deleteObj\n";

  #remove reference to the database adaptor
  $self->{'db'} = undef;
}


# list primary keys for a particular table
# args are table name and primary key field
# if primary key field is not supplied, tablename_id is assumed
# returns listref of IDs
sub _list_dbIDs {

  my ($self, $table, $pk) = @_;
  if (!defined($pk)) {
    $pk = $table . "_id";
  }

  my @out;
  my $sql = "SELECT " . $pk . " FROM " . $table;
  my $sth = $self->prepare($sql);
  $sth->execute;

  while (my ($id) = $sth->fetchrow) {
    push(@out, $id);
  }

  $sth->finish;

  return \@out;
}



1;
