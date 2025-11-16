// lib/model/prediction.dart
class Prediction {
  final String? description;
  final String? placeId;
  final StructuredFormatting? structuredFormatting;

  Prediction({this.description, this.placeId, this.structuredFormatting});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      structuredFormatting:
          json['structured_formatting'] != null
              ? StructuredFormatting.fromJson(json['structured_formatting'])
              : null,
    );
  }
}

class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }
}
