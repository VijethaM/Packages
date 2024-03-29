ad_library {

    Procs to add, edit, and remove notes for My First Package.

    @author oumi@arsdigita.com
    @cvs-id $Id: note-procs.tcl,v 1.2 2010/10/19 20:11:07 po34demo Exp $

}

namespace eval mfp {}
namespace eval mfp::note {}

ad_proc -public mfp::note::get {
    -item_id:required
    -array:required
} { 
    This proc retrieves a note.  This is annoying code that is only
    here because we wanted to give you a working tutorial in 5.0 that
    uses content repository, but the tcl api for content repository
    won't be complete until 5.1.  At least we can use the pregenerated views for select and edit.
} {
    upvar 1 $array row
    db_1row note_select {
	select ci.item_id,
	       n.title
	from   cr_items ci,
               mfp_notesx n
       where   ci.item_id = :item_id
       and     n.note_id = ci.live_revision
    } -column_array row
}

ad_proc -public mfp::note::add {
    -title:required
} { 
    This proc adds a note.  
    @return item_id of the new note.
} {
    db_transaction {
	set item_id [db_exec_plsql note_insert {
	    select content_item__new(:title,-100,null,null,null,null,null,null,'content_item','mfp_note',:title,null,null,null,null)
	}]

	set revision_id [db_nextval acs_object_id_seq]
	
	db_dml revision_add {
 	    insert into mfp_notesi (item_id, revision_id, title) 
	    values (:item_id, :revision_id, :title)
	}

	db_exec_plsql make_live {
	    select content_item__set_live_revision(:revision_id)
	}
    }
    return $item_id
}

ad_proc -public mfp::note::edit {
    -item_id:required
    -title:required
} { 
    This proc edits a note. Note that to edit a cr_item, you insert a new revision instead of changing the current revision.
} {
    db_transaction {
	set revision_id [db_nextval acs_object_id_seq]
	
	db_dml revision_add {
 	    insert into mfp_notesi (item_id, revision_id, title) 
	    values (:item_id, :revision_id, :title)
	}

	db_exec_plsql make_live {
	    select content_item__set_live_revision(:revision_id)
	}
    }
}

ad_proc -public mfp::note::delete {
    -item_id:required
} { 
    This proc deletes a note.
} {
    db_exec_plsql note_delete {
	select content_item__delete(:item_id)
    }
}
