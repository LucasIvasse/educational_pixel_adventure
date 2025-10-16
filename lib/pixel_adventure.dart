// Importa os pacotes necessários
import 'dart:async'; // Para operações assíncronas

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

// Classe principal do jogo que herda de FlameGame
// O "with" adiciona mixins (funcionalidades extras) ao jogo:
class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents, // Permite controle por teclado
        DragCallbacks, // Reconhece arrastar na tela
        HasCollisionDetection, // Detecta colisões entre objetos
        TapCallbacks {
  // Reconhece toques na tela

  // Define a cor de fundo do jogo (azul escuro)
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  // Componente de câmera que segue o jogador
  late CameraComponent cam;

  // Cria o jogador com o personagem 'Mask Dude'
  Player player = Player(character: 'Mask Dude');

  // Joystick para controle em dispositivos móveis
  late JoystickComponent joystick;

  // Controla se mostra os controles na tela
  bool showControls = false;

  // Configurações de áudio
  bool playSounds = true;
  double soundVolume = 1.0;

  // Lista com os nomes dos níveis do jogo
  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0; // Índice do nível atual

  // Método chamado quando o jogo é carregado
  @override
  FutureOr<void> onLoad() async {
    // Carrega todas as imagens do jogo na memória (cache), para reduzir o tempo de
    // carregamento
    await images.loadAllImages();

    // Carrega o nível inicial
    _loadLevel();

    // Se os controles estiverem ativados, adiciona joystick e botão de pulo
    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  // Método chamado a cada frame do jogo (atualização contínua)
  @override
  void update(double dt) {
    // dt = delta time (tempo desde o último frame)

    // Se os controles estiverem ativos, atualiza o joystick
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  // Método para adicionar o joystick na tela
  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10, // Prioridade de renderização (número maior = na frente)
      knob: SpriteComponent(
        // Parte móvel do joystick
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'), // Carrega imagem do knob
        ),
      ),
      background: SpriteComponent(
        // Base do joystick
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'), // Carrega imagem da base
        ),
      ),
      margin: const EdgeInsets.only(
          left: 32, bottom: 32), // Posição na tela, em pixels
    );

    add(joystick); // Adiciona o joystick ao jogo
  }

  // Atualiza o movimento do jogador baseado no joystick
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1; // Move para esquerda
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1; // Move para direita
        break;
      default:
        player.horizontalMovement = 0; // Para o movimento
        break;
    }
  }

  // Carrega o próximo nível do jogo
  void loadNextLevel() {
    // Remove todos os componentes do nível atual
    removeWhere((component) => component is Level);

    // Verifica se há mais níveis
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++; // Vai para o próximo nível
      _loadLevel();
    } else {
      // Se não há mais níveis, volta para o primeiro
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  // Método privado para carregar um nível
  void _loadLevel() {
    // Adiciona um pequeno delay antes de carregar o nível
    Future.delayed(const Duration(seconds: 1), () {
      // Cria o mundo/nível com o jogador e nome do nível
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      // Configura a câmera com resolução fixa
      cam = CameraComponent.withFixedResolution(
        world: world, // Mundo que a câmera vai seguir
        width: 640, // Largura da viewport
        height: 360, // Altura da viewport
      );
      cam.viewfinder.anchor =
          Anchor.topLeft; // Âncora no canto superior esquerdo

      // Adiciona a câmera e o mundo ao jogo
      addAll([cam, world]);
    });
  }
}

/*
* Mixins: 
São como "superpoderes" que adicionamos à classe. Cada with adiciona uma funcionalidade 
específica. 
*late: 
Indica que a variável será inicializada depois, mas o Dart confia que vamos fazer isso 
antes de usar.
*async/await: 
Permite que o jogo carregue recursos (imagens) sem travar.
*CameraComponent: 
É como os "olhos" do jogador, que segue o personagem pelo nível.
*JoystickDirection: 
São as 8 direções possíveis de um joystick (como os pontos cardeais).
*Future.delayed: 
Cria um pequeno atraso antes de executar uma ação.
*/
