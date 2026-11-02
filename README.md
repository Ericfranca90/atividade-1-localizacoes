# Atividade 1 - Coleta e visualização de localizações

Aplicativo Flutter desenvolvido para a disciplina Programação para Dispositivos
Móveis I. O aplicativo coleta posições do dispositivo, armazena os registros
localmente e permite consultá-los em uma lista e em um mapa.

## Integrantes

- Eric França Arantes dos Santos

## Funcionalidades

- Iniciar e interromper a coleta de localização.
- Continuar a coleta ao navegar entre as telas ou minimizar o aplicativo.
- Armazenar latitude, longitude, precisão e instante em um banco SQLite.
- Apresentar as últimas 100 localizações no histórico.
- Atualizar e limpar todo o histórico.
- Mostrar as últimas 100 posições em um mapa interativo.
- Utilizar cache local para as imagens do mapa.
- Manter uma notificação visível durante a coleta em segundo plano.

## Tecnologias

- Flutter e Dart.
- `geolocator` para permissões e coleta das posições.
- `permission_handler` para solicitar a permissão de notificações.
- `sqflite` para persistência local.
- `flutter_map` para o mapa interativo.
- OpenStreetMap como provedor das imagens do mapa.

## Como executar

1. Conecte um dispositivo Android com a depuração USB habilitada.
2. Na pasta do projeto, execute `flutter pub get`.
3. Execute `flutter run`.
4. Autorize o acesso à localização e às notificações quando solicitado.

O funcionamento em segundo plano, a notificação e o ícone devem ser conferidos
em um dispositivo Android real.

## Privacidade

O banco `localizacoes.db` é criado na área privada do aplicativo. Bancos locais
e coordenadas pessoais não devem ser enviados ao repositório.
