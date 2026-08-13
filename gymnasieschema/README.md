# Gymnasieschema

En app för att planera och administrera veckoscheman för gymnasieprogram.
Byggd som en enda fristående HTML-fil (ingen byggprocess) – öppna
`index.html` i webbläsaren eller lägg den på valfri statisk webbserver
(t.ex. GitHub Pages).

**Öppna appen:** `gymnasieschema/index.html`

## Funktioner

- **Veckoschema** – tidsrutnät (mån–fre, valfritt helg) med aktiviteter
  placerade efter start-/sluttid. Överlappande poster läggs bredvid varandra.
- **Redigera fritt** – klicka på en post för att ändra, eller dubbelklicka i
  schemat för att skapa en ny på den tiden.
- **Aktiviteter och uppgifter** – varje post har en **ansvarig** person,
  program/klass, plats, beskrivning och tider. Uppgifter kan bockas av som klara.
- **Uppgiftsvy** – samlad lista över alla uppgifter med öppna/klara/försenade.
- **3 administratörer** – tre personer (Lärare 1, Lärare 2, Rektor som
  standard) kan se och administrera schemat. Varje person har en färg.
- **Dölj/visa personers scheman** – klicka på person-chipparna för att
  filtrera bort en persons poster ur vyn.
- **Sök** – fritextsök i titel, ansvarig, program och plats.
- **Planera långt fram** – hoppa till valfritt datum eller +4v / +12v /
  +6 mån. Listvyn visar upp till 6 månader framåt.
- **Outlook-import** – läs in kalenderaktiviteter från en Outlook-CSV-export
  (kolumnerna Subject, Start Date, Start Time, … känns igen automatiskt).
  Se `exempel-outlook.csv`.
- **Läs in schema från bild** – ladda upp en bild eller skärmbild på ett
  schema. Texten läses av med OCR (textigenkänning) direkt i webbläsaren,
  visas redigerbar för korrigering och tolkas sedan till poster (tider,
  tidsintervall, sal/rum och veckodagar känns igen). Se nedan.
- **Historik** – alla ändringar (skapa/ändra/ta bort/import) loggas med vem
  och när, och kan exporteras som säkerhetskopia.
- **Supabase-synk (valfritt)** – anslut till Supabase så att de 3 personerna
  delar samma schema i realtid.

## Lagring

Utan konfiguration sparas allt lokalt i webbläsaren (`localStorage`) – appen
fungerar direkt offline. Under **Inställningar → Data** kan du exportera/importera
allt som JSON.

## Koppla till Supabase (delning mellan flera)

1. Skapa ett projekt på [supabase.com](https://supabase.com).
2. Öppna **SQL Editor** och kör innehållet i
   [`supabase-schema.sql`](./supabase-schema.sql) (samma SQL finns i appen
   under *Inställningar → Visa SQL-schema*).
3. Kopiera **Project URL** och **anon public key** från
   *Project Settings → API*.
4. Klistra in dem i appen under **Inställningar → Supabase-synk** och klicka
   **Anslut & synka**.

Därefter synkas alla ändringar i realtid mellan alla som använder samma
projekt. Befintliga lokala poster laddas upp vid första anslutningen.

### Om behörighet

Standarduppsättningen låter de tre administratörerna dela samma anon-nyckel
med full åtkomst; att "dölja" en persons schema är ett filter i
gränssnittet. Vill du ha riktig inloggning per person aktiverar du Supabase
Auth och byter RLS-policyerna i `supabase-schema.sql` mot
`authenticated`-baserade regler.

## Läs in schema från bild (OCR)

Klicka **🖼 Läs in från bild**, välj en bild eller skärmbild och klicka
**Läs av bild (OCR)**. Textigenkänningen körs i webbläsaren med
[Tesseract.js](https://github.com/naptha/tesseract.js) (svenska + engelska) –
biblioteket och språkdatan hämtas från CDN första gången, så internet krävs
vid första körningen.

- Den avlästa texten visas i en **redigerbar** ruta – rätta eventuella
  feltolkningar innan du klickar **Tolka schema**.
- Parsern känner igen tider (`08:15`, `08:15-09:45`, även med punkt `08.15`),
  sal/rum och **veckodagar** (Måndag–Söndag). Med *Känn igen veckodagar*
  ikryssat placeras posterna på rätt dag i vald vecka; annars hamnar allt på
  det valda startdatumet.
- Har du ingen nätåtkomst kan du klistra in texten manuellt i rutan och ändå
  använda **Tolka schema**.

Tips för bästa resultat: skarp, rak bild med tydlig text. OCR är aldrig
100 % – granska alltid resultatet, och kom ihåg att allt går att ändra i
schemat efteråt.

## Outlook-export → CSV

I klassiska Outlook: **Arkiv → Öppna och exportera → Importera/Exportera →
Exportera till fil → Kommaavgränsade värden**, välj kalendern och spara som
CSV. Importera sedan filen i appen via **⤓ Importera Outlook**. Är datumen
tvetydiga kan du välja datumformat (US/EU/ISO) i importdialogen.
