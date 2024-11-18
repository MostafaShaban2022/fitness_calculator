import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences? _prefs;
  num _height = 0, _weight = 0, _bmi = 0;
  List<String> _bmiHistory = <String>[];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _height = _prefs?.getDouble('last_input_height') ?? 0;
      _weight = _prefs?.getDouble('last_input_weight') ?? 0;
      _bmiHistory = _prefs?.getStringList('bmi_history') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _prefs == null ? _loadingIndicator() : _buildUI(),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bmiDisplay(),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _weightInput(),
              _heightInput(),
            ],
          ),
          _calculateBMIButton(),
          _bmiHistoryList(),
        ],
      ),
    );
  }

  Widget _bmiDisplay() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: Text(
          '${_bmiHistory.isNotEmpty ? _bmiHistory.last : '0.00'} BMI',
          style: const TextStyle(
            fontSize: 30,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _weightInput() {
    return Column(
      children: [
        const Text(
          'Weight',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7.5),
        InputQty(
          maxVal: double.infinity,
          initVal: _weight,
          minVal: 0,
          steps: 1,
          onQtyChanged: (value) {
            setState(() {
              _weight = value;
              _prefs?.setDouble('last_input_weight', _weight.toDouble());
            });
          },
        ),
      ],
    );
  }

  Widget _heightInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Column(
        children: [
          const Text(
            'Height',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7.5),
          InputQty(
            maxVal: double.infinity,
            initVal: _height,
            minVal: 0,
            steps: 1,
            onQtyChanged: (value) {
              setState(() {
                _height = value;
                _prefs?.setDouble('last_input_height', _height.toDouble());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _calculateBMIButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: MaterialButton(
          onPressed: _calculateBMI,
          color: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Calculate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _calculateBMI() {
    if (_height == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Height must be greater than 0")),
      );
      return;
    }

    double heightInMeters = _height / 100;
    double calculatedBMI = _weight / pow(heightInMeters, 2);

    if (kDebugMode) {
      print("Calculated BMI: $calculatedBMI");
    }

    setState(() {
      _bmi = calculatedBMI;
      _bmiHistory.add(_bmi.toStringAsFixed(2));
      _prefs?.setStringList('bmi_history', _bmiHistory);
    });
  }

  Widget _bmiHistoryList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _bmiHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _bmiHistory[index],
              style: const TextStyle(fontSize: 15),
            ),
            onLongPress: () {
              setState(() {
                _bmiHistory.removeAt(index);
                _prefs?.setStringList('bmi_history', _bmiHistory);
              });
            },
          );
        },
      ),
    );
  }
}
