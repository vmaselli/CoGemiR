#
# Module for Bio::Cogemir::DBSQL::LogicNameAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::LogicNameAdaptor

=head1 SYNOPSIS

    $logic_name_adaptor = $db->get_LogicNameAdaptor();

    $logic_name = $logic_name_adaptor->fetch_by_dbID();

    $logic_name = $logic_name_adaptor->fetch_by_name();

=head1 DESCRIPTION

    This adaptor work with the logic_name table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::LogicNameAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";
use Bio::Cogemir::LogicName;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of LogicName
  Example    : $logic_name = $ln_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an logic_name from the database via its internal id
  Returntype : Bio::Cogemir::LogicName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    
    $self->throw("I need a logic_name id") unless $dbID;
    my $query = qq {
    SELECT name
      FROM logic_name 
      WHERE  logic_name_id = ? 
    };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($name) = $sth->fetchrow_array();
    unless (defined $name){
    	$self->warn("no logic_name for $dbID");
    	return undef;
    }
    my ($logic_name) =  Bio::Cogemir::LogicName->new(   
							    -DBID => $dbID,
							    -ADAPTOR =>$self,
							    -NAME => $name
							   );
    return $logic_name;
}

=head2 fetch_by_name

  Arg [1]    : logic_name name
  Example    : $logic_name = $logic_name_adaptor->fetch_by_name($name);
  Description: Retrieves an logic_name from the database via its name
  Returntype : Bio::Cogemir::LogicName
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
    my ($self, $name) = @_;
    
    $self->throw("I need a name") unless $name;

    my $query = qq {
    SELECT logic_name_id
      FROM logic_name 
      WHERE  name = ? 
    };

    my $sth = $self->prepare($query);
    $sth->execute($name);
	my ($dbID) = $sth->fetchrow_array();
    unless (defined $dbID){
    	$self->warn("no logic_name for $name");
    	return undef;
    }
    my $logic_name = $self->fetch_by_dbID($dbID);
    return $logic_name;
}

sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	my $query = qq {
		SELECT logic_name_id
		FROM logic_name
		WHERE name = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->name);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Analysis
               the logic_name  to be stored in this database
  Example    : $logic_name_adaptor->store($logic_name);
 Description : Stores a logic_name in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $logic_name ) = @_;

    #if it is not an logic_name don't store
    if( ! $logic_name->isa('Bio::Cogemir::LogicName') ) {
	$self->throw("$logic_name is not a Bio::Cogemir::LogicName object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($logic_name->can('dbID') && $logic_name->dbID) {return $logic_name->dbID();}  
    
    #if name exists return without storing
    if ($self->_exists($logic_name)){
        return $self->_exists($logic_name);
    }

    #otherwise store the information being passed
    my $sql = q {INSERT INTO logic_name SET name = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($logic_name->name());
    my $logic_name_id = $sth->{'mysql_insertid'};
    
    $logic_name->dbID($logic_name_id);
    $logic_name->adaptor($self);
    return $logic_name_id;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::LogicName
               the logic_name  to be removed in this database
  Example    : $logic_name_adaptor->remove($logic_name);
 Description : removes a logic_name in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $logic_name) = @_;
    
    if( ! defined $logic_name->dbID() ) {$self->throw("A dbID is not defined\n");}
    
    foreach my $analysis (@{$self->db->get_AnalysisAdaptor->fetch_by_logic_name($logic_name->dbID)}){
        $analysis->logic_name->dbID(0);
        $self->db->get_AnalysisAdaptor->update($analysis);
    }
    foreach my $seq (@{$self->db->get_SeqAdaptor->fetch_by_type($logic_name->dbID)}){
        $seq->logic_name->dbID(0);
        $self->db->get_SeqAdaptor->update($seq);
    }
    my $blast_list = $self->db->get_BlastAdaptor->fetch_by_logic_name($logic_name->dbID);
    if (defined $blast_list){
      foreach my $blast (@{$blast_list}){
        $blast->logic_name->dbID(0);
        $self->db->get_BlastAdaptor->update($blast);
      }
    }
    my $sth= $self->prepare( "delete from logic_name where logic_name_id = ? " );
    $sth->execute($logic_name->dbID());
    return 1;

}


=head2 _remove

  Arg [1]    : Bio::Cogemir::LogicName
               the logic_name  to be removed in this database
  Example    : $logic_name_adaptor->remove($logic_name);
 Description : removes a logic_name in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $logic_name) = @_;
    return  $self->remove($logic_name);
}

=head2 update

  Arg [1]    : Bio::Cogemir::LogicName
               the logic_name  to be updated in this database
  Example    : $logic_name_adaptor->update($logic_name);
 Description : updates an logic_name in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
    my ($self, $logic_name) = @_;
    if( ! $logic_name->isa('Bio::Cogemir::LogicName') ) {
	$self->throw("$logic_name is not a Bio::Cogemir::LogicName object - not updating!");
    }
    my $sql = q {UPDATE logic_name SET name = ? where logic_name_id = ? };
    my $sth = $self->prepare($sql);
    $sth->execute($logic_name->name(),$logic_name->dbID);
    my $logic_name_updated =  $self->fetch_by_dbID($logic_name->dbID);

    return $logic_name_updated;
}
1;
