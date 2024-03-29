
<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>





<fullquery name="task_insert">
    <querytext>
  SELECT im_timesheet_task__new (
    :task_id,   -- p_task_id
    'im_timesheet_task',  -- object_type
    now(),      -- creation_date
    null,     -- creation_user
    null,     -- creation_ip
    null,     -- context_id

    :task_nr1,
    :task_name1,
    :pr_id,
    :material_id,   -- material_id
    :cost_center_id, -- cost_center_id
    :uom_id,        -- uom_id
    :task_type_id,  -- task_type_id,
    :task_status_id, -- task_status_id
    :note           --note
  );

    </querytext>
</fullquery>


<fullquery name="task_delete">
    <querytext>
    BEGIN
  PERFORM im_task__delete (:task_id1);
  return 0;
    END;
    </querytext>
</fullquery>


<fullquery name="task_update">
    <querytext>
  update im_timesheet_tasks set
    material_id = :material_id,
    cost_center_id  = :cost_center_id,
    uom_id      = :uom_id,
    planned_units   = :planned_units,
    billable_units  = :billable_units
  where
    task_id = :task_id1;
    </querytext>
</fullquery>


<fullquery name="project_update">
    <querytext>
  update im_projects set
    project_name  = :task_name1,
    parent_id       = :project_id1,
    project_nr  = :task_nr1,
   project_type_id  = :task_type_id,
    project_status_id = :task_status_id,
    note    = :desc1,
    percent_completed = 0,
    start_date      = :current_date,
    end_date        = :current_date,
    created_by    = $user_id

  where
    project_id = :task_id1;
    </querytext>
</fullquery>

</queryset>