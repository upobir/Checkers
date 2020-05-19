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
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) continue;
                if(i < 3) board[i][j] = new Piece(ColorSide.DARK, Type.SOLDIER);
                if(i >= gridSz-3) board[i][j] = new Piece(ColorSide.LIGHT, Type.SOLDIER);
            }
        highlightedPiece = board[1][0];
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
        drawHightlights();
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
                Piece cell = (whiteFront)? board[i][j] : board[gridSz-1-i][gridSz-1-j];
                if(cell != null){
                     float x = map(j+0.5, 0, gridSz, xlo, xhi);
                     float y = map(i+0.5, 0, gridSz, ylo, yhi);
                     cell.draw(x, y, cellWidth, cellHeight);     //TODO use same diameter
                }
            }
    }
    
    //drawing highlighted pieces and cells
    private void drawHightlights(){
        if(highlightedPiece != null){
            highlightedPiece.highlight(highlightColor);
        }
    }
    
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
