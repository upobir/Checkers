enum COLOR{
    LIGHT, DARK
}

enum TYPE{
    SOLDIER, KING
}

class Piece{
    final color lightPieceColor = color(255, 249, 244);
    final color darkPieceColor = color(196, 0, 3);
    
    //drawing variables
    float x, y;
    float diamX, diamY;
    
    COLOR side;
    TYPE type;
    Piece(COLOR side_, TYPE type_){
        side = side_;
        type = type_;
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
    
    private void drawCrown(){
        pushMatrix();
        translate(x, y);
        stroke(0);
        strokeWeight(1);
        if(side == COLOR.LIGHT)  fill(darkPieceColor);
        else                     fill(lightPieceColor);
        popMatrix();
    }
    
    public void highlight(color highlightColor){
        ellipseMode(CENTER);
        noFill();
        stroke(highlightColor);
        strokeWeight(6);
        ellipse(x, y, diamX, diamY);
    }
}
