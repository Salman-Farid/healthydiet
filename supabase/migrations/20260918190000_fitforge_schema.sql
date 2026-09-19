-- FitForge schema for project ghhelxjabukfuoxiwqaj
create extension if not exists "pgcrypto";

create table if not exists public.exercises (
  id text primary key,
  name text not null,
  category text not null,
  body_part text not null,
  equipment text not null,
  instructions jsonb not null default '{}'::jsonb,
  instruction_steps jsonb not null default '{}'::jsonb,
  muscle_group text,
  secondary_muscles text[] not null default '{}',
  target text,
  media_id text,
  image_path text,
  gif_path text,
  image_url text,
  gif_url text,
  attribution text default '© Gym visual — https://gymvisual.com/',
  search_text text,
  created_at timestamptz default now()
);

create index if not exists exercises_category_idx on public.exercises (category);
create index if not exists exercises_equipment_idx on public.exercises (equipment);
create index if not exists exercises_target_idx on public.exercises (target);
create index if not exists exercises_name_idx on public.exercises (lower(name));
create index if not exists exercises_search_idx on public.exercises using gin (to_tsvector('english', coalesce(search_text, name)));

create table if not exists public.body_parts (
  slug text primary key,
  label text not null,
  emoji text,
  color_hex text,
  sort_order int default 0
);

create table if not exists public.equipment_types (
  slug text primary key,
  label text not null,
  icon text,
  sort_order int default 0
);

create table if not exists public.workout_templates (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  description text,
  focus text,
  level text default 'intermediate',
  estimated_minutes int default 45,
  accent_color text default '#C8F542',
  sort_order int default 0
);

create table if not exists public.workout_template_exercises (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.workout_templates(id) on delete cascade,
  exercise_id text not null references public.exercises(id) on delete cascade,
  position int not null default 0,
  default_sets int not null default 3,
  default_reps int not null default 10,
  default_rest_seconds int not null default 60,
  unique (template_id, exercise_id, position)
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  language text default 'en',
  weight_unit text default 'kg' check (weight_unit in ('kg','lb')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  template_slug text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  exercise_id text not null references public.exercises(id) on delete cascade,
  position int not null default 0,
  target_sets int not null default 3,
  target_reps int not null default 10,
  target_weight numeric,
  rest_seconds int not null default 60,
  notes text
);

create table if not exists public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_id uuid references public.workouts(id) on delete set null,
  workout_name text,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds int,
  total_sets int default 0,
  total_reps int default 0,
  total_volume numeric default 0,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.session_sets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id text not null references public.exercises(id),
  exercise_name text,
  set_index int not null,
  weight numeric default 0,
  reps int default 0,
  rpe numeric,
  completed_at timestamptz default now()
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  exercise_id text not null references public.exercises(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, exercise_id)
);

alter table public.exercises enable row level security;
alter table public.body_parts enable row level security;
alter table public.equipment_types enable row level security;
alter table public.workout_templates enable row level security;
alter table public.workout_template_exercises enable row level security;
alter table public.profiles enable row level security;
alter table public.workouts enable row level security;
alter table public.workout_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.session_sets enable row level security;
alter table public.favorites enable row level security;

-- Public catalog reads
drop policy if exists "public read exercises" on public.exercises;
create policy "public read exercises" on public.exercises for select using (true);
drop policy if exists "public read body_parts" on public.body_parts;
create policy "public read body_parts" on public.body_parts for select using (true);
drop policy if exists "public read equipment" on public.equipment_types;
create policy "public read equipment" on public.equipment_types for select using (true);
drop policy if exists "public read templates" on public.workout_templates;
create policy "public read templates" on public.workout_templates for select using (true);
drop policy if exists "public read template_exercises" on public.workout_template_exercises;
create policy "public read template_exercises" on public.workout_template_exercises for select using (true);

-- Owner policies
drop policy if exists "profiles owner" on public.profiles;
create policy "profiles owner" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists "workouts owner" on public.workouts;
create policy "workouts owner" on public.workouts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "workout_exercises owner" on public.workout_exercises;
create policy "workout_exercises owner" on public.workout_exercises for all using (
  exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid())
) with check (
  exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid())
);
drop policy if exists "sessions owner" on public.workout_sessions;
create policy "sessions owner" on public.workout_sessions for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "session_sets owner" on public.session_sets;
create policy "session_sets owner" on public.session_sets for all using (
  exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
) with check (
  exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
);
drop policy if exists "favorites owner" on public.favorites;
create policy "favorites owner" on public.favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Seed lookup tables
insert into public.body_parts (slug, label, emoji, color_hex, sort_order) values
  ('chest','Chest','🫁','#FF6B35',1),
  ('back','Back','🔙','#4CC9F0',2),
  ('shoulders','Shoulders','💪','#C8F542',3),
  ('upper arms','Upper Arms','💪','#A78BFA',4),
  ('lower arms','Lower Arms','✊','#F472B6',5),
  ('waist','Waist','🎯','#FBBF24',6),
  ('upper legs','Upper Legs','🦵','#34D399',7),
  ('lower legs','Lower Legs','🦶','#60A5FA',8),
  ('cardio','Cardio','❤️','#F87171',9),
  ('neck','Neck','🧣','#94A3B8',10)
on conflict (slug) do update set label=excluded.label, emoji=excluded.emoji, color_hex=excluded.color_hex, sort_order=excluded.sort_order;

insert into public.equipment_types (slug, label, icon, sort_order) values
  ('body weight','Body Weight','self_improvement',1),
  ('dumbbell','Dumbbell','fitness_center',2),
  ('barbell','Barbell','fitness_center',3),
  ('cable','Cable','cable',4),
  ('kettlebell','Kettlebell','sports_mma',5),
  ('band','Band','timeline',6),
  ('smith machine','Smith Machine','fitness_center',7),
  ('leverage machine','Leverage Machine','precision_manufacturing',8),
  ('stability ball','Stability Ball','sports_baseball',9),
  ('ez barbell','EZ Barbell','fitness_center',10),
  ('weighted','Weighted','monitor_weight',11),
  ('assisted','Assisted','accessible',12)
on conflict (slug) do update set label=excluded.label, icon=excluded.icon, sort_order=excluded.sort_order;
