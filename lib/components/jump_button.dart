// Importa os pacotes necessários
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Para detectar toques na tela
import 'package:pixel_adventure/pixel_adventure.dart';

// Classe que representa o botão de pulo na tela (controles touch)
// Herda de SpriteComponent para ter uma imagem estática
// Mixins:
// - HasGameRef<PixelAdventure>: permite acessar o jogo principal
// - TapCallbacks: permite detectar toques no botão
class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton(); // Construtor simples

  // Configurações de posicionamento
  final margin = 32; // Margem das bordas da tela
  final buttonSize = 64; // Tamanho do botão (64x64 pixels)

  // Método chamado quando o botão é carregado no jogo
  @override
  FutureOr<void> onLoad() {
    // Define o sprite (imagem) do botão
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));

    // Posiciona o botão no canto inferior direito da tela
    position = Vector2(
      game.size.x -
          margin -
          buttonSize, // Calcula posição X: largura total - margem - tamanho do botão
      game.size.y -
          margin -
          buttonSize, // Calcula posição Y: altura total - margem - tamanho do botão
    );

    priority = 10; // Alta prioridade - renderiza na frente de outros elementos

    return super.onLoad();
  }

  // Método chamado quando o jogador toca no botão (aperta o botão)
  @override
  void onTapDown(TapDownEvent event) {
    // Ativa o pulo do jogador
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  // Método chamado quando o jogador solta o botão (para de apertar)
  @override
  void onTapUp(TapUpEvent event) {
    // Desativa o pulo do jogador
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}

/*
* Controles Touch para Jogos Mobile:
    Este botão permite que jogadores em dispositivos móveis controlem o pulo
    É uma alternativa ao controle por teclado para jogos mobile

* Posicionamento Inteligente:
    game.size.x e game.size.y obtêm as dimensões da tela do dispositivo
    O cálculo game.size.x - margin - buttonSize posiciona o botão:
        - Começa da borda direita (game.size.x)
        - Subtrai a margem (- margin)
        - Subtrai o tamanho do botão (- buttonSize)
    Resultado: botão fica colado no canto inferior direito com uma margem

* Sistema de Prioridade:
    priority = 10 garante que o botão fique sempre na frente
    Isso evita que outros elementos do jogo cubram o botão
    Números maiores = renderizados por último (na frente)

* Eventos de Toque:
    onTapDown: Quando o dedo toca na tela (início do pulo)
    onTapUp: Quando o dedo sai da tela (fim do pulo)
    Isso permite controles precisos de quanto tempo pular

* Lógica do Pulo:
    hasJumped = true: O jogador começa a pular
    hasJumped = false: O jogador para de pular (pode afetar altura do pulo)
    Muitos jogos usam esse sistema para pulos mais altos (quanto mais tempo segurar, mais alto)

* Como funciona na prática:
    Jogador toca no botão → onTapDown → hasJumped = true
    Personagem começa a pular
    Jogador solta o botão → onTapUp → hasJumped = false
    Personagem completa o pulo
*/
