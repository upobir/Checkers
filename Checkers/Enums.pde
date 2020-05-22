public enum COLOR{
    
    // final color lightPieceColor = color(255, 249, 244);
    // final color darkPieceColor = color(196, 0, 3);
    
    LIGHT(255<<24 | 255<<16 | 249<<8 | 244), DARK(255<<24 | 196<<16 | 0<<8 | 3);        //using integer masked color because enum won't allow color static, for values see above comment
    
    color drawColor;
    private COLOR(color drawColor){
        this.drawColor = drawColor;
    }
    
    public COLOR opposite(){
        if(this == LIGHT) return DARK;
        else              return LIGHT;
    }
  
}


public enum TYPE{
    SOLDIER, KING
}

public enum STATE{
    SETUP, PLAYING, FINISHED
}
