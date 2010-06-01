
=head1 NAME - Bio::Cogemir::DBSQL::DBAdaptor

=head1 SYNOPSIS

    $db = Bio::Cogemir::DBSQL::DBAdaptor->new(
        -user   => 'root',
        -dbname => 'pog',
        -host   => 'caldy',
        -driver => 'mysql'
        );

    $hsp_adaptor = $db->get_HSPAdaptor();

    $hsp = $hsp_adaptor()->fetch_by_dbID($id);

    
=head1 DESCRIPTION

This object represents a database that is implemented somehow (you shouldn\'t
care much as long as you can get the object). Once created you can retrieve
database adaptors specific to various database objects that allow the
retrieval and creation of objects from the database,

=head1 CONTACT

Elia Stupka - elia@tigem.it

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::Cogemir::DBSQL::DBAdaptor;

use vars qw(@ISA);
use strict;
use Data::Dumper;
use Bio::Cogemir::DBSQL::DBConnection;
use lib "/www/maselli.tigem.it/htdocs/Projects/microrna/modules";

@ISA = qw(Bio::Cogemir::DBSQL::DBConnection);



#Override constructor inherited by Bio::Cogemir::DBSQL::DBConnection


=head2 new

  Arg [-DNADB]: (optional) Bio::Cogemir::DBSQL::DBAdaptor DNADB 
               All sequence, assembly, contig information etc, will be
                retrieved from this database instead.              
  Arg [..]   : Other args are passed to superclass 
               Bio::Cogemir::DBSQL::DBConnection
  Example    : $db = new Bio::Cogemir::DBSQL::DBAdaptor(
						    -user   => 'root',
						    -dbname => 'pog',
						    -host   => 'caldy',
						    -driver => 'mysql' );
  Description: Constructor for DBAdaptor.
  Returntype : Bio::Cogemir::DBSQL::DBAdaptor
  Exceptions : none
  Caller     : general

=cut

sub new {
  my($class, @args) = @_;
    
  #call superclass constructor
  my $self = $class->SUPER::new(@args);
  
  # $self here is actually a Container object
  # so need to call _obj to get the DBAdaptor
  $self->_obj->{'default_module'} =  {
  	  'Analysis'			=> 'Bio::Cogemir::DBSQL::AnalysisAdaptor',
	  'GenomeDB'			=> 'Bio::Cogemir::DBSQL::GenomeDBAdaptor',
      'LogicName'			=> 'Bio::Cogemir::DBSQL::LogicNameAdaptor',
      'Ontology'			=> 'Bio::Cogemir::DBSQL::OntologyAdaptor',
      'Seq'			        => 'Bio::Cogemir::DBSQL::SeqAdaptor',
      'MirnaName'			=> 'Bio::Cogemir::DBSQL::MirnaNameAdaptor',
      'Member'              => 'Bio::Cogemir::DBSQL::MemberAdaptor',
      'Location'            => 'Bio::Cogemir::DBSQL::LocationAdaptor',
      'SymatlasAnnotation'  => 'Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor',
      'Attribute'           => 'Bio::Cogemir::DBSQL::AttributeAdaptor',
      'Gene'                => 'Bio::Cogemir::DBSQL::GeneAdaptor',
      'Cluster'             => 'Bio::Cogemir::DBSQL::ClusterAdaptor',
      'Seed'                => 'Bio::Cogemir::DBSQL::SeedAdaptor',
      'MicroRNA'            => 'Bio::Cogemir::DBSQL::MicroRNAAdaptor',
      'Homologs'            => 'Bio::Cogemir::DBSQL::HomologsAdaptor',
      'Paralogs'            => 'Bio::Cogemir::DBSQL::ParalogsAdaptor',
      'Feature'             => 'Bio::Cogemir::DBSQL::FeatureAdaptor',
      'Blast'                   => 'Bio::Cogemir::DBSQL::BlastAdaptor',
      'Hit'                     => 'Bio::Cogemir::DBSQL::HitAdaptor',
      'Hsp'                     => 'Bio::Cogemir::DBSQL::HspAdaptor',
      'Tissue'                  => 'Bio::Cogemir::DBSQL::TissueAdaptor',
      'Expression'         =>'Bio::Cogemir::DBSQL::ExpressionAdaptor',
      'Transcript'          =>'Bio::Cogemir::DBSQL::TranscriptAdaptor',
      'Exon'                    =>'Bio::Cogemir::DBSQL::ExonAdaptor',
      'Intron'                  =>'Bio::Cogemir::DBSQL::IntronAdaptor',
      'Localization'        => 'Bio::Cogemir::DBSQL::LocalizationAdaptor',
      'Aliases'           => 'Bio::Cogemir::DBSQL::AliasesAdaptor'
      };
  
  # initialise storage for hash of names of current modules
  %{$self->_obj->{'current_module'}} = %{$self->_obj->{'default_module'}}; 
  
  # keep a hash of objects representing objects of each adaptor type
  # instantiated as required in get adaptor
  $self->_obj->{'current_objects'} = {};
  
  return $self;
}


