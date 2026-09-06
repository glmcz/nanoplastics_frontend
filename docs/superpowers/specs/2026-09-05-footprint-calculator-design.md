# Feature A — Personal Nanoplastic Footprint Calculator

Date: 2026-09-05. Status: draft for review. Revised after a twelve-lens
critique; the science, privacy, accessibility and measurement sections are
rewrites, not edits.
Parent: `2026-09-05-student-tools-overview.md`.

## Purpose

A student walks through one ordinary day of their life as a short story. Each
chapter asks one habit question and shows the invisible particles that chapter
adds. At the end they see their year as a picture, which habit dominates by
count and which by weight, what one swap does, and where the particles go and
why. Then three doors: change a habit, study deeper, or help solve it.

Persona: a university student in the Arabic-speaking Gulf or Levant. Hot
climate, small bottles and 20 L cooler jugs, bottles left in cars, delivered
food in plastic, karak in a paper cup, wall-to-wall carpet and majlis
textiles, air conditioning, dust days. Most live with family, so household
purchases are not theirs to make. Arabic ships with English. The student is
curious, not guilty, and already anxious about the environment.

Success for the student: "I did not know the plastic box my lunch comes in
matters more than the bottle. And by weight it is the cutting board, which is
the opposite order. Charge is why these particles stick to things in my body.
Nobody has counted the nano fraction in the air here, and I could work on
that."

## Success, measured

The three-student test says the feature is understandable. These say whether
it works. Measured through the event pipeline defined below, reviewed four
weeks after release.

| Step | Target |
|------|--------|
| Explore card tapped, of students who see Explore | 40% |
| Story finished, of students who start it | 55% |
| Result screen reached, either by story or by skip | 65% of starts |
| Any door opened, of students who reach the result | 35% |
| Idea sent, of students who open the Help door | 10% |
| Returns within 14 days | 15% |

If story completion sits below 40%, the chapters are too many and the next
revision cuts them, not the copy. If door opening sits below 15%, the result
screen ends in a number and the doors are decoration.

## Scope

In:

- Story mode: seven chapters, one screen each, cloud grows as you go.
- A calculation model with cited coefficients, per-row counting method and
  size floor, a mass estimate, and regional values where they exist.
- A result screen: headline card, particle clouds by family, breakdown with a
  count/weight toggle, one-swap panel, charge panel, three doors.
- Explore screen, hub centre entry, and first-run routing.
- Arabic text and RTL behaviour, shipped in the same commit as English.
- Instrumentation: `app_events` table, `POST /api/events`, and the funnel above.
- Help door: consent, `ideas.context`, and a way to see what became of the idea.
- Result persisted locally; a return visit compares against the last one.
- A text-and-link share.

Out:

- Accounts. Server storage of habit answers except inside a submitted idea.
- A rendered share image; that follows in feature B where charts already exist.
- Medical claims. The app estimates intake, never health outcome.
- Translations to cs, es, fr and ru: they fall back to English via `gen-l10n`
  and are listed in `docs/l10n-queue.md`.

## Story and inputs

One day, seven chapters. Each chapter is one screen: a scene line, one or two
questions, and the growing particle cloud above. The student can go back.

| # | Chapter | Keys | Question | Control |
|---|---------|------|----------|---------|
| 1 | Morning, the water | `waterSource` | Where does your drinking water usually come from? | 3 chips: small bottles (default) / 20 L cooler jug / tap or filter |
| | | `waterAmount` | How much do you drink a day? | slider in 500 mL bottles, 0 to 8, litres shown beneath |
| | | `bottleStorage` | Where does your bottle usually sit? | 3 chips: fridge / room / car or sun |
| 2 | Midday, lunch | `plasticContainerMeals` | Meals a week that arrive or are stored in a plastic box | slider 0 to 21 |
| | | `microwaveMeals` | How many of those do you heat in that box? | slider 0 to the value above |
| 3 | The karak break | `teaBagType` | What kind of tea bag? | 3 chips with pictures: paper / silky pyramid / loose leaf |
| | | `teaCups` | Cups a day | slider 0 to 6 |
| 4 | Coffee to go | `takeawayCups` | Hot drinks in disposable cups a week | slider 0 to 21 |
| 5 | Home | `syntheticIndoorShare` | Carpet, majlis textiles and clothes around you: how much is synthetic? | 4 chips: little / some / most / all |
| | | `indoorHours` | Hours a day indoors with the AC on | slider 0 to 24 |
| 6 | Dinner | `seafoodMeals` | Seafood meals a week | slider 0 to 7 |
| | | `seafoodForm` | Mostly fillet, or small fish and shrimp eaten whole? | 2 chips |
| | | `cuttingBoard` | Is the cutting board at home plastic or wood? | 3 chips: plastic / wood / do not know |
| 7 | Outside | `dustyHours` | Hours a week outdoors on dusty or windy days | slider 0 to 20 |

