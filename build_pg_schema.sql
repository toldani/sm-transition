-- MySQL dump 10.13  Distrib 5.1.73, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: science_xmb1
-- ------------------------------------------------------
-- Server version	5.1.73-0ubuntu0.10.04.1
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,POSTGRESQL' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- CREATE TYPE notify_type AS ENUM ('off','u2u','email');

-- CREATE TYPE message_type AS ENUM ('incoming','outgoing','draft');

--
-- Table structure for table "xmb_attachments"
--

DROP TABLE IF EXISTS "xmb_attachments";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE xmb_attachments (
  "aid" integer,
  "pid" INTEGER NOT NULL DEFAULT 0,
  "filename" varchar(120),
  "filetype" varchar(120),
  "filesize" varchar(120),
  "attachment" bytea,
  "downloads" INTEGER NOT NULL DEFAULT 0,
  "img_size" varchar(9),
  "parentid" INTEGER NOT NULL DEFAULT 0,
  "subdir" varchar(15),
  "uid" INTEGER NOT NULL DEFAULT 0,
  "updatetime" timestamp NOT NULL DEFAULT now()
);

/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_banned"
--

DROP TABLE IF EXISTS "xmb_banned";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_banned" (
  "ip1" integer NOT NULL DEFAULT 0,
  "ip2" integer NOT NULL DEFAULT 0,
  "ip3" integer NOT NULL DEFAULT 0,
  "ip4" integer NOT NULL DEFAULT 0,
  "dateline" INTEGER NOT NULL DEFAULT 0,
  "id" integer NOT NULL
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_buddys"
--

DROP TABLE IF EXISTS "xmb_buddys";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_buddys" (
  "username" varchar(32),
  "buddyname" varchar(32)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_captchaimages"
--

DROP TABLE IF EXISTS "xmb_captchaimages";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_captchaimages" (
  "imagehash" varchar(32),
  "imagestring" varchar(12),
  "dateline" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_favorites"
--

DROP TABLE IF EXISTS "xmb_favorites";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_favorites" (
  "tid" INTEGER NOT NULL DEFAULT 0,
  "username" varchar(32),
  "type" varchar(32)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_forums"
--

DROP TABLE IF EXISTS "xmb_forums";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_forums" (
  "type" varchar(15),
  "fid" integer NOT NULL,
  "name" varchar(128),
  "status" varchar(15),
  "lastpost" varchar(54),
  "moderator" varchar(100),
  "displayorder" INTEGER NOT NULL DEFAULT 0,
  "description" text,
  "allowhtml" char(3),
  "allowsmilies" char(3),
  "allowbbcode" char(3),
  "userlist" text NOT NULL,
  "theme" INTEGER NOT NULL DEFAULT 0,
  "posts" INTEGER NOT NULL DEFAULT 0,
  "threads" INTEGER NOT NULL DEFAULT 0,
  "fup" INTEGER NOT NULL DEFAULT 0,
  "postperm" varchar(11) NOT NULL DEFAULT '0,0,0,0',
  "allowimgcode" char(3),
  "attachstatus" varchar(15),
  "password" varchar(32)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_lang_base"
--

DROP TABLE IF EXISTS "xmb_lang_base";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_lang_base" (
  "langid" integer NOT NULL,
  "devname" varchar(20)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_lang_keys"
--

DROP TABLE IF EXISTS "xmb_lang_keys";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_lang_keys" (
  "phraseid" integer NOT NULL,
  "langkey" varchar(30)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_lang_text"
--

DROP TABLE IF EXISTS "xmb_lang_text";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_lang_text" (
  "langid" INTEGER NOT NULL DEFAULT 0,
  "phraseid" INTEGER NOT NULL DEFAULT 0,
  "cdata" bytea NOT NULL,
  CONSTRAINT lang_phrase_key PRIMARY KEY ("langid","phraseid")
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_logs"
--

DROP TABLE IF EXISTS "xmb_logs";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_logs" (
  "username" varchar(32),
  "action" varchar(64),
  "fid" INTEGER NOT NULL DEFAULT 0,
  "tid" INTEGER NOT NULL DEFAULT 0,
  "date" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_members"
--

