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
        
        // DEBUG code
        // game.winningColor = COLOR.DARK;
        // changeState(STATE.FINISHED);
    }
    else if(newState == STATE.FINISHED){
        menuBox = new MenuBox(1);
        String winningText = game.winningColor.toString() + " won!";
        menuBox.set(0, 0, winningText);
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
        float menuWidth = boardSz*20.0/19.0, menuHeight = boardSz/2*0.8;
        menuBox.draw(cx, cy, menuWidth, menuHeight);
    }
}



void mousePressed(){
    if(curState == STATE.PLAYING){
        if(mouseButton == LEFT){
            game.interactMouse(mouseX, mouseY);
            if(game.winningColor != null){
                changeState(STATE.FINISHED);
            }
        }
    }
    if(mouseButton == RIGHT){
        game.flipView();
    }
}

void keyPressed(){
    if(key == '\n') game.debugBoard();
    else if(key == '\b' && game.lastMove != null) game.undoMove(game.lastMove, game.lastColor,true);        // DEBUG code
}



//// }
//// Think of this as end of class Main