Chapters are data, not code: a list of `Chapter` objects in
`lib/features/footprint/chapters.dart` (key, scene key, question key, why key,
control spec). Adding or cutting a chapter is one list entry.

Defaults are a Gulf student profile so no screen is empty: small bottles, 3 a day, car or sun, 7 plastic-box meals of which 3 microwaved, pyramid bags,
2 cups, 4 takeaway cups, "most" synthetic, 16 indoor hours, 1 seafood meal as
fillet, plastic board, 2 dusty hours.

Defaults are not answers. `FootprintInput` carries a `touched` set. A chapter
counts as touched when its control moves or a chip is tapped, or when the
student taps the small "yes, that is me" link under the control. The result
screen states how many of seven chapters the student actually answered and
offers to fill the rest; untouched chapters are drawn hatched in the
breakdown. A student who taps Next seven times does not get somebody else's
year presented as their own.

The story is told in the second person, in the student's own setting. Before
the number lands, chapter 1's opening line affirms rather than accuses: "None
of this is your fault. The plastic was chosen for you. Let us see how much of
it passes through your day."

Each chapter, after the answer, shows one line of why, and each line carries
the mechanism the app is actually claiming:

- Water: "Heat and shaking break the bottle wall into fragments. A bottle in a
  hot car sheds about nine times more of the smallest pieces than a cool one."
  No charge claim here; the source measured counts, not charge.
- Home: "Synthetic fibres rubbing on each other pick up static charge. Charge
  is what makes them cling to you and hang in the air instead of settling.
  This is the one place in your day where the charge story is measured."

### Predict before the reveal

Before chapter 1, and again before the result screen, the student is asked to
guess: "Which of these do you think puts the most plastic into you?" with the
seven habits as chips. The guess is stored in `FootprintInput.prediction`. The
result screen opens by comparing the guess to the answer. A wrong guess is
framed as the interesting case, never as a failure. Prediction before feedback
is what turns a surprising number from something read into something learned.

## Model

`lib/features/footprint/footprint_model.dart`. Pure Dart. No Flutter imports.

```dart
class FootprintInput { /* keys above, plus touched and prediction */ }

class HabitEstimate {
  final Habit habit;
  final Family family;
  final double particlesPerYear;  // as counted, at this row's floor
  final double low, high;
  final double? massMgPerYear;    // null where no size distribution exists
  final Method method;            // srs | nta | sem | fluorescence | ftir | visual
  final double sizeFloorNm;
  final List<Tag> tags;
}

class FootprintResult {
  final List<HabitEstimate> habits;
  List<HabitEstimate> byFamily(Family f);   // sorted, largest first
  double massTotalMg;                        // comparable across families
  FootprintResult withChange(Habit h, HabitChange c);
}

FootprintResult estimate(FootprintInput input);
```

### Confidence tags, defined once

Tested by the coefficient-table test, which fails if a row carries a tag not
defined here or a source line that is empty.

- `measured`: particles counted and chemically identified as plastic at the
  stated floor, with no published challenge to the number.
- `countedNotIdentified`: particles counted without per-particle polymer
  identification, so the count may include oligomers, salts or fillers. Shown
  to the student as "counted, could be more than plastic".
- `extrapolated`: a measured value scaled by an assumption the source did not
  make. The assumption is named on the bar.
- `disputed`: a published comment, letter or regulator assessment challenges
  the number. Both sides are shown as the band, one line each.

A row may carry two tags, and most do.

### Three families, never summed across

Rows counted with different instruments and different size floors are never
added together and never expressed as a percentage of one another. Doing so
makes the ranking a function of who owned the better microscope.

**Family 1 — swallowed, counted below 1 µm** (floors 30 nm to 100 nm)

