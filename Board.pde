class Board {
  Piece [][] board = new Piece [9][9];
  Player [] player = new Player [2];
  IntList able;
  int select = -1;

  Board(Player player0, Player player1) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        this.board[i][j] = new Empty();
      }
    }
    this.player[0] = player0;
    this.player[1] = player1;
    for (int id = 0; id < 2; id++) {
      int _owner = player[id].owner_ID;
      if (player[id] instanceof ShogiPlayer) {
        for (int i = 0; i < 9; i++) {
          this.board[i][6-4*_owner] = new Fu(_owner);
        }
        this.board[1+6*_owner][7-6*_owner] = new Kaku  (_owner);
        this.board[7-6*_owner][7-6*_owner] = new Hisya (_owner);
        this.board[0]         [8-8*_owner] = new Kyou  (_owner);
        this.board[1]         [8-8*_owner] = new Kei   (_owner);
        this.board[2]         [8-8*_owner] = new Silver(_owner);
        this.board[3]         [8-8*_owner] = new Gold  (_owner);
        this.board[4]         [8-8*_owner] = new King  (_owner);
        this.board[5]         [8-8*_owner] = new Gold  (_owner);
        this.board[6]         [8-8*_owner] = new Silver(_owner);
        this.board[7]         [8-8*_owner] = new Kei   (_owner);
        this.board[8]         [8-8*_owner] = new Kyou  (_owner);
      } else {
        for (int i = 0; i < 9; i++) {
          this.board[i][6-4*_owner] = new Igo(_owner);
          this.board[i][8-8*_owner] = new Igo(_owner);
        }
        this.board[1+6*_owner][7-6*_owner] = new Igo(_owner);
        this.board[7-6*_owner][7-6*_owner] = new Igo(_owner);
        this.board[4]         [8-8*_owner] = new King (_owner);
      }
    }
    able = new IntList();
  }

  Piece get(int _xy) {
    if (  0 <= _xy && _xy <=  80) return this.board[_xy/9][_xy%9];
    if (100 <= _xy && _xy <= 120) return this.player[0].possession.get(_xy-100);
    if (130 <= _xy && _xy <= 150) return this.player[1].possession.get(_xy-130);
    return null;
  }

  void set(int _xy, Piece _piece, int _owner) {
    this.board[_xy/9][_xy%9] = copy(_piece, _owner);
  }

  void remove(int _xy) {
    if (  0 <= _xy && _xy <=  80) this.board[_xy/9][_xy%9] = new Empty();
    if (100 <= _xy && _xy <= 120) this.player[0].possession.remove(_xy-100);
    if (130 <= _xy && _xy <= 150) this.player[1].possession.remove(_xy-130);
  }

  void drawBoard() {
    fill(#D3A775);
    rect(width/2, height/2, CELL_LEN*10, CELL_LEN*10);
    for (float i = 5.5; i < 14; i++) {
      for (float j = 1.5; j < 10; j++) {
        rect(i*CELL_LEN, j*CELL_LEN, CELL_LEN, CELL_LEN);
      }
    }
    rect(CELL_LEN* 2.25, CELL_LEN*4, CELL_LEN*3, CELL_LEN*7);
    rect(CELL_LEN*16.75, CELL_LEN*7, CELL_LEN*3, CELL_LEN*7);
  }
  
  void drawPiece() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        this.board[i][j].draw((i+5.5)*CELL_LEN, (j+1.5)*CELL_LEN, this.board[i][j].owner);
      }
    }
    for (int i = 0; i < player[0].possession.size(); i++) {
      player[0].possession.get(i).draw(CELL_LEN*17.75-CELL_LEN*(i%3), CELL_LEN*10-CELL_LEN*(i/3), 0);
    }
    for (int i = 0; i < player[1].possession.size(); i++) {
      player[1].possession.get(i).draw(CELL_LEN*1.25+CELL_LEN*(i%3), CELL_LEN+CELL_LEN*(i/3), 1);
    }
  }
  
  void drawCanMove(int _owner) {
    fill(0, 0, 255, 50);
    for(int i = 0; i < 9; i++) {
      for(int j = 0; j < 9; j++) {
        if(this.board[i][j].owner == _owner && this.board[i][j].code > 0) {
          rect((i+5.5)*CELL_LEN, (j+1.5)*CELL_LEN, CELL_LEN, CELL_LEN);
        }
      }
    }
  }

  void drawAble() {
    fill(255, 0, 0, 50);
    for (int i : this.able) {
      if (i == -1) continue;
      rect((i/9+5.5)*CELL_LEN, (i%9+1.5)*CELL_LEN, CELL_LEN, CELL_LEN);
    }
    fill(0, 0, 255, 50);
    if(this.select < 81) return;    
    rect((this.select/9+5.5)*CELL_LEN, (this.select%9+1.5)*CELL_LEN, CELL_LEN, CELL_LEN);
  }

  void setAbleToSet(int _owner, int _xy) {
    //if (this.player[_owner] instanceof IgoPlayer) {
    //  this.able = this.emptyList();
    //  return;
    //}
    if (_xy == -1) {
      this.selectClear();
      return;
    }
    Piece move = this.get(_xy);
    this.select = _xy;
    if (_xy >= 100) {
      if (move.code == 10) this.able = this.ableFuList(_owner);
      else                this.able = this.emptyList();
      return;
    }
    if (move.owner != _owner) return;
    int _code = move.code;
    int _x = _xy / 9;
    int _y = _xy % 9;
    switch(_code) {
    case 1:  // King
      this.able.append(isAbleToSet(_owner, _x, _y, -1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 0));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 0));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 1));
      break;
    case 2:  // Hisya
    case 3:  // Dragon
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, -i, 0));
        if (!canContinueToMove(_owner, _x, _y, -i, 0)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, i, 0));
        if (!canContinueToMove(_owner, _x, _y, i, 0)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, 0, -i));
        if (!canContinueToMove(_owner, _x, _y, 0, -i)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, 0, i));
        if (!canContinueToMove(_owner, _x, _y, 0, i)) break;
      }
      if (_code == 2) break;
      this.able.append(isAbleToSet(_owner, _x, _y, -1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 1));
      break;
    case 4:  // Kaku
    case 5:  // Hourse
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, -i, -i));
        if (!canContinueToMove(_owner, _x, _y, -i, -i)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, -i, i));
        if (!canContinueToMove(_owner, _x, _y, -i, i)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, i, -i));
        if (!canContinueToMove(_owner, _x, _y, i, -i)) break;
      }
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, i, i));
        if (!canContinueToMove(_owner, _x, _y, i, i)) break;
      }
      if (_code == 4) break;
      this.able.append(isAbleToSet(_owner, _x, _y, 0, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 0));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 0));
      break;
    case 6:  // Gold
      this.able.append(isAbleToSet(_owner, _x, _y, -1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 0));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 0));
      break;
    case 7:  // Silver
      this.able.append(isAbleToSet(_owner, _x, _y, -1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, -1, 1));
      this.able.append(isAbleToSet(_owner, _x, _y, 0, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, -1));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, 1));
      break;
    case 8:  // Kei
      this.able.append(isAbleToSet(_owner, _x, _y, -1, -2));
      this.able.append(isAbleToSet(_owner, _x, _y, 1, -2));
      break;
    case 9:  // Kyou
      for (int i = 1; i < 9; i++) {
        this.able.append(isAbleToSet(_owner, _x, _y, 0, -i));
        if (!canContinueToMove(_owner, _x, _y, 0, -i)) break;
      }
      break;
    case 10: // Fu
      this.able.append(isAbleToSet(_owner, _x, _y, 0, -1));
      break;
    default:
      break;
    }
  }

  int isAbleToSet(int _owner, int _x, int _y, int  _dx, int _dy) {
    int x = _x + (_owner == 0 ? _dx : -_dx);
    int y = _y + (_owner == 0 ? _dy : -_dy);
    if (x < 0 || 8 < x || y < 0 || 8 < y) return -1;
    Piece installed = this.get(x*9+y);
    if (installed instanceof Shogi && installed.owner == _owner) return -1;
    return x*9+y;
  }

  boolean canContinueToMove(int _owner, int _x, int _y, int  _dx, int _dy) {
    int x = _x + (_owner == 0 ? _dx : -_dx);
    int y = _y + (_owner == 0 ? _dy : -_dy);
    if (x < 0 || 8 < x || y < 0 || 8 < y) return false;
    Piece installed = this.get(x*9+y);
    if (installed instanceof Empty) return true;
    return false;
  }

  IntList emptyList() {
    IntList emptyList = new IntList();
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (this.get(i*9+j) instanceof Empty) emptyList.append(i*9+j);
      }
    }
    return emptyList;
  }

  IntList ableFuList(int _owner) {
    IntList FuList = new IntList();
  Fu:
    for (int _x = 0; _x < 9; _x++) {
      for (int _y = 0; _y < 9; _y++) {
        if (this.board[_x][_y].code == 10 && this.board[_x][_y].owner == _owner) continue Fu;
      }
      for (int _y = 0; _y < 9; _y++) {
        if (this.get(_x*9+_y) instanceof Empty) FuList.append(_x*9+_y);
      }
    }
    return FuList;
  }

  void movePiece(int _owner, int after) {
    Piece obtain = copy(this.board[after/9][after%9], _owner);
    this.set(after, copy(this.get(select), _owner), _owner);
    this.remove(this.select);
    if (obtain instanceof Empty) return;
    player[_owner].possession.add(obtain);
  }

  //@Duplicate
  void selectClear() {
    this.select = -1;
    this.able = new IntList();
  }

  boolean canAdvanced(int _owner, int after) {
    int code = this.get(after).code;
    if (code != 2 && code != 4 && code != 7 && code != 8 && code != 9 && code != 10) return false;
    return (_owner == 1 ? (after%9 > 5) : (after%9 < 3));
  }

  void Advanced(int after) {
    Piece seed = this.get(after);
    if      (seed.name.equals("飛\n車")) this.set(after, new Dragon(seed.owner), seed.owner);
    else if (seed.name.equals("角\n行")) this.set(after, new Hourse(seed.owner), seed.owner);
    else if (seed.name.equals("銀\n将")) this.set(after, new Silver(seed.owner), seed.owner);
    else if (seed.name.equals("桂\n馬")) this.set(after, new Kei   (seed.owner), seed.owner);
    else if (seed.name.equals("香\n車")) this.set(after, new Kyou  (seed.owner), seed.owner);
    else if (seed.name.equals("歩\n兵")) this.set(after, new To    (seed.owner), seed.owner);
  }
}