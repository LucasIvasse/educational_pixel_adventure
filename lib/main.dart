// Importa os pacotes necessários para o jogo
import 'package:flame/flame.dart'; // Framework para criar jogos
import 'package:flame/game.dart'; // Componentes básicos do Flame
import 'package:flutter/foundation.dart'; // Funcionalidades básicas do Flutter
import 'package:flutter/material.dart'; // Widgets de interface do Flutter
import 'package:pixel_adventure/pixel_adventure.dart'; // Nosso jogo principal

// Função principal que executa quando o app inicia
void main() async {
  // Garante que o Flutter está inicializado antes de executar qualquer coisa
  WidgetsFlutterBinding.ensureInitialized();

  // Configura o dispositivo para tela cheia (remove barras de status/navegação)
  await Flame.device.fullScreen();

  // Define a orientação do jogo como paisagem (horizontal)
  await Flame.device.setLandscape();

  // Cria uma instância do nosso jogo PixelAdventure
  PixelAdventure game = PixelAdventure();

  // Executa o aplicativo Flutter
  runApp(
    // GameWidget é um widget especial do Flame que exibe o jogo
    GameWidget(
      game: kDebugMode ? PixelAdventure() : game,
      // kDebugMode é uma constante que verifica se estamos em modo de desenvolvimento
      // Se estivermos em modo debug: cria uma nova instância do jogo
      // Se estivermos em modo produção: usa a instância 'game' que criamos acima
    ),
  );
}

/*
*async/await: 
Permite que o código espere por operações que levam tempo (como carregar recursos) 
sem travar o app.
* Modo Debug vs Produção:
  - Debug: Durante o desenvolvimento, com ferramentas de debug ativas
  - Produção: Versão final do app, otimizada para usuários
* WidgetsFlutterBinding: 
É como o "motor" do Flutter que coordena tudo entre o framework e a interface do 
dispositivo.
* GameWidget: 
É a "ponte" que conecta o jogo Flame com o Flutter, permitindo que o jogo seja 
exibido na tela.
*/
