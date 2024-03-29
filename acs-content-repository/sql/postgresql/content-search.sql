-- @cvs-id $Id: content-search.sql,v 1.2 2010/10/19 20:10:35 po34demo Exp $ 
------------------------------------------------------------
-- declare CR as a content provider for search/indexing interface
------------------------------------------------------------


select acs_sc_impl__new(
	   'FtsContentProvider',		-- impl_contract_name
           'content_revision',                  -- impl_name
	   'acs-content-repository'             -- impl_owner_name
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'content_revision',                  -- impl_name
	   'datasource',			-- impl_operation_name
	   'content_search__datasource',        -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'content_revision',                  -- impl_name
	   'url',				-- impl_operation_name
	   'content_search__url',               -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_binding__new('FtsContentProvider','content_revision');

select acs_sc_impl__new(
	   'FtsContentProvider',		-- impl_contract_name
           'image',                             -- impl_name
	   'acs-content-repository'             -- impl_owner_name
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'image',                             -- impl_name
	   'datasource',			-- impl_operation_name
	   'image_search__datasource',          -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'image',                             -- impl_name
	   'url',				-- impl_operation_name
	   'image_search__url',                 -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_binding__new('FtsContentProvider','image');

select acs_sc_impl__new(
	   'FtsContentProvider',		-- impl_contract_name
           'content_template',                  -- impl_name
	   'acs-content-repository'             -- impl_owner_name
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'content_template',                  -- impl_name
	   'datasource',			-- impl_operation_name
	   'template_search__datasource',       -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'content_template',                  -- impl_name
	   'url',				-- impl_operation_name
	   'template_search__url',              -- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_binding__new('FtsContentProvider','content_template');

-- triggers queue search interface to modify search index after content
-- changes.

-- DaveB: We only want to index live_revisions 2002-09-26



create function content_search__itrg ()
returns opaque as '
begin
if (select live_revision from cr_items where item_id=new.item_id) = new.revision_id and new.publish_date >= current_timestamp then
        perform search_observer__enqueue(new.revision_id,''INSERT'');
    end if;
    return new;
end;' language 'plpgsql';

create function content_search__dtrg ()
returns opaque as '
begin
    perform search_observer__enqueue(old.revision_id,''DELETE'');
    return old;
end;' language 'plpgsql';

create or replace function content_search__utrg ()
returns opaque as '
declare
    v_live_revision integer;
begin
    select into v_live_revision live_revision from
        cr_items where item_id=old.item_id;
    if old.revision_id=v_live_revision
      and new.publish_date <= current_timestamp then
        insert into search_observer_queue (
            object_id,
            event
        ) values (
old.revision_id,
            ''UPDATE''
        );
    end if;
    return new;
end;' language 'plpgsql';

-- we need new triggers on cr_items to index when a live revision
-- changes -DaveB 2002-09-26

create function content_item_search__utrg ()
returns opaque as '
begin
    if new.live_revision is not null and coalesce(old.live_revision,0) <> new.live_revision and (select publish_date from cr_revisions where revision_id=new.live_revision) <= current_timestamp then
        perform search_observer__enqueue(new.live_revision,''INSERT'');        
    end if;

    if old.live_revision is not null and old.live_revision <> coalesce(new.live_revision,0) then
        perform search_observer__enqueue(old.live_revision,''DELETE'');
    end if;
    if new.publish_status = ''expired'' then
        perform search_observer__enqueue(old.live_revision,''DELETE'');
    end if;

    return new;
end;' language 'plpgsql';

create trigger content_search__itrg after insert on cr_revisions
for each row execute procedure content_search__itrg (); 

create trigger content_search__dtrg after delete on cr_revisions
for each row execute procedure content_search__dtrg (); 

create trigger content_search__utrg after update on cr_revisions
for each row execute procedure content_search__utrg (); 


create trigger content_item_search__utrg before update on cr_items
for each row execute procedure content_item_search__utrg ();
