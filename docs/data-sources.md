# Live data sources

Endpoints hit live 2026-09-05 and 2026-09-06. Status codes and response
shapes below are real, not assumed. Where something could not be confirmed,
it says so.

Re-check before relying on any of these. Several that public guides still
recommend are already dead, and one widely-cited endpoint quietly serves
three-year-old data.

## The finding that shapes everything

**The Middle East is a data desert in every pollution-monitoring database,
while being a research powerhouse.**

NOAA's global marine microplastics database holds 29,076 records. The entire
Arabian Gulf has **2**. The Red Sea has **6**. The Levant eastern
Mediterranean has 133. About 151 records for the whole region. EMODnet has
none at all east of Suez.

Yet the literature is substantial: on the microplastics topic OpenAlex counts
2,363 works from Iran, 1,689 from Saudi Arabia, 1,636 from Egypt, 443 from
the UAE and 264 from Qatar, with 2,655 published since 2024.

The regional numbers exist. They are in papers, not in databases. **Anything
regional this app shows has to be literature-derived, and that has to be the
plan from day one rather than a fallback.**

For a student, this is not a limitation to apologise for. It is the most
honest thing the app can say: nobody has measured your sea properly, and you
could be the one who does.

## Regional anchors worth citing

Open-access, regional, recent. These are the numbers to put in front of a
Gulf student.

**Jaywun expedition**, Frontiers in Marine Science, July 2026, CC BY,
doi 10.3389/fmars.2026.1856396. Microplastic concentrations in water:

| Sea | Particles per litre |
|---|---|
| Arabian Sea | 56.0 ± 31.6 |
| Strait of Hormuz | 34.4 ± 24.2 |
| Suez Canal | 31.3 ± 10.1 |
| UAE waters | 30.6 ± 21.4 |
| Red Sea | 24.5 ± 11.0 |
| Mediterranean | 15.5 ± 9.6 |

Polyester and PET make up more than 57% of the polymers found.

**Gulf of Aqaba, Jordan**, MDPI Water, January 2026, CC BY,
doi 10.3390/w18030370: 6.7 ± 6.05 particles per litre in the water column,
2,900 ± 1,650 particles per kilogram in sediment.

**Plastic Atlas MENA edition**, Heinrich Böll Stiftung, **Arabic and English,
CC BY 4.0 with commercial use explicitly permitted**. Forty-nine infographics
that can legally be remixed for an Arabic-speaking audience. Graphics only,
no underlying data, but for this project's audience that licence on Arabic
material is rare and valuable.

**Qatar open data**, `data.gov.qa`. Bilingual `label_en` and `label_ar`
fields, CC BY, 500,000 requests a day, no key. Real datasets on waste by type,
coastal water quality, and plastics trade. One caution: its dataset named
`plastic-debris-density0` contains no plastic data at all, only chlorophyll,
nitrate and salinity. It is mislabelled.

## Feature B, dashboards

### World Bank "What a Waste" 3.0 — country plastic share

Current to 2026-03-20, CC BY 4.0, commercial use permitted, no key, all
thirteen target countries.

**Use the CSV, never the JSON endpoint, for anything about plastic.** The
JSON API silently drops the `WASTE_PRODUCT` dimension. A composition query
returns seven unlabelled numbers summing to 100, and adding the plastic
filter returns a byte-identical response. Only the CSV carries
`WASTE_PRODUCT_LABEL`; filter on `WASTE_PRODUCT == "PL"`.

| File | Size |
|---|---|
| `https://data360files.worldbank.org/data360-data/data/WB_WAW/WM_MSW_COMP.csv` | 1.4 MB |
| `https://data360files.worldbank.org/data360-data/data/WB_WAW/WM_LEG_PLS.csv` | 385 KB |

