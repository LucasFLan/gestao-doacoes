class ItemDoacao {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;
  final String estadoConservacao;
  final String? imageUrl;
  final bool isLocalSync;

  const ItemDoacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.estadoConservacao,
    this.imageUrl,
    this.isLocalSync = false,
  });

  factory ItemDoacao.fromJson(Map<String, dynamic> json) {
    return ItemDoacao(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String,
      estadoConservacao: json['estadoConservacao'] as String,
      imageUrl: json['imageUrl'] as String?,
      isLocalSync: _parseBool(json['isLocalSync']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'estadoConservacao': estadoConservacao,
      'imageUrl': imageUrl,
      'isLocalSync': isLocalSync,
    };
  }

  ItemDoacao copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? categoria,
    String? estadoConservacao,
    String? imageUrl,
    bool? isLocalSync,
  }) {
    return ItemDoacao(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      estadoConservacao: estadoConservacao ?? this.estadoConservacao,
      imageUrl: imageUrl ?? this.imageUrl,
      isLocalSync: isLocalSync ?? this.isLocalSync,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemDoacao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          descricao == other.descricao &&
          categoria == other.categoria &&
          estadoConservacao == other.estadoConservacao &&
          imageUrl == other.imageUrl &&
          isLocalSync == other.isLocalSync;

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descricao,
    categoria,
    estadoConservacao,
    imageUrl,
    isLocalSync,
  );
}
