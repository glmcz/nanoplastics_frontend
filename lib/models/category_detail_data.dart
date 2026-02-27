import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class CategoryDetailData {
  final String
      categoryKey; // stable, language-agnostic key (matches CategoryData.id)
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final Color glowColor;
  final List<DetailEntry> entries;
  final List<SourceLink>? sourceLinks;

  const CategoryDetailData({
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.glowColor,
    required this.entries,
    this.sourceLinks,
  });
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

class SourceLink {
  final String title;
  final String source;
  final String url;
  final String?
      pdfAssetPath; // Path to PDF asset (e.g., 'assets/docs/file.pdf')
  final int? pdfStartPage; // For PDFs, start page number
  final int? pdfEndPage; // For PDFs, end page number

  const SourceLink({
    required this.title,
    required this.source,
    required this.url,
    this.pdfAssetPath,
    this.pdfStartPage,
    this.pdfEndPage,
  });
}

// Predefined category data based on HTML designs
class CategoryDetailDataFactory {
  // Human Body Categories
  static CategoryDetailData centralSystems(AppLocalizations l10n) =>
      CategoryDetailData(
        categoryKey: 'human_central',
        title: l10n.detailCentralSystemsTitle,
        subtitle: l10n.detailCentralSystemsSubtitle,
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceAutismSpectrumBPA,
            source: 'Nat Commun (2024)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/39112449/',
          ),
          SourceLink(
            title: l10n.sourceBioaccumulationBrain,
            source: 'Nat Med (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/39901044/',
          ),
          SourceLink(
            title: l10n.sourceCrossingBloodBrainBarrier,
            source: 'Nanomaterials (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37110989/',
          ),
        ],
      );

  static CategoryDetailData filtrationDetox(AppLocalizations l10n) =>
      CategoryDetailData(
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
            pdfCategory:
                'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
          ),
          DetailEntry(
            highlight: l10n.detailFiltrationDetoxEntry2Highlight,
            description: l10n.detailFiltrationDetoxEntry2Desc,
            pdfStartPage: 71,
            pdfEndPage: 91,
            pdfCategory:
                'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
          ),
        ],
        sourceLinks: [
          SourceLink(
            title: l10n.sourceReductionMNPBoilingWater,
            source: 'Environ. Sci. Technol. Lett. (2024)',
            url: 'https://pubs.acs.org/doi/10.1021/acs.estlett.4c00081',
          ),
          SourceLink(
            title: l10n.sourceContaminationDairyProducts,
            source: 'Sci Rep (2021)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/34911996/',
          ),
          SourceLink(
            title: l10n.sourceQuantumEffectsProtonTransfer,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40339126/',
          ),
        ],
      );

  static CategoryDetailData vitalityTissues(AppLocalizations l10n) =>
      CategoryDetailData(
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceCardiovascularRisksAtheromas,
            source: 'N Engl J Med (2024)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/38446676/',
          ),
          SourceLink(
            title: l10n.sourceQuantumEffectsProtonTransfer,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40339126/',
          ),
          SourceLink(
            title: l10n.sourceBioaccumulationBrain,
            source: 'Nat Med (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/39901044/',
          ),
        ],
      );

  static CategoryDetailData reproduction(AppLocalizations l10n) =>
      CategoryDetailData(
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourcePlasticsInMaleSemen,
            source: 'Science of The Total Environment (2024)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/38802004/',
          ),
          SourceLink(
            title: l10n.sourcePlasticsInFemaleFollicularFluid,
            source: 'Ecotoxicology and Environmental Safety (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/39947063/',
          ),
          SourceLink(
            title: l10n.sourceAdverseBirthOutcomesUSAPhthalates,
            source: 'The Lancet Planetary Health (2024)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/38331533/',
          ),
          SourceLink(
            title: l10n.sourcePhthalateExposureCancerChildren,
            source: 'JNCI (2022)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/35179607/',
          ),
        ],
      );

  static CategoryDetailData entryGates(AppLocalizations l10n) =>
      CategoryDetailData(
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
            pdfCategory:
                'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
          ),
          DetailEntry(
            highlight: l10n.detailEntryGatesEntry2Highlight,
            description: l10n.detailEntryGatesEntry2Desc,
            pdfStartPage: 70,
            pdfEndPage: 91,
            pdfCategory:
                'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
          ),
          DetailEntry(
            highlight: l10n.detailEntryGatesEntry3Highlight,
            description: l10n.detailEntryGatesEntry3Desc,
            pdfStartPage: 70,
            pdfEndPage: 91,
            pdfCategory:
                'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
          ),
        ],
        sourceLinks: [
          SourceLink(
            title: l10n.sourceReductionMNPBoilingWater,
            source: 'Environ. Sci. Technol. Lett. (2024)',
            url: 'https://pubs.acs.org/doi/10.1021/acs.estlett.4c00081',
          ),
          SourceLink(
            title: l10n.sourceContaminationDairyProducts,
            source: 'Sci Rep (2021)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/34911996/',
          ),
          SourceLink(
            title: l10n.sourceEmissionPlasticsOceanToAtmosphere,
            source: 'PNAS Nexus (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37795272/',
          ),
        ],
      );

  static CategoryDetailData physicalAttack(AppLocalizations l10n) =>
      CategoryDetailData(
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
            pdfCategory:
                'Physical Attack (Quantum, Molecular, Cellular Damage)',
          ),
          DetailEntry(
            highlight: l10n.detailPhysicalAttackEntry2Highlight,
            description: l10n.detailPhysicalAttackEntry2Desc,
            pdfStartPage: 92,
            pdfEndPage: 119,
            pdfCategory:
                'Physical Attack (Quantum, Molecular, Cellular Damage)',
          ),
          DetailEntry(
            highlight: l10n.detailPhysicalAttackEntry3Highlight,
            description: l10n.detailPhysicalAttackEntry3Desc,
            pdfStartPage: 92,
            pdfEndPage: 119,
            pdfCategory:
                'Physical Attack (Quantum, Molecular, Cellular Damage)',
          ),
        ],
        sourceLinks: [
          SourceLink(
            title: l10n.sourceQuantumEffectsProtonTransfer,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40339126/',
          ),
          SourceLink(
            title: l10n.sourceCrossingBloodBrainBarrier,
            source: 'Nanomaterials (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37110989/',
          ),
          SourceLink(
            title: l10n.sourceCardiovascularRisksAtheromas,
            source: 'N Engl J Med (2024)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/38446676/',
          ),
        ],
      );

  // Planet Earth Categories
  static CategoryDetailData worldOcean(AppLocalizations l10n) =>
      CategoryDetailData(
        categoryKey: 'planet_ocean',
        title: l10n.detailWorldOceanTitle,
        subtitle: l10n.detailWorldOceanSubtitle,
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceOceanAcidificationPlasticDegradation,
            source: 'Science of The Total Environment (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/36099941/',
          ),
          SourceLink(
            title: l10n.sourceContaminationDeepestOcean,
            source: 'Geochem. Persp. Let. (2018)',
            url: 'https://www.geochemicalperspectivesletters.org/article1829/',
          ),
          SourceLink(
            title: l10n.sourceCoralReefCollapse,
            source: 'Nature (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37438592/',
          ),
        ],
      );

  static CategoryDetailData atmosphere(AppLocalizations l10n) =>
      CategoryDetailData(
        categoryKey: 'planet_atmosphere',
        title: l10n.detailAtmosphereTitle,
        subtitle: l10n.detailAtmosphereSubtitle,
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceEmissionPlasticsOceanToAtmosphere,
            source: 'PNAS Nexus (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37795272/',
          ),
          SourceLink(
            title: l10n.sourceIceFormationAtmosphereMNP,
            source: 'ACS EST Air (2024)',
            url:
                'https://chemrxiv.org/engage/chemrxiv/article-details/666cec53c9c6a5c07a8212e7',
          ),
          SourceLink(
            title: l10n.sourceMNPCloudsImpactPrecipitation,
            source: 'Environ Chem Lett (2023)',
            url: 'https://waseda.elsevierpure.com/en/publications',
          ),
        ],
      );

  static CategoryDetailData florFauna(AppLocalizations l10n) =>
      CategoryDetailData(
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceGlobalPhotosynthesisLosses,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40063820/',
          ),
          SourceLink(
            title: l10n.sourceCoralReefCollapse,
            source: 'Nature (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37438592/',
          ),
          SourceLink(
            title: l10n.sourceFragmentGrowthPacificGarbagePatch,
            source: 'Environ. Res. Lett. (2024)',
            url: 'https://www.researchgate.net/publication/385947350',
          ),
        ],
      );

  static CategoryDetailData magneticField(AppLocalizations l10n) =>
      CategoryDetailData(
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceGeophysicalBreak1995,
            source: 'Int. J. Environ. Sci. Nat. Res. (2022)',
            url: 'https://juniperpublishers.com/ijesnr/IJESNR.MS.ID.556271.php',
          ),
          SourceLink(
            title: l10n.sourceContaminationDeepestOcean,
            source: 'Geochem. Persp. Let. (2018)',
            url: 'https://www.geochemicalperspectivesletters.org/article1829/',
          ),
          SourceLink(
            title: l10n.sourceGlobalPhotosynthesisLosses,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40063820/',
          ),
        ],
      );

  static CategoryDetailData planetEntryGates(AppLocalizations l10n) =>
      CategoryDetailData(
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
        sourceLinks: [
          SourceLink(
            title: l10n.sourceFragmentGrowthPacificGarbagePatch,
            source: 'Environ. Res. Lett. (2024)',
            url: 'https://www.researchgate.net/publication/385947350',
          ),
          SourceLink(
            title: l10n.sourceEmissionPlasticsOceanToAtmosphere,
            source: 'PNAS Nexus (2023)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/37795272/',
          ),
          SourceLink(
            title: l10n.sourceContaminationDeepestOcean,
            source: 'Geochem. Persp. Let. (2018)',
            url: 'https://www.geochemicalperspectivesletters.org/article1829/',
          ),
        ],
      );

  static CategoryDetailData physicalProperties(AppLocalizations l10n) =>
      CategoryDetailData(
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
            pdfCategory:
                'Physical Properties (Polymer Degradation, Persistence)',
          ),
          DetailEntry(
            highlight: l10n.detailPhysicalPropertiesEntry2Highlight,
            description: l10n.detailPhysicalPropertiesEntry2Desc,
            pdfStartPage: 92,
            pdfEndPage: 119,
            pdfCategory:
                'Physical Properties (Polymer Degradation, Persistence)',
          ),
          DetailEntry(
            highlight: l10n.detailPhysicalPropertiesEntry3Highlight,
            description: l10n.detailPhysicalPropertiesEntry3Desc,
            pdfStartPage: 92,
            pdfEndPage: 119,
            pdfCategory:
                'Physical Properties (Polymer Degradation, Persistence)',
          ),
          DetailEntry(
            highlight: l10n.detailPhysicalPropertiesEntry4Highlight,
            description: l10n.detailPhysicalPropertiesEntry4Desc,
            pdfStartPage: 92,
            pdfEndPage: 119,
            pdfCategory:
                'Physical Properties (Polymer Degradation, Persistence)',
          ),
        ],
        sourceLinks: [
          SourceLink(
            title: l10n.sourceIceFormationAtmosphereMNP,
            source: 'ACS EST Air (2024)',
            url:
                'https://chemrxiv.org/engage/chemrxiv/article-details/666cec53c9c6a5c07a8212e7',
          ),
          SourceLink(
            title: l10n.sourceMNPCloudsImpactPrecipitation,
            source: 'Environ Chem Lett (2023)',
            url: 'https://waseda.elsevierpure.com/en/publications',
          ),
          SourceLink(
            title: l10n.sourceGlobalPhotosynthesisLosses,
            source: 'PNAS (2025)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/40063820/',
          ),
        ],
      );
}
