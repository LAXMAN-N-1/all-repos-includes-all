import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CustomReportBuilderScreen extends StatefulWidget {
  const CustomReportBuilderScreen({super.key});

  @override
  State<CustomReportBuilderScreen> createState() => _CustomReportBuilderScreenState();
}

class _CustomReportBuilderScreenState extends State<CustomReportBuilderScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Custom Report Builder'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) setState(() => _currentStep += 1);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                  child: Text(_currentStep == 3 ? 'Generate Report' : 'Next Step'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Select Report Type'),
            content: Column(
              children: [
                _buildRadioOption('Financial Report', 'Revenue, taxes, and payout data'),
                _buildRadioOption('Operational Report', 'Bookings, vendors, and customers'),
                _buildRadioOption('Custom Data', 'Combine multiple data sources'),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Data Sources & Fields'),
            content: Container(
              height: 200,
              color: Colors.grey[50],
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Expanded(child: Center(child: Text('Available Tables List...'))),
                  VerticalDivider(),
                  Expanded(child: Center(child: Text('Selected Fields...'))),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Filters & Grouping'),
             content: Column(
               children: [
                 const TextField(decoration: InputDecoration(labelText: 'Date Range', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today))),
                 const SizedBox(height: 16),
                 DropdownButtonFormField(items: const [], onChanged: (v){}, decoration: const InputDecoration(labelText: 'Group By', border: OutlineInputBorder())),
               ],
             ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Visualization & Schedule'),
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVizOption(Icons.table_chart, 'Table', true),
                    _buildVizOption(Icons.bar_chart, 'Bar Chart', false),
                    _buildVizOption(Icons.pie_chart, 'Pie Chart', false),
                  ],
                ),
                const SizedBox(height: 24),
                CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Email this report automatically')),
              ],
            ),
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.editing : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, String subtitle) {
    return RadioListTile(
      value: title, 
      groupValue: 'Custom Data', 
      onChanged: (v){},
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildVizOption(IconData icon, String label, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary50 : Colors.white,
        border: Border.all(color: selected ? AppTheme.primary600 : Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? AppTheme.primary600 : Colors.grey),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: selected ? AppTheme.primary600 : Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
