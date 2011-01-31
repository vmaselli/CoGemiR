
=pod

=head1 NAME - Bio::LoadDB

=head1 SYNOPSIS

    

=head1 DESCRIPTION



=head1 METHODS

=cut

BEGIN {require "$ENV{'HOME'}/src/cogemir-beta/data/configfile.pl" or die "$!\n"}; #settings

package Bio::LoadDB;

use strict;
use vars qw(@ISA);

use Bio::Root::Root;
use Bio::Root::IO;

@ISA = qw(Bio::Root::Root Bio::Root::IO);

use vars qw(@ISA);
use strict;
use Sys::Hostname 'hostname';
use DBI;
use Carp;
use Data::Dumper;
 
use Bio::Root::Root;
@ISA = qw(Bio::Root::Root );

my $basedir = $::path{'basedir'};

#Package variable for unique database name
my $counter=0;


#constructor
=head2 new

 Title          : new
 Usage          : my $loader =  Bio::Cogemir::MicroRNA->new(   
							    -DBID       => $dbID,
							    -ADAPTOR    => $adaptor,
							    -ATTRIBUTE  => $attribute_obj,
							    -SPECIFIC   => $specific,
							    -SEED       => $seed_obj,
							    -CLUSTER    => $cluster,
							    -HOSTGENE   => $hostgene_obj
							   );
 Returns        : Bio::Cogemir::MicroRNA
 Args           : Takes a set of named arguments
 Exceptions     : none

=cut


sub new{
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	my ($dbID,
		$adaptor,
		$attribute_obj,
		$specific,
		$share,
		$seed_obj,
		$cluster,
		$hostgene_obj
		) = $self->_rearrange([qw(
		DBID               
		ADAPTOR            
		ATTRIBUTE         
		SPECIFIC
		SHARE
		SEED           
		CLUSTER
		HOSTGENE  
		)],@args);
	
	$dbID && $self->dbID($dbID); 
	$adaptor && $self->adaptor($adaptor);
	$attribute_obj && $self->attribute($attribute_obj);
	$specific && $self->specific($specific);
	$share && $self->share($share);
	$seed_obj && $self->seed($seed_obj);
	$cluster && $self->cluster($cluster);
	$hostgene_obj && $self->hostgene($hostgene_obj);



	unless (defined $attribute_obj){
		$self->throw("The MicroRNA does not have all micro_rnas to be created: I need a attribute");
	}


	
	return $self;
}



{
    # This is a list of possible entries in the config
    # file "LoadDB.conf" or in the hash being used.
    my %known_field = map {$_, 1} qw(
        driver
        host
        user
        port
        pass
        schema_sql
        module
        dbname
        );

    ### Firstly, the file config.pl will be read. If this fails, some
    ### hopefully reasonable defaults are taken. Secondly, if an argument
    ### is given, this will be used to get arguments from. They will
    ### supplement or override those of configfile.pl . If the argument
    ### is a filename, that file will be read, and its contents will
    ### override/merge with those of configfile.pl. If the argument is a
    ### hash, its contents will likewise override/merge with those read
    ### from LoadDB.conf
    
	sub new {
        my( $pkg, $arg ) = @_;

        $counter++;
        my $conf_file="$basedir/data/LoadDB.conf";
        my $fallback_defaults = {
		'user'   => 'root',
		'host'  => 'localhost',
		'driver' => 'mysql',
		'pass'   => undef,
		'port'  => undef,
		'module' => 'Bio::Cogemir::DBSQL::DBAdaptor',
		'schema_sql' => "$ENV{'HOME'}/src/cogemir-beta/sql/cogemir_04_52.sql",
		'dbname' => 'cogemir_04_52'
		};

        my $self =undef;
		$self = do $conf_file || $fallback_defaults;
		if ($arg) {
	    	if  (ref $arg eq 'HASH' ) {  # a hash ref
                foreach my $key (keys %$arg) {
		    		$self->{$key} = $arg->{$key};
				}
	    	}
	    	elsif (-f $arg )  { # a file name
				$self = do $arg;
	    	} 
	    	else {
				confess "expected a hash ref or existing file";
	    	}
		}
        
        foreach my $f (keys %$self) {
            confess "Unknown config field: '$f'" unless $known_field{$f};
        }

        bless $self, $pkg;

        $self->create_db;
	
        return $self;
    }
}

sub driver {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'driver'} = $value;
    }
    return $self->{'driver'} || confess "driver not set";
}

sub host {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'host'} = $value;
    }
    return $self->{'host'} || confess "host not set";
}

sub user {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'user'} = $value;
    }
    #print "USER ", $self->{'user'},"\n";
    return $self->{'user'} || confess "user not set";
}

sub port {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'port'} = $value;
    }
    return $self->{'port'};
}

sub pass {
    my( $self, $value ) = @_;
    
    if ($value) {
        $self->{'pass'} = $value;
    }
    
    return $self->{'pass'};
}

sub schema_sql {
    my( $self, $value ) = @_;
    
    if ($value) {
        push(@{$self->{'schema_sql'}}, $value);
    }
    return $self->{'schema_sql'} || confess "schema_sql not set";
}

