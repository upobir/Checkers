enum COLOR{
    LIGHT, DARK
}

enum TYPE{
    SOLDIER, KING
}

class Piece{
    final color lightPieceColor = color(255, 249, 244);
    final color darkPieceColor = color(196, 0, 3);
    
    //movement directions in IJ
    int[][] movementVector;
    
    //drawing variables
    float x, y;
    float diamX, diamY;
    
    COLOR side;
    TYPE type;
    Piece(COLOR side_, TYPE type_){
        side = side_;
        type = type_;
        if(side == COLOR.LIGHT) 
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
        if(side == COLOR.LIGHT)  fill(lightPieceColor);
        else                     fill(darkPieceColor);
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
    
    //get a list of legal moves not considering other pieces.
    public List<Move> getMoves(int i, int j, int gridSz){
        List<Move> ret = new LinkedList<Move>();
        for(int [] vec: movementVector){
            int ni = i+vec[0], nj = j+vec[1];
            if(0 <= ni && ni < gridSz && 0 <= nj && nj < gridSz){
                ret.add(new Move(i, j, ni, nj));
            }
        }
        return ret;
    }
}
