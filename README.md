# sm-transition
Scripts and SQL queries for transitioning the sciencemadness XMB database to phpBB

The main file to load is "sm_transition.rb".  The easiest way to use it is to start up a Ruby console by running:

``` bash
pry -r ./sm-transition.rb
```

This will connect both the XMB and phpBB databases and allow access to both of them.  To see what tables are available, you can type `XMB_TABLES` or `PHPBB_TABLES` in the Ruby console.  If you want to make an SQL query to either database, you can use these wrappers:

``` ruby
XMB_DB.query("SELECT * FROM xmb_members WHERE uid = (SELECT MAX(uid) FROM xmb_members)").to_a.first
PHPBB_DB.query("SELECT * FROM sm_users WHERE user_id = (SELECT MAX(user_id) FROM sm_users)").to_a.first
```

These commands will return the most recently registered user in the XMB and phpBB databases, respectively. You don't have to do this in most cases though. Using the `SQLTable` class, you can do the same thing using the following commands:

``` ruby
XMB.members[XMB.members.max]
PHPBB.users[PHPBB.users.max]
```

Individual records are always returned as Ruby hash objects.  Some tables that are especially important for converting from XMB to phpBB have `.to_phpbb(n)` methods, which will convert as many fields as possible and return a hash of tables that then need to be written to the phpBB database.  The XMB tables should not be written to for any reason.

Files starting with "fix" or "import" are typically scripts that are made to perform various tasks that are necessary for converting the database to phpBB.  The X2P module contains a lot of useful methods for working with these databases.  New general-purpose methods are added there, and can be called without a reference to the X2P module.

Importing posts takes quite a lot of time, so in order to speed it up, my conversion script will load all the data for a given thread/topic into memory, then process each one before writing it to the phpBB post table.

For attachments, phpBB saves them as files in the regular filesystem, which seems preferable to saving them as large SQL fields.  I was curious as to how many attachments were duplicates in the system, and so set up a process where attachments were run through an MD5 checksum, then saved with their checksum as their filename.  This way, duplicate files would have the same name, and presumably also the same data.  The amount of duplication wasn't very high though, and implementing this only actually saved about 10% compared to not doing it.  