DROP TABLE IF EXISTS "xmb_members";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_members" (
  "uid" integer NOT NULL,
  "username" varchar(32),
  "password" varchar(32),
  "regdate" INTEGER NOT NULL DEFAULT 0,
  "postnum" INTEGER NOT NULL DEFAULT 0,
  "email" varchar(60),
  "site" varchar(75),
  "aim" varchar(40),
  "status" varchar(35),
  "location" varchar(50),
  "bio" text NOT NULL,
  "sig" text NOT NULL,
  "showemail" varchar(15),
  "timeoffset" numeric NOT NULL DEFAULT '0.00',
  "icq" varchar(30),
  "avatar" varchar(120) DEFAULT NULL,
  "yahoo" varchar(40),
  "customstatus" varchar(250),
  "theme" INTEGER NOT NULL DEFAULT 0,
  "bday" varchar(10) NOT NULL DEFAULT '0000-00-00',
  "langfile" varchar(40),
  "tpp" INTEGER NOT NULL DEFAULT 0,
  "ppp" INTEGER NOT NULL DEFAULT 0,
  "newsletter" char(3),
  "regip" varchar(15),
  "timeformat" INTEGER NOT NULL DEFAULT 0,
  "msn" varchar(40),
  "ban" varchar(15) NOT NULL DEFAULT '0',
  "dateformat" varchar(10),
  "ignoreu2u" text NOT NULL,
  "lastvisit" INTEGER NOT NULL DEFAULT 0,
  "mood" varchar(128) NOT NULL DEFAULT 'Not Set',
  "pwdate" INTEGER NOT NULL DEFAULT 0,
  "invisible" integer DEFAULT 0,
  "u2ufolders" text NOT NULL,
  "saveogu2u" char(3),
  "emailonu2u" char(3),
  "useoldu2u" char(3),
  "u2ualert" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_posts"
--

DROP TABLE IF EXISTS "xmb_posts";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_posts" (
  "fid" INTEGER NOT NULL DEFAULT 0,
  "tid" INTEGER NOT NULL DEFAULT 0,
  "pid" integer NOT NULL,
  "author" varchar(32),
  "message" text NOT NULL,
  "subject" text NOT NULL,
  "dateline" INTEGER NOT NULL DEFAULT 0,
  "icon" varchar(50) DEFAULT NULL,
  "usesig" varchar(15),
  "useip" varchar(15),
  "bbcodeoff" varchar(15),
  "smileyoff" varchar(15)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_ranks"
--

DROP TABLE IF EXISTS "xmb_ranks";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_ranks" (
  "title" varchar(100),
  "posts" integer DEFAULT '0',
  "id" integer NOT NULL,
  "stars" INTEGER NOT NULL DEFAULT 0,
  "allowavatars" char(3),
  "avatarrank" varchar(90) DEFAULT NULL
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_restricted"
--

DROP TABLE IF EXISTS "xmb_restricted";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_restricted" (
  "name" varchar(32),
  "id" integer NOT NULL,
  "case_sensitivity" integer DEFAULT 1,
  "partial" integer DEFAULT 1
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_settings"
--

