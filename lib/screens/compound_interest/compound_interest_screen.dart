import 'package:flutter/material.dart';
import '../../widgets/app_text_field.dart';
import 'dart:math';
import '../../widgets/primary_button.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {

  //Controllers
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  double futureValue = 0.0;

  int frequency = 1;

  void  calculateCompoundInterest() {
    final double principal = double.tryParse(principalController.text) ?? 0;
    final double rate = double.tryParse(rateController.text) ?? 0;
    final double time = double.tryParse(timeController.text) ?? 0;
    
    // The Formula
    final double result = principal * pow(1 + (rate / 100)
    / frequency, frequency * time,);

    setState(() {
      futureValue = result;
      });
  }

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compound Interest"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Compound Interest Calculator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Calculate how your investments grow over time.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

          // Principal Amount Field
            const SizedBox(height: 30),

            AppTextField(
              controller: principalController,
              label: "Principal Amount",
              icon: Icons.account_balance_wallet,
              keyboardType: TextInputType.number,
            ),  

            const SizedBox(height: 20),

            // Interest Rate Field
            AppTextField(
              controller: rateController,
              label: "Annual Interest Rate (%)",
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Time Field
            AppTextField(
              controller: timeController,
              label: "Time (Years)",
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: "Calculate",
              icon: Icons.calculate,
              onPressed: calculateCompoundInterest,
            ),
          ],
        ),
      ),
    ); 
  }
}
              