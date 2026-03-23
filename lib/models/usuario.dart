class Usuario {
  final String id;
  final String nome;
  final int doacoesFeitas;
  final int vidasSalvas;

  const Usuario({
    required this.id,
    required this.nome,
    this.doacoesFeitas = 0,
    this.vidasSalvas = 0,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      doacoesFeitas: json['doacoesFeitas'] as int? ?? 0,
      vidasSalvas: json['vidasSalvas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'doacoesFeitas': doacoesFeitas,
      'vidasSalvas': vidasSalvas,
    };
  }

  Usuario copyWith({
    String? id,
    String? nome,
    int? doacoesFeitas,
    int? vidasSalvas,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      doacoesFeitas: doacoesFeitas ?? this.doacoesFeitas,
      vidasSalvas: vidasSalvas ?? this.vidasSalvas,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          doacoesFeitas == other.doacoesFeitas &&
          vidasSalvas == other.vidasSalvas;

  @override
  int get hashCode => Object.hash(id, nome, doacoesFeitas, vidasSalvas);
}
