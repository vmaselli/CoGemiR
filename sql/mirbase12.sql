-- MySQL dump 10.11
--
-- Host: pfamdb1    Database: mirna_12_0
-- ------------------------------------------------------
-- Server version	5.0.27-standard-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `dead_mirna`
--

DROP TABLE IF EXISTS `dead_mirna`;
CREATE TABLE `dead_mirna` (
  `mirna_acc` varchar(9) NOT NULL default '',
  `mirna_id` varchar(40) NOT NULL default '',
  `previous_id` varchar(100) default NULL,
  `forward_to` varchar(20) default NULL,
  `comment` mediumtext
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `literature_references`
--

DROP TABLE IF EXISTS `literature_references`;
CREATE TABLE `literature_references` (
  `auto_lit` int(10) unsigned NOT NULL auto_increment,
  `medline` int(10) unsigned default NULL,
  `title` tinytext,
  `author` tinytext,
  `journal` tinytext,
  PRIMARY KEY  (`auto_lit`),
  FULLTEXT KEY `text_index` (`title`,`author`)
) ENGINE=MyISAM AUTO_INCREMENT=792 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna`
--

DROP TABLE IF EXISTS `mirna`;
CREATE TABLE `mirna` (
  `auto_mirna` int(10) unsigned NOT NULL auto_increment,
  `mirna_acc` varchar(9) NOT NULL default '',
  `mirna_id` varchar(40) NOT NULL default '',
  `description` varchar(100) default NULL,
  `sequence` blob,
  `comment` longtext,
  `auto_species` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`auto_mirna`),
  UNIQUE KEY `mirna_acc` (`mirna_acc`),
  FULLTEXT KEY `comment_index` (`comment`),
  FULLTEXT KEY `description_index` (`description`)
) ENGINE=MyISAM AUTO_INCREMENT=30066 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_2_prefam`
--

DROP TABLE IF EXISTS `mirna_2_prefam`;
CREATE TABLE `mirna_2_prefam` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `auto_prefam` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`auto_mirna`,`auto_prefam`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_chromosome_build`
--

DROP TABLE IF EXISTS `mirna_chromosome_build`;
CREATE TABLE `mirna_chromosome_build` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `xsome` varchar(20) default NULL,
  `contig_start` bigint(20) default NULL,
  `contig_end` bigint(20) default NULL,
  `strand` char(2) default NULL,
  KEY `auto_mirna` (`auto_mirna`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_context`
--

DROP TABLE IF EXISTS `mirna_context`;
CREATE TABLE `mirna_context` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `transcript_id` varchar(50) default NULL,
  `overlap_sense` char(2) default NULL,
  `overlap_type` varchar(20) default NULL,
  `number` int(4) default NULL,
  `transcript_source` varchar(50) default NULL,
  `transcript_name` varchar(50) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_database_links`
--

DROP TABLE IF EXISTS `mirna_database_links`;
CREATE TABLE `mirna_database_links` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `db_id` tinytext NOT NULL,
  `comment` tinytext,
  `db_link` tinytext NOT NULL,
  `db_secondary` tinytext,
  `other_params` tinytext,
  KEY `auto_rfam` (`auto_mirna`),
  KEY `auto_mirna` (`auto_mirna`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_literature_references`
--

DROP TABLE IF EXISTS `mirna_literature_references`;
CREATE TABLE `mirna_literature_references` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `auto_lit` int(10) unsigned NOT NULL default '0',
  `comment` mediumtext,
  `order_added` tinyint(4) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_mature`
--

DROP TABLE IF EXISTS `mirna_mature`;
CREATE TABLE `mirna_mature` (
  `auto_mature` int(10) unsigned NOT NULL auto_increment,
  `mature_name` varchar(40) NOT NULL default '',
  `mature_acc` varchar(20) NOT NULL default '',
  `mature_from` varchar(4) default NULL,
  `mature_to` varchar(4) default NULL,
  `evidence` mediumtext,
  `experiment` mediumtext,
  `similarity` mediumtext,
  PRIMARY KEY  (`auto_mature`)
) ENGINE=MyISAM AUTO_INCREMENT=34432 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_pre_mature`
--

DROP TABLE IF EXISTS `mirna_pre_mature`;
CREATE TABLE `mirna_pre_mature` (
  `auto_mirna` int(10) unsigned NOT NULL default '0',
  `auto_mature` int(10) unsigned NOT NULL default '0',
  KEY `auto_mirna` (`auto_mirna`),
  KEY `auto_mature` (`auto_mature`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_prefam`
--

DROP TABLE IF EXISTS `mirna_prefam`;
CREATE TABLE `mirna_prefam` (
  `auto_prefam` int(10) NOT NULL auto_increment,
  `prefam_acc` varchar(15) NOT NULL default '',
  `prefam_id` varchar(40) NOT NULL default '',
  `description` text,
  PRIMARY KEY  (`auto_prefam`),
  UNIQUE KEY `prefam_acc` (`prefam_acc`),
  UNIQUE KEY `prefam_id` (`prefam_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2509 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_species`
--

DROP TABLE IF EXISTS `mirna_species`;
CREATE TABLE `mirna_species` (
  `auto_id` bigint(20) NOT NULL default '0',
  `organism` varchar(10) default NULL,
  `division` varchar(10) default NULL,
  `name` varchar(100) default NULL,
  `taxonomy` varchar(200) default NULL,
  `genome_assembly` varchar(15) default NULL,
  `ensembl_db` varchar(50) default NULL,
  PRIMARY KEY  (`auto_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_target_links`
--

DROP TABLE IF EXISTS `mirna_target_links`;
CREATE TABLE `mirna_target_links` (
  `auto_mature` int(10) unsigned NOT NULL default '0',
  `auto_db` int(10) unsigned NOT NULL default '0',
  `display_name` tinytext NOT NULL,
  `field1` tinytext,
  `field2` tinytext
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `mirna_target_url`
--

DROP TABLE IF EXISTS `mirna_target_url`;
CREATE TABLE `mirna_target_url` (
  `auto_db` int(10) unsigned NOT NULL auto_increment,
  `display_name` tinytext NOT NULL,
  `url` tinytext NOT NULL,
  PRIMARY KEY  (`auto_db`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-09-01 11:35:42
