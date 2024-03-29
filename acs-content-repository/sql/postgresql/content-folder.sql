-- Data model to support content repository of the ArsDigita Community
-- System

-- Copyright (C) 1999-2000 ArsDigita Corporation
-- Author: Karl Goldstein (karlg@arsdigita.com)

-- $Id: content-folder.sql,v 1.2 2010/10/19 20:10:34 po34demo Exp $

-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

-- create or replace package body content_folder


create or replace function content_folder__new(varchar,varchar,varchar,integer,integer) 
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null  
  new__parent_id              alias for $4;  -- default null
  new__package_id             alias for $5;  -- default null
begin
        return content_folder__new(new__name,
                                   new__label,
                                   new__description,
                                   new__parent_id,
                                   null,
                                   null,
                                   now(),
                                   null,
                                   null,
                                   new__package_id
               );

end;' language 'plpgsql';

create or replace function content_folder__new(varchar,varchar,varchar,integer) 
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null  
  new__parent_id              alias for $4;  -- default null
begin
        return content_folder__new(new__name,
                                   new__label,
                                   new__description,
                                   new__parent_id,
                                   null,
                                   null,
                                   now(),
                                   null,
                                   null,
                                   ''t'',
                                   null
               );

end;' language 'plpgsql';

-- function new
create or replace function content_folder__new (varchar,varchar,varchar,integer,integer,integer,timestamptz,integer,varchar)
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null
  new__parent_id              alias for $4;  -- default null
  new__context_id             alias for $5;  -- default null
  new__folder_id              alias for $6;  -- default null
  new__creation_date          alias for $7;  -- default now()
  new__creation_user          alias for $8;  -- default null
  new__creation_ip            alias for $9;  -- default null
begin
        return content_folder__new(new__name,
                                   new__label,
                                   new__description,
                                   new__parent_id,
                                   new__context_id,
                                   new__folder_id,
                                   new__creation_date,
                                   new__creation_user,
                                   new__creation_ip,
                                   ''t'',
                                   null::integer
               );

end;' language 'plpgsql';

-- function new
create or replace function content_folder__new (varchar,varchar,varchar,integer,integer,integer,timestamptz,integer,varchar,integer)
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null
  new__parent_id              alias for $4;  -- default null
  new__context_id             alias for $5;  -- default null
  new__folder_id              alias for $6;  -- default null
  new__creation_date          alias for $7;  -- default now()
  new__creation_user          alias for $8;  -- default null
  new__creation_ip            alias for $9;  -- default null
  new__package_id             alias for $10;  -- default null
  v_folder_id                 cr_folders.folder_id%TYPE;
  v_context_id                acs_objects.context_id%TYPE;
  v_package_id                acs_objects.package_id%TYPE;
begin
        return content_folder__new(new__name,
                                   new__label,
                                   new__description,
                                   new__parent_id,
                                   new__context_id,
                                   new__folder_id,
                                   new__creation_date,
                                   new__creation_user,
                                   new__creation_ip,
                                   ''t'',
                                   new__package_id
               );
end;' language 'plpgsql';

create or replace function content_folder__new (varchar,varchar,varchar,integer,integer,integer,timestamptz,integer,varchar,boolean)
returns integer as '
declare
  new__name                   alias for $1;
  new__label                  alias for $2;
  new__description            alias for $3;  -- default null
  new__parent_id              alias for $4;  -- default null
  new__context_id             alias for $5;  -- default null
  new__folder_id              alias for $6;  -- default null
  new__creation_date          alias for $7;  -- default now()
  new__creation_user          alias for $8;  -- default null
  new__creation_ip            alias for $9;  -- default null
  new__security_inherit_p     alias for $10;  -- default true
  v_package_id                acs_objects.package_id%TYPE;
  v_folder_id                 cr_folders.folder_id%TYPE;
  v_context_id                acs_objects.context_id%TYPE;
begin

        return content_folder__new (
                new__name,
                new__label,
                new__description,
                new__parent_id,
                new__context_id,
                new__folder_id,
                new__creation_date,
                new__creation_user,
                new__creation_ip,
                new__security_inherit_p,
                null
        );

