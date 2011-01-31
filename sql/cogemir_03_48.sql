-- MySQL dump 10.9
--
-- Host: localhost    Database: cogemir_01_48
-- ------------------------------------------------------
-- Server version	4.1.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES latin1 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aliases`
--

DROP TABLE IF EXISTS `aliases`;
CREATE TABLE `aliases` (
  `aliases_id` int(10) unsigned NOT NULL auto_increment,
  `RefSeq_dna` varchar(40) ,
  `GeneSymbol` varchar(40) ,
  `RefSeq_dna_predicted` varchar(40) ,
  `UniGene` varchar(40) ,
  `UCSC` varchar(40) ,
  PRIMARY KEY  (`aliases_id`),
  KEY `RefSeq` (`RefSeq_dna`),
  KEY `GeneSymbol` (`GeneSymbol`),
  KEY `Unigene` (`Unigene`),
  KEY `UCSC` (`UCSC`),
  KEY `RefSeqP` (`RefSeq_dna_predicted`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `analysis`
--

DROP TABLE IF EXISTS `analysis`;
CREATE TABLE `analysis` (
  `analysis_id` int(10) unsigned NOT NULL auto_increment,
  `created` varchar(40) NOT NULL default '',
  `logic_name_id` int(10) NOT NULL default '0',
  `parameters` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`analysis_id`),
  KEY `logic_name_id` (`logic_name_id`) 
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `attribute`
--

DROP TABLE IF EXISTS `attribute`;
CREATE TABLE `attribute` (
  `attribute_id` int(10) unsigned NOT NULL auto_increment,
  `genome_db_id` int(10) unsigned NOT NULL default '0',
  `seq_id` int(10) unsigned NOT NULL default '0',
  `location_id` int(10) unsigned default '0',
  `mirna_name_id` int(10) unsigned NOT NULL default '0',
  `analysis_id` int(10) unsigned default NULL,
  `status` enum('KNOWN','NOVEL','PUTATIVE','PREDICTED','KNOWN_BY_PROJECTION','UNKNOWN','ANNOTATED','E PREDICTION','LC PREDICTION','HC PREDICTION') default NULL,
  `gene_name` varchar(40) NOT NULL default '',
  `stable_id` varchar(40) default NULL,
  `external_name` varchar(40) default NULL,
  `db_link` varchar(40) default NULL,
  `db_accession` varchar(40) default NULL,
  `aliases_id` int(10),
  
  PRIMARY KEY  (`attribute_id`),
  KEY `genome` (`genome_db_id`),
  KEY `mirna_name_id` (`mirna_name_id`),
  KEY `analysis_id` (`analysis_id`),
  KEY `sequence` (`seq_id`),
  KEY `location_id` (`location_id`),
  KEY `status` (`status`),
  KEY `gene_name` (`gene_name`),
  KEY `stable_id` (`stable_id`),
  KEY `external_name` (`external_name`),
  KEY `db_link` (`db_link`), 
  KEY `db_accession` (`db_accession`),
  KEY `aliases` (`aliases_id`),
  UNIQUE KEY `member` (`gene_name`,`stable_id`,`location_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `blast`
--

