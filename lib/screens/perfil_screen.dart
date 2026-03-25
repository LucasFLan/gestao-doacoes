import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../models/item_doacao.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/picked_image_widget.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StatsCards(
            doacoesRealizadas: state.usuario?.doacoesFeitas ?? 0,
            vidasImpactadas: state.usuario?.vidasSalvas ?? 0,
          ),
          const SizedBox(height: 32),
          _SectionTitle(title: 'Minhas doações'),
          const SizedBox(height: 12),
          if (state.minhasDoacoes.isEmpty)
            _EmptyDonationsCard()
          else
            _HistoricoDoacoes(itens: state.minhasDoacoes),
          const SizedBox(height: 32),
          _SectionTitle(title: 'Configurações'),
          const SizedBox(height: 12),
          _SettingsSection(),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Editar perfil'),
          const SizedBox(height: 12),
          _EditProfileSection(),
        ],
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  const _StatsCards({
    required this.doacoesRealizadas,
    required this.vidasImpactadas,
  });

  final int doacoesRealizadas;
  final int vidasImpactadas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.card_giftcard,
            label: 'Doações realizadas',
            value: '$doacoesRealizadas',
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite,
            label: 'Vidas impactadas',
            value: '$vidasImpactadas',
            color: Colors.red.shade400,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _EmptyDonationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma doação cadastrada',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre itens para doar e impactar vidas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push(AppRouter.cadastroItem),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar doação'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricoDoacoes extends StatelessWidget {
  const _HistoricoDoacoes({required this.itens});

  final List<ItemDoacao> itens;

  String _imageUrl(ItemDoacao item) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return item.imageUrl!;
    }
    return 'https://picsum.photos/seed/${item.id}/200/150';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < itens.length; i++) ...[
            _HistoricoTile(
              item: itens[i],
              imageUrl: _imageUrl(itens[i]),
            ),
            if (i < itens.length - 1)
              Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _HistoricoTile extends StatelessWidget {
  const _HistoricoTile({
    required this.item,
    required this.imageUrl,
  });

  final ItemDoacao item;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: buildPickedImage(imageUrl),
        ),
      ),
      title: Text(
        item.titulo,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${item.categoria} • ${item.estadoConservacao}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () => context.push(AppRouter.itemDetail, extra: item),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: const Text('Notificações'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: const Text('Modo escuro'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (enabled) => themeNotifier.setDarkMode(enabled),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Português'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _EditProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: const Text('Editar perfil'),
        subtitle: const Text('Nome, foto e informações pessoais'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Em breve: edição de perfil disponível'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