=head2 get_AnalysisAdaptor

  Args       : none 
  Example    : $Analysis_adaptor = $db_adaptor->get_AnalysisAdaptor();
  Description: Gets a AnalysisAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::AnalysisAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_AnalysisAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Analysis");

}



=head2 get_GenomeDBAdaptor

  Args       : none 
  Example    : $GenomeDB_adaptor = $db_adaptor->get_GenomeDBAdaptor();
  Description: Gets a GenomeDBAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::GenomeDBAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_GenomeDBAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("GenomeDB");

}



=head2 get_LogicNameAdaptor

  Args       : none 
  Example    : $LogicName_adaptor = $db_adaptor->get_LogicNameAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::LogicNameAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_LogicNameAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("LogicName");

}



=head2 get_OntologyAdaptor

  Args       : none 
  Example    : $ontology_adaptor = $db_adaptor->get_OntologyAdaptor();
  Description: Gets a OntologyAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::OntologyAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_OntologyAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Ontology");

}

=head2 get_SeqAdaptor

  Args       : none 
  Example    : $seq_adaptor = $db_adaptor->get_SeqAdaptor();
  Description: Gets a SeqAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::SeqAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_SeqAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Seq");

}

=head2 get_MirnaNameAdaptor

  Args       : none 
  Example    : $mirna_name_adaptor = $db_adaptor->get_MirnaNameAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::LogicNameAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_MirnaNameAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("MirnaName");

}

=head2 get_LocationAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_LocationAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::LocationAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_LocationAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Location");

}

=head2 get_MemberAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_MemberAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::MemberAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_MemberAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Member");

}

=head2 get_AttributeAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_AttributeAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::AttributeAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_AttributeAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Attribute");

}

=head2 get_GeneAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_GeneAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::GeneAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_GeneAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Gene");

}

=head2 get_TranscriptAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_TranscriptAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::TranscriptAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_TranscriptAdaptor {
  my( $self ) = @_;
  return $self->get_adaptor("Transcript");

}

=head2 get_ExonAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_ExonAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::ExonAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_ExonAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Exon");

}

=head2 get_IntronAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_IntronAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::IntronAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_IntronAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Intron");

}

=head2 get_ClusterAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_ClusterAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::ClusterAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_ClusterAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Cluster");

}

=head2 get_SeedAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_SeedAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::SeedAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_SeedAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Seed");

}

=head2 get_MicroRNAAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_MicroRNAAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::MicroRNAAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_MicroRNAAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("MicroRNA");

}

=head2 get_HomologsAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_HomologsAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::HomologsAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_HomologsAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Homologs");

}

=head2 get_ParalogsAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_ParalogsAdaptor();
  Description: Gets a ParalogsAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::ParalogsAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_ParalogsAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Paralogs");

}

=head2 get_FeatureAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_FeatureAdaptor();
  Description: Gets a FeatureAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::FeatureAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_FeatureAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Feature");

}

=head2 get_BlastAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_BlastAdaptor();
  Description: Gets a BlastAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::BlastAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_BlastAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Blast");

}

=head2 get_HitAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_HitAdaptor();
  Description: Gets a HitAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::HitAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_HitAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Hit");

}

=head2 get_HspAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_HspAdaptor();
  Description: Gets a HspAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::HspAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_HspAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Hsp");
}




=head2 get_SymatlasAnnotationAdaptor

  Args       : none 
  Example    : $symatlas_annotation_adaptor = $db_adaptor->get_SymatlasAnnotationAdaptor();
  Description: Gets a LogicNameAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::SymatlasAnnotationAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_SymatlasAnnotationAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("SymatlasAnnotation");

}

=head2 get_TissueAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_TissueAdaptor();
  Description: Gets a TissueAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::TissueAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_TissueAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Tissue");
}

