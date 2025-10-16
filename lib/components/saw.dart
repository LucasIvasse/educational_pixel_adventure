// Importa os pacotes necessários
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Classe que representa uma serra móvel - obstáculo perigoso no jogo
// Herda de SpriteAnimationComponent para ter animação giratória
// Mixin HasGameRef<PixelAdventure>: permite acessar o jogo principal
class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final bool
      isVertical; // Se o movimento é vertical (true) ou horizontal (false)
  final double offNeg; // Distância para esquerda/cima que a serra pode se mover
  final double offPos; // Distância para direita/baixo que a serra pode se mover

  Saw({
    this.isVertical = false, // Padrão: movimento horizontal
    this.offNeg = 0, // Padrão: não se move para trás
    this.offPos = 0, // Padrão: não se move para frente
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  // Constantes do jogo para configuração da serra
  static const double sawSpeed = 0.03; // Velocidade da animação (giro)
  static const moveSpeed = 50; // Velocidade de movimento (deslocamento)
  static const tileSize = 16; // Tamanho de cada tile no jogo

  // Variáveis de controle de movimento
  double moveDirection =
      1; // Direção do movimento (1 = direita/baixo, -1 = esquerda/cima)
  double rangeNeg = 0; // Limite inferior/esquerdo do movimento
  double rangePos = 0; // Limite superior/direito do movimento

  // Método chamado quando a serra é carregada no jogo
  @override
  FutureOr<void> onLoad() {
    priority =
        -1; // Prioridade de renderização (renderiza antes dos personagens)

    // Adiciona uma hitbox circular - apropriada para uma serra redonda
    add(CircleHitbox());

    // Calcula os limites de movimento baseado na direção e offsets
    if (isVertical) {
      // Movimento vertical: calcula limites Y
      rangeNeg = position.y - offNeg * tileSize; // Limite superior
      rangePos = position.y + offPos * tileSize; // Limite inferior
    } else {
      // Movimento horizontal: calcula limites X
      rangeNeg = position.x - offNeg * tileSize; // Limite esquerdo
      rangePos = position.x + offPos * tileSize; // Limite direito
    }

    // Define a animação da serra girando
    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Traps/Saw/On (38x38).png'), // Spritesheet da serra
        SpriteAnimationData.sequenced(
          amount: 8, // 8 frames na animação
          stepTime: sawSpeed, // Cada frame dura 0.03 segundos
          textureSize: Vector2.all(38), // Cada frame tem 38x38 pixels
        ));
    return super.onLoad();
  }

  // Método chamado a cada frame para atualizar a serra
  @override
  void update(double dt) {
    // Move a serra baseado na direção configurada
    if (isVertical) {
      _moveVertically(dt); // Movimento vertical
    } else {
      _moveHorizontally(dt); // Movimento horizontal
    }
    super.update(dt);
  }

  // Controla o movimento vertical da serra (para cima e para baixo)
  void _moveVertically(double dt) {
    // Verifica se atingiu o limite inferior
    if (position.y >= rangePos) {
      moveDirection = -1; // Muda direção para cima
    }
    // Verifica se atingiu o limite superior
    else if (position.y <= rangeNeg) {
      moveDirection = 1; // Muda direção para baixo
    }

    // Aplica o movimento vertical
    position.y += moveDirection * moveSpeed * dt;
  }

  // Controla o movimento horizontal da serra (para esquerda e direita)
  void _moveHorizontally(double dt) {
    // Verifica se atingiu o limite direito
    if (position.x >= rangePos) {
      moveDirection = -1; // Muda direção para esquerda
    }
    // Verifica se atingiu o limite esquerdo
    else if (position.x <= rangeNeg) {
      moveDirection = 1; // Muda direção para direita
    }

    // Aplica o movimento horizontal
    position.x += moveDirection * moveSpeed * dt;
  }
}

/*
* Obstáculos Móveis:
    Serras são obstáculos que se movem em padrões previsíveis
    Podem ser usadas para criar desafios de timing e coordenação
    São letais - o jogador morre ao tocar nelas

* Sistema de Movimento Oscilatório:
    A serra se move entre dois pontos (rangeNeg e rangePos)
    Quando atinge um limite, inverte a direção (moveDirection = -1)
    Cria um movimento de vai-e-vem contínuo

* Duas Direções de Movimento:
    Horizontal: Move entre esquerda e direita
    Vertical: Move entre cima e baixo
    Controlado pela flag isVertical

* CircleHitbox:
    Hitbox circular é perfeita para objetos redondos como serras
    Mais precisa que retângulos para objetos circulares
    Detecta colisões de forma mais realista

* Configuração via Tiled:
    offNeg e offPos são definidos no editor Tiled
    Permite criar serras com diferentes alcances sem modificar código
    Exemplo: offNeg: 3, offPos: 5 → move 3 tiles para trás e 5 para frente

* Animações Independentes:
    A animação de rotação (sawSpeed) é separada do movimento (moveSpeed)
    A serra gira continuamente independente do deslocamento
    Cria a ilusão de uma lâmina giratória real
*/
