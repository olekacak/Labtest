import 'package:sqflite/sqflite.dart';
import '../Controller/BMIController.dart';
import '../Controller/sqlite_db.dart';

class BmiModel {
  static const String SQLiteTable = "bmi";
  String fullname;
  double height;
  double weight;
  String gender;
  String bmi_status;

  BmiModel(this.fullname, this.weight, this.height, this.gender, this.bmi_status);

  BmiModel.fromJson(Map<String, dynamic> json)
      : fullname = json['fullname'] as String,
        weight = double.parse(json['weight'].toString()),
        height = double.parse(json['height'].toString()),
        gender = json['gender'] as String,
        bmi_status = json['bmi_status'] as String;

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'weight': weight.toString(),
    'height': height.toString(),
    'gender': gender,
    'bmi_status': bmi_status,
  };

  Future<bool> save() async {
    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());

    // API Operation
    BmiController bmiController = BmiController(path: "/api/expenses.php");
    bmiController.setBody(toJson());
    await bmiController.post();

    if (bmiController.status() == 200) {
      return true;
    } else {
      // If API request fails, attempt to save to SQLite again
      return await SQLiteDB().insert(SQLiteTable, toJson()) != 0;
    }
  }

  static Future<List<BmiModel>> loadAll() async {

      List<Map<String, dynamic>> result = await SQLiteDB().queryAll(SQLiteTable);
      List<BmiModel> bmi = [];
      for (var item in result) {
        bmi.add(BmiModel.fromJson(item) as BmiModel);
      }

    return bmi;
  }
}
