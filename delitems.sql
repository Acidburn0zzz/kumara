# MySQL dump 7.1
#
# Host: localhost    Database: c4test
#--------------------------------------------------------
# Server version	3.22.32-log

#
# Table structure for table 'deleteditems'
#
CREATE TABLE deleteditems (
  itemnumber int(11) DEFAULT '0' NOT NULL,
  biblionumber int(11) DEFAULT '0' NOT NULL,
  multivolumepart varchar(30),
  biblioitemnumber int(11) DEFAULT '0' NOT NULL,
  barcode varchar(9) DEFAULT '' NOT NULL,
  dateaccessioned date,
  booksellerid varchar(10),
  homebranch varchar(4),
  price decimal(30,6),
  replacementprice decimal(30,6),
  replacementpricedate date,
  datelastborrowed date,
  datelastseen date,
  multivolume tinyint(1),
  stack tinyint(1),
  notforloan tinyint(1),
  itemlost tinyint(1),
  wthdrawn tinyint(1),
  bulk varchar(30),
  issues smallint(6),
  renewals smallint(6),
  reserves smallint(6),
  restricted tinyint(1),
  binding decimal(30,6),
  itemnotes text,
  holdingbranch varchar(4),
  interim tinyint(1),
  timestamp timestamp(14),
  tprice decimal(10,3),
  tprice2 decimal(10,2),
  KEY itembarcodeidx (barcode),
  KEY itembinoidx (biblioitemnumber),
  KEY itembibnoidx (biblionumber),
  PRIMARY KEY (itemnumber),
  UNIQUE barcode (barcode)
);

