
--
-- Table structure for table `expression_data`
--

DROP TABLE IF EXISTS `expression_data`;
CREATE TABLE `expression_data` (
  `expression_data_id` int(10) unsigned NOT NULL auto_increment,
  `chip_annotation_id` int(10) unsigned NOT NULL default '0',
  `tissue_id` int(10) unsigned default NULL,
  `expression_level` float default NULL,
  `platform` varchar(40),
  PRIMARY KEY  (`expression_data_id`),
  KEY `chip_annotation_id` (`chip_annotation_id`),
  KEY `tissue_id` (`tissue_id`),
  KEY `expression_level` (`expression_level`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `chip_annotation`
--

DROP TABLE IF EXISTS `chip_annotation`;
CREATE TABLE `chip_annotation` (
  `chip_annotation_id` int(10) unsigned NOT NULL auto_increment,
  `species` varchar(40) NOT NULL,
  `name` varchar(40) NOT NULL,
  `accession` varchar(40) default NULL,
  `probeset_id` varchar(40) default NULL,
  `reporters` mediumtext,
  `genome_location` mediumtext,
  `LocusLink` mediumtext,
  `RefSeq` mediumtext,
  `UniGene` mediumtext,
  `UniProt` mediumtext,
  `Ensembl` mediumtext,
  `aliases` mediumtext,
  `description` mediumtext NOT NULL,
  `function` mediumtext,
  `protein_families` mediumtext,
  `number` mediumtext,
  PRIMARY KEY  (`chip_annotation_id`),
  KEY `name` (`name`),
  KEY `genome` (`species`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `tissue`
--

DROP TABLE IF EXISTS `tissue`;
CREATE TABLE `tissue` (
  `tissue_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(60) default NULL,
  PRIMARY KEY  (`tissue_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `ap_calls`
--

DROP TABLE IF EXISTS `ap_tissue`;
CREATE TABLE `ap_tissue` (
  `ap_calls_id` int(10) unsigned NOT NULL auto_increment,
  `tissue_id` int(10),
  `chip_annotation_id` int(10),
  `tag` enum('A','P','M'),
  `value` int(10),
  PRIMARY KEY  (`ap_calls_id`),
  KEY  `tissue_id` (`tissue_id`),
  KEY `probe` (`chip_annotation_id`),
  KEY `tag` (`tag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
