class ApiErrorResponse {
  final String message;

  const ApiErrorResponse({required this.message});

  factory ApiErrorResponse.fromDynamic(dynamic data) {
    if (data is String && data.isNotEmpty) {
      return ApiErrorResponse(message: data);
    }
    if (data is Map && data['message'] != null) {
      return ApiErrorResponse(message: data['message'].toString());
    }
    return const ApiErrorResponse(message: 'Error desconocido');
  }
}

