-- Create lessons table for the new_lesson feature.
-- Stores user-created lessons with type (language/school) and optional AI content.

create table if not exists public.lessons (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  lesson_type  text not null check (lesson_type in ('language', 'school')),
  content_type text not null,
  difficulty   text not null default 'Beginner' check (difficulty in ('Beginner', 'Intermediate', 'Advanced')),
  title        text not null default '',
  content      jsonb,
  status       text not null default 'draft' check (status in ('draft', 'active', 'completed')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Auto-update updated_at on every row change.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger lessons_updated_at
  before update on public.lessons
  for each row execute procedure public.set_updated_at();

-- RLS: each user can only access their own lessons.
alter table public.lessons enable row level security;

create policy "lessons: owner select"
  on public.lessons for select
  using (auth.uid() = user_id);

create policy "lessons: owner insert"
  on public.lessons for insert
  with check (auth.uid() = user_id);

create policy "lessons: owner update"
  on public.lessons for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "lessons: owner delete"
  on public.lessons for delete
  using (auth.uid() = user_id);
