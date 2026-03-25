import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../models/item_doacao.dart';
import '../providers/donation_provider.dart';
import '../services/image_picker_helper.dart';
import '../widgets/picked_image_widget.dart';

class CadastroDoacaoScreen extends ConsumerStatefulWidget {
  const CadastroDoacaoScreen({super.key});

  @override
  ConsumerState<CadastroDoacaoScreen> createState() =>
      _CadastroDoacaoScreenState();
}

class _CadastroDoacaoScreenState extends ConsumerState<CadastroDoacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  String? _categoria;
  String? _estadoConservacao;
  String? _imagePath;
  bool _isSaving = false;

  static const List<String> _categorias = [
    'Roupas',
    'Eletrônicos',
    'Móveis',
    'Livros',
    'Esportes',
    'Brinquedos',
    'Outros',
  ];

  static const List<String> _estadosConservacao = [
    'Novo',
    'Bom',
    'Regular',
    'Usado',
    'Recuperável',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    if (kIsWeb) {
      setState(() {
        _imagePath = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Imagem simulada (ambiente web)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final path = await pickImagePathFromGallery();
    if (path != null && mounted) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _salvarDoacao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoria == null || _estadoConservacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione a categoria e o estado de conservação'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final item = ItemDoacao(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoria!,
      estadoConservacao: _estadoConservacao!,
      imageUrl: _imagePath,
      isLocalSync: true,
    );

    try {
      await ref.read(donationFeedProvider.notifier).cadastrarItem(item);

      if (!mounted) return;
      context.go(AppRouter.home);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Doação cadastrada com sucesso!'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao salvar doação. Tente novamente.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Doação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ImagePickerButton(
              imagePath: _imagePath,
              onTap: _selecionarImagem,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Sofá 3 lugares',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o título';
                }
                if (v.trim().length < 3) {
                  return 'O título deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva o item em detalhes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe a descrição';
                }
                if (v.trim().length < 10) {
                  return 'A descrição deve ter pelo menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: _categorias.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (v) => setState(() => _categoria = v),
              validator: (v) =>
                  v == null ? 'Selecione a categoria' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _estadoConservacao,
              decoration: InputDecoration(
                labelText: 'Estado de conservação',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.verified_outlined),
              ),
              items: _estadosConservacao.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => setState(() => _estadoConservacao = v),
              validator: (v) =>
                  v == null ? 'Selecione o estado de conservação' : null,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isSaving ? null : _salvarDoacao,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Doação'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.imagePath,
    required this.onTap,
  });

  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: buildPickedImage(imagePath!),
              )
            : const _PlaceholderContent(),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Toque para adicionar imagem',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
