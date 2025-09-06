
enum AppRole { farmer, distributor, retailer, consumer }

class RoleService {
  // In a real app, this would be determined from Firebase custom claims
  // or another authoritative source.
  final Map<String, AppRole> _userRoles = {
    'farmer@test.com': AppRole.farmer,
    'distributor@test.com': AppRole.distributor,
    'retailer@test.com': AppRole.retailer,
    'consumer@test.com': AppRole.consumer,
  };

  AppRole getRoleForEmail(String email) {
    return _userRoles[email] ?? AppRole.consumer; // Default to consumer
  }
}
