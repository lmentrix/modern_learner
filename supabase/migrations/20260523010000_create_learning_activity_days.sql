create table if not exists public.learning_activity_days (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  activity_date  date not null,
  active_seconds integer not null default 0 check (active_seconds >= 0),
  sessions_count integer not null default 0 check (sessions_count >= 0),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (user_id, activity_date)
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists learning_activity_days_updated_at
  on public.learning_activity_days;

create trigger learning_activity_days_updated_at
  before update on public.learning_activity_days
  for each row execute function public.set_updated_at();

create index if not exists learning_activity_days_user_date_idx
  on public.learning_activity_days (user_id, activity_date desc);

alter table public.learning_activity_days enable row level security;

create policy "learning activity: owner select"
  on public.learning_activity_days for select
  using ((select auth.uid()) = user_id);

create policy "learning activity: owner insert"
  on public.learning_activity_days for insert
  with check ((select auth.uid()) = user_id);

create policy "learning activity: owner update"
  on public.learning_activity_days for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "learning activity: owner delete"
  on public.learning_activity_days for delete
  using ((select auth.uid()) = user_id);

create or replace function public.record_learning_activity_seconds(
  p_activity_date date,
  p_active_seconds integer
)
returns public.learning_activity_days
language plpgsql
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_row public.learning_activity_days;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  if p_activity_date is null then
    raise exception 'activity_date is required';
  end if;

  if p_active_seconds is null or p_active_seconds <= 0 then
    raise exception 'active_seconds must be greater than zero';
  end if;

  insert into public.learning_activity_days (
    user_id,
    activity_date,
    active_seconds,
    sessions_count
  )
  values (
    v_user_id,
    p_activity_date,
    p_active_seconds,
    1
  )
  on conflict (user_id, activity_date) do update
    set active_seconds = public.learning_activity_days.active_seconds
        + excluded.active_seconds,
        sessions_count = public.learning_activity_days.sessions_count + 1,
        updated_at = now()
  returning * into v_row;

  return v_row;
end;
$$;

revoke all on function public.record_learning_activity_seconds(date, integer)
  from public, anon;
grant execute on function public.record_learning_activity_seconds(date, integer)
  to authenticated;