DROP TABLE IF EXISTS "xmb_settings";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_settings" (
  "langfile" varchar(34) NOT NULL DEFAULT 'English',
  "bbname" varchar(32) NOT NULL DEFAULT 'Your Forums',
  "postperpage" integer NOT NULL DEFAULT '25',
  "topicperpage" integer NOT NULL DEFAULT '30',
  "hottopic" integer NOT NULL DEFAULT '20',
  "theme" integer NOT NULL DEFAULT '1',
  "bbstatus" char(3) NOT NULL DEFAULT 'on',
  "whosonlinestatus" char(3) NOT NULL DEFAULT 'on',
  "regstatus" char(3) NOT NULL DEFAULT 'on',
  "bboffreason" text NOT NULL,
  "regviewonly" char(3) NOT NULL DEFAULT 'off',
  "floodctrl" integer NOT NULL DEFAULT '5',
  "memberperpage" integer NOT NULL DEFAULT '45',
  "catsonly" char(3) NOT NULL DEFAULT 'off',
  "hideprivate" char(3) NOT NULL DEFAULT 'on',
  "emailcheck" char(3) NOT NULL DEFAULT 'off',
  "bbrules" char(3) NOT NULL DEFAULT 'off',
  "bbrulestxt" text NOT NULL,
  "searchstatus" char(3) NOT NULL DEFAULT 'on',
  "faqstatus" char(3) NOT NULL DEFAULT 'on',
  "memliststatus" char(3) NOT NULL DEFAULT 'on',
  "sitename" varchar(50) NOT NULL DEFAULT 'YourDomain.com',
  "siteurl" varchar(60),
  "avastatus" varchar(4) NOT NULL DEFAULT 'on',
  "u2uquota" integer NOT NULL DEFAULT '600',
  "gzipcompress" varchar(30) NOT NULL DEFAULT 'on',
  "coppa" char(3) NOT NULL DEFAULT 'off',
  "timeformat" integer NOT NULL DEFAULT '12',
  "adminemail" varchar(60) NOT NULL DEFAULT 'webmaster@domain.ext',
  "dateformat" varchar(10) NOT NULL DEFAULT 'dd-mm-yyyy',
  "sigbbcode" char(3) NOT NULL DEFAULT 'on',
  "sightml" char(3) NOT NULL DEFAULT 'off',
  "reportpost" char(3) NOT NULL DEFAULT 'on',
  "bbinsert" char(3) NOT NULL DEFAULT 'on',
  "smileyinsert" char(3) NOT NULL DEFAULT 'on',
  "doublee" char(3) NOT NULL DEFAULT 'off',
  "smtotal" varchar(15) NOT NULL DEFAULT '16',
  "smcols" varchar(15) NOT NULL DEFAULT '4',
  "editedby" char(3) NOT NULL DEFAULT 'off',
  "dotfolders" char(3) NOT NULL DEFAULT 'on',
  "attachimgpost" char(3) NOT NULL DEFAULT 'on',
  "todaysposts" char(3) NOT NULL DEFAULT 'on',
  "stats" char(3) NOT NULL DEFAULT 'on',
  "authorstatus" char(3) NOT NULL DEFAULT 'on',
  "tickerstatus" char(3) NOT NULL DEFAULT 'on',
  "tickercontents" text NOT NULL,
  "tickerdelay" integer NOT NULL DEFAULT '4000',
  "addtime" numeric NOT NULL DEFAULT '0.00',
  "max_avatar_size" varchar(9) NOT NULL DEFAULT '100x100',
  "footer_options" varchar(45) NOT NULL DEFAULT 'queries-phpsql-loadtimes-totaltime',
  "space_cats" char(3) NOT NULL DEFAULT 'no',
  "spellcheck" char(3) NOT NULL DEFAULT 'off',
  "allowrankedit" char(3) NOT NULL DEFAULT 'on',
  "notifyonreg" notify_type NOT NULL DEFAULT 'off',
  "subject_in_title" char(3) NOT NULL DEFAULT 'off',
  "def_tz" numeric NOT NULL DEFAULT '0.00',
  "indexshowbar" integer NOT NULL DEFAULT '2',
  "resetsigs" char(3) NOT NULL DEFAULT 'off',
  "pruneusers" INTEGER NOT NULL DEFAULT 0,
  "ipreg" char(3) NOT NULL DEFAULT 'on',
  "maxdayreg" integer NOT NULL DEFAULT '25',
  "maxattachsize" integer NOT NULL DEFAULT '256000',
  "captcha_status" boolean DEFAULT true,
  "captcha_reg_status" boolean DEFAULT true,
  "captcha_post_status" boolean DEFAULT true,
  "captcha_search_status" boolean DEFAULT false,
  "captcha_code_charset" varchar(128) NOT NULL DEFAULT 'A-Z',
  "captcha_code_length" integer NOT NULL DEFAULT '8',
  "captcha_code_casesensitive" boolean DEFAULT false,
  "captcha_code_shadow" boolean DEFAULT false,
  "captcha_image_type" varchar(4) NOT NULL DEFAULT 'png',
  "captcha_image_width" integer NOT NULL DEFAULT '250',
  "captcha_image_height" integer NOT NULL DEFAULT '50',
  "captcha_image_bg" varchar(128),
  "captcha_image_dots" INTEGER NOT NULL DEFAULT 0,
  "captcha_image_lines" integer NOT NULL DEFAULT '70',
  "captcha_image_fonts" varchar(128),
  "captcha_image_minfont" integer NOT NULL DEFAULT '16',
  "captcha_image_maxfont" integer NOT NULL DEFAULT '25',
  "captcha_image_color" boolean DEFAULT false,
  "showsubforums" boolean DEFAULT false,
  "regoptional" boolean DEFAULT false,
  "quickreply_status" boolean DEFAULT true,
  "quickjump_status" boolean DEFAULT true,
  "index_stats" boolean DEFAULT true,
  "onlinetodaycount" integer NOT NULL DEFAULT '50',
  "onlinetoday_status" boolean DEFAULT true,
  "attach_remote_images" boolean DEFAULT false,
  "files_min_disk_size" integer NOT NULL DEFAULT '9216',
  "files_storage_path" varchar(100),
  "files_subdir_format" integer NOT NULL DEFAULT '1',
  "file_url_format" integer NOT NULL DEFAULT '1',
  "files_virtual_url" varchar(60),
  "filesperpost" integer NOT NULL DEFAULT '10',
  "ip_banning" boolean DEFAULT false,
  "max_image_size" varchar(9) NOT NULL DEFAULT '1000x1000',
  "max_thumb_size" varchar(9) NOT NULL DEFAULT '200x200',
  "schema_version" integer NOT NULL DEFAULT '3'
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_smilies"
--

