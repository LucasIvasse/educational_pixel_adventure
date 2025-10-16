// Importa os componentes necessários do Flame
import 'package:flame/components.dart';

// Classe que representa um bloco de colisão no jogo
// Herda de PositionComponent - componente básico com posição e tamanho
class CollisionBlock extends PositionComponent {
  // Define se este bloco é uma plataforma (que o jogador pode pular através por baixo)
  bool isPlatform;

  // Construtor da classe
  CollisionBlock({
    position, // Posição do bloco no mundo do jogo (Vector2)
    size, // Tamanho do bloco (Vector2 - largura e altura)
    this.isPlatform = false, // Valor padrão: não é uma plataforma
  }) : super(
          position: position, // Passa a posição para a classe pai
          size: size, // Passa o tamanho para a classe pai
        ) {
    // debugMode = true;
  }
}

/*
* Blocos de Colisão (Collision Blocks):
    São componentes invisíveis que definem onde os personagens podem andar
    Criam os "limites" físicos do mundo do jogo
    São como as paredes e pisos invisíveis que impedem o jogador de cair fora do mapa

* PositionComponent:
    É a classe base mais simples do Flame para componentes que têm posição e tamanho
    Não tem sprite (imagem) própria - é invisível
    Não tem animações - é estático

* isPlatform:
    false: Bloco sólido normal (como parede ou chão) - impede passagem por todos os lados
    true: Plataforma (como plataformas flutuantes) - o jogador pode pular através por baixo e cair de cima, mas pode ficar em cima

* Modo Debug:
    Quando debugMode = true é ativado, o Flame mostra visualmente a hitbox do componente
    É muito útil durante o desenvolvimento para verificar se as colisões estão posicionadas corretamente
    Na versão final do jogo, isso fica desativado para não aparecer na tela
*/
