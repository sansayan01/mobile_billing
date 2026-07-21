import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  static const String shopKey = 'shop_details';

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final box = HiveDatabase.shopBox;
      final shop = box.get(shopKey);
      if (shop != null && shop.name.isNotEmpty) {
        return Right(shop);
      }

      // Hive mein valid shop nahi mila — Supabase se try karo.
      try {
        final userId = SupabaseConfig.client.auth.currentUser?.id;
        if (userId != null) {
          final profile = await SupabaseConfig.client
              .from('profiles')
              .select('shop_id')
              .eq('id', userId)
              .maybeSingle();
          final shopId = profile is Map<String, dynamic>
              ? profile['shop_id'] as String?
              : null;
          if (shopId != null) {
            final shopRow = await SupabaseConfig.client
                .from('shops')
                .select()
                .eq('id', shopId)
                .maybeSingle();
            if (shopRow is Map<String, dynamic>) {
              final shop = ShopModel(
                id: shopRow['id'] as String? ?? '',
                name: shopRow['name'] as String? ?? '',
                addressLine1: '',
                addressLine2: '',
                phoneNumber: '',
                upiId: '',
                footerText: '',
              );
              await box.put(shopKey, shop);
              return Right(shop);
            }
          }
        }
      } catch (_) {
        // Supabase fallback failed — return empty shop below
      }

      return const Right(Shop());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      final box = HiveDatabase.shopBox;
      final model = ShopModel.fromEntity(shop);
      await box.put(shopKey, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
