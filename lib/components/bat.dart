// // Importa os pacotes necessários
// import 'dart:async';
// import 'dart:ui'; // Para a função lerpDouble

// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame_audio/flame_audio.dart'; // Para reproduzir sons
// import 'package:pixel_adventure/components/player.dart';
// import 'package:pixel_adventure/pixel_adventure.dart';

// // Enum que define os estados possíveis da galinha
// enum State { idle, run, hit }

// // Classe que representa o inimigo Galinha no jogo
// // Herda de SpriteAnimationGroupComponent para ter múltiplas animações
// // Mixins:
// // - HasGameRef<PixelAdventure>: permite acessar o jogo principal
// // - CollisionCallbacks: permite detectar colisões
// class Bat extends SpriteAnimationGroupComponent
//     with HasGameRef<PixelAdventure>, CollisionCallbacks {
//   final double offNeg; // Distância para esquerda que a galinha pode patrulhar
//   final double offPos; // Distância para direita que a galinha pode patrulhar

//   Bat({
//     super.position,
//     super.size,
//     this.offNeg = 0,
//     this.offPos = 0,
//   });

//   // Constantes do jogo
//   static const stepTime = 0.05; // Tempo entre frames das animações
//   static const tileSize = 16; // Tamanho de cada tile no jogo
//   static const runSpeed = 80; // Velocidade de corrida da galinha
//   static const _bounceHeight =
//       260.0; // Altura do pulo do jogador ao pular na galinha
//   final textureSize = Vector2(32, 34); // Tamanho das texturas da galinha

//   // Variáveis de movimento e estado
//   Vector2 velocity = Vector2.zero(); // Velocidade atual (x, y)
//   double rangeNeg = 0; // Limite esquerdo do alcance
//   double rangePos = 0; // Limite direito do alcance
//   double moveDirection = 1; // Direção atual do movimento (-1 = esq, 1 = dir)
//   double targetDirection = -1; // Direção desejada do movimento
//   bool gotStomped = false; // Se a galinha foi derrotada

//   // Referências e animações
//   late final Player player; // Referência ao jogador
//   late final SpriteAnimation _idleAnimation; // Animação parado
//   late final SpriteAnimation _runAnimation; // Animação correndo
//   late final SpriteAnimation _hitAnimation; // Animação sendo derrotada

//   // Método chamado quando a galinha é carregada no jogo
//   @override
//   FutureOr<void> onLoad() {
//     // debugMode = true;

//     player = game.player; // Obtém referência ao jogador do jogo principal

//     // Adiciona hitbox (área de colisão) para a galinha
//     add(
//       RectangleHitbox(
//         position: Vector2(4, 6), // Ajuste fino da posição da hitbox
//         size: Vector2(24, 26), // Tamanho da área de colisão
//       ),
//     );

//     _loadAllAnimations(); // Carrega todas as animações
//     _calculateRange(); // Calcula a área de patrulha
//     return super.onLoad();
//   }

//   // Método chamado a cada frame para atualizar o estado
//   @override
//   void update(double dt) {
//     if (!gotStomped) {
//       // Só se move se não foi derrotada
//       _updateState(); // Atualiza o estado (idle/run) e direção
//       _movement(dt); // Calcula e aplica o movimento
//     }

//     super.update(dt);
//   }

//   // Carrega todas as animações da galinha
//   void _loadAllAnimations() {
//     _idleAnimation = _spriteAnimation('Idle', 13); // 13 frames parado
//     _runAnimation = _spriteAnimation('Run', 14); // 14 frames correndo
//     _hitAnimation = _spriteAnimation('Hit', 15) // 15 frames sendo derrotada
//       ..loop = false; // Não repete - executa apenas uma vez

//     // Mapeia cada estado para sua animação correspondente
//     animations = {
//       State.idle: _idleAnimation,
//       State.run: _runAnimation,
//       State.hit: _hitAnimation,
//     };

//     current = State.idle; // Estado inicial: parado
//   }

//   // Método auxiliar para criar animações a partir de spritesheets
//   SpriteAnimation _spriteAnimation(String state, int amount) {
//     return SpriteAnimation.fromFrameData(
//       game.images.fromCache(
//           'Enemies/Bat/$state (32x34).png'), // Caminho da textura
//       SpriteAnimationData.sequenced(
//         amount: amount, // Número de frames
//         stepTime: stepTime, // Tempo entre frames
//         textureSize: textureSize, // Tamanho de cada frame
//       ),
//     );
//   }

//   // Calcula a área que o morcego pode patrulhar
//   void _calculateRange() {
//     rangeNeg = position.x - offNeg * tileSize; // Limite esquerdo
//     rangePos = position.x + offPos * tileSize; // Limite direito
//   }

//   // Calcula e aplica o movimento da galinha
//   void _movement(dt) {
//     // Reseta a velocidade horizontal
//     velocity.x = 0;

//     // Calcula offsets baseados na direção que estão virados
//     double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
//     double batOffset = (scale.x > 0) ? 0 : -width;

