//file for all enum classes

// enum for colors;
public enum COLOR{
    
    // final color lightPieceColor = color(255, 249, 244);
    // final color darkPieceColor = color(196, 0, 3);
    
    LIGHT(255<<24 | 255<<16 | 249<<8 | 244), DARK(255<<24 | 196<<16 | 0<<8 | 3);        //using integer masked color because enum won't allow color static, for values see above comment
    
    public color drawColor;            //color
 
    private COLOR(color drawColor){
        this.drawColor = drawColor;
    }
    
    //printing as string
    public String toString(){
        if(this == LIGHT) return "White";
        else              return "Red";
    }
    
    //opposite color that makes logical stuff easy
    public COLOR opposite(){
        if(this == LIGHT) return DARK;
        else              return LIGHT;
    }
    
    //sign in heuristic value, since heurstic is white - red.
    public int sign(){
        if(this == LIGHT) return 1;
        else              return -1;
    }
  
}

//enum for piece type.
public enum TYPE{
    SOLDIER(1000), KING(3000);
    
    public int value;    //value in heuristic
    
    private TYPE(int val){
        this.value = val;
    }
}

//enum for state of game.
public enum STATE{
    SETUP, PLAYING, FINISHED
}

//enum for text box type in menu
public enum BOXTYPE{
    TEXTONLY, BUTTON
}

//enum for opponent type.
public enum OPPONENT{
    PLAYER("Player"), AI("Computer");
    
    public String string;        //string that will be shown in menu
    
    private OPPONENT(String string){
        this.string = string;
    }
    
    //to print to menu
    public String toString(){
        return this.string;
    }
}

//button trigger enum
public enum TRIGGER{
    STARTMENU, STARTGAME, OPPONENTFLIP
}
