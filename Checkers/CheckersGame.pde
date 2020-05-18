class CheckersGame{
    color lightCellColor = color(255, 238, 187);
    color darkCellColor = color(85, 136, 34);
    color lightPieceColor = color(255, 249, 244);
    color darkPieceColor = color(196, 0, 3);
    int board[][];     //board array 0 - light 1 - dark
    
    CheckersGame(){
        board= new int[8][8];
        for(int j = 0; j<board.length; j++)
            for(int i = 0; i<board[j].length; i++){
                board[j][i] = (i+j)%2; 
            }
    }
    
    void draw(float xlo, float ylo, float xhi, float yhi){
        int n = board.length;
        int m = board[0].length;
        float cellWidth = (xhi-xlo)/m;
        float cellHeight = (yhi-ylo)/n;
        rectMode(CORNERS);
        noStroke();
        for(int j = 0; j<n; j++)
            for(int i = 0; i<n; i++){
                if(board[j][i] == 0) fill(lightCellColor);
                else fill(darkCellColor);
                float x1 = map(i, 0, m, xlo, xhi);
                float y1 = map(j, 0, n, ylo, yhi);
                float x2 = map(i+1, 0, m, xlo, xhi);
                float y2 = map(j+1, 0, n, ylo, yhi);
                rect(x1, y1, x2, y2));
            }
    }
    
}
