enum UserRole { admin, owner, user }

extension UserRoleParsing on String {
  UserRole toUserRole() {
    switch (toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      case 'user':
        return UserRole.user;
      default:
        throw Exception('Unkown role: $this');
    }
  }
}
