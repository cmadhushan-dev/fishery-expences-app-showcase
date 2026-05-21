
class TripExpencesListModel {
  final String expencesName;
  final String expencesPrice;

  //constructor
  TripExpencesListModel({
    required this.expencesName,
    required this.expencesPrice,
  });

  //convert firestore  map to the dart objects
  factory TripExpencesListModel.fromMap(Map<String, dynamic> map) {
    return TripExpencesListModel(
      expencesName: map['name'] ?? '',
      expencesPrice: map['amount'] ?? '',
    );
  }
   // ✅ Dart → Firebase (WRITE) - මේක add කරන්න ඕනේ!
  Map<String, dynamic> toMap() {
    return {
      'name': expencesName,
      'amount': expencesPrice,
    };
  }
}
