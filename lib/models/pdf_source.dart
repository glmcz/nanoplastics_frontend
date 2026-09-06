class PDFSource {
  final String title;
  final int startPage;
  final int endPage;
  final String description;
  final String? pdfAssetPath; // Custom PDF asset path for non-main report PDFs
  final String language; // 'cs' for Czech, 'en' for English
  final String?
      url; // Optional URL for web links (opens in browser instead of PDF viewer)
  final int?
      actualPageCount; // Optional: actual page count for main reports (when known)
  final bool isNew; // Mark newly added sections for visual highlighting

  PDFSource({
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    this.pdfAssetPath,
    this.language = 'en',
    this.url,
    this.actualPageCount,
    this.isNew = false,
  });

  /// Returns true if this source should open as a web link
  bool get isWebLink => url != null && url!.isNotEmpty;

  /// Sentinel value for "all pages until end of document" (1,073,741,824)
  /// Used to indicate a document should be read from startPage to the end
  static const int endPageSentinel = 1 << 30;

  /// Check if this source uses the "all pages to end" sentinel
  bool get isEndPageSentinel => endPage == endPageSentinel;

  /// Get a user-friendly page range display string
  /// Shows "Pages X-Y" for regular ranges, "Pages X-Z (full document)" for sentinel+actualCount,
  /// or "Full document" for sentinel without known page count
  String getPageRangeDisplay() {
    if (isEndPageSentinel) {
      if (actualPageCount != null) {
        return 'Pages $startPage-$actualPageCount (full document)';
      }
      return 'Full document';
    }
    return 'Pages $startPage-$endPage';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Base URLs for hosted PDFs
// ─────────────────────────────────────────────────────────────────────────────
const _enBase =
    'https://allatra.org/storage/app/media/reports/en/Nanoplastics_in_the_Biosphere_Report.pdf';
const _czBase =
    'https://allatra.org/storage/app/media/reports/cs/Nanoplastics_in_the_Biosphere_Report_CS.pdf';
const _esBase =
    'https://allatra.org/storage/app/media/reports/es/Nanoplasticos_en_la_Biosfera_Informe_ES.pdf';
const _frBase =
    'https://allatra.org/storage/app/media/reports/fr/Nanoplastics_in_the_Biosphere_Report_FR.pdf';
const _ruBase =
    'https://allatra.org/storage/app/media/reports/ru/Nanoplastics_in_the_Biosphere_Report_RU.pdf';

// ─────────────────────────────────────────────────────────────────────────────
// Human Health Category
// ─────────────────────────────────────────────────────────────────────────────
final List<PDFSource> humanHealthSources = [
  // ── Czech ─────────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Poruchy autistického spektra a BPA',
    startPage: 92,
    endPage: 114,
    description: 'Centrální systémy (mozek a nervový systém)',
    language: 'cs',
    url: '$_czBase#page=92',
  ),
  PDFSource(
    title: 'Bioakumulace v lidském mozku',
    startPage: 92,
    endPage: 114,
    description: 'Centrální systémy (mozek a nervový systém)',
    language: 'cs',
    url: '$_czBase#page=92',
  ),
  PDFSource(
    title: 'Kardiovaskulární rizika (Ateromy)',
    startPage: 116,
    endPage: 119,
    description: 'Vitalita a tkáně (srdce, krev, orgány)',
    language: 'cs',
    url: '$_czBase#page=116',
  ),
  PDFSource(
    title: 'Nepříznivé výsledky porodů v USA (ftaláty)',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
    url: '$_czBase#page=120',
  ),
  PDFSource(
    title: 'Redukce příjmu MNP vařením vody',
    startPage: 71,
    endPage: 91,
    description: 'Filtrace a detox (ledviny, játra, lymfatický systém)',
    language: 'cs',
    url: '$_czBase#page=71',
  ),
  PDFSource(
    title: 'Kvantové efekty a přenos protonů v buňkách',
    startPage: 92,
    endPage: 119,
    description: 'Fyzický útok (kvantové, molekulární, buněčné poškození)',
    language: 'cs',
    url: '$_czBase#page=92',
  ),
  PDFSource(
    title: 'Plasty v mužském semeni',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
    url: '$_czBase#page=120',
  ),
  PDFSource(
    title: 'Plasty v ženské folikulární tekutině',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
    url: '$_czBase#page=120',
  ),
  PDFSource(
    title: 'Kontaminace mléčných výrobků',
    startPage: 70,
    endPage: 91,
    description: 'Vstupní brány (vdechování, požití, pronikání kůží)',
    language: 'cs',
    url: '$_czBase#page=70',
  ),
  PDFSource(
    title: 'Expozice ftalátům a rakovina u dětí',
    startPage: 92,
    endPage: 119,
    description: 'Fyzický útok (kvantové, molekulární, buněčné poškození)',
    language: 'cs',
    url: '$_czBase#page=92',
  ),
  // ── English ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Autism Spectrum Disorders and BPA',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
    language: 'en',
    url: '$_enBase#page=92',
  ),
  PDFSource(
    title: 'Bioaccumulation in Human Brain',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
    language: 'en',
    url: '$_enBase#page=92',
  ),
  PDFSource(
    title: 'Cardiovascular Risks (Atheromas)',
    startPage: 116,
    endPage: 119,
    description: 'Vitality & Tissues (Heart, Blood, Organs)',
    language: 'en',
    url: '$_enBase#page=116',
  ),
  PDFSource(
    title: 'Adverse Birth Outcomes in USA (Phthalates)',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
    url: '$_enBase#page=120',
  ),
  PDFSource(
    title: 'Reducing MNP Intake by Boiling Water',
    startPage: 71,
    endPage: 91,
    description: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
    language: 'en',
    url: '$_enBase#page=71',
  ),
  PDFSource(
    title: 'Quantum Effects and Proton Transfer in Cells',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
    language: 'en',
    url: '$_enBase#page=92',
  ),
  PDFSource(
    title: 'Plastics in Male Semen',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
    url: '$_enBase#page=120',
  ),
  PDFSource(
    title: 'Plastics in Female Follicular Fluid',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
    url: '$_enBase#page=120',
  ),
  PDFSource(
    title: 'Dairy Products Contamination',
    startPage: 70,
    endPage: 91,
    description: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
    language: 'en',
    url: '$_enBase#page=70',
  ),
  PDFSource(
    title: 'Phthalate Exposure and Childhood Cancer',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
    language: 'en',
    url: '$_enBase#page=92',
  ),
  PDFSource(
    title: 'Neurobiological Risk: CNS Penetration & Brain Dysfunction',
    startPage: 90,
    endPage: 100,
    description: 'Bioaccumulation in CNS & Neurodegeneration Risks',
    language: 'en',
    pdfAssetPath:
        'assets/docs/EN_report_nanoplastics_a_systematic_risk_analysis_for_human_health_ecosystems_and_the_environment_compressed.pdf',
    isNew: true,
  ),
  // ── French ────────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Troubles du spectre autistique et BPA',
    startPage: 93,
    endPage: 114,
    description: 'Systèmes centraux (cerveau et système nerveux)',
    language: 'fr',
    url: '$_frBase#page=93',
  ),
  PDFSource(
    title: 'Bioaccumulation dans le cerveau humain',
    startPage: 93,
    endPage: 114,
    description: 'Systèmes centraux (cerveau et système nerveux)',
    language: 'fr',
    url: '$_frBase#page=93',
  ),
  PDFSource(
    title: 'Risques cardiovasculaires (athéromes)',
    startPage: 116,
    endPage: 119,
    description: 'Vitalité et tissus (cœur, sang, organes)',
    language: 'fr',
    url: '$_frBase#page=116',
  ),
  PDFSource(
    title: 'Issues défavorables de la grossesse aux États-Unis (phtalates)',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction et développement (placenta, fœtus, fertilité)',
    language: 'fr',
    url: '$_frBase#page=120',
  ),
  PDFSource(
    title: "Réduction de l'apport en MNP par l'ébullition de l'eau",
    startPage: 71,
    endPage: 91,
    description: 'Filtration et détox (reins, foie, système lymphatique)',
    language: 'fr',
    url: '$_frBase#page=71',
  ),
  PDFSource(
    title: 'Effets quantiques et transfert de protons dans les cellules',
    startPage: 93,
    endPage: 119,
    description:
        'Attaque physique (dommages quantiques, moléculaires, cellulaires)',
    language: 'fr',
    url: '$_frBase#page=93',
  ),
  PDFSource(
    title: 'Plastiques dans le sperme masculin',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction et développement (placenta, fœtus, fertilité)',
    language: 'fr',
    url: '$_frBase#page=120',
  ),
  PDFSource(
    title: 'Plastiques dans le liquide folliculaire féminin',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction et développement (placenta, fœtus, fertilité)',
    language: 'fr',
    url: '$_frBase#page=120',
  ),
  PDFSource(
    title: 'Contamination des produits laitiers',
    startPage: 70,
    endPage: 91,
    description: "Portes d'entrée (inhalation, ingestion, pénétration cutanée)",
    language: 'fr',
    url: '$_frBase#page=70',
  ),
  PDFSource(
    title: 'Exposition aux phtalates et cancer infantile',
    startPage: 91,
    endPage: 119,
    description:
        'Attaque physique (dommages quantiques, moléculaires, cellulaires)',
    language: 'fr',
    url: '$_frBase#page=91',
  ),
  // ── Spanish ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Trastornos del espectro autista y BPA',
    startPage: 93,
    endPage: 114,
    description: 'Sistemas centrales (cerebro y sistema nervioso)',
    language: 'es',
    url: '$_esBase#page=93',
  ),
  PDFSource(
    title: 'Bioacumulación en el cerebro humano',
    startPage: 93,
    endPage: 114,
    description: 'Sistemas centrales (cerebro y sistema nervioso)',
    language: 'es',
    url: '$_esBase#page=93',
  ),
  PDFSource(
    title: 'Riesgos cardiovasculares (ateromas)',
    startPage: 116,
    endPage: 119,
    description: 'Vitalidad y tejidos (corazón, sangre, órganos)',
    language: 'es',
    url: '$_esBase#page=116',
  ),
  PDFSource(
    title: 'Resultados adversos en el parto en EE. UU. (ftalatos)',
    startPage: 120,
    endPage: 131,
    description: 'Reproducción y desarrollo (placenta, feto, fertilidad)',
    language: 'es',
    url: '$_esBase#page=120',
  ),
  PDFSource(
    title: 'Reducción de la ingesta de MNP mediante el hervido del agua',
    startPage: 71,
    endPage: 91,
    description: 'Filtración y desintoxicación (riñones, hígado, linfático)',
    language: 'es',
    url: '$_esBase#page=71',
  ),
  PDFSource(
    title: 'Efectos cuánticos y transferencia de protones en las células',
    startPage: 93,
    endPage: 119,
    description: 'Ataque físico (daño cuántico, molecular, celular)',
    language: 'es',
    url: '$_esBase#page=93',
  ),
  PDFSource(
    title: 'Plásticos en el semen masculino',
    startPage: 120,
    endPage: 131,
    description: 'Reproducción y desarrollo (placenta, feto, fertilidad)',
    language: 'es',
    url: '$_esBase#page=120',
  ),
  PDFSource(
    title: 'Plásticos en el líquido folicular femenino',
    startPage: 120,
    endPage: 131,
    description: 'Reproducción y desarrollo (placenta, feto, fertilidad)',
    language: 'es',
    url: '$_esBase#page=120',
  ),
  PDFSource(
    title: 'Contaminación de productos lácteos',
    startPage: 70,
    endPage: 91,
    description: 'Vías de entrada (inhalación, ingestión, penetración cutánea)',
    language: 'es',
    url: '$_esBase#page=70',
  ),
  PDFSource(
    title: 'Exposición a ftalatos y cáncer infantil',
    startPage: 91,
    endPage: 119,
    description: 'Ataque físico (daño cuántico, molecular, celular)',
    language: 'es',
    url: '$_esBase#page=91',
  ),
  // ── Russian ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Расстройства аутистического спектра и БПА',
    startPage: 93,
    endPage: 114,
    description: 'Центральные системы (мозг и нервная система)',
    language: 'ru',
    url: '$_ruBase#page=93',
  ),
  PDFSource(
    title: 'Биоакумуляция в мозге человека',
    startPage: 93,
    endPage: 114,
    description: 'Центральные системы (мозг и нервная система)',
    language: 'ru',
    url: '$_ruBase#page=93',
  ),
  PDFSource(
    title: 'Сердечно-сосудистые риски (атеромы)',
    startPage: 116,
    endPage: 119,
    description: 'Жизнеспособность и ткани (сердце, кровь, органы)',
    language: 'ru',
    url: '$_ruBase#page=116',
  ),
  PDFSource(
    title: 'Неблагоприятные исходы родов в США (фталаты)',
    startPage: 120,
    endPage: 131,
    description: 'Репродукция и развитие (плацента, плод, фертильность)',
    language: 'ru',
    url: '$_ruBase#page=120',
  ),
  PDFSource(
    title: 'Снижение потребления MNP путем кипячения воды',
    startPage: 71,
    endPage: 91,
    description: 'Фильтрация и детокс (почки, печень, лимфатическая система)',
    language: 'ru',
    url: '$_ruBase#page=71',
  ),
  PDFSource(
    title: 'Квантовые эффекты и перенос протонов в клетках',
    startPage: 93,
    endPage: 119,
    description:
        'Физическое воздействие (квантовые, молекулярные, клеточные повреждения)',
    language: 'ru',
    url: '$_ruBase#page=93',
  ),
  PDFSource(
    title: 'Пластмассы в мужской сперме',
    startPage: 120,
    endPage: 131,
    description: 'Репродукция и развитие (плацента, плод, фертильность)',
    language: 'ru',
    url: '$_ruBase#page=120',
  ),
  PDFSource(
    title: 'Пластик в фолликулярной жидкости женщин',
    startPage: 120,
    endPage: 131,
    description: 'Репродукция и развитие (плацента, плод, фертильность)',
    language: 'ru',
    url: '$_ruBase#page=120',
  ),
  PDFSource(
    title: 'Загрязнение молочных продуктов',
    startPage: 70,
    endPage: 91,
    description:
        'Пути проникновения (вдыхание, проглатывание, проникновение через кожу)',
    language: 'ru',
    url: '$_ruBase#page=70',
  ),
  PDFSource(
    title: 'Воздействие фталатов и рак у детей',
    startPage: 91,
    endPage: 119,
    description:
        'Физическое воздействие (квантовые, молекулярные, клеточные повреждения)',
    language: 'ru',
    url: '$_ruBase#page=91',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Earth Pollution Category
// ─────────────────────────────────────────────────────────────────────────────
final List<PDFSource> earthPollutionSources = [
  // ── Czech ─────────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Nanoplasty v biosféře - Zpráva (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Kompletní komplexní zpráva o nanoplastech',
    language: 'cs',
    url: _czBase,
  ),
  PDFSource(
    title: 'Nové metody detekce a řešení nanoplastu',
    startPage: 1,
    endPage: 1 << 30,
    description: 'Technologická řešení a metodiky detekce',
    language: 'cs',
    pdfAssetPath: 'assets/docs/CS_Nove_metody_detekce_a_reseni_nanoplastu.pdf',
    isNew: true,
  ),
  PDFSource(
    title: 'Acidifikace oceánů rozkladem plastů',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
    url: '$_czBase#page=45',
  ),
  PDFSource(
    title: 'Kontaminace nejhlubších částí oceánu',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
    url: '$_czBase#page=45',
  ),
  PDFSource(
    title: 'Zánik korálových útesů',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
    url: '$_czBase#page=45',
  ),
  PDFSource(
    title: 'Geofyzikální zlom v roce 1995',
    startPage: 68,
    endPage: 69,
    description: 'Magnetické pole a jádro Země',
    language: 'cs',
    url: '$_czBase#page=68',
  ),
  // ── English ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Global Photosynthesis Losses',
    startPage: 31,
    endPage: 44,
    description: 'Flora, Fauna & Soil Biota (Terrestrial Ecosystems)',
    language: 'en',
    url: '$_enBase#page=31',
  ),
  PDFSource(
    title: 'Fragment Growth in Pacific Garbage Patch',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
    url: '$_enBase#page=45',
  ),
  PDFSource(
    title: 'Plastic Emissions from Ocean to Atmosphere',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
    url: '$_enBase#page=45',
  ),
  PDFSource(
    title: 'Crossing the Blood-Brain Barrier',
    startPage: 92,
    endPage: 119,
    description: 'Physical Properties (Polymer Degradation)',
    language: 'en',
    url: '$_enBase#page=92',
  ),
  PDFSource(
    title: 'Ice Formation in Atmosphere via MNP',
    startPage: 23,
    endPage: 30,
    description: 'Atmosphere & Global Water Cycle',
    language: 'en',
    url: '$_enBase#page=23',
  ),
  PDFSource(
    title: 'MNP in Clouds and Precipitation Impact',
    startPage: 23,
    endPage: 30,
    description: 'Atmosphere & Global Water Cycle',
    language: 'en',
    url: '$_enBase#page=23',
  ),
  PDFSource(
    title: 'Ocean Acidification from Plastic Decomposition',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
    url: '$_enBase#page=45',
  ),
  PDFSource(
    title: 'Contamination of Deepest Ocean Parts',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
    url: '$_enBase#page=45',
  ),
  PDFSource(
    title: 'Coral Reef Extinction',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
    url: '$_enBase#page=45',
  ),
  PDFSource(
    title: 'Geophysical Break in 1995',
    startPage: 68,
    endPage: 69,
    description: 'Magnetic Field & Earth\'s Core',
    language: 'en',
    url: '$_enBase#page=68',
  ),
  PDFSource(
    title: 'MNP Influence on Climate & Ocean Processes',
    startPage: 214,
    endPage: 226,
    description: 'Atmosphere & Ocean Acidification | Climate System Impact',
    language: 'en',
    pdfAssetPath:
        'assets/docs/EN_report_nanoplastics_a_systematic_risk_analysis_for_human_health_ecosystems_and_the_environment_compressed.pdf',
    isNew: true,
  ),
  PDFSource(
    title: 'Nanoplastics in the Biosphere Report (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Complete comprehensive report on nanoplastics',
    language: 'en',
    pdfAssetPath: 'assets/docs/Nanoplastics_Report_EN_compressed.pdf',
  ),
  // ── French ────────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Pertes mondiales dues à la photosynthèse',
    startPage: 26,
    endPage: 45,
    description: 'Flore, faune et biote des sols (écosystèmes terrestres)',
    language: 'fr',
    url: '$_frBase#page=26',
  ),
  PDFSource(
    title: 'Croissance des fragments dans le vortex de déchets du Pacifique',
    startPage: 46,
    endPage: 66,
    description: 'Océan mondial (contamination marine)',
    language: 'fr',
    url: '$_frBase#page=46',
  ),
  PDFSource(
    title: "Émissions plastiques de l'océan vers l'atmosphère",
    startPage: 46,
    endPage: 66,
    description: 'Océan mondial (contamination marine)',
    language: 'fr',
    url: '$_frBase#page=46',
  ),
  PDFSource(
    title: 'Franchir la barrière hémato-encéphalique',
    startPage: 93,
    endPage: 119,
    description: 'Propriétés physiques (dégradation des polymères)',
    language: 'fr',
    url: '$_frBase#page=93',
  ),
  PDFSource(
    title: "Formation de glace dans l'atmosphère via MNP",
    startPage: 23,
    endPage: 30,
    description: 'Atmosphère et cycle mondial de l\'eau',
    language: 'fr',
    url: '$_frBase#page=23',
  ),
  PDFSource(
    title: 'MNP dans les nuages et leur impact sur les précipitations',
    startPage: 23,
    endPage: 30,
    description: 'Atmosphère et cycle mondial de l\'eau',
    language: 'fr',
    url: '$_frBase#page=23',
  ),
  PDFSource(
    title: 'Acidification des océans due à la décomposition des plastiques',
    startPage: 46,
    endPage: 67,
    description: 'Océan mondial (contamination marine)',
    language: 'fr',
    url: '$_frBase#page=46',
  ),
  PDFSource(
    title: 'Contamination des parties les plus profondes de l\'océan',
    startPage: 46,
    endPage: 67,
    description: 'Océan mondial (contamination marine)',
    language: 'fr',
    url: '$_frBase#page=46',
  ),
  PDFSource(
    title: 'Extinction des récifs coralliens',
    startPage: 46,
    endPage: 67,
    description: 'Océan mondial (contamination marine)',
    language: 'fr',
    url: '$_frBase#page=46',
  ),
  PDFSource(
    title: 'Rupture géophysique en 1995',
    startPage: 68,
    endPage: 70,
    description: 'Champ magnétique et noyau terrestre',
    language: 'fr',
    url: '$_frBase#page=68',
  ),
  PDFSource(
    title: 'Les nanoplastiques dans la biosphère Rapport (2025)',
    startPage: 1,
    endPage: 1 << 30,
    description: 'Rapport complet et exhaustif sur les nanoplastiques',
    language: 'fr',
    url: _frBase,
  ),
  // ── Spanish ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Pérdidas globales de fotosíntesis',
    startPage: 26,
    endPage: 45,
    description: 'Flora, fauna y biota del suelo (ecosistemas terrestres)',
    language: 'es',
    url: '$_esBase#page=26',
  ),
  PDFSource(
    title: 'Crecimiento de fragmentos en la isla de basura del Pacífico',
    startPage: 46,
    endPage: 66,
    description: 'Océano mundial (contaminación marina)',
    language: 'es',
    url: '$_esBase#page=46',
  ),
  PDFSource(
    title: 'Emisiones plásticas del océano a la atmósfera',
    startPage: 46,
    endPage: 66,
    description: 'Océano mundial (contaminación marina)',
    language: 'es',
    url: '$_esBase#page=46',
  ),
  PDFSource(
    title: 'Cruzar la barrera hematoencefálica',
    startPage: 93,
    endPage: 119,
    description: 'Propiedades físicas (degradación de polímeros)',
    language: 'es',
    url: '$_esBase#page=93',
  ),
  PDFSource(
    title: 'Formación de hielo en la atmósfera a través de MNP',
    startPage: 23,
    endPage: 30,
    description: 'Atmósfera y ciclo global del agua',
    language: 'es',
    url: '$_esBase#page=23',
  ),
  PDFSource(
    title: 'MNP en las nubes y su impacto en las precipitaciones',
    startPage: 23,
    endPage: 30,
    description: 'Atmósfera y ciclo global del agua',
    language: 'es',
    url: '$_esBase#page=23',
  ),
  PDFSource(
    title: 'Acidificación de los océanos por descomposición de plásticos',
    startPage: 46,
    endPage: 67,
    description: 'Océano mundial (contaminación marina)',
    language: 'es',
    url: '$_esBase#page=46',
  ),
  PDFSource(
    title: 'Contaminación de las partes más profundas del océano',
    startPage: 46,
    endPage: 67,
    description: 'Océano mundial (contaminación marina)',
    language: 'es',
    url: '$_esBase#page=46',
  ),
  PDFSource(
    title: 'Extinción de los arrecifes de coral',
    startPage: 46,
    endPage: 67,
    description: 'Océano mundial (contaminación marina)',
    language: 'es',
    url: '$_esBase#page=46',
  ),
  PDFSource(
    title: 'Ruptura geofísica en 1995',
    startPage: 68,
    endPage: 70,
    description: 'Campo magnético y núcleo terrestre',
    language: 'es',
    url: '$_esBase#page=68',
  ),
  PDFSource(
    title: 'Informe sobre los nanoplásticos en la biosfera (2025)',
    startPage: 1,
    endPage: 1 << 30,
    description: 'Informe completo e integral sobre nanoplásticos',
    language: 'es',
    url: _esBase,
  ),
  // ── Russian ───────────────────────────────────────────────────────────────
  PDFSource(
    title: 'Глобальные потери фотосинтеза',
    startPage: 26,
    endPage: 45,
    description: 'Флора, фауна и почвенная биота (наземные экосистемы)',
    language: 'ru',
    url: '$_ruBase#page=26',
  ),
  PDFSource(
    title: 'Рост фрагментов в тихоокеанском мусорном пятне',
    startPage: 46,
    endPage: 66,
    description: 'Мировой океан (морское загрязнение)',
    language: 'ru',
    url: '$_ruBase#page=46',
  ),
  PDFSource(
    title: 'Пластиковые выбросы из океана в атмосферу',
    startPage: 46,
    endPage: 66,
    description: 'Мировой океан (морское загрязнение)',
    language: 'ru',
    url: '$_ruBase#page=46',
  ),
  PDFSource(
    title: 'Прохождение гематоэнцефалического барьера',
    startPage: 93,
    endPage: 119,
    description: 'Физические свойства (деградация полимеров)',
    language: 'ru',
    url: '$_ruBase#page=93',
  ),
  PDFSource(
    title: 'Образование льда в атмосфере посредством MNP',
    startPage: 23,
    endPage: 30,
    description: 'Атмосфера и глобальный водный цикл',
    language: 'ru',
    url: '$_ruBase#page=23',
  ),
  PDFSource(
    title: 'MNP в облаках и влияние на осадки',
    startPage: 23,
    endPage: 30,
    description: 'Атмосфера и глобальный водный цикл',
    language: 'ru',
    url: '$_ruBase#page=23',
  ),
  PDFSource(
    title: 'Закисление океана в результате разложения пластика',
    startPage: 46,
    endPage: 67,
    description: 'Мировой океан (морское загрязнение)',
    language: 'ru',
    url: '$_ruBase#page=46',
  ),
  PDFSource(
    title: 'Загрязнение самых глубоких частей океана',
    startPage: 46,
    endPage: 67,
    description: 'Мировой океан (морское загрязнение)',
    language: 'ru',
    url: '$_ruBase#page=46',
  ),
  PDFSource(
    title: 'Исчезновение коралловых рифов',
    startPage: 46,
    endPage: 67,
    description: 'Мировой океан (морское загрязнение)',
    language: 'ru',
    url: '$_ruBase#page=46',
  ),
  PDFSource(
    title: 'Геофизический прорыв в 1995 году',
    startPage: 68,
    endPage: 70,
    description: 'Магнитное поле и ядро Земли',
    language: 'ru',
    url: '$_ruBase#page=68',
  ),
  PDFSource(
    title: 'Нанопластика в биосфере Отчёт (2025)',
    startPage: 1,
    endPage: 1 << 30,
    description: 'Полный комплексный отчет о нанопластике',
    language: 'ru',
    url: _ruBase,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Special Water Abilities Category
// ─────────────────────────────────────────────────────────────────────────────
final List<PDFSource> waterAbilitiesSources = [
  PDFSource(
    title: 'Speciální vlastnosti vody',
    startPage: 1,
    endPage: 6,
    description: 'Kvantové efekty a struktura vody',
    pdfAssetPath: 'assets/docs/CS_WATER_compressed.pdf',
    language: 'cs',
  ),
  PDFSource(
    title: 'Special Water Abilities',
    startPage: 1,
    endPage: 6,
    description: 'Water Properties & Quantum Effects',
    pdfAssetPath: 'assets/docs/EN_WATER_compressed.pdf',
    language: 'en',
  ),
  PDFSource(
    title: 'Capacidades Especiales del Agua',
    startPage: 1,
    endPage: 6,
    description: 'Propiedades del agua y efectos cuánticos',
    pdfAssetPath: 'assets/docs/ESP-WATER_compressed.pdf',
    language: 'es',
  ),
  PDFSource(
    title: 'Capacités Spéciales de l\'Eau',
    startPage: 1,
    endPage: 6,
    description: 'Propriétés de l\'eau et effets quantiques',
    pdfAssetPath: 'assets/docs/FR-WATER_compressed.pdf',
    language: 'fr',
  ),
  PDFSource(
    title: 'Специальные свойства воды',
    startPage: 1,
    endPage: 6,
    description: 'Квантовые эффекты и структура воды',
    pdfAssetPath: 'assets/docs/RUS-WATER_compressed.pdf',
    language: 'ru',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Video Source Model
// ─────────────────────────────────────────────────────────────────────────────
class VideoSource {
  final String title;
  final String url;
  final String language; // 'en', 'es', 'ru', 'fr', 'cs'
  final bool
      isReport; // True if this is a PDF report link, false if YouTube video

  VideoSource({
    required this.title,
    required this.url,
    required this.language,
    this.isReport = false,
  });
}

// Video Sources - English
final List<VideoSource> videoSourcesEn = [
  VideoSource(
    title: 'Dr. Ragusa on Microplastics in the Human Placenta',
    url: 'https://youtu.be/6nKLX-nBK4s?si=SWgw2hOfQ3XyXsTV',
    language: 'en',
  ),
  VideoSource(
    title: 'Dr. Long (Oncologist) Warns About Nanoplastics in the Human Body',
    url: 'https://youtu.be/C3gtFQVSQFs?si=24eDIryFp-FTucwM',
    language: 'en',
  ),
  VideoSource(
    title:
        'Conference in EU parliament: "Nanoplastics: Hidden Connections and Emerging Risks"',
    url: 'https://youtu.be/EZony1cFgjk?si=RVhtwSKnkmP9JmN_',
    language: 'en',
  ),
  VideoSource(
    title: 'Nanoplastics. Threat to Life | ALLATRA Documentary',
    url: 'https://youtu.be/BVap0MdbCZg',
    language: 'en',
  ),
  VideoSource(
    title: 'Why Is the Ocean Warming Up So Fast?',
    url: 'https://youtu.be/2tscXOUUVgk?si=tg_X9qMRyfM2pQm4',
    language: 'en',
  ),
  VideoSource(
    title: 'Anthropogenic Factor in the Ocean\'s Demise | Popular Science Film',
    url: 'https://youtu.be/CDWrsgX4syc',
    language: 'en',
  ),
  VideoSource(
    title: 'What Destroys You on a Quantum Level?',
    url: 'https://www.youtube.com/watch?v=lJk2Sz7kl0o',
    language: 'en',
  ),
  VideoSource(
    title: 'Nanoplastics. The Last Generation Has Already Been Born',
    url: 'https://youtu.be/qjOuYylvsBE',
    language: 'en',
  ),
  VideoSource(
    title:
        'ALLATRA at UN Summit COP16 | Climate Crisis and Ocean Pollution Documentary',
    url: 'https://youtu.be/0DNempKykno',
    language: 'en',
  ),
  VideoSource(
    title:
        'Nanoplastics and Society: An Interview with Professor Antonio Ragusa',
    url: 'https://youtu.be/eH_Q9DXO5Zk?si=qhCrouWaoLkZoi1R',
    language: 'en',
  ),
];

// Video Sources - Spanish
final List<VideoSource> videoSourcesEs = [
  VideoSource(
    title: 'Nanoplásticos. Una amenaza para la vida | Documental de ALLATRA',
    url: 'https://youtu.be/FHYw4qVI5wI?si=_YCkmF7n3NljuS3e',
    language: 'es',
  ),
  VideoSource(
    title: 'Nanoplásticos. Una amenaza para la vida | Documental de ALLATRA',
    url: 'https://youtu.be/G8Kxul9QVDE',
    language: 'es',
  ),
  VideoSource(
    title: 'Factor Antropogénico en la Muerte del Océano | Documental',
    url: 'https://youtu.be/V2vb6bbOzqg',
    language: 'es',
  ),
  VideoSource(
    title:
        'Por qué se está calentando el océano tan rápido? | Dr. Egon Cholakian',
    url: 'https://youtu.be/uxMwnRAgle4?si=p6ZEImTPNMMUturR',
    language: 'es',
  ),
  VideoSource(
    title:
        '¿Cómo limpiar el océano y detener la crisis climática? Soluciones de ALLATRA en COP29',
    url: 'https://youtu.be/LDHi5fk90nI',
    language: 'es',
  ),
];

// Video Sources - Russian
final List<VideoSource> videoSourcesRu = [
  VideoSource(
    title: 'Как микропластик обходит защиту нашего организма?',
    url: 'https://youtu.be/mRa8NF9uNXQ?si=gF2BVkfi2PI7tJr-',
    language: 'ru',
  ),
  VideoSource(
    title:
        'Нанопластик: скрытые связи и возникающие риски | Европейский парламент, Брюссель',
    url: 'https://youtu.be/ha6T0t0q7JA?si=h4Y85L9BjX4s9hby',
    language: 'ru',
  ),
  VideoSource(
    title: 'Нанопластик. Угроза жизни | Научно-популярный фильм АЛЛАТРА',
    url: 'https://youtu.be/y9ephv8L1-Q',
    language: 'ru',
  ),
  VideoSource(
    title: 'Почему океан нагревается так быстро? | Д-р Эгон Чолакян',
    url: 'https://youtu.be/6wYLXZfnkEo?si=rWmzjBD38vkDF0I-',
    language: 'ru',
  ),
  VideoSource(
    title: 'Антропогенный Фактор Гибели Океана | Научно-Популярный Фильм',
    url: 'https://youtu.be/6vYCFk3QWic',
    language: 'ru',
  ),
  VideoSource(
    title: 'Физика нанопластика: Почему частицы ведут себя как «аккумуляторы»?',
    url: 'https://youtu.be/wykOAppVrgA?si=SKfojXZFLAPkVPEp',
    language: 'ru',
  ),
  VideoSource(
    title:
        'Климатический кризис и загрязнение океанов | АЛЛАТРА на саммите ООН COP16',
    url: 'https://youtu.be/aiz2ADBo1qI',
    language: 'ru',
  ),
];

// Video Sources - French
final List<VideoSource> videoSourcesFr = [
  VideoSource(
    title:
        'Nanoplastiques : la menace invisible et un risque mondial | Présentation à ChangeNOW 2026',
    url: 'https://youtu.be/4OqOeNPM0SA?si=CM43jWsmjruyyBsw',
    language: 'fr',
  ),
  VideoSource(
    title: 'Nanoplastiques. Menace pour la vie | Documentaire ALLATRA',
    url: 'https://youtu.be/ilwHuxNgfa0',
    language: 'fr',
  ),
  VideoSource(
    title:
        'Nanoplastiques : liens cachés et risques émergents | Conférence au Parlement européen',
    url: 'https://youtu.be/VxEhJuBTLWM?si=hwp9bbV4V499IAXb',
    language: 'fr',
  ),
  VideoSource(
    title:
        "Pourquoi l'océan se réchauffe-t-il si rapidement ? | Dr Egon Cholakian",
    url: 'https://youtu.be/H5J6l_CxnuI?si=qNK0BMeCtBQG1uPz',
    language: 'fr',
  ),
  VideoSource(
    title: 'Le facteur anthropique dans le déclin de l\'océan | Film',
    url: 'https://youtu.be/afVoVR6upOQ',
    language: 'fr',
  ),
  VideoSource(
    title:
        'ALLATRA au Sommet de l\'ONU COP16 | Documentaire sur la crise climatique',
    url: 'https://youtu.be/5w7Ol0MMIUU',
    language: 'fr',
  ),
];

// Video Sources - Czech
final List<VideoSource> videoSourcesCs = [
  VideoSource(
    title:
        'Nanoplasty: Skryté souvislosti a vznikající rizika | konference v Evropském parlamentu',
    url: 'https://youtu.be/wzvzKiuBNaM?si=87_4toxs_96NpnSI',
    language: 'cs',
  ),
  VideoSource(
    title: 'Nanoplasty. Hrozba pro život | Dokument ALLATRA',
    url: 'https://www.youtube.com/watch?v=MRhJPOAQCJc',
    language: 'cs',
  ),
  VideoSource(
    title: 'Antropogenní faktor zániku oceánu | Vědecko-populární film',
    url: 'https://www.youtube.com/watch?v=1BUCp3m1uFE',
    language: 'cs',
  ),
  VideoSource(
    title: 'Prečo sa oceán otepľuje tak rýchlo? | Dr. Egon Cholakian',
    url: 'https://youtu.be/N88S-F6cvpw?si=n34fsRjLxYT91iBr',
    language: 'cs',
  ),
  VideoSource(
    title:
        'Ako vyčistiť oceán a zastaviť klimatickú krízu? Riešenia od ALLATRA na COP29',
    url: 'https://www.youtube.com/watch?v=y6YYgX5kRWU',
    language: 'cs',
  ),
  VideoSource(
    title: 'Mikro a nanoplasty v mozgu',
    url: 'https://www.youtube.com/watch?v=Tc--Q31C058',
    language: 'cs',
  ),
  VideoSource(
    title: 'Dopad mikroplastů na zdraví dětí | Co dělat?',
    url: 'https://www.youtube.com/watch?v=EBGDSROdf30',
    language: 'cs',
  ),
];

// All video sources combined for easy access
final Map<String, List<VideoSource>> allVideoSources = {
  'en': videoSourcesEn,
  'cs': videoSourcesCs,
  'es': videoSourcesEs,
  'ru': videoSourcesRu,
  'fr': videoSourcesFr,
};