| Habit | Coefficient | Method, floor | Source | Tags |
|-------|-------------|---------------|--------|------|
| Bottled water, small bottle | 2.4e5 particles / L, band 1.1e5 to 4.0e5, about 90% below 1 µm | SRS, 100 nm, polymer ID | Qian et al., PNAS 2024, doi 10.1073/pnas.2300582121 | measured, disputed (Materić, PNAS 2024, doi 10.1073/pnas.2411099121, argues samples sat below the procedural blank and the dominant polyamide signal indicates lab contamination; Qian replied, doi 10.1073/pnas.2415874121) |
| 20 L cooler jug | no published count at nano scale. Shown as an open question, contributing nothing to the count and one line to the Study door | — | — | unknown |
| Bottle in a hot car | multiply the small-bottle nano fraction by 9.3, from 60 °C plus 200 rpm shaking in a lab simulation of vehicle storage | NTA | Water Research, Feb 2026, "Everyday storage and handling of PET bottled water", S0043135426002526 | extrapolated (lab conditions, not a measured car) |
| Food heated in a plastic box | 2.11e9 nanoparticles per cm² per 3 min; 100 cm² contact assumed, band 50 to 200 | NTA, about 30 nm, no per-particle ID | Hussain et al., ES&T 2023, doi 10.1021/acs.est.3c01942 | countedNotIdentified, extrapolated, disputed (Correspondence and Rebuttal, ES&T 2024) |
| Silky pyramid tea bag | BfR's re-test found 5,800 to 20,400 particles above 1 µm per bag and concluded the sub-micron population was precipitated oligomers, not plastic. The app therefore shows the micron count and states that no confirmed nano count exists | SEM and NTA | Hernandez et al., ES&T 2019; BfR assessment 2020; Busse et al., ES&T 2020 | disputed, countedNotIdentified |
| Paper cup, hot drink | 2.5e4 particles above 1 µm per 100 mL cup; the 1.02e8 / mL sub-micron count carries no chemical ID and is shown as a separate, tagged bar | fluorescence and SEM | Ranjan et al., J. Hazard. Mater. 2021, S0304389420321087 | measured (micron), countedNotIdentified (sub-micron) |

**Family 2 — swallowed, counted above 1 µm** (floors vary from 1 µm to 100 µm; each bar states its own)

| Habit | Coefficient | Method, floor | Source | Tags |
|-------|-------------|---------------|--------|------|
| Seafood, fillet | Gulf fish: 0.057 items per fish, 5.7% of fish contaminated, fibres excluded, gut contents not fillet. Cox global 1.1e4 per year at one meal a week shown only as a comparison line | visual and FTIR, 100 µm | Western Arabian Gulf, Mar. Pollut. Bull. 2020, pubmed 32479293; Cox et al., ES&T 2019 | measured, gut not fillet |
| Seafood, small fish and shrimp eaten whole | per-individual Gulf counts times servings | visual, 100 µm | Arabian Gulf prawn study, Environ. Monit. Assess. 2026 | measured, regional |
| Plastic cutting board | 14.5 to 71.9 million particles a year, 7.4 to 50.7 g a year for polyethylene, 49.5 g for polypropylene | gravimetric and microscopy | Yadav et al., ES&T 2023, doi 10.1021/acs.est.3c00924 | measured |

**Family 3 — breathed, counted above about 11 µm**

| Habit | Coefficient | Method, floor | Source | Tags |
|-------|-------------|---------------|--------|------|
| Synthetic surfaces indoors | Kuwait indoor aerosol 3.2 to 27.1 particles / m³, carpeted flats 10.8 to 27.1; use 19 / m³ with 16.8 m³ a day at light activity, scaled 0.6x to 1.4x across the four synthetic-share chips | FTIR, 11 µm | Uddin et al., Kuwait indoor aerosol baseline, PMC8878012; breathing volume from Vianello et al., Sci. Rep. 2019 | measured (regional), extrapolated (share scaling) |
| Dust days outdoors | 32.5 items a day normal, 161 on dusty days, adults; per dusty hour add the difference over 24 | PM2.5-bound, micron | Bushehr, Iran, Environ. Res. 2021, pubmed 33068583 | measured, one city |

The share-scaling factors are an assumption, not a finding: no study reports
indoor counts by synthetic-textile share. The bar says so.

### Count and weight

Each habit carries two numbers. Count is what the instrument saw at its floor.
Mass is estimated from the source's published size distribution where one
exists, and otherwise from a stated assumption: a sphere at the floor
diameter, density 1.05 g/cm³. Both are labelled estimate, and the mass
assumption is named on the bar.