//     // Se o jogador está no alcance, persegue ele
//     if (playerInRange()) {
//       // Define direção alvo baseado na posição do jogador
//       targetDirection =
//           (player.x + playerOffset < position.x + batOffset) ? -1 : 1;
//       velocity.x = targetDirection * runSpeed; // Move na direção do jogador
//     }

//     // Suaviza a transição de direção (evita mudanças bruscas)
//     moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

//     // Aplica o movimento
//     position.x += velocity.x * dt;
//   }

//   // Verifica se o jogador está no alcance de detecção da galinha
//   bool playerInRange() {
//     double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

//     return player.x + playerOffset >= rangeNeg && // Dentro do limite esquerdo
//         player.x + playerOffset <= rangePos && // Dentro do limite direito
//         player.y + player.height >
//             position.y && // Acima da parte de baixo da galinha
//         player.y < position.y + height; // Abaixo do topo da galinha
//   }

//   // Atualiza o estado e direção da galinha
//   void _updateState() {
//     // Se está se movendo, corre; senão, fica parada
//     current = (velocity.x != 0) ? State.run : State.idle; // operador ternário

//     // Vira o sprite na direção do movimento
//     if ((moveDirection > 0 && scale.x > 0) ||
//         (moveDirection < 0 && scale.x < 0)) {
//       flipHorizontallyAroundCenter();
//     }
//   }

//   // Chamado quando colide com o jogador
//   void collidedWithPlayer() async {
//     // Se o jogador está caindo e acerta por cima (stomp)
//     if (player.velocity.y > 0 && player.y + player.height > position.y) {
//       if (game.playSounds) {
//         FlameAudio.play('bounce.wav',
//             volume: game.soundVolume); // Som de quique
//       }
//       gotStomped = true; // Marca como derrotada
//       current = State.hit; // Muda para animação de hit
//       player.velocity.y = -_bounceHeight; // Faz o jogador pular

//       // Aguarda a animação de hit terminar
//       await animationTicker?.completed;
//       removeFromParent(); // Remove a galinha do jogo
//     } else {
//       // Se o jogador foi atingido lateralmente ou por baixo
//       player.collidedwithEnemy(); // Causa dano ao jogador
//     }
//   }
// }

// /*
// * Inteligência Artificial Simples:
//     A galinha detecta quando o jogador está em seu alcance (playerInRange())
//     Persegue o jogador quando ele está próximo
//     Usa um sistema de patrulha baseado em rangeNeg e rangePos

// * Física de Colisão:
//     Stomp: Quando o jogador pula em cima do inimigo
//     Dano: Quando o jogador toca no inimigo pelos lados ou por baixo
//     Bounce: Efeito de quique quando o jogador derrota o inimigo

// * Suavização de Movimento:
//     lerpDouble() cria uma transição suave entre direções
//     Evita que a galinha mude de direção instantaneamente

// * Máquina de Estados:
//     Idle: Parado, esperando
//     Run: Perseguindo o jogador
//     Hit: Sendo derrotada (estado final)

// * Sistema de Áudio:
//     FlameAudio.play() reproduz efeitos sonoros
//     Respeita as configurações de volume do jogo
// */


// Importa os pacotes necessários
import 'dart:async';
import 'dart:ui'; // Para a função lerpDouble

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart'; // Para reproduzir sons
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum que define os estados possíveis do morcego
enum State { idle, fly, hit }

