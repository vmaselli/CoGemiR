#
# Module for Bio::Cogemir::DBSQL::MicroRNAAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

Bio::Cogemir::DBSQL::MicroRNAAdaptor

=head1 SYNOPSIS

    $micro_rna_adaptor = $db->get_MicroRNAAdaptor();

    $micro_rna =  $micro_rna_adaptor->fetch_by_dbID();


=head1 DESCRIPTION

    This adaptor work with the micro_rna table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::WEB::DBSQL::MicroRNAAdaptor;
use vars qw(@ISA);
use strict;
use Bio::Cogemir::MicroRNA;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);




=head2 fetch_by_group_status

  Arg [1]    : gene_name of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_name_like('hsa-mir-302');
  Description: Retrieves an micro_rna from the database via its gene_name
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_group_status{
	my ($self, $value,$status) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m, attribute a
	             WHERE mr.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND m.gene_name rlike ?
	             AND a.status = ?
	             };
# printf "SELECT mr.micro_rna_id 
#   	             FROM micro_rna mr, attribute m
#   	             WHERE mr.attribute_id = m.attribute_id
#   	             AND m.gene_name rlike \"%s\"",".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute(".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)",$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print "$dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}


sub fetch_by_group_organism_status{
	my ($self, $value,$organism,$status) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m, attribute a, genome_db
	             WHERE mr.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND m.gene_name rlike ?
	             AND g.organism = ?
	             AND a.status = ?
	             };
# printf "SELECT mr.micro_rna_id 
#   	             FROM micro_rna mr, attribute m
#   	             WHERE mr.attribute_id = m.attribute_id
#   	             AND m.gene_name rlike \"%s\"",".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute(".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)",$organism,$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print "$dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

sub fetch_by_group_taxa_status{
	my ($self, $value,$organism,$status) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m, attribute a, genome_db
	             WHERE mr.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND m.gene_name rlike ?
	             AND g.taxa = ?
	             AND a.status = ?
	             };
# printf "SELECT mr.micro_rna_id 
#   	             FROM micro_rna mr, attribute m
#   	             WHERE mr.attribute_id = m.attribute_id
#   	             AND m.gene_name rlike \"%s\"",".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute(".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)",$organism,$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print "$dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

