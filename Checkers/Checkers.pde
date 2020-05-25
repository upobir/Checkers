import java.util.*;

//TODO comment all code
//TODO use STATEs in a better way



//// Think of this as main class
//// class Main{
    
final int animationUnit = 10;
    
    
Game game;
float boardSz; //board size for drawing
STATE curState;
STATE nxtState;
MenuBox menuBox;
int clk;


void setup(){
    size(1200, 900);
    background(50);
    surface.setResizable(true);
    changeState(STATE.PLAYING, 0);
}

void changeState(STATE newState, int timer){
    clk = timer;
    nxtState = newState;
}

void updateState(){
    if(nxtState == null) return;
    if(nxtState == STATE.PLAYING){
        game = new Game();
        menuBox = null;
    }
    else if(nxtState == STATE.FINISHED){
        menuBox = new MenuBox(0, 1, 0, 3);
        String winningText = game.winningColor.toString() + " won!";
        menuBox.set(1, 0, winningText, BOXTYPE.TEXTONLY);
        menuBox.set(3, 1, "Start New Game", BOXTYPE.BUTTON);
    }
    curState = nxtState;
    nxtState = null;
}

// make drawing dependant on states?
void draw(){
    if(clk == 0) updateState();
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
    if(clk > 0) clk--;
}



void mousePressed(){
    if(mouseButton == RIGHT){
        game.flipView();
        return;
    }
    
    if(curState == STATE.PLAYING){        
         boolean interaction = game.interactMouse(mouseX, mouseY);
         if(interaction && game.winningColor != null){
             changeState(STATE.FINISHED, animationUnit*6);
         }
    }
    else if(curState == STATE.FINISHED){
        int[] clicked = menuBox.interactMouse(mouseX, mouseY);
        if(clicked != null && Arrays.equals(clicked, new int[]{3, 1})){
            menuBox.setInteractibility(false);
            changeState(STATE.PLAYING, 2*animationUnit);
        }
    }
    
}

void keyPressed(){
    if(key == '\n') game.debugBoard();
    else if(key == '\b' && game.lastMove != null) game.undoMove(game.lastMove, game.lastColor,true);        // DEBUG code
    else if(key == 'l'){ 
        // DEBUG code
        game.winningColor = COLOR.LIGHT;
        changeState(STATE.FINISHED, 0);
    }
}



//// }
//// Think of this as end of class Main