=head2 get_AliasesAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_AliasesAdaptor();
  Description: Gets a AliasesAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::AliasesAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_AliasesAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Aliases");
}

=head2 get_ExpressionAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_ExpressionAdaptor();
  Description: Gets a ExpressionAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::ExpressionAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_ExpressionAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Expression");
}

=head2 get_LocalizationAdaptor

  Args       : none 
  Example    : $location_adaptor = $db_adaptor->get_LocalizationAdaptor();
  Description: Gets a LocalizationAdaptor for this database
  Returntype : Bio::Cogemir::DBSQL::LocalizationAdaptor
  Exceptions : none
  Caller     : general

=cut

sub get_LocalizationAdaptor {
  my( $self ) = @_;
  
  return $self->get_adaptor("Localization");
}


=head2 deleteObj

  Arg [1]    : none
  Example    : none
  Description: Cleans up circular reference loops so proper garbage collection
               can occur.
  Returntype : none
  Exceptions : none
  Caller     : DBAdaptorContainer::DESTROY

=cut




sub deleteObj {
  my $self = shift;

    if ($self->isa('Bio::Cogemir::Container')) {
        $self = $self->_obj;
    }

  #print "called deleteObj on DBAdaptor\n";

  #clean up external feature adaptor references
  if(exists $self->{'_xf_adaptors'}) {
    foreach my $key (keys %{$self->{'_xf_adaptors'}}) {
      delete $self->{'_xf_adaptors'}->{$key};
    }
  }
	
  if(exists $self->{'current_objects'}) {
    foreach my $adaptor_name (keys %{$self->{'current_objects'}}) {
      my $adaptor = $self->{'current_objects'}->{$adaptor_name};
      if($adaptor && $adaptor->can('deleteObj')) {
        $adaptor->deleteObj();
      }
        #print STDERR "DELETING '$adaptor_name'\n";
      delete $self->{'current_objects'}->{$adaptor_name};
    }
  }


  #call the superclass deleteObj method
  $self->SUPER::deleteObj;
}

=head2 get_adaptor

  Arg [1]    : Canonical data type for which an adaptor is required.
  Example    : $db_adaptor->get_adaptor("Protein")
  Description: Gets an adaptor object for a standard data type.
  Returntype : Adaptor Object of arbitrary type
  Exceptions : thrown if there is no associated module
  Caller     : external

=cut

sub get_adaptor() {

	my ($self, $canonical_name, @other_args) = @_;
        if ($self->isa('Bio::Cogemir::Container')) {
            $self = $self->_obj;
        }

	# throw if module for $canonical_name does not exist
	$self->throw("No such data type $canonical_name") if (!exists($self->{'current_module'}->{$canonical_name}));

	# get module name for $canonical_name
	my $module_name = $self->{'default_module'}->{$canonical_name};
	# create and store a new one if necessary
	if (!exists($self->{'current_objects'}->{$canonical_name})) {
	  $self->{'current_objects'}->{$canonical_name} = $self->_get_adaptor($module_name, @other_args);
	}
	return $self->{'current_objects'}->{$canonical_name};

}


=head2 set_adaptor

  Arg [1]    : Canonical data type for new adaptor.
	Arg [2]    : Object defining the adaptor for arg1.
  Example    : $pa = Bio::Cogemir::DBSQL::ProteinAdaptor->new($db_adaptor);
             : $db_adaptor->set_adaptor("Protein", $pa)
  Description: Stores the object which represents the adaptor for the arg1 data type.
  Returntype : none
  Exceptions : If arg2 is not a subclass of the default module for this data type.
  Caller     : external

=cut

sub set_adaptor() {

	my ($self, $canonical_name, $new_object) = @_;

        if ($self->isa('Bio::Cogemir::Container')) {
            $self = $self->_obj;
        }

  # throw if an unrecognised canonical_name is used
	$self->throw("No such data type $canonical_name") if (!exists($self->{'default_module'}->{$canonical_name}));

	my $default_module = $self->{'default_module'}->{$canonical_name};
	
	# Check that $new_module is a subclass of $default_module	
	if (!$new_object->isa($default_module)) {  # polymorphism should work
		$self->throw("ref($new_object) is not a subclass of $default_module");
	}

	# set the value in current_module
	$self->{'current_objects'}->{$canonical_name} = $new_object;

}

1;
