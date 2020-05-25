import java.util.*;

//TODO comment all code
//TODO use STATEs in a better way



//// Think of this as main class
//// class Main{
    
Game game;
float boardSz; //board size for drawing
STATE curState;
MenuBox menuBox;

void setup(){
    size(1200, 900);
    background(50);
    surface.setResizable(true);
    changeState(STATE.PLAYING);
}

void changeState(STATE newState){
    if(newState == STATE.PLAYING){
        game = new Game();
        menuBox = null;
    }
    else if(newState == STATE.FINISHED){
        menuBox = new MenuBox(0, 1, 0, 3);
        String winningText = game.winningColor.toString() + " won!";
        menuBox.set(1, 0, winningText, BOXTYPE.TEXTONLY);
        menuBox.set(3, 1, "Start New Game", BOXTYPE.BUTTON);
    }
    curState = newState;
}

// make drawing dependant on states?
void draw(){
    
    background(25);
    
    float cx = width/2, cy = height/2;
    boardSz = Math.min(width, height)*0.95;
    game.draw(cx, cy, boardSz);
    
    
    if(menuBox != null){
        cx = width/2;
        cy = height/2;
        float menuWidth = boardSz*20.0/19.0, menuRowHeight = boardSz/2*0.2;
        menuBox.draw(cx, cy, menuWidth, menuRowHeight);
    }
}



void mousePressed(){
    if(mouseButton == RIGHT){
        game.flipView();
        return;
    }
    
    if(curState == STATE.PLAYING){        
         game.interactMouse(mouseX, mouseY);
         if(game.winningColor != null){
             changeState(STATE.FINISHED);
         }
    }
    else if(curState == STATE.FINISHED){
        int[] clicked = menuBox.interactMouse(mouseX, mouseY);
        /*if(clicked != null){
            println(clicked[0], clicked[1]);
            println(clicked.equals(new int[]{3, 0}));
        }*/
        if(clicked != null && Arrays.equals(clicked, new int[]{3, 1}))
            changeState(STATE.PLAYING);
    }
    
}

void keyPressed(){
    if(key == '\n') game.debugBoard();
    else if(key == '\b' && game.lastMove != null) game.undoMove(game.lastMove, game.lastColor,true);        // DEBUG code
    else if(key == 'l'){ 
        // DEBUG code
        game.winningColor = COLOR.LIGHT;
        changeState(STATE.FINISHED);
    }
}



//// }
//// Think of this as end of class Main
