--
-- file-storage/sql/postgresql/file-storage-package-create.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Nov 2000
-- @cvs-id $Id: file-storage-package-create.sql,v 1.2 2011/01/19 11:33:52 kpmg Exp $
--

create or replace function file_storage__get_root_folder (
       --
       -- Returns the root folder corresponding to a particular
       -- package instance.
       --
       integer        -- apm_packages.package_id%TYPE
)
returns integer as '  -- fs_root_folders.folder_id%TYPE 
declare
        get_root_folder__package_id  alias for $1;
        v_folder_id                  fs_root_folders.folder_id%TYPE;
begin
        select folder_id into v_folder_id 
        from fs_root_folders
        where package_id = get_root_folder__package_id;

        return v_folder_id;

end;' language 'plpgsql' stable;

create or replace function file_storage__get_package_id (
    integer                     -- cr_items.item_id%TYPE
) returns integer as '          -- fs_root_folders.package_id%TYPE
declare
    get_package_id__item_id     alias for $1;
    v_package_id                fs_root_folders.package_id%TYPE;
    v_tree_sortkey              cr_items.tree_sortkey%TYPE;
begin

    select fs_root_folders.package_id
    into v_package_id
    from fs_root_folders,
        (select cr_items.item_id 
           from (select tree_ancestor_keys(cr_items_get_tree_sortkey(get_package_id__item_id)) as tree_sortkey) parents,
             cr_items
          where cr_items.tree_sortkey = parents.tree_sortkey) this
    where fs_root_folders.folder_id = this.item_id;

    if NOT FOUND then
        return null;
    else
        return v_package_id;
    end if;

end;' language 'plpgsql' stable;

create or replace function file_storage__new_root_folder (
       --
       -- Creates a new root folder
       --
       -- 
       -- A hackish function to get around the fact that we can not run
       -- code automatically when a new package instance is created.
       --
       integer,         -- apm_packages.package_id%TYPE
       varchar,         -- cr_folders.label%TYPE
       varchar,          -- cr_items.name%TYPE
       varchar
)
returns integer as '    --  fs_root_folders.folder_id%TYPE
declare
        new_root_folder__package_id         alias for $1;
        new_root_folder__folder_name        alias for $2;
	new_root_folder__url	            alias for $3;
        new_root_folder__description        alias for $4;
        v_folder_id                         fs_root_folders.folder_id%TYPE;
begin


        v_folder_id := content_folder__new (
            new_root_folder__url, -- name
            new_root_folder__folder_name, -- label
	    new_root_folder__description, -- description
            null,  -- parent_id (default)
	    new_root_folder__package_id, --context_id
	    null, --folder_id
	    null, --creation_date
	    null, --creation_user
	    null, --creation_ip
            new_root_folder__package_id --package_id
	);

        insert into fs_root_folders 
        (package_id, folder_id)
        values 
        (new_root_folder__package_id, v_folder_id);

        -- allow child items to be added
        -- JS: Note that we need to set include_subtypes to 
        -- JS: true since we created a new subtype.
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_revision'',   -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_folder'',     -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_symlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_extlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );

        return v_folder_id;

end;' language 'plpgsql';
    

create or replace function file_storage__new_file(
       -- 
       -- Create a file in CR in preparation for actual storage
       -- Wrapper for content_item__new
       --
       -- DRB: I added this version to allow one to predefine item_id, among other things to
       -- make it easier to use with ad_form
       varchar,         -- cr_items.name%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar,         -- acs_objects.creation_ip%TYPE,
       boolean,         -- store in db? 
       integer,           -- cr_items.item_id%TYPE,
       integer        -- apm_packages.package_id%TYPE
) returns integer as ' -- cr_items.item_id%TYPE
declare
        new_file__name                 alias for $1;
        new_file__folder_id             alias for $2;
        new_file__user_id               alias for $3;
        new_file__creation_ip           alias for $4;
        new_file__indb_p                alias for $5;
        new_file__item_id               alias for $6;
        new_file__package_id            alias for $7;
        v_item_id                       integer;