sub dbname {
    my( $self,$value ) = @_;

   if ($value) {
        $self->{'dbname'} = $value;
    }
    
    return $self->{'dbname'};
}

# convenience method: by calling it, you get the name of the database,
# which  you can cut-n-paste into another window for doing some mysql
# stuff interactively
sub pause {
    my ($self) = @_;
    my $db = $self->{'_dbname'};
    print STDERR "pausing to inspect database; name of database is:  $db\n";
    print STDERR "press ^D to continue\n";
    `cat `;
}

sub module {
    my ($self, $value) = @_;
    $self->{'module'} = $value if ($value);
    return $self->{'module'};
}



sub create_db {
    my( $self ) = @_;
    
    ### FIXME: not portable between different drivers
    my $locator = 'DBI:'. $self->driver .':host='.$self->host;
    my $db = DBI->connect(
        $locator, $self->user, $self->pass, {RaiseError => 1}
        ) or confess "Can't connect to server";
    my $db_name = $self->dbname;
    #$db->do("DROP DATABASE $db_name ");
    $db->do("CREATE DATABASE $db_name");
    $db->do("USE $db_name");
    $db->disconnect;
      
    $self->do_sql_file(@{$self->schema_sql});
}

sub db_handle {
    my( $self ) = @_;
    unless ($self->{'_db_handle'}) {
        $self->{'_db_handle'} = DBI->connect(
            $self->test_locator, $self->user, $self->pass, {RaiseError => 1}
            ) or confess "Can't connect to server";
    }
    return $self->{'_db_handle'};
}

sub test_locator {
    my( $self ) = @_;
    
    my $locator = 'dbi:'. $self->driver .':database='. $self->dbname;
    foreach my $meth (qw{ host port }) {
        if (my $value = $self->$meth()) {
            $locator .= ";$meth=$value";
        }
    }
    #print "LOCATOR $locator\n";
    return $locator;
}

sub mirna_name_db_locator {
    my( $self) = @_;
    
    my $module = ($self->module() || 'Bio::Cogemir::DBSQL::DBAdaptor');
    my $locator = '';
    foreach my $meth (qw{ host port dbname user pass }) {
        my $value = $self->$meth();
	next unless defined $value;
        $locator .= ';' if $locator;
        $locator .= "$meth=$value";
    }
    $locator .= ";perlonlyfeatures=1";
   
    return "$module/$locator";
}

# return the database handle:
sub get_DBAdaptor {
    my( $self ) = @_;
    
    my $locator = $self->mirna_name_db_locator();
    my $db =  Bio::Cogemir::DBLoader->new($locator);
    #$db->gfdb($self->gfdb);
}

sub do_sql_file {
    my( $self, @files ) = @_;
    local *SQL;
    my $i = 0;
    my $dbh = $self->db_handle;

    my $comment_strip_warned=0;

    foreach my $file (@files)
    {
 		
        my $sql = '';
        open SQL, $file or die "Can't read SQL file '$file' : $!";
        while (<SQL>) {
            # careful with stripping out comments; quoted text
            # (e.g. aligments) may contain them. Just warn (once) and ignore
            if (    /'[^']*#[^']*'/ || /'[^']*--[^']*'/ ) {
				if ( $comment_strip_warned++ ) { 
					# already warned
				} 	
				else {
					#warn "#################################\n".
					#warn "# found comment strings inside quoted string; not stripping, too complicated: $_\n";
					#warn "# (continuing, assuming all these they are simply valid quoted strings)\n";
					#warn "#################################\n";
				}
			} 
			else {
				s/(#|--).*//;       # Remove comments
			}
            next unless /\S/;   # Skip lines which are all space
            $sql .= $_;
            $sql .= ' ';
        }
        close SQL;
        
     	
    	
		#Modified split statement, only semicolumns before end of line,
		#so we can have them inside a string in the statement
		#\s*\n, takes in account the case when there is space before the new line
        foreach my $s (grep /\S/, split /;[ \t]*\n/, $sql) {
           
            $self->validate_sql($s);
            $dbh->do($s);
            $i++;
        }
    }
    return $i;
}                                       # do_sql_file

sub validate_sql {
    my ($self, $statement) = @_;
    
    if ($statement =~ /insert\s/i)
    {	#print "statement $statement\n";
        $statement =~ s/\n/ /g; #remove newlines
        
        die ("INSERT should use explicit column names (-c switch in mysqldump)\n$statement\n")
            unless ($statement =~ /insert.+into.*\(.+\).+values.*\(.+\)/i);
    }
}

sub load_file{
	my( $self, @files ) = @_;
    local *SQL;
    my $i = 0;
    my $dbh = $self->db_handle;

    my $comment_strip_warned=0;
	
    foreach my $file (@files){
    		my $input = $dbh->quote($file);
 			$dbh->do("load data infile $input into table ontology");  
    	}
}


sub DESTROY {
    my( $self ) = @_;

    if (my $dbh = $self->db_handle) {
        my $db_name = $self->dbname;
        #$dbh->do("DROP DATABASE $db_name");
        print "$db_name\n";
        $dbh->disconnect;
    }
}


1;
        

