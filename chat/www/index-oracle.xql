<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="rooms_list">
  <querytext>
    select rm.room_id, rm.pretty_name, rm.description, rm.moderated_p, rm.active_p, rm.archive_p,
    acs_permission.permission_p(room_id, :user_id, 'chat_room_admin') as admin_p
    from chat_rooms rm, acs_objects obj
    where obj.context_id = :package_id
    and rm.room_id = obj.object_id
    order by rm.pretty_name
  </querytext>
</fullquery>

</queryset>