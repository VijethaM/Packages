-- packages/acs-events/sql/acs-events-drop.sql
--
-- $Id: acs-events-drop.sql,v 1.2 2010/10/19 20:11:25 po34demo Exp $

drop package acs_event;

drop view    partially_populated_events;
drop view    partially_populated_event_ids;
drop view	 acs_events_activities;
drop view	 acs_events_dates;

drop table   acs_event_party_map;
drop index	 acs_events_recurrence_id_idx;
drop table   acs_events;

begin
    acs_object_type.drop_type ('acs_event');
end;
/
show errors

drop sequence acs_events_seq;

@@recurrence-drop
@@timespan-drop
@@activity-drop