Plastic share of municipal waste, edition 3.0: Bahrain 29.98% (2022), Oman
25.66 (2022), UAE 24.96 (2015), Kuwait 20.00 (2021), Israel 19.00 (2020),
Jordan 15.00 (2015), Qatar 14.00 (2016), Egypt 13.00 (2017), Lebanon 12.50
(2021), Saudi Arabia 10.47 (2022), Iran 7.77 (2004), Iraq 6.71 (2008),
Türkiye 5.86 (2018).

Two traps. Reference years run from 2004 to 2022, so every value must show
its own year or a bar chart implies a comparison that does not exist. And
Bahrain moved from 7.4% to 29.98% between editions, a fourfold revision, so
pin the edition or a cached value looks like a bug.

The best material here is `WM_LEG_PLS`, national plastic legislation dated
2026, at three stages. Türkiye has all three. Lebanon has none. Saudi Arabia
covers disposal and use but not manufacture. It tells a student what their
own government has and has not done.

### Our World in Data — one real time series, several snapshots

The distinction matters more than the freshness label suggests.

| Dataset | Span | Next update |
|---|---|---|
| `plastic-waste-trade` (UN Comtrade) | **1988 to 2024** | 2026-09-25 |
| `plastic-pollution`, `plastic-waste-generation` (Cottom 2024) | 2020 only | 2027-01-14 |
| `global-plastics-production`, `plastic-fate` (OECD) | to 2019 | none |
| `plastic-waste-generation-total` (Jambeck 2015) | 2010 only, last touched 2017 | none |

**`plastic-waste-trade` is the only genuine annual per-country series.** The
commonly cited `plastic-waste-generation-total` is a 2010 baseline that has
not been updated since 2017; do not build a "pollution over time" chart on
it.

The Cottom 2024 underlying data is on Dryad, doi 10.5061/dryad.8cz8w9gxb,
**CC0**, covering 50,702 municipalities rather than OWID's country roll-up.
That is the cleanest licence in this whole review.

### UN SDG API — best annual per-country series

Live, keyless, annual to 2024, seven to eight of our countries for
`EN_MWT_GENV` and `EN_MWT_RCYR`. Attribution only.

Avoid `EN_MAR_BEALIT_PUSA`: its values are cleanup-effort artefacts. Saudi
Arabia reads 9,360,000 items per 100 square metres. Do not draw a trend line
through it. `EN_MAR_PLASDD` is effectively empty, twenty observations
worldwide and none in the region.

## Feature E, the pollution map

### NOAA NCEI global marine microplastics

The only source that is live, keyless, GeoJSON-native, public domain, and has
any points at all in our region.

```
https://services2.arcgis.com/C8EMgrsFcRFL6LrL/ArcGIS/rest/services/Hub_Microplastics_Replace/FeatureServer/0/query
```

**Use that layer, not `Marine_Microplastics_WGS84`.** Nearly every guide
points at the older one, which holds 22,530 records with the newest sample
from 2023-02-12. The live layer holds 29,076 records with samples through
2026-04-28 and a last edit of 2026-06-25. Following the common advice would
have shipped three-year-old data.

Public domain, quarterly refresh, 2,000 records per page, and every row
carries its own source DOI, so the same ingest feeds both the map and the
citation layer. Server-side aggregation works, so a per-country bar chart is
one request rather than a full download.

Two gotchas. The `Country` attribute is null on roughly two-thirds of rows
and contains typos such as "Saudia Arabia", so filter spatially by envelope
rather than by that field. And cache in Postgres rather than calling Esri
from the handset.

## Feature D, the barcode scanner

### The design has to change: OCR first, barcode second

Open Food Facts and Open Beauty Facts are the only viable option, and the
packaging mechanic works beautifully in isolation. A product lookup returns
structured per-component packaging with a `food_contact` flag, which is
exactly what "plastic-shedding packaging" needs.

The problem is coverage in our markets.

| Country | Open Beauty Facts | Open Food Facts |
|---|---|---|
| Saudi Arabia | 868 | 8,923 |
| UAE | 400 | 4,064 |
| Qatar | 229 | 3,872 |
| Egypt | 239 | 2,273 |
| Kuwait | 77 | 1,977 |
| Lebanon | 59 | 1,682 |
| Oman | 29 | 308 |
| *France, for comparison* | *20,753* | *1,264,650* |

