# Inventory App — iPhone

Native iOS aplikacija (Swift, SwiftUI, SwiftData) za brzu inventuru:
pretraga + glasovni unos artikala, prema priloženom specu.

## Kako otvoriti projekt

Treba ti Mac s Xcode 15+ (cilja se iOS 17+, zbog SwiftData).

### Opcija A — XcodeGen (preporučeno)

```bash
brew install xcodegen
cd InventoryApp
xcodegen generate
open InventoryApp.xcodeproj
```

Ovo generira `.xcodeproj` iz `project.yml`, uključujući potrebne Info.plist
ključeve za mikrofon i prepoznavanje govora.

### Opcija B — ručno kroz Xcode

1. File → New → Project → iOS → App
2. Ime: `InventoryApp`, Interface: SwiftUI, Storage: SwiftData
3. Obriši default `ContentView.swift` i `Item.swift`
4. Povuci sve foldere iz `InventoryApp/InventoryApp/` (Models, Domain,
   Services, ViewModels, Views) u projekt ("Create groups")
5. U Target → Info dodaj:
   - `Privacy - Microphone Usage Description`
   - `Privacy - Speech Recognition Usage Description`
6. U Target → Signing & Capabilities postavi svoj Team/Bundle ID
7. Build & Run na simulatoru ili uređaju (Speech framework radi i na
   simulatoru, ali mikrofon je pouzdaniji na fizičkom uređaju)

## Arhitektura

```
UI (SwiftUI Views)
 ↓
ViewModel (samo za "Nova inventura" — ostatak koristi @Query direktno)
 ↓
Domain / Use Cases (SearchArticlesUseCase, AddItemToInventoryUseCase,
                     VoiceCommandParser, ArticleMatcher)
 ↓
SwiftData (ModelContext, lokalna baza, offline-first)
```

Namjerna pojednostavljenja u odnosu na strogi "Repository" sloj iz speca:
CRUD ekrani (Artikli, Jedinice mjere, Kategorije, Inventure) koriste
SwiftData `@Query` direktno u View-u — to je idiomatski SwiftData pristup
i izbjegava nepotrebni boilerplate. Najvažniji arhitektonski zahtjev iz
speca — **AI sloj odvojen od poslovne logike** — je zadržan: `Domain/`
sadrži čistu logiku (search, matching, parsing) koja ne zna ništa o
UI-u, a AI/voice sloj (`Services/SpeechRecognitionService.swift`)
nikad direktno ne piše u bazu — uvijek prolazi kroz `VoiceConfirmationView`
i eksplicitnu potvrdu korisnika.

Voice pipeline (spec sekcije 12-13):

```
Mikrofon (AVAudioEngine)
  → SFSpeechRecognizer (hr-HR, on-device kad je dostupno)
  → CroatianNumberParser + VoiceCommandParser (izdvajanje količine i artikla)
  → ArticleMatcher (fuzzy matching: Levenshtein + token overlap)
  → VoiceConfirmationView (POTVRDI / PROMIJENI / "Jeste li mislili...")
  → AddItemToInventoryUseCase (tek nakon potvrde)
```

## Pokriveno prema MVP prioritetima (spec sekcija 20)

- **P0 — Core**: potpuno implementirano (Home, Artikli/Jedinice/Kategorije
  CRUD, instant search, Nova inventura, ručni unos količine, spremanje i
  pregled inventura, sprječavanje duplikata sa zamjenom količine).
- **P1 — Voice**: potpuno implementirano (mikrofon UI s "Slušam..."
  stanjem, speech-to-text, izdvajanje artikla + količine, fuzzy matching,
  confirmation screen s disambiguation listom).
- **P2 — Improvements**: fuzzy matching je gotov. Undo zadnje akcije,
  export inventure i potpuno offline voice processing nisu implementirani
  — prirodni sljedeći koraci.

## Poznata ograničenja

- `CroatianNumberParser` je pragmatičan MVP parser (regex + rječnik
  hrvatskih brojevnih riječi), ne potpuna NLP gramatika brojeva — dobro
  pokriva uobičajene slučajeve iz speca ("dvadeset četiri", "pola",
  "dvanaest i pol"), ali ne sve moguće varijante izgovora.
- Kvaliteta hr-HR govornog prepoznavanja ovisi o iOS verziji i uređaju;
  on-device prepoznavanje se koristi kad je dostupno (`supportsOnDeviceRecognition`),
  inače pada natrag na sistemski default.
- Transkript se čita iz zadnjeg partial rezultata u trenutku kad korisnik
  ponovno pritisne mikrofon (bez čekanja na `isFinal`), radi brzine — u
  praksi je to skoro uvijek dovoljno stabilan tekst.

## Data model

`Article`, `UnitOfMeasure`, `Category`, `Inventory`, `InventoryItem` —
točno prema spec sekciji 17, kao SwiftData `@Model` klase s
relationshipima (`Inventory.items` ↔ `InventoryItem.inventory`,
`Article` ↔ `UnitOfMeasure`/`Category`).
