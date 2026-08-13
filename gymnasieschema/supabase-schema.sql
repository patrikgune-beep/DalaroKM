-- ============================================================
-- Gymnasieschema – eget Supabase-projekt
--
-- Appen använder SAMMA mekanism som DalaroKM (hela tillståndet som en
-- JSON-blob, direkta REST-anrop, updatedAt-baserad synk), men ett EGET
-- Supabase-projekt och en egen databas – inte DalaroKM:s.
--
-- 1. Skapa ett eget projekt på https://supabase.com
-- 2. Kör detta i Supabase SQL Editor (Dashboard -> SQL Editor -> New query)
-- 3. Klistra in Project URL + anon public key i appen under
--    Inställningar -> Molnsynk.
-- ============================================================

create table if not exists app_state (
  key  text primary key,
  data jsonb,
  updated_at timestamptz default now()
);

-- Radnivåsäkerhet: de tre administratörerna delar samma anon-nyckel och
-- har full åtkomst. ("Dölja" en persons schema görs som ett filter i
-- appens gränssnitt.)
alter table app_state enable row level security;
create policy "anon all app_state" on app_state for all using (true) with check (true);

-- Hela schemat lagras på en rad:
--   key  = 'gymnasieschema'
--   data = { persons, items, history, settings, updatedAt, app:'gymnasieschema' }