sub fetch_by_family_status{
	my ($self, $value,$status) = @_;
	#print ref $self," line 85 <br>\n";
	$self->throw("I need a gene_name") unless $value;
	
	my $obj;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($value);
    my $family_name = $first_sth->fetchrow;
    #print ref $self," line 92 $value $family_name<br>\n";
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr,  attribute a, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND mn.family_name = ?
	             AND a.status = ?
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($family_name,$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print ref $self," line 98 $dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}


sub fetch_by_family_organism_status{
	my ($self, $value,$status) = @_;
	#print ref $self," line 85 <br>\n";
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($value);
    my $family_name = $first_sth->fetchrow;
    #print ref $self," line 92 $value $family_name<br>\n";
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr,  attribute a, mirna_name mn, genome_db g 
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mn.family_name = ?
	             AND g.organism = ?
	             AND a.status = ?
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($family_name,$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print ref $self," line 98 $dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}


sub fetch_by_family_taxa_status{
	my ($self, $value,$taxa,$status) = @_;
	#print ref $self," line 85 <br>\n";
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($value);
    my $family_name = $first_sth->fetchrow;
    #print ref $self," line 92 $value $family_name<br>\n";
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr,  attribute a, mirna_name mn, genome_db g 
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mn.family_name = ?
	             AND g.taxa = ?
	             AND a.status = ?
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($family_name,$taxa,$status);
	while (my $dbID = $sth->fetchrow_array){
	  #print ref $self," line 98 $dbID <br>\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

=head2 fetch_by_gene_id

  Arg [1]    : host or target gene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene or targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     :  general

=cut

sub fetch_by_gene_id{
	my ($self, $value) = @_;
	#print "FETCH BY GENE ID\n";
	$self->throw("I need a gene") unless $value;
	my @objs;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE hostgene_id = ? or targetgene_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}




=head2 fetch_by_hoststable_id

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hoststable_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hoststable_id{
	my ($self, $value) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, gene g, attribute m
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND m.stable_id = ?
	             };
# 	printf "SELECT mr.micro_rna_id 
# 	             FROM micro_rna mr, gene g, attribute m
# 	             WHERE mr.hostgene_id = g.gene_id
# 	             AND g.attribute_id = m.attribute_id
# 	             AND m.stable_id = %s<br>",$value;
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



=head2 fetch_by_hostgene_organism

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hoststable_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene_organism{
	my ($self, $value,$organism) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, gene g, attribute m, genome_db gdb, attribute a
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = gdb.genome_db_id
	             AND (m.stable_id = ? or m.external_name like ?)
	             AND gdb.organism = ?
	             };
  
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$organism);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_hostgene_status

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hostgene_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene_status{
	my ($self, $value,$status) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, gene g, attribute m
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND (m.stable_id = ? or m.external_name like ?)
	             AND mr.attribute_id = a.attribute_id
	             AND a.status = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$status);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_hostgene_status_organism

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hostgene_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene_status_organism{
	my ($self, $value,$status,$organism) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, gene g, attribute m, genome_db gdb
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = gdb.genome_db_id
	             AND (m.stable_id = ? or m.external_name like ?)
	             AND a.status = ?
	             AND gdb.organism = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$status,$organism);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_hostgene_status_taxa{
	my ($self, $value,$status,$taxa) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, gene g, attribute m, genome_db gdb
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = gdb.genome_db_id
	             AND (m.stable_id = ? or m.external_name like ?)
	             AND a.status = ?
	             AND gdb.taxa = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$status,$taxa);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}




=head2 fetch_by_organism_mirna_name

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_organism_mirna_name_id(1);
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_organism_mirna_name{
	my ($self, $organism,$mirna_name) = @_;
	#print "MR FETCH by_organism mirna_name_id\n";
	$self->throw("I need a organism") unless $organism;
	$self->throw("I need a mirna name") unless $mirna_name;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, genome_db gn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = gn.genome_db_id
	             AND a.mirna_name_id = ?
	             AND gn.organism = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($mirna_name,$organism);
	my ($dbID) = $sth->fetchrow;
		
	$obj = $self->fetch_by_dbID($dbID) if defined  $dbID;
	
	return $obj;
}

sub fetch_by_taxa_mirna_name{
	my ($self, $organism,$mirna_name) = @_;
	#print "MR FETCH by_organism mirna_name_id\n";
	$self->throw("I need a organism") unless $organism;
	$self->throw("I need a mirna name") unless $mirna_name;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, genome_db gn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = gn.genome_db_id
	             AND a.mirna_name_id = ?
	             AND gn.taxa = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($mirna_name,$organism);
	my ($dbID) = $sth->fetchrow;
		
	$obj = $self->fetch_by_dbID($dbID) if defined  $dbID;
	
	return $obj;
}



=head2 fetch_by_all_label

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label{
	my ($self, $value) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $sql = qq{SELECT distinct(mr.micro_rna_id) 
	             FROM micro_rna mr, localization l
	             WHERE mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?)
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%");
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


=head2 fetch_by_all_label_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_name{
	my ($self, $value,$name) = @_;
	#print "MR FETCH BY label $name\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $sql = qq{SELECT distinct(mr.micro_rna_id) 
	             FROM micro_rna mr, localization l, attribute m
	             WHERE mr.micro_rna_id = l.micro_rna_id
	             AND mr.attribute_id = m.attribute_id
	             AND (l.label = ? or l.label like ?)
	             AND m.gene_name rlike ?
	             };
	
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$string);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result $string\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_family{
	my ($self, $value,$name) = @_;
	#print "MR FETCH BY label $name\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $sql = qq{SELECT distinct(mr.micro_rna_id) 
	             FROM micro_rna mr, localization l, attribute m, mirna_name mn
	             WHERE mr.micro_rna_id = l.micro_rna_id
	             AND mr.attribute_id = m.attribute_id
	             AND m.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?)
	             AND mn.family_name = ?
	             };
	
	my $sth = $self->prepare($sql);
	my $string = $name;
	$sth->execute($value,"%$value%",$string);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result $string\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_status{
	my ($self, $value,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $sql = qq{SELECT distinct(mr.micro_rna_id) 
	             FROM micro_rna mr, localization l, attribute a
	             WHERE mr.micro_rna_id = l.micro_rna_id
	             AND mr.attribute_id = a.attribute_id
	             AND a.status = ?
	             AND (l.label = ? or l.label like ? )
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($status,$value,"%$value%");
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_by_status{
	my ($self, $status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a status") unless $status;
	my @objs;
	my $sql = qq{SELECT distinct(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.status = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($status);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_label_by_organism

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_label_by_organism{
	my ($self, $value,$species) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $sql = qq{SELECT count(distinct(mr.micro_rna_id)) 
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species);
	my $count = $sth->fetchrow;
	return $count;
}

=head2 fetch_by_all_label_organism

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism{
	my ($self, $value,$species) = @_;
		#print ref $self, " line 1152 fetch_by_all_label_organism $value $species<br>\n";

	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND g.organism = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		my $microrna = $self->fetch_by_dbID($dbID) if $dbID;
		push (@objs, $microrna) if $microrna;
	}
	return \@objs;
}

sub fetch_by_all_label_taxa{
	my ($self, $value,$species) = @_;
	#print ref $self, " line 1199 fetch_by_all_label_taxa $value $species<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND g.taxa = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		my $microrna = $self->fetch_by_dbID($dbID) if $dbID;
		push (@objs, $microrna) if $microrna;
	}
	return \@objs;
}
=head2 fetch_by_all_label_organism_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_status{
	my ($self, $value,$species,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND g.organism = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		# print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_organism_status_name{
	my ($self, $value,$species,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND g.organism = ?
	             AND a.status = ?
	             AND a.gene_name rlike = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$species,$status,$name);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		# print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}
sub fetch_by_all_label_taxa_status{
	my ($self, $value,$taxa,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND g.taxa = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$taxa,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		# print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_status_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_status_name{
	my ($self, $value,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a status") unless $status;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, attribute m
	             WHERE mr.attribute_id = a.attribute_id
	             AND mr.attribute_id = m.attribute_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	
	$sth->execute($value,"%$value%",$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_status_family{
	my ($self, $value,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a status") unless $status;
	$self->throw("I need a name") unless $name;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string =$family_name;
	
	$sth->execute($value,"%$value%",$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_direction_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_direction_status{
	my ($self, $value,$species,$direction,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species,$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_direction_status{
	my ($self, $value,$species,$direction,$status) = @_;
	#print ref $self, " line 1368 $value,$species,$direction,$status<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$species,$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}
=head2 fetch_all_label_direction_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_label_direction_status{
	my ($self, $value,$direction,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ? )
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_direction

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_direction{
	my ($self, $value,$species,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?)
	             AND g.organism = ?
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);
	# printf "SELECT distinct(mr.micro_rna_id)
# 	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d
# 	             WHERE mr.attribute_id = a.attribute_id 
# 	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
# 	             AND a.genome_db_id = g.genome_db_id
# 	             AND mr.micro_rna_id = l.micro_rna_id
# 	             AND (l.label = %s or l.label like %s)
# 	             AND g.organism = %s
# 	             AND d.direction = %s",$value,"%$value%",$species,$direction;
	$sth->execute($value,"%$value%",$species,$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


sub fetch_by_all_label_taxa_direction{
	my ($self, $value,$species,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?)
	             AND g.taxa = ?
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);

	$sth->execute($value,"%$value%",$species,$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}
=head2 fetch_all_label_direction

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_direction{
	my ($self, $value,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l, direction d
	             WHERE (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_all_label_direction_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_direction_name{
	my ($self, $value,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l, direction d, attribute m
	             WHERE (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



sub fetch_by_all_label_direction_family{
	my ($self, $value,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l, direction d, attribute m, mirna_name mn
	             WHERE (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	             AND m.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($value,"%$value%",$direction,$family_name);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_direction_family{
	my ($self, $value,$species,$direction,$name) = @_;
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id), g.taxa, d.direction, mn.family_name, a.gene_name
	             FROM micro_rna mr, localization l,attribute a, genome_db g, 
	             direction d,  mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.attribute_id = mr.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND mn.family_name = ?
	             };
	             
	#print ref $self, " $value,$species,$direction,$name line 1055<br>\n";

	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($value,"%$value%",$species,$direction,$string);
	while (my ($dbID, $taxa, $direction, $family_name, $gene_name) = $sth->fetchrow_array){
		#print "$dbID, $taxa, $direction, $family_name, $gene_name<br>";
		$count ++;
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_family{
	my ($self, $value,$species,$name) = @_;
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g,  mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?)
	             AND g.taxa = ?
	             AND mn.family_name = ?
	             };
	print ref $self, "line 1055<br>\n";
	
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($value,"%$value%",$species,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_status_family{
	my ($self, $value,$species,$stauts,$name) = @_;
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g,  mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?)
	             AND g.taxa = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	#print ref $self, "line 1237<br>\n";
	
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($value,"%$value%",$species,$stauts,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



sub fetch_by_all_label_taxa_status_name{
	my ($self, $value,$species,$stauts,$name) = @_;
	$self->throw("I need a label") unless $value;
	my @objs;
	
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g,  mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?)
	             AND g.taxa = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	print ref $self, "line 1055<br>\n";
	
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$species,$stauts,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_direction_name{
	my ($self, $value,$species,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, 
	             direction d, gene h,  genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND a.status = ?
	             AND mn.family_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$species,$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


=head2 fetch_all_label_status_direction_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_status_direction_name{
	my ($self, $value,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a direction") unless $direction;
	$self->throw("I need a status") unless $status;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND mr.attribute_id = m.attribute_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($value,"%$value%",$direction,$status,$string);
	#print ref $self," line 1456 $value,\%$value\%,$direction,$status,$string";
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_status_direction_family{
	my ($self, $value,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a direction") unless $direction;
	$self->throw("I need a status") unless $status;
	$self->throw("I need a name") unless $name;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($value,"%$value%",$direction,$status,$string);
	#print ref $self," line 1456 $value,\%$value\%,$direction,$status,$string";
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


=head2 fetch_all_label_direction_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_direction_status{
	my ($self, $value,$direction,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%",$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_direction_status_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_direction_status_name{
	my ($self, $value,$species,$biotype,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
		my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction_status_name{
	my ($self, $value,$species,$biotype,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
		my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_organism_biotype_direction_status_family{
	my ($self, $value,$species,$biotype,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, 
	             direction d, gene h,  genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
		my $string = $name;

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction_status_family{
	my ($self, $value,$species,$biotype,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, 
	             direction d, gene h,  genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
		my $string = $family_name;

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction_family{
	my ($self, $value,$species,$biotype,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, 
	             direction d, gene h,  genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND a.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
		my $string = $family_name;

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}




=head2 fetch_by_all_label_organism_biotype_direction_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_direction_status{
	my ($self, $value,$species,$biotype,$direction,$status) = @_;
	#print ref $self,"MR FETCH BY $biotype line 1673\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a species") unless $species;
	$self->throw("I need a biotype") unless $biotype;
	$self->throw("I need a direction") unless $direction;
	$self->throw("I need a status") unless $status;

	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		#$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction_status{
	my ($self, $value,$species,$biotype,$direction,$status) = @_;
	#print ref $self,"MR FETCH BY $biotype line 1480\n";
	$self->throw("I need a label") unless $value;
	$self->throw("I need a species") unless $species;
	$self->throw("I need a biotype") unless $biotype;
	$self->throw("I need a direction") unless $direction;
	$self->throw("I need a status") unless $status;

	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);

	$sth->execute($biotype,$value,"%$value%",$species,$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		#$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_status_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_status_name{
	my ($self, $value,$species,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.organism = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
  my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_status_name{
	my ($self, $value,$species,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.taxa = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
  my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_organism_biotype_status_family{
	my ($self, $value,$species,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
							FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, 
									 attribute m, genome_db gh, attribute ah, mirna_name mn
							WHERE mr.attribute_id = a.attribute_id 
							AND mr.hostgene_id = h.gene_id
							AND a.genome_db_id = g.genome_db_id
							AND mr.micro_rna_id = l.micro_rna_id
							AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
							AND gh.db_type = ?
							AND (l.label = ? or  l.label like ?)
							AND g.organism = ?
							AND a.status = ?
							AND mn.family_name = ?
							};
	my $sth = $self->prepare($sql);
  my $string = $family_name;
  
	$sth->execute($biotype,$value,"%$value%",$species,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_status_family{
	my ($self, $value,$species,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
							FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, 
									 attribute m, genome_db gh, attribute ah, mirna_name mn
							WHERE mr.attribute_id = a.attribute_id 
							AND mr.hostgene_id = h.gene_id
							AND a.genome_db_id = g.genome_db_id
							AND mr.micro_rna_id = l.micro_rna_id
							AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
							AND gh.db_type = ?
							AND (l.label = ? or  l.label like ?)
							AND g.taxa = ?
							AND a.status = ?
							AND mn.family_name = ?
							};
	my $sth = $self->prepare($sql);
  my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$species,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}
=head2 fetch_by_all_label_organism_biotype_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_name{
	my ($self, $value,$species,$biotype,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.organism = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
  my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_name{
	my ($self, $value,$species,$biotype,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.taxa = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
  my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_organism_biotype_family{
	my ($self, $value,$species,$biotype,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.organism = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
  my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$species,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}



sub fetch_by_all_label_taxa_biotype_family{
	my ($self, $value,$species,$biotype,$name) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, attribute m, genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND m.attribute_id = mr.attribute_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	            AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.taxa = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
  my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$species,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_status{
	my ($self, $value,$species,$biotype,$status) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.organism = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$species,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_status{
	my ($self, $value,$species,$biotype,$status) = @_;
	#print ref $self, "MR FETCH BY label line 1284<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	            AND ah.genome_db_id = gh.genome_db_id
	            AND h.attribute_id = ah.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.taxa = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$species,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_biotype_status_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_status_name{
	my ($self, $value,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line <br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  gene h, genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_biotype_status_family{
	my ($self, $value,$biotype,$status,$name) = @_;
	#print ref $self, "MR FETCH BY label line <br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  gene h, genome_db gh, attribute ah, attribute m, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_biotype_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_name{
	my ($self, $value,$biotype,$name) = @_;
	#print ref $self, "MR FETCH BY label line <br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  gene h, genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_biotype_family{
	my ($self, $value,$biotype,$name) = @_;
	print ref $self, "$value,$biotype,$name line 1856<br>\n";
	$self->throw("I need a label") unless $value;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,gene h, genome_db gh, attribute ah, attribute m, mirna_name mn
	             WHERE mr.attribute_id = m.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND m.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_status{
	my ($self, $value,$biotype,$status) = @_;
	#print ref $self, "MR FETCH BY label line 1323<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype{
	my ($self, $value,$biotype) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l, gene h, genome_db gh, attribute ah
	             WHERE mr.hostgene_id = h.gene_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%");
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype{
	my ($self, $value,$species,$biotype) = @_;
	#print $self,"MR FETCH BY label $value,$species,$biotype line 1397<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id 
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.organism = ?
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($biotype,$value,"%$value%",$species);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result<br>";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype{
	my ($self, $value,$species,$biotype) = @_;
	#print $self,"MR FETCH BY label $value,$species,$biotype line 1397<br>\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id 
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND gh.db_type = ?
	             AND (l.label = ? or  l.label like ?)
	             AND g.taxa = ?
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($biotype,$value,"%$value%",$species);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result<br>";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	
	return \@objs;
}

=head2 fetch_by_all_label_biotype_direction_status

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_direction_status{
	my ($self, $value,$biotype,$direction,$status) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d, gene h , genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$direction,$status);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_biotype_direction_status_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_direction_status_name{
	my ($self, $value,$biotype,$direction,$status,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d, gene h , genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_biotype_direction_status_family{
	my ($self, $value,$biotype,$direction,$status,$name) = @_;
	#print ref $self, " line 2162 $value,$biotype,$direction,$status,$name\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a,  direction d, gene h , genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND a.attribute_id = mr.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND a.status = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$direction,$status,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


=head2 fetch_by_all_label_organism_biotype_direction

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_direction{
	my ($self, $value,$species,$biotype,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$species,$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction{
	my ($self, $value,$species,$biotype,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$species,$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_organism_biotype_direction_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_organism_biotype_direction_name{
	my ($self, $value,$species,$biotype,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND m.attribute_id = mr.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_organism_biotype_direction_family{
	my ($self, $value,$species,$biotype,$direction,$name) = @_;
	print ref $self, " line 2315 $value,$species,$biotype,$direction,$name<br>";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, 
	             genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND a.attribute_id = mr.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.organism = ?
	             AND d.direction = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$species,$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_taxa_biotype_direction_name{
	my ($self, $value,$species,$biotype,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND m.attribute_id = mr.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND g.taxa = ?
	             AND d.direction = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$species,$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

# sub fetch_by_all_label_taxa_biotype_direction_family{
# 	my ($self, $value,$species,$biotype,$direction,$name) = @_;
# 	print ref $self, "line 2387 $value,$species,$biotype,$direction,$name<br>\n";
# 	$self->throw("I need a label") unless $value;
# 	my @objs;
# 	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
#     my $first_sth = $self->prepare($first_sql);
#     $first_sth->execute($name);
#     my $family_name = $first_sth->fetchrow;
# 	my $count = 0;
# 	my $sql = qq{SELECT distinct(mr.micro_rna_id)
# 	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, 
# 	             genome_db gh, attribute ah, mirna_name mn
# 	             WHERE mr.attribute_id = a.attribute_id 
# 	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
# 	             AND mr.hostgene_id = h.gene_id
# 	             AND a.genome_db_id = g.genome_db_id
# 	             AND mr.micro_rna_id = l.micro_rna_id
# 	             AND h.attribute_id = ah.attribute_id
# 	             AND a.attribute_id = mr.attribute_id
# 	             AND ah.genome_db_id = gh.genome_db_id
# 	             AND a.mirna_name_id = mn.mirna_name_id
# 	             AND gh.db_type = ?
# 	             AND (l.label = ? or l.label like ?) 
# 	             AND g.taxa = ?
# 	             AND d.direction = ?
# 	             AND mn.family_name = ?
# 	             };
# 	my $sth = $self->prepare($sql);
# 	my $string = $family_name;
# 	$sth->execute($biotype,$value,"%$value%",$species,$direction,$string);
# 	while (my $dbID = $sth->fetchrow_array){
# 		$count ++;
# 		#print "$count result\n";
# 		push (@objs, $self->fetch_by_dbID($dbID));
# 	}
# 	return \@objs;
# }


=head2 fetch_by_all_label_biotype_direction_name

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_direction_name{
	my ($self, $value,$biotype,$direction,$name) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, gene h, genome_db gh, attribute ah, attribute m
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND m.attribute_id = mr.attribute_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND m.gene_name rlike ?
	             };
	my $sth = $self->prepare($sql);
	my $string = ".".$name."(\$|-.\$|[a-z]|[a-z]-.\$)";
	$sth->execute($biotype,$value,"%$value%",$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_label_biotype_direction_family{
	my ($self, $value,$biotype,$direction,$name) = @_;
	#print "$value,$biotype,$direction,$name<br>";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $first_sql = qq{SELECT family_name from mirna_name where name = ?};
    my $first_sth = $self->prepare($first_sql);
    $first_sth->execute($name);
    my $family_name = $first_sth->fetchrow;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l,attribute a, genome_db g, direction d, 
	             gene h, genome_db gh, attribute ah, mirna_name mn
	             WHERE mr.attribute_id = a.attribute_id 
	             AND (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND a.attribute_id = mr.attribute_id
	             AND a.mirna_name_id = mn.mirna_name_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             AND mn.family_name = ?
	             };
	my $sth = $self->prepare($sql);
	my $string = $family_name;
	$sth->execute($biotype,$value,"%$value%",$direction,$string);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_all_label_biotype_direction

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_label_biotype_direction{
	my ($self, $value,$biotype,$direction) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $count = 0;
	my $sql = qq{SELECT distinct(mr.micro_rna_id)
	             FROM micro_rna mr, localization l, direction d, gene h, genome_db gh, attribute ah
	             WHERE (mr.hostgene_id = d.gene_id and mr.micro_rna_id = d.micro_rna_id)
	             AND mr.hostgene_id = h.gene_id
	             AND mr.micro_rna_id = l.micro_rna_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND gh.db_type = ?
	             AND (l.label = ? or l.label like ?) 
	             AND d.direction = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($biotype,$value,"%$value%",$direction);
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_organism{
	my ($self, $value) = @_;
	#print "MR FETCH BY oganism\n";
	$self->throw("I need a organism") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND g.organism = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		my $micro_rna = $self->fetch_by_dbID($dbID);
		push (@objs, $micro_rna) if $micro_rna;
	}
	return \@objs;
}


=head2 fetch_by_all_organism_status

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_all_organism_status{
	my ($self, $value,$status) = @_;
	#print "MR FETCH BY oganism\n";
	$self->throw("I need a organism") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND g.organism = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$status);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_all_taxa_status{
	my ($self, $value,$status) = @_;
	#print "MR FETCH BY oganism\n";
	$self->throw("I need a organism") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND g.taxa = ?
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$status);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}
=head2 fetch_all_by_organism_status

  Arg [1]    : organism and status of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism_status("HOMO SAPIENS","ANNOTATED");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_by_organism_status{
	my ($self, $value,$status) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND a.status = ?
	             AND g.organism = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($status,$value);
  return  $sth->fetchrow;
}
sub fetch_all_by_taxa_status{
	my ($self, $value,$status) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND a.status = ?
	             AND g.taxa = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($status,$value);
  return  $sth->fetchrow;
}


=head2 fetch_all_intragenic_by__organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_intragenic_by_organism{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id 
	             AND g.organism = ?
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_intragenic_by_taxa{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id 
	             AND g.taxa = ?
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

=head2 fetch_all_intraknown_by_organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_intraknown_by_organism{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, attribute ah, genome_db gh
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.hostgene_id = h.gene_id 
	             AND g.organism = ?
	             AND (gh.db_type = 'core' or gh.db_type = 'vega') 
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_intraknown_by_taxa{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, attribute ah, genome_db gh
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.hostgene_id = h.gene_id 
	             AND g.taxa = ?
	             AND (gh.db_type = 'core' or gh.db_type = 'vega') 
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

=head2 fetch_all_intraest_by_organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_intraest_by_organism{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, attribute ah, genome_db gh
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.hostgene_id = h.gene_id 
	             AND g.organism = ?
	             AND gh.db_type = 'otherfeatures'
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_intraest_by_taxa{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, attribute ah, genome_db gh
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND h.attribute_id = ah.attribute_id
	             AND ah.genome_db_id = gh.genome_db_id
	             AND mr.hostgene_id = h.gene_id 
	             AND g.taxa = ?
	             AND gh.db_type = 'otherfeatures'
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}
=head2 fetch_all_oversense_by_organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_oversense_by_organism{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
		     AND h.attribute_id = ah.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.location_id = mrl.location_id
	             AND ah.location_id = lh.location_id
	             AND g.organism = ?
	             AND lh.strand = mrl.strand
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_oversense_by_taxa{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
		     AND h.attribute_id = ah.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.location_id = mrl.location_id
	             AND ah.location_id = lh.location_id
	             AND g.taxa = ?
	             AND lh.strand = mrl.strand
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

=head2 fetch_all_overantisense_by_organism

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_overantisense_by_organism{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND h.attribute_id = ah.attribute_id
		     AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.location_id = mrl.location_id
	             AND ah.location_id = lh.location_id
	             AND g.organism = ?
	             AND lh.strand != mrl.strand
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_overantisense_by_taxa{
	my ($self, $value) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND mr.location_id = mrl.location_id
	             AND h.location_id = lh.location_id
	             AND g.taxa = ?
	             AND lh.strand != mrl.strand
	             AND a.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  return  $sth->fetchrow;
}

sub fetch_all_oversense_by_organism_type{
	my ($self, $value,$type) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl, attribute ah
	             WHERE mr.attribute_id = a.attribute_id 
	             AND h.attribute_id = ah.attribute_id
		     AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.location_id = mrl.location_id
	             AND ah.location_id = lh.location_id
	             AND g.organism = ?
	             AND lh.strand = mrl.strand
	             AND a.status != 'LC PREDICTION'
	             AND g.db_type = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$type);
  return  $sth->fetchrow;
}

sub fetch_all_oversense_by_taxa_type{
	my ($self, $value,$type) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND mr.location_id = mrl.location_id
	             AND h.location_id = lh.location_id
	             AND g.taxa = ?
	             AND lh.strand = mrl.strand
	             AND a.status != 'LC PREDICTION'
	             AND g.db_type = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$type);
  return  $sth->fetchrow;
}


=head2 fetch_all_overantisense_by_organism_type

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_overantisense_by_organism_type{
	my ($self, $value,$type) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g, gene h, location lh, location mrl, attribute ah
	             WHERE mr.attribute_id = a.attribute_id
		     AND h.attribute_id = ah.attribute_id
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id = h.gene_id
	             AND a.location_id = mrl.location_id
	             AND ah.location_id = lh.location_id
	             AND g.organism = ?
	             AND lh.strand != mrl.strand
	             AND a.status != 'LC PREDICTION'
	             AND g.db_type = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value, $type);
  return  $sth->fetchrow;
}



=head2 fetch_all_intragenic_annotated_by_organism_status

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_oganism("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_intragenic_by_organism_status{
	my ($self, $value,$status) = @_;
	
	$self->throw("I need a organism") unless $value;

	my $sql = qq{SELECT count(mr.micro_rna_id) 
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND a.status = 'ANNOTATED'?
	             AND mr.hostgene_id 
	             AND g.organism = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($status,$value);
  return  $sth->fetchrow;
}



sub fetch_by_micro_rna_tissue{
  my ($self,$value,$dbID) = @_;
  my @ref;
  my $sql = qq{select probset, expression_level 
              from micro_rna_tissue 
              where tissue_name = ?
              and micro_rna_id = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($value,$dbID);
  push(@ref,$sth->fetchrow_hashref);
  return \@ref
}



sub get_all_tissue_expression_by_probe{
  my ($self, $dbID) = @_;
  my $res;
  my $sql = qq{select tissue_name, probset, expression_level
               from micro_rna_tissue
               where micro_rna_id = ?};
  #print ref $self," line 2534<br>\n";
  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  while (my $ref = $sth->fetchrow_hashref){
    push (@{$res},$ref);
  }
  return $res;
}



sub get_all_intragenic_by_taxa{
  my ($self,$species) = @_;
   my $obj;
  my $sql = qq{SELECT mr.micro_rna_id
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id 
	             AND g.taxa = ?};
	my $sth = $self->prepare($sql);
	$sth->execute($species);
	while(my $dbID = $sth->fetchrow_array){
	    push (@{$obj},$self->fetch_by_dbID($dbID));
	}
	return $obj;
	             
	        
}





sub fetch_by_tissue_organism{
	my ($self,$value,$species) = @_;
  my $ret;
  my $sql = qq{select distinct(a.gene_name), mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and mt.tissue_name = ?
              and g.organism = ?
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species);
  while (my ($name,$dbID) = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_direction{
	my ($self,$value,$species,$direction) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, direction d
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and d.micro_rna_id = mr.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              and d.direction = ?
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$direction);
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_status{
	my ($self,$value,$species,$status) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and mt.tissue_name = ?
              and g.organism = ?
              and a.status = ?
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$status);
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_localization{
	my ($self,$value,$species,$localization) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, localization l
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and mr.micro_rna_id = l.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              AND (l.label = ? or l.label like ?) 
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$localization,"%$localization%");
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_localization_status{
	my ($self,$value,$species,$localization,$status) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, localization l
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and mr.micro_rna_id = l.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              and a.status = ?
              AND (l.label = ? or l.label like ?) 
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$status,$localization,"%$localization%");
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_status_direction{
	my ($self,$value,$species,$status,$direction) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, direction d
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and d.micro_rna_id = mr.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              and d.direction = ?
              and a.status = ?
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$direction,$status);
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}
sub fetch_by_tissue_organism_localization_direction{
	my ($self,$value,$species,$localization,$direction) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, direction d, localization l
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and d.micro_rna_id = mr.micro_rna_id
               and mr.micro_rna_id = l.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              and d.direction = ?
              AND (l.label = ? or l.label like ?) 
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$direction,$localization,"%$localization%");
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

sub fetch_by_tissue_organism_localization_status_direction{
	my ($self,$value,$species,$localization,$status,$direction) = @_;
  my $ret;
  my $sql = qq{select mt.micro_rna_id 
              from micro_rna_tissue mt, micro_rna mr, attribute a, genome_db g, direction d, localization l
              where mt.micro_rna_id = mr.micro_rna_id
              and a.attribute_id = mr.attribute_id
              and a.genome_db_id = g.genome_db_id
              and d.micro_rna_id = mr.micro_rna_id
               and mr.micro_rna_id = l.micro_rna_id
              and mt.tissue_name = ?
              and g.organism = ?
              and d.direction = ?
              AND (l.label = ? or l.label like ?) 
              and a.status = ?
              };
  my $sth = $self->prepare($sql);
  $sth->execute($value,$species,$direction,$localization,"%$localization%",$status);
  while (my $dbID = $sth->fetchrow_array){
  	push (@$ret, $self->fetch_by_dbID($dbID))
  }
  return $ret;
}

1;
