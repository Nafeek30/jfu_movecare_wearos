import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class UtilityController {
  /// Creates a csv file using the accelerometer and gyroscope data to create rows in the csv file
  Future<File> createCSVFile(List<List<dynamic>> rows, String filename) async {
    // Convert our data to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Save the CSV data to a file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/$filename.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    return file;
  }
}
