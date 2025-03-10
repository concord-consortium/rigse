# Upgrade to MySQL 8

As of March 2025, the production and staging portals each use an AWS RDS Aurora cluster for their MySQL 5 database. AWS is ending support for MySQL 5, so we need to upgrade the clusters to MySQL 8. That means going from Aurora 2 to Aurora 3.

The upgrade process is largely automated, but issues in the production database need to be addressed first. For the full upgrade prechecks log, see the `upgrade-prechecks.log` file.

## Issues

### ERROR #1: Old Temporal Type

Some table columns use a no-longer-supported temporal disk storage format. They must be converted to the new format before upgrading. This can by done by rebuilding the table using `ALTER TABLE <table_name> FORCE` command.

[[documentation](https://mysqlserverteam.com/mysql-8-0-removing-support-for-old-temporal-datatypes/)]

#### Affected Objects

_See `old-temporal-type.md` for a list of affected objects._

#### Proposed Fix

Run the ALTER queries listed in `old-temporal-type.md`.

### ERROR #2: Table Rebuild Required

Issues reported by `check table x for upgrade` command. Table rebuild required.

#### Affected Objects

_See `check-table-for-upgrade.md` for a list of affected objects._

#### Proposed Fix

Run the ALTER queries listed in `check-table-for-upgrade.md`.

### WARNING #1: New Reserved Keyword Conflict

Some objects have names ~~with deprecated usage of dollar sign ($) at the begining of the identifier or~~ that conflict with new reserved keywords. Ensure ~~that names starting with dollar sign, also end with it and~~ queries sent by your applications use backticks when referring to the reserved keywords.

[[documentation](https://dev.mysql.com/doc/refman/en/keywords.html)]

#### Affected Objects

- portal.portal_nces06_districts.MEMBER
- portal.portal_nces06_schools.MEMBER

**Details:** Column name `MEMBER` is a reserved keyword.

#### Proposed Fix

##### Option A
Use backticks around column name in application code.

##### Option B
- Rename `MEMBER` table to `member_count`: `ALTER TABLE portal_nces06_districts CHANGE `MEMBER` member_count INT;`
- Replace `MEMBER` with `member_count` in application code

### WARNING #2: Convert UTF8MB3 Character Set

Some objects use the utf8mb3 character set. It is recommended to convert them to use utf8mb4 instead, for improved Unicode support.

[[documentation](https://dev.mysql.com/doc/refman/8.0/en/charset-unicode-utf8mb3.html)]

#### Affected Objects

_See `utf8mb3.md` for a list of affected objects._

#### Proposed Fix

Run the ALTER queries listed in `utf8mb3.md`.

### WARNING #3: Zero date/datetime/timestamp Values No Longer Allowed

By default zero date/datetime/timestamp values are no longer allowed in MySQL, as of 5.7.8 NO_ZERO_IN_DATE and NO_ZERO_DATE are included in SQL_MODE by default. These modes should be used with strict mode as they will be merged with strict mode in a future release. If you do not include these modes in your SQL_MODE setting, you are able to insert date/datetime/timestamp values that contain zeros. It is strongly advised to replace zero values with valid ones, as they may not work correctly in the future.

[[documentation](https://lefred.be/content/mysql-8-0-and-wrong-dates/)]

#### Affected Objects

- global.sql_mode

**Details:** Object does not contain either `NO_ZERO_DATE` or `NO_ZERO_IN_DATE` which allows insertion of zero dates.

#### Proposed Fix

_See `zero-dates.md`._

### WARNING #4: New Default Authentication Plugin Considerations

The new default authentication plugin `caching_sha2_password` offers more secure password hashing than previously used `mysql_native_password` (and consequent improved client connection authentication). However, it also has compatibility implications that may affect existing MySQL installations. If your MySQL installation must serve pre-8.0 clients and you encounter compatibility issues after upgrading, the simplest way to address those issues is to reconfigure the server to revert to the previous default authentication plugin (`mysql_native_password`). For example, use these lines in the server option file:

```
[mysqld] default_authentication_plugin=mysql_native_password
```

However, the setting should be viewed as temporary, not as a long term or permanent solution, because it causes new accounts created with the setting in effect to forego the improved authentication security.

If you are using replication please take time to understand how the authentication plugin changes may impact you.

[[documentation 1](https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password-compatibility-issues)]
[[documentation 2](https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password-replication)]

## Notes on Running Queries

Most queries will run within a few seconds. Some will take a minute or two. There are some queries that will take hours to run, however. These queries involve the `sessions` table.

- The query `ALTER TABLE sessions FORCE;` took about 2 hours.
- The query `ALTER TABLE sessions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;` took about three hours and then failed, twice.

Since we'll be upgrading in off hours, it'd be safe and better to simply delete all the `sessions` table rows before running queries on it. After deleting all rows, the queries should only take a minute or so.