Mass is the only quantity comparable across families, and it reverses the
order: by count the heated plastic box dominates, by weight the cutting board
beats everything by three orders of magnitude while contributing little by
count. That reversal is the feature's best teaching moment, not a problem to
hide. One caption carries it: "Bigger bar can mean a better microscope, not
more plastic. Switch to weight to compare fairly."

There is no single grand total and no "percent of your year" anywhere in the
app, including the Help door copy and the share text.

### Regional comparison, and what the app must not claim

Saudi tap water measured 2 to 5 particles per litre in the 25 to 500 µm range
by FTIR, from two tap samples (Almaiman et al., Environ. Monit. Assess. 2021,
doi 10.1007/s10661-021-09132-9). Bottled water measured 2.4e5 per litre down
to 100 nm by a different method. These two numbers are five orders apart
because the instruments are, not because the water is. They never appear on
one bar or in one sentence.

The Change door says instead: "Tap water here has very few particles large
enough for today's routine lab methods to count. Nobody has counted the nano
fraction in Gulf tap water. That is an open question," and links it to the
Study door.

Boiling is not offered as a Gulf remedy. It works by trapping particles in
calcium carbonate, so it needs hard water: about 34% removal at 80 mg/L rising
to 90% at 300 mg/L (Yu et al., ES&T Letters 2024). Desalinated Gulf supply is
remineralised well below that, so the mechanism is weak exactly here. The app
says this, because it is a good example of a real remedy that does not travel.

### Display formatting

`formatParticles(double n, AppLocalizations l10n)` returns a localised string.

- Western digits in every locale, matching the convention already used in the
  app's ARB files. Never format with a bare `ar` locale, which emits
  Arabic-Indic digits inconsistent with the rest of the app.
- Scale words come from ARB with plural forms, not string concatenation, so
  Arabic dual and plural are correct.
- Numbers inside RTL sentences are wrapped in Unicode isolates so digits and
  units do not reorder.
- One significant figure plus a word ("about 90 million"), and above 1e9 a
  human comparison ("about N a second, all year").

## Screens

### Explore screen and first run

