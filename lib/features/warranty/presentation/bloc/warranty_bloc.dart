import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/warranty_claim.dart';
import '../../domain/usecases/warranty_usecases.dart';

part 'warranty_event.dart';
part 'warranty_state.dart';

class WarrantyBloc extends Bloc<WarrantyEvent, WarrantyState> {
  final CreateWarrantyClaimUseCase createClaimUseCase;
  final GetWarrantyClaimsUseCase getClaimsUseCase;
  final UpdateClaimStatusUseCase updateClaimStatusUseCase;
  final AuthBloc authBloc;

  WarrantyBloc({
    required this.createClaimUseCase,
    required this.getClaimsUseCase,
    required this.updateClaimStatusUseCase,
    required this.authBloc,
  }) : super(const WarrantyState()) {
    on<LoadWarrantyClaims>(_onLoadClaims);
    on<CreateWarrantyClaim>(_onCreateClaim);
    on<UpdateWarrantyClaimStatus>(_onUpdateStatus);
  }

  String? get _shopId {
    if (authBloc.state is Authenticated) {
      return (authBloc.state as Authenticated).user.shopId;
    }
    return null;
  }

  Future<void> _onLoadClaims(
    LoadWarrantyClaims event,
    Emitter<WarrantyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getClaimsUseCase.call(
      shopId: _shopId,
      status: event.status,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (claims) => emit(state.copyWith(
        isLoading: false,
        claims: claims,
      )),
    );
  }

  Future<void> _onCreateClaim(
    CreateWarrantyClaim event,
    Emitter<WarrantyState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final claim = WarrantyClaim(
      id: const Uuid().v4(),
      billId: event.billId,
      productId: event.productId,
      productName: event.productName,
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      claimReason: event.claimReason,
      claimType: event.claimType,
      warrantyDuration: event.warrantyDuration,
      warrantyUnit: event.warrantyUnit,
      createdAt: DateTime.now(),
    );

    final result = await createClaimUseCase.call(claim, shopId: _shopId);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        error: failure.message,
      )),
      (newClaim) => emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        claims: [newClaim, ...state.claims],
      )),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateWarrantyClaimStatus event,
    Emitter<WarrantyState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true));
    final result = await updateClaimStatusUseCase.call(
      event.claimId,
      event.status,
      shopId: _shopId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isUpdating: false,
        error: failure.message,
      )),
      (updatedClaim) {
        final updatedClaims = state.claims.map((c) {
          return c.id == updatedClaim.id ? updatedClaim : c;
        }).toList();
        emit(state.copyWith(
          isUpdating: false,
          updateSuccess: true,
          claims: updatedClaims,
        ));
      },
    );
  }
}