DROP TABLE IF EXISTS `blast`;
CREATE TABLE `blast` (
  `blast_id` int(10) unsigned NOT NULL auto_increment,
  `feature_id` int(10) NOT NULL default '0',
  `logic_name_id` int(10) default NULL,
  `length` int(10) NOT NULL default '0',
  PRIMARY KEY  (`blast_id`),
  KEY `feature_id` (`feature_id`),
  KEY `logic_name_id` (`logic_name_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `cluster`
--

DROP TABLE IF EXISTS `cluster`;
CREATE TABLE `cluster` (
  `cluster_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `analysis_id` int(11) default NULL,
  PRIMARY KEY  (`cluster_id`),
  UNIQUE KEY `name` (`name`),
  KEY `analysis_id` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `direction`
--

DROP TABLE IF EXISTS `direction`;
CREATE TABLE `direction` (
  `micro_rna_id` int(11) NOT NULL default '0',
  `direction` enum('sense','antisense') default NULL,
  `gene_id` int(11) default NULL,
  KEY `micro_rna` (`micro_rna_id`),
  KEY `direction` (`direction`),
  KEY `gene` (`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `exon`
--

DROP TABLE IF EXISTS `exon`;
CREATE TABLE `exon` (
  `exon_id` int(10) unsigned NOT NULL auto_increment,
  `rank` int(10) unsigned NOT NULL default '0',
  `phase` enum('0','1','2','-1') default NULL,
  `pre_intron_id` int(10) unsigned default NULL,
  `post_intron_id` int(10) unsigned default NULL,
  `length` int(10) unsigned default NULL,
  `part_of` int(10) unsigned NOT NULL default '0',
  `attribute_id` int(10),
  `type` varchar(40),
  PRIMARY KEY  (`exon_id`),
  KEY `attribute` (`attribute_id`),
  KEY `part_of` (`part_of`),
  KEY `exon_phase` (`phase`),
  KEY `pre_intron_id` (`pre_intron_id`),
  KEY `post_intron_id` (`post_intron_id`),
  KEY `exon_rank` (`rank`),
  KEY `length` (`length`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `expression`
--

DROP TABLE IF EXISTS `expression`;
CREATE TABLE `expression` (
  `external_id` int(10) unsigned NOT NULL default '0',
  `tissue_id` int(10) unsigned default NULL,
  `expression_level` float default NULL,
  `platform` varchar(40),
  KEY `external_id` (`external_id`),
  KEY `tissue_id` (`tissue_id`),
  KEY `expression_level` (`expression_level`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `expression_statistics`
--

DROP TABLE IF EXISTS `expression_statistics`;
CREATE TABLE `expression_statistics` (
  `symatlas_annotation_id` int(11) default NULL,
  `average` float default NULL,
  `standard_deviation` float default NULL,
  `gene_id` int(11) default NULL,
  `platform` varchar(40),
  KEY `expression_id` (`symatlas_annotation_id`),
  KEY `media` (`average`),
  KEY `standard_deviation` (`standard_deviation`),
  KEY `gene_id` (`gene_id`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `external_database`
--

DROP TABLE IF EXISTS `external_database`;
CREATE TABLE `external_database` (
  `external_database_id` int(10) unsigned NOT NULL auto_increment,
  `micro_rna_id` int(10),
  `database_name` varchar(40),
  `accession_number` varchar(40),
  `display` varchar(40),
  KEY (`external_database_id`),
  KEY `micro_rna_id` (`micro_rna_id`),
  KEY `accession_number` (`accession_number`),
  KEY `display` (`display`),
  KEY `dbname`(`database_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;






--
-- Table structure for table `feature`
--

DROP TABLE IF EXISTS `feature`;
CREATE TABLE `feature` (
  `feature_id` int(10) unsigned NOT NULL auto_increment,
  `logic_name_id` int(10) NOT NULL default '',
  `description` varchar(255) default NULL,
  `note` text,
  `distance_from_upstream_gene` int(10) default '0',
  `closest_upstream_gene` varchar(40) default '',
  `distance_from_downstream_gene` int(10) default '0',
  `closest_downstream_gene` varchar(40) default '',
  `analysis_id` int(10) default NULL,
  PRIMARY KEY  (`feature_id`),
  KEY `logic_name` (`logic_name_id`),
  KEY `descr` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `gene`
--

DROP TABLE IF EXISTS `gene`;
CREATE TABLE `gene` (
  `gene_id` int(10) unsigned NOT NULL auto_increment,
  `attribute_id` int(10) unsigned NOT NULL default '0',
  `biotype` varchar(40) default NULL,
  `label` enum('host','target') default NULL,
  `conservation_score` varchar(255),
  PRIMARY KEY  (`gene_id`),
  UNIQUE KEY `attribute` (`attribute_id`),
  KEY `attribute_id` (`attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `gene_feature`
--

DROP TABLE IF EXISTS `gene_feature`;
CREATE TABLE `gene_feature` (
  `feature_id` int(10) unsigned NOT NULL default '0',
  `gene_id` int(10) unsigned NOT NULL default '0',
  KEY `feature` (`feature_id`),
  KEY `gene` (`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `genome_db`
--

DROP TABLE IF EXISTS `genome_db`;
CREATE TABLE `genome_db` (
  `genome_db_id` int(10) NOT NULL auto_increment,
  `taxon_id` int(10) default NULL,
  `organism` varchar(40) NOT NULL default '',
  `db_host` varchar(255) NOT NULL default '',
  `db_name` varchar(255) NOT NULL default '',
  `db_type` varchar(40) NOT NULL default '',
  `common_name` varchar(100),
  `taxa` enum('Primates','Rodentia','Mammalia','Marsupials','Aves','Amphibia','Pisces','Tunicates','Arthropoda','Nematoda','Yeast') default NULL,
  PRIMARY KEY  (`genome_db_id`),
  KEY `db_host` (`db_host`),
  KEY `db_name` (`db_name`),
  KEY `db_type` (`db_type`),
  KEY `organism` (`organism`),
  KEY `group` (`taxa`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `hit`
--

DROP TABLE IF EXISTS `hit`;
CREATE TABLE `hit` (
  `hit_id` int(11) NOT NULL auto_increment,
  `blast_id` int(10) NOT NULL default '0',
  `feature_id` int(10) NOT NULL default '0',
  PRIMARY KEY  (`hit_id`),
  KEY `blast_id` (`blast_id`),
  KEY `feature_id` (`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `homologs`
--

DROP TABLE IF EXISTS `homologs`;
CREATE TABLE `homologs` (
  `homologs_id` int(11) NOT NULL auto_increment,
  `query_gene_id` int(11) NOT NULL default '0',
  `target_gene_id` int(11) NOT NULL default '0',
  `type` varchar(40) default '',
  `analysis_id` int(11) default NULL,
  PRIMARY KEY  (`homologs_id`),
  KEY `q` (`query_gene_id`),
  KEY `t` (`target_gene_id`),
  KEY `analysis_id` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `hsp`
--

DROP TABLE IF EXISTS `hsp`;
CREATE TABLE `hsp` (
  `hsp_id` int(11) NOT NULL auto_increment,
  `hit_id` int(11) NOT NULL default '0',
  `percent_identity` float NOT NULL default '0',
  `length` int(11) NOT NULL default '0',
  `p_value` float NOT NULL default '0',
  `e_value` float NOT NULL default '0',
  `frame` int(11) default NULL,
  `seq_id` int(10) NOT NULL default '',
  `start` int(11) NOT NULL default '0',
  `end` int(11) NOT NULL default '0',
  PRIMARY KEY  (`hsp_id`),
  UNIQUE KEY `map_id` (`hit_id`,`start`,`end`),
  KEY `hit_id` (`hit_id`),
  KEY `percent_identity` (`percent_identity`),
  KEY `length` (`length`),
  KEY `p_value` (`p_value`),
  KEY `frame` (`frame`),
  KEY `start` (`start`),
  KEY `end` (`end`),
  KEY `seq` (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `intron`
--

DROP TABLE IF EXISTS `intron`;
CREATE TABLE `intron` (
  `intron_id` int(10) unsigned NOT NULL auto_increment,
  `length` int(10) default NULL,
  `part_of` int(10) unsigned NOT NULL default '0',
  `attribute_id` int(10) unsigned NOT NULL,
  `pre_exon_id` varchar(40) default NULL,
  `post_exon_id` varchar(40) default NULL,
  PRIMARY KEY  (`intron_id`),
  UNIQUE KEY `position` (`pre_exon_id`,`post_exon_id`,`part_of`,`length`),
  KEY `part_of` (`part_of`),
  KEY `pre_exon_id` (`pre_exon_id`),
  KEY `post_exon_id` (`post_exon_id`),
  KEY `attribute_id` (`attribute_id`)
  ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `localization`
--

DROP TABLE IF EXISTS `localization`;
CREATE TABLE `localization` (
  `localization_id` int(11) unsigned NOT NULL auto_increment,
  `label` enum('intron','exon','exon_left','exon_right','over exon','out of transcript','intergenic','UTR','UTR_left','UTR_right','over UTR','undef') default NULL,
  `module_rank` int(10) unsigned default '0',
  `transcript_id` int(10) unsigned default NULL,
  `offset` int(10)  default '0',
  `micro_rna_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`localization_id`),
  KEY `offset` (`offset`),
  KEY `label` (`label`),
  KEY `micro_rna_id` (`micro_rna_id`),
  KEY `module_rank` (`module_rank`),
  KEY `transcript_id` (`transcript_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `location_id` int(10) unsigned NOT NULL auto_increment,
  `CoordSystem` varchar(40) default NULL,
  `name` varchar(40) default NULL,
  `start` int(10) unsigned default NULL,
  `end` int(10) unsigned default NULL,
  `strand` int(10) default NULL,
  PRIMARY KEY  (`location_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `logic_name`
--

DROP TABLE IF EXISTS `logic_name`;
CREATE TABLE `logic_name` (
  `logic_name_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`logic_name_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `micro_rna`
--

DROP TABLE IF EXISTS `micro_rna`;
CREATE TABLE `micro_rna` (
  `micro_rna_id` int(10) unsigned NOT NULL auto_increment,
  `attribute_id` int(10) unsigned NOT NULL default '0',
  `seed` varchar(10) default NULL,
  `hostgene_id` int(10) unsigned default NULL,
  `mature_seq_id` int(10) unsigned default '0',
  `cluster_id` int(10) unsigned default '0',
  `specific` enum('yes','no') default NULL,
  `share` enum('yes','no') default NULL,
  PRIMARY KEY  (`micro_rna_id`),
  UNIQUE KEY `attribute` (`attribute_id`),
  KEY `hostgene_id` (`hostgene_id`),
  KEY `attribute_id` (`attribute_id`),
  KEY `seed_id` (`seed`),
  KEY `mature_seq_id` (`mature_seq_id`),
  KEY `cluster_id` (`cluster_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `micro_rna_feature`
--

DROP TABLE IF EXISTS `micro_rna_feature`;
CREATE TABLE `micro_rna_feature` (
  `feature_id` int(10) unsigned NOT NULL default '0',
  `micro_rna_id` int(10) unsigned NOT NULL default '0',
  KEY `feature` (`feature_id`),
  KEY `micro_rna` (`micro_rna_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `micro_rna_tissue`
--

DROP TABLE IF EXISTS `micro_rna_tissue`;
CREATE TABLE `micro_rna_tissue` (
  `micro_rna_id` int(11) default NULL,
  `probset` varchar(40) default NULL,
  `tissue_name` varchar(40) default NULL,
  `expression_level` float default NULL,
  `platform` varchar(40),
  KEY `micro_rna_id` (`micro_rna_id`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `micro_rna_target`
--

DROP TABLE IF EXISTS `micro_rna_target`;
CREATE TABLE `micro_rna_target` (
  `gene_id` int(10) unsigned NOT NULL default '0',
  `micro_rna_id` int(10) unsigned NOT NULL default '0',
  KEY `target` (`gene_id`),
  KEY `micro_rna` (`micro_rna_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_name`
--

DROP TABLE IF EXISTS `mirna_name`;
CREATE TABLE `mirna_name` (
  `mirna_name_id` int(11) NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  `family_name` varchar(40) default '',
  `analysis_id` int(11) default NULL,
  `exon_conservation` enum('0','1','2') default NULL,
  `description` mediumtext,
  `hostgene_conservation` enum('total','partial','none','unique') default NULL,
  PRIMARY KEY  (`mirna_name_id`),
  UNIQUE KEY `name` (`name`),
  KEY `family_name` (`family_name`),
  KEY `analysis_id` (`analysis_id`),
  KEY `exon` (`exon_conservation`),
  KEY `hostgene` (`hostgene_conservation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `paralogs`
--

DROP TABLE IF EXISTS `paralogs`;
CREATE TABLE `paralogs` (
  `paralogs_id` int(11) NOT NULL auto_increment,
  `query_microrna_id` int(11) NOT NULL default '0',
  `target_microrna_id` int(11) NOT NULL default '0',
  `type` varchar(40) default '',
  `analysis_id` int(11) default NULL,
  PRIMARY KEY  (`paralogs_id`),
  KEY `q` (`query_microrna_id`),
  KEY `t` (`target_microrna_id`),
  KEY `analysis_id` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `seq`
--

DROP TABLE IF EXISTS `seq`;
CREATE TABLE `seq` (
  `seq_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL default '',
  `sequence` longtext NOT NULL,
  `logic_name_id` int(10) NOT NULL default '0',
  PRIMARY KEY  (`seq_id`),
  UNIQUE KEY `seqname` (`name`,`logic_name_id`),
  KEY `logic_name_id` (`logic_name_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `symatlas_annotation`
--

DROP TABLE IF EXISTS `symatlas_annotation`;
CREATE TABLE `symatlas_annotation` (
  `symatlas_annotation_id` int(10) unsigned NOT NULL auto_increment,
  `genome_db_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(40) default NULL,
  `accession` varchar(40) default NULL,
  `probset_id` varchar(40) default NULL,
  `reporters` mediumtext,
  `LocusLink` mediumtext,
  `RefSeq` mediumtext,
  `UniGene` mediumtext,
  `UniProt` mediumtext,
  `Ensembl` mediumtext NOT NULL,
  `aliases` mediumtext,
  `description` mediumtext,
  `function` mediumtext,
  `protein_families` mediumtext,
  PRIMARY KEY  (`symatlas_annotation_id`),
  KEY `name` (`name`),
  KEY `genome` (`genome_db_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `symatlas_annotation_gene`
--

DROP TABLE IF EXISTS `symatlas_annotation_gene`;
CREATE TABLE `symatlas_annotation_gene` (
  `symatlas_annotation_id` int(10) unsigned NOT NULL default '0',
  `gene_id` int(10) unsigned default NULL,
  KEY `symatlas_annotation_id` (`symatlas_annotation_id`),
  KEY `gene_id` (`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `tissue`
--

DROP TABLE IF EXISTS `tissue`;
CREATE TABLE `tissue` (
  `tissue_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) default NULL,
  PRIMARY KEY  (`tissue_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `ap_tissue`
--

DROP TABLE IF EXISTS `ap_tissue`;
CREATE TABLE `ap_tissue` (
  `tissue_id` int(10) unsigned NOT NULL auto_increment,
  `symatlas_annotation_id` int(10),
  `tag` enum('A','P','M'),
  KEY  `tissue_id` (`tissue_id`),
  KEY `probe` (`symatlas_annotation_id`),
  KEY `tag` (`tag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `transcript`
--

DROP TABLE IF EXISTS `transcript`;
CREATE TABLE `transcript` (
  `transcript_id` int(10) unsigned NOT NULL auto_increment,
  `attribute_id` int(10) default NULL,
  `part_of` int(10) NOT NULL default '0',
  PRIMARY KEY  (`transcript_id`),
  KEY `part_of` (`part_of`),
  KEY `attribute_id` (`attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

