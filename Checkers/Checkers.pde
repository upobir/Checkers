import java.util.*;

//TODO comment all code
//TODO use STATEs in a better way



//// Think of this as main class
//// class Main{
    
final int animationUnit = 6;
    
    
Game game;
OPPONENT opponent;
GameAI com;
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
        opponent = OPPONENT.PLAYER;
        com = new GameAI(5*animationUnit);
        menuBox = new MenuBox(true, 1, 1, 1, 3);
        menuBox.set(0, 0, "Choose Mode", BOXTYPE.TEXTONLY, null);
        menuBox.set(1, 0, "", BOXTYPE.TEXTONLY, null);
        menuBox.set(2, 0, "VS Player", BOXTYPE.BUTTON, TRIGGER.OPPONENTFLIP);
        menuBox.set(3, 1, "Start Game", BOXTYPE.BUTTON, TRIGGER.STARTGAME);
    }
    else if(nxtState == STATE.PLAYING){
        menuBox = new MenuBox(false, 1, 0, 3);
        menuBox.set(0, 0, "You are playing: Player VS " +opponent.toString(), BOXTYPE.TEXTONLY, null);             
        menuBox.set(2, 1, "Start New Game", BOXTYPE.BUTTON, TRIGGER.STARTMENU);
    }
    else if(nxtState == STATE.FINISHED){
        menuBox = new MenuBox(true, 0, 1, 0, 3);
        String winningText;
        if(opponent == OPPONENT.PLAYER){
            winningText = game.winningColor.toString() + " won!";
        }
        else{
            if(com.playingColor == game.winningColor)
                winningText = "Computer won!";
            else
                winningText = "You won";
        }
        menuBox.set(1, 0, winningText, BOXTYPE.TEXTONLY, null);
        menuBox.set(3, 1, "Start New Game", BOXTYPE.BUTTON, TRIGGER.STARTMENU);
    }
    curState = nxtState;
    nxtState = null;
}

// make drawing dependant on states?
void draw(){
    if(clk == 0) updateState();
    if(clk == 0 && curState == STATE.PLAYING && game.winningColor != null){
        changeState(STATE.FINISHED, 4*animationUnit);
    }
    
    if((menuBox == null || !menuBox.isActive) &&
        opponent == OPPONENT.AI && game.winningColor == null && game.currentPlayingColor == com.playingColor){
        int[] pos = com.reply(game);
        if(pos != null){
            game.interactCell(pos[0], pos[1]);
        }
    }
    
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
        if(opponent == OPPONENT.AI && curState == STATE.SETUP){
            com.setColor((game.whiteFront)? COLOR.DARK : COLOR.LIGHT);
        }
        return;
    }
    if(curState == STATE.SETUP){
        if(menuBox != null && menuBox.isActive){
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);
            if(response == TRIGGER.STARTGAME){
                changeState(STATE.PLAYING, 2*animationUnit);
            }
            else if(response == TRIGGER.OPPONENTFLIP){
                if(opponent == OPPONENT.PLAYER) {
                    opponent = OPPONENT.AI;
                    com.setColor((game.whiteFront)? COLOR.DARK : COLOR.LIGHT);
                    menuBox.changeText(1, 0, "Right click to choose your side", animationUnit);
                }
                else{
                    opponent = OPPONENT.PLAYER;
                    com.setColor(null);
                    menuBox.changeText(1, 0, "", animationUnit);
                }
                menuBox.changeText(2, 0, "VS " + opponent.toString(), 0);
            }
        }
    }
    else if(curState == STATE.PLAYING){
        if(menuBox == null || !menuBox.isActive){
            if(opponent == OPPONENT.AI && game.currentPlayingColor == com.playingColor)
                return;
            game.interactMouse(mouseX, mouseY);
        }
        else if(menuBox != null && menuBox.isActive){
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);
            if(response == TRIGGER.STARTMENU){
                changeState(STATE.SETUP, 2*animationUnit);
            }
        }
    }
    else if(curState == STATE.FINISHED){
        if(menuBox != null && menuBox.isActive){
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);
            if(response == TRIGGER.STARTMENU){
                changeState(STATE.SETUP, 2*animationUnit);
            }
        }
    }
    
}

void keyPressed(){
    if(clk > 0) return;
    
    if(key == '\n') game.debugBoard();
    else if(key == 'l'){ 
        // DEBUG code
        game.winningColor = COLOR.LIGHT;
        changeState(STATE.FINISHED, 0);
    }
    else if(key == 'h'){
        println(game.heuristic);
    }
    
    if(key == ESC){
        key = 0;
        if(menuBox != null) 
            menuBox.isActive = !menuBox.isActive;
    }
}



//// }
//// Think of this as end of class Main
