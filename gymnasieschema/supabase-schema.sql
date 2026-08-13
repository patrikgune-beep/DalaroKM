-- ============================================================
-- Gymnasieschema – molnsynk via Supabase
--
-- Appen använder SAMMA koppling och mönster som DalaroKM: hela
-- tillståndet lagras som en JSON-blob i den delade tabellen
-- "tournaments", på en egen rad med nyckeln '__gymnasieschema'.
-- Ingen appspecifik konfiguration behövs – URL och anon-nyckel är
-- inbyggda i index.html (samma projekt som DalaroKM).
--
-- Tabellen "tournaments" finns redan i DalaroKM-projektet. Behöver du
-- skapa den i ett nytt projekt räcker följande:
-- ============================================================

create table if not exists tournaments (
  key  text primary key,
  data jsonb,
  name text,
  created_at timestamptz default now()
);

-- Radnivåsäkerhet: anon (delad nyckel) har full åtkomst, precis som i
-- DalaroKM. "Dölja" personers scheman görs som ett filter i appens
-- gränssnitt.
alter table tournaments enable row level security;
create policy "anon all tournaments" on tournaments for all using (true) with check (true);

-- Gymnasieschemat ligger på raden:
--   key  = '__gymnasieschema'
--   data = { persons, items, history, settings, updatedAt, app:'gymnasieschema' }
-- __-prefixet gör att raden inte dyker upp i DalaroKM:s turneringslista.