begin

        if new_file__indb_p
        then 
            v_item_id := content_item__new (
                        new_file__name,            -- name
                        new_file__folder_id,      -- parent_id
                        new_file__item_id,        -- item_id (default)
                        null,                       -- locale (default)
                        now(),              -- creation_date (default)
                        new_file__user_id,        -- creation_user
                        new_file__folder_id,      -- context_id
                        new_file__creation_ip,    -- creation_ip
                        ''content_item'',         -- item_subtype (default)
                        ''file_storage_object'',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        ''text/plain'',     -- mime_type (default)
                        null,                       -- nls_language (default)
                        null,                       -- data (default)
                        new_file__package_id        -- package_id
                    );
        else
            v_item_id := content_item__new (
                        new_file__name,            -- name
                        new_file__folder_id,        -- parent_id
                        new_file__item_id,          -- item_id (default)
                        null,                       -- locale (default)
                        now(),              -- creation_date (default)
                        new_file__user_id,          -- creation_user
                        new_file__folder_id,        -- context_id
                        new_file__creation_ip,    -- creation_ip
                        ''content_item'',         -- item_subtype (default)
                        ''file_storage_object'',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        ''text/plain'',     -- mime_type (default)
                        null,                       -- nls_language (default)
                        null,                       -- text (default)
                        ''file'',                   -- storage_type
                        new_file__package_id        -- package_id
                    );

        end if;

        perform acs_object__update_last_modified(new_file__folder_id,new_file__user_id,new_file__creation_ip);

        return v_item_id;

end;' language 'plpgsql';
    

create or replace function file_storage__new_file(
       varchar,         -- cr_items.name%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar,         -- acs_objects.creation_ip%TYPE,
       boolean,          -- store in db? 
       integer        -- apm_packages.package_id%TYPE       
) returns integer as ' -- cr_items.item_id%TYPE
declare
        new_file__name                  alias for $1;
        new_file__folder_id             alias for $2;
        new_file__user_id               alias for $3;
        new_file__creation_ip           alias for $4;
        new_file__indb_p                alias for $5;
        new_file__package_id            alias for $6;
begin
        return file_storage__new_file(
             new_file__name,            -- name
             new_file__folder_id,       -- parent_id
             new_file__user_id,         -- creation_user
             new_file__creation_ip,     -- creation_ip
             new_file__indb_p,          -- storage_type
             null,                      -- item_id
             new_file__package_id       -- pacakge_id
        );

end;' language 'plpgsql';


create or replace function file_storage__delete_file (
       --
       -- Delete a file and all its version
       -- Wrapper to content_item__delete
       --
       integer          -- cr_items.item_id%TYPE
) returns integer as '
declare
        delete_file__file_id    alias for $1;
begin

        return content_item__delete(delete_file__file_id);

end;' language 'plpgsql';


create or replace function file_storage__rename_file (
       --
       -- Rename a file and all
       -- Wrapper to content_item__edit_name
       --
       integer,         -- cr_items.item_id%TYPE,
       varchar          -- cr_items.name%TYPE
) returns integer as '
declare
        rename_file__file_id    alias for $1;
        rename_file__name      alias for $2;

begin

        return content_item__edit_name(
               rename_file__file_id,  -- item_id
               rename_file__name     -- name
               );

end;' language 'plpgsql';

create or replace function file_storage__copy_file(
       --
       -- Copy a file, but only copy the live_revision
       --
       integer,         -- cr_items.item_id%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar          -- acs_objects.creation_ip%TYPE
) returns integer as '  -- cr_revisions.revision_id%TYPE
declare
        copy_file__file_id           alias for $1;
        copy_file__target_folder_id  alias for $2;
        copy_file__creation_user     alias for $3;
        copy_file__creation_ip       alias for $4;
        v_name                      cr_items.name%TYPE;
        v_live_revision              cr_items.live_revision%TYPE;
        v_filename                   cr_revisions.title%TYPE;
        v_description                cr_revisions.description%TYPE;
        v_mime_type                  cr_revisions.mime_type%TYPE;
        v_content_length             cr_revisions.content_length%TYPE;
        v_lob_id                     cr_revisions.lob%TYPE;
        v_new_lob_id                 cr_revisions.lob%TYPE;
        v_file_path                  cr_revisions.content%TYPE;
        v_new_file_id                cr_items.item_id%TYPE;
        v_new_version_id                     cr_revisions.revision_id%TYPE;
        v_indb_p                     boolean;
        v_isurl                      boolean;
        v_content_type               cr_items.content_type%TYPE;
        v_package_id                 apm_packages.package_id%TYPE;
