import java.util.*;

//TODO comment all code

Game game;
float boardSz = 850; //board size for drawing
boolean frontWhite = true;

void setup(){
    size(1200, 900);
    background(50);
    game = new Game();
    surface.setResizable(true);
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
