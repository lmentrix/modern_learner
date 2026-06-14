alter table public.roadmaps
  add column if not exists generated_roadmap_json jsonb;

update public.roadmaps
set generated_roadmap_json = roadmap_json
where generated_roadmap_json is null;

update public.roadmaps r
set course_id = (
  select uc.id
  from public.user_courses uc
  where uc.user_id = r.user_id
    and uc.topic = r.topic
    and uc.roadmap_language = r.roadmap_language
    and uc.level = r.level
    and uc.native_language = r.native_language
  order by uc.updated_at desc, uc.created_at desc
  limit 1
)
where r.course_id is null
  and exists (
    select 1
    from public.user_courses uc
    where uc.user_id = r.user_id
      and uc.topic = r.topic
      and uc.roadmap_language = r.roadmap_language
      and uc.level = r.level
      and uc.native_language = r.native_language
  );

update public.roadmap_chapter_progress rcp
set course_id = r.course_id
from public.roadmaps r
where rcp.course_id is null
  and r.course_id is not null
  and r.user_id = rcp.user_id
  and coalesce(
    r.generated_roadmap_json ->> 'id',
    r.generated_roadmap_json #>> '{roadmap,id}',
    r.roadmap_json ->> 'id',
    r.roadmap_json #>> '{roadmap,id}'
  ) = rcp.roadmap_id;

delete from public.roadmap_chapter_progress rcp
where rcp.course_id is null
  or not exists (
    select 1
    from public.user_courses uc
    where uc.id = rcp.course_id
  );

delete from public.roadmaps r
where r.course_id is null
  or not exists (
    select 1
    from public.user_courses uc
    where uc.id = r.course_id
  );

do $$
declare
  fk_name text;
begin
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    join pg_attribute a on a.attrelid = t.oid
      and a.attnum = any(c.conkey)
    where n.nspname = 'public'
      and t.relname = 'roadmaps'
      and c.contype = 'f'
      and a.attname = 'course_id'
  loop
    execute format('alter table public.roadmaps drop constraint %I', fk_name);
  end loop;
end $$;

alter table public.roadmaps
  alter column course_id set not null,
  alter column generated_roadmap_json set not null,
  add constraint roadmaps_course_id_fkey
  foreign key (course_id)
  references public.user_courses(id)
  on delete cascade;

do $$
declare
  fk_name text;
begin
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    join pg_attribute a on a.attrelid = t.oid
      and a.attnum = any(c.conkey)
    where n.nspname = 'public'
      and t.relname = 'roadmap_chapter_progress'
      and c.contype = 'f'
      and a.attname = 'course_id'
  loop
    execute format(
      'alter table public.roadmap_chapter_progress drop constraint %I',
      fk_name
    );
  end loop;
end $$;

alter table public.roadmap_chapter_progress
  alter column course_id set not null,
  add constraint roadmap_chapter_progress_course_id_fkey
  foreign key (course_id)
  references public.user_courses(id)
  on delete cascade;
