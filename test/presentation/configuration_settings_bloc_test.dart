import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';
import 'package:vanguard_crisis_response/presentation/configuration_settings_screen/bloc/configuration_settings_bloc.dart';

void main() {
  group('ConfigurationSettingsBloc Tests', () {
    late ConfigurationSettingsBloc bloc;
    
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      bloc = ConfigurationSettingsBloc(ConfigurationSettingsState());
    });

    tearDown(() {
      bloc.close();
    });

    test('initializes cleanly', () async {
      bloc.add(ConfigurationSettingsInitialEvent());
      await Future.delayed(Duration.zero);
      expect(bloc.state.meshNetworkConfig.maxHops, 3);
    });

    test('valid update saves new config', () async {
      bloc.add(UpdateMaxHopsEvent(maxHops: 4));
      await Future.delayed(Duration.zero);
      expect(bloc.state.meshNetworkConfig.maxHops, 4);
      expect(bloc.state.validationError, null);
    });

    test('invalid update triggers validation error', () async {
      bloc.add(UpdateMaxHopsEvent(maxHops: 10)); // max is 5
      await Future.delayed(Duration.zero);
      expect(bloc.state.validationError, isNotNull);
      expect(bloc.state.meshNetworkConfig.maxHops, 3); // Kept original
    });
  });
}
