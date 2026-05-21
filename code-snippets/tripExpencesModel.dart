
import 'trip_expences_list_model.dart';

class TripExpencesModel {
  final String id;
  final String boatNumber;
  final String tripStartDate;
  final List<TripExpencesListModel> tripExpences;

  TripExpencesModel({
    required this.id,
    required this.boatNumber,
    required this.tripExpences,
    required this.tripStartDate,
  });
  //firebase to dart
  factory TripExpencesModel.fromMap(Map<String, dynamic> map,String docId) {
    return TripExpencesModel(
      //this id is from the firebase not from the firebase field
      id: docId,
      boatNumber: map['boatNumber'] ?? '',
      tripStartDate: map['tripStartDate'] ?? '',
      tripExpences: (map['expenses'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                TripExpencesListModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
   // ✅ Dart → Firebase (WRITE) - මේක add කරන්න ඕනේ!
 Map<String, dynamic> toMap() {
  return {
    'boatNumber': boatNumber,
    'tripStartDate': tripStartDate,
    'expenses': tripExpences.map((e) => e.toMap()).toList(), // ✅ Fix!
  };
}
}
