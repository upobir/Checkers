class CheckersGame{
    final color lightCellColor = color(255, 238, 187);
    final color darkCellColor = color(85, 136, 34);
    
    final int gridSz = 8;
    Piece board[][];     //board array 0 - light 1 - dark
    
    CheckersGame(){
        board = new Piece[8][8];
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) continue;
                if(i < 3) board[i][j] = new Piece(ColorSide.DARK, Type.SOLDIER);
                if(i >= gridSz-3) board[i][j] = new Piece(ColorSide.LIGHT, Type.SOLDIER);
            }
        
    }
    
    //draw function to be called with x, y bounds of drawing space and boolean of whether white is front.
    public void draw(float xlo, float ylo, float xhi, float yhi, boolean whiteFront){    //TODO check if square
        drawBoard(xlo, ylo, xhi, yhi);
        drawPieces(xlo, ylo, xhi, yhi, whiteFront);
    }
    
    //draws board given bounding box
    private void drawBoard(float xlo, float ylo, float xhi, float yhi){
        float cellWidth = (xhi - xlo) /gridSz;
        float cellHeight = (yhi - ylo) /gridSz;
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
    private void drawPieces(float xlo, float ylo, float xhi, float yhi, boolean whiteFront){
        float cellWidth = (xhi - xlo) /gridSz;
        float cellHeight = (yhi - ylo) /gridSz;
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
    
}
