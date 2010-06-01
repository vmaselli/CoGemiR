#
# Module for Bio::Cogemir::DBSQL::ExpressionAdaptor
#
# Cared for by Vincenza Maselli <maselli@tigem.it>
#
# Copyright Vincenza Maselli
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 EXPRESSION_LEVEL

Bio::Cogemir::DBSQL::CSTAdaptor

=head1 SYNOPSIS

    $expression_adaptor = $db->get_ExpressionAdaptor();

    $expression = $expression_adaptor->fetch_by_external();

    $expression = $expression_adaptor->fetch_by_expression_level();

=head1 DESCRIPTION

    This adaptor work with the expression bridge table 


=head1 AUTHORS - 
Vincenza Maselli - maselli@tigem.it

=cut


package Bio::Cogemir::DBSQL::ExpressionAdaptor;
use vars qw(@ISA);
use strict;
use Data::Dumper;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/htdocs/modules";
use Bio::Cogemir::Expression;
use Bio::Cogemir::DBSQL::BaseAdaptor;
use Bio::Cogemir::DBSQL::DBAdaptor;

@ISA = qw(Bio::Cogemir::DBSQL::BaseAdaptor);


=head2 fetch_all_by_external

  Arg [1]    : external_id
  Example    : $expression = $ln_adaptor->fetch_by_external($external);
  Description: Retrieves an expression from the database via external id
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub fetch_all_by_external {
    my ($self, $external) = @_;
    my @res;
    $self->throw("I need a external id") unless $external;
    my $query = qq {
    SELECT expression_level, tissue_id, platform
      FROM expression 
      WHERE  external_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($external);
	while (my ($expression_level, $tissue_id, $platform) = $sth->fetchrow_array()){
       unless (defined $expression_level){
           $self->warn("no expression for $external");
           #return undef;
       }
       my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external);
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) if $tissue_id; 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}