Worse, only 170,669 of 4.73 million products carry any plastic packaging tag
at all, and in our markets that collapses to 34 products in Egypt, 12 in
Bahrain, 9 in Oman. **A barcode-first scanner will simply fail to fire in
Riyadh or Cairo.**

So: photograph the ingredient list and read it, with barcode lookup as the
optimisation when the product happens to be known. That is what the
incumbents do. **Arabic and Farsi OCR is an open differentiator, because the
leading app scans English labels only.**

### Two implementation rules

**Call Open Food Facts directly from Flutter, never through the Rust
backend.** Their limits are 15 product reads and 10 searches per minute, and
their documentation says the limit applies per user when requests come from
the user's device. Proxying would collapse every user onto one address and
one shared budget.

**Check the content type, not the status code.** On rate limit, Open Food
Facts serves an HTML block page with HTTP 200. A client that trusts the
status will parse a web page as product data.

A custom `User-Agent` naming the app and a contact address is required.

### There is no clean list of plastic ingredient names

This is the finding for Feature D. No maintained, downloadable,
licence-clean list of microplastic INCI names exists anywhere.

Beat the Microbead's Red List is the obvious candidate and its terms
expressly forbid commercial use and derivative works. Its terms do invite
collaboration, so **emailing Plastic Soup Foundation is the highest-value
next step for this feature.** PlastChem is CC BY-NC. The UNEP chemicals
annex forbids commercial use outright. The authoritative PCPC dictionary is
$725 or more per user per year with no API and no redistribution.

EU Regulation 2023/2055 contains no polymer list at all: it is a
property-based definition, so it cannot be turned into a lookup table.

The workable path: seed from the ECHA Annex XV report's Table 44, nineteen
generic polymers with cosmetic functions under an EU reuse licence, expand
**by CAS number** against the Open Beauty Facts taxonomy and the FCCprio
dataset (CC BY 4.0, published 2026-09-01), normalise names through the EU
CosIng bulk CSVs (CC BY 4.0, no key, updated 2026-08-28), and publish the
result under ODbL at a public URL. That one file discharges the share-alike
obligation, and ODbL is a database licence that never touches app code.

### Three traps in the matching engine

**The taxonomy rollup is a lie.** `en:plastics` has only twenty children and
**polyethylene is not one of them**, despite being the most common cosmetic
microbead polymer. Polyethylene has no parent tags at all. Query each polymer
tag individually and never trust the rollup.

**Substring matching produces systematic false positives.** Twenty-two of
thirty-six short entries in the published lists are substrings of longer
ones: "Nylon" inside "Nylon 12", "PEG-12" inside "PEG-120 Glucose Dioleate".
Use word-boundary, longest-match-first.

**Do not pattern-match on "poly".** A regex over the taxonomy yields 2,565
candidates, mostly wrong: polyglyceryls are emulsifiers, polypeptides are
proteins. Match on CAS number.

**Never claim regulatory compliance.** EU law defines microplastics by
particle properties in a specific formulation, not by ingredient name. The
same name can be in or out of scope depending on grade. Present a result as
an indicator with a source and a date.

## Keeping the coefficients current

This is the purpose that works best and costs almost nothing.

**OpenAlex went usage-priced on 2026-02-24**, so the common advice that it is
free and unlimited is now wrong. Looking up a single work by DOI is still
free. Filtered lists cost $0.0001 per call and searches $0.001. An anonymous
budget is $0.10 a day and a free key raises it to $1.

The refresh job is two steps per coefficient: look up the cited paper by DOI,
which is free, then ask for newer work citing it, which is one credit.
Running that nightly for ten coefficients costs well under a cent a month.
Use the topic filter rather than a text search, which is ten times cheaper.