end;' language 'plpgsql';

-- function new -- accepts security_inherit_p DaveB
select define_function_args('content_folder__new','name,label,description,parent_id,context_id,folder_id,creation_date;now,creation_user,creation_ip,security_inherit_p;t,package_id');

create or replace function content_folder__new (varchar,varchar,varchar,integer,integer,integer,timestamptz,integer,varchar, boolean,integer)
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null
  new__parent_id              alias for $4;  -- default null
  new__context_id             alias for $5;  -- default null
  new__folder_id              alias for $6;  -- default null
  new__creation_date          alias for $7;  -- default now()
  new__creation_user          alias for $8;  -- default null
  new__creation_ip            alias for $9;  -- default null
  new__security_inherit_p     alias for $10;  -- default true
  new__package_id             alias for $11; -- default null
  v_folder_id                 cr_folders.folder_id%TYPE;
  v_context_id                acs_objects.context_id%TYPE;
begin

  -- set the context_id
  if new__context_id is null then
    v_context_id := new__parent_id;
  else
    v_context_id := new__context_id;
  end if;

  -- parent_id = security_context_root means that this is a mount point
  if new__parent_id != -4 and 
    content_folder__is_folder(new__parent_id) and
    content_folder__is_registered(new__parent_id,''content_folder'',''f'') = ''f'' then

    raise EXCEPTION ''-20000: This folder does not allow subfolders to be created'';
    return null;

  else

    v_folder_id := content_item__new(
	new__folder_id,
	new__name, 
        new__parent_id,
        null,
        new__creation_date, 
        new__creation_user, 
	new__context_id,
	new__creation_ip, 
	''f'',
	''text/plain'',
	null,
	''text'',
	new__security_inherit_p,
	''CR_FILES'',
	''content_folder'',
        ''content_folder'',
        new__package_id
    );

    insert into cr_folders (
      folder_id, label, description, package_id
    ) values (
      v_folder_id, new__label, new__description, new__package_id
    );

    -- set the correct object title
    update acs_objects
    set title = new__label
    where object_id = v_folder_id;

    -- inherit the attributes of the parent folder
    if new__parent_id is not null then
    
      insert into cr_folder_type_map
        select
          v_folder_id as folder_id, content_type
        from
          cr_folder_type_map

where
          folder_id = new__parent_id;
    end if;

    -- update the child flag on the parent
    update cr_folders set has_child_folders = ''t''
      where folder_id = new__parent_id;

    return v_folder_id;

  end if;

  return v_folder_id; 
end;' language 'plpgsql';

create or replace function content_folder__new (varchar,varchar,varchar,integer,integer,integer,timestamptz,integer,varchar,boolean)
returns integer as '
declare
  new__name                   alias for $1;  
  new__label                  alias for $2;  
  new__description            alias for $3;  -- default null
  new__parent_id              alias for $4;  -- default null
  new__context_id             alias for $5;  -- default null
  new__folder_id              alias for $6;  -- default null
  new__creation_date          alias for $7;  -- default now()
  new__creation_user          alias for $8;  -- default null
  new__creation_ip            alias for $9;  -- default null
  new__security_inherit_p     alias for $10;  -- default true	
begin
        return content_folder__new(new__name,
                                   new__label,
                                   new__description,
                                   new__parent_id,
                                   new__context_id,
                                   new__folder_id,
                                   new__creation_date,
                                   new__creation_user,
                                   new__creation_ip,
                                   new__security_inherit_p,
                                   null::integer
               );

end;' language 'plpgsql';

-- procedure delete
select define_function_args('content_folder__del','folder_id,cascade_p;f');
create or replace function content_folder__del (integer, boolean)
returns integer as '
declare
  delete__folder_id              alias for $1;  
  p_cascade_p                    alias for $2; -- default ''f''
  v_count                        integer;       
  v_child_row                    record;
  v_parent_id                    integer;  
  v_path                         varchar;     
  v_folder_sortkey               varbit;
