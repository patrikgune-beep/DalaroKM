-- ============================================================
-- Gymnasieschema – Supabase-databasschema
-- Kör detta i Supabase SQL Editor (Dashboard -> SQL Editor -> New query).
-- Klistra sedan in Project URL och anon public key i appens Inställningar.
-- ============================================================

create table if not exists persons (
  id text primary key,
  name text not null,
  color text,
  visible boolean default true
);

create table if not exists schedule_items (
  id text primary key,
  type text not null default 'activity',   -- 'activity' | 'task'
  title text not null,
  description text,
  date date not null,
  start_time text,                          -- 'HH:MM' eller null (heldag)
  end_time text,
  program text,
  location text,
  person_id text,                           -- ansvarig (persons.id)
  done boolean default false,
  source text default 'manual',             -- 'manual' | 'outlook'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists idx_items_date on schedule_items(date);
create index if not exists idx_items_person on schedule_items(person_id);

create table if not exists history (
  id text primary key,
  ts timestamptz default now(),
  action text,                              -- create | update | delete | import
  item_id text,
  item_title text,
  by_name text,
  details text
);

-- ------------------------------------------------------------
-- Realtidsuppdateringar så att alla 3 administratörer ser
-- ändringar direkt.
-- ------------------------------------------------------------
alter publication supabase_realtime add table schedule_items;
alter publication supabase_realtime add table persons;

-- ------------------------------------------------------------
-- Radnivåsäkerhet (RLS).
-- Enkel variant: de 3 administratörerna delar samma anon-nyckel
-- och har full åtkomst. (Att "dölja" personers scheman görs som
-- ett filter i appens gränssnitt.)
--
-- Vill du ha riktig inloggning per person, aktivera Supabase Auth
-- och byt policyerna nedan mot authenticated-baserade regler.
-- ------------------------------------------------------------
alter table persons enable row level security;
alter table schedule_items enable row level security;
alter table history enable row level security;

create policy "anon all persons"  on persons        for all using (true) with check (true);
create policy "anon all items"    on schedule_items for all using (true) with check (true);
create policy "anon all history"  on history        for all using (true) with check (true);
