class Game{
    final color lightCellColor = color(255, 238, 187);
    final color darkCellColor = color(85, 136, 34);
    final color highlightColor = color(255, 255, 0);
    final color multijumpHighlightColor = color(248, 150, 0);
    final color availableMoveColor = color(0, 0, 0);
    final int gridSz = 8;
    final COLOR startingColor = COLOR.DARK;
    
    //game variables
    Piece board[][];
    Map<Piece, int[]> activePieces;        //TODO maybe set this to different maps for different colors?
    COLOR currentPlayerColor;
    ArrayList<Move> validMoves;
    COLOR winningColor;
    
    //drawing variables
    float xlo, ylo, xhi, yhi;
    boolean whiteFront;
    float cellSize, borderSpace;
    
    //IO variables
    Piece highlightedPiece;
    
    // DEBUG code
    Move lastMove;
    COLOR lastColor;
    
    Game(){
        board = new Piece[8][8];
        activePieces = new HashMap<Piece, int[]>();
        validMoves = new ArrayList<Move>();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){            //Initializing dark pieces on row 0, 1, 2 & light pieces on row 5, 6, 7
                if((i+j)%2 == 0) continue;
                if(i < 3) 
                    changePiecePosition(new Piece(COLOR.DARK, TYPE.SOLDIER, gridSz-1), null, new int[]{i, j});
                if(i >= gridSz-3) 
                    changePiecePosition(new Piece(COLOR.LIGHT, TYPE.SOLDIER, 0), null, new int[]{i, j});
            }    
        
        highlightedPiece = null;
        winningColor = null;
        
