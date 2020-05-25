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
    changeState(STATE.SETUP, 0);
}

void changeState(STATE newState, int timer){
    clk = timer;
    nxtState = newState;
}

void updateState(){
    if(nxtState == null) return;
    
    if(nxtState == STATE.SETUP){
        game =  new Game();    
        menuBox = new MenuBox(true, 1, 1, 1, 3);
        menuBox.set(0, 0, "Choose Mode", BOXTYPE.TEXTONLY);
        menuBox.set(3, 1, "Start Game", BOXTYPE.BUTTON);
    }
    else if(nxtState == STATE.PLAYING){
        menuBox = new MenuBox(false, 0, 3, 0);
        menuBox.set(1, 1, "Start New Game", BOXTYPE.BUTTON);
    }
    else if(nxtState == STATE.FINISHED){
        menuBox = new MenuBox(true, 0, 1, 0, 3);
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
    
    
    if(menuBox != null && menuBox.isActive){
        cx = width/2;
        cy = height/2;
        float menuWidth = boardSz*20.0/19.0, menuRowHeight = boardSz/2*0.2;
        menuBox.draw(cx, cy, menuWidth, menuRowHeight);
    }
    if(clk > 0) clk--;
}



void mousePressed(){
    if(clk > 0) return;
    
    if(mouseButton == RIGHT){
        game.flipView();
        return;
    }
    if(curState == STATE.SETUP){
        if(menuBox != null && menuBox.isActive){
            int[] clicked = menuBox.interactMouse(mouseX, mouseY);
            if(Arrays.equals(clicked, new int[]{3, 1})){
                changeState(STATE.PLAYING, 2*animationUnit);
            }
        }
    }
    else if(curState == STATE.PLAYING){   
        if(menuBox == null || !menuBox.isActive){
            boolean interaction = game.interactMouse(mouseX, mouseY);
             if(interaction && game.winningColor != null){
                 changeState(STATE.FINISHED, animationUnit*4);
             }
        }
        else if(menuBox != null && menuBox.isActive){
            int[] clicked = menuBox.interactMouse(mouseX, mouseY);
            if(Arrays.equals(clicked, new int[]{1, 1})){
                changeState(STATE.SETUP, 2*animationUnit);
            }
        }
    }
    else if(curState == STATE.FINISHED){
        if(menuBox != null && menuBox.isActive){
            int[] clicked = menuBox.interactMouse(mouseX, mouseY);
            if(Arrays.equals(clicked, new int[]{3, 1})){
                changeState(STATE.SETUP, 2*animationUnit);
            }
        }
    }
    
}

void keyPressed(){
    if(clk > 0) return;
    
    if(key == '\n') game.debugBoard();
    else if(key == '\b' && game.lastMove != null) game.undoMove(game.lastMove, game.lastColor,true);        // DEBUG code
    else if(key == 'l'){ 
        // DEBUG code
        game.winningColor = COLOR.LIGHT;
        changeState(STATE.FINISHED, 0);
    }
    
    if(key == ESC){
        key = 0;
        if(menuBox != null) 
            menuBox.isActive = !menuBox.isActive;
    }
}



//// }
//// Think of this as end of class Main
