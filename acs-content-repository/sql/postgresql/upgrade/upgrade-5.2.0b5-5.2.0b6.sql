-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-10-25
-- @arch-tag: 14af9d7e-7d34-4db0-aa12-6560f61d2142
-- @cvs-id $Id: upgrade-5.2.0b5-5.2.0b6.sql,v 1.2 2010/10/19 21:00:53 po34demo Exp $
--

select define_function_args('content_item__set_live_revision','revision_id,publish_status;ready');

create or replace function content_item__new (
  cr_items.name%TYPE,
  cr_items.parent_id%TYPE,
  acs_objects.object_id%TYPE,
  cr_items.locale%TYPE,
  acs_objects.creation_date%TYPE,
  acs_objects.creation_user%TYPE,
  acs_objects.context_id%TYPE,
  acs_objects.creation_ip%TYPE,
  acs_object_types.object_type%TYPE,
  acs_object_types.object_type%TYPE, 
  cr_revisions.title%TYPE,
  cr_revisions.description%TYPE,
  cr_revisions.mime_type%TYPE,
  cr_revisions.nls_language%TYPE,
  varchar,
  cr_revisions.content%TYPE,
  cr_child_rels.relation_tag%TYPE,
  boolean,
  cr_items.storage_type%TYPE,
  acs_objects.package_id%TYPE
) returns integer as '
declare
  new__name       alias for $1;
  new__parent_id  alias for $2;
  new__item_id    alias for $3;
  new__locale     alias for $4;
  new__creation_date alias for $5;
  new__creation_user alias for $6;
  new__context_id    alias for $7;
  new__creation_ip   alias for $8;
  new__item_subtype  alias for $9;
  new__content_type  alias for $10;
  new__title         alias for $11;
  new__description   alias for $12;
  new__mime_type     alias for $13;
  new__nls_language  alias for $14;
  new__text          alias for $15;
  new__data          alias for $16;
  new__relation_tag  alias for $17;
  new__is_live       alias for $18;
  new__storage_type  alias for $19;
  new__package_id    alias for $20;
  v_parent_id      cr_items.parent_id%TYPE;
  v_parent_type    acs_objects.object_type%TYPE;
  v_item_id        cr_items.item_id%TYPE;
  v_title          cr_revisions.title%TYPE;
  v_revision_id    cr_revisions.revision_id%TYPE;
  v_rel_id         acs_objects.object_id%TYPE;
  v_rel_tag        cr_child_rels.relation_tag%TYPE;
  v_context_id     acs_objects.context_id%TYPE;
  v_package_id     acs_objects.package_id%TYPE;
  v_storage_type   cr_items.storage_type%TYPE;
begin

  -- place the item in the context of the pages folder if no
  -- context specified 

  if new__parent_id is null then
    v_parent_id := content_item_globals.c_root_folder_id;
  else
    v_parent_id := new__parent_id;
  end if;

  -- Determine context_id
  if new__context_id is null then
    v_context_id := v_parent_id;
  else
    v_context_id := new__context_id;
  end if;

  -- use the name of the item if no title is supplied
  if new__title is null or new__title = '''' then
    v_title := new__name;
  else
    v_title := new__title;
  end if;

  if new__package_id is null and v_parent_id != 0 then
    v_package_id := acs_object__package_id(content_item__get_root_folder(v_parent_id));
  else
    v_package_id := new__package_id;
  end if;

  if v_parent_id = 0 or 
    content_folder__is_folder(v_parent_id) = ''t'' then

    if v_parent_id != 0 and 
      content_folder__is_registered(
        v_parent_id, new__content_type, ''f'') = ''f'' then

      raise EXCEPTION ''-20000: This items content type % is not registered to this folder %'', new__content_type, v_parent_id;
    end if;

  else if v_parent_id != 0 then

     if new__relation_tag is null then
       v_rel_tag := content_item__get_content_type(v_parent_id) 
         || ''-'' || new__content_type;
     else
       v_rel_tag := new__relation_tag;
     end if;

     select object_type into v_parent_type from acs_objects
       where object_id = v_parent_id;

     if NOT FOUND then 
       raise EXCEPTION ''-20000: Invalid parent ID % specified in content_item.new'',  v_parent_id;
     end if;

     if content_item__is_subclass(v_parent_type, ''content_item'') = ''t'' and
        content_item__is_valid_child(v_parent_id, new__content_type, v_rel_tag) = ''f'' then

       raise EXCEPTION ''-20000: This items content type % is not allowed in this container %'', new__content_type, v_parent_id;
     end if;

  end if; end if;

  -- Create the object

  v_item_id := acs_object__new(
      new__item_id,
      new__item_subtype, 
      new__creation_date, 
      new__creation_user, 
      new__creation_ip, 
      v_context_id,
      ''t'',
      v_title,
      v_package_id
  );


  insert into cr_items (
    item_id, name, content_type, parent_id, storage_type
  ) values (
    v_item_id, new__name, new__content_type, v_parent_id, new__storage_type
  );

  -- if the parent is not a folder, insert into cr_child_rels
  if v_parent_id != 0 and
    content_folder__is_folder(v_parent_id) = ''f'' then

    v_rel_id := acs_object__new(
      null,
      ''cr_item_child_rel'',
      now(),
      null,
      null,
      v_parent_id,
      ''t'',
      v_rel_tag || '': '' || v_parent_id || '' - '' || v_item_id,
      v_package_id
    );

    insert into cr_child_rels (
      rel_id, parent_id, child_id, relation_tag, order_n
    ) values (
      v_rel_id, v_parent_id, v_item_id, v_rel_tag, v_item_id
    );

  end if;

  if new__data is not null then

    v_revision_id := content_revision__new(
        v_title,
	new__description,
        now(),
	new__mime_type,
	new__nls_language,
	new__data,
        v_item_id,
        null,
        new__creation_date, 
        new__creation_user, 
        new__creation_ip,
        v_package_id
        );

  elsif new__text is not null or new__title is not null then

    v_revision_id := content_revision__new(
        v_title,
	new__description,
        now(),
	new__mime_type,
        null,
	new__text,
	v_item_id,
        null,
        new__creation_date, 
        new__creation_user, 
        new__creation_ip,
        v_package_id
    );

  end if;

  -- make the revision live if is_live is true
  if new__is_live = ''t'' then
    PERFORM content_item__set_live_revision(v_revision_id);
  end if;

  return v_item_id;

end;' language 'plpgsql';


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
  v_package_id                acs_objects.object_id%TYPE;
  v_folder_id                 cr_folders.folder_id%TYPE;
  v_context_id                acs_objects.context_id%TYPE;
begin

  -- set the context_id
  if new__context_id is null then
    v_context_id := new__parent_id;
  else
    v_context_id := new__context_id;
  end if;

  -- parent_id = 0 means that this is a mount point
  if new__parent_id != 0 and 
    content_folder__is_folder(new__parent_id) and
    content_folder__is_registered(new__parent_id,''content_folder'',''f'') = ''f'' then

    raise EXCEPTION ''-20000: This folder does not allow subfolders to be created'';
    return null;

  else

    v_package_id := new__package_id;

    if new__parent_id is not null and new__parent_id not in (-100,-200) and new__package_id is null then
        v_package_id := acs_object__package_id(content_item__get_root_folder(new__parent_id));
    end if;

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
        v_package_id
    );

    insert into cr_folders (
      folder_id, label, description, package_id
    ) values (
      v_folder_id, new__label, new__description, v_package_id
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
