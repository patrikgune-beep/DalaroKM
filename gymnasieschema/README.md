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
  schema. Antingen med **AI-bildtolkning** (vision-modell, bäst för
  rutnätsscheman, kräver egen API-nyckel) eller med **OCR** direkt i
  webbläsaren (utan nyckel). Resultatet visas redigerbart och tolkas till
  poster (tider, tidsintervall, sal/rum och veckodagar känns igen). Se nedan.
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

Klicka **🖼 Läs in från bild** och välj en bild eller skärmbild. Det finns
två sätt att tolka bilden:

### Alternativ 1 (rekommenderas): Tolka med AI

Bäst för riktiga **rutnätsscheman**, där ren OCR ofta läser i fel ordning.
En vision-modell läser bilden direkt och returnerar strukturerade poster.

1. Välj leverantör: **Anthropic (Claude)** eller **OpenAI (GPT)**.
2. Klistra in din egen **API-nyckel** (sparas endast lokalt i webbläsaren).
   Vid behov kan du ange modell (standard `claude-sonnet-5` resp. `gpt-4o`)
   och en egen bas-URL för OpenAI-kompatibla API:er.
3. Klicka **Tolka bild med AI** → granska → **Importera**.

Bilden skalas ned innan den skickas. Kräver internet, och API-anrop kan
medföra en kostnad hos leverantören. Veckodagar mappas till valt startdatum
(måndag) på samma sätt som nedan, och explicita datum i bilden respekteras.

### Alternativ 2: OCR i webbläsaren (utan nyckel)

Klicka **Läs av bild (OCR)**. Textigenkänningen körs lokalt med
[Tesseract.js](https://github.com/naptha/tesseract.js) (svenska + engelska) –
biblioteket och språkdatan hämtas från CDN första gången, så internet krävs
vid första körningen.

- Den avlästa texten visas i en **redigerbar** ruta – rätta eventuella
  feltolkningar innan du klickar **Tolka schema**.
- Parsern är tolerant och känner igen:
  - tider som `08:15`, `08:15-09:45`, med punkt `08.15`, med `till`/`kl`,
    samt tid både **före** och **efter** ämnet;
  - **flera aktiviteter på samma rad** (t.ex. när OCR plattar ut ett rutnät):
    `08:15 Fysik 09:30 Kemi 11:00 Historia` blir tre poster;
  - sal/rum (`Sal 214`, `sal214`, `Rum 12`);
  - **veckodagar** (Måndag–Söndag). Med *Känn igen veckodagar* ikryssat
    placeras posterna på rätt dag i vald vecka; annars hamnar allt på det
    valda startdatumet.
- *Ta med rader utan tid* styr om rader utan klockslag tas med som
  heldagsposter (praktiskt om schemat mest består av rubriker).
- Under förhandsgranskningen visas **diagnostik** (hur många textrader som
  lästes och hur många poster som tolkades). Tolkas inget visas den avlästa
  råtexten så att du kan rätta den och tolka om.
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
