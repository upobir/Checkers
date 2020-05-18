enum ColorSide{
    LIGHT, DARK
}

enum Type{
    SOLDIER, KING
}

class Piece{
    final color lightPieceColor = color(255, 249, 244);
    final color darkPieceColor = color(196, 0, 3);
    
    ColorSide side;
    Type type;
    Piece(ColorSide side_, Type type_){
        side = side_;
        type = type_;
    }
    
    public void draw(float x, float y, float cellWidth, float cellHeight){
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(2);
        float diamX = 0.75*cellWidth;        
        float diamY = 0.75*cellHeight;
        fill(lightPieceColor);
        ellipse(x, y, diamX, diamY);
    }
}
