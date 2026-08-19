import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../data/models/app_settings.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(settingsControllerProvider);
    final core = ref.watch(coreControllerProvider);
    final settings = controller.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsGroup(
            title: 'General',
            children: [
              const SettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
              ),
              SettingsTile(
                icon: Icons.power_settings_new,
                title: 'Start on boot',
                trailing: Switch(
                  value: settings.startOnBoot,
                  onChanged: controller.setStartOnBoot,
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Switch(
                  value: settings.enableNotifications,
                  onChanged: controller.setNotifications,
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Network',
            children: [
              SettingsTile(
                icon: Icons.alt_route,
                title: 'Proxy mode',
                subtitle: settings.proxyMode.label,
                onTap: _showProxyModeDialog,
              ),
              SettingsTile(
                icon: Icons.tune,
                title: 'Mixed port',
                subtitle: '${settings.mixedPort}',
                onTap: _showPortDialog,
              ),
              SettingsTile(
                icon: Icons.language,
                title: 'IPv6',
                trailing: Switch(
                  value: settings.ipv6,
                  onChanged: (value) {
                    controller.setIPv6(value);
                    _syncCore();
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.settings_ethernet,
                title: 'System proxy',
                trailing: Switch(
                  value: settings.systemProxy,
                  onChanged: (value) {
                    controller.setSystemProxy(value);
                    _syncCore();
                  },
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Appearance',
            children: [
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: settings.themeMode.label,
                onTap: _showThemeDialog,
              ),
            ],
          ),
          SettingsGroup(
            title: 'About',
            children: [
              const SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '0.2.0',
              ),
              SettingsTile(
                icon: Icons.memory_outlined,
                title: 'Core backend',
                subtitle:
                    core.available
                        ? core.backendName
                        : '${core.backendName} bridge pending',
              ),
              const SettingsTile(
                icon: Icons.description_outlined,
                title: 'License',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final controller = ref.read(settingsControllerProvider);
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: const Text('Theme'),
            children:
                ThemeModeOption.values.map((mode) {
                  return SimpleDialogOption(
                    onPressed: () {
                      controller.setThemeMode(mode);
                      Navigator.pop(dialogContext);
                    },
                    child: Row(
                      children: [
                        if (controller.settings.themeMode == mode)
                          const Icon(Icons.check, size: 20)
                        else
                          const SizedBox(width: 20),
                        const SizedBox(width: 12),
                        Text(mode.label),
                      ],
                    ),
                  );
                }).toList(),
          ),
    );
  }

  void _showProxyModeDialog() {
    final controller = ref.read(settingsControllerProvider);
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: const Text('Proxy mode'),
            children:
                ProxyMode.values.map((mode) {
                  return SimpleDialogOption(
                    onPressed: () {
                      controller.setProxyMode(mode);
                      _syncCore();
                      Navigator.pop(dialogContext);
                    },
                    child: Row(
                      children: [
                        if (controller.settings.proxyMode == mode)
                          const Icon(Icons.check, size: 20)
                        else
                          const SizedBox(width: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(mode.label)),
                      ],
                    ),
                  );
                }).toList(),
          ),
    );
  }

  void _showPortDialog() {
    final settingsController = ref.read(settingsControllerProvider);
    final textController = TextEditingController(
      text: settingsController.settings.mixedPort.toString(),
    );
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Mixed port'),
            content: TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Port'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final port = int.tryParse(textController.text);
                  if (port != null && port > 0 && port < 65536) {
                    settingsController.setMixedPort(port);
                    _syncCore();
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _syncCore() {
    final settings = ref.read(settingsControllerProvider).settings;
    ref.read(coreControllerProvider).configure(settings);
  }
}
