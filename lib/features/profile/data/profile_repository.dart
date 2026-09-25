import '../models/user_profile_model.dart';

/// Faux service utilisateur : pas d'authentification dans ce projet.
class ProfileRepository {
  Future<UserProfile> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return UserProfile(
      firstName: 'Ange',
      lastName: 'KOUGO',
      email: 'ange@example.com',
      phone: '+225 07 00 00 00 00',
      address: '123 Rue des Fleurs, Cocody, Abidjan',
      memberSince: DateTime(2025, 3, 12),
      orderCount: 7,
    );
  }
}
