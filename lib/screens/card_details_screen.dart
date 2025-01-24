import 'package:flutter/material.dart';
import 'package:nhis_card_scanner/widgets/card_info_widget.dart';
// import 'package:hospital_card_scanner/widgets/card_info_widget.dart';

class CardDetailsScreen extends StatelessWidget {
  final Map<String, String> cardDetails;

  CardDetailsScreen({required this.cardDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CardInfoWidget(title: 'Name', value: cardDetails['name'] ?? ''),
            CardInfoWidget(title: 'Date of Birth', value: cardDetails['dob'] ?? ''),
            CardInfoWidget(title: 'Membership No.', value: cardDetails['membership_no'] ?? ''),
            CardInfoWidget(title: 'Date of Issue', value: cardDetails['issue_date'] ?? ''),
            CardInfoWidget(title: 'Sex', value: cardDetails['sex'] ?? ''),
            CardInfoWidget(title: 'Expiry Date', value: cardDetails['expiry_date'] ?? ''),
          ],
        ),
      ),
    );
  }
}
