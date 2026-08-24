part of 'warranty_bloc.dart';

class WarrantyState extends Equatable {
  final List<WarrantyClaim> claims;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUpdating;
  final String? error;
  final bool submitSuccess;
  final bool updateSuccess;

  const WarrantyState({
    this.claims = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUpdating = false,
    this.error,
    this.submitSuccess = false,
    this.updateSuccess = false,
  });

  WarrantyState copyWith({
    List<WarrantyClaim>? claims,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUpdating,
    String? error,
    bool clearError = false,
    bool? submitSuccess,
    bool? updateSuccess,
  }) {
    return WarrantyState(
      claims: claims ?? this.claims,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
      submitSuccess: submitSuccess ?? this.submitSuccess,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }

  @override
  List<Object?> get props => [
        claims,
        isLoading,
        isSubmitting,
        isUpdating,
        error,
        submitSuccess,
        updateSuccess,
      ];
}
