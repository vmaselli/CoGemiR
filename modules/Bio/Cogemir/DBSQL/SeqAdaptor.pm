#
# Module for Bio::Cogemir::DBSQL::SeqAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::SeqAdaptor

=head1 SYNOPSIS

    $seq_adaptor = $dbadaptor->get_SeqAdaptor();

    $features = $seq_adaptor->fetch_by_seq_id();

    $features = $seq_adaptor->fetch_by_name();

=head1 DESCRIPTION


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it


=cut

$!=1;
package Bio::Cogemir::DBSQL::SeqAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;

use Bio::Cogemir::Seq;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBConnection;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);

=head2 fetch_by_dbID

  Arg [1]    : internal id of Seq
  Example    : $seq = $seq_adaptor->fetch_by_dbID($seq_id);
  Description: Retrieves an seq from the database via its internal id
  Returntype : Bio::Cogemir::Seq
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
    my ($self, $dbID) = @_;
    $self->throw("I need a dbID") unless $dbID;
    my $query = qq {
    SELECT name, sequence, logic_name_id
      FROM seq 
      WHERE seq_id = ?  
  };

    my $sth = $self->prepare($query);
    $sth->execute($dbID);
	my ($name, $sequence, $logic_name_id) = $sth->fetchrow_array();
	
	unless (defined $name){
    	#$self->warn("no seq for dbID $dbID");
    	return undef;
    }
    
	my $logic_name;
	$logic_name = $self->db->get_LogicNameAdaptor->fetch_by_dbID($logic_name_id) if $logic_name_id;
	my ($seq) = Bio::Cogemir::Seq->new(
					-DBID => $dbID,
					-ADAPTOR => $self,
					-NAME => $name,
					-SEQUENCE => $sequence,
					-LOGIC_NAME =>$logic_name
				);
	
	return $seq;
	
}

=head2 fetch_by_name

  Arg [1]    : name of Seq
  Example    : $seq = $seq_adaptor->fetch_by_name($name);
  Description: Retrieves an seq from the database via its name
  Returntype : listref Bio::Cogemir::Seq
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_name {
     my ($self, $value) = @_;
    $self->throw("I need a name") unless $value;
    my @seqs;
    my $query = qq {
    SELECT seq_id
      FROM seq
      WHERE name =?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while ((my $dbID) = $sth->fetchrow_array()){
        push (@seqs, $self->fetch_by_dbID($dbID));
    }
	return 	\@seqs;
}

=head2 fetch_by_type

  Arg [1]    : type of sequence
  Example    : $seq = $seq_adaptor->fetch_by_type($type);
  Description: Retrieves an seq from the database via its logic name
  Returntype : listref of Bio::Cogemir::Seq
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_type {
     my ($self, $value) = @_;
    $self->throw("I need a logic_name id") unless $value;
    my @seqs;
    my $query = qq {
    SELECT s.seq_id
      FROM seq s
      WHERE s.logic_name_id = ?
    };
	
	my $sth = $self->prepare($query);
    $sth->execute($value);
    while ((my $dbID) = $sth->fetchrow_array()){
        push (@seqs, $self->fetch_by_dbID($dbID));
    }
	return 	\@seqs;
}

=head2 fetch_by_name_type

  Arg [1]    : name and type of sequence
  Example    : $seq = $seq_adaptor->fetch_by_name_type($name,$type);
  Description: Retrieves an seq from the database via its name and logic name
  Returntype : Bio::Cogemir::Seq
  Exceptions : none
  Caller     : general

=cut


sub fetch_by_name_type{
	my ($self, $name, $type) = @_;
	$self->throw("I need a name") unless $name;
	$name =~ s/R/r/;
	my($spid,$t,$root,$p) = split /-/,$name;
	$name =~ s/-$p$// if $p;
	my $seq_id;
	my $query = qq {
		SELECT s.seq_id
		FROM seq s, logic_name l
        WHERE s.logic_name_id = l.logic_name_id 
        AND  s.name like ? 
        AND l.name = ?
	};
	# printf "1. SELECT s.seq_id
# 		FROM seq s, logic_name l
#         WHERE s.logic_name_id = l.logic_name_id 
#         AND  s.name like %s 
#         AND l.name = %s
# 	<p>",$name,$type;
	my $sth = $self->prepare($query);
	$sth->execute($name, $type);
	($seq_id) = $sth->fetchrow;
	unless ($seq_id){
		$name .="-%p";
		$sth->execute($name, $type);
	    ($seq_id) = $sth->fetchrow;
		    unless ($seq_id){
		        $name .="*";
		        $sth->execute($name, $type);
	            ($seq_id) = $sth->fetchrow;
	         }
	}
	# printf "2. SELECT s.seq_id
# 		FROM seq s, logic_name l
#         WHERE s.logic_name_id = l.logic_name_id 
#         AND  s.name like %s 
#         AND l.name = %s
# 	<p>",$name,$type;
	return $self->fetch_by_dbID($seq_id) if $seq_id;
}

sub _exists{
	my ($self,$obj) = @_;
	my $obj_id;
	my $logic_name_id = $obj->logic_name->dbID if defined $obj->logic_name;
	
	my $sql = qq{SELECT seq_id FROM seq WHERE name = ? AND sequence =? AND logic_name_id = ?};
	my $sth = $self->prepare($sql);
	$sth->execute($obj->name, $obj->sequence, $logic_name_id);
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::Seq
               the Seq  to be stored in this database
  Example    : $seq_adaptor->store($seq);
 Description : Stores an Seq in the database
  Returntype : string, seq_id
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $seq ) = @_;

    # if the object being passed is a Cogemir::Seq store it locally with the sequence
    if( ! $seq->isa('Bio::Cogemir::Seq') ) {
	$self->throw("$seq is not a Bio::Cogemir::Seq object - not storing!");
    }
   	if ($seq->can('dbID')&& $seq->dbID) {return $seq->dbID();}
    
    my $logic_name_id;
   	 if (defined $seq->logic_name){
   	    unless ($seq->logic_name->dbID){$logic_name_id = $self->db->get_LogicNameAdaptor->store($seq->logic_name);}
   	    else{$logic_name_id = $seq->logic_name->dbID}
   	 }
    # if the dbID is present and if the Seq is already stored return the dbID 
    if ($self->_exists($seq)){
        return $self->_exists($seq);
    }
    
    # if logic_name doesn't exist store it
	
    my $sql = q { INSERT INTO seq SET name = ?, sequence =? ,  logic_name_id = ?};
    my $sth = $self->prepare($sql);
    $sth->execute($seq->name, $seq->sequence, $logic_name_id);
    
    my $seq_id = $sth->{'mysql_insertid'};
 	$seq->dbID($seq_id);
 	$seq->adaptor($self);
 	
   	return $seq_id;

}

