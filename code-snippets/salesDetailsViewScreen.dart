
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:my_crud_app/pages/All-sales-details-view-screen/model/fish_buyer_full_details_view_model.dart';
import 'package:my_crud_app/pages/All-sales-details-view-screen/provider/sales_details_view_provider.dart';
import 'package:provider/provider.dart';

class SalesDetailsViewScreen extends StatefulWidget {
  const SalesDetailsViewScreen({super.key});

  @override
  State<SalesDetailsViewScreen> createState() => _SalesDetailsViewScreenState();
}

class _SalesDetailsViewScreenState extends State<SalesDetailsViewScreen> {
  @override
  void initState() {
    super.initState();
    loadSalesDetails();
  }

  void loadSalesDetails() {
    context.read<SalesDetailsViewProvider>().loadSalesDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Consumer<SalesDetailsViewProvider>(
          builder: (context, provider, child) {
            if (provider.loadingResult) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.grey,
                  strokeWidth: 8,
                ),
              );
            }
            // 2️⃣ List හිස්ද?
            if (provider.salesDetilsViewScreen.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'දත්ත නොමැත',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'තවම කිසිම විකුණුමක් එකතු කර නොමැත',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            // 3️⃣ Data තිබෙනවා නම් List පෙන්නනවා
            return ListView.builder(
              itemCount: provider.salesDetilsViewScreen.length,
              itemBuilder: (context, index) {
                FishBuyerFullDetailsViewModel fishDetailsView =
                    provider.salesDetilsViewScreen[index];
                return Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      debugPrint('button clicked');
                      context.pushNamed(
                        'EditDeleteShareSalesDetailsViewScreen',
                        extra: fishDetailsView,
                      );
                    },
                    onLongPress: () async {
                      final provider = context.read<SalesDetailsViewProvider>();
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete'),
                          content: Text(
                            'Are you Sure want to delete this trip',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        bool result = await provider.deleteaSpecifiRecord(
                          fishDetailsView.id,
                        );
                        if (result) {
                          Fluttertoast.showToast(msg: 'Delete succsfully');
                        } else {
                          Fluttertoast.showToast(msg: 'Fail to Delete');
                        }
                      }
                    },
                    child: ListTile(
                      title: Text(fishDetailsView.fishBuyerName),
                      subtitle: Text(fishDetailsView.fishSaleDate),
                      trailing: Text(fishDetailsView.boatNumberForSales),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
