// @dart=2.9
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Votacao &&
      other.hashSala == hashSala &&
      other.hashUsuario == hashUsuario &&
      other.nota == nota;
  }

  @override
  int get hashCode => hashSala.hashCode ^ hashUsuario.hashCode ^ nota.hashCode;
}
