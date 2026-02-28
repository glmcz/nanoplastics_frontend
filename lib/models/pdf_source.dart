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

  PDFSource({
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    this.pdfAssetPath,
    this.language = 'en',
    this.url,
    this.actualPageCount,
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

// Human Health Category
// TODO: remove source from one PDF and add relevant one and not these examples
final List<PDFSource> humanHealthSources = [
  // Czech
  PDFSource(
    title: 'Poruchy autistického spektra a BPA',
    startPage: 92,
    endPage: 114,
    description: 'Centrální systémy (mozek a nervový systém)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Bioakumulace v lidském mozku',
    startPage: 92,
    endPage: 114,
    description: 'Centrální systémy (mozek a nervový systém)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Kardiovaskulární rizika (Ateromy)',
    startPage: 116,
    endPage: 119,
    description: 'Vitalita a tkáně (srdce, krev, orgány)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Nepříznivé výsledky porodů v USA (ftaláty)',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Redukce příjmu MNP vařením vody',
    startPage: 71,
    endPage: 91,
    description: 'Filtrace a detox (ledviny, játra, lymfatický systém)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Kvantové efekty a přenos protonů v buňkách',
    startPage: 92,
    endPage: 119,
    description: 'Fyzický útok (kvantové, molekulární, buněčné poškození)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Plasty v mužském semeni',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Plasty v ženské folikulární tekutině',
    startPage: 120,
    endPage: 131,
    description: 'Reprodukce a vývoj (placenta, plod, plodnost)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Kontaminace mléčných výrobků',
    startPage: 70,
    endPage: 91,
    description: 'Vstupní brány (vdechování, požití, pronikání kůží)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Expozice ftalátům a rakovina u dětí',
    startPage: 92,
    endPage: 119,
    description: 'Fyzický útok (kvantové, molekulární, buněčné poškození)',
    language: 'cs',
  ),
  // English
  PDFSource(
    title: 'Autism Spectrum Disorders and BPA',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
    language: 'en',
  ),
  PDFSource(
    title: 'Bioaccumulation in Human Brain',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
    language: 'en',
  ),
  PDFSource(
    title: 'Cardiovascular Risks (Atheromas)',
    startPage: 116,
    endPage: 119,
    description: 'Vitality & Tissues (Heart, Blood, Organs)',
    language: 'en',
  ),
  PDFSource(
    title: 'Adverse Birth Outcomes in USA (Phthalates)',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
  ),
  PDFSource(
    title: 'Reducing MNP Intake by Boiling Water',
    startPage: 71,
    endPage: 91,
    description: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
    language: 'en',
  ),
  PDFSource(
    title: 'Quantum Effects and Proton Transfer in Cells',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
    language: 'en',
  ),
  PDFSource(
    title: 'Plastics in Male Semen',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
  ),
  PDFSource(
    title: 'Plastics in Female Follicular Fluid',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
    language: 'en',
  ),
  PDFSource(
    title: 'Dairy Products Contamination',
    startPage: 70,
    endPage: 91,
    description: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
    language: 'en',
  ),
  PDFSource(
    title: 'Phthalate Exposure and Childhood Cancer',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
    language: 'en',
  ),
];

// Earth Pollution Category
final List<PDFSource> earthPollutionSources = [
  // Main Report - Czech (downloaded on demand)
  PDFSource(
    title: 'Nanoplasty v biosféře - Zpráva (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Kompletní komplexní zpráva o nanoplastech',
    language: 'cs',
  ),
  // Czech
  PDFSource(
    title: 'Acidifikace oceánů rozkladem plastů',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Kontaminace nejhlubších částí oceánu',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Zánik korálových útesů',
    startPage: 45,
    endPage: 66,
    description: 'Světový oceán (mořská kontaminace)',
    language: 'cs',
  ),
  PDFSource(
    title: 'Geofyzikální zlom v roce 1995',
    startPage: 68,
    endPage: 69,
    description: 'Magnetické pole a jádro Země',
    language: 'cs',
  ),
  // English
  PDFSource(
    title: 'Global Photosynthesis Losses',
    startPage: 31,
    endPage: 44,
    description: 'Flora, Fauna & Soil Biota (Terrestrial Ecosystems)',
    language: 'en',
  ),
  PDFSource(
    title: 'Fragment Growth in Pacific Garbage Patch',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
  ),
  PDFSource(
    title: 'Plastic Emissions from Ocean to Atmosphere',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
  ),
  PDFSource(
    title: 'Crossing the Blood-Brain Barrier',
    startPage: 92,
    endPage: 119,
    description: 'Physical Properties (Polymer Degradation)',
    language: 'en',
  ),
  PDFSource(
    title: 'Ice Formation in Atmosphere via MNP',
    startPage: 23,
    endPage: 30,
    description: 'Atmosphere & Global Water Cycle',
    language: 'en',
  ),
  PDFSource(
    title: 'MNP in Clouds and Precipitation Impact',
    startPage: 23,
    endPage: 30,
    description: 'Atmosphere & Global Water Cycle',
    language: 'en',
  ),
  PDFSource(
    title: 'Ocean Acidification from Plastic Decomposition',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
  ),
  PDFSource(
    title: 'Contamination of Deepest Ocean Parts',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
  ),
  PDFSource(
    title: 'Coral Reef Extinction',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination)',
    language: 'en',
  ),
  PDFSource(
    title: 'Geophysical Break in 1995',
    startPage: 68,
    endPage: 69,
    description: 'Magnetic Field & Earth\'s Core',
    language: 'en',
  ),
  // Main Report - English
  PDFSource(
    title: 'Nanoplastics in the Biosphere Report (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Complete comprehensive report on nanoplastics',
    language: 'en',
    pdfAssetPath: 'assets/docs/Nanoplastics_Report_EN_compressed.pdf',
  ),
  // Spanish (downloaded on demand)
  PDFSource(
    title: 'Nanoplásticos en la Biosfera - Informe (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Informe completo e integral sobre nanoplásticos',
    language: 'es',
  ),
  // Russian (downloaded on demand)
  PDFSource(
    title: 'Нанопластик в биосфере - Отчёт (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Полный комплексный отчет о нанопластике',
    language: 'ru',
  ),
  // French (downloaded on demand)
  PDFSource(
    title: 'Les Nanoplastiques dans la Biosphère - Rapport (2025)',
    startPage: 1,
    endPage: 1 << 30, // Sentinel: "all pages to end"
    description: 'Rapport complet et exhaustif sur les nanoplastiques',
    language: 'fr',
  ),
];

// Special Water Abilities Category
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

// Video Source Model
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
    title: 'Nanoplastics. Threat to Life | ALLATRA Documentary',
    url: 'https://youtu.be/BVap0MdbCZg',
    language: 'en',
  ),
  VideoSource(
    title: 'Trap for Humanity | Popular Science Film',
    url: 'https://youtu.be/NBbbqRzzQGY',
    language: 'en',
  ),
  VideoSource(
    title: 'Anthropogenic Factor in the Ocean\'s Demise | Popular Science Film',
    url: 'https://youtu.be/CDWrsgX4syc',
    language: 'en',
  ),
  VideoSource(
    title: 'What Destroys You on a Quantum Level?',
    url: 'https://youtu.be/0CBfe7w8oUU',
    language: 'en',
  ),
  VideoSource(
    title: 'Nanoplastics. The Last Generation Has Already Been Born',
    url: 'https://youtu.be/qsarcxl1jls',
    language: 'en',
  ),
  VideoSource(
    title:
        'ALLATRA at UN Summit COP16 | Climate Crisis and Ocean Pollution Documentary',
    url: 'https://youtu.be/0DNempKykno',
    language: 'en',
  ),
];

