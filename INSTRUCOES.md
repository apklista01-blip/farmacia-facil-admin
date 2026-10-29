# Farmácia Fácil — Painel Admin

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

## Como criar o primeiro administrador

O login do painel só permite contas que existam na coleção `admins` do Firestore.

1. Acesse o [Firebase Console](https://console.firebase.google.com/) e abra o projeto `farmacia-facil-b980c`.
2. Vá em **Authentication → Users → Add user** e crie um usuário com e-mail e senha (ex.: `admin@farmacia.com`).
3. Copie o **UID** gerado para esse usuário.
4. Vá em **Firestore Database → Start collection** (ou adicione documento) na coleção `admins`.
5. Crie um documento com o **ID = UID** do usuário criado. O conteúdo pode ser vazio ou `{ "role": "admin" }`.
6. Volte ao app e faça login com o e-mail e senha criados.

## Funcionalidades

- Dashboard com totais de usuários, farmácias, pedidos e pedidos pendentes.
- Farmácias: listar, aprovar/rejeitar, ativar/desativar.
- Usuários: listar cadastrados.
- Pedidos: listar todos, filtrar por status.

## Estrutura de pastas

```
lib/
  main.dart
  firebase_options.dart
  app/        (theme, routes)
  models/     (user, pharmacy, order)
  providers/  (auth, users, pharmacies, orders)
  screens/    (auth, dashboard, pharmacies, users, orders)
  widgets/    (admin_shell)
```
