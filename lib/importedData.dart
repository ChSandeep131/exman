// import 'package:flutter/material.dart';

// class ImportedData extends StatelessWidget {
//   final List csvData;
//   const ImportedData({super.key, required this.csvData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Imported Data"),
//       ),
//       body: ListView.builder(
//           itemCount: csvData.length - 1,
//           itemBuilder: (context, index) {
//             final rowData = csvData[index + 1];
//             return Card(
//               margin: EdgeInsets.all(15),
//               child: ListTile(
//                   title: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Item: ${rowData[0]}"),
//                   Text("merchant: ${rowData[1]}"),
//                   Text("price: ${rowData[2]}"),
//                   Text("Payment: ${rowData[3]}"),
//                   Text("category: ${rowData[4]}"),
//                 ],
//               )),
//             );
//           }),
//     );
//   }
// }
