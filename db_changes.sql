CREATE TABLE im_vmc_brands (

       brand_id integer not null
                                                       constraint im_vmc_brands_pk primary key

       constraint im_vmc_brand_id_fk

                references acs_objects,

    brand_name character varying(100) unique,

description character varying(200),

company_id integer not null,

key_contact integer,

industry_category integer,

phone integer ,

email character varying(50),

logo_path character varying(60),

constraint im_industry_category_fk foreign key(industry_category) references im_categories(category_id),

constraint im_brand_contact_fk foreign key (key_contact) references users(user_id),

constraint im_vmc_company_id_fk foreign key (company_id)

references im_companies (company_id) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION);



insert into acs_object_types 

( object_type, pretty_name, pretty_plural, table_name, id_column,package_name)
values ('im_vmc_brands','brands','vmc_brands','im_vmc_brands','brand_id','intranet/companies');


CREATE TABLE im_vmc_products (

    product_id integer not null

        constraint im_vmc_product_pk primary key

        constraint im_vmc_product_fk references

        acs_objects,

    product_name character varying(100),

    description character varying(200),

    brand_id integer not null,

    constraint im_brand_id_fk foreign key (brand_id)
    references im_vmc_brands (brand_id));


insert into acs_object_types
( object_type, pretty_name, pretty_plural, table_name, id_column,package_name)
values
('im_vmc_products','product','products','im_vmc_products','product_id','intranet/companies/');

ALTER TABLE im_projects Add Column created_by integer;
ALTER TABLE im_projects Add constraint created_by_fk foreign key(created_by) references users(user_id);

-- For Tasks Duration and Documents Configuration :
create table im_vmc_config_tasks (project_type_id integer,task_name_id integer,doc_type_id1 integer,doc_mandatory1 boolean, doc_type_id2 integer, doc_mandatory2 boolean,doc_type_id3 integer, doc_mandatory3 boolean,duration integer, updated_on timestamp);
ALTER TABLE im_vmc_config_tasks ADD column num_docs integer;

insert into im_view_columns(view_id,group_id,column_name,column_render_tcl) values (910,NULL,'Members','"[im_biz_object_member_list_format $project_member_list]"');
ALTER TABLE im_projects ADD COLUMN task_position integer;
ALTER TABLE cr_items DROP Constraint cr_items_pub_status_chk;
 ALTER TABLE cr_items ADD CONSTRAINT cr_items_pub_status_chk CHECK (((((((publish_status)::text = 'production'::text) OR ((publish_status)::text = 'ready'::text)) OR ((publish_status)::text = 'live'::text)) OR ((publish_status)::text = 'expired'::text)) OR ((publish_status)::text = 'chekd_out'::text)));
 ALTER TABLE cr_items ADD COLUMN status_updated_by integer;
