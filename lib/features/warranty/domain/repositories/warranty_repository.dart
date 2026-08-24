import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/warranty_claim.dart';

abstract class WarrantyRepository {
  Future<Either<Failure, WarrantyClaim>> createClaim(WarrantyClaim claim, {String? shopId});
  Future<Either<Failure, List<WarrantyClaim>>> getClaims({String? shopId, String? status});
  Future<Either<Failure, WarrantyClaim>> updateClaimStatus(String claimId, String status, {String? shopId});
}
