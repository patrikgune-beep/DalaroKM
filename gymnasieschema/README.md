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
- **Rensa tidigare CSV-poster per ansvarig** – i importdialogen kan du för en
  vald ansvarig ta bort tidigare CSV-inlästa poster, antingen fristående (en
  knapp som bara raderar) eller automatiskt vid en ny import (kryssrutan
  *Ersätt*). Endast CSV-inlästa poster för just den personen påverkas –
  manuella poster, bildinlästa poster och andra personers poster berörs inte.
  **Passerade poster behålls alltid:** endast dagens och framtida CSV-poster
  raderas, medan poster vars datum redan passerats ligger kvar i schemat och
  historiken.
- **Upprepning** – när du skapar en aktivitet, importerar en bild eller en
  CSV-fil kan du välja att posterna ska upprepas **varje vecka**, **varannan
  vecka** eller **en gång i månaden (samma datum)**, t.o.m. ett valt slutdatum
  (standard 6 månader fram). Varje tillfälle skapas som en egen post som kan
  ändras individuellt.
- **Läs in schema från bild** – ladda upp en bild eller skärmbild på ett
  schema. Texten läses av med **OCR** direkt i webbläsaren (ingen API-nyckel),
  visas redigerbar och tolkas till poster (tider, tidsintervall, sal/rum och
  veckodagar känns igen). Se nedan.
- **Historik** – alla ändringar (skapa/ändra/ta bort/import) loggas med vem
  och när, och kan exporteras som säkerhetskopia.
- **Molnsynk (Supabase)** – schemat delas automatiskt mellan alla enheter
  via **samma Supabase-projekt som DalaroKM**. Ingen inställning behövs.

## Lagring & molnsynk

Appen använder **samma koppling och funktionalitet som DalaroKM**: hela
tillståndet lagras som en JSON-blob i den delade tabellen `tournaments`
(på raden `__gymnasieschema`). Webbläsaren pratar direkt med Supabase via
REST – URL och anon-nyckel är inbyggda, ingen inloggning eller konfiguration
krävs.

- **Automatisk synk:** ändringar sparas till molnet strax efter att de görs,
  och appen hämtar andras ändringar var 12:e sekund. Nyare version vinner
  (`updatedAt`), precis som i DalaroKM.
- **Offline:** `localStorage` används som backup. Utan internet fungerar
  appen lokalt och synkar upp när uppkopplingen är tillbaka.
- **Status & manuell synk:** under **Inställningar → Molnsynk** ser du
  anslutningsstatus och kan tvinga **Hämta från molnet** / **Spara till
  molnet**. Under **Inställningar → Data** kan du dessutom exportera/importera
  allt som JSON.

Eftersom alla tre administratörer delar samma projekt ser och administrerar
de samma schema. Att "dölja" en persons schema är ett filter i gränssnittet.
Behöver du skapa tabellen i ett nytt projekt finns DDL i
[`supabase-schema.sql`](./supabase-schema.sql).

## Läs in schema från bild (OCR)

Klicka **🖼 Läs in från bild**, välj en bild eller skärmbild och klicka
**Läs av bild (OCR)**. Textigenkänningen körs lokalt i webbläsaren med
[Tesseract.js](https://github.com/naptha/tesseract.js) (svenska + engelska) –
biblioteket och språkdatan hämtas från CDN första gången, så internet krävs
vid första körningen. Ingen API-nyckel behövs.

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
