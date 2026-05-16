import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create New Campaign'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () { if (_currentStep < 4) setState(() => _currentStep++); },
        onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep--); },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                child: Text(_currentStep == 4 ? 'Launch Campaign' : 'Continue'),
              ),
              if (_currentStep > 0) ...[const SizedBox(width: 12), TextButton(onPressed: details.onStepCancel, child: const Text('Back'))],
            ],
          ),
        ),
        steps: [
          Step(title: const Text('Basics'), content: _buildBasicsStep(), isActive: _currentStep >= 0),
          Step(title: const Text('Target'), content: _buildTargetStep(), isActive: _currentStep >= 1),
          Step(title: const Text('Offer'), content: _buildOfferStep(), isActive: _currentStep >= 2),
          Step(title: const Text('Channels'), content: _buildChannelsStep(), isActive: _currentStep >= 3),
          Step(title: const Text('Review'), content: _buildReviewStep(), isActive: _currentStep >= 4),
        ],
      ),
    );
  }

  Widget _buildBasicsStep() {
    return const Column(
      children: [
        TextField(decoration: InputDecoration(labelText: 'Campaign Name', hintText: 'e.g. Summer Wedding Carnival', border: OutlineInputBorder())),
        SizedBox(height: 16),
        TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
        SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(decoration: InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()))),
          SizedBox(width: 16),
          Expanded(child: TextField(decoration: InputDecoration(labelText: 'End Date', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()))),
        ]),
      ],
    );
  }

  Widget _buildTargetStep() {
    return Column(
      children: [
        CheckboxListTile(value: true, onChanged: (v){}, title: const Text('All Customers')),
        CheckboxListTile(value: false, onChanged: (v){}, title: const Text('New Customers (< 3 months)')),
        const Divider(),
        const Text('Category Interest', style: TextStyle(fontWeight: FontWeight.bold)),
        CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Weddings')),
        CheckboxListTile(value: false, onChanged: (v){}, title: const Text('Corporate')),
      ],
    );
  }

  Widget _buildOfferStep() {
    return const Column(
      children: [
         TextField(decoration: InputDecoration(labelText: 'Discount Percentage (%)', border: OutlineInputBorder())),
         SizedBox(height: 16),
         TextField(decoration: InputDecoration(labelText: 'Min Booking Amount', prefixText: '₹ ', border: OutlineInputBorder())),
         SizedBox(height: 16),
         TextField(decoration: InputDecoration(labelText: 'Max Discount Cap', prefixText: '₹ ', border: OutlineInputBorder())),
         SizedBox(height: 16),
         TextField(decoration: InputDecoration(labelText: 'Coupon Code', hintText: 'Auto-generated or Custom', border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildChannelsStep() {
    return Column(
      children: [
        SwitchListTile(value: true, onChanged: (v){}, title: const Text('Push Notification'), subtitle: const Text('Cost: ₹5,000')),
        SwitchListTile(value: true, onChanged: (v){}, title: const Text('Email Marketing'), subtitle: const Text('Cost: ₹8,000')),
        SwitchListTile(value: false, onChanged: (v){}, title: const Text('SMS Campaign'), subtitle: const Text('Cost: ₹12,000')),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campaign Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16),
          Text('Name: Summer Wedding Carnival'),
          Text('Target: 18,500 Users (Weddings)'),
          Text('Channels: Push, Email'),
          Divider(),
          Text('Total Investment: ₹2,08,000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
          Text('Projected ROI: 3,500%', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}
