--
-- The Notifications Package
--
-- @author Ben Adida (ben@openforce.net)
-- @version $Id: notifications-init.sql,v 1.2 2010/10/20 02:08:06 po34demo Exp $
--
-- Copyright (C) 2000 MIT
--
-- GNU GPL v2
--

-- initialize some stuff
declare
    v_foo   integer;
begin

    v_foo:= notification_interval.new(
        name => 'daily',
        n_seconds => 3600 * 24,
        creation_user => null,
        creation_ip => null
    );

    v_foo:= notification_interval.new(
        name => 'hourly',
        n_seconds => 3600,
        creation_user => null,
        creation_ip => null
    );

    v_foo:= notification_interval.new(
        name => 'instant',
        n_seconds => 0,
        creation_user => null,
        creation_ip => null
    );
           
end;
/
show errors