begin

        v_isurl:= false;
        select content_type into v_content_type from cr_items where item_id = copy_file__file_id;
        if v_content_type = ''content_extlink''
        then
          v_isurl:= true;
        end if;

        -- We copy only the title from the file being copied, and attributes of the live revision
        if v_isurl = false
        then
          select i.name,i.live_revision,r.title,r.description,r.mime_type,r.content_length,
               (case when i.storage_type = ''lob''
                     then true
                     else false
                end)
               into v_name,v_live_revision,v_filename,v_description,v_mime_type,v_content_length,v_indb_p
          from cr_items i, cr_revisions r
          where r.item_id = i.item_id
          and   r.revision_id = i.live_revision
          and   i.item_id = copy_file__file_id;

          select package_id into v_package_id from acs_objects where object_id = copy_file__file_id;

          v_new_file_id := file_storage__new_file(
                             v_name,                     -- name
                             copy_file__target_folder_id, -- folder_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip,      -- creation_ip
                             v_indb_p,                    -- indb_p
                             v_package_id                 -- package_id
                             );

          v_new_version_id := file_storage__new_version (
                             v_filename,                  -- title
                             v_description,               -- description
                             v_mime_type,                 -- mime_type
                             v_new_file_id,               -- item_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip       -- creation_ip
                             );

          if v_indb_p
          then

                -- Lob to copy from
                select lob into v_lob_id
                from cr_revisions
                where revision_id = v_live_revision;

                -- New lob id
                v_new_lob_id := empty_lob();

                -- copy the blob
                perform lob_copy(v_lob_id,v_new_lob_id);

                -- Update the lob id on the new version
                update cr_revisions
                set lob = v_new_lob_id,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

          else
               -- For now, we simply copy the file name
                select content into v_file_path
                from cr_revisions
                where revision_id = v_live_revision;

                -- Update the file path
                update cr_revisions
                set content = v_file_path,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

          end if;
          perform acs_object__update_last_modified(copy_file__target_folder_id,copy_file__creation_user,copy_file__creation_ip);
          return v_new_version_id;
        else
          perform content_extlink__copy (copy_file__file_id, copy_file__target_folder_id, copy_file__creation_user,copy_file__creation_ip,v_name);
          return 0;
        end if;

end;' language 'plpgsql';

create or replace function file_storage__move_file (
       --
       -- Move a file (ans all its versions) to a different folder.
       -- Wrapper for content_item__move
       -- 
       integer,         -- cr_folders.folder_id%TYPE,
       integer,         -- cr_folders.folder_id%TYPE
       integer,         -- ceration_user
       varchar          -- creation_ip
) returns integer as '  -- 0 for success 
declare
        move_file__file_id              alias for $1;
        move_file__target_folder_id     alias for $2;
        move_file__creation_user        alias for $3;
        move_file__creation_ip          alias for $4;
begin

        perform content_item__move(
               move_file__file_id,              -- item_id
               move_file__target_folder_id      -- target_folder_id
               );

        perform acs_object__update_last_modified(move_file__target_folder_id,move_file__creation_user,move_file__creation_ip);

        return 0;
end;' language 'plpgsql';


create or replace function file_storage__get_title (
       --
       integer          -- cr_items.item_id%TYPE
) returns varchar as ' 
declare
  get_title__item_id                 alias for $1;  
  v_title                            cr_revisions.title%TYPE;
  v_content_type                     cr_items.content_type%TYPE;
begin
  
  select content_type into v_content_type 
  from cr_items 
  where item_id = get_title__item_id;

  if v_content_type = ''content_folder'' 
  then
      select label into v_title 
      from cr_folders 
      where folder_id = get_title__item_id;
  else if v_content_type = ''content_symlink'' 
       then
         select label into v_title from cr_symlinks 
         where symlink_id = get_title__item_id;
       else
         select title into v_title
         from cr_revisions, cr_items
         where revision_id=live_revision
	 and cr_items.item_id=get_title__item_id;
       end if;
  end if;

  return v_title;

end;' language 'plpgsql';

create or replace function file_storage__get_parent_id (
        integer --  item_id in cr_items.item_id%TYPE
     ) returns integer as ' -- cr_items.item_id%TYPE
     declare 
         get_parent_id__item_id alias for $1;
         v_parent_id          cr_items.item_id%TYPE;
     begin

         select parent_id
         into v_parent_id
         from cr_items
         where item_id = get_parent_id__item_id;

       return v_parent_id;

end;'language 'plpgsql';


create or replace function file_storage__get_content_type (
       --
       -- Wrapper for content_item__get_content_type
       integer          -- cr_items.item_id%TYPE
) returns varchar as '  -- cr_items.content_type%TYPE
declare
        get_content_type__file_id       alias for $1;
