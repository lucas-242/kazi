import 'dart:convert';

import 'package:kazi_core/shared/models/api_error.dart';

class ApiResponse {
  ApiResponse({
    required this.status,
    this.message,
    required this.body,
  });

  final int status;
  final String? message;
  final String body;

  dynamic get json => jsonDecode(body);

  void handleStatus({
    Function? status408,
    Function? status404,
    Function? status403,
    Function? status401,
    Function? status400,
    Function? status500,
  }) {
    switch (status) {
      case 404:
        {
          if (status404 != null) {
            status404();
          }
          throw ApiError(ApiFailure.notFound, message: message);
        }
      case 403:
        {
          if (status403 != null) {
            status403();
          }
          throw ApiError(ApiFailure.forbidden, message: message);
        }
      case 401:
        {
          if (status401 != null) {
            status401();
          }
          throw ApiError(ApiFailure.unauthorized, message: message);
        }
      case 400:
        {
          if (status400 != null) {
            status400();
          }
          throw ApiError(ApiFailure.badRequest, message: message);
        }
      case 408:
        {
          if (status408 != null) {
            status408();
          }
          throw ApiError(ApiFailure.timeout, message: message);
        }
      case 500:
        {
          if (status500 != null) {
            status500();
          }
          throw ApiError(ApiFailure.server, message: message);
        }
    }
  }
}
