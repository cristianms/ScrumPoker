// @dart=2.9
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Classe que representa o modelo da entidade Sala
class Sala {
  String descricao;
  String hashCriador;
  List<String> hashsParticipantes;
  bool votacaoConcluida;

  /// Construtor
  Sala({
    this.descricao,
    this.hashCriador,
    this.hashsParticipantes,
    this.votacaoConcluida,
  });

  Sala copyWith({
    String descricao,
    String hashCriador,
    List<String> hashsParticipantes,
    bool votacaoConcluida,
  }) {
    return Sala(
      descricao: descricao ?? this.descricao,
      hashCriador: hashCriador ?? this.hashCriador,
      hashsParticipantes: hashsParticipantes ?? this.hashsParticipantes,
      votacaoConcluida: votacaoConcluida ?? this.votacaoConcluida,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'hashCriador': hashCriador,
      'hashsParticipantes': hashsParticipantes,
      'votacaoConcluida': votacaoConcluida,
    };
  }

  factory Sala.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Sala(
      descricao: map['descricao'],
      hashCriador: map['hashCriador'],
      hashsParticipantes: List<String>.from(map['hashsParticipantes']),
      votacaoConcluida: map['votacaoConcluida'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Sala.fromJson(String source) => Sala.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Sala(descricao: $descricao, hashCriador: $hashCriador, hashsParticipantes: $hashsParticipantes, votacaoConcluida: $votacaoConcluida)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Sala &&
        o.descricao == descricao &&
        o.hashCriador == hashCriador &&
        listEquals(o.hashsParticipantes, hashsParticipantes) &&
        o.votacaoConcluida == votacaoConcluida;
  }

  @override
  int get hashCode {
    return descricao.hashCode ^
        hashCriador.hashCode ^
        hashsParticipantes.hashCode ^
        votacaoConcluida.hashCode;
  }
}