// Video Sources - Spanish
final List<VideoSource> videoSourcesEs = [
  VideoSource(
    title: 'Nanoplásticos. Una amenaza para la vida | Documental de ALLATRA',
    url: 'https://youtu.be/G8Kxul9QVDE',
    language: 'es',
  ),
  VideoSource(
    title: 'Trampa para la Humanidad | Documental de divulgación científica',
    url: 'https://youtu.be/2Ul0-69xuH4',
    language: 'es',
  ),
  VideoSource(
    title: 'Factor Antropogénico en la Muerte del Océano | Documental',
    url: 'https://youtu.be/V2vb6bbOzqg',
    language: 'es',
  ),
  VideoSource(
    title: 'Nanoplásticos. La última generación ya ha nacido',
    url: 'https://youtu.be/McTGMca-pHI',
    language: 'es',
  ),
  VideoSource(
    title: 'Comprendiendo la resistencia a los antibióticos 2025',
    url: 'https://youtu.be/vlXQmLxlN9E',
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
    title: 'Нанопластик. Угроза жизни | Научно-популярный фильм АЛЛАТРА',
    url: 'https://youtu.be/y9ephv8L1-Q',
    language: 'ru',
  ),
  VideoSource(
    title: 'Ловушка для человечества | Научно-Популярный Фильм',
    url: 'https://youtu.be/7LGWum8MEBk',
    language: 'ru',
  ),
  VideoSource(
    title: 'Антропогенный Фактор Гибели Океана | Научно-Популярный Фильм',
    url: 'https://youtu.be/6vYCFk3QWic',
    language: 'ru',
  ),
  VideoSource(
    title: 'Что разрушает вас на квантовом уровне?',
    url: 'https://youtu.be/QJPXPE3j2Rc',
    language: 'ru',
  ),
  VideoSource(
    title: 'Нанопластик. Последнее поколение уже родилось',
    url: 'https://youtu.be/AHlSwq65B4Q',
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
    title: 'Nanoplastiques. Menace pour la vie | Documentaire ALLATRA',
    url: 'https://youtu.be/ilwHuxNgfa0',
    language: 'fr',
  ),
  VideoSource(
    title: 'Un Piège Pour L\'humanité | Film De Vulgarisation Scientifique',
    url: 'https://youtu.be/xmMNIqyb8pA',
    language: 'fr',
  ),
  VideoSource(
    title: 'Le facteur anthropique dans le déclin de l\'océan | Film',
    url: 'https://youtu.be/afVoVR6upOQ',
    language: 'fr',
  ),
  VideoSource(
    title:
        'Des lésions cérébrales à l\'infertilité : comment les nanoparticules de plastique volent votre avenir',
    url: 'https://youtu.be/e9N3YRMS8NE',
    language: 'fr',
  ),
  VideoSource(
    title: 'Comprendre la Résistance aux Antibiotiques 2025',
    url: 'https://youtu.be/m8fksm68moE',
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
    title: 'Past pro lidstvo | Vědecko-populární film',
    url: 'https://www.youtube.com/watch?v=v6FBZz4j1_Y',
    language: 'cs',
  ),
  VideoSource(
    title: 'Čo vás ničí na kvantovej úrovni?',
    url: 'https://www.youtube.com/watch?v=k2lf9lIiOJE',
    language: 'cs',
  ),
  VideoSource(
    title: 'Nanoplasty. Posledná generácia sa už narodila',
    url: 'https://www.youtube.com/watch?v=-YoP7PBguPU',
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
