import 'package:flutter/material.dart';

import '../../../data/models/app_settings.dart';
import '../../../repositories/proxy_repository.dart';
import '../application/settings_controller.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final repository = ProxyRepositoryScope.of(context);
    final controller = SettingsControllerScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              SettingsGroup(
                title: 'General',
                children: [
                  SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.power_settings_new,
                    title: 'Start on boot',
                    trailing: Switch(
                      value: controller.settings.startOnBoot,
                      onChanged: controller.setStartOnBoot,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: Switch(
                      value: controller.settings.enableNotifications,
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
                    subtitle: repository.proxyMode.label,
                    onTap: _showProxyModeDialog,
                  ),
                  SettingsTile(
                    icon: Icons.tune,
                    title: 'Mixed port',
                    subtitle: '${repository.mixedPort}',
                    onTap: _showPortDialog,
                  ),
                  SettingsTile(
                    icon: Icons.language,
                    title: 'IPv6',
                    trailing: Switch(
                      value: controller.settings.ipv6,
                      onChanged: controller.setIPv6,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.settings_ethernet,
                    title: 'System proxy',
                    trailing: Switch(
                      value: repository.systemProxyEnabled,
                      onChanged: (v) {
                        _showReconnectWarning(
                          () {
                            controller.setSystemProxy(v);
                            repository.setSystemProxyEnabled(v);
                          },
                        );
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
                    subtitle: controller.settings.themeMode.label,
                    onTap: _showThemeDialog,
                  ),
                ],
              ),
              SettingsGroup(
                title: 'About',
                children: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '0.1.0',
                  ),
                  SettingsTile(
                    icon: Icons.update,
                    title: 'Check for updates',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'License',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    final controller = SettingsControllerScope.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Theme'),
        children: ThemeModeOption.values.map((mode) {
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
    final repository = ProxyRepositoryScope.of(context);
    final controller = SettingsControllerScope.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Proxy mode'),
        children: ProxyMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showReconnectWarning(
                () {
                  controller.setProxyMode(mode);
                  repository.setProxyMode(mode);
                },
              );
            },
            child: Row(
              children: [
                if (repository.proxyMode == mode)
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
    final repository = ProxyRepositoryScope.of(context);
    final settingsController = SettingsControllerScope.of(context);
    final controller = TextEditingController(
      text: repository.mixedPort.toString(),
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mixed port'),
        content: TextField(
          controller: controller,
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
              final port = int.tryParse(controller.text);
              if (port != null && port > 0 && port < 65536) {
                settingsController.setMixedPort(port);
                repository.updateEndpoint(
                  listenAddress: repository.listenAddress,
                  mixedPort: port,
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReconnectWarning(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reconnect required'),
        content: const Text(
          'Changing this setting requires reconnecting the proxy. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogContext);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