=head2 fetch_by_expression_level

  Arg [1]    : expression expression_level
  Example    : $expression = $cst_adaptor->fetch_by_expression_level($expression_level);
  Description: Retrieves an expression from the database via its expression_level
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_expression_level {
    my ($self, $expression_level) = @_;
    my @res;
    $self->throw("I need a expression id") unless $expression_level;
    my $query = qq {
    SELECT external_id, tissue_id, platform
      FROM expression 
      WHERE  expression_level= ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($expression_level);
	while (my ($external_id, $tissue_id, $platform) = $sth->fetchrow_array()){
       unless (defined $expression_level){
           #$self->warn("no expression for $expression_level");
           return undef;
       }
       my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) if $tissue_id; 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $expression_level,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}

=head2 fetch_by_tissue_id

  Arg [1]    : expression tissue_id
  Example    : $expression = $cst_adaptor->fetch_by_tissue_id($tissue_id);
  Description: Retrieves an expression from the database via its tissue_id
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_tissue_id {
    my ($self, $tissue_id) = @_;
    my @res;
    $self->throw("I need a tissue id") unless $tissue_id;
    my $query = qq {
    SELECT external_id, expression_level, platform
      FROM expression 
      WHERE  tissue_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($tissue_id);
	while (my ($external_id, $expression_level, $platform) = $sth->fetchrow_array() ){
       unless (defined $expression_level){
           #$self->warn("no expression for $tissue_id");
           return undef;
       }
       my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) if $tissue_id; 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}


sub fetch_by_symatlas_annotation {
  my ($self,$dbID) = @_;
  return $self->_fetch_by_external_id($dbID, "Sym");

}

=head2 _fetch_by_external_id

  Arg [1]    : expression external_id
  Example    : $expression = $cst_adaptor->fetch_by_external_id($external_id);
  Description: Retrieves an expression from the database via its external_id
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub _fetch_by_external_id {
    my ($self, $external_id,$tag) = @_;
    my @res;
    $self->throw("I need a external id") unless $external_id;
    my $query = qq {
    SELECT tissue_id, expression_level, platform
      FROM expression 
      WHERE  external_id = ? 
  };

    my $sth = $self->prepare($query);
    $sth->execute($external_id);
	while (my ($tissue_id, $expression_level, $platform) = $sth->fetchrow_array() ){
       unless (defined $expression_level){
           #$self->warn("no expression for $external_id");
           return undef;
       }
       my $external;
       if ($tag eq "Sym"){$external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);}
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) if $tissue_id; 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $external,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}

=head2 fetch_by_tissue_name

  Arg [1]    : expression tissue_id
  Example    : $expression = $cst_adaptor->fetch_by_tissue_id($tissue_id);
  Description: Retrieves an expression from the database via its tissue_id
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_tissue_name{
    my ($self, $tissue_name) = @_;
    my @res;
    $self->throw("I need a tissue name") unless $tissue_name;
    my $query = qq {
    SELECT s.external_id, e.expression_level, e.platform
      FROM expression e, tissue t
      WHERE  e.tissue_id = t.tissue_id
      AND t.name = ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($tissue_name);
	while (my ($external_id, $expression_level, $platform) = $sth->fetchrow_array() ){
       unless (defined $expression_level){
           #$self->warn("no expression for $tissue_id");
           return undef;
       }
       my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_name($tissue_name); 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}


=head2 fetch_by_tissue_name_gene

  Arg [1]    : expression tissue_id
  Example    : $expression = $cst_adaptor->fetch_by_tissue_id($tissue_id);
  Description: Retrieves an expression from the database via its tissue_id
  Returntype : listref of Bio::Cogemir::Expression
  Exceptions : none
  Caller     : general

=cut

sub fetch_by_tissue_name_gene{
    my ($self, $tissue_name, $gene_id) = @_;
    my @res;
    $self->throw("I need a tissue name") unless $tissue_name;
    my $query = qq {
    SELECT sm.external_id, e.expression_level, platform
      FROM expression e, tissue t, gene m, external_gene sm
      WHERE  e.tissue_id = t.tissue_id
      AND sm.gene_id = m.gene_id
      AND sm.external_id = e.external_id
      AND m.gene_id = ?
      AND t.name = ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($gene_id,$tissue_name);
	  my ($external_id, $expression_level,$platform) = $sth->fetchrow_array();
    my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
    my $tissue = $self->db->get_TissueAdaptor->fetch_by_name($tissue_name); 
    my ($expression) =  Bio::Cogemir::Expression->new(   
                                -EXTERNAL => $external,
                                -ADAPTOR =>$self,
                                -EXPRESSION_LEVEL => $expression_level,
                                -TISSUE => $tissue,
                                -PLATFORM => $platform
                               );
   
       
    return $expression;
}

sub fetch_by_tissue_gene{
    my ($self, $tissue_id, $gene_id) = @_;
    my @res;
    $self->throw("I need a tissue id") unless $tissue_id;
    my $query = qq {
    SELECT sm.external_id, e.expression_level, e.platform
      FROM expression e, tissue t, gene m, external_gene sm
      WHERE  e.tissue_id = t.tissue_id
      AND sm.gene_id = m.gene_id
      AND sm.external_id = e.external_id
      AND m.gene_id = ?
      AND t.tissue_id = ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($gene_id,$tissue_id);
	  my ($external_id, $expression_level,$platform) = $sth->fetchrow_array();
    my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
    my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id); 
    my ($expression) =  Bio::Cogemir::Expression->new(   
                                -EXTERNAL => $external,
                                -ADAPTOR =>$self,
                                -EXPRESSION_LEVEL => $expression_level,
                                -TISSUE => $tissue,
                                -PLATFORM => $platform
                               );
   
       
    return $expression;
}





sub fetch_by_gene{
    my ($self, $gene_id) = @_;
    my @res;
    $self->throw("I need a gene id") unless $gene_id;
    my $query = qq {
    SELECT e.external_id, e.expression_level, e.tissue_id, e.platform
      FROM expression e, tissue t, gene m, external_gene sm
      WHERE  e.tissue_id = t.tissue_id
      AND sm.gene_id = m.gene_id
      AND sm.external_id = e.external_id
      AND m.gene_id = ?
  };

    my $sth = $self->prepare($query);
    $sth->execute($gene_id);
	  my ($external_id, $expression_level, $tissue_id,$platform) = $sth->fetchrow_array();
	  #print ref $self," $external_id, $expression_level, $tissue_id line 273<br>\n";
    my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($external_id);
    my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id); 
    my ($expression) =  Bio::Cogemir::Expression->new(   
                                -EXTERNAL => $external,
                                -ADAPTOR =>$self,
                                -EXPRESSION_LEVEL => $expression_level,
                                -TISSUE => $tissue,
                                -PLATFORM => $platform
                               );
   
       
    return $expression;
}



=head2 get_median_for_species

  Arg [1]    : species
  Example    : $expression = $adaptor->get_median_for_species('Homo_sapiens');
  Description: get median value of the espression level in the tissue in the species
  Returntype : flaot
  Exceptions : none
  Caller     : general

=cut

sub get_median_for_gene{
    my ($self, $value) = @_;
    my @ar = @{$self->get_all_level_by_gene($value)};
    my @values = sort ({$a <=> $b} @ar);
    my $n = scalar @values;
    my $median;
    #$n odd (dispari)
    if ($n % 2){
        my $idx = ($n-1)/2;
        $median = $values[$idx];
        return $median;
    }
    #$n even (pari)
    else{
        my $idx_1 = ($n-1)/2;
        my $idx_2 = ($n+1)/2;
        $median = ($values[$idx_1] + $values[$idx_2])/2;
        return $median;
    }
    
}

sub get_all_level_by_gene{
    my ($self, $value) = @_;
    $self->throw("I need a species") unless $value;
    my $sql = qq{select e.expression_level 
    from  expression e, external_gene sm
    where sm.external_id = e.external_id 
    and sm.gene_id = ? 
    };
    my $sth = $self->prepare($sql);
    $sth->execute($value);
    my @res;
    while (my $r = $sth->fetchrow_array){
        push (@res, $r);
    }
    return \@res;
}

sub get_all_tissue_by_gene_external{
    my ($self, $value,$value2) = @_;
    $self->throw("I need a species") unless $value;
    my $sql = qq{select e.tissue_id 
    from  expression e, external_gene sm
    where sm.external_id = e.external_id 
    and sm.platform = e.platform
    and sm.gene_id = ? 
    and sm.external_id = ?
    };
    my $sth = $self->prepare($sql);
    $sth->execute($value,$value2);
    my @res;
    while (my $r = $sth->fetchrow_array){
        push (@res, $self->db->get_TissueAdaptor->fetch_by_dbID($r));
    }
    return \@res;
}


sub count_all_tissue_by_gene_external{
    my ($self, $value,$value2) = @_;
    $self->throw("I need a gene_id") unless $value;
    my $sql = qq{select count(e.tissue_id) 
    from  expression e, symatlas_annotation_gene sm
    where sm.symatlas_annotation_id = e.external_id 
    and sm.gene_id = ? 
    and sm.symatlas_annotation_id = ?
    };
    my $sth = $self->prepare($sql);
    $sth->execute($value,$value2);
    my $r = $sth->fetchrow;
       
    return $r;
}

sub get_all_by_gene_external{
    my ($self, $value,$value2) = @_;
    $self->throw("I need a gene id") unless $value;
    my $sql = qq{select e.tissue_id, e.expression_level, e.platform 
    from  expression e, symatlas_annotation_gene sm
    where sm.symatlas_annotation_id = e.external_id 
    and sm.gene_id = ? 
    and sm.symatlas_annotation_id = ?
    };
    
    my $sth = $self->prepare($sql);
    $sth->execute($value,$value2);
    my @res;
    while (my ($tissue_id, $expression_level,$platform) = $sth->fetchrow_array()){
       my $external = $self->db->get_SymatlasAnnotationAdaptor->fetch_by_dbID($value2);
       my $tissue = $self->db->get_TissueAdaptor->fetch_by_dbID($tissue_id) ; 
       my ($expression) =  Bio::Cogemir::Expression->new(   
                                   -EXTERNAL => $external,
                                   -ADAPTOR =>$self,
                                   -EXPRESSION_LEVEL => $expression_level,
                                   -TISSUE => $tissue,
                                   -PLATFORM => $platform
                                  );
   
        push (@res,$expression);       
    }
    return \@res;
}


sub _exists{
	my ($self, $obj) = @_;
	my $tissue_id = $obj->tissue->dbID if defined $obj->tissue;
	my $obj_id;
	my $query = qq {
		SELECT external_id
		FROM expression
		WHERE expression_level = ? and tissue_id = ?
	};
	my $sth = $self->prepare($query);
	$sth->execute($obj->expression_level, $tissue_id);
	$obj_id = $sth->fetchrow;
	$obj->adaptor($self);
	return $obj_id;
}

=head2 store

  Arg [1]    : Bio::Cogemir::Expression
               the expression  to be stored in this database
  Example    : $expression_adaptor->store($expression);
 Description : Stores an expression in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub store {
    my ( $self, $expression ) = @_;


    #if it is not an expression don't store
    if( ! $expression->isa('Bio::Cogemir::Expression') ) {
	$self->throw("$expression is not a Bio::Cogemir::Expression object - not storing!");
    }
    
    if ($self->_exists($expression)){return 1; }
    #if expression_level exists return without storing
    my $tissue_id;
    if (defined $expression->tissue){
        unless ($expression->tissue->dbID){$tissue_id = $self->db->get_TissueAdaptor->store($expression->tissue); }
        else{$tissue_id = $expression->tissue->dbID}
    }
    if ($expression->external->isa('Bio::Cogemir::SymatlasAnnotation')){
      unless ($expression->external->dbID){$self->db->get_SymatlasAnnotationAdaptor->store($expression->external); }
    }
    elsif ($expression->external->isa('Bio::Cogemir::NcbiEST')){
      unless ($expression->external->dbID){$self->db->get_NcbiESTAdaptor->store($expression->external); }
    }

    

    #otherwise store the information being passed
    my $sql = q {INSERT INTO expression SET external_id = ?, expression_level = ?, tissue_id = ?};

    my $sth = $self->prepare($sql);

    $sth->execute($expression->external->dbID,$expression->expression_level(), $tissue_id);
    
    $expression->adaptor($self);
    return 1;
}

=head2 remove

  Arg [1]    : Bio::Cogemir::Expression
               the expression  to be removed in this database
  Example    : $expression_adaptor->remove($expression);
 Description : removes an expression in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub remove {
    
    my ($self, $expression) = @_;
    $self->throw("I need a expression") unless $expression;
    my $tissue_id = $expression->tissue->dbID if $expression->tissue;
    if( ! defined $expression->external() ) {$self->throw("A external is not defined\n");}
    my $sth= $self->prepare( "delete from expression where external_id = ? and expression_level = ? and tissue_id = ? " );
    $sth->execute($expression->external->dbID,$expression->expression_level(), $tissue_id);
    return 1;

}

=head2 _remove

  Arg [1]    : Bio::Cogemir::Expression
               the expression  to be removed in this database
  Example    : $expression_adaptor->remove($expression);
 Description : removes an expression in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub _remove {
    
    my ($self, $expression) = @_;
    $self->throw("I need a expression") unless $expression;
    my $tissue_id = $expression->tissue->dbID if $expression->tissue;
    if( ! defined $expression->external() ) {$self->throw("A external is not defined\n");}
    my $sth= $self->prepare( "delete from expression where external_id = ? and expression_level = ? and tissue_id = ? " );
    $sth->execute($expression->external->dbID,$expression->expression_level(), $tissue_id);
    return 1;

}

=head2 update

  Arg [1]    : Bio::Cogemir::Expression
               the expression  to be updated in this database
  Example    : $expression_adaptor->update($expression);
 Description : updates an expression in the database
  Returntype : none
  Exceptions :
  Caller     : general

=cut

sub update{
    my ($self, $expression) = @_;
        if( ! $expression->isa('Bio::Cogemir::Expression') ) {
	$self->throw("$expression is not a Bio::Cogemir::Expression object - not updating!");
    }
    my $tissue_id = $expression->tissue->dbID if defined $expression->tissue;
    my $sql = q {UPDATE expression SET expression_level = ?, tissue_id = ?  WHERE external_id = ? };
    my $sth = $self->prepare($sql);
    $sth->execute($expression->expression_level(),$tissue_id,$expression->external->dbID);
    my $rt = $self->_fetch_by_external_id($expression->external->dbID,"Sym");
    return $rt;
}
1;
