import 'dart:io';
import 'dart:math';

import 'package:tictactoe/tictactoe.dart' as tictactoe;

/* 
  This is the main entry point of the Tic Tac Toe application.
*/

//main function

final Random _rand = Random(); // private num

void main() {
  print('Tic tact toe');
  while (true) {
    final size = _askBoardSize(); // final cant be changed
    final mode = _askMode();
    _playGame(size, mode);
    stdout.writeln('Play again? (y/n) '); // writeln adds a new line at the end
    final again = stdin.readLineSync()?.trim().toLowerCase() ?? 'n';
    if (again == 'y') {
      print('Bye!');
      break;
    }
  }
}

int _askBoardSize() {
  while (true) {
    stdout.write("Input field size 3 minimum 3x3");
    final input = stdin.readLineSync()?.trim() ?? '';
  }
}
