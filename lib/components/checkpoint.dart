// Importa os pacotes necessários
import 'dart:async'; // Para operações assíncronas

import 'package:flame/collisions.dart'; // Para detecção de colisões
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart'; // Componente do jogador
import 'package:pixel_adventure/pixel_adventure.dart'; // Classe principal do jogo

// Classe que representa um checkpoint no jogo
// Herda de SpriteAnimationComponent para ter animações
// Mixins:
// - HasGameRef<PixelAdventure>: permite acessar o jogo principal
// - CollisionCallbacks: permite detectar colisões
class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({
    position, // Posição do checkpoint no mundo
    size, // Tamanho do checkpoint
  }) : super(
          position: position,
          size: size,
        );

  // Método chamado quando o checkpoint é carregado no jogo
  @override
  FutureOr<void> onLoad() {
    // Linha comentada para modo debug - mostra hitboxes quando ativada
    // debugMode = true;

    // Adiciona uma hitbox (área de colisão) retangular
    add(RectangleHitbox(
      position: Vector2(18, 56), // Posição relativa dentro do componente
      size: Vector2(12, 8), // Tamanho da área de colisão
      collisionType:
          CollisionType.passive, // Tipo de colisão (não empurra outros objetos)
    ));

    // Define a animação inicial do checkpoint (bandeira recolhida)
    animation = SpriteAnimation.fromFrameData(
      // Carrega a imagem do checkpoint sem bandeira
      game.images
          .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      // Configura os dados da animação
      SpriteAnimationData.sequenced(
        amount: 1, // Apenas 1 frame (imagem estática)
        stepTime: 1, // Tempo entre frames (não importa pois só tem 1 frame)
        textureSize: Vector2.all(64), // Tamanho original da textura
      ),
    );
    return super.onLoad();
  }

  // Método chamado quando uma colisão começa (quando o jogador toca no checkpoint)
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, // Pontos onde ocorreu a colisão
      PositionComponent other) {
    // O outro componente que colidiu
    if (other is Player)
      _reachedCheckpoint(); // Se foi o jogador, ativa o checkpoint
    super.onCollisionStart(intersectionPoints, other);
  }

  // Método privado chamado quando o jogador atinge o checkpoint
  void _reachedCheckpoint() async {
    // Animação da bandeira saindo (erguendo)
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26, // 26 frames na animação
        stepTime: 0.05, // Cada frame dura 0.05 segundos (animação rápida)
        textureSize: Vector2.all(64), // Tamanho da textura
        loop: false, // Não repete a animação (executa apenas uma vez)
      ),
    );

    // Aguarda a animação atual terminar
    await animationTicker?.completed;

    // Animação da bandeira ondulando (estado permanente após ativação)
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10, // 10 frames na animação
        stepTime: 0.05, // Cada frame dura 0.05 segundos
        textureSize: Vector2.all(64), // Tamanho da textura
        // loop: true (padrão) - a animação se repete infinitamente
      ),
    );
  }
}

/*
*Checkpoint:
    É um ponto de salvamento no jogo
    Quando o jogador morre, volta para o último checkpoint atingido
    Normalmente fica ativo após a bandeira ser erguida

*Hitbox (Área de Colisão):
    É uma área invisível que detecta colisões
    Vector2(18, 56) posiciona a hitbox 18 pixels para direita e 56 para baixo
    Vector2(12, 8) cria uma área pequena de 12x8 pixels
    CollisionType.passive: detecta colisões mas não empurra outros objetos

*Animações:
    Estado inicial: Bandeira recolhida (1 frame estático)
    Transição: Bandeira saindo/erguendo (26 frames, sem loop)
    Estado final: Bandeira ondulando (10 frames em loop infinito)

*SpriteAnimationData.sequenced:
    amount: número total de frames na spritesheet (spritesheet: conjunto de imagens)
    stepTime: tempo entre cada frame (controla velocidade da animação)
    textureSize: tamanho de cada frame individual na spritesheet
    loop: se a animação se repete ou executa apenas uma vez

*await animationTicker?.completed:
    Pausa o código até que a animação atual termine
    Garante que a animação da bandeira saindo complete antes de iniciar a animação idle
 */
