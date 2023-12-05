  import 'package:flutter/material.dart';

  import '../Controller/BmiController.dart';
  import '../Model/BmiModel.dart';
  import '../Controller/sqlite_db.dart';

  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {


    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: const MainPage(),
      );
    }
  }

  class MainPage extends StatefulWidget {

    const MainPage({Key? key,}) : super(key: key);

    @override
    _MainPageState createState() => _MainPageState();
  }

  class _MainPageState extends State<MainPage> {
    final List<BmiModel> bmi = [];
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController bmi_statusController = TextEditingController();
    final TextEditingController totalBmiValue = TextEditingController();

    double averageBMIMale = 0.0;
    double averageBMIFemale = 0.0;
    int countMale = 0;
    int countFemale = 0;
    String? gender = '';
    double totalBmi = 0.0;

    @override
    void initState() {
      super.initState();
      loadData();
    }

    // Additional function to load data
    void loadData() async {
      bmi.addAll(await BmiModel.loadAll());
      print('cuba');

      if (bmi.isNotEmpty) {
        BmiModel latestBmi = bmi.last;
        print(latestBmi.fullname);
        setState(() {
          fullNameController.text = latestBmi.fullname;
          heightController.text = latestBmi.height.toString();
          weightController.text = latestBmi.weight.toString();
          gender = latestBmi.gender;
          bmi_statusController.text = latestBmi.bmi_status;
        });
      }
    }

    void calculateTotalBmi() async {

      List<BmiModel> bmiList = await BmiModel.loadAll();

      if (bmiList.isNotEmpty) {
        // Display the latest record
        BmiModel latestBmi = bmiList.last;
        setState(() {
          fullNameController.text = latestBmi.fullname;
          heightController.text = latestBmi.height.toString();
          weightController.text = latestBmi.weight.toString();
          gender = latestBmi.gender;
          bmi_statusController.text = latestBmi.bmi_status;
        });
      }

      if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
        // Existing code to calculate BMI and update controllers

        // Save the new BMI record
        BmiModel bmiModel = BmiModel(
          fullNameController.text,
          double.parse(weightController.text),
          double.parse(heightController.text),
          gender!,
          bmi_statusController.text,
        );

        if (await bmiModel.save()) {
          setState(() {
            fullNameController.text = '';
            heightController.text = '';
            weightController.text = '';
            gender = '';
            bmi_statusController.text = '';
          });
        }
        double height = double.parse(heightController.text);
        double weight = double.parse(weightController.text);

        setState(() {
          totalBmi = (weight / ((height/100) * (height/100)));
          totalBmiValue.text = totalBmi.toStringAsFixed(2);

        });


        if (gender == 'Male') {
          if (totalBmi < 18) {
            bmi_statusController.text = 'Underweight. Careful during strong wind!';
          } else if (totalBmi >= 18.5 && totalBmi < 24.9) {
            bmi_statusController.text = 'That’s ideal! Please maintain';
          } else if (totalBmi >= 25 && totalBmi < 30) {
            bmi_statusController.text = 'Overweight! Work out please';
          } else {
            bmi_statusController.text = 'Whoa Obese! Dangerous mate!';
          }
        }else{
          if (totalBmi < 16) {
            bmi_statusController.text = 'Underweight. Careful during strong wind!';
          } else if (totalBmi >= 16 && totalBmi < 22) {
            bmi_statusController.text = 'That’s ideal! Please maintain';
          } else if (totalBmi >= 22 && totalBmi < 27) {
            bmi_statusController.text = 'Overweight! Work out please';
          } else {
            bmi_statusController.text = 'Whoa Obese! Dangerous mate!';
          }
        }

        Map<String, dynamic> bmiData = {
          'username': fullNameController.text,
          'height': height,
          'weight': weight,
          'gender': gender,
          'bmi_status': bmi_statusController.text,
        };
    }
    }


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BMI Calculator'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: bmi_statusController,
                      decoration: InputDecoration(labelText: 'BMI Value'),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Male'),
                          value: 'male',
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'female',
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      calculateTotalBmi();
                    },
                    child: const Text('Calculate BMI'),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ('$gender' == 'male') ...[
                        Text('Male'),
                      ] else if ('$gender' == 'female') ...[
                        Text('Female'),
                      ],
                      const SizedBox(width: 8), // Add a SizedBox for spacing
                      Text('${bmi_statusController.text}'),
                    ],
                  ),
                  Column(
                    children: [
                      Column(
                        children: List.generate(
                          bmi.length,
                              (index) => ListTile(
                            title: Text('Name: ${bmi[index].fullname}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Height: ${bmi[index].height.toString()}'),
                                Text('Weight: ${bmi[index].weight.toString()}'),
                                Text('Gender: ${bmi[index].gender}'),
                                Text('BMI Status: ${bmi[index].bmi_status}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