begin

  if p_cascade_p = ''f'' then
    select count(*) into v_count from cr_items 
     where parent_id = delete__folder_id;
    -- check if the folder contains any items
    if v_count > 0 then
      v_path := content_item__get_path(delete__folder_id, null);
      raise EXCEPTION ''-20000: Folder ID % (%) cannot be deleted because it is not empty.'', delete__folder_id, v_path;
    end if;  
  else 
  -- delete children
    select into v_folder_sortkey tree_sortkey
    from cr_items where item_id=delete__folder_id;

    for v_child_row in select
        item_id, tree_sortkey, name
        from cr_items
        where tree_sortkey between v_folder_sortkey and tree_right(v_folder_sortkey)   
	and tree_sortkey != v_folder_sortkey
        order by tree_sortkey desc
    loop
	if content_folder__is_folder(v_child_row.item_id) then
	  perform content_folder__delete(v_child_row.item_id);
        else
         perform content_item__delete(v_child_row.item_id);
	end if;
    end loop;
  end if;

  PERFORM content_folder__unregister_content_type(
      delete__folder_id,
      ''content_revision'',
      ''t'' 
  );

  delete from cr_folder_type_map
    where folder_id = delete__folder_id;

  select parent_id into v_parent_id from cr_items 
    where item_id = delete__folder_id;
  raise notice ''deleteing folder %'',delete__folder_id;
  PERFORM content_item__delete(delete__folder_id);

  -- check if any folders are left in the parent
  update cr_folders set has_child_folders = ''f'' 
    where folder_id = v_parent_id and not exists (
      select 1 from cr_items 
        where parent_id = v_parent_id and content_type = ''content_folder'');

  return 0; 
end;' language 'plpgsql';

select define_function_args('content_folder__delete','folder_id,cascade_p;f');

create or replace function content_folder__delete (integer, boolean)
returns integer as '
declare
  delete__folder_id              alias for $1;  
  p_cascade_p                    alias for $2;  -- default ''f''
begin
        PERFORM content_folder__del(delete__folder_id,p_cascade_p);
  return 0; 
end;' language 'plpgsql';


create or replace function content_folder__delete (integer)
returns integer as '
declare
  delete__folder_id              alias for $1;  
  v_count                        integer;       
  v_parent_id                    integer;  
  v_path                         varchar;     
begin
	return content_folder__del(
		delete__folder_id,
		''f''
		);
end;' language 'plpgsql';


-- procedure rename
select define_function_args('content_folder__edit_name','folder_id,name,label,description');
create or replace function content_folder__edit_name (integer,varchar,varchar,varchar)
returns integer as '
declare
  edit_name__folder_id              alias for $1;  
  edit_name__name                   alias for $2;  -- default null  
  edit_name__label                  alias for $3;  -- default null
  edit_name__description            alias for $4;  -- default null
  v_name_already_exists_p        integer;
begin

  if edit_name__name is not null and edit_name__name != '''' then
    PERFORM content_item__edit_name(edit_name__folder_id, edit_name__name);
  end if;

  if edit_name__label is not null and edit_name__label != '''' then
    update acs_objects
    set title = edit_name__label
    where object_id = edit_name__folder_id;
  end if;

  if edit_name__label is not null and edit_name__label != '''' and 
     edit_name__description is not null and edit_name__description != '''' then 

    update cr_folders
      set label = edit_name__label,
      description = edit_name__description
      where folder_id = edit_name__folder_id;

  else if(edit_name__label is not null and edit_name__label != '''') and 
         (edit_name__description is null or edit_name__description = '''') then  
    update cr_folders
      set label = edit_name__label
      where folder_id = edit_name__folder_id;

  end if; end if;

  return 0; 
end;' language 'plpgsql';

-- 1) make sure we are not moving the folder to an invalid location:
--   a. destination folder exists
--   b. folder is not the webroot (folder_id = -1)
--   c. destination folder is not the same as the folder
--   d. destination folder is not a subfolder
-- 2) make sure subfolders are allowed in the target_folder
-- 3) update the parent_id for the folder

