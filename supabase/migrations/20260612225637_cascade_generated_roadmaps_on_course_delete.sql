alter table public.roadmaps
  add column if not exists generated_roadmap_json jsonb;

update public.roadmaps
set generated_roadmap_json = roadmap_json
where generated_roadmap_json is null;

delete from public.roadmaps
where course_id is null;

delete from public.roadmaps r
where r.course_id is not null
  and not exists (
    select 1
    from public.user_courses c
    where c.id = r.course_id
  );

delete from public.roadmap_chapter_progress
where course_id is null;

delete from public.roadmap_chapter_progress rcp
where rcp.course_id is not null
  and not exists (
    select 1
    from public.user_courses c
    where c.id = rcp.course_id
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
