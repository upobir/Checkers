class CheckersGame{
    final color lightCellColor = color(255, 238, 187);
    final color darkCellColor = color(85, 136, 34);
    final color lightPieceColor = color(255, 249, 244);
    final color darkPieceColor = color(196, 0, 3);
    final int gridSz = 8;
    int board[][];     //board array 0 - light 1 - dark
    
    CheckersGame(){
        board= new int[8][8];
        board[1][1] = 1;
    }
    
    //draw function to be called with x, y bounds of drawing space and boolean of whether white is front.
    public void draw(float xlo, float ylo, float xhi, float yhi, boolean whiteFront){
        drawBoard(xlo, ylo, xhi, yhi);
        drawPieces(xlo, ylo, xhi, yhi, whiteFront);
    }
    
    //draws board given bounding box
    private void drawBoard(float xlo, float ylo, float xhi, float yhi){
        float cellWidth = (xhi - xlo) /gridSz;
        float cellHeight = (yhi - ylo) /gridSz;
        rectMode(CORNER);
        noStroke();
        for(int j = 0; j<gridSz; j++)
            for(int i = 0; i<gridSz; i++){
                if((i+j)%2 == 0) fill(lightCellColor);
                else             fill(darkCellColor);
                
                float x = map(i, 0, gridSz, xlo, xhi);
                float y = map(j, 0, gridSz, ylo, yhi);
                rect(x, y, cellWidth, cellHeight);
            }
    }
    
    //draws pieces given bounding box of board.
    private void drawPieces(float xlo, float ylo, float xhi, float yhi, boolean whiteFront){
        float cellWidth = (xhi - xlo) /gridSz;
        float cellHeight = (yhi - ylo) /gridSz;
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(2);
        for(int j = 0; j<board.length; j++)
            for(int i = 0; i<board[j].length; i++){
                int cell = (whiteFront)? board[j][i] : board[gridSz-1-j][gridSz-1-i];
                if(cell == 1){
                     float x = map(i+0.5, 0, gridSz, xlo, xhi);
                     float y = map(j+0.5, 0, gridSz, ylo, yhi);
                     float diamX = 0.75*cellWidth;        //TODO use same diameter
                     float diamY = 0.75*cellHeight;
                     fill(lightPieceColor);
                     ellipse(x, y, diamX, diamY);
                }
            }
    }
    
}
