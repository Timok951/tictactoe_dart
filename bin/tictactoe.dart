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
    if (input.isEmpty) continue;
    final normalized = input.toLowerCase().replaceAll('x', '');
    final n = int.tryParse(normalized); //Parses a string containing a number literal into a number.
    if (n != null && n >= 3) return n;
    print("incorrect input try again");
  }
}

enum GameMode {pvp, pvc} // Enumerated types, often called enumerations or enums, are a special kind of class used to represent a fixed number of constant values. 

GameMode _askMode(){
  while(true){
    stdout.write('Choose regime: 1) player 1 vs player 2) player vs robot');
  }
}

void _playGame(int size, GameMode mode){
  final board = List.generate(size, (_) => List.filled(size, ' '));
  //List.generate - creating list _-means does not matter =>-lambda expression does not neeed } and return
  /* 
  List.generate(size, (_) {
  return List.filled(size, ' ');
});
  */
  String current = _rand.nextBool() ? 'X' : 'O';
  final humanPlays = _determineHumanSide(mode);
  print('\nStart game ${size}x$size. First to go: $current');
  _printBoard(board);

  while(true){
    if(_isHumanTurn(current, mode, humanPlays)){
      _humanMove(board, current);
    }
    else{
      _robotMove(board, current);
    }

    _printBoard(board);

    if(_checkWin(board,current)){
      print('Win "$current"');
      break;
    }
    
    if(_isDraw(board)){
      print('Draw');
      break;
    }
    current = (current == 'X') ? 'O' : 'X';

  }
}

String _determineHumanSide (GameMode mode){
  //for pvp all - people return X 
  if(mode == GameMode.pvp) return 'both';
  // in pvc ask player to choose X or O
  while (true){
    stdout.write("Which side do you choode? (X/O). X By default");
    final s = stdin.readLineSync()?.trim().toUpperCase();
    if(s == null || s.isEmpty ) return 'X';
    if (s == 'X' || s == 'O') return s;
    print('Input number X or O');
  }
}

bool _isHumanTurn(String current, GameMode mode, String humanPlays){
  if(mode == GameMode.pvp) return true;
  //mode == pvc 
  // humanPlays == 'X' or 'O'
  return current == humanPlays;
}

void _printBoard(List<List<String>> b){
  final n = b.length;
  stdout.write('  ');
  for(var r = 0; r < n; r++){
    stdout.write('${r + 1}'.padLeft(2) + ' ');
    for (var c = 0; c<n; c++){
      final ch = b[r][c] == ' ' ? '.' : b[r][c];
      stdout.write('$ch');
    }
    print('');
  }
}

void _humanMove(List<List<String>> board, String player){
  final n = board.length;
  while (true){
      stdout.write('Move player "$player" input row and col through space (example: 2, 3)');
      final line = stdin.readLineSync();
      if(line == null) continue;
      final parts = line.trim().split(RegExp(r'\s+'));
      if(parts.length < 2){
        print("You need to input two numbers");
        continue;
      }
      final r = int.tryParse(parts[0]);
      final c = int.tryParse(parts[1]);
      if(r == null || c == null){
        print('Not right format use numbers');
        continue;
      }
      final ri = r - 1;
      final ci = c - 1;
      if (ri < 0 || ri >= n || ci < 0 || ci >= n){
        print('Coordinates not in the field');
        continue;
      }
      if(board[ri][ci] != ' '){
        print('Cell was already painted');
        continue;
      }
      board[ri][ci] = player;
      break;
  }
}

void _robotMove(List<List<String>> board, String player){
  final opponent = player == 'X' ? 'O' : 'X';
  print('Robot is moving for player "$player"....');

  // 1) Win if has move
  final win = _findWinningMove(board, player);
  if(win != null){
    board[win[0]][win[1]] = player;
    print('Robot has made a move: ${win[0] + 1} ${win[1]+1} (winnig)');
    return;
  }

  // 2) block opponent
  final block = _findWinningMove(board, opponent);
  if(block != null){
    board[block[0]][block[1]] = player;
    print('Robot made a move ${block[0] + 1} ${block[1] + 1} (block)');
    return;
  }

  // 3) center if it has
  final n = board.length; 
  final center = (n / 2).floor();
  if(board[center][center] == ' '){
    board[center][center] == player;
    print('Robot made move ${center + 1} ${center + 1} (center)');
  }
  // 4) 
  final near = _findNearMove(board, player);
  if(near != null){
    board[near[0]][near[1]] = player;
    print('Robot made move: ${near[0] + 1} ${near[1] + 1} (neares)');
    return;
  }

  // 5) Random free 
  final free = <List<int>>[];
  for(var i = 0; i < n; i++){
    for(var j =0; j < n; j++){
      if(board[i][j] == ' ') free.add([i,j]);
    }
  }
  if(free.isNotEmpty){
    final pick = free[_rand.nextInt(free.length)];
    board[pick[0]][pick[1]] = player;
    print('Robot made move: ${pick[0] + 1} ${pick[1] + 1} (random)');
  }
}

///find move tham made win for player - return [r,c] or null
List<int>? _findWinningMove(List<List<String>> board, String player){
  final n = board.length;
  for (var i = 0; i < n; i++){
    for (var j = 0; j < n; j++){
      if (board[i][j] != ' ') continue;
      board[i][j] = player;
      final win = _checkWin(board, player);
      board[i][j] = ' ';
      if (win) return [i,j];
    }
  }
  return null;
}

//Evrystic find cell near with symbol player
List<int>? _findNearMove(List<List<String>> board, String player){
  final n = board.length;
  int? bestR, bestC;
  int bestScore = -1;
  for (var i =0; i < n; i++){
    for (var j = 0; j < n; j++){
      if(board[i][j] != ' ') continue;
      int score = 0;
      for (var di = -1; di <= 1; di++){
        for(var dj =-1; dj <= 1; dj++){
          if(di == 0 && dj == 0) continue;
          final ni = i + di, nj = j + dj;
          if(ni >= 0 && ni < n && nj >= 0 && nj < n) {
            if(board[ni][nj]==player) score +=2;
            else if (board[ni][nj] != ' ') score += 1;
          }
        }
      }
      if(score > bestScore){
        bestScore = score;
        bestR = i;
        bestC = j;
      }
    }
  }
  if(bestR != null && bestC != null) return [bestR, bestC];
  return null;

}

///Check Win if it has 3 symbols 

bool _checkWin(List <List<String>> board, String player){
  final n = board.length;

  final dirs = [
    [0, 1], //right
    [1,0], //down
    [1,1], //down right
    [1,-1] //down left
  ];

  for (var r = 0; r < n; r++){
    for (var c = 0; c < n; c++){
      if(board[r][c] != player ) continue;
      for (var d in dirs){
        final dr = d[0], dc = d[1];
        var ok = true;
        for (var k =1; k < 3; k++){
          final nr = r + dr * k;
          final nc = c + dc * k;
          if (nr < 0 || nr >= n || nc < 0 || nc >= n) {
            ok = false;
            break;
          }
          if (board[nr][nc] != player){
            ok = false;
            break;
          }
        }
        if (ok) return true;
      }
    }
  }
  return false;
}

bool _isDraw(List<List<String>> board){
  for(var row in board){
    for (var ch in row){
      if (ch == ' ') return false;
    }
  }
  return true;
}
