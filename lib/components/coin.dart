// Importa os pacotes necessários
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Classe que representa uma fruta coletável no jogo
// Herda de SpriteAnimationComponent para ter animações
// Mixins:
// - HasGameRef<PixelAdventure>: permite acessar o jogo principal
// - CollisionCallbacks: permite detectar colisões com o jogador
class Coin extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String coin; // Tipo da fruta (Apple, Banana, Cherry, etc.)

  Coin({
    this.coin = 'coin', // Valor padrão: Maçã
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  // Configurações de animação e colisão
  final double stepTime = 0.05; // Tempo entre cada frame da animação

  // Define a hitbox personalizada para a fruta
  // A hitbox é menor que o sprite visual para melhor jogabilidade
  final hitbox = CustomHitbox(
    offsetX: 10, // 10 pixels da esquerda
    offsetY: 10, // 10 pixels do topo
    width: 12, // Largura de 12 pixels
    height: 12, // Altura de 12 pixels
  );

  bool collected = false; // Controla se a fruta já foi coletada

  // Método chamado quando a fruta é carregada no jogo
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    priority =
        -1; // Prioridade de renderização (renderiza antes dos personagens)

    // Adiciona uma hitbox retangular para detecção de colisão
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY), // Posição da hitbox
        size: Vector2(hitbox.width, hitbox.height), // Tamanho da hitbox
        collisionType:
            CollisionType.passive, // Tipo passivo (não empurra outros objetos)
      ),
    );

    // Define a animação inicial da fruta (flutuando/brilhando)
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Coins/$coin.png'), // Carrega a spritesheet da fruta
      SpriteAnimationData.sequenced(
        amount: 17, // 17 frames na animação
        stepTime: stepTime, // Cada frame dura 0.05 segundos
        textureSize: Vector2.all(32), // Cada frame tem 32x32 pixels
      ),
    );
    return super.onLoad();
  }

  // Método chamado quando o jogador coleta a fruta
  void collidedWithPlayer() async {
    // Verifica se a fruta ainda não foi coletada (evita coleta múltipla)
    if (!collected) {
      collected = true; // Marca como coletada

      // Toca o som de coleta se os sons estiverem ativados
      if (game.playSounds) {
        FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
      }

      // Muda para a animação de coleta (partículas/efeito visual)
      animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Items/Coins/Collected.png'), // Spritesheet de coleta
        SpriteAnimationData.sequenced(
          amount: 6, // 6 frames na animação de coleta
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false, // Não repete - executa apenas uma vez
        ),
      );

      // Aguarda a animação de coleta terminar
      await animationTicker?.completed;

      // Remove a fruta do jogo após a animação
      removeFromParent();
    }
  }
}

/*
* Sistema de Coletáveis:
    Frutas são itens que o jogador pode coletar para pontos ou objetivos
    Cada tipo de fruta pode ter valores diferentes (mais pontos, etc.)
    O sistema collected evita que a mesma fruta seja coletada múltiplas vezes

* Animações Duplas:
    Animação de Idle: Fruta flutuando/brilhando (17 frames em loop)
    Animação de Coleta: Efeito visual quando coletada (6 frames, sem loop)

* Prioridade de Renderização:
    priority = -1 faz a fruta renderizar antes do jogador
    Garante que a fruta apareça "atrás" se o jogador pular sobre ela
    Números menores = renderiza primeiro (no fundo)

* CollisionType.passive:
    A fruta detecta colisões mas não empurra outros objetos
    O jogador pode passar através da fruta sem ser bloqueado
    Ideal para itens coletáveis

*Fluxo de Coleta:
    Jogador toca na fruta → collidedWithPlayer() é chamado
    Toca som de coleta (se ativado)
    Muda para animação de coleta
    Aguarda animação terminar
    Remove a fruta do jogo
*/
