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
                if(i < 3) board[i][j] = new Piece(COLOR.DARK, TYPE.SOLDIER);
                if(i >= gridSz-3) board[i][j] = new Piece(COLOR.LIGHT, TYPE.SOLDIER);
                if(board[i][j] != null) activePieces.put( board[i][j], new int[]{i, j} );
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
        
        float x = map(mx, xlo, xhi, 0, gridSz);
        float y = map(my, ylo, yhi, 0, gridSz);
        int j = Math.round(x-0.5+0.001);
        int i = Math.round(y-0.5+0.001);
        Piece cellPiece = board[i][j];
        
        if(cellPiece != null){
            if(cellPiece == highlightedPiece)
                highlightedPiece = null;
            else if(cellPiece.pieceColor == currentPlayerColor && !getValidMovesFor(cellPiece).isEmpty()) 
                highlightedPiece = cellPiece;
        }
    }
}
