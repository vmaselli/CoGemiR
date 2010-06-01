BEGIN
{
	package main;
	use lib "/home/tigem/maselli/src/cogemir-beta/modules/";
	%lib = (
		#ensembl lib
		'ensembl' => '/home/tigem/maselli/src/ensembl-api/v52/ensembl/modules',
		'compara' => '/home/tigem/maselli/src/ensembl-api/v52/ensembl-compara/modules',
		'cogemir' => '/home/tigem/maselli/src/cogemir-beta/modules/'
	);
	
	%path = (
		'basedir' => "$ENV{'HOME'}/src/cogemir-beta/",
		'datadir' => "$ENV{'HOME'}/Projects/cogemir/data/"
	);
	
	%mysql_settings = (
		# DBD driver to use - mandatory
   	 	'driver'        => 'mysql',
		# machine to connect to - mandatory
		'host'			 => 'biodb.tigem.it',	
		#'host'			 => 'localhost',
		'user'           => 'mysql_dev',
		#'user'           => 'root',
		# port the server is running on - optional
		'port'          => undef,
		# Password if needed
		'pass'       => 'dEvEl0pEr',
		#'pass'       => undef,
		# DB name
		'dbname' => 'cogemir_04_52',
		# File containing the datbase schema in SQL format - mandatory
		'schema_sql'    => "$ENV{'HOME'}/src/cogemir-beta/sql/cogemir_04_52.sql",
		# module
		'module' =>'Bio::Cogemir::DBSQL::DBConnection'
	);
}
1;