Supporting APIs, all free and all verified: Crossref at three requests per
second in the polite pool, PubMed E-utilities at three per second, and
OpenCitations under CC0. Europe PMC works but returned HTTP 503 on every
endpoint for about ten minutes during testing before recovering on its own,
so treat it as secondary and build in backoff.

Realistic alert volume: a Europe PMC query across our exposure routes for
2026 returns 231 papers, and PubMed returns about 32 new nanoplastics papers
a week. Small enough for a person to triage, which is the point.

One Crossref gotcha: `from-index-date` catches re-indexed old records, not
only new publications. Use `from-pub-date` for genuinely new work.

Do not plan on Semantic Scholar: anonymous requests returned 429 on six
consecutive attempts.

**Four of the app's seven exposure routes carry a formal published dispute.**
Cox 2019 has an erratum correcting the adult total to about 113,743 per year
rather than the widely quoted 121,664. The "five grams a week" figure is the
upper bound of a 0.1 to 5 gram range and is contested as overestimating by
orders of magnitude. The tea-bag and microwave papers both have published
comment and response exchanges. This is why the coefficient table ships
ranges and tags rather than point estimates.

## Do not use

**Abandoned or frozen:** LITTERBASE, unchanged for about two and a half years
with no API and its download button saving a picture of a chart. The European
Environment Agency's Marine LitterWatch, last event January 2020, topic page
now HTTP 410 Gone. Global Plastic Watch, stops at 2022 and forbids commercial
use. OECD plastics, frozen at 2019. NanoCommons, DNS gone. MEMAC, HTTP 500.

**Do not link students to `medqsr.org`.** The domain has been squatted and now
serves a fitness site.

**No machine-readable regional monitoring data exists.** ROPME is unreachable
over HTTP despite an open port, MEMAC returns 500, PERSGA publishes PDFs. An
archived ROPME page advertises a live-data section and a portal that was due
in April 2026, so **emailing ROPME directly is worth doing**: it would be the
only real Gulf monitoring feed in existence.

**Licence-blocked for a shipped app:** Beat the Microbead, PlastChem,
the UNEP chemicals annex, WHO reports, GESAMP, UN Comtrade directly, and both
ToMEx and Nurdle Patrol, which publish no licence at all and are therefore
all rights reserved.

**Eligibility-blocked rather than merely expensive:** Scopus, whose free tier
is non-commercial and institution-bound, and Web of Science, which restricts
public display to an institution's own authors. There is no legal path from
an unaffiliated app. Do not design around them.

**FAO has no plastics data.** Verified three ways: a search across all
sixty-nine dataset descriptions, a manual read of every dataset name, and an
item-level check of the closest domain. Its legacy REST API now returns 401
with no public key path, so any tutorial calling it is broken.

**Does not exist, stop searching:** there is no microplastics database called
MOSAIC. The similar name belongs to an Arctic expedition whose data is in
PANGAEA.

**Looks perfect, do not trust it:** MP-GERE, published September 2026 under
CC BY 4.0, advertises 11,268 measurements including 482 Middle East rows,
which would be twenty times better regional coverage than anything else. It
is extracted by a language model from an unpublished manuscript, 933 rows are
flagged as needing manual review, and the first record inspected contained
two independent errors. **Use its Middle East DOIs as a reading list. Do not
use its numbers as data.**

## Could not confirm

Saudi, Kuwaiti and Iranian government open-data portals all failed to
complete a TCP handshake from the testing network, though DNS resolves for
most. Geo-blocking and outage are indistinguishable from outside. **Retest
from a Gulf address before writing them off.**

Several licence pages, including those of the European Chemicals Agency, UNEP
and OECD, return 403 to automated requests, so statements about their terms
rest on secondary sources rather than the verbatim clauses.

The two Open Food Facts indexes disagree with each other: the UAE shows 8,885
products through the v2 API and 4,064 through the search index, whose sampled
documents were last indexed in 2024. **The search index is stale. Use the v2
API or the daily dump for anything that must be accurate.**
