import java.util.*;



//// Think of this as main class
//// class Main{
    
//All animation delays use this as unit
final int animationUnit = 6;
    
// game variables; game object, opponent type and ai object.    
Game game;
OPPONENT opponent;
GameAI com;

// drawing variabls; boardSize which is calculated every frame, animation timer clock, state of the full app, menu object
float boardSz;
int clk;
STATE curState;
STATE nxtState;
MenuBox menuBox;

// initialization of app
void setup(){
    size(1200, 900);
    background(50);
    surface.setResizable(true);    // the screen can be resized
    changeState(STATE.SETUP, 0);   // start with setup state
}

// function that schedules a change of state
void changeState(STATE newState, int timer){
    clk = timer;
    nxtState = newState;
}

// function that is called every frame to make any scheduled changes to state
void updateState(){
    if(nxtState == null) return;
    
    if(nxtState == STATE.SETUP){        //settin up game, ai with new objects.
        game =  new Game();   
        opponent = OPPONENT.PLAYER;     
        com = new GameAI(5*animationUnit);          //ai has 5 unit delay for moves
        menuBox = new MenuBox(true, 1, 1, 1, 3);    //menuBox has 4 rows
        menuBox.set(0, 0, "Choose Mode", BOXTYPE.TEXTONLY, null);
        menuBox.set(1, 0, "", BOXTYPE.TEXTONLY, null);
        menuBox.set(2, 0, "VS Player", BOXTYPE.BUTTON, TRIGGER.OPPONENTFLIP);
        menuBox.set(3, 1, "Start Game", BOXTYPE.BUTTON, TRIGGER.STARTGAME);
    }
    else if(nxtState == STATE.PLAYING){    // during playing the pause menu starts hidden
        menuBox = new MenuBox(false, 1, 0, 3);    //menu has 3 rows
        menuBox.set(0, 0, "You are playing: Player VS " +opponent.toString(), BOXTYPE.TEXTONLY, null);             
        menuBox.set(2, 1, "Start New Game", BOXTYPE.BUTTON, TRIGGER.STARTMENU);
    }
    else if(nxtState == STATE.FINISHED){   //after finishing menu has only one button to take back to startup
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

// drawing every frame, first checks for any change to state, then asks ai if it's ai's turn, then draws everything.
void draw(){
    if(clk == 0) updateState();                //clk = 0 means time to update any scheduled state changes
    if(clk == 0 && curState == STATE.PLAYING && game.winningColor != null){    //if game is finished schedule change of state
        changeState(STATE.FINISHED, 4*animationUnit);
    }
    
    if((menuBox == null || !menuBox.isActive) &&                //if it's vs ai and it's ai's turn, ask for a response
        opponent == OPPONENT.AI && game.winningColor == null && game.currentPlayingColor == com.playingColor){
        int[] pos = com.reply(game);
        if(pos != null){                                    //if ai did reply interact that cell directly
            game.interactCell(pos[0], pos[1]);
        }
    }
    
    //Drawing
    background(25);
    
    float cx = width/2, cy = height/2;
    boardSz = Math.min(width, height)*0.95;
    game.draw(cx, cy, boardSz);                    //after setting center positions from current window, tell game to draw there.
    
    
    if(menuBox != null && menuBox.isActive){            //if menu is active draw that on top.
        cx = width/2;
        cy = height/2;
        float menuWidth = boardSz*20.0/19.0, menuRowHeight = boardSz/2*0.2;
        menuBox.draw(cx, cy, menuWidth, menuRowHeight);
    }
    if(clk > 0) clk--;                        //update timer
}

// event handling where mouse is pressed.
void mousePressed(){
    if(clk > 0) return;        //if animation delay timer is on, no click will be recorded.
    
    if(mouseButton == RIGHT){    //right click means always change view.
        game.flipView();
        if(opponent == OPPONENT.AI && curState == STATE.SETUP){        //when it's setup stage and vs ai is selected right click also means chooseing player color
            com.setColor((game.whiteFront)? COLOR.DARK : COLOR.LIGHT);    //give ai color according to view.
        }
        return;
    }
    if(curState == STATE.SETUP){                    //in setup stage.
        if(menuBox != null && menuBox.isActive){
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);     //get response trigger, if any, due to the click from menu
            if(response == TRIGGER.STARTGAME){                            // if trigger was of startgame, then schedule a change to playing state.
                changeState(STATE.PLAYING, 2*animationUnit);
            }
            else if(response == TRIGGER.OPPONENTFLIP){                    // if trigger was changing mode, then change mode and change text at second row.
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
    else if(curState == STATE.PLAYING){        // in playing stage.
        if(menuBox == null || !menuBox.isActive){        // if menubox is not active interact with game
            if(opponent == OPPONENT.AI && game.currentPlayingColor == com.playingColor)    //if however it is ai's turn, ignore the click
                return;
            game.interactMouse(mouseX, mouseY);
        }
        else if(menuBox != null && menuBox.isActive){        //if menubox is active, interact with menu
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);
            if(response == TRIGGER.STARTMENU){                //if response was to startup, then schedule change to setup stage.
                changeState(STATE.SETUP, 2*animationUnit);
            }
        }
    }
    else if(curState == STATE.FINISHED){    // in finished stage.
        if(menuBox != null && menuBox.isActive){        //interact if menu is active
            TRIGGER response = menuBox.interactMouse(mouseX, mouseY);
            if(response == TRIGGER.STARTMENU){            //if trigger to startupis returned schedule change to setup
                changeState(STATE.SETUP, 2*animationUnit);        
            }
        }
    }
    
}

void keyPressed(){
    if(clk > 0) return;        //ignore key press when animation delay is on
    
    if(key == ESC){            // if escape was clicked, first override key to make sure processing doesn't close then change active status of menu
        key = 0;
        if(menuBox != null) 
            menuBox.isActive = !menuBox.isActive;
    }
    else if(key == 'c'){       //special key pressing changes ai's side, if it's vs ai.
        if(opponent == OPPONENT.AI){
            com.setColor(com.playingColor.opposite());
        }
    }
}



//// }
//// Think of this as end of class Main
