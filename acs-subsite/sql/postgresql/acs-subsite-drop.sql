-- Uninstall file for the data model created by 'acs-core-ui-create.sql'
-- (This file created automatically by create-sql-uninst.pl.)
--
-- @author Bryan Quinn
-- @creation-date  (Sat Aug 26 17:56:07 2000)
-- @cvs-id $Id: acs-subsite-drop.sql,v 1.2 2010/10/19 20:12:16 po34demo Exp $

\i subsite-callbacks-drop.sql
\i user-profiles-drop.sql
\i application-groups-drop.sql
\i portraits-drop.sql
\i email-image-drop.sql
\i attributes-drop.sql
\i host-node-map-drop.sql
\i site-node-selection-dro.sql

drop view party_names;
