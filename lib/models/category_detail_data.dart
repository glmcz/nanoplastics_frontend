import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class CategoryDetailData {
  final String categoryKey;
  final String title;
  final String subtitle;
  final String? chargeHint;
  final IconData icon;
  final Color themeColor;
  final Color glowColor;
  final List<DetailEntry> entries;
  final List<EvidenceSection> evidenceSections;
  final List<SourceLink>? sourceLinks;

  const CategoryDetailData({
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    this.chargeHint,
    required this.icon,
    required this.themeColor,
    required this.glowColor,
    required this.entries,
    required this.evidenceSections,
    this.sourceLinks,
  });

  int get evidenceStudyCount => evidenceSections.fold(
      0, (total, section) => total + section.studies.length);

  List<EvidenceStudy> get allEvidenceStudies => evidenceSections
      .expand((section) => section.studies)
      .toList(growable: false);

  List<EvidenceStudy> featuredStudies([int count = 3]) =>
      allEvidenceStudies.take(count).toList(growable: false);
}

class DetailEntry {
  final String highlight;
  final String description;
  final List<String>? bulletPoints;
  final int? pdfStartPage;
  final int? pdfEndPage;
  final String? pdfCategory;

  const DetailEntry({
    required this.highlight,
    required this.description,
    this.bulletPoints,
    this.pdfStartPage,
    this.pdfEndPage,
    this.pdfCategory,
  });
}

class EvidenceSection {
  final String id;
  final String title;
  final String? description;
  final List<EvidenceStudy> studies;

  const EvidenceSection({
    required this.id,
    required this.title,
    this.description,
    required this.studies,
  });
}

class EvidenceStudy {
  final String title;
  final String authorsShort;
  final String journal;
  final int year;
  final String url;
  final String? doiOrPubMed;
  final String? studyType;
  final String? summary;
  final List<String> tags;

  const EvidenceStudy({
    required this.title,
    required this.authorsShort,
    required this.journal,
    required this.year,
    required this.url,
    this.doiOrPubMed,
    this.studyType,
    this.summary,
    this.tags = const [],
  });
}

class SourceLink {
  final String title;
  final String source;
  final String url;
  final String? pdfAssetPath;
  final int? pdfStartPage;
  final int? pdfEndPage;

  const SourceLink({
    required this.title,
    required this.source,
    required this.url,
    this.pdfAssetPath,
    this.pdfStartPage,
    this.pdfEndPage,
  });
}

EvidenceStudy _study({
  required String title,
  required String authorsShort,
  required String journal,
  required int year,
  required String url,
  String? doiOrPubMed,
  String? studyType,
  String? summary,
  List<String> tags = const [],
}) {
  return EvidenceStudy(
    title: title,
    authorsShort: authorsShort,
    journal: journal,
    year: year,
    url: url,
    doiOrPubMed: doiOrPubMed,
    studyType: studyType,
    summary: summary,
    tags: tags,
  );
}

List<SourceLink> _toSourceLinks(List<EvidenceSection> sections) {
  return sections
      .expand((section) => section.studies)
      .map(
        (study) => SourceLink(
          title: study.title,
          source: '${study.journal} (${study.year})',
          url: study.url,
        ),
      )
      .toList(growable: false);
}

class CategoryDetailDataFactory {
  static List<CategoryDetailData> all(AppLocalizations l10n) => [
        centralSystems(l10n),
        filtrationDetox(l10n),
        vitalityTissues(l10n),
        reproduction(l10n),
        entryGates(l10n),
        physicalAttack(l10n),
        worldOcean(l10n),
        atmosphere(l10n),
        florFauna(l10n),
        magneticField(l10n),
        planetEntryGates(l10n),
        physicalProperties(l10n),
      ];

