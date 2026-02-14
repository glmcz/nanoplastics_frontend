class ResourceItem {
  final String icon;
  final String titleKey;
  final String subtitle;
  final ResourceTag tag;
  final String? url;

  const ResourceItem({
    required this.icon,
    required this.titleKey,
    required this.subtitle,
    required this.tag,
    this.url,
  });
}

enum ResourceTag {
  pdf,
  web,
  video,
}