        whiteFront = (startingColor == COLOR.LIGHT);
        setPlayer(startingColor);
    }
    
    //draw function to be called with x, y bounds of drawing space and boolean of whether white is front.
    public void draw(float centerX, float centerY, float boardSz){
        borderSpace = boardSz*0.011;
        float innerBoardSz = boardSz - borderSpace*2; 
        xlo = centerX - innerBoardSz/2;
        xhi = centerX + innerBoardSz/2;
        ylo = centerY - innerBoardSz/2;
        yhi = centerY + innerBoardSz/2;
        cellSize = innerBoardSz / gridSz;
        
        drawBoard();
        drawPieces();
        drawHighlights();
    }
    
    //draws board given bounding box
    private void drawBoard(){
        rectMode(CORNERS);
        fill(currentPlayerColor.drawColor);
        noStroke();
        rect(xlo - borderSpace, ylo - borderSpace, xhi + borderSpace, yhi + borderSpace);
        
        
        rectMode(CENTER);
        noStroke();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) fill(lightCellColor);
                else             fill(darkCellColor);
                
                float x = map(j+0.5, 0, gridSz, xlo, xhi);
                float y = map(i+0.5, 0, gridSz, ylo, yhi);
                rect(x, y, cellSize, cellSize);
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
                     
                     cellPiece.draw(x, y, cellSize);     //TODO use same diameter
                }
            }
    }
    
    //drawing highlighted pieces and cells
    private void drawHighlights(){        //TODO highlight multijumps differently
        
        for(Move move : validMoves){
            board[move.from[0]][move.from[1]].highlight(availableMoveColor, false);
        }
        
        if(highlightedPiece == null) return;
        
        highlightedPiece.highlight(highlightColor, true);

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
            if(!futureJumpPossible(move)) stroke(highlightColor);
            else                          stroke(multijumpHighlightColor);
            strokeJoin(ROUND);
            strokeWeight(cellSize*0.06);        //TODO make stroke weight varying
            rectMode(CENTER);
            rect(x, y, cellSize, cellSize);
        }        
    }
    
    private boolean futureJumpPossible(Move move){
        if(!move.isCapturing()) return false;
        
        Piece[][] virtualBoard = new Piece[gridSz][];
        for(int i = 0; i<gridSz; i++)
            virtualBoard[i] = board[i].clone();
            
        int[] oldP = move.from;
        int[] newP = move.to;
        int[] capP = new int[]{ (oldP[0] + newP[0])/2, (oldP[1] + newP[1])/2 };
        
        Piece movingPiece = virtualBoard[oldP[0]][oldP[1]];
        virtualBoard[oldP[0]][oldP[1]] = null;
        virtualBoard[newP[0]][newP[1]] = movingPiece;
        virtualBoard[capP[0]][capP[1]] = null;
        
        List<Move> futureMoveList = movingPiece.getMoves(virtualBoard, newP[0], newP[1]);
        for(Move futureMove: futureMoveList){
            if(futureMove.isCapturing())
                return true;
        }
        
        return false;
    }
    
    
    //public function to reverse view
    public void flipView(){
        whiteFront = !whiteFront;
        return;
    }
    
    //setiing current playing side.
    private void setPlayer(COLOR side){
        if(winningColor != null) return;
        currentPlayerColor = side;
        computeValidMoves();
        if(validMoves.isEmpty()){
            winningColor = currentPlayerColor.opposite();
        }
    }
    
    //computing valid moves for current player.
    private void computeValidMoves(){
        if(winningColor != null) return;
        validMoves.clear();
        for(Map.Entry<Piece, int[]> entry: activePieces.entrySet()){
            if(entry.getKey().pieceColor != currentPlayerColor) continue;
            
            int i = entry.getValue()[0], j = entry.getValue()[1];
            List<Move> movesForPiece = entry.getKey().getMoves(board, i, j);
            validMoves.addAll(movesForPiece);
        }
        
        ArrayList<Move> capturingMoves = new ArrayList<Move>();
        for(Move move : validMoves){
            if(move.isCapturing()){
                capturingMoves.add(move);
            }
        }
        
        if(!capturingMoves.isEmpty()){
            validMoves = capturingMoves;
        }
    }
    
    //get valid moves for one piece from precomputed validMoves
    private List<Move> getValidMovesFor(Piece piece){
        if(winningColor != null) return null;
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
        if(winningColor != null) return;
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
        
        if(cellPiece != null){        //if the cell we clicked on, had a piece on it
            if(cellPiece == highlightedPiece)
                highlightedPiece = null;
            else if(cellPiece.pieceColor == currentPlayerColor && !getValidMovesFor(cellPiece).isEmpty()) 
                highlightedPiece = cellPiece;
        }
        else{                        //if the cell we clicked on, was empty
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
        if(winningColor != null) return false;
        //TODO check if move is valid, inefficient?
        if(!validMoves.contains(move)) return false;
        
        Piece movingPiece = board[move.from[0]][move.from[1]];
        changePiecePosition(movingPiece, move.from, move.to);
        
        if(move.isCapturing()){
            changePiecePosition(move.capturedPiece, activePieces.get(move.capturedPiece), null);
        }
        
        if(movingPiece.type == TYPE.SOLDIER && move.to[0] == movingPiece.kingingRow){
            movingPiece.changeType(TYPE.KING);
            move.isKingingMove = true;
        }
        
        validMoves.clear();
        if(move.isCapturing()){            //check if multi-jump is possible, only when this move itself was jumping
            List<Move> moreMoves = movingPiece.getMoves(board, move.to[0], move.to[1]);
            for(Move newMove: moreMoves){
                if(newMove.isCapturing())
                    validMoves.add(newMove);
            }
        }
        
        if(validMoves.isEmpty()){
            if(currentPlayerColor == COLOR.LIGHT) setPlayer(COLOR.DARK);
            else                                  setPlayer(COLOR.LIGHT);
        }
        
        
        // DEBUG code
        lastMove = move;
        lastColor = movingPiece.pieceColor;
        
        return true;
    }
    
    public void undoMove(Move move, COLOR prvPlayerColor, boolean hardUndo){
        if(winningColor != null) winningColor = null;
        Piece movingPiece = board[move.to[0]][move.to[1]];
        
        if(move.isKingingMove) movingPiece.changeType(TYPE.SOLDIER);
        
        changePiecePosition(movingPiece, move.to, move.from);
        
        if(move.isCapturing()){
            int[] capP = new int[]{(move.from[0] + move.to[0])/2, (move.from[1] + move.to[1])/2};
            changePiecePosition(move.capturedPiece, null, capP);
        }
        
        if(hardUndo){
            setPlayer(prvPlayerColor);
        }
        else{
            currentPlayerColor = prvPlayerColor;
        }
        
        // DEBUG code
        lastMove = null;
        lastColor = null;
        return;
    }
    
    //chaging piece position by inserting it, deleting it or just changing it.
    private void changePiecePosition(Piece piece, int[] from, int to[]){
        if(winningColor != null) return;
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
    
    
    // DEBUG code
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
