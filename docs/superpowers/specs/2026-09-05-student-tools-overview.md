# Student Tools — Umbrella Spec

Date: 2026-09-05. Status: draft for review. Revised after a twelve-lens critique
(student, region, science, behaviour, growth, engineering, ethics, pedagogy,
accessibility, competitors, metrics, research path).

Five new frontend features for NanoSolve Hive, built one at a time. This document
holds what all five share: audience, thesis, acceptance bar, navigation, and
shared decisions. Each feature gets its own spec that references this one.

## Audience

University students who know nothing about nanoplastic pollution. Not scientists,
not activists. They open the app once, curious. Every feature must work for
someone who has never heard the word "nanoplastic".

Primary region: the Arabic-speaking Gulf and Levant. Hot climate, bottled water
and 20 L cooler jugs as the default drink, bottles kept in cars, delivered food
in plastic, karak and coffee in disposable cups, wall-to-wall carpet and majlis
textiles, air conditioning, dust days, coastal cities on the Gulf and Red Sea.
Arabic is a first-class locale: every string ships in Arabic in the same commit
as English.

Iran is named in the project's ambitions but the app has no Persian locale.
Until a `fa` locale exists, Iranian students are not a served audience and no
spec claims them. Adding `fa` is its own task, listed under later features.

The student may want to go further: study the topic, or work on a solution.
Every feature ends with a door to that, never with only a number. The existing
idea submission and Sources screens are those doors.

## Thesis to carry through every feature

This is the project's central claim and the reason NanoSolve exists. It is
stated plainly, not hedged:

> Nanoplastics carry an electrostatic charge. Friction renews that charge
> (the triboelectric effect), and charge is what lets these particles cross
> biological barriers, bind to proteins and lipids, and disrupt water and
> living tissue. Charge is the root cause. Particle count is only the symptom.

Every feature must show this at least once, visually, not as a paragraph:
particles do not merely exist, they are charged, and charged particles behave
differently from neutral ones.

### The evidence the app can point to

Published work supporting the mechanism, cited wherever the thesis appears:

- Surface charge changes cell uptake and barrier integrity, in both
  directions. Neutral and low-anionic particles left the blood-brain barrier
  intact; high-anionic and cationic particles disrupted it (Lockman et al.,
  J. Drug Target. 2004).
- Surface charge governs which proteins form the corona around a particle,
  and the corona then governs passage. Cholesterol on the surface promoted
  blood-brain-barrier passage in mice; a protein corona inhibited it
  (Kopatz et al., Nanomaterials 2023).
- Surface charge outweighs corona formation in determining cytotoxicity,
  uptake and biodistribution in comparable nanoparticle systems (ACS Appl.
  Bio Mater. 2025).
- Ionic strength screens surface charge, which is why nanoplastics aggregate
  in seawater rather than staying dispersed. Charge is the variable that
  decides dispersion.
- Friction charges polymers by contact electrification, and the effect is
  well characterised for plastics; water and humidity modulate it rather than
  abolishing it.

### How the app frames it

Stated as the project's thesis, which is what it is: a mechanism claim that
the evidence above supports and that further independent work is expected to
confirm. The app says "this project's thesis is that charge is the root
cause", and then shows the evidence, rather than presenting it as settled
textbook fact. That framing is not a hedge. It is what makes the Study and
Help doors work: a student can see an open scientific question they could
help answer, which is the whole point of the app.

Where a specific chapter's source measured something other than charge, the
app says what that source measured. The bottled-water storage study counted
particles, not charge, so its line talks about fragments and heat. This
keeps individual citations honest without weakening the thesis they sit
under.

## What makes this different

Positioning, for every feature's copy and for the store listing: other apps
scan a product, count litter, or estimate exposure. NanoSolve is the place
where a student can see the problem in their own day and then join the work
on solving it. Exposure numbers are the doorway, not the product. The
knowledge of what is unsolved, and the path into it, is the product.

## Communication rules (from the literature, applies to every feature)

Sources and detail in the feature A spec, section "Evidence behind the design".
Short form:

1. Story plus explicit numbers plus picture. Never one alone.
2. The student is the protagonist. Second person, their setting.
3. Every frightening number sits next to a working response with the effect
   stated in their numbers. Prefer one-time actions and swaps over willpower.
