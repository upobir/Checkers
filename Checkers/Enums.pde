public enum COLOR{
    
    // final color lightPieceColor = color(255, 249, 244);
    // final color darkPieceColor = color(196, 0, 3);
    
    LIGHT(255<<24 | 255<<16 | 249<<8 | 244), DARK(255<<24 | 196<<16 | 0<<8 | 3);        //using integer masked color because enum won't allow color static, for values see above comment
    
    color drawColor;
    private COLOR(color drawColor){
        this.drawColor = drawColor;
    }
    
    public String toString(){
        if(this == LIGHT) return "White";
        else              return "Red";
    }
    
    public COLOR opposite(){
        if(this == LIGHT) return DARK;
        else              return LIGHT;
    }
    
    public int sign(){
        if(this == LIGHT) return 1;
        else              return -1;
    }
  
}


public enum TYPE{
    SOLDIER(20), KING(40);
    
    int value;
    private TYPE(int val){
        this.value = val;
    }
}

public enum STATE{
    SETUP, PLAYING, FINISHED
}

public enum BOXTYPE{
    TEXTONLY, BUTTON
}

public enum OPPONENT{
    PLAYER("Player"), AI("Computer");
    
    String string;
    private OPPONENT(String string){
        this.string = string;
    }
    
    public String toString(){
        return this.string;
    }
}

public enum TRIGGER{
    STARTMENU, STARTGAME, OPPONENTFLIP
}
