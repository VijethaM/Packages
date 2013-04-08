<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<fullquery name="task_insert">
    <querytext>
	SELECT im_timesheet_task__new (
		null,		-- p_task_id
		'im_timesheet_task',	-- object_type
		now(),			-- creation_date
		null,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id

		:task_nr,
		:task_name,
		:project_id,
		:task_material_id,
		:task_cost_center_id,
		:task_uom_id,
		:task_type_id,
		:task_status_id,
		:task_note
	);

    </querytext>
</fullquery>


<fullquery name="task_delete">
    <querytext>
    BEGIN
	PERFORM im_task__delete (:task_id);
	return 0;
    END;
    </querytext>
</fullquery>


<fullquery name="task_update">
    <querytext>
	update im_timesheet_tasks set
		material_id	= :task_material_id,
		cost_center_id	= :task_cost_center_id,
		uom_id 		= :task_uom_id,
		planned_units	= :task_planned_units,
		billable_units	= :task_billable_units
	where
		task_id = :task_id;
    </querytext>
</fullquery>


<fullquery name="task_project_update">
    <querytext>
	update im_projects set
		project_name	= :task_name,
                parent_id       = :project_id,
		project_nr	= :task_nr,
		project_type_id	= :task_type_id,
		project_status_id = :task_status_id,
		note		= :task_note,
		percent_completed = :task_percent_completed,
        	created_by		= $current_user_id,
	start_date ='$task_start_date'::date,
	end_date='$task_end_date'::date,
	task_position=$task_position

	where
		project_id = :task_id;
    </querytext>
</fullquery>


</queryset>