4. No ranking against other people, and no "you are worse than average".
   Comparison to the student's own possible future is allowed. So is a
   dynamic norm ("more students here are switching") and collective efficacy
   ("N ideas came from students like you"), which are about direction and
   shared capability, not personal ranking.
5. Offer a way past the story for people who only want facts.
6. The audience is already anxious (70% of Arab youth). Add agency, not fear.
7. Where science disagrees, show the disagreement, including where the
   project's own thesis is hypothesis rather than finding.
8. Text rules: scene and body text is left-aligned in LTR and right-aligned in
   RTL, never justified. No italics for emphasis, no all-caps words, no colour
   as the only signal. Confidence tags are words, not symbols.

## Acceptance bar (applies to every feature)

Technical:

- `flutter analyze` clean, `flutter test` green, `cargo clippy` and
  `cargo test` clean for any backend change.
- Renders without overflow at 375 x 667 logical pixels, in English and in
  Arabic, and again at 200% OS text scaling, where a "one screen" layout may
  scroll but must not clip or overlap.
- Arabic typography: the app's typography tokens must not apply `letterSpacing`
  to Arabic text, which breaks letter joining. Numbers inside Arabic sentences
  are wrapped in Unicode isolates so they do not reorder.
- Design tokens only (AppSpacing / AppSizing / AppTypography / AppThemeColors).
- Every user-facing string ships in `app_en.arb` and `app_ar.arb` in the same
  commit. The other four locales are left to `gen-l10n` fallback and listed in
  a translation queue file; English copies are never pasted into their ARBs.
- Pure logic (models, calculators, rule engines) lives outside widgets and has
  unit tests written before the implementation.
- Accessibility: no information carried by colour alone; every interactive and
  animated element has a semantic label; motion respects the OS reduce-motion
  setting; nothing flashes faster than three times per second.

Human, per feature:

- Three university students, no prior knowledge, use the feature unassisted.
  At least one uses the Arabic build.
- Each can afterwards explain in their own words: what a nanoplastic is, why
  charge matters, and one concrete thing the feature told them.
- If two of three cannot, the feature is not done.

Human test protocol, because this is research on people:

- Read a three-sentence consent script: what is being tested, that the app is
  being tested and not them, that they can stop, and that nothing is recorded
  beyond written notes.
- Capture the same fields each time: the three explanations verbatim, where
  they hesitated, what they tapped first, and whether they finished.
- Notes carry no names. They are stored in the repository under
  `docs/research/` with the date and the build.

## Success is measured, not asserted

The three-student test says whether the feature is understandable. It cannot
say whether it works at scale. Every feature therefore ships with a small
funnel, defined in its own spec, and a target for each step. A feature with no
instrumentation is not finished.

Events go to the project's own backend, never to Firebase Analytics: the
backend is already in the trust boundary, the payload can be kept free of
personal data, and a self-hosted endpoint keeps working where Google services
do not. The event contract lives in "Shared decisions" below.

## Navigation

The hub is a fixed 2x2 quadrant (Human, Planet, Sources, Results) plus
Settings. Five tools do not fit as five more quadrants.

Decision: a new `ExploreScreen` lists the tools as cards, reached from a
button placed in the centre of the hub, between the four quadrants. The
quadrant geometry and its `HubButtonPosition` enum are untouched. Badges live
in Results, where competition already is.

The hub change happens once, in feature A. Later features only add a card.

First run is routed, not left to chance: a student who has never opened a tool
lands on the Explore screen once after onboarding, with the newest tool card
expanded. After that the hub behaves as it does today.

## Build order and dependencies

| # | Feature | Backend | New packages | Depends on |
|---|---------|---------|--------------|------------|
| A | Footprint calculator | `ideas.context` JSONB, `app_events` table, two endpoints | fl_chart | hub entry, Explore screen |
| B | Data dashboards | none | fl_chart (from A) | A |
| C | Badges | badge table + endpoint | none | A's event pipeline |
| D | Ingredient reader | none | camera, OCR, mobile_scanner | Explore screen |
| E | Map + fragmentation simulation | table, photo upload, NOAA ingest | flutter_map, geolocator, camera | Explore screen |

Named follow-ups, deliberately not in A:

- Share card as an image (feature A ships a text-and-link share; the rendered
  card follows in B, where charts already exist).