begin
        return content_item__get_content_type(
                          get_content_type__file_id
                          );

end;' language 'plpgsql';  



create or replace function file_storage__get_folder_name (
       --
       -- Wrapper for content_folder__get_label
       integer          -- cr_folders.folder_id%TYPE
) returns varchar as '  -- cr_folders.label%TYPE 
declare
        get_folder_name__folder_id      alias for $1;
begin
        return content_folder__get_label(
                          get_folder_name__folder_id
                          );

end;' language 'plpgsql';  


create or replace function file_storage__new_version (
       --
       -- Create a new version of a file
       -- Wrapper for content_revision__new
       --
       varchar,         -- cr_revisions.title%TYPE,
       varchar,         -- cr_revisions.description%TYPE,
       varchar,         -- cr_revisions.mime_type%TYPE,
       integer,         -- cr_items.item_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar          -- acs_objects.creation_ip%TYPE
) returns integer as '  -- cr_revisions.revision_id 
declare
        new_version__filename           alias for $1;
        new_version__description        alias for $2;
        new_version__mime_type          alias for $3;
        new_version__item_id            alias for $4;
        new_version__creation_user      alias for $5;
        new_version__creation_ip        alias for $6;
        v_revision_id                   cr_revisions.revision_id%TYPE;
        v_folder_id                     cr_items.parent_id%TYPE;
begin
        -- Create a revision
        v_revision_id := content_revision__new (
                          new_version__filename,        -- title
                          new_version__description,     -- description
                          now(),                        -- publish_date
                          new_version__mime_type,       -- mime_type
                          null,                         -- nls_language
                          null,                         -- data (default)
                          new_version__item_id,         -- item_id
                          null,                         -- revision_id
                          now(),                        -- creation_date
                          new_version__creation_user,   -- creation_user
                          new_version__creation_ip      -- creation_ip
                          );

        -- Make live the newly created revision
        perform content_item__set_live_revision(v_revision_id);

        select cr_items.parent_id
        into v_folder_id
        from cr_items
        where cr_items.item_id = new_version__item_id;

        perform acs_object__update_last_modified(v_folder_id,new_version__creation_user,new_version__creation_ip);
    	perform acs_object__update_last_modified(new_version__item_id,new_version__creation_user,new_version__creation_ip);

        return v_revision_id;

end;' language 'plpgsql';


create or replace function file_storage__delete_version (
       --
       -- Delete a version of a file
       --
       integer, -- cr_items.item_id%TYPE,
       integer  -- cr_revisions.revision_id%TYPE
) returns integer as ' -- cr_items.parent_id%TYPE
declare
        delete_version__file_id         alias for $1;
        delete_version__version_id      alias for $2;
        v_parent_id                     cr_items.parent_id%TYPE;
        v_deleted_last_version_p        boolean;
begin

        if delete_version__version_id = content_item__get_live_revision(delete_version__file_id) 
        then
            PERFORM content_revision__delete(delete_version__version_id);
            PERFORM content_item__set_live_revision(
                        content_item__get_latest_revision(delete_version__file_id)
                        );
        else
            PERFORM content_revision__delete(delete_version__version_id);
        end if;

        -- If the live revision is null, we have deleted the last version above
        select (case when live_revision is null
                     then parent_id
                     else 0
                end)
          into v_parent_id 
        from cr_items
        where item_id = delete_version__file_id;

        -- Unfortunately, due to PostgreSQL behavior with regards referential integrity,
        -- we cannot delete the content_item entry if there are no more revisions.
        return v_parent_id;

end;' language 'plpgsql';


create or replace function file_storage__new_folder(
       --
       -- Create a folder
       --
       varchar,         -- cr_items.name%TYPE,
       varchar,         -- cr_folders.label%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,       
       varchar          -- acs_objects.creation_ip%TYPE       
) returns integer as '  -- cr_folders.folder_id%TYPE
declare
        new_folder__name              alias for $1;
        new_folder__folder_name       alias for $2;
        new_folder__parent_id         alias for $3;
        new_folder__creation_user     alias for $4;
        new_folder__creation_ip       alias for $5;
        v_folder_id                   cr_folders.folder_id%TYPE;
        v_package_id                  acs_objects.package_id%TYPE;
