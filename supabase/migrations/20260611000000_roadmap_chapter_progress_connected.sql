alter table if exists public.roadmap_chapter_progress
  add column if not exists completed_subcontents integer not null default 0,
  add column if not exists total_subcontents integer not null default 0;

do $$
begin
  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'roadmap_chapter_progress'
      and c.conname = 'roadmap_chapter_progress_course_id_fkey'
  ) then
    alter table public.roadmap_chapter_progress
      add constraint roadmap_chapter_progress_course_id_fkey
      foreign key (course_id) references public.user_courses(id) on delete cascade;
  end if;
end $$;
