import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'DBHelper.dart';
import 'pojo.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _expenseData = [];
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _getData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController merchantNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController idController = TextEditingController();

  //Relative to pie chart data
  Map<String, double> dataMap = {
    "Food": 0,
    "Grocery": 0,
    "Stationery": 0,
    "Team Building": 0,
    "Software Tool": 0,
    "Office Maintenance": 0,
    "Computer & Mobile Hardware": 0,
    "Others/Miscellaneous": 0,
  };

  List<Map<String, dynamic>> dataMap1 = [
    {'category': 'Food', 'value': 0.0},
    {'category': 'Grocery', 'value': 0.0},
    {'category': 'Stationery', 'value': 0.0},
    {'category': 'Team Building', 'value': 0.0},
    {'category': 'Software Tool', 'value': 0.0},
    {'category': 'Office Maintenance', 'value': 0.0},
    {'category': 'Computer & Mobile Hardware', 'value': 0.0},
    {'category': 'Others/Miscellaneous', 'value': 0.0},
  ];

  void updatePieChart() {
    // Clear the dataMap
    dataMap.clear();

    for (var expense in _expenseData) {
      String category = expense["category"];
      double price = expense["price"] ?? 0.0;

      // Check if the category already exists in dataMap
      if (dataMap.containsKey(category)) {
        dataMap[category] = (dataMap[category] ?? 0) + price;
      } else {
        dataMap[category] = price;
      }
    }

    // Update dataMap1 with the newly calculated values
    dataMap1.clear();
    for (var category in dataMap.keys) {
      dataMap1.add({'category': category, 'value': dataMap[category]});
    }

    setState(() {});
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var expense in _expenseData) {
      double? price = expense["price"];
      if (price != null) {
        totalAmount += price;
      }
    }
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              exportToCSV();
            },
            child: const Text("export"),
          ),
          ElevatedButton(
            onPressed: () {
              importCSV();
            },
            child: const Text("import"),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: SfCircularChart(
              // title: ChartTitle(text: "Expenses in Rupees"),
              tooltipBehavior: _tooltipBehavior,
              legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom),
              series: <CircularSeries>[
                PieSeries<Map<String, dynamic>, String>(
                  enableTooltip: true,
                  dataSource: dataMap1,
                  xValueMapper: (Map<String, dynamic> data, _) =>
                      data['category'],
                  yValueMapper: (Map<String, dynamic> data, _) => data['value'],
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 3,
          ),
          const Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Expenses",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total Amount: ₹${calculateTotalAmount().toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _expenseData.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time: ${_expenseData[index]["ctime"]}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Item name: ',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: _expenseData[index]["item"],
                                            style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                          text: 'Merchant Name: ',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: _expenseData[index]
                                                  ["merchant"],
                                              style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 14),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: 'price: ',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: _expenseData[index]["price"]
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 14),
                                            )
                                          ]),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                          text: 'payment: ',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: _expenseData[index]
                                                  ["payment"],
                                              style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 14),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              //mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showBottomSheet(_expenseData[index]["id"]);
                                  },
                                  icon: const Icon(Icons.edit),
                                  color: Colors.indigo,
                                ),
                                IconButton(
                                  onPressed: () {
                                    _deleteData(_expenseData[index]["id"]);
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.redAccent,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'category: ',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: _expenseData[index]
                                                ["category"],
                                            style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 14),
                                          )
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBottomSheet(null),
        label: const Text("Add Expences"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  //SQFlite crud operations
  //Reading data
  void _getData() async {
    final data = await DbHelper.getData();
    setState(() {
      _expenseData = data;
      updatePieChart();
    });
    print(_expenseData);
  }

  //Creating Data
  Future<void> _addData() async {
    String item = itemNameController.text;
    String merchant = merchantNameController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;
    String payment = paymentController.text;
    String category = categoryController.text;
    DateTime myDate = DateTime.now(); // Replace this with your desired date
    String ctime = DateFormat('dd-MM-yyyy HH:mm').format(myDate);

    Map<String, dynamic> dataMap = Pojo(
      item: item,
      merchant: merchant,
      price: price,
      payment: payment,
      category: category,
      ctime: ctime,
    ).toMap();

    await DbHelper.createData(dataMap);
    _getData();
    updatePieChart();
    print(dataMap);
  }

  //Updating the data
  Future<void> _updateData(int id) async {
    int parsedId = int.parse(idController.text);
    String item = itemNameController.text;
    String password = merchantNameController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;
    String payment = paymentController.text;
    String category = categoryController.text;
    DateTime myDate = DateTime.now(); // Replace this with your desired date
    String ctime = DateFormat('dd-MM-yyyy HH:mm').format(myDate);
    Map<String, dynamic> dataMap = Pojo(
      id: parsedId,
      item: item,
      merchant: password,
      price: price,
      payment: payment,
      category: category,
      ctime: ctime,
    ).toMap();

    await DbHelper.updateData(dataMap);
    _getData();
    updatePieChart();
  }

  //Delecting the data
  Future<void> _deleteData(int? id) async {
    // Update the parameter type to int?
    if (id != null) {
      await DbHelper.deleteData(id);
      _getData();
    } else {
      print("Invalid id");
    }
  }

  //List for Dropdown
  List items = [
    "Food",
    "Grocery",
    "Stationery",
    "Team Building",
    "Software Tool",
    "Office Maintenance",
    "Computer & Mobile Hardware",
    "Others/Miscellaneous",
  ];
  String selectedItem = "";

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _expenseData.firstWhere((element) => element['id'] == id);
      itemNameController.text = existingData['item'];
      merchantNameController.text = existingData['merchant'];
      priceController.text = existingData['price'].toString();
      paymentController.text = existingData['payment'];
      categoryController.text = existingData['category'];
      idController.text = id.toString();
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Item name",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: merchantNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Merchant Name",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: priceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Amount",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: paymentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Mode of payment",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: categoryController,
              readOnly: true, // Make it read-only
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Category",
                suffixIcon: DropdownButton(
                  //value: selectedItem,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedItem = newValue.toString();
                      categoryController.text = newValue.toString();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addData();
                    }
                    if (id != null) {
                      await _updateData(id);
                    }
                    itemNameController.text = "";
                    merchantNameController.text = "";
                    priceController.text = "";
                    paymentController.text = "";
                    categoryController.text = "";
                    Navigator.of(context).pop();
                    print("Data");
                  },
                  child: Padding(
                    padding:const EdgeInsets.all(18),
                    child: Text(
                      id == null ? "Add Data" : "Update",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportToCSV() async {
    List<List<dynamic>> csvData = [];

    csvData.add(
        ["Item", "Merchant Name", "Price", "Payment", "Category", "ctime"]);

    for (var expense in _expenseData) {
      csvData.add([
        expense["item"],
        expense["merchant"],
        expense["price"],
        expense["payment"],
        expense["category"],
        expense["ctime"],
      ]);
    }

    final String csv = const ListToCsvConverter().convert(csvData);

    final String path = (await getExternalStorageDirectory())!.path;

    final String filepath = "$path/android.csv";

    await File(filepath).writeAsString(csv);

    print(filepath);
    // ignore: use_build_context_synchronously
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Csv file Is imported",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Path: ${filepath}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String csvText = await File(file.path!).readAsString();

      List csvData = CsvToListConverter().convert(csvText);
      print(csvData);

      csvData.removeAt(0);

      for (var row in csvData) {
        String item = row[0];
        String merchant = row[1];
        double price = double.tryParse(row[2].toString()) ?? 0.0;
        String payment = row[3];
        String category = row[4];
        String ctime = row[5];

        bool entryExists = _expenseData.any(
            (expense) => expense["item"] == item && expense["ctime"] == ctime);

        if (!entryExists) {
          Map<String, dynamic> dataMap = Pojo(
            item: item,
            merchant: merchant,
            price: price,
            payment: payment,
            category: category,
            ctime: ctime,
          ).toMap();

          await DbHelper.createData(dataMap);
          _getData();
        }
      }
    } else {}
  }
}