DROP TABLE IF EXISTS "xmb_smilies";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_smilies" (
  "type" varchar(15),
  "code" varchar(40),
  "url" varchar(40),
  "id" integer NOT NULL
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_templates"
--

DROP TABLE IF EXISTS "xmb_templates";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_templates" (
  "id" integer NOT NULL,
  "name" varchar(32),
  "template" text NOT NULL
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_themes"
--

DROP TABLE IF EXISTS "xmb_themes";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_themes" (
  "themeid" integer NOT NULL,
  "name" varchar(32),
  "bgcolor" varchar(25),
  "altbg1" varchar(15),
  "altbg2" varchar(15),
  "link" varchar(15),
  "bordercolor" varchar(15),
  "header" varchar(15),
  "headertext" varchar(15),
  "top" varchar(15),
  "catcolor" varchar(15),
  "tabletext" varchar(15),
  "text" varchar(15),
  "borderwidth" varchar(15),
  "tablewidth" varchar(15),
  "tablespace" varchar(15),
  "font" varchar(40),
  "fontsize" varchar(40),
  "boardimg" varchar(128) DEFAULT NULL,
  "imgdir" varchar(120),
  "admdir" varchar(120) NOT NULL DEFAULT 'images/admin',
  "smdir" varchar(120) NOT NULL DEFAULT 'images/smilies',
  "cattext" varchar(15)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_threads"
--

DROP TABLE IF EXISTS "xmb_threads";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_threads" (
  "tid" integer NOT NULL,
  "fid" INTEGER NOT NULL DEFAULT 0,
  "subject" varchar(128),
  "icon" varchar(75),
  "lastpost" varchar(54),
  "views" INTEGER NOT NULL DEFAULT 0,
  "replies" INTEGER NOT NULL DEFAULT 0,
  "author" varchar(32),
  "closed" varchar(15),
  "topped" INTEGER NOT NULL DEFAULT 0,
  "pollopts" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_u2u"
--

DROP TABLE IF EXISTS "xmb_u2u";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_u2u" (
  "u2uid" integer NOT NULL,
  "msgto" varchar(32),
  "msgfrom" varchar(32),
  "type" message_type,
  "owner" varchar(32),
  "folder" varchar(32),
  "subject" varchar(64),
  "message" text NOT NULL,
  "dateline" INTEGER NOT NULL DEFAULT 0,
  "readstatus" boolean,
  "sentstatus" boolean
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_vote_desc"
--

DROP TABLE IF EXISTS "xmb_vote_desc";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_vote_desc" (
  "vote_id" integer NOT NULL,
  "topic_id" INTEGER NOT NULL DEFAULT 0,
  "vote_text" text NOT NULL,
  "vote_start" INTEGER NOT NULL DEFAULT 0,
  "vote_length" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_vote_results"
--

DROP TABLE IF EXISTS "xmb_vote_results";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_vote_results" (
  "vote_id" INTEGER NOT NULL DEFAULT 0,
  "vote_option_id" INTEGER NOT NULL DEFAULT 0,
  "vote_option_text" varchar(255),
  "vote_result" INTEGER NOT NULL DEFAULT 0
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_vote_voters"
--

DROP TABLE IF EXISTS "xmb_vote_voters";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_vote_voters" (
  "vote_id" INTEGER NOT NULL DEFAULT 0,
  "vote_user_id" INTEGER NOT NULL DEFAULT 0,
  "vote_user_ip" char(8)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_whosonline"
--

DROP TABLE IF EXISTS "xmb_whosonline";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_whosonline" (
  "username" varchar(32),
  "ip" varchar(15),
  "time" INTEGER NOT NULL DEFAULT 0,
  "location" varchar(150),
  "invisible" boolean DEFAULT false
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table "xmb_words"
--

DROP TABLE IF EXISTS "xmb_words";
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "xmb_words" (
  "find" varchar(60),
  "replace1" varchar(60),
  "id" integer NOT NULL
);
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-19 23:12:14