-- procedure move
select define_function_args('content_folder__move','folder_id,target_folder_id,name;null');

create or replace function content_folder__move (integer,integer,varchar)
returns integer as '
declare
  move__folder_id              alias for $1;  
  move__target_folder_id       alias for $2;
  move__name                   alias for $3; -- default null
  v_source_folder_id           integer;       
  v_valid_folders_p            integer;
begin

  select 
    count(*)
  into 
    v_valid_folders_p
  from 
    cr_folders
  where
    folder_id = move__target_folder_id
  or 
    folder_id = move__folder_id;

  if v_valid_folders_p != 2 then
    raise EXCEPTION ''-20000: content_folder.move - Not valid folder(s)'';
  end if;

  if move__folder_id = content_item__get_root_folder(null) or
    move__folder_id = content_template__get_root_folder() then
    raise EXCEPTION ''-20000: content_folder.move - Cannot move root folder'';
  end if;
  
  if move__target_folder_id = move__folder_id then
    raise EXCEPTION ''-20000: content_folder.move - Cannot move a folder to itself'';
  end if;

  if content_folder__is_sub_folder(move__folder_id, move__target_folder_id) = ''t'' then
    raise EXCEPTION ''-20000: content_folder.move - Destination folder is subfolder'';
  end if;

  if content_folder__is_registered(move__target_folder_id,''content_folder'',''f'') != ''t'' then
    raise EXCEPTION ''-20000: content_folder.move - Destination folder does not allow subfolders'';
  end if;

  select parent_id into v_source_folder_id from cr_items 
    where item_id = move__folder_id;

   -- update the parent_id for the folder
   update cr_items 
     set parent_id = move__target_folder_id,
         name = coalesce ( move__name, name )
     where item_id = move__folder_id;

  -- update the has_child_folders flags

  -- update the source
  update cr_folders set has_child_folders = ''f'' 
    where folder_id = v_source_folder_id and not exists (
      select 1 from cr_items 
        where parent_id = v_source_folder_id 
          and content_type = ''content_folder'');

  -- update the destination
  update cr_folders set has_child_folders = ''t''
    where folder_id = move__target_folder_id;

  return 0; 
end;' language 'plpgsql';

create or replace function content_folder__move (integer,integer)
returns integer as '
declare
  move__folder_id              alias for $1;  
  move__target_folder_id       alias for $2;  
begin

  perform content_folder__move (
                                move__folder_id,
                                move__target_folder_id,
                                NULL
                               );
  return null;
end;' language 'plpgsql';

-- procedure copy
create or replace function content_folder__copy (integer,integer,integer,varchar)
returns integer as '
declare
  copy__folder_id              alias for $1;  
  copy__target_folder_id       alias for $2;  
  copy__creation_user          alias for $3;  
  copy__creation_ip            alias for $4;  -- default null  
  v_valid_folders_p            integer;        
  v_current_folder_id          cr_folders.folder_id%TYPE;
  v_name                       cr_items.name%TYPE;
  v_label                      cr_folders.label%TYPE;
  v_description                cr_folders.description%TYPE;
  v_new_folder_id              cr_folders.folder_id%TYPE;
  v_folder_contents_val        record;
begin
	v_new_folder_id := content_folder__copy (
			copy__folder_id,
			copy__target_folder_id,
			copy__creation_user,
			copy__creation_ip,
			NULL
			);
	return v_new_folder_id;
end;' language 'plpgsql';

create or replace function content_folder__copy (integer,integer,integer,varchar,varchar)
returns integer as '
declare
  copy__folder_id              alias for $1;  
  copy__target_folder_id       alias for $2;  
  copy__creation_user          alias for $3;  
  copy__creation_ip            alias for $4;  -- default null
  copy__name                   alias for $5; -- default null
  v_valid_folders_p            integer;
  v_current_folder_id          cr_folders.folder_id%TYPE;
  v_name                       cr_items.name%TYPE;
  v_label                      cr_folders.label%TYPE;
  v_description                cr_folders.description%TYPE;
  v_new_folder_id              cr_folders.folder_id%TYPE;
  v_folder_contents_val        record;
