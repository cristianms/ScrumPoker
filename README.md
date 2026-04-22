# ScrumPoker

O ScrumPoker é um projeto em andamento de um aplicativo direcionado para times de desenvolvimento Scrum, tem o objetivo de facilitar as votações/pontuação das tarefas através de um planning poker virtual realtime.
Sinta-se a vontade para contribuir, sugestões e críticas construtivas serão bem vindas.

## Iniciando

O projeto é desenvolvido em Flutter portanto é necessário ter o ambiente Flutter instalado para contribuir.

<h4 align="center"> 
	🚧  ScrumPoker 🚀 Em construção...  🚧
</h4>

### Features
- [x] Cadastro de usuário
- [x] Autenticação normal(usuário e senha) ou via Google SignIn
- [x] Cadastro de sala da equipe
- [x] Compartilhamento de convite para uma sala
- [x] Exclusão de sala
- [x] Votação em tempo real
- [ ] Acesso para PO (espectador)
- [x] Possibilitar que um participante da votação possa remover outro da sessão
- [ ] Apresentação de resultado (destacar pontuação mais alta/mais baixa ou consenso)

### 🛠 Tecnologias
As seguintes ferramentas foram usadas na construção do projeto:
- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/?hl=pt-br)

Alguns fontes para ajudar caso seja novo no Flutter:
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

Documentação Flutter:
[online documentation](https://flutter.dev/docs)

#### Execução do projeto:
Para executar o projeto é necessário fazer o processo de criação e vinculação do aplicativo com o Firebase. O Firebase disponibiliza a [documentação necessária](https://firebase.google.com/docs/flutter/setup?hl=pt&platform=Android) para esses passos.
Caso tenha dúvidas não deixe de entrar em contato.

#### Vincular este projeto à sua conta Firebase
O projeto já usa `firebase_core`, `firebase_auth`, `cloud_firestore` e `firebase_storage`, então a vinculação correta depende de regenerar os arquivos de configuração do Firebase para o seu projeto.

Pré-requisitos instalados neste ambiente:
- Flutter SDK
- FlutterFire CLI (`flutterfire 1.3.2`)
- Firebase CLI instalada via winget

Passos:
1. Abra um terminal novo para garantir que o comando `firebase` esteja no `PATH`.
2. Faça login na sua conta Firebase:
```bash
firebase login
```
3. Na raiz do projeto, gere novamente a configuração do FlutterFire para o seu projeto:
```bash
flutterfire configure
```
4. Quando solicitado, selecione o projeto Firebase correto e as plataformas que deseja manter.
5. Para Android, confirme a criação do app com o pacote `br.com.cristiandemellos.scrumpoker`.
6. Se usar login com Google na Web, atualize também a meta tag `google-signin-client_id` em `web/index.html` com o Client ID Web do novo projeto.

Observações importantes:
- O arquivo `lib/firebase_options.dart` será reescrito pelo `flutterfire configure`.
- Em iOS e macOS, os arquivos `GoogleService-Info.plist` também devem passar a corresponder ao novo projeto.
- Em Android, este repositório já está preparado para aplicar o plugin `com.google.gms.google-services`, mas você ainda precisará do `google-services.json` gerado para o novo app Android.
- Se quiser publicar hosting/deploy web com Firebase, depois do login execute também `firebase use --add` para associar o projeto padrão local.

#### Deploy WEB
Após já ter realizado login e configurado um projeto WEB, executar os comandos:
1º executar o build
```dart
flutter build web
```
2º executar o deploy
```dart
firebase deploy
```

## MIT
### The MIT License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
