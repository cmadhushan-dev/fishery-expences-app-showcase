
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../firebase/trip_expences_firebase.dart';
import '../model/trip_expences_all_models/trip_expences_model.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ViewTripExpencesProvider extends ChangeNotifier {
  //object from trip-expences firebase class
  final TripExpencesFirebase _tripExpencesFirebaseClass =
      TripExpencesFirebase();
  List<TripExpencesModel> _tripExpences = [];
  //getting current user
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoadingTripExpencesResult = true;
  bool _isLoadingUpdatedDataSending = false;
  //getters
  bool get isLoadingTripViewExpences => _isLoadingTripExpencesResult;
  List<TripExpencesModel> get tripExpenceslist => _tripExpences;
  bool get isLoadingUpdatedDataSending => _isLoadingUpdatedDataSending;

  //function for getting data from firebase
  void loadTripDetails() async {
    try {
      _tripExpences = await _tripExpencesFirebaseClass.getTripsData();
      _isLoadingTripExpencesResult =
          false; // ← ADD THIS: reset loading at start
      notifyListeners();
    } catch (e) {
      print('Error loading trips: $e');
      _tripExpences = []; // empty list on error
    }
  }

  //function to the calculte the total of the expences
  double calculateTotalOfTheExpences(TripExpencesModel trip) {
    double total = 0;
    try {
      for (var expencesValue in trip.tripExpences) {
        int value = int.tryParse(expencesValue.expencesPrice) ?? 0;
        total += value;
      }
    } catch (e) {
      print('Fail to calculate total');
    }
    return total;
  }

  //function for delete a specific user
  Future<bool> deleteuserFromtripExpences(String id) async {
    try {
      await _tripExpencesFirebaseClass.deleteUserstripExpencesDocument(id);
      _tripExpences.removeWhere((trip) => trip.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  //function for sending updated data to the firebase file
  Future<bool> sendingUpdatedDataTheFireBaseFile(
    String id,
    TripExpencesModel updatedTrip,
  ) async {
    try {
      _isLoadingUpdatedDataSending = true;
      notifyListeners();
      // Firebase class ලදී function call කරනවා
      bool success = await _tripExpencesFirebaseClass
          .sendUpdatedDataToTheFirebase(id, updatedTrip);

      if (success) {
        // Local list එකත් update කරනවා
        // (Firebase ආයෙ fetch නොකර UI update වෙන්න)
        int index = _tripExpences.indexWhere((trip) => trip.id == id);
        if (index != -1) {
          _tripExpences[index] = updatedTrip;
          notifyListeners(); // ✅ UI refresh වෙනවා
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update error: $e');
      return false;
    } finally {
      _isLoadingUpdatedDataSending = false;
      notifyListeners();
    }
  }

  //function for sharing data via whatsap and email
  // PDF හදලා Share කරන function එක
  Future<void> shareTripDataAsPdf(TripExpencesModel trip) async {
    // 1️⃣ PDF document එකක් create කරනවා
    final pdf = pw.Document();

    // 🔥 Sinhala font load
    final fontData = await rootBundle.load("assets/fonts/NotoSansSinhala.ttf");
    final ttf = pw.Font.ttf(fontData);
    final textStyle = pw.TextStyle(font: ttf);
    final boldStyle = pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold);

    // 2️⃣ Total price calculate කරනවා
    double totalPrice = calculateTotalOfTheExpences(trip);

    // 3️⃣ PDF එකට page එකක් add කරනවා
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---- Title ----
              pw.Center(
                child: pw.Text(
                  'Trip Expenses Report',
                  style: boldStyle.copyWith(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // ---- Boat Number & Date ----
              pw.Text('Boat Number : ${trip.boatNumber}', style: textStyle),
              pw.SizedBox(height: 8),
              pw.Text(
                'Trip Start Date : ${trip.tripStartDate}',
                style: textStyle,
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // ---- Table Header ----
              pw.Text(
                'Expenses List',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // ---- Table ----
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Name column
                  1: const pw.FlexColumnWidth(1), // Price column
                },
                children: [
                  // Table Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Expense Name', style: boldStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price (Rs.)', style: boldStyle),
                      ),
                    ],
                  ),

                  // Data Rows - loop කරලා හැම expense එකක්ම add කරනවා
                  ...List.generate(trip.tripExpences.length, (index) {
                    final expencesCollectionWithNameandPrice =
                        trip.tripExpences[index];
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            expencesCollectionWithNameandPrice.expencesName,
                            style: textStyle,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            expencesCollectionWithNameandPrice.expencesPrice,
                            style: textStyle,
                          ),
                        ),
                      ],
                    );
                  }),

                  // Total Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.lightBlue50,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('TOTAL', style: boldStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Rs. ${totalPrice.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              // Footer
              pw.Center(
                child: pw.Text(
                  'Generated by Trip Expenses App',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 4️⃣ PDF file එක phone එකේ save කරනවා (temporary)
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/trip_expenses_${trip.boatNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    // 5️⃣ Share sheet එක open කරනවා (WhatsApp, Email, etc.)
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Trip Expenses - ${trip.boatNumber}',
        text:
            'Boat: ${trip.boatNumber}\nDate: ${trip.tripStartDate}\n\nPlease find the trip expenses PDF attached.',
      );
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('share error $e');
    }
  }
}
