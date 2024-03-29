-- 
-- Upgrade script from 5.0d to 5.0d2
--
-- @author Simon Carstensen (simon@collaboraid.biz)
--
-- @cvs-id $Id: upgrade-5.0d-5.0d2.sql,v 1.2 2010/10/19 20:11:37 po34demo Exp $
--

-- Adds column timezone to table user_preferences

alter table user_preferences add timezone varchar2(100);

create or replace trigger acs_objects_context_id_up_tr
after update on acs_objects
for each row
declare
  security_context_root acs_objects.object_id%TYPE;
begin
  if :new.object_id = :old.object_id and
     :new.context_id = :old.context_id and
     :new.security_inherit_p = :old.security_inherit_p then
    return;
  end if;

  -- Hate the hardwiring but magic objects aren't defined yet (PG doesn't
  -- mind because function bodies aren't compiled until first called)

  security_context_root := -4;

  -- Remove my old ancestors from my descendants.
  for pair in ( select object_id from acs_object_contexts where 
                ancestor_id = :old.object_id) loop
    delete from acs_object_context_index
    where object_id = pair.object_id
      and ancestor_id in ( select ancestor_id from acs_object_contexts
                           where object_id = :old.object_id );
  end loop;

  -- Kill all my old ancestors.
  delete from acs_object_context_index
  where object_id = :old.object_id;

  insert into acs_object_context_index
   (object_id, ancestor_id, n_generations)
  values
   (:new.object_id, :new.object_id, 0);

  if :new.context_id is not null and :new.security_inherit_p = 't' then
     -- Now insert my new ancestors for my descendants.
    for pair in (select *
		 from acs_object_context_index
		 where ancestor_id = :new.object_id) loop
      insert into acs_object_context_index
       (object_id, ancestor_id, n_generations)
      select
       pair.object_id, ancestor_id,
       n_generations + pair.n_generations + 1 as n_generations
      from acs_object_context_index
      where object_id = :new.context_id;
    end loop;
  else
    if :new.object_id != 0 then
      -- We need to make sure that :NEW.OBJECT_ID and all of its
      -- children have security_context_root as an ancestor.
      for pair in (select *
		   from acs_object_context_index
		   where ancestor_id = :new.object_id)
      loop
        insert into acs_object_context_index
          (object_id, ancestor_id, n_generations)
        values
          (pair.object_id, security_context_root, pair.n_generations + 1);
      end loop;
    end if;
  end if;
end;
/
show errors