- A web landing page that opens a shared link without an install.
- Store listing rewrite, campus and society distribution, QR posters.
- Research brief templates, measurement uploads, and a contact path to a lab.
- Persian (`fa`) locale.

## Shared decisions

- Ideas are the training corpus. Every feature that ends in "Help" sends
  through the existing `POST /api/ideas`, never a side channel, and attaches a
  `context` JSON (source feature, the numbers or scan or location that led
  there) so the corpus records why, not only what. Consent precedes every send.
- `ideas.context` is private. It is never returned by `GET /api/ideas`,
  `GET /api/ideas/:id`, or the solver endpoints. Feature A's spec states how.
- Charts: `fl_chart`. Pure Dart, no native code, maintained, works on every
  platform this app targets. Values spanning more than two orders of magnitude
  are drawn on a log scale with the scale named on the axis.
- Build flavors: features ship in the full flavor only, in the sense that lite
  is deprecated. No feature gating code. Removing the lite flavor is a separate
  cleanup.
- Dashboard data (feature B): curated JSON in assets for the charge and health
  facts, plus World Bank "What a Waste" 3.0 for plastic waste by country and
  Our World in Data's plastic waste trade series, which is the only genuine
  annual per-country time series available. The widely cited plastic waste
  generation total is a 2010 baseline last updated in 2017 and must not carry
  a trend line.
  Verified 2026-09-05: CC BY 4.0, commercial use permitted, no API key, all
  thirteen Middle East countries covered, last updated 2026-03-20. Use the
  per-indicator CSVs, never the JSON endpoint, which silently drops the
  dimension that says which number is plastic. Two files, 1.4 MB and 385 KB,
  are small enough to bundle. Every value must be displayed with its own
  reference year, because they range from 2004 for Iran to 2022 for the Gulf.
  Details and endpoints in `docs/data-sources.md`.
- Badges (feature C): first badge on first report opened. Second badge on the
  first idea in a water or filtration category that finishes evaluation,
  regardless of score. Feature C also closes the loop: the student sees what
  became of the idea they sent.
- Map (feature E): no moderation. Reports go live on upload. Existing
  measurements come from NOAA's marine microplastics layer, cached in
  Postgres rather than called from the handset. Use the
  `Hub_Microplastics_Replace` layer; the `Marine_Microplastics_WGS84` layer
  that most guides name is three years stale.
- Feature D is an ingredient reader, not a barcode scanner. Photographing the
  ingredient list is the primary path and barcode lookup is the optimisation,
  because Open Food Facts holds packaging data for 34 products in Egypt, 12
  in Bahrain and 9 in Oman. A barcode-first design would not fire in this
  region. Arabic and Farsi reading is the differentiator: the leading
  incumbent handles English labels only. Open Food Facts is called directly
  from Flutter, never proxied through our backend, because its rate limit is
  per user only when the request comes from the user's own device.
- Anything regional is literature-derived. The monitoring databases are
  empty here: NOAA holds two records for the entire Arabian Gulf and six for
  the Red Sea, out of 29,076 worldwide. The papers exist even where the
  databases do not, and saying so plainly is better material for a student
  than pretending the coverage is there.
- AR (feature E): camera preview with a drawn particle simulation, not
  ARKit/ARCore. Flutter AR plugins are unmaintained.

### Usage events: the contract

One table, `app_events`, and one endpoint, `POST /api/events`, introduced by
feature A and used by every later feature.

- Identifier: a random `install_id` generated on first run and stored in
  `SharedPreferences`. It is not the user id, not the device id, not derived
  from anything. Clearing app data ends it.
- Payload per event: `install_id`, `name`, `at`, `locale`, `platform`, and a
  small `props` JSON restricted to enumerated keys. No free text, no habit
  values, no coordinates, no identifiers of any kind.
- Batched and best-effort: events are queued locally and posted in one request;
  failures are dropped, never retried into a growing queue.
- Retention: 180 days, enforced by a scheduled delete. Stated in the privacy
  policy.
- Off switch: Settings gains "Usage statistics" defaulting to on, and when off
  nothing is queued or sent. The existing privacy screen text about disabling
  analytics must become true for this pipeline too.
- Disclosure: the privacy policy must name this collection before feature A
  ships, in English and Arabic. Saudi and UAE personal data laws both expect a
  stated purpose and retention period.
