import java.util.*;

//TODO comment all code
//TODO use STATEs in a better way



//// Think of this as main class
//// class Main{
    
Game game;
float boardSz; //board size for drawing
STATE state;
MenuBox menuBox;

void setup(){
    size(1200, 900);
    background(50);
    surface.setResizable(true);
    menuBox = new MenuBox(3, 1, 1);
    menuBox.set(0, 0, new TextBox());
    menuBox.set(1, 0, new TextBox());
    menuBox.set(2, 0, new TextBox());
    
    gameStart(); 
    
    // DEBUG code
    // game.winningColor = COLOR.LIGHT;
}

void gameStart(){
    game = new Game();
    state = STATE.SETUP;
}

void draw(){
    background(25);
    
    float cx = width/2, cy = height/2;
    boardSz = Math.min(width, height)*0.95;
    game.draw(cx, cy, boardSz);
    
    
    if(game.winningColor != null){
        cx = width/2;
        cy = height/2;
        float menuWidth = boardSz*1.1, menuHeight = boardSz/2*0.8;
        menuBox.draw(cx, cy, menuWidth, menuHeight);
    }
}



void mousePressed(){
    if(mouseButton == LEFT){
        game.interactMouse(mouseX, mouseY);
    }
    else if(mouseButton == RIGHT){
        game.flipView();
    }
}

void keyPressed(){
    if(key == '\n') game.debugBoard();
    else if(key == '\b' && game.lastMove != null) game.undoMove(game.lastMove, game.lastColor,true);        // DEBUG code
}



//// }
//// Think of this as end of class Main