`lib/screens/explore_screen.dart`. Cards for the tools, styled like
`CategoryCard`. Feature A adds the Footprint card: title, hook ("How much
plastic is in your year?"), icon.

Hub: a centre button between the four quadrants opens Explore. The quadrant
geometry and `HubButtonPosition` are untouched.

First run: after onboarding, a student who has never opened a tool is taken to
Explore once, Footprint card expanded, with a Skip. The flag lives in
`SettingsManager` beside the other one-shot flags.

### Footprint story screen

`lib/screens/footprint/footprint_story_screen.dart`. A `PageView` with
`NeverScrollableScrollPhysics`; chapters change through Next, Back and the
progress dots only. Swipe is deliberately not a navigation gesture: the app
installs a right-edge back overlay that collides with forward paging in
Arabic, and horizontal sliders inside a page fight a horizontal `PageView` for
the same drag.

Opening page: "Nanoplastics are plastic pieces smaller than a bacterium. You
cannot see them. Let us walk through one of your days and count them." Buttons:
"Start my day", and a text link "Skip the story, show me numbers" that goes
straight to the result with defaults, every panel offering an edit that
returns to its chapter. Narrative persuades the curious; people who only want
facts do better with facts.

The cloud is one widget above the `PageView`, owned by the screen, so a page
change never runs two animations.

Repetition rule: the why lines and the charge sentence are shown in full on
first read and collapsed to a tappable one-liner on later visits, keyed per
chapter in `SettingsManager`. A story that repeats itself verbatim on the
third open teaches nothing and reads as nagging.

### Footprint result screen

`lib/screens/footprint/footprint_result_screen.dart`. Panels in order.

0. **Headline**. One card that survives a screenshot: the app name, the
   one-line definition, the student's own headline sentence built only from
   touched chapters, the word "estimate", and how many of seven chapters they
   answered. Opens by resolving the prediction: "You guessed the bottle. It is
   the lunch box, by about a hundred times."
1. **Clouds**. One cloud per family, each captioned with its floor ("counted
   from 100 nm", "from 25 µm", "from 11 µm"). Each dot is a stated number of
   particles; dot shape and pattern differ per habit, not only colour. A
   sentence sits between the clouds: "Nobody has counted the nano fraction of
   what you breathe. That is an open research question," linking to Study.
2. **Breakdown**. `fl_chart` horizontal bars, grouped by family, drawn on a
   log10 length scale with the scale named on the axis, because the values
   span nine orders of magnitude and a linear bar would render every habit but
   one as a hairline. A Count / Weight toggle sits above the chart; switching
   to Weight reorders the bars and shows the reversal. Each bar carries its
   method, floor, and tags as words. Tapping a bar opens the source.
3. **One swap**. Not "if you stopped". Each habit row in the coefficient table
   names one or two concrete swaps with a factor: keep the bottle out of the
   car (removes the 9.3x), move lunch to a glass or ceramic dish before
   heating, paper or loose-leaf tea instead of pyramid bags, a wooden board.
   The panel shows before and after in the student's own numbers, by count and
   by weight.
   Then the commitment step, which is what the literature says converts a
   number into a behaviour: the student picks one swap and writes a when and
   where into a single sentence ("When I take lunch from the fridge, I will
   move it to a glass dish"). It is stored locally and shown on the next
   visit. Wording is autonomy-supportive throughout: "you could", never "you
   should", and skipping is a plain, unpunished option.
   Actions are split into "yours" (a steel bottle, a lunch dish you carry, tea
   you buy) and "your household's" (the board, the water source), because most
   students in this region do not buy the kitchenware.
4. **Where they go, and why charge decides**. The charge panel, animated
   rather than static, and it carries the project's thesis. Three states, one
   control, reduce-motion safe: a particle rubs against fabric and gains
   charge; the charged particle enters water, where salt screens the charge
   and the particles clump; the charged particle enters blood, where proteins
   and lipids coat it and its charge decides whether it sticks to a membrane
   or crosses. The panel says plainly that charge is the root cause and count
   is the symptom, and names it as this project's thesis with the supporting
   studies one tap away.
   Beneath it, "What this means for you", fixed text: known, that plastic
   particles have been found in human blood, brain and placenta, and that
   surface charge changes how cells take particles up; not known, how much is
   harmful, since no study has yet tied a number like this one to an illness.
   Then the link to the Human category detail.
5. **Say it back**. One prompt: "In one sentence, why does charge matter?"
   with a text box and a Skip. What the student writes is stored locally and
   shown next to the model answer, never graded, never sent. Explaining in
   your own words is the step that turns reading into learning, and it is the
   same test the acceptance bar uses.
6. **Three doors**. Equal weight.
   - *Change*: opens panel 3 and the commitment sentence. If a commitment
     already exists, it opens a two-week check: "You chose the glass dish. How
     did it go?" with three answers and a recount.
   - *Study*: not a list of papers. A short path: one "start here" card, the
     three sources behind the student's own largest habits with their DOIs,
     regional cards ("labs near you working on this", drawn from existing
     `EvidenceStudy` entries by domain), and the open questions with a size
     and a next step each: "Nobody has counted nanoplastics in Gulf tap water
     or in a 20 L cooler jug. Size: one term project. Next step: read this
     method paper." A "follow this topic" control subscribes the existing
     digest to that keyword.
   - *Help*: see below.

## Help door: consent, context, and the loop back

Copy is personal and built from the student's largest touched habit, without a
percentage: "Your lunch box is the biggest single source in your day, and the
cutting board is the biggest by weight. Nobody has a cheap way to count
nanoplastics outside a lab, or to keep them out of hot food. Have an idea?"

Three seed prompts sit under it at observation level, one tap prefills the
box, because a first-year asked to invent a lab instrument writes nothing:
"Which bottle brand goes soft in your car?", "Where does the dust settle in
your room after a dusty day?", "What would make a plastic box stop shedding
when it is hot?" The copy does not steer only to detection ideas.

### Consent and identity

A line above a Send button is not consent. Before the first send, a sheet
states, in Arabic and English, on separate lines with separate checkboxes:

1. Your idea text and attachments are stored by NanoSolve and read by people
   working on the project.
2. Your idea is sent to a third-party AI provider outside your country to be
   scored, and the score comes back into the app.
3. Your habit answers from this tool are attached, so the idea can be
   understood in context.

Item 3 is optional and independently unchecked-able; the idea sends without
it. Nickname and email are shown as they will be attached, with a control to
send anonymously. The sheet links the privacy policy and states the retention
period. Consent is stored locally with a version number, so a later change of
terms re-asks.

Copy accuracy: the app must not say "used to train our AI" unless that is
true. Today ideas are scored by third-party hosted models. The consent says
"scored by an AI service outside your country" and names the providers in the
privacy policy. If a free tier is used whose terms permit the provider to
train on submissions, the consent must say so.

Age: the send sheet asks the student to confirm they are 18 or over, or that a
guardian agrees. Gulf data laws set guardian thresholds higher than the 13
used in the current policy text, and this app is aimed at universities.

Deletion: the send confirmation shows a reference code and how to request
deletion, and the privacy policy gains a working address for it. "No server
storage" in Scope refers to habit answers outside a submitted idea; the Help
door is the one path that stores anything, and the spec says so plainly.

Offline: if the request fails, the idea text is kept locally and offered again
on the next open. Nothing typed on a campus connection is lost silently.

### The context field: storage, exposure, use

Migration `048_ideas_context.sql` adds `context JSONB` to `ideas`.

```json
{
  "source": "footprint",
  "coefficients_version": "2026-09-05",
  "largest_by_count": "microwaveMeals",
  "largest_by_mass": "cuttingBoard",
  "prediction": "bottledWater",
  "touched": 6,
  "input": { "waterSource": "jug", "bottleStorage": "car" }
}
```

Exposure: `context` must not be added to `models::Idea`, which is selected
with `SELECT *` and serialised straight out of `GET /api/ideas` and
`GET /api/ideas/:id`. It is written by `submit_idea` and read only by the
evaluation path and by explicit admin queries. A `cargo test` asserts that the
public list and detail responses contain no `context` key.

Validation: `submit_idea` gains one match arm that parses the field as JSON,
rejects payloads over 16 KB with 400 through the existing `AppError::InvalidInput`, which is what this codebase returns for bad input, and binds it with `COALESCE` so a
missing field stores SQL NULL rather than a JSON null.

Use: the field is not write-only. `evaluation::scorer` includes a short
rendering of the context in the prompt it sends, so the model scoring an idea
knows the habit that prompted it. Without a reader, the "why" never reaches
the corpus and the column is decoration.

Category: ideas from this tool must carry a category the database accepts. The
allowed keys are fixed by migration 002. `chapters.dart` holds the mapping:
water, lunch, tea, cups and board map to `human_entry`; seafood maps to
`planet_ocean`; indoor and dust map to `planet_atmosphere`. A unit test
asserts every habit maps to one of the twelve keys.

### Closing the loop

A one-way send teaches the student that nothing happens. After sending, the
app keeps the idea id locally and the Help door becomes a status card: sent,
being scored, scored. When the score arrives the student sees the tier and the
reasoning the evaluator already produces, and a link to their entry in the
existing leaderboard. This uses `GET /api/ideas/:id`, which exists.

## RTL, accessibility and performance rules

RTL:

- Chapter order follows reading order; in Arabic, Next moves the page to the
  left. Progress dots mirror. The story opts out of the app's right-edge back
  overlay.
- `fl_chart` is wrapped in an explicit `Directionality`; bars grow from the
  start edge and axis labels are checked in both directions.
- The charge diagram is drawn, not a mirrored bitmap, so its arrows point with
  the text direction.

Accessibility:

- No information by colour alone. Habits are identified by shape and pattern
  in the cloud, by an icon and label on every bar, and by text in the legend.
  Palette contrast is checked in light and dark against WCAG 2.2 AA.
- The particle cloud is one `Semantics` node with a live label: "Estimated
  particle cloud, about 90 million particles a year from six habits", updated
  when the number changes. It is not a decorative canvas.
- Sliders carry `semanticFormatterCallback` so they announce bottles, meals
  and hours, not percentages.
- Chapter changes and the growing total are announced through the live region;
  a student using a screen reader is told the number changed.
- Motion: the cloud respects `MediaQuery.disableAnimations`, and a visible
  pause control stops it in every case. Nothing flashes faster than three
  times per second, which rules out per-dot charge flicker; the charge glyph
  animates on a slow shared cycle instead.
- Text scaling to 200% must not clip; chapter screens scroll rather than
  compress.

Performance:

- One `Ticker` per screen, owned by the `State`, cancelled in `dispose` and
  paused when the route is not current.
- The cloud caps at 400 dots and drops to 200 with reduce-motion or when the
  device reports a low refresh budget; the caption states the dot scale, which
  changes with the cap.
- Dots are drawn as shapes in a single `CustomPainter` pass inside a
  `RepaintBoundary`. No per-dot text glyphs, which is the expensive path.

## Instrumentation

Backend: migration `049_app_events.sql` creates `app_events (id, install_id,
name, at, locale, platform, props JSONB)`, and `POST /api/events` accepts a
batch of at most 50. The endpoint validates event names against a fixed list
and rejects unknown ones with 400 (`AppError::InvalidInput`), so the table cannot become a dumping
ground. A scheduled delete removes rows older than 180 days.

Client: `lib/services/event_service.dart` queues events and flushes on app
pause. `install_id` is a random v4 UUID in `SharedPreferences`, unrelated to
the user id. The service is a no-op when Settings has usage statistics off.

Event dictionary for feature A, `props` keys in brackets:

| Event | When | Props |
|-------|------|-------|
| `explore_opened` | Explore screen shown | `first_run` |
| `footprint_started` | Story or skip begins | `mode` (story, skip) |
| `footprint_chapter` | Chapter shown | `index`, `touched` |
| `footprint_abandoned` | Story left before result | `index` |
| `footprint_result` | Result screen shown | `mode`, `touched_count` |
| `footprint_view_toggled` | Count / weight switched | `to` |
| `footprint_door` | Door opened | `door` (change, study, help) |
| `footprint_commitment` | Commitment saved | `habit` |
| `footprint_explained` | Say-it-back submitted | none |
| `footprint_shared` | Share sheet opened | none |
| `idea_sent` | Idea submitted from this tool | `habit` |
| `footprint_return` | Reopened after a previous result | `days_since` |

No habit values, no free text, no coordinates. `habit` is an enum key.

## Persistence and the return visit

The last `FootprintInput`, the last `FootprintResult` summary, the commitment
sentence and its date, and the say-it-back text are stored via
`SettingsManager` under one JSON key.

Reopening shows the last result first, with "Recount my day" and, if a
commitment is older than fourteen days, the check-in. A second result is shown
against the first: what moved, and whether the swap held. Nothing brings a
student back to a one-shot calculator; a comparison against their own past
does.

## Sharing

One share, text and link, through the existing `share_plus`: the headline
sentence, the word estimate, and a link to the app. No image in feature A; the
rendered card follows in feature B. The share text never contains a
percentage or a habit value beyond the headline habit name.

## Files

New, Flutter:

- `lib/features/footprint/footprint_model.dart`
- `lib/features/footprint/footprint_coefficients.dart`
- `lib/features/footprint/chapters.dart`
- `lib/screens/explore_screen.dart`
- `lib/screens/footprint/footprint_story_screen.dart`
- `lib/screens/footprint/footprint_result_screen.dart`
- `lib/widgets/footprint/particle_cloud.dart`
- `lib/widgets/footprint/habit_bar_chart.dart`
- `lib/widgets/footprint/charge_panel.dart`
- `lib/services/event_service.dart`
- `assets/images/charge_panel/*.png`

New, backend:

- `services/nanoSolve-backend/migrations/048_ideas_context.sql`
- `services/nanoSolve-backend/migrations/049_app_events.sql`
- `services/nanoSolve-backend/src/events.rs`

Edited:

- `pubspec.yaml` (fl_chart)
- `lib/screens/main_screen.dart` (hub centre entry)
- `lib/services/settings_manager.dart` (footprint state, install id, usage
  statistics switch, first-run flag)
- `lib/services/api_service.dart` (`submitIdea` gains optional `context`;
  injectable `http.Client`)
- `lib/screens/user_settings/privacy_policy_screen.dart` and the web policy
  strings (events, context, providers, retention, deletion)
- `assets/l10n/app_en.arb`, `assets/l10n/app_ar.arb`
- `services/nanoSolve-backend/src/handlers.rs`, `lib.rs`, `models.rs`
- `services/nanoSolve-backend/src/evaluation/scorer.rs` (reads context)
- The three ARB strings that state charge is renewed in the body

## Testing

Unit, written first, red before green:

- Zero input gives zero in every family.
- Default input: the heated plastic box leads family 1 by count; the cutting
  board leads by mass across families; the two orders differ.
- Bottle storage "car or sun" multiplies the bottled-water nano estimate by
  9.3, not 2.
- `withChange` reduces exactly the chosen habit and nothing else.
- No API returns a cross-family total or a percentage.
- Coefficient table: every row has a source, a method, a floor and at least
  one defined tag; no row carries an undefined tag.
- Every habit maps to one of the twelve allowed category keys.
- `formatParticles`: 9.2e7 renders as "about 90 million"; Arabic renders
  Western digits and the correct plural form.
- Untouched chapters are excluded from the headline sentence.

Widget:

- Every chapter renders at 375 x 667 in English and Arabic, and at 200% text
  scale, without overflow.
- Moving the water slider changes the cloud's dot count and its semantic label.
- Result screen renders seven panels; the Count/Weight toggle reorders bars;
  tapping a bar shows its source and tags.
- The Help door shows the consent sheet before any network call, and the
  optional habit-context checkbox can be cleared while still sending.
- Reduce-motion renders the cloud static and shows the pause control.

Flutter seams. Two exist and both are used. `ServiceLocator`'s
`overrideApiServiceForTesting` with the existing `FakeApiService` covers
call-site behaviour: that the screen passes the context it should. The wire
format needs more, so `ApiService` gains `@visibleForTesting http.Client
client` and sends through it, letting a `MockClient` assert that the multipart
body actually carries a `context` field. Four tests in the previous revision
could not be written against the current code; this is why.

Backend, `cargo test`:

- `submit_idea` with a valid `context` stores it; without, the column is NULL.
- `context` over 16 KB is rejected with 400 and no row is written.
- `GET /api/ideas` and `GET /api/ideas/:id` responses contain no `context` key.
- `POST /api/events` accepts a batch, rejects an unknown event name with 400,
  and rejects a batch over 50.

Human: the three-student protocol from the umbrella spec, one of them on the
Arabic build, results recorded in `docs/research/` and compared against the
funnel targets above.

## Evidence behind the design

Checked 2026-09-05. Each rule is a constraint on the build.

Communication psychology:

- Narrative beats statistical evidence for risk perception and behavioural
  intention; explicit numbers still help; longer and visual messages do better.
  Choi, Chen, Guo, Science Communication 2025, doi 10.1177/10755470251344211.
- Identification with the protagonist mediates narrative persuasion; everyday
  settings identify best. Frontiers in Communication 2026,
  doi 10.3389/fcomm.2026.1814277; Sci. Rep. 2021, PMC8782940.
- Fear appeals work (d = 0.29, 127 studies) and work better with efficacy
  statements and one-time behaviours. Tannenbaum et al., Psych. Bull. 2015.
- Narrative suits the pre-action stage; people not yet contemplating change do
  better with plain messages. Frontiers in Psychology 2023, PMC10171234.
- Personalised footprint feedback raises awareness and rarely changes
  behaviour on its own; above-average results produce guilt. Energy Policy
  2018; J. Cleaner Prod. 2023. Hence no ranking, and hence panel 3.
- Implementation intentions close the intention-behaviour gap (d = 0.65,
  Gollwitzer and Sheeran 2006); commitment outperforms information across
  environmental field studies (Lokhorst et al. 2013). Hence the commitment
  sentence and the two-week check-in.
- Autonomy-supportive wording produces durable motivation where controlling
  wording does not (Pelletier and Sharp 2008). Hence "you could".
- Prediction before feedback improves learning from surprising results. Hence
  the guess before chapter 1.

Audience:

- 70% of Arab youth felt anxious about the environment in the last six months,
  41% very anxious; 40% call it their generation's top issue. Economist Impact;
  ASDA'A BCW Arab Youth Survey. The audience is already afraid. Add agency.
- UAE per-capita bottled water is among the world's highest, about 285 L a
  year, mostly desalinated water rebottled.

Exposure and mechanism: see the coefficient tables. Five findings changed the
design: the Water Research 2026 storage study (the hot-car multiplier is real
and large), the BfR re-test (no confirmed nano count for tea bags), the
Materić letter (the headline bottled-water number is contested), Yadav 2023
(mass and count disagree by three orders), and Kuwait's indoor baseline (a
regional number exists, so the Danish one is not needed). Lockman 2004 and
Kopatz 2023 set what the charge panel may claim.

## Risks

- Two sources were read as abstracts and press summaries rather than full
  texts: Water Research 2026 and Choi 2025. The plan keeps a task to read both
  before the numbers ship. If the fold change differs, the table row changes.
- Mass estimates rest on a sphere assumption wherever a source publishes no
  size distribution. The bar names the assumption; if a reviewer objects, the
  row shows count only.
- The tea chapter may end up with no defensible nano number at all. That is an
  acceptable outcome and is shown as such.
- Seven chapters may be too many. The funnel measures it, and the first
  revision cuts chapters rather than words.
- The event endpoint is new attack surface. It writes no free text, validates
  names against a list, caps the batch, and stores no identifier that outlives
  a data clear.