  static CategoryDetailData centralSystems(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'aggressiveness',
        title: l10n.detailCentralSystemsEntry1Highlight,
        description: l10n.detailCentralSystemsEntry1Desc,
        studies: [
          _study(
            title:
                'Micro- and Nanoplastics Breach the Blood-Brain Barrier (BBB): Biomolecular Corona\'s Role Revealed',
            authorsShort: 'Kopatz et al.',
            journal: 'Nanomaterials',
            year: 2023,
            url: 'https://doi.org/10.3390/nano13081404',
            doiOrPubMed: 'doi:10.3390/nano13081404',
            studyType: 'Mechanistic study',
            summary:
                'Shows how biomolecular corona formation supports transport across the blood-brain barrier.',
            tags: ['mechanism', 'brain', 'barrier'],
          ),
          _study(
            title:
                'Environmental exposure enhances the internalization of microplastic particles into cells',
            authorsShort: 'Ramsperger et al.',
            journal: 'Science Advances',
            year: 2020,
            url: 'https://www.science.org/doi/10.1126/sciadv.abd1211',
            doiOrPubMed: 'doi:10.1126/sciadv.abd1211',
            studyType: 'Cell study',
            summary:
                'Demonstrates rapid cellular uptake after environmental conditioning of plastic particles.',
            tags: ['cellular uptake', 'mechanism'],
          ),
          _study(
            title:
                'Interfacial Interactions between Nanoplastics and Biological Systems: toward an Atomic and Molecular Understanding of Plastics-Driven Biological Dyshomeostasis',
            authorsShort: 'Karim et al.',
            journal: 'ACS Applied Materials and Interfaces',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acsami.4c03008',
            doiOrPubMed: 'doi:10.1021/acsami.4c03008',
            studyType: 'Mechanistic review',
            summary:
                'Connects surface interactions, corona formation, and downstream biological disruption.',
            tags: ['review', 'surface chemistry', 'mechanism'],
          ),
          _study(
            title:
                'Analysis of Microplastics in Human Feces Reveals a Correlation between Fecal Microplastics and Inflammatory Bowel Disease Status',
            authorsShort: 'Yan et al.',
            journal: 'Environmental Science and Technology',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.est.1c03924',
            doiOrPubMed: 'doi:10.1021/acs.est.1c03924',
            studyType: 'Human biomonitoring study',
            summary:
                'Links fecal microplastic burden with IBD status, suggesting gut inflammation involvement.',
            tags: ['gut', 'inflammation', 'human study'],
          ),
          _study(
            title:
                'Nano/micro-plastic, an invisible threat getting into the brain',
            authorsShort: 'Kaushik et al.',
            journal: 'Chemosphere',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0045653524012736?via%3Dihub',
            studyType: 'Review',
            summary:
                'Reviews pathways and mechanisms by which nano/micro-plastics penetrate and accumulate in the brain.',
            tags: ['review', 'brain', 'mechanism'],
          ),
          _study(
            title:
                'Effects of Microplastic Accumulation on Neuronal Death After Global Cerebral Ischemia',
            authorsShort: 'Kim et al.',
            journal: 'Cells',
            year: 2025,
            url: 'https://www.mdpi.com/2073-4409/14/4/241',
            studyType: 'In vivo study',
            summary:
                'Shows microplastic accumulation worsens neuronal death following cerebral ischemia.',
            tags: ['neuro', 'ischemia', 'in vivo'],
          ),
          _study(
            title:
                'Selective bioaccumulation of polystyrene nanoplastics in fetal rat brain and damage to myelin development',
            authorsShort: 'Zhang et al.',
            journal: 'Ecotoxicology and Environmental Safety',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S014765132400469X?via%3Dihub',
            studyType: 'Animal study',
            summary:
                'Demonstrates nanoplastic accumulation in fetal brain and impaired myelin sheath development.',
            tags: ['animal study', 'fetal', 'brain'],
          ),
          _study(
            title:
                'Bisphenols exert detrimental effects on neuronal signaling in mature vertebrate brains',
            authorsShort: 'Schirmer et al.',
            journal: 'Communications Biology',
            year: 2021,
            url: 'https://www.nature.com/articles/s42003-021-01966-w',
            doiOrPubMed: 'doi:10.1038/s42003-021-01966-w',
            studyType: 'Animal study',
            summary:
                'Shows that bisphenol additives from plastics disrupt mature vertebrate neuronal signaling.',
            tags: ['bisphenol', 'neuro', 'animal study'],
          ),
          _study(
            title:
                'A perspective on the potential impact of microplastics and nanoplastics on the human central nervous system',
            authorsShort: 'Moiniafshari et al.',
            journal: 'Environmental Science: Nano',
            year: 2025,
            url:
                'https://pubs.rsc.org/en/content/articlelanding/2025/en/d4en01017e',
            studyType: 'Review',
            summary:
                'Evaluates the potential CNS impact of MNPs via neuroinflammation, oxidative stress, and barrier disruption.',
            tags: ['review', 'CNS', 'brain'],
          ),
          _study(
            title:
                'Genotoxic and neurotoxic potential of intracellular nanoplastics: A review',
            authorsShort: 'Casella and Ballaz',
            journal: 'Journal of Applied Toxicology',
            year: 2024,
            url:
                'https://analyticalsciencejournals.onlinelibrary.wiley.com/doi/10.1002/jat.4598',
            studyType: 'Review',
            summary:
                'Reviews DNA-damage and neurotoxicity mechanisms triggered by intracellular nanoplastic particles.',
            tags: ['review', 'genotoxicity', 'neuro'],
          ),
          _study(
            title:
                'A pan-cancer mycobiome analysis reveals fungal involvement in gastrointestinal and lung tumors',
            authorsShort: 'Dohlman et al.',
            journal: 'Cell',
            year: 2022,
            url: 'https://www.cell.com/cell/fulltext/S0092-8674(22)01173-4',
            doiOrPubMed: 'doi:10.1016/j.cell.2022.09.015',
            studyType: 'Pan-cancer analysis',
            summary:
                'Identifies fungal co-factors in GI and lung tumors, providing context for plastic-microbiome-cancer links.',
            tags: ['cancer', 'microbiome', 'gut'],
          ),
          _study(
            title: 'Global prevalence of autism: A systematic review update',
            authorsShort: 'Zeidan et al.',
            journal: 'Autism Research',
            year: 2022,
            url: 'https://onlinelibrary.wiley.com/doi/10.1002/aur.2696',
            doiOrPubMed: 'doi:10.1002/aur.2696',
            studyType: 'Systematic review',
            summary:
                'Reports updated global autism prevalence data supporting neurodevelopmental impact monitoring.',
            tags: ['autism', 'prevalence', 'systematic review'],
          ),
          _study(
            title:
                'Microplastics and Nanoplastics in Atheromas and Cardiovascular Events',
            authorsShort: 'Marfella et al.',
            journal: 'The New England Journal of Medicine',
            year: 2024,
            url: 'https://www.nejm.org/doi/10.1056/NEJMoa2309822',
            doiOrPubMed: 'PMID:38446676',
            studyType: 'Human cohort study',
            summary:
                'Finds MNPs embedded in atherosclerotic plaques; patients had dramatically higher rates of heart attack, stroke, and death — demonstrating systemic vascular penetration.',
            tags: ['human study', 'cardiovascular', 'bloodstream'],
          ),
          _study(
            title:
                'Autism in boys linked to common plastic exposure in the womb',
            authorsShort: 'New Atlas',
            journal: 'New Atlas',
            year: 2024,
            url:
                'https://newatlas.com/health-wellbeing/prenatal-bisphenol-a-bpa-autism-boys',
            studyType: 'Science news',
            summary:
                'Reports research showing prenatal BPA (plastic additive) exposure is linked to autism diagnosis in boys.',
            tags: ['autism', 'BPA', 'prenatal'],
          ),
          _study(
            title:
                'Autism Prevalence Higher, Signals Possible Shift in Who Is Being Identified',
            authorsShort: 'CDC',
            journal: 'Centers for Disease Control and Prevention',
            year: 2023,
            url: 'https://www.cdc.gov/media/releases/2023/p0323-autism.html',
            studyType: 'Public health data',
            summary:
                'CDC update on rising US autism prevalence, providing epidemiological context for neurodevelopmental disruption from plastic-linked chemicals.',
            tags: ['autism', 'prevalence', 'CDC'],
          ),
          _study(
            title: 'Autism Statistics You Need To Know in 2024',
            authorsShort: 'Autism Parenting Magazine',
            journal: 'Autism Parenting Magazine',
            year: 2025,
            url: 'https://www.autismparentingmagazine.com/autism-statistics/',
            studyType: 'Statistics reference',
            summary:
                'Compiles current autism statistics and global prevalence trends for public awareness.',
            tags: ['autism', 'statistics', 'reference'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'brain-penetration',
        title: l10n.detailCentralSystemsEntry2Highlight,
        description: l10n.detailCentralSystemsEntry2Desc,
        studies: [
          _study(
            title: 'Bioaccumulation of microplastics in decedent human brains',
            authorsShort: 'Nihart et al.',
            journal: 'Nature Medicine',
            year: 2025,
            url: 'https://www.nature.com/articles/s41591-024-03453-1',
            doiOrPubMed: 'PMID:39901044',
            studyType: 'Human tissue study',
            summary:
                'Reports brain accumulation in decedent tissue with higher burdens than liver or kidney.',
            tags: ['human study', 'brain', 'bioaccumulation'],
          ),
          _study(
            title:
                'Microplastics in the bloodstream can induce cerebral thrombosis by causing cell obstruction and lead to neurobehavioral abnormalities',
            authorsShort: 'Huang et al.',
            journal: 'Science Advances',
            year: 2025,
            url: 'https://www.science.org/doi/10.1126/sciadv.adr8243',
            doiOrPubMed: 'doi:10.1126/sciadv.adr8243',
            studyType: 'In vivo study',
            summary:
                'Links circulating microplastics with thrombosis and neurologic changes in vivo.',
            tags: ['circulation', 'neuro', 'vascular'],
          ),
          _study(
            title: 'Microplastics in the Olfactory Bulb of the Human Brain',
            authorsShort: 'Amato-Lourenco et al.',
            journal: 'JAMA Network Open',
            year: 2024,
            url:
                'https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2823787',
            doiOrPubMed: 'doi:10.1001/jamanetworkopen.2024.3787',
            studyType: 'Human tissue study',
            summary:
                'Finds microplastics in the human olfactory bulb, supporting inhalation-related entry routes.',
            tags: ['human study', 'olfactory', 'brain'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_central',
      title: l10n.detailCentralSystemsTitle,
      subtitle: l10n.detailCentralSystemsSubtitle,
      chargeHint: l10n.detailCentralSystemsChargeHint,
      icon: Icons.psychology_outlined,
      themeColor: AppColors.neonCyan,
      glowColor: AppColors.neonCyanGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailCentralSystemsEntry1Highlight,
          description: l10n.detailCentralSystemsEntry1Desc,
          bulletPoints: [
            l10n.detailCentralSystemsEntry1Bullet1,
            l10n.detailCentralSystemsEntry1Bullet2,
            l10n.detailCentralSystemsEntry1Bullet3,
          ],
          pdfStartPage: 92,
          pdfEndPage: 114,
          pdfCategory: 'Central Systems (Brain & Nervous System)',
        ),
        DetailEntry(
          highlight: l10n.detailCentralSystemsEntry2Highlight,
          description: l10n.detailCentralSystemsEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 114,
          pdfCategory: 'Central Systems (Brain & Nervous System)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData filtrationDetox(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'gut-disruption',
        title: l10n.detailFiltrationDetoxEntry1Highlight,
        description: l10n.detailFiltrationDetoxEntry1Desc,
        studies: [
          _study(
            title:
                'The triple exposure nexus of microplastic particles, plastic-associated chemicals, and environmental pollutants from a human health perspective',
            authorsShort: 'Alijagic et al.',
            journal: 'Environment International',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412024003222?via%3Dihub',
            studyType: 'Review',
            summary:
                'Frames gut and detox burden as a combined exposure problem involving particles, additives, and co-pollutants.',
            tags: ['review', 'gut', 'exposure'],
          ),
          _study(
            title:
                'Microplastics and human health: unveiling the gut microbiome disruption and chronic disease risks',
            authorsShort: 'Bora et al.',
            journal: 'Frontiers in Cellular and Infection Microbiology',
            year: 2024,
            url:
                'https://www.frontiersin.org/journals/cellular-and-infection-microbiology/articles/10.3389/fcimb.2024.1492759/full?trk=public_post_comment-text',
            studyType: 'Review',
            summary:
                'Summarizes gut barrier disruption, dysbiosis, and downstream chronic disease pathways.',
            tags: ['review', 'gut', 'microbiome'],
          ),
          _study(
            title:
                'Drinking Boiled Tap Water Reduces Human Intake of Nanoplastics and Microplastics',
            authorsShort: 'Yu et al.',
            journal: 'Environmental Science and Technology Letters',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acs.estlett.4c00081',
            doiOrPubMed: 'doi:10.1021/acs.estlett.4c00081',
            studyType: 'Exposure mitigation study',
            summary:
                'Provides a practical exposure-reduction finding relevant to ingestion pathways.',
            tags: ['exposure', 'drinking water', 'mitigation'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'organ-accumulation',
        title: l10n.detailFiltrationDetoxEntry2Highlight,
        description: l10n.detailFiltrationDetoxEntry2Desc,
        studies: [
          _study(
            title: 'Bioaccumulation of microplastics in decedent human brains',
            authorsShort: 'Nihart et al.',
            journal: 'Nature Medicine',
            year: 2025,
            url: 'https://www.nature.com/articles/s41591-024-03453-1',
            doiOrPubMed: 'PMID:39901044',
            studyType: 'Human tissue study',
            summary:
                'Includes organ burden comparisons that highlight accumulation beyond the gut.',
            tags: ['human study', 'organs', 'bioaccumulation'],
          ),
          _study(
            title:
                'Microplastics: A threat for developing and repairing organs?',
            authorsShort: 'Hofstede et al.',
            journal: 'Cambridge Prisms: Plastics',
            year: 2023,
            url:
                'https://www.cambridge.org/core/journals/cambridge-prisms-plastics/article/microplastics-a-threat-for-developing-and-repairing-organs/F4683C00B4F24CAF7506A467F1037CF5',
            studyType: 'Review',
            summary:
                'Reviews inflammation, oxidative stress, and impaired organ repair under microplastic exposure.',
            tags: ['review', 'organs', 'inflammation'],
          ),
          _study(
            title:
                'Recent insights into uptake, toxicity, and molecular targets of microplastics and nanoplastics relevant to human health impacts',
            authorsShort: 'Khan and Jia',
            journal: 'iScience',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2589004223001384',
            doiOrPubMed: 'PMID:36818296',
            studyType: 'Review',
            summary:
                'Summarizes cellular uptake, liver and kidney burden, and molecular toxicity targets.',
            tags: ['review', 'toxicity', 'organs'],
          ),
          _study(
            title:
                'Adipogenic Activity of Chemicals Used in Plastic Consumer Products',
            authorsShort: 'Völker et al.',
            journal: 'Environmental Science and Technology',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.est.1c06316',
            doiOrPubMed: 'doi:10.1021/acs.est.1c06316',
            studyType: 'Laboratory study',
            summary:
                'Demonstrates plastic-derived chemicals promote fat-cell formation, directly linking plastic exposure to obesity.',
            tags: ['obesity', 'adipogenic', 'metabolic'],
          ),
          _study(
            title:
                'Association of Urinary Concentrations of Bisphenol A and Phthalate Metabolites with Risk of Type 2 Diabetes',
            authorsShort: 'Sun et al.',
            journal: 'Environmental Health Perspectives',
            year: 2014,
            url: 'https://pubmed.ncbi.nlm.nih.gov/24633239/',
            doiOrPubMed: 'PMID:24633239',
            studyType: 'Epidemiological study',
            summary:
                'Associates plastic chemical metabolites in urine with elevated type 2 diabetes risk.',
            tags: ['diabetes', 'bisphenol', 'phthalate'],
          ),
          _study(
            title: 'Obesity and overweight',
            authorsShort: 'WHO',
            journal: 'WHO Fact Sheets',
            year: 2025,
            url:
                'https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight',
            studyType: 'Global health data',
            summary:
                'Provides global obesity statistics and trends relevant to plastic-linked metabolic disruption.',
            tags: ['obesity', 'global data', 'WHO'],
          ),
          _study(
            title: 'Overweight and obesity statistics',
            authorsShort: 'NIDDK',
            journal:
                'National Institute of Diabetes and Digestive and Kidney Diseases',
            year: 2021,
            url:
                'https://www.niddk.nih.gov/health-information/health-statistics/overweight-obesity',
            studyType: 'National health data',
            summary:
                'US-level obesity and overweight prevalence data contextualizing metabolic overloading.',
            tags: ['obesity', 'statistics', 'national data'],
          ),
          _study(
            title:
                'Younger but sicker? Cohort trends in disease accumulation among middle-aged and older adults',
            authorsShort: 'Ribe et al.',
            journal: 'European Journal of Public Health',
            year: 2024,
            url: 'https://academic.oup.com/eurpub/article/34/4/696/7644332',
            studyType: 'Cohort study',
            summary:
                'Documents accelerating disease accumulation in younger cohorts, consistent with chronic toxic exposure.',
            tags: ['disease burden', 'aging', 'cohort'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_detox',
      title: l10n.detailFiltrationDetoxTitle,
      subtitle: l10n.detailFiltrationDetoxSubtitle,
      icon: Icons.water_drop_outlined,
      themeColor: AppColors.neonLime,
      glowColor: AppColors.neonLimeGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailFiltrationDetoxEntry1Highlight,
          description: l10n.detailFiltrationDetoxEntry1Desc,
          bulletPoints: [
            l10n.detailFiltrationDetoxEntry1Bullet1,
            l10n.detailFiltrationDetoxEntry1Bullet2,
            l10n.detailFiltrationDetoxEntry1Bullet3,
          ],
          pdfStartPage: 71,
          pdfEndPage: 91,
          pdfCategory: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
        ),
        DetailEntry(
          highlight: l10n.detailFiltrationDetoxEntry2Highlight,
          description: l10n.detailFiltrationDetoxEntry2Desc,
          pdfStartPage: 71,
          pdfEndPage: 91,
          pdfCategory: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData vitalityTissues(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'mitochondrial-dysfunction',
        title: l10n.detailVitalityTissuesEntry1Highlight,
        description: l10n.detailVitalityTissuesEntry1Desc,
        studies: [
          _study(
            title:
                'Microplastics and Nanoplastics in Atheromas and Cardiovascular Events',
            authorsShort: 'Marfella et al.',
            journal: 'The New England Journal of Medicine',
            year: 2024,
            url: 'https://www.nejm.org/doi/10.1056/NEJMoa2309822',
            doiOrPubMed: 'PMID:38446676',
            studyType: 'Human cohort study',
            summary:
                'Links plaque-contained microplastics with elevated risk of major cardiovascular events.',
            tags: ['human study', 'cardiovascular', 'bloodstream'],
          ),
          _study(
            title:
                'Microplastics in three types of human arteries detected by pyrolysis-gas chromatography/mass spectrometry (Py-GC/MS)',
            authorsShort: 'Liu et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389424004345?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'Detects plastic residues in multiple artery types, reinforcing vascular exposure concerns.',
            tags: ['human study', 'arteries', 'vascular'],
          ),
          _study(
            title: 'Journey of micronanoplastics with blood components',
            authorsShort: 'Rajendran and Chandrasekaran',
            journal: 'RSC Advances',
            year: 2023,
            url:
                'https://pubs.rsc.org/en/content/articlelanding/2023/ra/d3ra05620a',
            studyType: 'Review',
            summary:
                'Explains interactions between particles and blood components during circulation.',
            tags: ['review', 'blood', 'mechanism'],
          ),
          _study(
            title:
                'Mitochondria as a target of micro- and nanoplastic toxicity',
            authorsShort: 'Yontem and Ahbab',
            journal: 'Cambridge Prisms: Plastics',
            year: 2024,
            url:
                'https://www.cambridge.org/core/journals/cambridge-prisms-plastics/article/mitochondria-as-a-target-of-micro-and-nanoplastic-toxicity/5A3E8C7CDB7F9919874A3F10F7586A78',
            studyType: 'Review',
            summary:
                'Reviews mitochondrial oxidative stress, membrane injury, and bioenergetic dysfunction.',
            tags: ['review', 'mitochondria', 'cell stress'],
          ),
          _study(
            title:
                'Coupling between electrons\' spin and proton transfer in chiral biological crystals',
            authorsShort: 'Goren et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2500584122',
            doiOrPubMed: 'doi:10.1073/pnas.2500584122',
            studyType: 'Mechanistic study',
            summary:
                'Provides a mechanistic reference for proton-transfer and charge-coupled bioelectric processes.',
            tags: ['mechanism', 'bioelectric', 'proton transfer'],
          ),
          _study(
            title:
                'Airborne micro- and nanoplastics: emerging causes of respiratory diseases',
            authorsShort: 'Gou et al.',
            journal: 'Particle and Fibre Toxicology',
            year: 2024,
            url: 'https://link.springer.com/article/10.1186/s12989-024-00613-6',
            studyType: 'Review',
            summary:
                'Reviews how airborne plastic particles damage lung tissue and trigger respiratory disease.',
            tags: ['review', 'inhalation', 'respiratory'],
          ),
          _study(
            title:
                'Study unravels how mitochondrial dysfunction leads to premature aging',
            authorsShort: 'Medindia',
            journal: 'Medindia',
            year: 2022,
            url:
                'https://www.medindia.net/news/study-unravels-how-mitochondrial-dysfunction-leads-to-premature-aging-208364-1.htm',
            studyType: 'Science news',
            summary:
                'Discusses research linking mitochondrial dysfunction to accelerated cellular aging.',
            tags: ['mitochondria', 'aging', 'reference'],
          ),
          _study(
            title: 'Mitochondria medicine',
            authorsShort: 'Borisova',
            journal: 'Open Longevity',
            year: 2019,
            url: 'https://openlongevity.org/mitochondria_medicine_1',
            studyType: 'Science overview',
            summary:
                'Overview of mitochondria-targeted medicine and its role in cellular health and longevity.',
            tags: ['mitochondria', 'longevity', 'reference'],
          ),
          _study(
            title:
                'The Biology of Electricity: How electricity is critical to the functioning of the human body',
            authorsShort: 'Azim Premji University',
            journal: 'Azim Premji University',
            year: 2022,
            url:
                'https://azimpremjiuniversity.edu.in/news/2022/the-biology-of-electricity',
            studyType: 'Educational reference',
            summary:
                'Explains fundamental bioelectricity and its role in cellular processes and health.',
            tags: ['bioelectric', 'reference', 'education'],
          ),
          _study(
            title:
                'Exposure to polystyrene nanoparticles leads to changes in the zeta potential of bacterial cells',
            authorsShort: 'Zajac et al.',
            journal: 'Scientific Reports',
            year: 2023,
            url: 'https://pubmed.ncbi.nlm.nih.gov/37308531/',
            studyType: 'Cell study',
            summary:
                'Documents how nanoplastic exposure shifts the surface electrical charge of bacterial cells.',
            tags: ['surface charge', 'zeta potential', 'cell study'],
          ),
          _study(
            title:
                'Interplay Between Nanoplastics and the Immune System of the Mediterranean Sea Urchin Paracentrotus lividus',
            authorsShort: 'Murano et al.',
            journal: 'Frontiers in Marine Science',
            year: 2021,
            url:
                'https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2021.647394/full',
            studyType: 'Mechanistic study',
            summary:
                'Shows positively charged nanoplastics damage lysosomal membranes and disrupt immunity.',
            tags: ['surface charge', 'immune', 'membrane damage'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_vitality',
      title: l10n.detailVitalityTissuesTitle,
      subtitle: l10n.detailVitalityTissuesSubtitle,
      icon: Icons.favorite_outline,
      themeColor: AppColors.neonCrimson,
      glowColor: AppColors.neonCrimsonGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailVitalityTissuesEntry1Highlight,
          description: l10n.detailVitalityTissuesEntry1Desc,
          bulletPoints: [
            l10n.detailVitalityTissuesEntry1Bullet1,
            l10n.detailVitalityTissuesEntry1Bullet2,
            l10n.detailVitalityTissuesEntry1Bullet3,
            l10n.detailVitalityTissuesEntry1Bullet4,
          ],
          pdfStartPage: 116,
          pdfEndPage: 119,
          pdfCategory: 'Vitality & Tissues (Heart, Blood, Organs)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData reproduction(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'reproductive-damage',
        title: l10n.detailReproductionEntry1Highlight,
        description: l10n.detailReproductionEntry1Desc,
        studies: [
          _study(
            title:
                'Prevalence and implications of microplastic contaminants in general human seminal fluid: A Raman spectroscopic study',
            authorsShort: 'Li et al.',
            journal: 'Science of The Total Environment',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0048969724036696?via%3Dihub',
            studyType: 'Human biomonitoring study',
            summary:
                'Reports microplastic contamination in human seminal fluid samples.',
            tags: ['human study', 'fertility', 'male reproduction'],
          ),
          _study(
            title:
                'First evidence of microplastics in human ovarian follicular fluid: An emerging threat to female fertility',
            authorsShort: 'Montano et al.',
            journal: 'Ecotoxicology and Environmental Safety',
            year: 2025,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0147651325002040?via%3Dihub',
            studyType: 'Human biomonitoring study',
            summary:
                'Finds microplastics in ovarian follicular fluid, tying exposure to female fertility concerns.',
            tags: ['human study', 'fertility', 'female reproduction'],
          ),
          _study(
            title:
                'Plasticenta: First evidence of microplastics in human placenta',
            authorsShort: 'Ragusa et al.',
            journal: 'Environment International',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412020322297?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'First widely cited evidence of microplastics present in the human placenta.',
            tags: ['human study', 'placenta', 'pregnancy'],
          ),
          _study(
            title:
                'Prenatal phthalate exposure and adverse birth outcomes in the USA',
            authorsShort: 'Trasande et al.',
            journal: 'The Lancet Planetary Health',
            year: 2024,
            url:
                'https://www.thelancet.com/journals/lanplh/article/PIIS2542-5196(23)00270-X/fulltext',
            studyType: 'Population study',
            summary:
                'Associates prenatal phthalate exposure with substantial adverse birth outcome burden.',
            tags: ['population', 'pregnancy', 'birth outcomes'],
          ),
          _study(
            title:
                'Maternal exposure to polystyrene nanoplastics causes brain abnormalities in progeny',
            authorsShort: 'Jeong et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2022,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389421027849?via%3Dihub',
            studyType: 'Animal study',
            summary:
                'Shows developmental brain abnormalities in offspring after maternal nanoplastic exposure.',
            tags: ['animal study', 'development', 'nanoplastic'],
          ),
          _study(
            title:
                'Elevated Micro- and Nanoplastics Detected in Preterm Human Placentae',
            authorsShort: 'Jochum et al.',
            journal: 'Research Square (Preprint)',
            year: 2025,
            url: 'https://www.researchsquare.com/article/rs-5903715/v1',
            studyType: 'Human tissue study',
            summary:
                'Finds significantly elevated MNP concentrations in placentae of preterm births.',
            tags: ['human study', 'placenta', 'preterm'],
          ),
          _study(
            title:
                'Temporal trends in sperm count: a systematic review and meta-regression analysis of samples collected globally',
            authorsShort: 'Levine et al.',
            journal: 'Human Reproduction Update',
            year: 2023,
            url: 'https://academic.oup.com/humupd/article/29/2/157/6824414',
            studyType: 'Meta-analysis',
            summary:
                'Documents a dramatic global decline in sperm count, consistent with widespread toxic exposures.',
            tags: ['sperm', 'fertility', 'meta-analysis'],
          ),
          _study(
            title: 'Mitochondrial DNA mutations in human disease',
            authorsShort: 'Taylor and Turnbull',
            journal: 'Nature Reviews Genetics',
            year: 2005,
            url: 'https://www.nature.com/articles/nrg1606',
            doiOrPubMed: 'doi:10.1038/nrg1606',
            studyType: 'Review',
            summary:
                'Foundational study on mitochondrial DNA mutations as drivers of inherited and acquired diseases.',
            tags: ['mitochondria', 'DNA', 'review'],
          ),
          _study(
            title:
                'Mitochondrial proteins and congenital birth defect risk: a mendelian randomization study',
            authorsShort: 'Li et al.',
            journal: 'BMC Pregnancy and Childbirth',
            year: 2025,
            url: 'https://link.springer.com/article/10.1186/s12884-025-07562-8',
            studyType: 'Mendelian randomization',
            summary:
                'Links mitochondrial protein dysfunction to elevated congenital birth defect risk.',
            tags: ['mitochondria', 'birth defects', 'genetics'],
          ),
          _study(
            title:
                'Gastroschisis prevalence patterns in 27 surveillance programs from 24 countries',
            authorsShort: 'Feldkamp et al.',
            journal: 'Birth Defects Research',
            year: 2024,
            url: 'https://onlinelibrary.wiley.com/doi/10.1002/bdr2.2306',
            doiOrPubMed: 'doi:10.1002/bdr2.2306',
            studyType: 'Global surveillance study',
            summary:
                'Documents global rise in gastroschisis, a congenital defect associated with environmental chemical exposure.',
            tags: ['birth defects', 'global data', 'congenital'],
          ),
          _study(
            title: 'Analyzing the Trends and Causes of Birth Defects',
            authorsShort: 'Wei et al.',
            journal: 'China CDC Weekly',
            year: 2023,
            url:
                'https://weekly.chinacdc.cn/en/article/doi/10.46234/ccdcw2023.184',
            studyType: 'Trend analysis',
            summary:
                'Analyzes increasing birth defect trends over two decades, highlighting environmental factors.',
            tags: ['birth defects', 'trends', 'epidemiology'],
          ),
          _study(
            title:
                'Effect of nanoplastic intake on the dopamine system during the development of male mice',
            authorsShort: 'Kim et al.',
            journal: 'Neuroscience',
            year: 2024,
            url:
                'https://www.ibroneuroscience.org/article/S0306-4522(24)00331-2/abstract',
            studyType: 'Animal study',
            summary:
                'Shows nanoplastic exposure disrupts the dopamine system during male mouse neurodevelopment.',
            tags: ['animal study', 'dopamine', 'neurodevelopment'],
          ),
          _study(
            title:
                'Microplastics in Internal Tissues of Companion Animals from Urban Environments',
            authorsShort: 'Prata et al.',
            journal: 'Animals',
            year: 2022,
            url: 'https://www.mdpi.com/2076-2615/12/15/1979',
            studyType: 'Animal biomonitoring',
            summary:
                'Finds widespread microplastic contamination in internal organs of dogs and cats in urban settings.',
            tags: ['animals', 'companion animals', 'tissue accumulation'],
          ),
          _study(
            title:
                'Detection of microplastics in domestic and fetal pigs\' lung tissue in natural environment',
            authorsShort: 'Li et al.',
            journal: 'Environmental Research',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0013935122019508?via%3Dihub',
            studyType: 'Animal study',
            summary:
                'Detects microplastics in the lung tissue of both adult and fetal pigs, demonstrating prenatal exposure.',
            tags: ['animal study', 'fetal', 'lung'],
          ),
          _study(
            title:
                'Seabirds in crisis: Plastic ingestion induces proteomic signatures of multiorgan failure and neurodegeneration',
            authorsShort: 'De Jersey et al.',
            journal: 'Science Advances',
            year: 2025,
            url: 'https://www.science.org/doi/10.1126/sciadv.ads0834',
            doiOrPubMed: 'doi:10.1126/sciadv.ads0834',
            studyType: 'Animal study',
            summary:
                'Reveals Alzheimer-like neurodegeneration and multi-organ failure in seabirds from plastic ingestion.',
            tags: ['animal study', 'neuro', 'multi-organ failure'],
          ),
          _study(
            title:
                'Impact of Microplastics on Pregnancy and Fetal Development: A Systematic Review',
            authorsShort: 'Sharma et al.',
            journal: 'Cureus',
            year: 2024,
            url:
                'https://www.cureus.com/articles/252793-impact-of-microplastics-on-pregnancy-and-fetal-development-a-systematic-review#!/',
            studyType: 'Systematic review',
            summary:
                'Systematically reviews evidence linking plastic exposure to adverse pregnancy and fetal outcomes.',
            tags: ['systematic review', 'pregnancy', 'fetal development'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_reproduction',
      title: l10n.detailReproductionTitle,
      subtitle: l10n.detailReproductionSubtitle,
      icon: Icons.child_care_outlined,
      themeColor: AppColors.neonViolet,
      glowColor: AppColors.neonVioletGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailReproductionEntry1Highlight,
          description: l10n.detailReproductionEntry1Desc,
          bulletPoints: [
            l10n.detailReproductionEntry1Bullet1,
            l10n.detailReproductionEntry1Bullet2,
            l10n.detailReproductionEntry1Bullet3,
            l10n.detailReproductionEntry1Bullet4,
          ],
          pdfStartPage: 120,
          pdfEndPage: 131,
          pdfCategory:
              'Reproduction & Development (Placenta, Fetus, Fertility)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData entryGates(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'inhalation',
        title: l10n.detailEntryGatesEntry1Highlight,
        description: l10n.detailEntryGatesEntry1Desc,
        studies: [
          _study(
            title:
                'Airborne micro- and nanoplastics: emerging causes of respiratory diseases',
            authorsShort: 'Gou et al.',
            journal: 'Particle and Fibre Toxicology',
            year: 2024,
            url: 'https://link.springer.com/article/10.1186/s12989-024-00613-6',
            studyType: 'Review',
            summary:
                'Summarizes inhalation exposure and respiratory disease mechanisms for airborne particles.',
            tags: ['review', 'inhalation', 'respiratory'],
          ),
          _study(
            title: 'Presence of airborne microplastics in human lung tissue',
            authorsShort: 'Amato-Lourenco et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389421010888?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'Detects airborne microplastics in human lung tissue, supporting direct pulmonary exposure.',
            tags: ['human study', 'lungs', 'inhalation'],
          ),
          _study(
            title:
                'The triple exposure nexus of microplastic particles, plastic-associated chemicals, and environmental pollutants from a human health perspective',
            authorsShort: 'Alijagic et al.',
            journal: 'Environment International',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412024003222?via%3Dihub',
            studyType: 'Review',
            summary:
                'Shows entry via air, food, and water creates a combined toxic burden exceeding individual route risks.',
            tags: ['review', 'exposure', 'entry routes'],
          ),
          _study(
            title:
                'Microplastics and human health: unveiling the gut microbiome disruption and chronic disease risks',
            authorsShort: 'Bora et al.',
            journal: 'Frontiers in Cellular and Infection Microbiology',
            year: 2024,
            url:
                'https://www.frontiersin.org/journals/cellular-and-infection-microbiology/articles/10.3389/fcimb.2024.1492759/full',
            studyType: 'Review',
            summary:
                'Links ingested plastics with gut microbiome disruption and chronic disease pathways.',
            tags: ['review', 'ingestion', 'gut'],
          ),
          _study(
            title:
                'Recent insights into uptake, toxicity, and molecular targets of microplastics and nanoplastics relevant to human health impacts',
            authorsShort: 'Khan and Jia',
            journal: 'iScience',
            year: 2023,
            url: 'https://www.cell.com/iscience/fulltext/S2589-0042(23)00138-4',
            doiOrPubMed: 'PMID:36818296',
            studyType: 'Review',
            summary:
                'Synthesizes uptake routes, with particular detail on inhalation, ingestion, and skin mechanisms.',
            tags: ['review', 'uptake', 'entry routes'],
          ),
          _study(
            title:
                'Toxicological impact of microplastics and nanoplastics on humans: understanding the mechanistic aspect of the interaction',
            authorsShort: 'Alqahtani et al.',
            journal: 'Frontiers in Toxicology',
            year: 2023,
            url:
                'https://www.frontiersin.org/journals/toxicology/articles/10.3389/ftox.2023.1193386/full',
            studyType: 'Review',
            summary:
                'Explains mechanistic toxicological interactions after entry via multiple routes.',
            tags: ['review', 'toxicity', 'mechanism'],
          ),
          _study(
            title:
                'Transport and deposition of microplastics and nanoplastics in the human respiratory tract',
            authorsShort: 'Huang et al.',
            journal: 'Environmental Advances',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2666765724000437?via%3Dihub',
            studyType: 'Transport study',
            summary:
                'Models where particles deposit along the respiratory tract after inhalation.',
            tags: ['modeling', 'respiratory', 'deposition'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'ingestion',
        title: l10n.detailEntryGatesEntry2Highlight,
        description: l10n.detailEntryGatesEntry2Desc,
        studies: [
          _study(
            title:
                'Micro- and nano-plastics in edible fruit and vegetables. The first diet risks assessment for the general population',
            authorsShort: 'Oliveri Conti et al.',
            journal: 'Environmental Research',
            year: 2020,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0013935120305703?via%3Dihub',
            studyType: 'Exposure assessment',
            summary:
                'Provides early dietary risk assessment for edible produce contamination.',
            tags: ['diet', 'food', 'ingestion'],
          ),
          _study(
            title:
                'Estimation of the mass of microplastics ingested - A pivotal first step towards human health risk assessment',
            authorsShort: 'Senathirajah et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389420319944?via%3Dihub',
            studyType: 'Exposure assessment',
            summary:
                'Estimates ingestion mass from food and beverages for risk-assessment framing.',
            tags: ['risk assessment', 'diet', 'ingestion'],
          ),
          _study(
            title:
                'Anthropogenic contamination of tap water, beer, and sea salt',
            authorsShort: 'Kosuth et al.',
            journal: 'PLoS ONE',
            year: 2018,
            url:
                'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0194970',
            studyType: 'Exposure study',
            summary:
                'Shows contamination across common drinking and food-related sources.',
            tags: ['drinking water', 'food', 'exposure'],
          ),
          _study(
            title:
                'Uptake and Accumulation of Nano/Microplastics in Plants: A Critical Review',
            authorsShort: 'Azeem et al.',
            journal: 'Nanomaterials',
            year: 2021,
            url: 'https://www.mdpi.com/2079-4991/11/11/2935',
            studyType: 'Review',
            summary:
                'Reviews how plants absorb and accumulate MNPs from soil and water, contributing to dietary exposure.',
            tags: ['review', 'plants', 'food chain'],
          ),
          _study(
            title:
                'Drinking Boiled Tap Water Reduces Human Intake of Nanoplastics and Microplastics',
            authorsShort: 'Yu et al.',
            journal: 'Environmental Science and Technology Letters',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acs.estlett.4c00081',
            doiOrPubMed: 'doi:10.1021/acs.estlett.4c00081',
            studyType: 'Exposure mitigation study',
            summary:
                'Demonstrates boiling tap water significantly reduces ingested MNP load.',
            tags: ['drinking water', 'mitigation', 'ingestion'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'skin',
        title: l10n.detailEntryGatesEntry3Highlight,
        description: l10n.detailEntryGatesEntry3Desc,
        studies: [
          _study(
            title:
                'Potential Health Impact of Microplastics: A Review of Environmental Distribution, Human Exposure, and Toxic Effects',
            authorsShort: 'Li et al.',
            journal: 'Environmental Health',
            year: 2023,
            url: 'https://pubs.acs.org/doi/10.1021/envhealth.3c00052',
            studyType: 'Review',
            summary:
                'Reviews human exposure routes including dermal contact and translocation questions.',
            tags: ['review', 'dermal', 'exposure'],
          ),
          _study(
            title: 'Impact of Microplastics and Nanoplastics on Human Health',
            authorsShort: 'Yee et al.',
            journal: 'Nanomaterials',
            year: 2021,
            url: 'https://www.mdpi.com/2079-4991/11/2/496',
            studyType: 'Review',
            summary:
                'Provides route-specific overview of uptake pathways and health effects, including skin contact considerations.',
            tags: ['review', 'dermal', 'uptake'],
          ),
          _study(
            title:
                'The potential impact of nano- and microplastics on human health: Understanding human health risks',
            authorsShort: 'Winiarska et al.',
            journal: 'Environmental Research',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0013935124004390?via%3Dihub',
            studyType: 'Review',
            summary:
                'Updates route-of-exposure evidence and uncertainty across inhalation, ingestion, and skin contact.',
            tags: ['review', 'risk', 'dermal'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_entry',
      title: l10n.detailEntryGatesTitle,
      subtitle: l10n.detailEntryGatesSubtitle,
      icon: Icons.air_outlined,
      themeColor: AppColors.neonOrange,
      glowColor: AppColors.neonOrangeGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry1Highlight,
          description: l10n.detailEntryGatesEntry1Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry2Highlight,
          description: l10n.detailEntryGatesEntry2Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry3Highlight,
          description: l10n.detailEntryGatesEntry3Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData physicalAttack(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'electrostatic-charge',
        title: l10n.detailPhysicalAttackEntry1Highlight,
        description: l10n.detailPhysicalAttackEntry1Desc,
        studies: [
          _study(
            title:
                'Selective Targeting of Neurons with Inorganic Nanoparticles: Revealing the Crucial Role of Nanoparticle Surface Charge',
            authorsShort: 'Dante et al.',
            journal: 'ACS Nano',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acsnano.7b00397',
            studyType: 'Mechanistic study',
            summary:
                'Demonstrates how charged nanoparticles preferentially interact with electrically active neurons.',
            tags: ['surface charge', 'neurons', 'mechanism'],
          ),
          _study(
            title:
                'Exposure to polystyrene nanoparticles leads to changes in the zeta potential of bacterial cells',
            authorsShort: 'Zajac et al.',
            journal: 'Scientific Reports',
            year: 2023,
            url: 'https://www.nature.com/articles/s41598-023-36603-5',
            studyType: 'Cell study',
            summary:
                'Shows measurable electrical surface-potential shifts after nanoparticle exposure.',
            tags: ['surface charge', 'zeta potential', 'cell study'],
          ),
          _study(
            title:
                'Interplay Between Nanoplastics and the Immune System of the Mediterranean Sea Urchin Paracentrotus lividus',
            authorsShort: 'Murano et al.',
            journal: 'Frontiers in Marine Science',
            year: 2021,
            url:
                'https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2021.647394/full',
            studyType: 'Mechanistic study',
            summary:
                'Shows how positively charged nanoplastics can trigger membrane damage and immune disruption.',
            tags: ['surface charge', 'membrane damage', 'immune'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'electrical-interference',
        title: l10n.detailPhysicalAttackEntry2Highlight,
        description: l10n.detailPhysicalAttackEntry2Desc,
        studies: [
          _study(
            title:
                'Surface-Functionalized Polystyrene Nanoparticles Alter the Transmembrane Potential via Ion-Selective Pores Maintaining Global Bilayer Integrity',
            authorsShort: 'Perini et al.',
            journal: 'Langmuir',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.langmuir.2c02487',
            studyType: 'Mechanistic study',
            summary:
                'Shows nanoparticle-driven changes in transmembrane potential without full membrane rupture.',
            tags: ['bioelectric', 'membrane potential', 'mechanism'],
          ),
          _study(
            title:
                'Coupling between electrons\' spin and proton transfer in chiral biological crystals',
            authorsShort: 'Goren et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2500584122',
            studyType: 'Mechanistic study',
            summary:
                'Provides a reference point for charge-sensitive proton-transfer processes in living systems.',
            tags: ['bioelectric', 'proton transfer', 'mechanism'],
          ),
          _study(
            title:
                'Microplastics in the bloodstream can induce cerebral thrombosis by causing cell obstruction and lead to neurobehavioral abnormalities',
            authorsShort: 'Huang et al.',
            journal: 'Science Advances',
            year: 2025,
            url: 'https://www.science.org/doi/10.1126/sciadv.adr8243',
            studyType: 'In vivo study',
            summary:
                'Connects bloodstream obstruction to downstream neurologic and behavioral disruption.',
            tags: ['circulation', 'neuro', 'bioelectric'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'structural-deformation',
        title: l10n.detailPhysicalAttackEntry3Highlight,
        description: l10n.detailPhysicalAttackEntry3Desc,
        studies: [
          _study(
            title:
                'Micro- and Nanoplastics\' Effects on Protein Folding and Amyloidosis',
            authorsShort: 'Windheim et al.',
            journal: 'International Journal of Molecular Sciences',
            year: 2022,
            url: 'https://www.mdpi.com/1422-0067/23/18/10329',
            studyType: 'Review',
            summary:
                'Reviews how plastic particles perturb protein folding and aggregation pathways.',
            tags: ['protein folding', 'structural', 'review'],
          ),
          _study(
            title:
                'Interfacial Interactions between Nanoplastics and Biological Systems: toward an Atomic and Molecular Understanding of Plastics-Driven Biological Dyshomeostasis',
            authorsShort: 'Karim et al.',
            journal: 'ACS Applied Materials and Interfaces',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acsami.4c03008',
            studyType: 'Mechanistic review',
            summary:
                'Frames structural dyshomeostasis through surface-binding, membrane, and protein interactions.',
            tags: ['structural', 'surface chemistry', 'review'],
          ),
          _study(
            title:
                'Recent insights into uptake, toxicity, and molecular targets of microplastics and nanoplastics relevant to human health impacts',
            authorsShort: 'Khan and Jia',
            journal: 'iScience',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2589004223001384',
            studyType: 'Review',
            summary:
                'Synthesizes molecular damage pathways, including oxidative stress and structural biomolecule disruption.',
            tags: ['review', 'molecular targets', 'toxicity'],
          ),
          _study(
            title:
                'An Atomic and Molecular Insight into How PFOA Reduces α-Helicity, Compromises Substrate Binding',
            authorsShort: 'Yadav et al.',
            journal: 'Journal of the American Chemical Society',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/jacs.4c02934',
            doiOrPubMed: 'doi:10.1021/jacs.4c02934',
            studyType: 'Mechanistic study',
            summary:
                'Shows at atomic resolution how PFOA (a plastic-linked chemical) degrades protein alpha-helical structure.',
            tags: ['PFAS', 'protein folding', 'structural'],
          ),
          _study(
            title:
                'Nano/micro-plastic, an invisible threat getting into the brain',
            authorsShort: 'Kaushik et al.',
            journal: 'Chemosphere',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0045653524012736?via%3Dihub',
            studyType: 'Review',
            summary:
                'Reviews pathways by which MNPs physically penetrate the CNS, causing cellular and structural damage.',
            tags: ['review', 'brain', 'mechanism'],
          ),
          _study(
            title:
                'Mitochondria as a target of micro- and nanoplastic toxicity',
            authorsShort: 'Yontem and Ahbab',
            journal: 'Cambridge Prisms: Plastics',
            year: 2024,
            url:
                'https://www.cambridge.org/core/journals/cambridge-prisms-plastics/article/mitochondria-as-a-target-of-micro-and-nanoplastic-toxicity/5A3E8C7CDB7F9919874A3F10F7586A78',
            studyType: 'Review',
            summary:
                'Reviews mitochondrial membrane disruption, oxidative stress, and bioenergetic dysfunction caused by MNPs at the cellular level.',
            tags: ['review', 'mitochondria', 'cell stress'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_ways_of_destruction',
      title: l10n.detailPhysicalAttackTitle,
      subtitle: l10n.detailPhysicalAttackSubtitle,
      icon: Icons.science_outlined,
      themeColor: AppColors.neonWhite,
      glowColor: AppColors.neonWhiteGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry1Highlight,
          description: l10n.detailPhysicalAttackEntry1Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry2Highlight,
          description: l10n.detailPhysicalAttackEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry3Highlight,
          description: l10n.detailPhysicalAttackEntry3Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData worldOcean(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'hydrogen-bond-disruption',
        title: l10n.detailWorldOceanEntry1Highlight,
        description: l10n.detailWorldOceanEntry1Desc,
        studies: [
          _study(
            title: 'Record-Setting Ocean Warmth Continued in 2019',
            authorsShort: 'Cheng et al.',
            journal: 'Advances in Atmospheric Sciences',
            year: 2020,
            url: 'https://link.springer.com/article/10.1007/s00376-020-9283-7',
            studyType: 'Climate observation',
            summary:
                'Documents record ocean warming in 2019 as part of a multi-year heating trend.',
            tags: ['ocean heat', 'climate', 'observation'],
          ),
          _study(
            title: 'Another Year of Record Heat for the Oceans',
            authorsShort: 'Cheng et al.',
            journal: 'Advances in Atmospheric Sciences',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s00376-023-2385-2',
            studyType: 'Climate observation',
            summary:
                'Updates the record-setting ocean heat signal across the global ocean.',
            tags: ['ocean heat', 'climate', 'observation'],
          ),
          _study(
            title:
                'Frequent marine heatwaves hidden below the surface of the global ocean',
            authorsShort: 'Sun et al.',
            journal: 'Nature Geoscience',
            year: 2023,
            url: 'https://www.nature.com/articles/s41561-023-01325-w',
            studyType: 'Observation study',
            summary:
                'Shows major heat anomalies below the surface, relevant to stratified ocean impacts.',
            tags: ['marine heatwave', 'subsurface', 'ocean'],
          ),
          _study(
            title:
                'Microplastics contaminate the deepest part of the world\'s ocean',
            authorsShort: 'Peng et al.',
            journal: 'Geochemical Perspectives Letters',
            year: 2018,
            url: 'https://www.geochemicalperspectivesletters.org/article1829/',
            studyType: 'Field study',
            summary:
                'Finds plastic contamination at Mariana Trench depths with polymer-specific distribution patterns.',
            tags: ['deep ocean', 'field study', 'contamination'],
          ),
          _study(
            title:
                'Abundance, size and polymer composition of marine microplastics and their modelled vertical distribution',
            authorsShort: 'Enders et al.',
            journal: 'Marine Pollution Bulletin',
            year: 2015,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0025326X15300370?via%3Dihub',
            studyType: 'Distribution study',
            summary:
                'Models how polymer type and particle properties shape vertical ocean distribution.',
            tags: ['vertical distribution', 'ocean', 'modeling'],
          ),
          _study(
            title:
                'Seven years into the North Pacific garbage patch: legacy plastic fragments rising disproportionately faster than larger floating objects',
            authorsShort: 'Lebreton et al.',
            journal: 'Environmental Research Letters',
            year: 2024,
            url: 'https://iopscience.iop.org/article/10.1088/1748-9326/ad78ed',
            studyType: 'Field study',
            summary:
                'Shows accelerating fragmentation and growth of small plastic particles in the Pacific.',
            tags: ['fragmentation', 'Pacific', 'field study'],
          ),
          _study(
            title: 'Pacific Ocean Heat Content During the Past 10,000 Years',
            authorsShort: 'Rosenthal et al.',
            journal: 'Science',
            year: 2013,
            url: 'https://www.science.org/doi/10.1126/science.1240837',
            doiOrPubMed: 'doi:10.1126/science.1240837',
            studyType: 'Paleoclimate study',
            summary:
                'Proves average ocean depths are warming 15x faster than at any point in the past 10,000 years.',
            tags: ['ocean heat', 'deep ocean', 'paleoclimate'],
          ),
          _study(
            title:
                'Observed Ocean Bottom Temperature Variability at Four Sites in the Northwestern Argentine Basin',
            authorsShort: 'Meinen et al.',
            journal: 'Geophysical Research Letters',
            year: 2020,
            url:
                'https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2020GL089093',
            studyType: 'Observation study',
            summary:
                'Provides direct evidence of warming at ocean-floor depth, confirming deep-water heating.',
            tags: ['deep ocean', 'temperature', 'observation'],
          ),
          _study(
            title: 'Argo — Two Decades: Global Oceanography, Revolutionized',
            authorsShort: 'Johnson et al.',
            journal: 'Annual Review of Marine Science',
            year: 2022,
            url:
                'https://www.annualreviews.org/content/journals/10.1146/annurev-marine-022521-102008',
            studyType: 'Review',
            summary:
                'Presents two decades of Argo buoy measurements revealing systematic warming at ocean depth.',
            tags: ['ocean monitoring', 'temperature', 'review'],
          ),
          _study(
            title: 'Water Dynamics in the Hydration Shells of Biomolecules',
            authorsShort: 'Laage et al.',
            journal: 'Chemical Reviews',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acs.chemrev.6b00765',
            doiOrPubMed: 'doi:10.1021/acs.chemrev.6b00765',
            studyType: 'Review',
            summary:
                'Describes how charged particles create hydration shells affecting millions of surrounding water molecules.',
            tags: ['water', 'hydration', 'hydrogen bonds'],
          ),
          _study(
            title:
                'Thermal Conductivity and Specific Heat Capacity of Dodecylbenzenesulfonic Acid-Doped Polyaniline Particles — Water Based Nanofluid',
            authorsShort: 'Chew et al.',
            journal: 'Polymers',
            year: 2015,
            url: 'https://www.mdpi.com/2073-4360/7/7/1221',
            studyType: 'Material science study',
            summary:
                'Shows nanoparticles in water increase its thermal conductivity, relevant to ocean heat dynamics.',
            tags: ['nanofluid', 'thermal conductivity', 'water'],
          ),
          _study(
            title: 'Specific heat control of nanofluids: A critical review',
            authorsShort: 'Riazi et al.',
            journal: 'International Journal of Thermal Sciences',
            year: 2016,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S129007291630103X',
            studyType: 'Review',
            summary:
                'Reviews how nanoparticle suspensions alter specific heat and thermal properties of fluids.',
            tags: ['nanofluid', 'specific heat', 'thermal'],
          ),
          _study(
            title:
                'The Vertical Distribution of Microplastics in the Water Column',
            authorsShort: 'Tikhonova et al.',
            journal: 'Water Resources',
            year: 2024,
            url: 'https://link.springer.com/article/10.1134/S009780782370063X',
            studyType: 'Field study',
            summary:
                'Investigates plastic stratification and thermocline trapping by density gradient in the water column.',
            tags: ['vertical distribution', 'ocean', 'stratification'],
          ),
          _study(
            title:
                'The rise in ocean plastics evidenced from a 60-year time series',
            authorsShort: 'Ostle et al.',
            journal: 'Nature Communications',
            year: 2019,
            url: 'https://www.nature.com/articles/s41467-019-09506-1',
            doiOrPubMed: 'doi:10.1038/s41467-019-09506-1',
            studyType: 'Long-term observation',
            summary:
                'Provides a 60-year historical record of increasing macro/microplastic volume in the seas.',
            tags: ['ocean', 'time series', 'contamination'],
          ),
          _study(
            title:
                'A growing plastic smog, now estimated to be over 170 trillion plastic particles afloat in the world\'s oceans',
            authorsShort: 'Eriksen et al.',
            journal: 'PLoS ONE',
            year: 2023,
            url:
                'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0281596',
            doiOrPubMed: 'doi:10.1371/journal.pone.0281596',
            studyType: 'Global modeling study',
            summary:
                'Models over 170 trillion floating plastic particles in global oceans requiring urgent action.',
            tags: ['ocean', 'global model', 'contamination'],
          ),
          _study(
            title:
                'A hierarchical clustering method of hydrogen bond networks in liquid water undergoing shear flow',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2021,
            url: 'https://www.nature.com/articles/s41598-021-88810-7',
            studyType: 'Water structure study',
            summary:
                'Investigates the complex hydrogen-bond network on which unique ocean-water heat properties depend; relevant to how MNPs disrupt these dynamics.',
            tags: ['water', 'hydrogen bonds', 'ocean'],
          ),
          _study(
            title:
                'Water clusters and density fluctuations in liquid water based on extended hierarchical clustering methods',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2022,
            url: 'https://www.nature.com/articles/s41598-022-11947-6',
            studyType: 'Water structure study',
            summary:
                'Studies cluster formation and density fluctuations in water, underlying ocean heat distribution and layering.',
            tags: ['water', 'clusters', 'ocean'],
          ),
          _study(
            title:
                'Electrolytes induce long-range orientational order and free energy changes in the H-bond network of bulk water',
            authorsShort: 'Chen et al.',
            journal: 'Science Advances',
            year: 2016,
            url: 'https://www.science.org/doi/10.1126/sciadv.1501891',
            doiOrPubMed: 'doi:10.1126/sciadv.1501891',
            studyType: 'Water physics study',
            summary:
                'Describes how charged particles create hydration shells affecting millions of surrounding water molecules, relevant to charged MNP-ocean water interaction.',
            tags: ['water', 'charge', 'hydrogen bonds'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_ocean',
      title: l10n.detailWorldOceanTitle,
      subtitle: l10n.detailWorldOceanSubtitle,
      chargeHint: l10n.detailWorldOceanChargeHint,
      icon: Icons.waves_outlined,
      themeColor: AppColors.neonOcean,
      glowColor: AppColors.neonOceanGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailWorldOceanEntry1Highlight,
          description: l10n.detailWorldOceanEntry1Desc,
          bulletPoints: [
            l10n.detailWorldOceanEntry1Bullet1,
            l10n.detailWorldOceanEntry1Bullet2,
          ],
          pdfStartPage: 45,
          pdfEndPage: 66,
          pdfCategory: 'World Ocean (Marine Contamination, Ocean Impacts)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData atmosphere(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'low-heavy-clouds',
        title: l10n.detailAtmosphereEntry1Highlight,
        description: l10n.detailAtmosphereEntry1Desc,
        studies: [
          _study(
            title:
                'Airborne hydrophilic microplastics in cloud water at high altitudes and their role in cloud formation',
            authorsShort: 'Wang et al.',
            journal: 'Environmental Chemistry Letters',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s10311-023-01626-x',
            studyType: 'Field study',
            summary:
                'Detects hydrophilic plastics in cloud water and links them to cloud-formation processes.',
            tags: ['atmosphere', 'clouds', 'field study'],
          ),
          _study(
            title:
                'Pristine and Aged Microplastics Can Nucleate Ice through Immersion Freezing',
            authorsShort: 'Busse et al.',
            journal: 'ACS EST Air',
            year: 2024,
            url: 'https://doi.org/10.1021/acsestair.4c00146',
            studyType: 'Laboratory study',
            summary:
                'Shows microplastics acting as ice-nucleating particles during cloud freezing.',
            tags: ['ice nucleation', 'clouds', 'laboratory'],
          ),
          _study(
            title: 'Plastic rain in protected areas of the United States',
            authorsShort: 'Brahney et al.',
            journal: 'Science',
            year: 2020,
            url: 'https://www.science.org/doi/10.1126/science.aaz5819',
            studyType: 'Field study',
            summary:
                'Documents atmospheric deposition of plastic particles over protected landscapes.',
            tags: ['atmosphere', 'deposition', 'field study'],
          ),
          _study(
            title: 'Atmospheric electricity and cloud microphysics',
            authorsShort: 'Harrison',
            journal: 'CERN Proceedings',
            year: 2002,
            url: 'https://cds.cern.ch/record/557170/files/p75.pdf',
            studyType: 'Conceptual reference',
            summary:
                'Provides background on cloud charge separation and atmospheric electricity relevant to particle interactions.',
            tags: ['atmosphere', 'electricity', 'reference'],
          ),
          _study(
            title:
                'Projected increase in lightning strikes in the United States due to global warming',
            authorsShort: 'Romps et al.',
            journal: 'Science',
            year: 2014,
            url: 'https://www.science.org/doi/10.1126/science.1259100',
            studyType: 'Projection study',
            summary:
                'Models how atmospheric changes intensify lightning activity under warming conditions.',
            tags: ['lightning', 'climate', 'projection'],
          ),
          _study(
            title:
                'Satellites reveal widespread decline in global lake water storage',
            authorsShort: 'Yao et al.',
            journal: 'Science',
            year: 2023,
            url: 'https://www.science.org/doi/10.1126/science.abo2812',
            doiOrPubMed: 'doi:10.1126/science.abo2812',
            studyType: 'Satellite observation',
            summary:
                'Documents global lake water storage decline, linked to hydrological cycle disruption.',
            tags: ['water cycle', 'lakes', 'satellite'],
          ),
          _study(
            title:
                'Trends of moisture exchange components in the ocean-atmosphere system under global warming conditions',
            authorsShort: 'Malinin and Vainovsky',
            journal: 'ResearchGate',
            year: 2021,
            url:
                'https://www.researchgate.net/publication/353407662_Trends_in_moisture_exchange_components_in_the_ocean-atmosphere_system_under_global_warming_according_to_the_Reanalysis-2_archive',
            studyType: 'Climate analysis',
            summary:
                'Analyzes trends in ocean-atmosphere moisture exchange relevant to water cycle disruption.',
            tags: ['moisture exchange', 'water cycle', 'climate'],
          ),
          _study(
            title: 'Hailstorms of 2024',
            authorsShort: 'ESSL',
            journal: 'European Severe Storms Laboratory',
            year: 2024,
            url: 'https://www.essl.org/cms/hailstorms-of-2024/',
            studyType: 'Observational database',
            summary:
                'Records spatial distribution and exponential increase of anomalously large hailstones in 2024.',
            tags: ['hailstorms', 'extreme weather', 'observation'],
          ),
          _study(
            title:
                '2024: An active year of U.S. billion-dollar weather and climate disasters',
            authorsShort: 'Smith',
            journal: 'NOAA Climate.gov',
            year: 2024,
            url:
                'https://www.climate.gov/news-features/blogs/beyond-data/2024-active-year-us-billion-dollar-weather-and-climate-disasters',
            studyType: 'Climate report',
            summary:
                'Documents record-level U.S. weather disasters in 2024 consistent with atmospheric destabilization.',
            tags: ['extreme weather', 'climate disasters', 'data'],
          ),
          _study(
            title:
                'Microplastics impact cloud formation, likely affecting weather and climate',
            authorsShort: 'Penn State University',
            journal: 'Penn State News',
            year: 2024,
            url:
                'https://www.psu.edu/news/research/story/microplastics-impact-cloud-formation-likely-affecting-weather-and-climate',
            studyType: 'Science news',
            summary:
                'Penn State researchers show microplastics alter cloud-formation processes with potential weather and climate implications.',
            tags: ['clouds', 'atmosphere', 'research news'],
          ),
          _study(
            title:
                'A hierarchical clustering method of hydrogen bond networks in liquid water undergoing shear flow',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2021,
            url: 'https://www.nature.com/articles/s41598-021-88810-7',
            studyType: 'Water structure study',
            summary:
                'Explains the hydrogen-bond structure upon which natural water dynamics and atmospheric moisture exchange depend.',
            tags: ['water', 'hydrogen bonds', 'atmosphere'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_atmosphere',
      title: l10n.detailAtmosphereTitle,
      subtitle: l10n.detailAtmosphereSubtitle,
      chargeHint: l10n.detailAtmosphereChargeHint,
      icon: Icons.cloud_outlined,
      themeColor: AppColors.neonAtmos,
      glowColor: AppColors.neonAtmosGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailAtmosphereEntry1Highlight,
          description: l10n.detailAtmosphereEntry1Desc,
          pdfStartPage: 23,
          pdfEndPage: 30,
          pdfCategory:
              'Atmosphere & Global Water Cycle (Airborne Plastics, Precipitation)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData florFauna(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'bioelectric-signals',
        title: l10n.detailFloraFaunaEntry1Highlight,
        description: l10n.detailFloraFaunaEntry1Desc,
        studies: [
          _study(
            title:
                'Microplastics reach the brain and interfere with honey bee cognition',
            authorsShort: 'Pasquini et al.',
            journal: 'Science of The Total Environment',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0048969723079925',
            studyType: 'Animal study',
            summary:
                'Links plastic exposure with cognition effects in pollinators.',
            tags: ['pollinators', 'animal study', 'ecosystems'],
          ),
          _study(
            title:
                'Plastic pollution in agricultural landscapes: an overlooked threat to pollination, biocontrol and food security',
            authorsShort: 'Sheng et al.',
            journal: 'Nature Communications',
            year: 2024,
            url: 'https://www.nature.com/articles/s41467-024-52734-3',
            studyType: 'Review',
            summary:
                'Frames plastics as a systems-level threat to pollination and agricultural resilience.',
            tags: ['pollination', 'ecosystem', 'review'],
          ),
          _study(
            title:
                'Microplastics incorporated by honeybees from food are transferred to honey, wax and larvae',
            authorsShort: 'Alma et al.',
            journal: 'Environmental Pollution',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0269749123000805?via%3Dihub',
            studyType: 'Transfer study',
            summary:
                'Shows particle transfer through bee products and brood pathways.',
            tags: ['pollinators', 'transfer', 'food web'],
          ),
          _study(
            title:
                'Uptake and Accumulation of Nano/Microplastics in Plants: A Critical Review',
            authorsShort: 'Azeem et al.',
            journal: 'Nanomaterials',
            year: 2021,
            url: 'https://www.mdpi.com/2079-4991/11/11/2935',
            studyType: 'Review',
            summary:
                'Reviews how plants take up MNPs through roots, leaves, and soil, disrupting growth and food chains.',
            tags: ['review', 'plants', 'uptake'],
          ),
          _study(
            title:
                'Microplastics accumulate on pores in seed capsule and delay germination and root growth of the terrestrial vascular plant Lepidium sativum',
            authorsShort: 'Bosker et al.',
            journal: 'Chemosphere',
            year: 2019,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0045653519306095?via%3Dihub',
            studyType: 'Plant study',
            summary:
                'Demonstrates that plastics block seed pores, delaying germination and root development.',
            tags: ['plants', 'germination', 'seed'],
          ),
          _study(
            title:
                'Impacts of Microplastics on the Soil Biophysical Environment',
            authorsShort: 'De Souza Machado et al.',
            journal: 'Environmental Science and Technology',
            year: 2018,
            url: 'https://pubs.acs.org/doi/10.1021/acs.est.8b02212',
            doiOrPubMed: 'doi:10.1021/acs.est.8b02212',
            studyType: 'Field/laboratory study',
            summary:
                'Shows microplastics alter soil physical properties, affecting water retention and plant growth.',
            tags: ['soil', 'ecosystem', 'biophysical'],
          ),
          _study(
            title:
                'Microplastics as an emerging threat to terrestrial ecosystems',
            authorsShort: 'De Souza Machado et al.',
            journal: 'Global Change Biology',
            year: 2018,
            url: 'https://onlinelibrary.wiley.com/doi/10.1111/gcb.14020',
            doiOrPubMed: 'doi:10.1111/gcb.14020',
            studyType: 'Review',
            summary:
                'Frames microplastics as a systemic emerging threat to terrestrial ecosystem function.',
            tags: ['review', 'terrestrial', 'ecosystem'],
          ),
          _study(
            title:
                'Effects of plastic contamination on water evaporation and desiccation cracking in soil',
            authorsShort: 'Wan et al.',
            journal: 'Science of The Total Environment',
            year: 2019,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0048969718344784?via%3Dihub',
            studyType: 'Laboratory study',
            summary:
                'Shows plastic contamination impairs soil water evaporation and causes desiccation cracking.',
            tags: ['soil', 'water cycle', 'laboratory'],
          ),
          _study(
            title:
                'An overview of microplastic and nanoplastic pollution in agroecosystems',
            authorsShort: 'Ng et al.',
            journal: 'Science of The Total Environment',
            year: 2018,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0048969718303838?via%3Dihub',
            studyType: 'Review',
            summary:
                'Reviews MNP pollution in agricultural ecosystems and impacts on soil biota and crop health.',
            tags: ['review', 'agriculture', 'soil biota'],
          ),
          _study(
            title:
                'Active uptake of artificial particles in the nematode Caenorhabditis elegans',
            authorsShort: 'Kiyama et al.',
            journal: 'Journal of Experimental Biology',
            year: 2012,
            url:
                'https://journals.biologists.com/jeb/article/215/7/1178/11278/Active-uptake-of-artificial-particles-in-the',
            studyType: 'Animal study',
            summary:
                'Shows soil nematodes actively ingest synthetic particles, establishing MNP uptake in soil organisms.',
            tags: ['soil biota', 'nematode', 'uptake'],
          ),
          _study(
            title:
                'Microplastics are present in women\'s and cows\' follicular fluid and polystyrene microplastics compromise bovine oocyte function in vitro',
            authorsShort: 'Grechi et al.',
            journal: 'eLife',
            year: 2023,
            url: 'https://elifesciences.org/reviewed-preprints/86791v1',
            studyType: 'Cross-species study',
            summary:
                'Finds MNPs in both human and bovine follicular fluid; shows direct oocyte function impairment.',
            tags: ['fertility', 'follicular fluid', 'livestock'],
          ),
          _study(
            title:
                'Plastic ingestion by marine fish is widespread and increasing',
            authorsShort: 'Savoca et al.',
            journal: 'Global Change Biology',
            year: 2021,
            url: 'https://onlinelibrary.wiley.com/doi/10.1111/gcb.15533',
            doiOrPubMed: 'doi:10.1111/gcb.15533',
            studyType: 'Global review',
            summary:
                'Documents massive and growing scale of plastic ingestion by marine fish across global fisheries.',
            tags: ['marine fish', 'food chain', 'ingestion'],
          ),
          _study(
            title:
                'Marine plastic debris emits a keystone infochemical for olfactory foraging seabirds',
            authorsShort: 'Savoca et al.',
            journal: 'Science Advances',
            year: 2016,
            url: 'https://www.science.org/doi/10.1126/sciadv.1600395',
            doiOrPubMed: 'doi:10.1126/sciadv.1600395',
            studyType: 'Behavioral study',
            summary:
                'Shows plastic debris mimics food odor for seabirds, causing them to consume plastics instead of prey.',
            tags: ['seabirds', 'food web', 'olfaction'],
          ),
          _study(
            title:
                'Development and application of a novel extraction protocol for the monitoring of microplastic contamination in widely consumed ruminant feeds',
            authorsShort: 'Glorio Patrucco et al.',
            journal: 'Science of The Total Environment',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0048969724046412?via%3Dihub',
            studyType: 'Monitoring study',
            summary:
                'Detects microplastic contamination in ruminant feeds, tracing plastics into the livestock food chain.',
            tags: ['livestock', 'feed contamination', 'food chain'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'photosynthesis-damage',
        title: l10n.detailFloraFaunaEntry2Highlight,
        description: l10n.detailFloraFaunaEntry2Desc,
        studies: [
          _study(
            title:
                'A global estimate of multiecosystem photosynthesis losses under microplastic pollution',
            authorsShort: 'Zhu et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2423957122',
            studyType: 'Global modeling study',
            summary:
                'Estimates global photosynthesis losses across terrestrial, freshwater, and marine systems.',
            tags: ['photosynthesis', 'global model', 'ecosystems'],
          ),
          _study(
            title:
                'Uptake and physiological impacts of nanoplastics in trees with divergent water use strategies',
            authorsShort: 'Murazzi et al.',
            journal: 'Environmental Science: Nano',
            year: 2024,
            url:
                'https://pubs.rsc.org/en/content/articlelanding/2024/en/d4en00286e',
            studyType: 'Plant study',
            summary:
                'Shows uptake and physiological stress in tree systems after nanoplastic exposure.',
            tags: ['plants', 'tree physiology', 'nanoplastic'],
          ),
          _study(
            title:
                'Nanoplastic exposure inhibits growth, photosynthetic pigment synthesis and oxidative enzymes in microalgae',
            authorsShort: 'Sarkar et al.',
            journal: 'Journal of Hazardous Materials Advances',
            year: 2025,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2772416625000257',
            studyType: 'Laboratory study',
            summary:
                'Shows impaired pigment synthesis and oxidative enzyme balance in primary producers.',
            tags: ['microalgae', 'photosynthesis', 'laboratory'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_bio',
      title: l10n.detailFloraFaunaTitle,
      subtitle: l10n.detailFloraFaunaSubtitle,
      icon: Icons.nature_outlined,
      themeColor: AppColors.neonBio,
      glowColor: AppColors.neonBioGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailFloraFaunaEntry1Highlight,
          description: l10n.detailFloraFaunaEntry1Desc,
          bulletPoints: [
            l10n.detailFloraFaunaEntry1Bullet1,
            l10n.detailFloraFaunaEntry1Bullet2,
          ],
          pdfStartPage: 31,
          pdfEndPage: 44,
          pdfCategory:
              'Flora, Fauna & Soil Biota (Terrestrial Ecosystems, Photosynthesis)',
        ),
        DetailEntry(
          highlight: l10n.detailFloraFaunaEntry2Highlight,
          description: l10n.detailFloraFaunaEntry2Desc,
          pdfStartPage: 31,
          pdfEndPage: 44,
          pdfCategory:
              'Flora, Fauna & Soil Biota (Terrestrial Ecosystems, Photosynthesis)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData magneticField(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'magnetic-destabilization',
        title: l10n.detailMagneticFieldEntry1Highlight,
        description: l10n.detailMagneticFieldEntry1Desc,
        studies: [
          _study(
            title:
                'Polar Drift in the 1990s Explained by Terrestrial Water Storage Changes',
            authorsShort: 'Deng et al.',
            journal: 'Geophysical Research Letters',
            year: 2021,
            url:
                'https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2020GL092114',
            studyType: 'Geophysics study',
            summary:
                'Shows large-scale Earth-system mass redistribution can shift polar motion.',
            tags: ['geophysics', 'polar drift', 'mass redistribution'],
          ),
          _study(
            title:
                'Detection of a large-scale mass redistribution in the terrestrial system since 1998',
            authorsShort: 'Cox and Chao',
            journal: 'Science',
            year: 2002,
            url: 'https://www.science.org/doi/10.1126/science.1072188',
            studyType: 'Geophysics study',
            summary:
                'Measures abrupt terrestrial mass redistribution relevant to Earth-shape dynamics.',
            tags: ['mass redistribution', 'geophysics'],
          ),
          _study(
            title: 'An accelerating high-latitude jet in Earth\'s core',
            authorsShort: 'Livermore et al.',
            journal: 'Nature Geoscience',
            year: 2017,
            url: 'https://www.nature.com/articles/ngeo2859',
            studyType: 'Core dynamics study',
            summary:
                'Uses geomagnetic observations to show dynamic changes within the liquid outer core.',
            tags: ['earth core', 'geomagnetism', 'core dynamics'],
          ),
          _study(
            title:
                'International Geomagnetic Reference Field: the thirteenth generation',
            authorsShort: 'Alken et al.',
            journal: 'Earth, Planets and Space',
            year: 2021,
            url: 'https://link.springer.com/article/10.1186/s40623-020-01288-x',
            studyType: 'Reference model',
            summary:
                'Documents current geomagnetic reference-field changes and secular variation.',
            tags: ['geomagnetism', 'reference', 'field intensity'],
          ),
          _study(
            title:
                'Remnant of the late Permian superplume that generated the Siberian Traps inferred from geomagnetic data',
            authorsShort: 'Li et al.',
            journal: 'Nature Communications',
            year: 2023,
            url: 'https://www.nature.com/articles/s41467-023-37053-3',
            studyType: 'Geodynamic study',
            summary:
                'Uses geomagnetic data to infer deep mantle structure beneath Siberia.',
            tags: ['mantle', 'geomagnetic', 'geodynamics'],
          ),
          _study(
            title:
                'Influence of soil consolidation and thermal expansion effects on height and gravity variations',
            authorsShort: 'Romagnoli et al.',
            journal: 'Journal of Geodynamics',
            year: 2003,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0264370703000127?via%3Dihub',
            studyType: 'Geodynamic study',
            summary:
                'Records changes in planetary gravity linked to internal Earth dynamics.',
            tags: ['gravity', 'geodynamics', 'Earth structure'],
          ),
          _study(
            title:
                'Exposure of the solar system and the Earth to external influences',
            authorsShort: 'Smolkov',
            journal: 'Physics and Astronomy International Journal',
            year: 2018,
            url:
                'https://medcraveonline.com/PAIJ/exposure-of-the-solar-system-and-the-earth-to-external-influences.html',
            studyType: 'Theoretical study',
            summary:
                'Discusses external cosmic influences contributing to Earth system destabilization.',
            tags: ['cosmic influence', 'Earth dynamics', 'theoretical'],
          ),
          _study(
            title:
                'The role of geomagnetic field intensity in Late Quaternary evolution of humans and large mammals',
            authorsShort: 'Channell and Vigliotti',
            journal: 'Reviews of Geophysics',
            year: 2019,
            url:
                'https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2018RG000629',
            studyType: 'Paleogeophysics study',
            summary:
                'Analyzes how drastic historical declines in magnetic field intensity impacted the biosphere.',
            tags: ['geomagnetism', 'biosphere', 'history'],
          ),
          _study(
            title: 'Mantle plumes control magnetic reversal frequency',
            authorsShort: 'Larson and Olson',
            journal: 'Earth and Planetary Science Letters',
            year: 1991,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/0012821X9190091U?via%3Dihub',
            studyType: 'Geodynamic study',
            summary:
                'Proves a direct link between mantle plume intensity and magnetic field reversal frequency.',
            tags: ['mantle plume', 'magnetic reversal', 'geodynamics'],
          ),
          _study(
            title:
                'The 15 m.y. geomagnetic reversal periodicity: a quantitative test',
            authorsShort: 'Mazaud and Laj',
            journal: 'Earth and Planetary Science Letters',
            year: 1991,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/0012821X9190111T?via%3Dihub',
            studyType: 'Geophysics study',
            summary:
                'Quantitatively tests the periodicity of geomagnetic field inversions across geological time.',
            tags: ['magnetic reversal', 'periodicity', 'geophysics'],
          ),
          _study(
            title:
                '1995: An Important Inflection Point in Recent Geophysical History',
            authorsShort: 'Viterito',
            journal:
                'International Journal of Environmental Sciences and Natural Resources',
            year: 2022,
            url: 'https://juniperpublishers.com/ijesnr/IJESNR.MS.ID.556271.php',
            studyType: 'Statistical study',
            summary:
                'Proves a massive increase in mid-ocean ridge earthquakes after 1995, linked to internal Earth heat release.',
            tags: ['earthquakes', 'ocean floor', 'heat'],
          ),
          _study(
            title:
                'Low-buoyancy thermochemical plumes resolve controversy of classical mantle plume concept',
            authorsShort: 'Dannberg and Sobolev',
            journal: 'Nature Communications',
            year: 2015,
            url: 'https://www.nature.com/articles/ncomms7960',
            doiOrPubMed: 'doi:10.1038/ncomms7960',
            studyType: 'Geodynamic modeling',
            summary:
                'Models thermochemical mantle plume dynamics, resolving disputes about the classical plume concept.',
            tags: ['mantle plume', 'modeling', 'geodynamics'],
          ),
          _study(
            title:
                'Structure of the upper mantle beneath southern Siberia and Mongolia based on regional seismic tomography data',
            authorsShort: 'Kulakov',
            journal: 'Russian Geology and Geophysics',
            year: 2008,
            url:
                'https://pubs.geoscienceworld.org/nsu/rgg/article-abstract/49/2/98/588894/',
            studyType: 'Seismic tomography',
            summary:
                'Investigates magma flow patterns around the Siberian Craton using seismic data.',
            tags: ['mantle', 'seismology', 'Siberia'],
          ),
          _study(
            title:
                'New data on mud volcanism in the Arctic on the Yamal Peninsula',
            authorsShort: 'Bogoyavlensky',
            journal: 'Doklady Earth Sciences',
            year: 2023,
            url: 'https://journals.rcsi.science/2686-7397/article/view/135891',
            studyType: 'Field observation',
            summary:
                'Studies giant craters and mud volcanism caused by thermokarst thawing and deep gas expulsion.',
            tags: ['Arctic', 'volcanism', 'gas expulsion'],
          ),
          _study(
            title: 'Thunderstorms near the North Pole',
            authorsShort: 'Popykina et al.',
            journal: 'Atmosphere',
            year: 2024,
            url: 'https://www.mdpi.com/2073-4433/15/3/310',
            studyType: 'Observation study',
            summary:
                'Documents anomalous thunderstorm activity near the North Pole linked to increased ionization.',
            tags: ['Arctic', 'lightning', 'atmosphere'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_magnetic',
      title: l10n.detailMagneticFieldTitle,
      subtitle: l10n.detailMagneticFieldSubtitle,
      icon: Icons.explore_outlined,
      themeColor: AppColors.neonMagma,
      glowColor: AppColors.neonMagmaGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailMagneticFieldEntry1Highlight,
          description: l10n.detailMagneticFieldEntry1Desc,
          pdfStartPage: 68,
          pdfEndPage: 69,
          pdfCategory: 'Magnetic Field & Earth\'s Core (Geophysical Impacts)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData planetEntryGates(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'plastic-system-failure',
        title: l10n.detailPlanetEntryGatesEntry1Highlight,
        description: l10n.detailPlanetEntryGatesEntry1Desc,
        studies: [
          _study(
            title: 'Production, use, and fate of all plastics ever made',
            authorsShort: 'Geyer et al.',
            journal: 'Science Advances',
            year: 2017,
            url: 'https://www.science.org/doi/10.1126/sciadv.1700782',
            studyType: 'Global accounting study',
            summary:
                'Maps the cumulative fate of plastic production into recycling, incineration, landfill, and waste.',
            tags: ['plastic waste', 'global accounting', 'systems'],
          ),
          _study(
            title: 'Plastic waste inputs from land into the ocean',
            authorsShort: 'Jambeck et al.',
            journal: 'Science',
            year: 2015,
            url: 'https://www.science.org/doi/10.1126/science.1260352',
            studyType: 'Global model',
            summary:
                'Quantifies land-based inputs of plastic waste into ocean systems.',
            tags: ['ocean entry', 'plastic waste', 'modeling'],
          ),
          _study(
            title: 'Export of Plastic Debris by Rivers into the Sea',
            authorsShort: 'Schmidt et al.',
            journal: 'Environmental Science and Technology',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acs.est.7b02368',
            studyType: 'Transport model',
            summary:
                'Shows the river systems responsible for a large share of marine plastic transport.',
            tags: ['rivers', 'transport', 'ocean entry'],
          ),
          _study(
            title: 'Plastic debris in lakes and reservoirs',
            authorsShort: 'Nava et al.',
            journal: 'Nature',
            year: 2023,
            url: 'https://www.nature.com/articles/s41586-023-06168-4',
            studyType: 'Field study',
            summary:
                'Documents severe contamination in lakes and reservoirs as regional entry systems.',
            tags: ['lakes', 'reservoirs', 'field study'],
          ),
          _study(
            title:
                'Accumulation and fragmentation of plastic debris in global environments',
            authorsShort: 'Barnes et al.',
            journal: 'Philosophical Transactions of the Royal Society B',
            year: 2009,
            url:
                'https://royalsocietypublishing.org/rstb/article-abstract/364/1526/1985/21064/Accumulation-and-fragmentation-of-plastic-debris?redirectedFrom=fulltext',
            studyType: 'Review',
            summary:
                'Classic review on fragmentation pathways that create persistent smaller plastic particles.',
            tags: ['fragmentation', 'review', 'environment'],
          ),
          _study(
            title:
                'A multidisciplinary perspective on the role of plastic pollution in the triple planetary crisis',
            authorsShort: 'Schmidt et al.',
            journal: 'Environment International',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412024006457?via%3Dihub',
            studyType: 'Review',
            summary:
                'Frames plastic pollution as a driver across biodiversity, climate, and pollution crises.',
            tags: ['review', 'planetary crisis', 'systems'],
          ),
          _study(
            title: 'Annual plastic waste by disposal method',
            authorsShort: 'Our World in Data',
            journal: 'Our World in Data',
            year: 2023,
            url: 'https://ourworldindata.org/grapher/plastic-fate',
            studyType: 'Data visualization',
            summary:
                'Visualizes global plastic waste disposal methods, illustrating the scale of the recycling failure.',
            tags: ['plastic waste', 'recycling', 'global data'],
          ),
          _study(
            title: 'Blind spots in the monitoring of plastic waste',
            authorsShort: 'Karlsruhe Institute of Technology',
            journal: 'KIT Press Release',
            year: 2022,
            url:
                'https://www.kit.edu/kit/english/pi_2022_097_blind-spots-in-the-monitoring-of-plastic-waste.php',
            studyType: 'Science news',
            summary:
                'Highlights systematic monitoring gaps that lead to underestimation of plastic waste volumes.',
            tags: ['plastic waste', 'monitoring', 'policy'],
          ),
          _study(
            title:
                'A growing plastic smog, now estimated to be over 170 trillion plastic particles afloat in the world\'s oceans',
            authorsShort: 'Eriksen et al.',
            journal: 'PLoS ONE',
            year: 2023,
            url:
                'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0281596',
            studyType: 'Global modeling study',
            summary:
                'Models exponentially growing ocean plastic smog from land-based waste inputs.',
            tags: ['ocean', 'plastic smog', 'modeling'],
          ),
          _study(
            title:
                'The rise in ocean plastics evidenced from a 60-year time series',
            authorsShort: 'Ostle et al.',
            journal: 'Nature Communications',
            year: 2019,
            url: 'https://www.nature.com/articles/s41467-019-09506-1',
            studyType: 'Long-term observation',
            summary:
                'Documents rising ocean plastics since the 1960s, reflecting decades of inadequate waste management.',
            tags: ['ocean', 'time series', 'plastic waste'],
          ),
          _study(
            title:
                'Abiotic plastic leaching contributes to ocean acidification',
            authorsShort: 'Romera-Castillo et al.',
            journal: 'Science of The Total Environment',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0048969722057825?via%3Dihub',
            studyType: 'Laboratory study',
            summary:
                'Shows UV-driven plastic degradation releases dissolved organic acids, accelerating ocean acidification.',
            tags: ['ocean acidification', 'UV degradation', 'leaching'],
          ),
          _study(
            title: 'Current opinion: What is a nanoplastic?',
            authorsShort: 'Gigault et al.',
            journal: 'Environmental Pollution',
            year: 2018,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0269749117337247?via%3Dihub',
            studyType: 'Conceptual study',
            summary:
                'Defines nanoplastics and examines their formation from UV degradation of plastics in the Atlantic.',
            tags: ['definition', 'nanoplastic', 'degradation'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_entry',
      title: l10n.detailPlanetEntryGatesTitle,
      subtitle: l10n.detailPlanetEntryGatesSubtitle,
      icon: Icons.delete_outline,
      themeColor: AppColors.neonSource,
      glowColor: AppColors.neonSourceGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPlanetEntryGatesEntry1Highlight,
          description: l10n.detailPlanetEntryGatesEntry1Desc,
          pdfStartPage: 7,
          pdfEndPage: 22,
          pdfCategory:
              'Entry Gates - Crisis Sources (Plastic Production, Waste Management)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData physicalProperties(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'water-hydrogen-bonds',
        title: l10n.detailPhysicalPropertiesEntry1Highlight,
        description: l10n.detailPhysicalPropertiesEntry1Desc,
        studies: [
          _study(
            title:
                'A hierarchical clustering method of hydrogen bond networks in liquid water undergoing shear flow',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2021,
            url: 'https://www.nature.com/articles/s41598-021-88810-7',
            studyType: 'Water structure study',
            summary:
                'Characterizes hydrogen-bond network structure in liquid water under dynamic conditions.',
            tags: ['water', 'hydrogen bonds', 'structure'],
          ),
          _study(
            title:
                'Water clusters and density fluctuations in liquid water based on extended hierarchical clustering methods',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2022,
            url: 'https://www.nature.com/articles/s41598-022-11947-6',
            studyType: 'Water structure study',
            summary:
                'Studies cluster formation and density fluctuations in liquid water.',
            tags: ['water', 'clusters', 'structure'],
          ),
          _study(
            title:
                'Electrolytes induce long-range orientational order and free energy changes in the H-bond network of bulk water',
            authorsShort: 'Chen et al.',
            journal: 'Science Advances',
            year: 2016,
            url: 'https://www.science.org/doi/10.1126/sciadv.1501891',
            studyType: 'Water physics study',
            summary:
                'Shows how charged species alter bulk-water orientational order and hydration structure.',
            tags: ['water', 'charge', 'hydration shell'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'heavy-clouds',
        title: l10n.detailPhysicalPropertiesEntry2Highlight,
        description: l10n.detailPhysicalPropertiesEntry2Desc,
        studies: [
          _study(
            title:
                'Airborne hydrophilic microplastics in cloud water at high altitudes and their role in cloud formation',
            authorsShort: 'Wang et al.',
            journal: 'Environmental Chemistry Letters',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s10311-023-01626-x',
            studyType: 'Field study',
            summary:
                'Connects airborne plastics with cloud-water chemistry and formation.',
            tags: ['clouds', 'atmosphere', 'microplastics'],
          ),
          _study(
            title:
                'Pristine and Aged Microplastics Can Nucleate Ice through Immersion Freezing',
            authorsShort: 'Busse et al.',
            journal: 'ACS EST Air',
            year: 2024,
            url: 'https://doi.org/10.1021/acsestair.4c00146',
            studyType: 'Laboratory study',
            summary:
                'Demonstrates direct ice-nucleation capacity of microplastics.',
            tags: ['ice nucleation', 'clouds', 'laboratory'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'bioelectric-signals',
        title: l10n.detailPhysicalPropertiesEntry3Highlight,
        description: l10n.detailPhysicalPropertiesEntry3Desc,
        studies: [
          _study(
            title:
                'A review of microplastic surface interactions in water and potential capturing methods',
            authorsShort: 'Rahman et al.',
            journal: 'Water Science and Engineering',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S1674237023001217?via%3Dihub',
            studyType: 'Review',
            summary:
                'Reviews charge acquisition and surface interaction behavior of plastics in water.',
            tags: ['review', 'surface interactions', 'charge'],
          ),
          _study(
            title:
                'Surface-Functionalized Polystyrene Nanoparticles Alter the Transmembrane Potential via Ion-Selective Pores Maintaining Global Bilayer Integrity',
            authorsShort: 'Perini et al.',
            journal: 'Langmuir',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.langmuir.2c02487',
            studyType: 'Mechanistic study',
            summary:
                'Provides a direct membrane-potential reference for bioelectric interference.',
            tags: ['bioelectric', 'membrane potential', 'mechanism'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'photosynthesis',
        title: l10n.detailPhysicalPropertiesEntry4Highlight,
        description: l10n.detailPhysicalPropertiesEntry4Desc,
        studies: [
          _study(
            title:
                'Effect of microplastics exposure on the photosynthesis system of freshwater algae',
            authorsShort: 'Wu et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2019,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389419304674?via%3Dihub',
            studyType: 'Laboratory study',
            summary:
                'Shows direct damage to the photosynthesis system in freshwater algae under microplastic exposure.',
            tags: ['photosynthesis', 'algae', 'laboratory'],
          ),
          _study(
            title:
                'Thermal Conductivity and Specific Heat Capacity of Dodecylbenzenesulfonic Acid-Doped Polyaniline Particles — Water Based Nanofluid',
            authorsShort: 'Chew et al.',
            journal: 'Polymers',
            year: 2015,
            url: 'https://www.mdpi.com/2073-4360/7/7/1221',
            studyType: 'Material science study',
            summary:
                'Shows nanoparticles in water increase its thermal conductivity and alter specific heat.',
            tags: ['nanofluid', 'thermal conductivity', 'water'],
          ),
          _study(
            title: 'Specific heat control of nanofluids: A critical review',
            authorsShort: 'Riazi et al.',
            journal: 'International Journal of Thermal Sciences',
            year: 2016,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S129007291630103X',
            studyType: 'Review',
            summary:
                'Reviews how nanoparticle concentration and type alter specific heat in aqueous fluids.',
            tags: ['nanofluid', 'specific heat', 'thermal'],
          ),
          _study(
            title: 'Water Dynamics in the Hydration Shells of Biomolecules',
            authorsShort: 'Laage et al.',
            journal: 'Chemical Reviews',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acs.chemrev.6b00765',
            doiOrPubMed: 'doi:10.1021/acs.chemrev.6b00765',
            studyType: 'Review',
            summary:
                'Describes how charged particles and biomolecules create hydration shells altering bulk-water dynamics.',
            tags: ['water', 'hydration shell', 'hydrogen bonds'],
          ),
          _study(
            title:
                'Effective Thermal Conductivity of Nanofluids: Measurement and Prediction',
            authorsShort: 'Berger Bioucas et al.',
            journal: 'International Journal of Thermophysics',
            year: 2020,
            url: 'https://link.springer.com/article/10.1007/s10765-020-2621-2',
            studyType: 'Experimental study',
            summary:
                'Measures and predicts thermal conductivity changes in nanofluids relevant to water heat dynamics.',
            tags: ['nanofluid', 'thermal', 'measurement'],
          ),
          _study(
            title:
                'The Biology of Electricity: How electricity is critical to the functioning of the human body',
            authorsShort: 'Azim Premji University',
            journal: 'Azim Premji University',
            year: 2022,
            url:
                'https://azimpremjiuniversity.edu.in/news/2022/the-biology-of-electricity',
            studyType: 'Educational reference',
            summary:
                'Explains bioelectricity as a fundamental property of living systems, relevant to MNP interference.',
            tags: ['bioelectric', 'reference', 'education'],
          ),
          _study(
            title: 'The anomalies and criticality of liquid water',
            authorsShort: 'Shi et al.',
            journal: 'PNAS',
            year: 2020,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2008426117',
            doiOrPubMed: 'doi:10.1073/pnas.2008426117',
            studyType: 'Water physics study',
            summary:
                'Explores unique thermodynamic anomalies of liquid water relevant to how nanoparticles disrupt its structure.',
            tags: ['water', 'thermodynamics', 'anomalies'],
          ),
          _study(
            title:
                'Quantum effects in proteins: How tiny particles coordinate energy transfer inside cells',
            authorsShort: 'Phys.org',
            journal: 'Phys.org',
            year: 2025,
            url:
                'https://phys.org/news/2025-05-quantum-effects-proteins-tiny-particles.html',
            studyType: 'Science news',
            summary:
                'Explains the Goren et al. (2025) PNAS study on quantum proton transfer in proteins and its implications for bioelectric processes disrupted by MNPs.',
            tags: ['bioelectric', 'quantum', 'reference'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_physical',
      title: l10n.detailPhysicalPropertiesTitle,
      subtitle: l10n.detailPhysicalPropertiesSubtitle,
      icon: Icons.hub_outlined,
      themeColor: AppColors.neonPhysics,
      glowColor: AppColors.neonPhysicsGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry1Highlight,
          description: l10n.detailPhysicalPropertiesEntry1Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry2Highlight,
          description: l10n.detailPhysicalPropertiesEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry3Highlight,
          description: l10n.detailPhysicalPropertiesEntry3Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry4Highlight,
          description: l10n.detailPhysicalPropertiesEntry4Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }
}
