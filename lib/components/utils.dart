// Função que verifica se há colisão entre o jogador e um bloco
// Retorna true se estão colidindo, false caso contrário
bool checkCollision(player, block) {
  // Obtém a hitbox personalizada do jogador
  final hitbox = player.hitbox;

  // Calcula a posição real da hitbox do jogador no mundo
  // (posição do jogador + offset da hitbox)
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  // Posição e tamanho do bloco (já estão nas coordenadas do mundo)
  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Ajusta a posição X do jogador baseado na direção que está virado
  // Quando o jogador está virado para esquerda (scale.x < 0),
  // precisamos ajustar a posição X porque o flip horizontal afeta a hitbox
  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth // Ajuste para esquerda
      : playerX; // Posição normal para direita

  // Ajusta a posição Y para plataformas
  // Para plataformas, verificamos colisão apenas pela parte de baixo do jogador
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  // Verifica colisão usando o algoritmo de Intersecção de Retângulos (AABB)
  return (fixedY <
          blockY +
              blockHeight && // Topo do jogador está acima do fundo do bloco?
      playerY + playerHeight >
          blockY && // Fundo do jogador está abaixo do topo do bloco?
      fixedX <
          blockX +
              blockWidth && // Esquerda do jogador está à esquerda da direita do bloco?
      fixedX + playerWidth >
          blockX); // Direita do jogador está à direita da esquerda do bloco?
}

/*
* Detecção de Colisão AABB (Axis-Aligned Bounding Box):
    Verifica se dois retângulos estão se sobrepondo
      AABB = "Alinhado aos Eixos" - os retângulos não estão rotacionados
      Compara as extremidades de cada retângulo nos eixos X e Y
      Como funciona a verificaçao: 
        1. fixedY < blockY + blockHeight    → Topo do jogador acima do fundo do bloco?
        2. playerY + playerHeight > blockY  → Fundo do jogador abaixo do topo do bloco?  
        3. fixedX < blockX + blockWidth     → Esquerda do jogador à esquerda da direita do bloco?
        4. fixedX + playerWidth > blockX    → Direita do jogador à direita da esquerda do bloco?
        Todas as 4 condições devem ser verdadeiras para haver colisão

* Ajuste para Direção do Jogador:
    Quando o jogador vira para esquerda (scale.x < 0), o Flame automaticamente espelha o sprite
    Porém, a hitbox NÃO é espelhada automaticamente
    Precisamos recalcular manualmente a posição X da hitbox:
      fixedX = playerX - (hitbox.offsetX * 2) - playerWidth

* Lógica Especial para Plataformas:
    Para plataformas, só queremos detectar colisão quando o jogador está CAINDO sobre ela
    fixedY = playerY + playerHeight → verifica apenas pela parte de BAIXO do jogador
    Isso permite que o jogador pule através da plataforma por baixo
*/