begin

  if copy__folder_id = content_item__get_root_folder(null) 
     or copy__folder_id = content_template__get_root_folder() then
     raise EXCEPTION ''-20000: content_folder.copy - Not allowed to copy root folder'';
  end if;

  select 
    count(*)
  into 
    v_valid_folders_p
  from 
    cr_folders
  where
    folder_id = copy__target_folder_id
  or 
    folder_id = copy__folder_id;

  if v_valid_folders_p != 2 then 
    raise EXCEPTION ''-20000: content_folder.copy - Invalid folder(s)'';
  end if;

  if copy__target_folder_id = copy__folder_id then 
    raise EXCEPTION ''-20000: content_folder.copy - Cannot copy folder to itself'';
  end if;
  
  if content_folder__is_sub_folder(copy__folder_id, copy__target_folder_id) = ''t'' then
    raise EXCEPTION ''-20000: content_folder.copy - Destination folder is subfolder'';
  end if;

  if content_folder__is_registered(copy__target_folder_id,''content_folder'',''f'') != ''t'' then
    raise EXCEPTION ''-20000: content_folder.copy - Destination folder does not allow subfolders'';
  end if;

  -- get the source folder info
  select
    name, label, description, parent_id
  into
    v_name, v_label, v_description, v_current_folder_id
  from 
    cr_items i, cr_folders f
  where
    f.folder_id = i.item_id
  and
    f.folder_id = copy__folder_id;

  -- would be better to check if the copy__name alredy exists in the destination folder.

  if v_current_folder_id = copy__target_folder_id and (v_name = copy__name or copy__name is null) then
    raise EXCEPTION ''-20000: content_folder.copy - Destination folder is parent folder and folder alredy exists'';
  end if;

      -- create the new folder
      v_new_folder_id := content_folder__new(
          coalesce (copy__name, v_name),
	  v_label,
	  v_description,
	  copy__target_folder_id,
	  copy__target_folder_id,
          null,
          now(),
	  copy__creation_user,
	  copy__creation_ip,
          ''t'',
          null
      );

      -- copy attributes of original folder
      insert into cr_folder_type_map
        select 
          v_new_folder_id as folder_id, content_type
        from
          cr_folder_type_map map
        where
          folder_id = copy__folder_id
        and
	  -- do not register content_type if it is already registered
          not exists ( select 1 from cr_folder_type_map
	               where folder_id = v_new_folder_id 
		       and content_type = map.content_type ) ;

      -- for each item in the folder, copy it
      for v_folder_contents_val in select
                                     item_id
                                   from
                                     cr_items
                                   where
                                     parent_id = copy__folder_id 
      LOOP
        
	PERFORM content_item__copy(
	    v_folder_contents_val.item_id,
	    v_new_folder_id,
	    copy__creation_user,
	    copy__creation_ip,
            null
	);

      end loop;

  return 0; 
end;' language 'plpgsql';


-- function is_folder
select define_function_args('content_folder__is_folder','item_id');
create or replace function content_folder__is_folder (integer)
returns boolean as '
declare
  item_id                alias for $1;  
begin

  return count(*) > 0 from cr_folders
    where folder_id = item_id;

end;' language 'plpgsql' stable;


-- function is_sub_folder
select define_function_args('content_folder__is_sub_folder','folder_id,target_folder_id');
create or replace function content_folder__is_sub_folder (integer,integer)
returns boolean as '
declare
  is_sub_folder__folder_id              alias for $1;  
  is_sub_folder__target_folder_id       alias for $2;  
  v_parent_id                           integer default 0;       
  v_sub_folder_p                        boolean default ''f'';           
  v_rec                                 record;
begin

  if is_sub_folder__folder_id = content_item__get_root_folder(null) or
    is_sub_folder__folder_id = content_template__get_root_folder() then

    v_sub_folder_p := ''t'';
  end if;

