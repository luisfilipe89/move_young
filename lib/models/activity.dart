class Activity {
  final String title;
  final String subtitle;
  final String buttonText;
  final String iconPath;
  final Color backgroundColor;
  final VoidCallback onTap;

  Activity({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.iconPath,
    required this.backgroundColor,
    required this.onTap,
  });
}
