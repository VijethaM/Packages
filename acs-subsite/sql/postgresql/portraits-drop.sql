--
-- packages/acs-subsite/sql/portraits-drop.sql
--
-- @author oumi@arsdigita.com
-- @creation-date 2000-02-02
-- @cvs-id $Id: portraits-drop.sql,v 1.2 2010/10/19 20:12:16 po34demo Exp $
--

select acs_rel_type__drop_type('user_portrait_rel', 'f');
select acs_rel_type__drop_role('portrait');
select acs_rel_type__drop_role('user');

drop table user_portraits;
