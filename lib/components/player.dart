// Importa os pacotes necessários
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart'; // Para input do teclado
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum que define todos os estados possíveis do jogador
enum PlayerState {
  idle, // Parado
  running, // Correndo
  jumping, // Pulando (subindo)
  falling, // Caindo (descendo)
  hit, // Tomando dano
  appearing, // Aparecendo (spawn)
  disappearing // Desaparecendo (checkpoint)
}

// Classe principal do jogador - o personagem controlado pelo jogador
class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character; // Tipo do personagem (Ninja Frog, Mask Dude, etc.)
  Player({
    position,
    this.character = 'Ninja Frog', // Personagem padrão
  }) : super(position: position);

  // Configurações de animação
  final double stepTime = 0.05;

  // Todas as animações do jogador
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  // Física do jogo
  final double _gravity = 9.8; // Força da gravidade
  final double _jumpForce = 260; // Força do pulo
  final double _terminalVelocity = 300; // Velocidade máxima de queda
  double horizontalMovement = 0; // Movimento horizontal (-1, 0, 1)
  double moveSpeed = 100; // Velocidade de movimento
  Vector2 startingPosition = Vector2.zero(); // Posição inicial para respawn
  Vector2 velocity = Vector2.zero(); // Velocidade atual (x, y)

  // Estados do jogador
  bool isOnGround = false; // Se está no chão
  bool hasJumped = false; // Se o jogador apertou para pular
  bool gotHit = false; // Se acabou de tomar dano
  bool reachedCheckpoint = false; // Se atingiu um checkpoint

  List<CollisionBlock> collisionBlocks = []; // Blocos de colisão do nível

  // Hitbox personalizada - área de colisão menor que o sprite visual
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10, // 10 pixels da esquerda
    offsetY: 4, // 4 pixels do topo
    width: 14, // Largura de 14 pixels
    height: 28, // Altura de 28 pixels
  );

  // Sistema de física com tempo fixo para consistência
  double fixedDeltaTime = 1 / 60; // 60 FPS
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // Carrega todas as animações
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y); // Salva posição inicial

    // Adiciona a hitbox de colisão retangular
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  // Método chamado a cada frame - usa física com tempo fixo
  @override
  void update(double dt) {
    accumulatedTime += dt;

    // Executa a física em steps fixos (60 FPS) para consistência
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState(); // Atualiza animação baseada no estado
        _updatePlayerMovement(fixedDeltaTime); // Aplica movimento horizontal
        _checkHorizontalCollisions(); // Verifica colisões laterais
        _applyGravity(fixedDeltaTime); // Aplica gravidade
        _checkVerticalCollisions(); // Verifica colisões verticais
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  // Manipula input do teclado
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    // Verifica teclas de movimento esquerda/direita
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0; // Esquerda = -1
    horizontalMovement += isRightKeyPressed ? 1 : 0; // Direita = 1

    // Verifica tecla de pulo
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  // Chamado quando colide com outros componentes
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer(); // Coleta fruta
      if (other is Saw) _respawn(); // Morre para serra
      if (other is Chicken) other.collidedWithPlayer(); // Interage com galinha
      if (other is Checkpoint) _reachedCheckpoint(); // Ativa checkpoint
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  // Carrega todas as animações do personagem
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11); // 11 frames parado
    runningAnimation = _spriteAnimation('Run', 12); // 12 frames correndo
    jumpingAnimation = _spriteAnimation('Jump', 1); // 1 frame pulando
    fallingAnimation = _spriteAnimation('Fall', 1); // 1 frame caindo
    hitAnimation = _spriteAnimation('Hit', 7)
      ..loop = false; // 7 frames hit (sem loop)
    appearingAnimation =
        _specialSpriteAnimation('Appearing', 7); // Animação especial
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    // Mapeia cada estado para sua animação correspondente
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Define a animação inicial
    current = PlayerState.idle;
  }

  // Método auxiliar para criar animações normais (32x32)
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  // Método auxiliar para criar animações especiais (96x96)
  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false, // Animações especiais não repetem
      ),
    );
  }

  // Atualiza o estado do jogador baseado na velocidade
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    // Vira o sprite na direção do movimento (sprite = personagem)
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter(); // Vira para esquerda
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter(); // Vira para direita
    }

    // Verifica movimento horizontal
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // Verifica se está caindo
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Verifica se está pulando
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  // Atualiza o movimento horizontal e aplica pulo
  void _updatePlayerMovement(double dt) {
    // dt = delta time (tempo desde o último frame)
    if (hasJumped && isOnGround) _playerJump(dt); // Aplica pulo se possível

    velocity.x =
        horizontalMovement * moveSpeed; // Calcula velocidade horizontal
    position.x += velocity.x * dt; // Aplica movimento horizontal
  }

  // Faz o jogador pular
  void _playerJump(double dt) {
    if (game.playSounds)
      FlameAudio.play('jump.wav',
          volume: game.soundVolume); //se tiver sons, toca o som
    velocity.y = -_jumpForce; // Aplica força do pulo (para cima)
    position.y += velocity.y * dt;
    isOnGround = false; // Não está mais no chão
    hasJumped = false; // Reseta o pulo
  }

  // Verifica colisões horizontais (paredes laterais)
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        // Plataformas não colidem lateralmente
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            // Colidindo indo para direita
            velocity.x = 0;
            position.x = block.x -
                hitbox.offsetX -
                hitbox.width; // Para na frente da parede
            break;
          }
          if (velocity.x < 0) {
            // Colidindo indo para esquerda
            velocity.x = 0;
            position.x = block.x +
                block.width +
                hitbox.width +
                hitbox.offsetX; // Para antes da parede
            break;
          }
        }
      }
    }
  }

  // Aplica gravidade ao jogador
  void _applyGravity(double dt) {
    velocity.y += _gravity; // Adiciona gravidade à velocidade vertical
    velocity.y =
        velocity.y.clamp(-_jumpForce, _terminalVelocity); // Limita velocidade
    position.y += velocity.y * dt; // Aplica movimento vertical
  }

  // Verifica colisões verticais (chão e teto)
  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        // Colisão com plataforma (só por cima)
        if (checkCollision(this, block)) {
          // Verifica colisão, se houver. THIS = PLAYER, BLOCK = PLATFORM
          if (velocity.y > 0) {
            // Caindo sobre a plataforma
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        // Colisão com bloco sólido
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            // Caindo no chão
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            // Batendo no teto
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  // Respawna o jogador após tomar dano
  void _respawn() async {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit; // Animação de tomar dano

    // Aguarda animação de hit terminar
    await animationTicker?.completed;
    animationTicker?.reset();

    // Prepara para aparecer
    scale.x = 1; // Garante que está virado para direita
    position = startingPosition - Vector2.all(32); // Posição temporária
    current = PlayerState.appearing; // Animação de aparecer

    // Aguarda animação de aparecer terminar
    await animationTicker?.completed;
    animationTicker?.reset();

    // Retorna à posição inicial
    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();

    // Permite movimento novamente após um delay
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  // Chamado quando atinge um checkpoint
  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }

    // Ajusta posição para animação
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing; // Animação de desaparecer

    // Aguarda animação terminar
    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640); // Move para fora da tela

    // Carrega próximo nível após delay
    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
  }

  // Chamado quando colide com inimigo (dano)
  void collidedwithEnemy() {
    _respawn();
  }
}

/*
* Física de Plataforma:
    Gravidade: Puxa o jogador para baixo continuamente
    Pulo: Força instantânea para cima quando no chão
    Velocidade Terminal: Velocidade máxima de queda
    Colisões: Impedem que o jogador passe através dos blocos

* Máquina de Estados Complexa:
    7 estados diferentes com transições suaves
    Cada estado tem sua própria animação
    Estados especiais (hit, appearing) bloqueiam o controle do jogador

* Sistema de Colisão Preciso:
    Hitbox personalizada menor que o sprite visual
    Colisões separadas para horizontal e vertical
    Plataformas permitem pular através por baixo

* Fixed Timestep:
    Garante que a física seja consistente em diferentes FPS
    Executa física em passos fixos de 1/60 segundos
    Acumula tempo extra entre frames

* Input Híbrido:
    Teclado para computadores
    Toque para dispositivos móveis (através do botão de pulo)
*/
