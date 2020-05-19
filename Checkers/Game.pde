class Game{
    final color lightCellColor = color(255, 238, 187);
    final color darkCellColor = color(85, 136, 34);
    final color highlightColor = color(255, 255, 0);
    
    final int gridSz = 8;
    Piece board[][];
    Piece highlightedPiece;
    
    //drawing variables
    float xlo, ylo, xhi, yhi;
    boolean whiteFront;
    float cellWidth;
    float cellHeight;
    
    Game(){
        board = new Piece[8][8];
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){            //Initializing dark pieces on row 0, 1, 2 & light pieces on row 5, 6, 7
                if((i+j)%2 == 0) continue;
                if(i < 3) board[i][j] = new Piece(COLOR.DARK, TYPE.SOLDIER);
                if(i >= gridSz-3) board[i][j] = new Piece(COLOR.LIGHT, TYPE.SOLDIER);
            }
        highlightedPiece = null;
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
    }
    
    //draws board given bounding box
    private void drawBoard(){
        
        rectMode(CORNER);
        noStroke();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) fill(lightCellColor);
                else             fill(darkCellColor);
                
                float x = map(j, 0, gridSz, xlo, xhi);
                float y = map(i, 0, gridSz, ylo, yhi);
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
                     
                     if(highlightedPiece == cellPiece){
                         drawHighlights(i, j);
                     }
                }
            }
    }
    
    //drawing highlighted pieces and cells
    private void drawHighlights(int hi, int hj){
        assert highlightedPiece != null;
        highlightedPiece.highlight(highlightColor);
        List<Move> movesList = highlightedPiece.getMoves(hi, hj, gridSz);
        println(hi, hj);
        for(Move move: movesList){
            int i = move.to[0], j = move.to[1];
            //println(i, j);
            if(!whiteFront){ 
                i = gridSz-1-i;
                j = gridSz-1-j;
            }
            float y = map(i, 0, gridSz, ylo, yhi);
            float x = map(j, 0, gridSz, xlo, xhi);
            noFill();
            stroke(highlightColor);
            strokeWeight(6);        //TODO make stroke weight varying
            rect(x, y, cellWidth, cellHeight);
        }
        
    }
    
    //interact with mouse press
    public void interactMouse(float mx, float my){
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return;
        
        float x = map(mx, xlo, xhi, 0, gridSz);
        float y = map(my, ylo, yhi, 0, gridSz);
        int j = Math.round(x-0.5+0.001);
        int i = Math.round(y-0.5+0.001);
        Piece cell = (whiteFront)? board[i][j] : board[gridSz-1-i][gridSz-1-j];
        if(cell == null) return;
        if(cell == highlightedPiece) highlightedPiece = null;
        else                         highlightedPiece = cell;
    }
    
}
