-- Create lessons table
create table if not exists public.lessons (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  title       text not null default '',
  content     jsonb not null default '{}',
  lesson_type text not null default 'school',
  status      text not null default 'draft',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Index for fast per-user queries (used by getLessonsService)
create index if not exists lessons_user_id_idx
  on public.lessons(user_id, created_at desc);

-- Enable RLS
alter table public.lessons enable row level security;

-- Users can only read their own lessons
create policy "users can read own lessons"
  on public.lessons for select
  using (auth.uid() = user_id);

-- Users can insert their own lessons
create policy "users can insert own lessons"
  on public.lessons for insert
  with check (auth.uid() = user_id);

-- Users can update their own lessons
create policy "users can update own lessons"
  on public.lessons for update
  using (auth.uid() = user_id);

-- Users can delete their own lessons
create policy "users can delete own lessons"
  on public.lessons for delete
  using (auth.uid() = user_id);
