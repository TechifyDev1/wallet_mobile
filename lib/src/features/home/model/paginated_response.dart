class PaginatedResponse<T> {
  final List<T> content;
  final bool isLast;
  final int totalElements;

  PaginatedResponse({
    required this.content,
    required this.isLast,
    required this.totalElements,
  });
}
