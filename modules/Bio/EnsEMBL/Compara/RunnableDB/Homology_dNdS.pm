#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod 

=head1 NAME

Bio::EnsEMBL::Compara::RunnableDB::Homology_dNdS

=cut

=head1 SYNOPSIS

my $db      = Bio::EnsEMBL::Compara::DBAdaptor->new($locator);
my $repmask = Bio::EnsEMBL::Compara::RunnableDB::Homology_dNdS->new ( 
                                                    -db      => $db,
                                                    -input_id   => $input_id
                                                    -analysis   => $analysis );
$repmask->fetch_input(); #reads from DB
$repmask->run();
$repmask->output();
$repmask->write_output(); #writes to DB

=cut

=head1 DESCRIPTION

This object wraps Bio::EnsEMBL::Pipeline::Runnable::Blast to add
functionality to read and write to databases.
The appropriate Bio::EnsEMBL::Analysis object must be passed for
extraction of appropriate parameters. A Bio::EnsEMBL::Pipeline::DBSQL::Obj is
required for databse access.

=cut

=head1 CONTACT

Describe contact details here

=cut

=head1 APPENDIX

The rest of the documentation details each of the object methods. 
Internal methods are usually preceded with a _

=cut

package Bio::EnsEMBL::Compara::RunnableDB::Homology_dNdS;

use strict;

use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Compara::Member;

use Bio::Tools::Run::Phylo::PAML::Codeml;

our @ISA = qw(Bio::EnsEMBL::Hive::Process);

sub fetch_input {
  my( $self) = @_;

  $self->{'codeml_parameters_href'} = undef;
  $self->throw("No input_id") unless defined($self->input_id);

  #create a Compara::DBAdaptor which shares the same DBI handle
  #with the Pipeline::DBAdaptor that is based into this runnable
  $self->{'comparaDBA'} = Bio::EnsEMBL::Compara::DBSQL::DBAdaptor->new(-DBCONN=>$self->db->dbc);

  $self->get_params($self->parameters);
  my $homology_id = $self->input_id;
  $self->{'homology'}= $self->{'comparaDBA'}->get_HomologyAdaptor->fetch_by_dbID($homology_id);
  return 1 if($self->{'homology'});
  return 0;
}

sub get_params {
  my $self         = shift;
  my $param_string = shift;

  return unless($param_string);
  print("parsing parameter string : ",$param_string,"\n") if($self->debug);
  
  my $params = eval($param_string);
  return unless($params);

  if($self->debug) {
    foreach my $key (keys %$params) {
      print("  $key : ", $params->{$key}, "\n");
    }
  }

  if (defined $params->{'dNdS_analysis_data_id'}) {
    my $analysis_data_id = $params->{'dNdS_analysis_data_id'};
    my $ada = $self->db->get_AnalysisDataAdaptor;
    my $codeml_parameters_hashref = eval($ada->fetch_by_dbID($analysis_data_id));
    if (defined $codeml_parameters_hashref) {
      $self->{'codeml_parameters_href'} = $codeml_parameters_hashref;
    }
  }
  
  return;

}


sub run
{
  my $self = shift;
  $self->calc_genetic_distance($self->{'homology'});
  return 1;
}


sub write_output {
  my $self = shift;
  my $homologyDBA = $self->{'comparaDBA'}->get_HomologyAdaptor;
  $homologyDBA->update_genetic_distance($self->{'homology'});
  return 1;
}


##########################################
#
# internal methods
#
##########################################

sub calc_genetic_distance
{
  my $self = shift;
  my $homology = shift;

  #print("use codeml to get genetic distance of homology\n");
  #$homology->print_homology;
  
  # second argument will change selenocyteine TGA codons to NNN
  my $aln = $homology->get_SimpleAlign("cdna", 1);

  $self->{'comparaDBA'}->dbc->disconnect_when_inactive(1);
  
  my $codeml = new Bio::Tools::Run::Phylo::PAML::Codeml();
  if (defined $self->{'codeml_parameters_href'}) {
    my %params = %{$self->{'codeml_parameters_href'}};
    foreach my $key (keys %params) {
      $codeml->set_parameter($key,$params{$key});
    }
  }
  $codeml->alignment($aln);
  if (0 != $aln->{_special_codeml_icode}) {
    $codeml->set_parameter("icode",$aln->{_special_codeml_icode})
  }
  my ($rc,$parser) = $codeml->run();
  if($rc == 0) {
    print_simple_align($aln, 80);
    print("codeml error : ", $codeml->error_string, "\n");
  }
  my $result = $parser->next_result;
  
  my $MLmatrix = $result->get_MLmatrix();

  #print "n = ", $MLmatrix->[0]->[1]->{'N'},"\n";
  #print "s = ", $MLmatrix->[0]->[1]->{'S'},"\n";
  #print "t = ", $MLmatrix->[0]->[1]->{'t'},"\n";
  #print "lnL = ", $MLmatrix->[0]->[1]->{'lnL'},"\n";
  #print "Ka = ", $MLmatrix->[0]->[1]->{'dN'},"\n";
  #print "Ks = ", $MLmatrix->[0]->[1]->{'dS'},"\n";
  #print "Ka/Ks = ", $MLmatrix->[0]->[1]->{'omega'},"\n";

  $homology->n($MLmatrix->[0]->[1]->{'N'});
  $homology->s($MLmatrix->[0]->[1]->{'S'});
  $homology->dn($MLmatrix->[0]->[1]->{'dN'});
  $homology->ds($MLmatrix->[0]->[1]->{'dS'});
  $homology->lnl($MLmatrix->[0]->[1]->{'lnL'});

  $self->{'comparaDBA'}->dbc->disconnect_when_inactive(0);

  return $homology;
}

sub print_simple_align
{
  my $alignment = shift;
  my $aaPerLine = shift;
  $aaPerLine=40 unless($aaPerLine and $aaPerLine > 0);

  my ($seq1, $seq2)  = $alignment->each_seq;
  my $seqStr1 = "|".$seq1->seq().'|';
  my $seqStr2 = "|".$seq2->seq().'|';

  my $enddiff = length($seqStr1) - length($seqStr2);
  while($enddiff>0) { $seqStr2 .= " "; $enddiff--; }
  while($enddiff<0) { $seqStr1 .= " "; $enddiff++; }

  my $label1 = sprintf("%40s : ", $seq1->id);
  my $label2 = sprintf("%40s : ", "");
  my $label3 = sprintf("%40s : ", $seq2->id);

  my $line2 = "";
  for(my $x=0; $x<length($seqStr1); $x++) {
    if(substr($seqStr1,$x,1) eq substr($seqStr2, $x,1)) { $line2.='|'; } else { $line2.=' '; }
  }

  my $offset=0;
  my $numLines = (length($seqStr1) / $aaPerLine);
  while($numLines>0) {
    printf("$label1 %s\n", substr($seqStr1,$offset,$aaPerLine));
    printf("$label2 %s\n", substr($line2,$offset,$aaPerLine));
    printf("$label3 %s\n", substr($seqStr2,$offset,$aaPerLine));
    print("\n\n");
    $offset+=$aaPerLine;
    $numLines--;
  }
}

1;
