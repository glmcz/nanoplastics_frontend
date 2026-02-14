class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _currentLanguage = 'cs';

  String get currentLanguage => _currentLanguage;

  void setLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'cs': {
      // Onboarding
      'onboarding_welcome_title': 'Vítejte v NanoHive',
      'onboarding_welcome_desc': 'Společně řešíme globální krizi nanoplastů. Vaše nápady mohou změnit svět.',
      'onboarding_problem_title': 'Problém Nanoplastů',
      'onboarding_problem_desc': 'Nanoplasty pronikají do krve, placenty a mozku. Ohrožují budoucnost lidstva.',
      'onboarding_solution_title': 'Crowdsourcing Řešení',
      'onboarding_solution_desc': 'AI vyhodnotí vaše nápady. Nejlepší řešení předáme vědcům a vývojářům.',
      'onboarding_paths_title': 'Dvě Cesty k Řešení',
      'onboarding_paths_desc': 'Vyberte si: Ochrana lidského těla nebo čištění planety Země.',
      'onboarding_start': 'Začít',
      'onboarding_skip': 'Přeskočit',

      // Solution Paths
      'path_human_title': 'Lidské Tělo',
      'path_human_desc': 'Ochrana organismu před nanoplasty',
      'path_earth_title': 'Planeta Země',
      'path_earth_desc': 'Čištění prostředí a prevence',
      'choose_path': 'Vyberte si Svou cestu.',

      // Categories - Human Body
      'cat_detox_title': 'Detoxikace Těla',
      'cat_detox_desc': 'Jak odstranit nanoplasty z organismu',
      'cat_detox_example1': '🥬 Potraviny vázající toxiny',
      'cat_detox_example2': '💊 Chelátotvorné látky',
      'cat_detox_example3': '🛡️ Podpora imunitního systému',

      'cat_barrier_title': 'Ochrana Bariér',
      'cat_barrier_desc': 'Prevence průniku do těla',
      'cat_barrier_example1': '🔬 Placenta ochrana pro těhotné',
      'cat_barrier_example2': '😷 Respirátory nové generace',
      'cat_barrier_example3': '🧪 Hematoencefalická bariéra',

      // Categories - Earth
      'cat_water_filter_title': 'Filtrace Vody',
      'cat_water_filter_desc': 'Zachytávání nanoplastů ve vodě',
      'cat_water_example1': '💧 Čističky pitné vody',
      'cat_water_example2': '🌊 Oceánské čisticí systémy',
      'cat_water_example3': '♻️ Filtry v pračkách',

      'cat_energy_title': 'Energie z Plastů',
      'cat_energy_desc': 'Využití vlastností nanoplastů',
      'cat_energy_example1': '⚡ Triboelektrický efekt',
      'cat_energy_example2': '🔋 Statický náboj -> energie',
      'cat_energy_example3': '🧲 Magnetická separace',

      // Existing translations
      'header_reports': 'OFICIÁLNÍ REPORTY',
      'header_db': 'VĚDECKÉ DATABÁZE',
      'header_edu': 'EDUKACE PRO VEŘEJNOST',
      'res_nano_title': 'Nanoplasty v Biosféře',
      'res_pubmed_desc': 'Vyhledávání v biomedicínské literatuře.',
      'res_sd_desc': 'Recenzované studie o polymerech.',
      'res_vid_title': 'Jak funguje Zeta Potenciál?',
      'res_vid_desc': 'Video vysvětlení fyzikálních jevů.',
      'brainstorm_title': 'Vyberte oblast řešení',
      'cat_placenta': 'Placenta & Plod',
      'cat_blood': 'Krevní oběh',
      'cat_water': 'Voda & Oceán',
      'community_stats': 'Včera přispělo 1,240 lidí z 15 zemí.',
      'results_title': 'Top AI Hodnocení',
      'results_subtitle': 'Řazeno dle proveditelnosti a dopadu na zdraví.',
      'nav_library': 'Zdroje',
      'nav_ideas': 'Nápady',
      'nav_results': 'Výsledky',
      'cat_votes': 'hlasů',
      'confirm_path': 'Potvrdit výběr',
      'back_to_path_selection': 'Zpět na výběr cesty',
      'skip_to_app': 'Přeskočit',

      // Idea Submission Form
      'submit_idea_title': 'Sdílejte Svůj Nápad',
      'submit_idea_subtitle': 'Pomozte nám řešit krizi nanoplastů',
      'idea_category_label': 'Kategorie',
      'idea_category_hint': 'Vyberte kategorii',
      'idea_title_label': 'Název nápadu',
      'idea_title_hint': 'Stručný název vašeho řešení',
      'idea_description_label': 'Popis',
      'idea_description_hint': 'Popište váš nápad podrobně...',
      'idea_contact_section': 'Kontaktní informace (volitelné)',
      'idea_name_label': 'Jméno',
      'idea_name_hint': 'Vaše jméno nebo přezdívka',
      'idea_email_label': 'Email',
      'idea_email_hint': 'pro budoucí komunikaci',
      'idea_submit_button': 'Odeslat Nápad',
      'idea_success_title': 'Děkujeme!',
      'idea_success_message': 'Váš nápad byl úspěšně odeslán a bude vyhodnocen naším AI systémem.',
      'idea_error_title': 'Chyba',
      'idea_error_message': 'Nepodařilo se odeslat nápad. Zkuste to prosím znovu.',
      'idea_validation_category': 'Prosím vyberte kategorii',
      'idea_validation_title': 'Prosím zadejte název',
      'idea_validation_description': 'Prosím popište váš nápad',

      // Ideas Feed
      'ideas_feed_title': 'Nápady Komunity',
      'ideas_feed_no_path': 'Vyberte nejprve cestu, abyste viděli nápady',
      'read_more': 'Číst více',
    },
    'en': {
      // Onboarding
      'onboarding_welcome_title': 'Welcome to NanoHive',
      'onboarding_welcome_desc': 'Together we solve the global nanoplastics crisis. Your ideas can change the world.',
      'onboarding_problem_title': 'The Nanoplastic Problem',
      'onboarding_problem_desc': 'Nanoplastics penetrate blood, placenta, and brain. They threaten humanity\'s future.',
      'onboarding_solution_title': 'Crowdsourcing Solutions',
      'onboarding_solution_desc': 'AI evaluates your ideas. Best solutions go to scientists and developers.',
      'onboarding_paths_title': 'Two Paths to Solutions',
      'onboarding_paths_desc': 'Choose your focus: Protecting human body or cleaning planet Earth.',
      'onboarding_start': 'Get Started',
      'onboarding_skip': 'Skip',

      // Solution Paths
      'path_human_title': 'Human Body',
      'path_human_desc': 'Protecting organisms from nanoplastics',
      'path_earth_title': 'Planet Earth',
      'path_earth_desc': 'Environmental cleaning and prevention',
      'choose_path': 'Choose your solution path',

      // Categories - Human Body
      'cat_detox_title': 'Body Detoxification',
      'cat_detox_desc': 'How to remove nanoplastics from body',
      'cat_detox_example1': '🥬 Toxin-binding foods',
      'cat_detox_example2': '💊 Chelation therapy',
      'cat_detox_example3': '🛡️ Immune system support',

      'cat_barrier_title': 'Barrier Protection',
      'cat_barrier_desc': 'Preventing penetration into body',
      'cat_barrier_example1': '🔬 Placental protection for pregnancy',
      'cat_barrier_example2': '😷 Next-gen respirators',
      'cat_barrier_example3': '🧪 Blood-brain barrier',

      // Categories - Earth
      'cat_water_filter_title': 'Water Filtration',
      'cat_water_filter_desc': 'Capturing nanoplastics in water',
      'cat_water_example1': '💧 Drinking water purifiers',
      'cat_water_example2': '🌊 Ocean cleaning systems',
      'cat_water_example3': '♻️ Washing machine filters',

      'cat_energy_title': 'Energy from Plastics',
      'cat_energy_desc': 'Using nanoplastic properties',
      'cat_energy_example1': '⚡ Triboelectric effect',
      'cat_energy_example2': '🔋 Static charge -> energy',
      'cat_energy_example3': '🧲 Magnetic separation',

      // Existing translations
      'header_reports': 'OFFICIAL REPORTS',
      'header_db': 'SCIENTIFIC DATABASES',
      'header_edu': 'PUBLIC EDUCATION',
      'res_nano_title': 'Nanoplastics in the Biosphere',
      'res_pubmed_desc': 'Search in biomedical literature.',
      'res_sd_desc': 'Peer-reviewed polymer studies.',
      'res_vid_title': 'How Zeta Potential Works?',
      'res_vid_desc': 'Video explainer of physical phenomena.',
      'brainstorm_title': 'Select Solution Area',
      'cat_placenta': 'Placenta & Fetus',
      'cat_blood': 'Bloodstream',
      'cat_water': 'Water & Ocean',
      'community_stats': '1,240 contributors from 15 countries yesterday.',
      'results_title': 'Top AI Rankings',
      'results_subtitle': 'Sorted by feasibility and health impact.',
      'nav_library': 'Library',
      'nav_ideas': 'Ideas',
      'nav_results': 'Results',
      'cat_votes': 'votes',
      'confirm_path': 'Confirm Path',
      'back_to_path_selection': 'Back to Path Selection',
      'skip_to_app': 'Skip to App',

      // Idea Submission Form
      'submit_idea_title': 'Share Your Idea',
      'submit_idea_subtitle': 'Help us solve the nanoplastics crisis',
      'idea_category_label': 'Category',
      'idea_category_hint': 'Select a category',
      'idea_title_label': 'Idea Title',
      'idea_title_hint': 'Brief name for your solution',
      'idea_description_label': 'Description',
      'idea_description_hint': 'Describe your idea in detail...',
      'idea_contact_section': 'Contact Information (optional)',
      'idea_name_label': 'Name',
      'idea_name_hint': 'Your name or nickname',
      'idea_email_label': 'Email',
      'idea_email_hint': 'for future communication',
      'idea_submit_button': 'Submit Idea',
      'idea_success_title': 'Thank You!',
      'idea_success_message': 'Your idea has been successfully submitted and will be evaluated by our AI system.',
      'idea_error_title': 'Error',
      'idea_error_message': 'Failed to submit idea. Please try again.',
      'idea_validation_category': 'Please select a category',
      'idea_validation_title': 'Please enter a title',
      'idea_validation_description': 'Please describe your idea',

      // Ideas Feed
      'ideas_feed_title': 'Community Ideas',
      'ideas_feed_no_path': 'Choose a path first to see ideas',
      'read_more': 'Read more',
    },
    'fr': {
      'brainstorm_title': 'Sélectionnez un domaine',
      'nav_library': 'Ressources',
      'nav_ideas': 'Idées',
      'nav_results': 'Résultats',
      'results_title': 'Classement IA',
      'cat_votes': 'votes',
    },
    'es': {
      'brainstorm_title': 'Seleccionar área',
      'nav_library': 'Recursos',
      'nav_ideas': 'Ideas',
      'nav_results': 'Resultados',
      'results_title': 'Ranking IA',
      'cat_votes': 'votos',
    },
    'ru': {
      'brainstorm_title': 'Выберите область',
      'nav_library': 'Ресурсы',
      'nav_ideas': 'Идеи',
      'nav_results': 'Результаты',
      'results_title': 'Рейтинг ИИ',
      'cat_votes': 'голосов',
    },
  };

  static const List<LanguageOption> availableLanguages = [
    LanguageOption(code: 'en', flag: '🇺🇸', label: 'EN'),
    LanguageOption(code: 'cs', flag: '🇨🇿', label: 'CS'),
    LanguageOption(code: 'fr', flag: '🇫🇷', label: 'FR'),
    LanguageOption(code: 'es', flag: '🇪🇸', label: 'ES'),
    LanguageOption(code: 'ru', flag: '🇷🇺', label: 'RU'),
  ];
}

class LanguageOption {
  final String code;
  final String flag;
  final String label;

  const LanguageOption({
    required this.code,
    required this.flag,
    required this.label,
  });
}
