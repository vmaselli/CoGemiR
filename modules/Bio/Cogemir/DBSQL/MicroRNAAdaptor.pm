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


package Bio::Cogemir::DBSQL::MicroRNAAdaptor;
use vars qw(@ISA);
use strict;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";
use Bio::Cogemir::MicroRNA;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;
use Bio::Cogemir::WEB::DBSQL::MicroRNAAdaptor;

use Data::Dumper;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor Bio::Cogemir::WEB::DBSQL::MicroRNAAdaptor);


=head2 fetch_by_dbID

  Arg [1]    : internal id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_dbID($dbID);
  Description: Retrieves an micro_rna from the database via its internal id
  Returntype : Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_dbID {
  my ($self, $dbID) = @_;
  $self->throw("I need a micro_rna id") unless $dbID;

  my $query = qq {
  SELECT   attribute_id, specific, seed, cluster_id, hostgene_id,   share
    FROM micro_rna 
    WHERE  micro_rna_id = $dbID  
};

  my $sth = $self->prepare($query);
  $sth->execute();
  my ( $attribute_id, $specific, $seed, $cluster_id, $hostgene_id,   $share) = $sth->fetchrow_array();
  unless (defined $attribute_id){
    #self->warn("no micro_rna for $dbID in MicroRNAAdaptor line 72");
    return undef;
  }
  
  my $hostgene;
	my $attribute_obj = $self->db->get_AttributeAdaptor->fetch_by_dbID($attribute_id) if $attribute_id ;
	$hostgene = $self->db->get_GeneAdaptor->fetch_by_dbID($hostgene_id) if  $hostgene_id;
	#print "HOST ".$hostgene->gene_name," ",ref $self," line 78 <br>\n" if defined $hostgene;
	my $cluster = $self->db->get_ClusterAdaptor->fetch_by_dbID($cluster_id) if  $cluster_id;
  my $micro_rna =  Bio::Cogemir::MicroRNA->new(   
                -DBID =>$dbID,
                -ADAPTOR => $self,
                -ATTRIBUTE => $attribute_obj,
                -SPECIFIC => $specific,
                -SHARE => $share,
                -SEED => $seed,
                -CLUSTER => $cluster,
                -HOSTGENE => $hostgene,
                
               );
  return $micro_rna;
}

=head2 fetch_by_attribute_id

  Arg [1]    : attribute_id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_attribute_id(34);
  Description: Retrieves an micro_rna from the database via its attribute_id
  Returntype : Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_attribute_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my $obj;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE attribute_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if defined $dbID;
	#print ref $self," attribute id = $dbID line 180<br>\n" if $dbID;
	return $obj;
}