--               select
--                 parent_id
--               from 
--                 cr_items
--               connect by
--                 prior parent_id = item_id
--               start with
--                 item_id = is_sub_folder__target_folder_id

  for v_rec in select i2.parent_id
               from cr_items i1, cr_items i2
               where i1.item_id = is_sub_folder__target_folder_id
                 and i1.tree_sortkey between i2.tree_sortkey and tree_right(i2.tree_sortkey)
               order by i2.tree_sortkey desc
  LOOP
    v_parent_id := v_rec.parent_id;
    exit when v_parent_id = is_sub_folder__folder_id;
    -- we did not find the folder, reset v_parent_id
    v_parent_id := -4;
  end LOOP;

  if v_parent_id != -4 then 
    v_sub_folder_p := ''t'';
  end if;

  return v_sub_folder_p;
 
end;' language 'plpgsql'; 


-- function is_empty
select define_function_args('content_folder__is_empty','folder_id');
create or replace function content_folder__is_empty (integer)
returns boolean as '
declare
  is_empty__folder_id              alias for $1;  
  v_return                         boolean;    
begin

  select
    count(*) = 0 into v_return
  from
    cr_items
  where
    parent_id = is_empty__folder_id;

  return v_return;
 
end;' language 'plpgsql' stable;


-- procedure register_content_type
select define_function_args('content_folder__register_content_type','folder_id,content_type,include_subtypes;f');

create or replace function content_folder__register_content_type (integer,varchar,boolean)
returns integer as '
declare
  register_content_type__folder_id              alias for $1;  
  register_content_type__content_type           alias for $2;  
  register_content_type__include_subtypes       alias for $3;  -- default ''f''
  v_is_registered                               varchar;  
begin

  if register_content_type__include_subtypes = ''f'' then

    v_is_registered := content_folder__is_registered(
        register_content_type__folder_id,
	register_content_type__content_type, 
	''f'' 
    );

    if v_is_registered = ''f'' then

        insert into cr_folder_type_map (
	  folder_id, content_type
	) values (
	  register_content_type__folder_id, 
	  register_content_type__content_type
	);

    end if;

  else

--    insert into cr_folder_type_map
--      select 
--        register_content_type__folder_id as folder_id, 
--        object_type as content_type
--      from
--        acs_object_types
--      where
--        object_type <> ''acs_object''
--      and
--        not exists (select 1 from cr_folder_type_map
--                    where folder_id = register_content_type__folder_id
--                    and content_type = acs_object_types.object_type)
--      connect by 
--        prior object_type = supertype
--      start with 
--        object_type = register_content_type__content_type;
    
    insert into cr_folder_type_map
      select register_content_type__folder_id as folder_id, 
        o.object_type as content_type
      from acs_object_types o, acs_object_types o2
      where o.object_type <> ''acs_object''
        and not exists (select 1
                        from cr_folder_type_map
                        where folder_id = register_content_type__folder_id
                          and content_type = o.object_type)
        and o2.object_type = register_content_type__content_type
        and o.tree_sortkey between o2.tree_sortkey and tree_right(o2.tree_sortkey);
  end if;

  return 0; 
end;' language 'plpgsql';


-- procedure unregister_content_type
select define_function_args('content_folder__unregister_content_type','folder_id,content_type,include_subtypes;f');
create or replace function content_folder__unregister_content_type (integer,varchar,boolean)
returns integer as '
declare
  unregister_content_type__folder_id              alias for $1;  
  unregister_content_type__content_type           alias for $2;  
  unregister_content_type__include_subtypes       alias for $3; -- default ''f'' 
begin

  if unregister_content_type__include_subtypes = ''f'' then
    delete from cr_folder_type_map
      where folder_id = unregister_content_type__folder_id
      and content_type = unregister_content_type__content_type;
  else

--    delete from cr_folder_type_map
--    where folder_id = unregister_content_type__folder_id
--    and content_type in (select object_type
--           from acs_object_types    
--	   where object_type <> ''acs_object''
--	   connect by prior object_type = supertype
--	   start with 
--             object_type = unregister_content_type__content_type);

    delete from cr_folder_type_map
    where folder_id = unregister_content_type__folder_id
    and content_type in (select o.object_type
                           from acs_object_types o, acs_object_types o2
	                  where o.object_type <> ''acs_object''
                            and o2.object_type = unregister_content_type__content_type
                            and o.tree_sortkey between o2.tree_sortkey and tree_right(o2.tree_sortkey));

  end if;

  return 0; 
