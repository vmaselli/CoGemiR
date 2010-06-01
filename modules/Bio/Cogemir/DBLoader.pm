
#
# BioPerl module for Bio::Cogemir::DBLoader
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::GeneCogemir::DBLoader - Run time database loader

=head1 SYNOPSIS

    $db = Bio::GeneCogemir::DBLoader->new("Bio::GeneCogemir::DBSQL::DBAdaptor/host=localhost;dbname=homo_sapiens_core_19_34a;user=ensro;");

    # $db is a database object
    $db = Bio::GeneCogemir::DBLoader->standard();
    # equivalent to Bio::GeneCogemir::DBLoader->new($ENV{'ENSEMBL_DATABASE'});


=head1 DESCRIPTION

This system provides a run-time loading of the database for ensembl, allowing two things

    a) Only "using" the database module which is required for a particular implementation

    b) Providing a simple string method to indicate where the database is, allowing per sites
defaults and other things as such


The string is parsed as follows:

Before the / is the Perl database object to load, after are the parameters to pass
to that database. The parameters are series of key=values separated by semi-colons.
These are passed as a hash to the new method of the database object

=head1 CONTACT

Post questions/comments to the Ensembl development list:
B<ensembl-dev@ebi.ac.uk>

=head1 METHODS

=cut

package Bio::Cogemir::DBLoader;

use strict;


=head2 new

  Arg [1]    : string $string
               An Ensembl database locator string.
  Example    : Bio::GeneCogemir::DBSQL::DBLoader->new("Bio::GeneCogemir::DBSQL::DBAdaptor/host=localhost;dbname=homo_sapiens_core_19_34a;user=ensro;"
  Description: Connects to an Ensembl database using the module specified in
               the locator string.
  Returntype : The module specified in the load string is returned.
  Exceptions : thrown if the specified module cannot be instantiated or the
               locator string cannot be parsed
  Caller     : ?

=cut

sub new{
   my ($class,$string) = @_;
   my ($module,%hash);

   $string =~ /(\S+?)\/(\S+)/ || die "Could not parse [$string] as a ensembl database locator. Needs database_module/params";
   $module = $1;
   my $param = $2;

   &_load_module($module);
   my @param = split(/;/,$param);
   foreach my $keyvalue ( @param ) {
       $keyvalue =~ /(\S+?)=(\S*)/ || do { warn("In loading $keyvalue, could not split into keyvalue for loading $module. Ignoring"); next; };

       my $key = $1;
       my $value = $2;

       $hash{"-$key"} = $value;
   }
   
   my @kv = %hash;

   return "$module"->new(%hash);
}


sub _load_module{
  my ($modulein) = @_;
  my ($module,$load,$m);

  $module = "_<$modulein.pm";
  $load = "$modulein.pm";
  $load =~ s/::/\//g;
  
  return 1 if $main::{$module};
  eval {
    require $load;
  };
  if( $@ ) {
    print STDERR <<END;
$load: cannot be found
Exception $@

END
  ;
    return;
  }
  return 1;
}

1;
