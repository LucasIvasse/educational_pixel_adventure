// Importa os pacotes necessários
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart'; // Para carregar mapas Tiled
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/frogger.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/coin.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Classe que representa um nível completo do jogo
// Herda de World (mundo do Flame) e tem acesso ao jogo principal
class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName; // Nome do nível (ex: 'Level-01')
  final Player player; // Referência ao jogador
  Level({required this.levelName, required this.player});

  late TiledComponent level; // Componente do mapa Tiled
  List<CollisionBlock> collisionBlocks = []; // Lista de blocos de colisão

  // Método chamado quando o nível é carregado
  @override
  FutureOr<void> onLoad() async {
    // Carrega o arquivo Tiled (.tmx) com tamanho de tile 16x16 pixels
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level); // Adiciona o mapa ao mundo

    // Configura os diferentes elementos do nível
    _scrollingBackground(); // Fundo animado
    _spawningObjects(); // Objetos e personagens
    _addCollisions(); // Blocos de colisão

    return super.onLoad();
  }

  // Configura o fundo animado com efeito parallax
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      // Obtém a cor do fundo das propriedades do layer no Tiled
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      // Cria e adiciona o tile de fundo
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray', // Usa 'Gray' como padrão
        position: Vector2(0, 0), // Posição inicial
      );
      add(backgroundTile);
    }
  }

  // Spawna (cria) todos os objetos do nível baseado no mapa Tiled
  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      // Verifica se a camada existe
      // Itera por todos os objetos na camada 'Spawnpoints'
      for (final spawnPoint in spawnPointsLayer.objects) {
        // Obtem os objetos
        // Usa a classe definida no Tiled para determinar o tipo de objeto
        switch (spawnPoint.class_) {
          case 'Player':
            // Posiciona o jogador no ponto de spawn
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1; // Garante que está virado para direita
            add(player); // Adiciona o jogador ao nível
            break;

          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name, // Tipo da fruta (Apple, Banana, etc.)
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;

          case 'Saw': // Inimigo
            // Obtém propriedades customizadas do Tiled
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final saw = Saw(
              isVertical: isVertical, // Movimento vertical ou horizontal
              offNeg: offNeg, // Distância para esquerda/cima
              offPos: offPos, // Distância para direita/baixo
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;

          case 'Checkpoint': // Ponto de checkpoint (bandeira)
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;

          case 'Chicken':
            // Obtém propriedades de patrulha do inimigo
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg, // Alcance para esquerda
              offPos: offPos, // Alcance para direita
            );
            add(chicken);
            break;

          case 'Frogger':
            // Obtém propriedades de patrulha do inimigo
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final frogger = Frogger(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg, // Alcance para esquerda
              offPos: offPos, // Alcance para direita
            );
            add(frogger);
            break;

            case 'Coin':
            final coin = Coin(
              coin: spawnPoint.name, // Tipo da fruta (Apple, Banana, etc.)
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(coin);
            break;


          default:
          // Ignora objetos com classes desconhecidas
        }
      }
    }
  }

  // Adiciona os blocos de colisão (paredes, chão, plataformas)
  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        // Itera pelos objetos, obtendo as propriedades
        switch (collision.class_) {
          // Usa a classe para determinar o tipo de colisão
          case 'Platform':
            // Cria uma plataforma (pode pular por baixo)
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true, // Marca como plataforma
            );
            collisionBlocks.add(platform);
            add(platform);
            break;

          default:
            // Cria um bloco sólido normal
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              // isPlatform: false (valor padrão)
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }

    // Passa a lista de blocos de colisão para o jogador
    player.collisionBlocks = collisionBlocks;
  }
}

/*
* Tiled Map Editor:
    Ferramenta visual para criar níveis de jogo
    Exporta arquivos .tmx que são carregados pelo Flame
    Permite criar camadas para diferentes elementos

* Estrutura de Camadas (Layers):
    Background: Fundo animado com parallax
    Spawnpoints: Objetos e personagens do jogo
    Collisions: Blocos de colisão invisíveis

* Sistema de Spawn por Classe:
    Cada objeto no Tiled tem uma "classe" que define seu tipo
    O jogo usa switch para criar o componente correto baseado na classe
    Propriedades customizadas no Tied são acessadas via getValue()

* Fluxo de Carregamento:
    Carrega mapa Tiled → estrutura básica do nível
    Adiciona fundo → efeito parallax
    Spawma objetos → jogador, inimigos, itens
    Configura colisões → física do nível
    Conecta colisões ao jogador → permite detecção

* Vantagens deste Sistema:
    Design visual: Níveis são criados no Tiled, não no código
    Flexibilidade: Fácil adicionar novos tipos de objetos
    Organização: Código separado por responsabilidades
    Manutenção: Mudanças no nível não exigem recompilar código
*/