end;' language 'plpgsql';


-- function is_registered
select define_function_args('content_folder__is_registered','folder_id,content_type,include_subtypes;f');
create or replace function content_folder__is_registered (integer,varchar,boolean)
returns boolean as '
declare
  is_registered__folder_id              alias for $1;  
  is_registered__content_type           alias for $2;  
  is_registered__include_subtypes       alias for $3;  -- default ''f''  
  v_is_registered                       integer;
  v_subtype_val                         record;
begin

  if is_registered__include_subtypes = ''f'' or  is_registered__include_subtypes is null then
    select 
      count(1)
    into 
      v_is_registered
    from
      cr_folder_type_map
    where
      folder_id = is_registered__folder_id
    and
      content_type = is_registered__content_type;

  else
--                         select
--                            object_type
--                          from 
--                            acs_object_types
--                          where 
--                            object_type <> ''acs_object''
--                          connect by 
--                            prior object_type = supertype
--                          start with 
--                            object_type = is_registered.content_type 

    v_is_registered := 1;
    for v_subtype_val in select o.object_type
                         from acs_object_types o, acs_object_types o2
                         where o.object_type <> ''acs_object''
                           and o2.object_type = is_registered__content_type
                           and o.tree_sortkey between o2.tree_sortkey and tree_right(o2.tree_sortkey)
                         order by o.tree_sortkey
    LOOP
      if content_folder__is_registered(is_registered__folder_id,
                       v_subtype_val.object_type, ''f'') = ''f'' then
        v_is_registered := 0;
      end if;
    end loop;
  end if;

  if v_is_registered = 0 then
    return ''f'';
  else
    return ''t'';
  end if;
 
end;' language 'plpgsql' stable;


-- function get_label
select define_function_args('content_folder__get_label','folder_id');
create or replace function content_folder__get_label (integer)
returns varchar as '
declare
  get_label__folder_id              alias for $1;  
  v_label                           cr_folders.label%TYPE;
begin

  select 
    label into v_label 
  from 
    cr_folders       
  where 
    folder_id = get_label__folder_id;

  return v_label;
 
end;' language 'plpgsql' stable strict;


-- function get_index_page
select define_function_args('content_folder__get_index_page','folder_id');
create or replace function content_folder__get_index_page (integer)
returns integer as '
declare
  get_index_page__folder_id              alias for $1;  
  v_folder_id                            cr_folders.folder_id%TYPE;
  v_index_page_id                        cr_items.item_id%TYPE;
begin

  -- if the folder is a symlink, resolve it
  if content_symlink__is_symlink(get_index_page__folder_id) = ''t'' then
    v_folder_id := content_symlink__resolve(get_index_page__folder_id);
  else
    v_folder_id := get_index_page__folder_id;
  end if;

  select
    item_id into v_index_page_id
  from
    cr_items
  where
    parent_id = v_folder_id
  and
    name = ''index''
  and
    content_item__is_subclass(
      content_item__get_content_type(content_symlink__resolve(item_id)),
    ''content_folder'') = ''f''
  and
    content_item__is_subclass(
      content_item__get_content_type(content_symlink__resolve(item_id)),
    ''content_template'') = ''f'';

  if NOT FOUND then 
     return null;
  end if;

  return v_index_page_id;

end;' language 'plpgsql' stable strict;


-- function is_root
select define_function_args('content_folder__is_root','folder_id');
create or replace function content_folder__is_root (integer)
returns boolean as '
declare
  is_root__folder_id              alias for $1;  
  v_is_root                       boolean;       
begin

  select parent_id = -4 into v_is_root 
    from cr_items where item_id = is_root__folder_id;

  return v_is_root;
 
end;' language 'plpgsql';



-- show errors
