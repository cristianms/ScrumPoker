import 'dart:convert';

class Votacao {
  String hashSala;
  String hashUsuario;
  int nota;
  Votacao({
    this.hashSala,
    this.hashUsuario,
    this.nota,
  });

  Votacao copyWith({
    String hashSala,
    String hashUsuario,
    int nota,
  }) {
    return Votacao(
      hashSala: hashSala ?? this.hashSala,
      hashUsuario: hashUsuario ?? this.hashUsuario,
      nota: nota ?? this.nota,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hashSala': hashSala,
      'hashUsuario': hashUsuario,
      'nota': nota,
    };
  }

  factory Votacao.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Votacao(
      hashSala: map['hashSala'],
      hashUsuario: map['hashUsuario'],
      nota: map['nota'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Votacao.fromJson(String source) => Votacao.fromMap(json.decode(source));

  @override
  String toString() => 'Votacao(hashSala: $hashSala, hashUsuario: $hashUsuario, nota: $nota)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Votacao &&
      o.hashSala == hashSala &&
      o.hashUsuario == hashUsuario &&
      o.nota == nota;
  }

  @override
  int get hashCode => hashSala.hashCode ^ hashUsuario.hashCode ^ nota.hashCode;
}