=head2 remove

  Arg [1]    : Bio::Cogemir::Seq
               the Seq  to be removed from this database
  Example    : $seq_adaptor->remove($seq);
 Description : Delete  a seq in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub remove {
    
  my ($self, $seq) = @_;
  if( ! defined $seq->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  
  my $attribute = $self->db->get_AttributeAdaptor->fetch_by_seq_id($seq->dbID);
  $self->db->get_AttributeAdaptor->_remove($attribute) if $attribute;
  
  my $micro_rna = $self->db->get_MicroRNAAdaptor->fetch_by_mature_seq_id($seq->dbID);
  if ($micro_rna){
    $micro_rna->mature_seq->dbID(0);
    $self->db->get_MicroRNAAdaptor->update($micro_rna);
  }
  my $sth= $self->prepare( "delete from seq where seq_id = ? " );
  $sth->execute($seq->dbID());
  return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Seq
               the Seq  to be removed from this database
  Example    : $seq_adaptor->remove($seq);
 Description : Delete  a seq in the database
  Returntype : 1
  Exceptions :
  Caller     : general

=cut
 
sub _remove {
    
  my ($self, $seq) = @_;
  return unless $seq;
  #print $self." _remove\n";
  if( ! defined $seq->dbID() ) {
    $self->throw("A dbID is not defined\n");
  }
  
  my $sth= $self->prepare( "delete from seq where seq_id = ? " );
  $sth->execute($seq->dbID());
  return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Seq
               the Seq  to be updated in this database
  Example    : $seq_adaptor->update($seq);
 Description : Stores an Seq in the database
  Returntype : Bio::Cogemir::Seq
  Exceptions :
  Caller     : general

=cut

sub update {
    my ( $self, $seq ) = @_;
    if( ! $seq->isa('Bio::Cogemir::Seq') ) {
	$self->throw("$seq is not a Bio::Cogemir::Seq object - not updating!");
    }
    my $logic_name_id = $seq->logic_name->dbID if defined $seq->logic_name;
    my $sql = q { UPDATE seq SET name = ?, sequence =? ,  logic_name_id = ? WHERE seq_id = ?};
    #printf "UPDATE seq SET name = %s, sequence =%s ,  logic_name_id = %d WHERE seq_id = %d\n",$seq->name, $seq->sequence, $logic_name_id, $seq->dbID;
    my $sth = $self->prepare($sql);
    $sth->execute($seq->name, $seq->sequence, $logic_name_id, $seq->dbID);
    
    return $self->fetch_by_dbID($seq->dbID);
}
1;
