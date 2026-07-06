class ScreeningStatus {
  const ScreeningStatus({
    required this.supported,
    required this.roleAvailable,
    required this.roleHeld,
    required this.androidSdk,
  });

  const ScreeningStatus.unavailable()
    : supported = false,
      roleAvailable = false,
      roleHeld = false,
      androidSdk = 0;

  final bool supported;
  final bool roleAvailable;
  final bool roleHeld;
  final int androidSdk;
}
