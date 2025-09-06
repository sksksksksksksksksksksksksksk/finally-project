enum AppRole { farmer, distributor, retailer, consumer }

class RoleService {
  AppRole getRoleForEmail(String email) {
    if (email.endsWith('@farmer.com')) {
      return AppRole.farmer;
    } else if (email.endsWith('@distributor.com')) {
      return AppRole.distributor;
    } else if (email.endsWith('@retailer.com')) {
      return AppRole.retailer;
    } else {
      return AppRole.consumer;
    }
  }
}
