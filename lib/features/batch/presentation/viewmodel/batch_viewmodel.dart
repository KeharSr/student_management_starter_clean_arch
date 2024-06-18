import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_starter/core/common/my_snackbar.dart';
import 'package:student_management_starter/features/batch/domain/entity/batch_entity.dart';
import 'package:student_management_starter/features/batch/domain/usecases/batch_usecase.dart';
import 'package:student_management_starter/features/batch/presentation/state/batch_state.dart';

final batchViewModelProvider =
    StateNotifierProvider<BatchViewmodel, BatchState>(
  (ref) => BatchViewmodel(
    ref.read(batchUsecaseProvider),
  ),
);

class BatchViewmodel extends StateNotifier<BatchState> {
  BatchViewmodel(this.batchUseCase) : super(BatchState.initial()) {
    getAllBatches();
  }

  final BatchUseCase batchUseCase;

  addBatch(BatchEntity batch) async {
    // To show the progress bar
    state = state.copyWith(isLoading: true);
    var data = await batchUseCase.addBatch(batch);

    data.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.error);
        showMySnackBar(message: l.error, color: Colors.red);
      },
      (r) {
        state = state.copyWith(isLoading: false, error: null);
        showMySnackBar(message: "Batch added successfully");
      },
    );

    getAllBatches();
  }

  deleteBatch(BatchEntity batch) async {
    state.copyWith(isLoading: true);
    var data = await batchUseCase.deleteBatch(batch.batchId!);

    data.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.error);
        showMySnackBar(message: l.error, color: Colors.red);
      },
      (r) {
        state.lstBatches.remove(batch);
        state = state.copyWith(isLoading: false, error: null);
        showMySnackBar(
          message: 'Batch delete successfully',
        );
      },
    );

    getAllBatches();
  }

  // For getting all batches
  getAllBatches() async {
    // To show the progress bar
    state = state.copyWith(isLoading: true);
    var data = await batchUseCase.getAllBatches();

    data.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.error);
        showMySnackBar(message: l.error, color: Colors.red);
      },
      (r) {
        state = state.copyWith(isLoading: false, lstBatches: r, error: null);
      },
    );
  }



  //Navigation
}