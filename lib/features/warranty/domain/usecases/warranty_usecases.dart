import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/warranty_claim.dart';
import '../repositories/warranty_repository.dart';

class CreateWarrantyClaimUseCase {
  final WarrantyRepository repository;

  CreateWarrantyClaimUseCase(this.repository);

  Future<Either<Failure, WarrantyClaim>> call(
    WarrantyClaim claim, {
    String? shopId,
  }) {
    return repository.createClaim(claim, shopId: shopId);
  }
}

class GetWarrantyClaimsUseCase {
  final WarrantyRepository repository;

  GetWarrantyClaimsUseCase(this.repository);

  Future<Either<Failure, List<WarrantyClaim>>> call({
    String? shopId,
    String? status,
  }) {
    return repository.getClaims(shopId: shopId, status: status);
  }
}

class UpdateClaimStatusUseCase {
  final WarrantyRepository repository;

  UpdateClaimStatusUseCase(this.repository);

  Future<Either<Failure, WarrantyClaim>> call(
    String claimId,
    String status, {
    String? shopId,
  }) {
    return repository.updateClaimStatus(claimId, status, shopId: shopId);
  }
}
