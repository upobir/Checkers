import java.util.*;

//TODO comment all code

Game game;
float boardSz; //board size for drawing
boolean frontWhite;

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
    game.draw(cx, cy, boardSz, frontWhite);
}

void mousePressed(){
    if(mouseButton == LEFT){
        game.interactMouse(mouseX, mouseY);
    }
}

void keyPressed(){
    if(key == ' '){
        frontWhite = !frontWhite;
    }
    else if(key == '\n') game.debugBoard();
}

void start(){
    frontWhite = true;
    game = new Game();
    state = STATE.SETUP;
}
