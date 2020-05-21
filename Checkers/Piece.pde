enum TYPE{
    SOLDIER, KING
}

class Piece{
    
    //piece game properties
    int[][] movementVector;
    COLOR pieceColor;
    TYPE type;
    
    //drawing variables
    float x, y;
    float diamX, diamY;
    
    
    Piece(COLOR pieceColor_, TYPE type_){
        pieceColor = pieceColor_;
        type = type_;
        if(type == TYPE.KING)
            movementVector = new int[][]{ {-1, 1}, {-1, -1}, {1, -1}, {1, 1} };
        else if(pieceColor == COLOR.LIGHT) 
            movementVector = new int[][]{ {-1, 1}, {-1, -1} };
        else
            movementVector = new int[][]{ {1, 1}, {1, -1} };
    }
    
    //to draw the pieces.
    public void draw(float x_, float y_, float cellWidth, float cellHeight){
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(2);
        x = x_;
        y = y_;
        diamX = 0.75*cellWidth;        
        diamY = 0.75*cellHeight;
        /*if(pieceColor == COLOR.LIGHT)  fill(lightPieceColor);
        else                           fill(darkPieceColor);*/
        fill(pieceColor.drawColor);
        ellipse(x, y, diamX, diamY);
        
        if(type == TYPE.KING){
            drawCrown();
        }
    }
    
    //drawing the crown for king pieces
    private void drawCrown(){
        pushMatrix();
        translate(x, y);
        stroke(0);
        strokeWeight(2);
        fill(255, 255, 0);
        //if(side == COLOR.LIGHT)  fill(darkPieceColor);
        //else                     fill(lightPieceColor);
        //noFill();
        
        float bottomHalf = 0.22;
        float topHalf = 0.28;
        float heightHalf = 0.15;
        float crownMiddleHalf = 0.115;
        
        beginShape();
        //base of the crown
        vertex(-diamX*bottomHalf, diamY*heightHalf);
        vertex(diamX*bottomHalf, diamY*heightHalf);
        
        vertex(diamX*topHalf, -diamY*heightHalf);    //going up
        vertex(diamX*crownMiddleHalf, 0);            //going down
        vertex(0, -diamY*heightHalf);                //going up
        vertex(-diamX*crownMiddleHalf, 0);           //going down
        vertex(-diamX*topHalf, -diamY*heightHalf);   //going up
        endShape(CLOSE);
        
        popMatrix();
    }
    
    //highlight selected piece
    public void highlight(color highlightColor){
        ellipseMode(CENTER);
        noFill();
        stroke(highlightColor);
        strokeWeight(6);            //make stroke weight varying
        ellipse(x, y, diamX, diamY);
    }
    
    //get a list of legal moves considering other pieces.
    public List<Move> getMoves(Piece[][] board, int i, int j){
        List<Move> ret = new LinkedList<Move>();
        for(int [] vec: movementVector){
            int newi = i+vec[0], newj = j+vec[1];
            
            if(isInside(board, newi, newj)){
                if(board[newi][newj] == null)
                    ret.add(new Move(i, j, newi, newj));
                else if(board[newi][newj].pieceColor != this.pieceColor){
                    int capi = newi+vec[0], capj = newj + vec[1];
                    
                    if(isInside(board, capi, capj) && board[capi][capj] == null){
                        Move move = new Move(i, j, capi, capj);
                        move.setCaptured(board[newi][newj]);
                        ret.add(move);
                    }
                }
            }
        }
        return ret;
    }
    
    //helper fucntion
    private boolean isInside(Piece[][] board, int i,int j){
        return (0 <= i && i <= board.length && 0 <= j && j < board[i].length);
    }
}
