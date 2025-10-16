// Importa os pacotes necessários
import 'dart:async'; // Para operações assíncronas

import 'package:flame/components.dart';
import 'package:flame/parallax.dart'; // Para efeito de parallax
import 'package:flutter/material.dart';

// Classe que representa um tile de fundo com efeito parallax
// Parallax: efeito onde o fundo se move mais devagar que o primeiro plano,
// criando sensação de profundidade
class BackgroundTile extends ParallaxComponent {
  // Cor do tile de fundo (ex: 'Gray', 'Blue', 'Green')
  final String color;

  // Construtor da classe
  BackgroundTile({
    this.color = 'Gray', // Valor padrão se não for especificado
    position, // Posição do tile no mundo do jogo
  }) : super(
          position: position, // Passa a posição para o construtor pai
        );

  // Velocidade de rolagem do fundo (em pixels por segundo)
  // Quanto menor o número, mais devagar o fundo se move
  final double scrollSpeed = 40;

  // Método chamado quando o componente é carregado
  @override
  FutureOr<void> onLoad() async {
    // Define a prioridade de renderização (número menor = renderiza primeiro)
    // -10 significa que será renderizado antes da maioria dos componentes
    priority = -10;

    // Define o tamanho do tile (64x64 pixels)
    size = Vector2.all(64);

    // Carrega e configura o efeito parallax
    parallax = await game.loadParallax(
      // Lista de imagens para o parallax
      [ParallaxImageData('Background/$color.png')], // Caminho da imagem

      // Velocidade base do parallax (movimento vertical para cima)
      // Vector2(horizontal, vertical):
      // - Valores positivos movem para baixo/direita
      // - Valores negativos movem para cima/esquerda
      baseVelocity: Vector2(0, -scrollSpeed), // Move para cima

      // Como a imagem se repete
      repeat: ImageRepeat.repeat, // Repete infinitamente em ambas as direções

      // Como preencher a camada
      fill: LayerFill.none, // Não preenche a tela automaticamente
    );

    // Chama o onLoad da classe pai para completar o carregamento
    return super.onLoad();
  }
}

/*
* Efeito Parallax:
    É uma técnica onde diferentes camadas de fundo se movem em velocidades diferentes
    Cria uma ilusão de profundidade e movimento
    No jogo, o fundo se move mais devagar que o personagem

* Vector2:
    É um objeto que representa uma coordenada 2D (x, y)
    Vector2.all(64) cria um vetor (64, 64) - largura e altura iguais
    Vector2(0, -scrollSpeed) significa:
        - movimento horizontal = 0 (não se move lateralmente)
        - movimento vertical = -scrollSpeed (move para cima)

* Prioridade (priority):
    Controla a ordem de renderização dos componentes
    Números menores são renderizados primeiro (ficam no fundo)
    Números maiores são renderizados por último (ficam na frente)

* ImageRepeat:
    repeat: a imagem se repete infinitamente em ambas as direções
    Outras opções: noRepeat, repeatX, repeatY

* Camadas (Layers):
    Pense como folhas de papel transparente umas sobre as outras
    O fundo é a folha de baixo, o personagem é a folha de cima
    Cada uma pode se mover em velocidades diferentes
*/
