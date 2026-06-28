import 'package:flutter/material.dart';

import '../../../data/models/app_settings.dart';
import '../../../repositories/proxy_repository.dart';
import '../application/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ProxyRepositoryScope.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              _SettingsGroup(
                title: 'General',
                children: [
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.power_settings_new,
                    title: 'Start on boot',
                    trailing: Switch(
                      value: _controller.settings.startOnBoot,
                      onChanged: _controller.setStartOnBoot,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _controller.settings.enableNotifications,
                      onChanged: _controller.setNotifications,
                    ),
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Network',
                children: [
                  _SettingsTile(
                    icon: Icons.alt_route,
                    title: 'Proxy mode',
                    subtitle: repository.proxyMode.label,
                    onTap: _showProxyModeDialog,
                  ),
                  _SettingsTile(
                    icon: Icons.tune,
                    title: 'Mixed port',
                    subtitle: '${repository.mixedPort}',
                    onTap: _showPortDialog,
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'IPv6',
                    trailing: Switch(
                      value: _controller.settings.ipv6,
                      onChanged: _controller.setIPv6,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.settings_ethernet,
                    title: 'System proxy',
                    trailing: Switch(
                      value: repository.systemProxyEnabled,
                      onChanged: (v) {
                        _showReconnectWarning(
                          () {
                            _controller.setSystemProxy(v);
                            repository.setSystemProxyEnabled(v);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Appearance',
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    subtitle: _controller.settings.themeMode.label,
                    onTap: _showThemeDialog,
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'About',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '0.1.0',
                  ),
                  _SettingsTile(
                    icon: Icons.update,
                    title: 'Check for updates',
                    onTap: () {},
                  ),
                  _SettingsTile(
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
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Theme'),
        children: ThemeModeOption.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              _controller.setThemeMode(mode);
              Navigator.pop(dialogContext);
            },
            child: Row(
              children: [
                if (_controller.settings.themeMode == mode)
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
                  _controller.setProxyMode(mode);
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
                _controller.setMixedPort(port);
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...children,
        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
