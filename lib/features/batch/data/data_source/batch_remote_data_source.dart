


import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_starter/app/constants/api_endpoint.dart';
import 'package:student_management_starter/core/failure/failure.dart';
import 'package:student_management_starter/core/networking/remote/http_service.dart';
import 'package:student_management_starter/core/shared_prefs/user_shared_prefs.dart';
import 'package:student_management_starter/features/batch/data/dto/get_all_batch_dto.dart';
import 'package:student_management_starter/features/batch/data/model/batch_api_model.dart';
import 'package:student_management_starter/features/batch/domain/entity/batch_entity.dart';


final batchRemoteDataSourceProvider = Provider<BatchRemoteDataSource>((ref) {
  final dio = ref.read(httpServiceProvider);
  final batchApiModel = ref.read(batchApiModelProvider);
  final userSharedPrefs = ref.read(userSharedPrefsProvider);

  return BatchRemoteDataSource(
    dio: dio,
    batchApiModel: batchApiModel,
    userSharedPrefs: userSharedPrefs,
  );
});

class BatchRemoteDataSource {
  final Dio dio;
  final BatchApiModel batchApiModel;
  final UserSharedPrefs userSharedPrefs;

  BatchRemoteDataSource({
    required this.dio,
    required this.batchApiModel,
    required this.userSharedPrefs,
  });

  Future<Either<Failure, bool>> addBatch(BatchEntity batch) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createBatch,
        data: batchApiModel.fromEntity(batch).toJson(),
      );
      if (response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(Failure(error: 'Failed to add course'));
      }
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, List<BatchEntity>>> getAllBatch() async {
    try {
      final response = await dio.get(ApiEndpoints.getAllBatch);
      if (response.statusCode == 200) {
        final getAllBatchDTO = GetAllBatchDTO.fromJson(response.data);
        final batches = getAllBatchDTO.data.map((e) => e.toEntity()).toList();
        return Right(batches);
      } else {
        return Left(Failure(error: 'Failed to get all batches'));
      }
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      // Retrieve token from shared preferences
      String? token;
      var data = await userSharedPrefs.getUserToken();
      data.fold(
        (l) => token = null,
        (r) => token = r!,
      );
      //localhost:3000/api/v1/course/666fa63c025b203550d06179
      Response response = await dio.delete(
        ApiEndpoints.deleteBatch + batchId,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(
          Failure(
            error: response.data["message"],
            statusCode: response.statusCode.toString(),
          ),
        );
      }
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }
}
