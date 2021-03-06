
=pod

=head1 NAME - CogemirTestDB

=head1 SYNOPSIS

    # Add test dir to lib search path
    use lib 't';
    
    use CogemirTestDB;
    
    my $mirna_nameDB_test = CogemirTestDB->new();
    # OR: 
    #   my $mirna_nameDB_test = CogemirTestDB->new({host=>'foo'});
    # OR:
    #   my $mirna_nameDB_test = CogemirTestDB->new('myconf.dat');
    
    # Load some data into the db
    $mirna_nameDB_test->do_sql_file("some_data.sql");
    
    # Get an Cogemir db object for the test db
    my $db = $mirna_nameDB_test->get_DBSQL_Obj;

=head1 DESCRIPTION



=head1 METHODS

=cut

package CogemirTestDB;

use vars qw(@ISA);
use strict;
use lib "$ENV{'HOME'}/src/cogemir/modules";
use Sys::Hostname 'hostname';
use Bio::Cogemir::DBLoader;
use DBI;
use Carp;

#Package variable for unique database name
my $counter=0;

{
    # This is a list of possible entries in the config
    # file "CogemirTestDB.conf" or in the hash being used.
    my %known_field = map {$_, 1} qw(
        driver
        host
        user
        port
        pass
        schema_sql
        module
        );

    ### Firstly, the file CogemirTestDB.conf will be read. If this fails, some
    ### hopefully reasonable defaults are taken. Secondly, if an argument
    ### is given, this will be used to get arguments from. They will
    ### supplement or override those of CogemirTestDB.conf. If the argument
    ### is a filename, that file will be read, and its contents will
    ### override/merge with those of CogemirTestDB.conf. If the argument is a
    ### hash, its contents will likewise override/merge with those read
    ### from CogemirTestDB.conf
    
	sub new {
        my( $pkg, $arg ) = @_;

        $counter++;
        my $conf_file='CogemirTestDB.conf';
        my $fallback_defaults = {
		'user'   => 'root',
		'host'  => 'localhost',
		'driver' => 'mysql',
		'pass'   => undef,
		'port'  => undef,
		'module' => 'Bio::Cogemir::DBSQL::DBAdaptor',
		'schema_sql' => "$ENV{'HOME'}/src/cogemir/sql/cogemir_01_48.sql"
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
	    } else {
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
    my( $self ) = @_;

    $self->{'_dbname'} ||= $self->_create_db_name();
    return $self->{'_dbname'};
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

sub _create_db_name {
    my( $self ) = @_;

    my $host = hostname();
    my $db_name = "_test_cogemir_db_${host}_$$".$counter;
    $db_name =~ s{\W}{_}g;
    return $db_name;
}

sub create_db {
    my( $self ) = @_;
    
    ### FIXME: not portable between different drivers
    my $locator = 'DBI:'. $self->driver .':host='.$self->host;
    my $db = DBI->connect(
        $locator, $self->user, $self->pass, {RaiseError => 1}
        ) or confess "Can't connect to server";
    my $db_name = $self->dbname;
    $db->do("CREATE DATABASE $db_name");
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
            if (    /'[^']*#[^']*'/ 
                 || /'[^']*--[^']*'/ ) {
                     if ( $comment_strip_warned++ ) { 
                         # already warned
                     } else {
                         #warn "#################################\n".
                         #warn "# found comment strings inside quoted string; not stripping, too complicated: $_\n";
                         #warn "# (continuing, assuming all these they are simply valid quoted strings)\n";
                         #warn "#################################\n";
                     }
                 } else {
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
            #print $s, "\n";
           
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


__END__

=head1 AUTHOR

James Gilbert B<email> jgrg@sanger.ac.uk
