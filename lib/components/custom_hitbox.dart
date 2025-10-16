// Classe que define uma hitbox personalizada para componentes do jogo
// Hitbox: área de colisão invisível que detecta quando objetos se tocam
class CustomHitbox {
  // Deslocamento horizontal em relação à posição original do componente
  // Valores positivos = move para direita, valores negativos = move para esquerda
  final double offsetX;

  // Deslocamento vertical em relação à posição original do componente
  // Valores positivos = move para baixo, valores negativos = move para cima
  final double offsetY;

  // Largura da área de colisão
  final double width;

  // Altura da área de colisão
  final double height;

  // Construtor da classe - todos os parâmetros são obrigatórios (required)
  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
/*
* O que é uma Hitbox?:
    É uma área invisível ao redor de um objeto que detecta colisões
    Pense como uma "caixa de colisão" que envolve o personagem
    Quando duas hitboxes se sobrepõem, ocorre uma colisão

* Por que usar CustomHitbox?:
    - Precisão: A hitbox pode ser menor que o sprite visual
    - Jogabilidade: Cria colisões mais justas e naturais
    - Controle: Permite ajustes finos na detecção de colisão

* OffsetX e OffsetY:
    Controlam o posicionamento da hitbox em relação ao componente
    Exemplo: offsetX: 5 move a hitbox 5 pixels para direita
    Útil para centralizar a hitbox ou criar áreas de colisão específicas

* Width e Height:
    Controlam o tamanho da área de colisão
    Podem ser diferentes do tamanho visual do sprite
    Normalmente são menores para melhor jogabilidade

* Por que isso é importante?
Sem custom hitboxes, as colisões usariam todo o tamanho do sprite, o que poderia causar:
    Colisões muito "generosas" (o jogador parece ser maior que o visual)
    Frustração do jogador ("eu nem cheguei perto e colidi!")
    Jogabilidade imprecisa

Com custom hitboxes, temos tem controle total sobre como e quando as colisões acontecem
Isso permite criar colisões mais precisas e naturais 
*/
