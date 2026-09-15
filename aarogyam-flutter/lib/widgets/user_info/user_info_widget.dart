import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'user_info_model.dart';
export 'user_info_model.dart';

class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  late UserInfoModel _model;

  @override
  void initState() {
    super.initState();
    _model = UserInfoModel();
    _model.init(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 44,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Initialise local state from AppState on first build
    _model.dropDownValue ??=
        appState.genderValue.isNotEmpty ? appState.genderValue : null;
    _model.countControllerValue1 ??= appState.ageValue;
    _model.countControllerValue2 ??=
        appState.heightValue > 0 ? appState.heightValue : 150;
    _model.countControllerValue3 ??=
        appState.weightValue > 0 ? appState.weightValue : 50;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Gender
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gender', style: Theme.of(context).textTheme.bodyLarge),
              DropdownButton<String>(
                value: _model.dropDownValue,
                hint: const Text('Gender'),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) {
                  setState(() => _model.dropDownValue = val);
                  if (val != null) appState.genderValue = val;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Age
          _buildCounterRow(
            label: 'Age',
            value: _model.countControllerValue1!,
            min: 1,
            max: 150,
            onChanged: (v) {
              setState(() => _model.countControllerValue1 = v);
              appState.ageValue = v;
            },
          ),
          const SizedBox(height: 24),
          // Height
          _buildCounterRow(
            label: 'Height (cm)',
            value: _model.countControllerValue2!,
            min: 50,
            max: 250,
            onChanged: (v) {
              setState(() => _model.countControllerValue2 = v);
              appState.heightValue = v;
            },
          ),
          const SizedBox(height: 24),
          // Weight
          _buildCounterRow(
            label: 'Weight (kg)',
            value: _model.countControllerValue3!,
            min: 30,
            max: 150,
            onChanged: (v) {
              setState(() => _model.countControllerValue3 = v);
              appState.weightValue = v;
            },
          ),
          const SizedBox(height: 24),
          // Allergies
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Allergies (if any)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () => context.pushNamed('Allergies'),
          ),
        ],
      ),
    );
  }
}
