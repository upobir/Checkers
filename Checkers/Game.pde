class Game{
    final color lightCellColor = color(255, 238, 187);
    final color darkCellColor = color(85, 136, 34);
    final color highlightColor = color(255, 255, 0);
    final int gridSz = 8;
    
    //game variables
    Piece board[][];
    Map<Piece, int[]> activePieces;        //TODO maybe set this to different maps for different colors?
    COLOR currentPlayerColor;
    List<Move> validMoves;
    
    //drawing variables
    float xlo, ylo, xhi, yhi;
    boolean whiteFront;
    float cellWidth;
    float cellHeight;
    
    //IO variables
    Piece highlightedPiece;
    
    Game(){
        board = new Piece[8][8];
        activePieces = new HashMap<Piece, int[]>();
        validMoves = new ArrayList<Move>();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){            //Initializing dark pieces on row 0, 1, 2 & light pieces on row 5, 6, 7
                if((i+j)%2 == 0) continue;
                if(i < 3) 
                    changePiecePosition(new Piece(COLOR.DARK, TYPE.SOLDIER), null, new int[]{i, j});
                if(i >= gridSz-3) 
                    changePiecePosition(new Piece(COLOR.LIGHT, TYPE.SOLDIER), null, new int[]{i, j});
            }    
        
        highlightedPiece = null;
        setPlayer(COLOR.LIGHT);
    }
    
    //draw function to be called with x, y bounds of drawing space and boolean of whether white is front.
    public void draw(float xlo_, float ylo_, float xhi_, float yhi_, boolean whiteFront_){    //TODO check if square
        xlo = xlo_;
        ylo = ylo_;
        xhi = xhi_;
        yhi = yhi_;
        whiteFront = whiteFront_;
        cellWidth = (xhi - xlo) /gridSz;
        cellHeight = (yhi - ylo) /gridSz;
        
        drawBoard();
        drawPieces();
        drawHighlights();
    }
    
    //draws board given bounding box
    private void drawBoard(){
        
        rectMode(CENTER);
        noStroke();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) fill(lightCellColor);
                else             fill(darkCellColor);
                
                float x = map(j+0.5, 0, gridSz, xlo, xhi);
                float y = map(i+0.5, 0, gridSz, ylo, yhi);
                rect(x, y, cellWidth, cellHeight);
            }
    }
    
    //draws pieces given bounding box of board.
    private void drawPieces(){
        for(int i = 0; i<board.length; i++)
            for(int j = 0; j<board[i].length; j++){
                Piece cellPiece = board[i][j];
                if(cellPiece != null){
                     float x = map(j+0.5, 0, gridSz, xlo, xhi);
                     float y = map(i+0.5, 0, gridSz, ylo, yhi);
                     
                     if(!whiteFront){
                         x = xlo + xhi - x;
                         y = ylo + yhi - y;
                     }
                     
                     cellPiece.draw(x, y, cellWidth, cellHeight);     //TODO use same diameter
                }
            }
    }
    
    //drawing highlighted pieces and cells
    private void drawHighlights(){
        if(highlightedPiece == null) return;
        
        highlightedPiece.highlight(highlightColor);

        List<Move> highlightMoves = getValidMovesFor(highlightedPiece);        
        for(Move move: highlightMoves){
            int i = move.to[0], j = move.to[1];
            float y = map(i+0.5, 0, gridSz, ylo, yhi);
            float x = map(j+0.5, 0, gridSz, xlo, xhi);
            if(!whiteFront){
                x = xlo + xhi - x;
                y = ylo + yhi - y;
            }
            
            noFill();
            stroke(highlightColor);
            strokeWeight(6);        //TODO make stroke weight varying
            rectMode(CENTER);
            rect(x, y, cellWidth, cellHeight);
            
            
            /*if(move.capturedPiece != null){
                int capi = (move.to[0] + move.from[0])/2;
                int capj = (move.to[1] + move.from[1])/2;
                float capy = map(capi+0.5, 0, gridSz, ylo, yhi);
                float capx = map(capj+0.5, 0, gridSz, xlo, xhi);
                if(!whiteFront){
                    x = xlo + xhi - x;
                    y = ylo + yhi - y;
                }
                
                noFill();
                stroke(0);
                strokeWeight(6);
                rectMode(CENTER);
                rect(capx, capy, cellWidth, cellHeight);
            }*/
        }
        
    }
    
    //setiing current playing side.
    private void setPlayer(COLOR side){
        currentPlayerColor = side;
        validMoves.clear();
        for(Map.Entry<Piece, int[]> entry: activePieces.entrySet()){
            int i = entry.getValue()[0], j = entry.getValue()[1];
            List<Move> movesForPiece = entry.getKey().getMoves(board, i, j);
            validMoves.addAll(movesForPiece);
        }
        
        if(validMoves.isEmpty()) println("no more moves possible");
    }
    
    //get valid moves for one piece.
    private List<Move> getValidMovesFor(Piece piece){
        List<Move> ret = new LinkedList<Move>();
        for(Move move: validMoves){
            int[] pos = move.from;
            if(board[pos[0]][pos[1]] == piece)
                ret.add(move);
        }
        return ret;
    }
    
    //interact with mouse press
    public void interactMouse(float mx, float my){
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return;
        if(!whiteFront){
            mx = xlo + xhi - mx;
            my = ylo + yhi - my;
        }
        //reverse has been handled assume normal view
        
        float x = map(mx, xlo, xhi, 0, gridSz);
        float y = map(my, ylo, yhi, 0, gridSz);
        int j = Math.round(x-0.5+0.001);
        int i = Math.round(y-0.5+0.001);
        //[i][j] is the cell clicked on 
        
        Piece cellPiece = board[i][j];
        
        if(cellPiece != null){
            if(cellPiece == highlightedPiece)
                highlightedPiece = null;
            else if(cellPiece.pieceColor == currentPlayerColor && !getValidMovesFor(cellPiece).isEmpty()) 
                highlightedPiece = cellPiece;
        }
        else{
            if(highlightedPiece != null){
                List<Move> interactableMoves = getValidMovesFor(highlightedPiece);
                for(Move move: interactableMoves){
                    if(move.to[0] == i && move.to[1] == j){
                        applyMove(move);
                        highlightedPiece = null;
                    }
                }
            }
        }
    }
    
    
    //applying a move
    public boolean applyMove(Move move){
        //TODO check if move is valid, inefficient?
        if(!validMoves.contains(move)) return false;
        
        Piece movingPiece = board[move.from[0]][move.from[1]];
        changePiecePosition(movingPiece, move.from, move.to);
        
        setPlayer(COLOR.LIGHT);
        
        return true;
    }
    
    //chaging piece position by inserting it, deleting it or just changing it.
    private void changePiecePosition(Piece piece, int[] from, int to[]){
        //TODO remove these asserts before finishing
        assert from != null || to != null;
        if(from != null) assert board[from[0]][from[1]] == piece;
        if(to != null) assert board[to[0]][to[1]] == null;
        
        if(from != null) 
            board[from[0]][from[1]] = null;
            
        if(to != null){ 
            board[to[0]][to[1]] = piece;
            activePieces.put(piece, to);
        }
        else
            activePieces.remove(piece);
        
    }
    
    
    //debugging the board
    public void debugBoard(){
        for(int i = 0; i<gridSz; i++){
            for(int j = 0; j<gridSz; j++){
                if(board[i][j] == null) print(" - ");
                else if(board[i][j].pieceColor == COLOR.LIGHT) print(" L ");
                else print(" D ");
            }
            println();
        }
        println();
        println();
    }
    
}