begin
        v_package_id := file_storage__get_package_id(new_folder__parent_id);

        -- Create a new folder
        v_folder_id := content_folder__new (
                            new_folder__name,           -- name
                            new_folder__folder_name,    -- label
                            null,                       -- description
                            new_folder__parent_id,      -- parent_id
                            null,                       -- context_id (default)
                            null,                       -- folder_id (default)
                            now(),                      -- creation_date
                            new_folder__creation_user,  -- creation_user
                            new_folder__creation_ip,    -- creation_ip
                            v_package_id                -- package_id
                            );

        -- register the standard content types
        -- JS: Note that we need to set include_subtypes 
        -- JS: to true since we created a new subtype.
        PERFORM content_folder__register_content_type(
                        v_folder_id,            -- folder_id
                        ''content_revision'',   -- content_type
                        ''t'');                 -- include_subtypes (default)

        PERFORM content_folder__register_content_type(
                        v_folder_id,            -- folder_id
                        ''content_folder'',     -- content_type
                        ''t''                   -- include_subtypes (default)
                        );                      

        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_extlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );

        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_symlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );

        -- Give the creator admin privileges on the folder
        PERFORM acs_permission__grant_permission (
                     v_folder_id,                -- object_id
                     new_folder__creation_user,  -- grantee_id
                     ''admin''                   -- privilege
                     );

        return v_folder_id;

end;' language 'plpgsql';


create or replace function file_storage__delete_folder(
       --
       -- Delete a folder
       --
       integer          -- cr_folders.folder_id%TYPE
) returns integer as '  -- 0 for success
declare
        delete_folder__folder_id        alias for $1; 
begin

        return file_storage__delete_folder(
                    delete_folder__folder_id,  -- folder_id
                    ''f''
                    );

end;' language 'plpgsql';

create or replace function file_storage__delete_folder(
       --
       -- Delete a folder
       --
       integer,          -- cr_folders.folder_id%TYPE
       boolean
) returns integer as '  -- 0 for success
declare
        delete_folder__folder_id        alias for $1; 
        delete_folder__cascade_p        alias for $2;
begin

        return content_folder__delete(
                    delete_folder__folder_id,  -- folder_id
                    delete_folder__cascade_p
                    );

end;' language 'plpgsql';



-- Fraber: No idea why this trigger could already exist, but it does...
create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from pg_trigger
        where lower(tgname) = ''fs_package_items_delete_trig'';
        if v_count = 0 then return 0; end if;

	drop function fs_package_items_delete_trig () cascade;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-- JS: BEFORE DELETE TRIGGER to clean up CR entries (except root folder)
create or replace function fs_package_items_delete_trig () returns opaque as '
declare

        v_rec   record;
begin

        for v_rec in
        
                -- We want to delete all cr_items entries, starting from the leaves all
                --  the way up the root folder (old.folder_id).
                select c1.item_id, c1.content_type
                from cr_items c1, cr_items c2
                where c2.item_id = old.folder_id
                  and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
                  and c1.item_id <> old.folder_id
                order by c1.tree_sortkey desc
        loop

                -- DRB: Why can''t we just use object delete here?


                -- We delete the item. On delete cascade should take care
                -- of deletion of revisions.
                if v_rec.content_type = ''file_storage_object''
                then
                    raise notice ''Deleting item_id = %'',v_rec.item_id;
                    PERFORM content_item__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = ''content_folder''
                then
                    raise notice ''Deleting folder_id = %'',v_rec.item_id;
                    PERFORM content_folder__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = ''content_symlink''
                then
                    raise notice ''Deleting symlink_id = %'',v_rec.item_id;
                    PERFORM content_symlink__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = ''content_extlink''
                then
                    raise notice ''Deleting folder_id = %'',v_rec.item_id;
                    PERFORM content_extlink__delete(v_rec.item_id);
                end if;

        end loop;

        -- We need to return something for the trigger to be activated
        return old;

end;' language 'plpgsql';

create trigger fs_package_items_delete_trig before delete
on fs_root_folders for each row 
execute procedure fs_package_items_delete_trig ();


-- JS: AFTER DELETE TRIGGER to clean up last CR entry
create or replace function fs_root_folder_delete_trig () returns opaque as '
begin
        PERFORM content_folder__delete(old.folder_id);
        return null;

end;' language 'plpgsql';

create trigger fs_root_folder_delete_trig after delete
on fs_root_folders for each row 
execute procedure fs_root_folder_delete_trig ();

-- Comment out to disable site-wide search  interface
\i file-storage-sc-create.sql