=head2 fetch_by_specific

  Arg [1]    : specific of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_specific('ENSG0000001234');
  Description: Retrieves an micro_rna from the database via its specific term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_specific{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE specific = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_share

  Arg [1]    : share of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_share('ENSG0000001234');
  Description: Retrieves an micro_rna from the database via its share term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_share{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my @objs;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE share = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



=head2 fetch_by_mature_seq_id

  Arg [1]    : mature_seq_id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_mature_seq_id();
  Description: Retrieves an micro_rna from the database via its mature_seq_id term
  Returntype : Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_mature_seq_id{
	my ($self, $value) = @_;
	$self->throw("I need a mature_seq_id") unless $value;
	my $obj;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna_mature_sequence
	             WHERE mature_seq_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if defined $dbID;
	
	return $obj;
}

=head2 get_mature_seq

  Arg [1]    : micro_rna_id
  Example    : $micro_rna = $micro_rna_adaptor->fetch_mature_seq_id();
  Description: Retrieves an micro_rna from the database via its mature_seq_id term
  Returntype : listref of Bio::Cogemir::Seq
  Exceptions : none
  Caller     : general

=cut

sub get_mature_seq{
	my ($self, $value) = @_;
	$self->throw("I need a mature_seq_id") unless $value;
	my $obj;
	my $sql = qq{SELECT mature_seq_id 
	             FROM micro_rna_mature_sequence
	             WHERE micro_rna_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while(my $dbID = $sth->fetchrow_array){
		my $seq = $self->db->get_SeqAdaptor->fetch_by_dbID($dbID);
		push (@{$obj},$seq);
	}
	return $obj;
}


=head2 fetch_by_cluster_id

  Arg [1]    : cluster of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_conservation_score('ENSG0000001234');
  Description: Retrieves an micro_rna from the database via its cluster term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_cluster_id{
	my ($self, $value) = @_;
	$self->throw("I need a cluster") unless $value;
	my @objs;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE cluster_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_hostgene_id

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hostgene_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene_id{
	my ($self, $value) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE hostgene_id = ?
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_seed

  Arg [1]    : seed_id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label(12);
  Description: Retrieves an micro_rna from the database via its seed_id
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_seed{
	my ($self, $value) = @_;
	$self->throw("I need a seed") unless $value;
	my $obj;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE seed = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID);

	return $obj;
}

=head2 fetch_by_gene_name

  Arg [1]    : gene_name of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_name('mir-302');
  Description: Retrieves an micro_rna from the database via its gene_name
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_gene_name{
	my ($self, $value) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.gene_name rlike ?
	             AND m.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($value."(\$\|-%)");
	
  while(my ($dbID) = $sth->fetchrow_array){
    push (@{$obj},$self->fetch_by_dbID($dbID));
  }
	return $obj;
}

sub fetch_by_gene_name_taxa{
	my ($self, $value,$taxa) = @_;
	#print ref $self, " line 319<br>\n";
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m, genome_db g
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.genome_db_id = g.genome_db_id
	             AND g.db_type = 'core'
	             AND m.gene_name rlike ?
	             AND g.taxa = ?
	             AND m.status != 'LC PREDICTION'
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($value."(\$\|-%)",$taxa);
  while(my ($dbID) = $sth->fetchrow_array){
    push (@{$obj},$self->fetch_by_dbID($dbID));
  }
	return $obj;
}

=head2 fetch_by_specific_gene_name

  Arg [1]    : specific_gene_name of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_specific_gene_name('hsa-mir-302');
  Description: Retrieves an micro_rna from the database via its specific_gene_name
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : specific_general

=cut

sub fetch_by_specific_gene_name{
	my ($self, $value) = @_;
	$self->throw("I need a specific_gene_name") unless $value;
	my $obj;
	#print ref $self," line 355 $value<br>\n";
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.gene_name = ?
	             };
	my $sth = $self->prepare($sql);
	
	$sth->execute($value);
  my ($dbID) = $sth->fetchrow_array;
  $obj = $self->fetch_by_dbID($dbID) if $dbID;

	return $obj;
}


=head2 fetch_by_stable_id

  Arg [1]    : stable_id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_stable_id($stable_id);
  Description: Retrieves an micro_rna from the database via its stable_id
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_stable_id{
	my ($self, $value) = @_;
	$self->throw("I need a stable_id") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.stable_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
  while(my ($dbID) = $sth->fetchrow_array){
    push(@{$obj},$self->fetch_by_dbID($dbID));
	}
	return $obj;
}


=head2 fetch_by_gene_name_like

  Arg [1]    : gene_name of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_name_like('mir-302');
  Description: Retrieves an micro_rna from the database via its gene_name
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_gene_name_like{
	my ($self, $value) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.gene_name rlike ?
	             AND m.status != 'LC PREDICTION'
	             };
 # 	printf "%s line 420 SELECT mr.micro_rna_id 
# 	             FROM micro_rna mr, attribute m
# 	             WHERE mr.attribute_id = m.attribute_id
# 	             AND m.gene_name rlike \"%s\"\n<br>",ref $self,"(\^)".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute($value."(\$|-.\$)");
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

=head2 fetch_by_location_id

  Arg [1]    : location_id of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_location_id(12);
  Description: Retrieves an micro_rna from the database via its location_id
  Returntype : Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_location_id{
	my ($self, $value) = @_;
	$self->throw("I need a genome_bd_id") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a
	             WHERE mr.attribute_id = a.attribute_id and a.location_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $dbID = $sth->fetchrow_array;
	$obj = $self->fetch_by_dbID($dbID) if $dbID;
	
	return $obj;
}



=head2 fetch_by_targetgene_id

  Arg [1]    : target gene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene or targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     :  general

=cut

sub fetch_by_targetgene_id{
	my ($self, $value) = @_;
	#print "FETCH BY GENE ID\n";
	$self->throw("I need a gene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, micro_rna_target mt
	             WHERE mt.micro_rna_id = mr.micro_rna_id and mt.gene_id = ? 
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value,$value);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}



=head2 fetch_by_hostgene

  Arg [1]    : hostgene of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_hoststable_id(356);
  Description: Retrieves an micro_rna from the database via its hostgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_hostgene{
	my ($self, $value) = @_;
	$self->throw("I need a hostgene") unless $value;
	my @objs;
	#print ref $self, "line 504<br>\n";
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, gene g, attribute m
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND (m.stable_id = ? or m.external_name like ?)
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($value,"%$value%");
	while (my $dbID = $sth->fetchrow_array){
		#print ref $self, "line 515 DBID $dbID<br>";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_hostgene_taxa{
	my ($self, $value,$taxa) = @_;
	$self->throw("I need a hostgene") unless $value;
	#print ref $self, " line 524<br>\n";
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, gene g, attribute m , genome_db gb
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND m.genome_db_id = gb.genome_db_id
	             AND gb.taxa = ?
	             AND (m.stable_id = ? or m.external_name like ?)
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($taxa,$value,"%$value%");
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_hostgene_organism{
	my ($self, $value,$taxa) = @_;
	$self->throw("I need a hostgene") unless $value;
	#print ref $self, " line 524<br>\n";
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, gene g, attribute m , genome_db gb
	             WHERE mr.hostgene_id = g.gene_id
	             AND g.attribute_id = m.attribute_id
	             AND m.genome_db_id = gb.genome_db_id
	             AND gb.organism = ?
	             AND (m.stable_id = ? or m.external_name like ?)
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($taxa,$value,"%$value%");
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

sub fetch_by_taxa{
	my ($self, $taxa) = @_;
	$self->throw("I need a taxa") unless $taxa;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr,  attribute m , genome_db g
	             WHERE  mr.attribute_id = m.attribute_id
	             AND m.genome_db_id = g.genome_db_id
	             AND g.db_type = 'core'
	             AND g.taxa = ?
	             };

	my $sth = $self->prepare($sql);
	$sth->execute($taxa);
	while (my $dbID = $sth->fetchrow_array){
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}


=head2 fetch_by_status

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_status("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_status{
	my ($self, $value) = @_;
	#print "MR FETCH BY STATUS\n";
	$self->throw("I need a targetgene") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.status = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_mirna_name_id

  Arg [1]    : stauts of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_mirna_name_id(1);
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of Bio::Cogemir::MicroRNA
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_mirna_name_id{
	my ($self, $value) = @_;
	#print "MR FETCH BY mirna_name_id\n";
	$self->throw("I need a mirna_name_id") unless $value;
	my @objs;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute a
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.mirna_name_id = ?
	             };
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $count = 0;
	while (my $dbID = $sth->fetchrow_array){
		$count ++;
		#print "$count result\n";
		push (@objs, $self->fetch_by_dbID($dbID));
	}
	return \@objs;
}

=head2 fetch_by_label

  Arg [1]    : localization of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_all_label("KNOWN");
  Description: Retrieves an micro_rna from the database via its targetgene term
  Returntype : listref of id
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_label{
	my ($self, $value) = @_;
	#print "MR FETCH BY label\n";
	$self->throw("I need a label") unless $value;
	my @objs;
	my $sql = qq{SELECT count(distinct(mr.micro_rna_id)) 
	             FROM  micro_rna mr, localization l
	             WHERE mr.micro_rna_id = l.micro_rna_id
	             AND l.label = ? 
	             };
	
	my $sth = $self->prepare($sql);
	$sth->execute($value);
	my $count = $sth->fetchrow;
	unless ($count){
    my  $sql = qq{SELECT count(distinct(mr.micro_rna_id)) 
                 FROM micro_rna mr, localization l
                 WHERE mr.micro_rna_id = l.micro_rna_id
                 AND l.label like ? 
                 };
    
    my $sth = $self->prepare($sql);
    $sth->execute("%$value%");
    my $count = $sth->fetchrow;
  }
	return $count;
}


sub fetch_all_by_tissue{
  my ($self,$value) = @_;
  my $sql = qq{select micro_rna_id, probset, expression_level 
              from micro_rna_tissue 
              where tissue_name = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($value);
  return $sth->fetchrow_hashref;
}

sub fetch_by_tissue{
  my ($self,$value,$dbID) = @_;
  my $ret;
  my @res;
  my $sql = qq{select distinct(probset), expression_level 
              from micro_rna_tissue 
              where tissue_name = ?
              and micro_rna_id = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($value,$dbID);
  while (my ($probset, $expression_level) = $sth->fetchrow_array){
  	$ret->{$probset} = $expression_level;
  }
  return $ret;
}

=head2 fetch_by_gene_name_all_like

  Arg [1]    : gene_name of micro_rna
  Example    : $micro_rna = $micro_rna_adaptor->fetch_by_gene_name_like('hsa-mir-302');
  Description: Retrieves an micro_rna from the database via its gene_name
  Returntype : listref of Bio::Cogemir::MicroRNA more than one if has multiple localization
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_gene_name_all_like{
	my ($self, $value) = @_;
	
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.gene_name rlike ?
	             AND m.status != 'LC PREDICTION'
	             };
   #print ref $self, "line 711<br>\n";
   #printf "SELECT mr.micro_rna_id 
    #  	             FROM micro_rna mr, attribute m
    #  	             WHERE mr.attribute_id = m.attribute_id
    #  	             AND m.gene_name rlike \"%s\"<p>\n",".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute(".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)");
	while (my $dbID = $sth->fetchrow_array){
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

sub fetch_by_gene_name_all_one_like{
	my ($self, $value) = @_;
	$self->throw("I need a gene_name") unless $value;
	my $obj;
	my $sql = qq{SELECT mr.micro_rna_id 
	             FROM micro_rna mr, attribute m
	             WHERE mr.attribute_id = m.attribute_id
	             AND m.gene_name rlike ?
	             AND m.status != 'LC PREDICTION'
	             };
#     print ref $self, " line 796 <br>\n";
     printf "SELECT mr.micro_rna_id 
       	             FROM micro_rna mr, attribute m
       	             WHERE mr.attribute_id = m.attribute_id
       	             AND m.gene_name rlike \"%s\"<br>",".".$value."(\$|-.\$|[a-z]|[a-z]-.\$)";
	my $sth = $self->prepare($sql);
	$sth->execute($value."(\$|-.\$|[a-z]|[a-z]-.\$)");
	while (my $dbID = $sth->fetchrow_array){
	    print "$self\t$dbID\n";
		push (@{$obj} ,$self->fetch_by_dbID($dbID));
	}
	
	return $obj;
}

sub get_All{
    my ($self) = @_;
    my $obj;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             };
	my $sth = $self->prepare($sql);
	$sth->execute;
	while(my $dbID = $sth->fetchrow_array){
	    push (@{$obj},$self->fetch_by_dbID($dbID));
	}
	return $obj;

}

sub get_all_ExternalDatabase{
	my ($self,$dbID) = @_;
	my $res;
	my $sql = qq{select database_name as db, accession_number as accession, display
								from external_database
								where micro_rna_id = ?
							};
	my $sth = $self->prepare($sql);
	$sth->execute($dbID);
	while (my $href = $sth->fetchrow_hashref){
		push (@{$res},$href)
	}
	return $res;
}


sub get_all_tissue_expression{
  my ($self, $dbID) = @_;
  my $res;
  my $sql = qq{select e.tissue_id, e.external_id, e.expression_level, e.platform
  						from micro_rna_tissue mt, tissue t, expression e, symatlas_annotation sm
  						where mt.tissue_name = t.name
  						and e.tissue_id = t.tissue_id
  						and e.external_id = sm.symatlas_annotation_id
  						and e.expression_level = mt.expression_level
  						and e.platform = mt.platform
  						and sm.probset_id = mt.probset
              and mt.micro_rna_id = ?};
  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  while (my ($tissue_id, $external_id, $expression_level,$platform) = $sth->fetchrow_array){
  	#print ref $self, " line 751 $tissue_id, $external_id, $expression_level,$platform<br>\n";
  	my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
   	my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) if $tissue_id;
    my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self->db->get_ExpressionAdaptor,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
    push(@{$res},$expression);
  }
  return $res;
}

sub get_all_apcalls{
	my ($self,$dbID) = @_;
	my %res;
	my $sql = qq{select distinct(t.name), ap.tag
							from  tissue t,  ap_tissue ap, symatlas_annotation_gene sa
  						where sa.symatlas_annotation_id = ap.symatlas_annotation_id
  						and t.tissue_id = ap.tissue_id
              and sa.gene_id = ?};
#    printf "select distinct(t.name), ap.tag
#  							from  tissue t,  ap_tissue ap, symatlas_annotation_gene sa
#    						where sa.symatlas_annotation_id = ap.symatlas_annotation_id
#    						and t.tissue_id = ap.tissue_id
#                and sa.gene_id = %d<br>\n",$dbID;             
  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  while (my ($name, $tag) = $sth->fetchrow_array){
  	push (@{$res{$tag}},$name);
	}
	return \%res;
}

sub get_all_intragenic{
    my ($self) = @_;
    my $obj;
	my $sql = qq{SELECT micro_rna_id 
	             FROM micro_rna
	             WHERE hostgene_id
	             };
	my $sth = $self->prepare($sql);
	$sth->execute;
	while(my $dbID = $sth->fetchrow_array){
	    push (@{$obj},$self->fetch_by_dbID($dbID));
	}
	return $obj;

}

sub get_all_intragenic_by_organism{
  my ($self,$species) = @_;
   my $obj;
  my $sql = qq{SELECT mr.micro_rna_id
	             FROM micro_rna mr, attribute a, genome_db g
	             WHERE mr.attribute_id = a.attribute_id 
	             AND a.genome_db_id = g.genome_db_id
	             AND mr.hostgene_id 
	             AND g.organism = ?};
	my $sth = $self->prepare($sql);
	$sth->execute($species);
	while(my $dbID = $sth->fetchrow_array){
	    push (@{$obj},$self->fetch_by_dbID($dbID));
	}
	return $obj;
	             
	        
}
sub get_all_Localization{
	my ($self, $dbID) = @_;
	return $self->db->get_LocalizationAdaptor->fetch_by_micro_rna($dbID);
}

sub get_all_Features{
	my ($self, $dbID) = @_;
	return $self->db->get_FeatureAdaptor->fetch_by_micro_rna($dbID);
}

sub get_all_Hits{
	my ($self,$dbID) = @_;
	my $res;
	my $sql = qq{SELECT h.hit_id 
							 FROM micro_rna mr, micro_rna_feature mrf, blast b, hit h
							 WHERE mr.micro_rna_id = mrf.micro_rna_id 
							 AND mrf.feature_id = b.feature_id
							 AND h.blast_id = b.blast_id
							 AND mr.micro_rna_id = ?
							};
	my $sth = $self->prepare($sql);
	$sth->execute($dbID);
	while (my $hit_id = $sth->fetchrow_array){
		push (@{$res}, $self->db->get_HitAdaptor->fetch_by_dbID($hit_id))
	}
	
}


sub _exists{
	my ($self, $obj) = @_;
	my $obj_id;
	#print "MR EXISTS\n";
	
	my $sql = q { 
	SELECT micro_rna_id FROM micro_rna WHERE  attribute_id = ?  };
    my $sth = $self->prepare($sql);
	
    $sth->execute($obj->attribute->dbID());
	$obj_id = $sth->fetchrow;
	$obj->dbID($obj_id);
	$obj->adaptor($self);
	#print "$obj_id Exists\n";
	return $obj_id;
}


=head2 store

  Arg [1]    : Bio::Cogemir::MicroRNA
               the micro_rna  to be stored in this database
  Example    : $micro_rna_adaptor->store($micro_rna);
 Description : Stores an micro_rna in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $micro_rna ) = @_;
    #print "MR STORE in ",$self->db->dbname,"\n";

    #if it is not an micro_rna dont store
    if( ! $micro_rna->isa('Bio::Cogemir::MicroRNA') ) {
	$self->throw("$micro_rna is not a Bio::Cogemir::MicroRNA object - not storing!");
    }
    
    #if it has a dbID defined just return without storing
    if ($micro_rna->can('dbID') && $micro_rna->dbID) {return $micro_rna->dbID();}
   
   	unless($micro_rna->attribute->dbID){$self->db->get_AttributeAdaptor->store($micro_rna->attribute);}
   
   	
   	my $specific;
   	$specific = $micro_rna->specific if defined $micro_rna->specific;
   	my $share;
   	$share = $micro_rna->share if defined $micro_rna->share;
   
   	my $cluster_id;
   	if (defined $micro_rna->cluster){
   		unless($micro_rna->cluster->dbID){$cluster_id = $self->db->get_ClusterAdaptor->store($micro_rna->cluster);}
   		else{$cluster_id = $micro_rna->cluster->dbID}
   	}
   	my $hostgene_id;
   	if (defined $micro_rna->hostgene){
   		unless($micro_rna->hostgene->dbID){$hostgene_id = $self->db->get_GeneAdaptor->store($micro_rna->hostgene);}
   		else{$hostgene_id = $micro_rna->hostgene->dbID}
   	}
   
   	
   	
   	if ($self->_exists($micro_rna)){return $self->_exists($micro_rna);}

   	

    #otherwise store the information being passed
    my $sql = q { 
	INSERT INTO micro_rna SET  attribute_id = ?,  specific = ?, share = ?, seed = ?, cluster_id = ?, hostgene_id = ?};
    my $sth = $self->prepare($sql);

    $sth->execute($micro_rna->attribute->dbID(), 
                  $specific,$share,$micro_rna->seed,$cluster_id,
                  $hostgene_id);
    my $micro_rna_id = $sth->{'mysql_insertid'};
    $micro_rna->dbID($micro_rna_id);
    $micro_rna->adaptor($self);
    #print "MR STORED \n";
    return $micro_rna_id;
}

=head2 update

  Arg [1]    : Bio::Cogemir::MicroRNA
               the micro_rna  to be updated in this database
  Example    : $micro_rna_adaptor->update($micro_rna);
 Description : updates an micro_rna in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update {
    
  my ($self, $micro_rna) = @_;
  if( ! $micro_rna->isa('Bio::Cogemir::MicroRNA') ) {
	$self->throw("$micro_rna is not a Bio::Cogemir::MicroRNA object - not storing!");
  }
  my $specific;
  if (defined $micro_rna->specific){
    $specific = $micro_rna->specific;		 
  }
  my $share;
  if (defined $micro_rna->share){
    $share = $micro_rna->share;		 
  }
	my $cluster_id;
  if (defined $micro_rna->cluster){
    $cluster_id = $micro_rna->cluster->dbID;		 
  }
  my $seed_id;
  
  my $hostgene_id;
  if (defined $micro_rna->hostgene){$hostgene_id = $micro_rna->hostgene->dbID}
  
  my $sql = q { 
	UPDATE micro_rna SET  attribute_id = ?,  specific = ?, share = ?, seed = ?, cluster_id = ?, hostgene_id = ? where micro_rna_id = ?};
   	
  my $sth = $self->prepare($sql);

  $sth->execute($micro_rna->attribute->dbID(), 
                $specific,$share,$micro_rna->seed,$cluster_id,
                $hostgene_id, $micro_rna->dbID);
  return $self->fetch_by_dbID($micro_rna->dbID);
  
}    


=head2 remove

  Arg [1]    : Bio::Cogemir::MicroRNA
               the micro_rna  to be removed from this database
  Example    : $micro_rna_adaptor->remove($micro_rna);
 Description : removes an micro_rna in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
  my ($self, $micro_rna) = @_;
  #print $self." remove\n";
  unless (defined $micro_rna){$self->throw("micro_rna is not defined\n");}	
  if( ! defined $micro_rna->dbID() ) {$self->throw("A dbID is not defined\n"); }
  
  foreach my $localization (@{$micro_rna->localization}){$self->db->get_LocalizationAdaptor->_remove($localization);}
  #if ($micro_rna->features){foreach my $feature (@{$micro_rna->features}){$self->db->get_FeatureAdaptor->_remove($feature);}}
  
  $self->db->get_SeqAdaptor->_remove($micro_rna->mature_seq) if $micro_rna->mature_seq;
  $self->db->get_SeqAdaptor->_remove($micro_rna->attribute->seq) if $micro_rna->attribute;
  $self->db->get_AttributeAdaptor->_remove($micro_rna->attribute) if $micro_rna->attribute; 
  $self->db->get_GeneAdaptor->_remove($micro_rna->hostgene) if $micro_rna->hostgene;
  #if (defined $self->db->get_FeatureAdaptor->fetch_by_attribute_id($micro_rna->attribute->dbID)){
  #  foreach my $feature (@{$self->db->get_FeatureAdaptor->fetch_by_attribute_id($micro_rna->attribute->dbID)}){ $self->db->get_FeatureAdaptor->_remove($feature);}
  #}
  my $sth= $self->prepare( "delete from micro_rna where micro_rna_id = ? " );
  #printf "delete from micro_rna where micro_rna_id = %d\n",$micro_rna->dbID();
  $sth->execute($micro_rna->dbID());
  return 1;
}

=head2 _remove

  Arg [1]    : Bio::Cogemir::MicroRNA
               the micro_rna  to be removed from this database
  Example    : $micro_rna_adaptor->remove($micro_rna);
 Description : removes an micro_rna in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $micro_rna) = @_;
    #print $self." remove\n";
    unless (defined $micro_rna){
    	$self->throw("micro_rna is not defined\n");
    }	
    if( ! defined $micro_rna->dbID() ) {
		$self->throw("A dbID is not defined\n");
    }

  my $sth= $self->prepare( "delete from micro_rna where micro_rna_id = ? " );
    #printf "delete from micro_rna where micro_rna_id = %d\n",$micro_rna->dbID();
    $sth->execute($micro_rna->dbID());
    return 1;
}


1;
