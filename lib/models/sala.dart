import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Classe que representa o modelo da entidade Sala
class Sala {
  String? hash;
  String? descricao;
  String? hashCriador;
  List<String>? hashsParticipantes;
  bool? votacaoConcluida;
  Sala({
    this.hash,
    this.descricao,
    this.hashCriador,
    this.hashsParticipantes,
    this.votacaoConcluida,
  });

  Sala copyWith({
    String? hash,
    String? descricao,
    String? hashCriador,
    List<String>? hashsParticipantes,
    bool? votacaoConcluida,
  }) {
    return Sala(
      hash: hash ?? this.hash,
      descricao: descricao ?? this.descricao,
      hashCriador: hashCriador ?? this.hashCriador,
      hashsParticipantes: hashsParticipantes ?? this.hashsParticipantes,
      votacaoConcluida: votacaoConcluida ?? this.votacaoConcluida,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'descricao': descricao,
      'hashCriador': hashCriador,
      'hashsParticipantes': hashsParticipantes,
      'votacaoConcluida': votacaoConcluida,
    };
  }

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      hash: map['hash'],
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
    return 'Sala(hash: $hash, descricao: $descricao, hashCriador: $hashCriador, hashsParticipantes: $hashsParticipantes, votacaoConcluida: $votacaoConcluida)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sala &&
        other.hash == hash &&
        other.descricao == descricao &&
        other.hashCriador == hashCriador &&
        listEquals(other.hashsParticipantes, hashsParticipantes) &&
        other.votacaoConcluida == votacaoConcluida;
  }

  @override
  int get hashCode {
    return hash.hashCode ^ descricao.hashCode ^ hashCriador.hashCode ^ hashsParticipantes.hashCode ^ votacaoConcluida.hashCode;
  }
}
