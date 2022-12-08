// @dart=2.9
import 'dart:convert';

class Usuario {
  String hash;
  String nome;
  String email;
  String urlFoto;
  String senha;
  Usuario({
    this.hash,
    this.nome,
    this.email,
    this.urlFoto,
    this.senha,
  });

  Usuario copyWith({
    String hash,
    String nome,
    String email,
    String urlFoto,
    String senha,
  }) {
    return Usuario(
      hash: hash ?? this.hash,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      urlFoto: urlFoto ?? this.urlFoto,
      senha: senha ?? this.senha,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'nome': nome,
      'email': email,
      'urlFoto': urlFoto,
      'senha': senha,
    };
  }

  Map<String, dynamic> toMapWithoutPass() {
    return {
      'hash': hash,
      'nome': nome,
      'email': email,
      'urlFoto': urlFoto,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Usuario(
      hash: map['hash'],
      nome: map['nome'],
      email: map['email'],
      urlFoto: map['urlFoto'],
      senha: map['senha'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Usuario.fromJson(String source) => Usuario.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Usuario(hash: $hash, nome: $nome, email: $email, urlFoto: $urlFoto, senha: $senha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Usuario &&
      other.hash == hash &&
      other.nome == nome &&
      other.email == email &&
      other.urlFoto == urlFoto &&
      other.senha == senha;
  }

  @override
  int get hashCode {
    return hash.hashCode ^
      nome.hashCode ^
      email.hashCode ^
      urlFoto.hashCode ^
      senha.hashCode;
  }
}
