import java.util.*;

//TODO comment all code

Game game;
float boardSz; //board size for drawing
STATE state;

void setup(){
    size(1200, 900);
    background(50);
    surface.setResizable(true);
    start(); 
}

void draw(){
    background(25);
    float cx = width/2, cy = height/2;
    boardSz = Math.min(width, height)*0.95;
    game.draw(cx, cy, boardSz);
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
}

void start(){
    game = new Game();
    state = STATE.SETUP;
}