// Classe que representa o inimigo Morcego no jogo
class Bat extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg; // Distância horizontal para patrulha
  final double offPos; // Distância horizontal para patrulha

  Bat({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  // Constantes do jogo
  static const stepTime = 0.05; // Tempo entre frames das animações
  static const tileSize = 16; // Tamanho de cada tile no jogo
  static const flySpeed = 100; // Velocidade de voo do morcego (mais rápido)
  static const _bounceHeight = 260.0; // Altura do pulo do jogador
  final textureSize = Vector2(32, 34); // Tamanho das texturas do morcego

  // Variáveis de movimento e estado
  Vector2 velocity = Vector2.zero(); // Velocidade atual (x, y)
  Vector2 targetPosition = Vector2.zero(); // Posição alvo (jogador)
  double rangeNeg = 0; // Limite esquerdo do alcance
  double rangePos = 0; // Limite direito do alcance
  double moveDirection = 1; // Direção horizontal atual
  double targetDirection = -1; // Direção horizontal desejada
  bool gotStomped = false; // Se o morcego foi derrotado
  bool isChasing = false; // Se está perseguindo ativamente

  // Referências e animações
  late final Player player; // Referência ao jogador
  late final SpriteAnimation _idleAnimation; // Animação parado
  late final SpriteAnimation _flyAnimation; // Animação voando
  late final SpriteAnimation _hitAnimation; // Animação sendo derrotado

  // Método chamado quando o morcego é carregado no jogo
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    player = game.player; // Obtém referência ao jogador do jogo principal

    // Adiciona hitbox (área de colisão) para o morcego
    add(
      RectangleHitbox(
        position: Vector2(4, 6), // Ajuste fino da posição da hitbox
        size: Vector2(24, 26), // Tamanho da área de colisão
      ),
    );

    _loadAllAnimations(); // Carrega todas as animações
    _calculateRange(); // Calcula a área de patrulha inicial
    return super.onLoad();
  }

  // Método chamado a cada frame para atualizar o estado
  @override
  void update(double dt) {
    if (!gotStomped) {
      // Só se move se não foi derrotado
      _updateMovement(dt); // Calcula movimento de perseguição
      _updateState(); // Atualiza o estado (idle/fly) e direção
    }

    super.update(dt);
  }

  // Carrega todas as animações do morcego
  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 7); // 7 frames parado
    _flyAnimation = _spriteAnimation('Fly', 7); // 7 frames voando
    _hitAnimation = _spriteAnimation('Hit', 7) // 7 frames sendo derrotado
      ..loop = false; // Não repete - executa apenas uma vez

    // Mapeia cada estado para sua animação correspondente
    animations = {
      State.idle: _idleAnimation,
      State.fly: _flyAnimation,
      State.hit: _hitAnimation,
    };

    current = State.idle; // Estado inicial: parado
  }

  // Método auxiliar para criar animações a partir de spritesheets
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Enemies/Bat/$state (32x34).png'), // Caminho da textura
      SpriteAnimationData.sequenced(
        amount: amount, // Número de frames
        stepTime: stepTime, // Tempo entre frames
        textureSize: textureSize, // Tamanho de cada frame
      ),
    );
  }

  // Calcula a área inicial que o morcego pode patrulhar
  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize; // Limite esquerdo
    rangePos = position.x + offPos * tileSize; // Limite direito
  }

  // Calcula e aplica o movimento de perseguição do morcego
  void _updateMovement(double dt) {
    // Reseta a velocidade
    velocity = Vector2.zero();

    // Verifica se o jogador está no alcance de detecção
    if (playerInRange()) {
      isChasing = true;
      
      // Calcula direção para o jogador (perseguição agressiva)
      targetPosition = Vector2(player.x + player.width / 2, player.y + player.height / 2);
      Vector2 direction = targetPosition - (position + size / 2);
      
      // Normaliza a direção e aplica velocidade
      if (direction.length > 0) {
        direction.normalize();
        velocity = direction * flySpeed.toDouble();
      }

      // Define direção horizontal para o sprite
      targetDirection = (direction.x < 0) ? -1 : 1;
      
    } else {
      isChasing = false;
      
      // Comportamento de patrulha quando o jogador não está no alcance
      if (position.x <= rangeNeg) {
        targetDirection = 1; // Vira para direita
      } else if (position.x >= rangePos) {
        targetDirection = -1; // Vira para esquerda
      }
      
      velocity.x = targetDirection * (flySpeed * 0.5); // Move mais devagar na patrulha
    }

    // Suaviza a transição de direção horizontal
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.2) ?? moveDirection;

    // Aplica o movimento
    position += velocity * dt;
  }

  // Verifica se o jogador está no alcance de detecção do morcego
  bool playerInRange() {
    double detectionRange = 200.0; // Alcance de detecção em pixels
    
    // Calcula distância até o jogador
    double distance = (position + size / 2).distanceTo(
      Vector2(player.x + player.width / 2, player.y + player.height / 2)
    );
    
    return distance <= detectionRange;
  }

  // Atualiza o estado e direção do morcego
  void _updateState() {
    // Se está se movendo, voa; senão, fica parado
    current = (velocity.length > 0) ? State.fly : State.idle;

    // Vira o sprite na direção do movimento horizontal
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  // Chamado quando colide com o jogador
  void collidedWithPlayer() async {
    // Se o jogador está caindo e acerta por cima (stomp)
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume); // Som de quique
      }
      gotStomped = true; // Marca como derrotado
      current = State.hit; // Muda para animação de hit
      player.velocity.y = -_bounceHeight; // Faz o jogador pular

      // Aguarda a animação de hit terminar
      await animationTicker?.completed;
      removeFromParent(); // Remove o morcego do jogo
    } else {
      // Se o jogador foi atingido lateralmente ou por baixo
      player.collidedwithEnemy(); // Causa dano ao jogador
    }
  }
}

/*
* COMPORTAMENTO DO MORCEGO vs GALINHA:

GALINHA (original):
- Movimento apenas horizontal
- Patrulha em plataforma
- Persegue apenas na direção X
- Velocidade fixa em X

MORCEGO (modificado):
- Movimento livre em X e Y (voa)
- Persegue o jogador em todas as direções
- Alcance de detecção circular
- Perseguição mais agressiva e direta
- Pode voar sobre obstáculos
- Velocidade variável baseada na distância

* CARACTERÍSTICAS DO NOVO MORCEGO:
1. Perseguição 2D: Move em X e Y simultaneamente
2. Detecção por distância: Usa cálculo de distância euclidiana
3. Movimento suave: Normaliza a direção para movimento consistente
4. Dois comportamentos: Perseguição agressiva + Patrulha passiva
5. Voo livre: Ignora colisões com plataformas (pode voar sobre tudo)
*/