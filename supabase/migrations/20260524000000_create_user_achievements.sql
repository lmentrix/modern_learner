create table if not exists public.user_achievements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  achievement_id text not null,
  progress_value integer not null default 0 check (progress_value >= 0),
  unlocked_at    timestamptz,
  seen_at        timestamptz,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (user_id, achievement_id)
);

drop trigger if exists user_achievements_updated_at
  on public.user_achievements;

create trigger user_achievements_updated_at
  before update on public.user_achievements
  for each row execute function public.set_updated_at();

create index if not exists user_achievements_user_unlocked_idx
  on public.user_achievements (user_id, unlocked_at desc)
  where unlocked_at is not null;

create index if not exists user_achievements_user_seen_idx
  on public.user_achievements (user_id, seen_at)
  where unlocked_at is not null and seen_at is null;

alter table public.user_achievements enable row level security;

create policy "achievements: owner select"
  on public.user_achievements for select
  using ((select auth.uid()) = user_id);

create policy "achievements: owner insert"
  on public.user_achievements for insert
  with check ((select auth.uid()) = user_id);

create policy "achievements: owner update"
  on public.user_achievements for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "achievements: owner delete"
  on public.user_achievements for delete
  using ((select auth.uid()) = user_id);
