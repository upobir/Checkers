import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Checkers extends PApplet {





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
public void setup(){
    
    background(50);
    surface.setResizable(true);    // the screen can be resized
    changeState(STATE.SETUP, 0);   // start with setup state
    return;
}

// function that schedules a change of state
public void changeState(STATE newState, int timer){
    clk = timer;
    nxtState = newState;
    return;
}

// function that is called every frame to make any scheduled changes to state
public void updateState(){
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
    return;
}

// drawing every frame, first checks for any change to state, then asks ai if it's ai's turn, then draws everything.
public void draw(){
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
    boardSz = Math.min(width, height)*0.95f;
    game.draw(cx, cy, boardSz);                    //after setting center positions from current window, tell game to draw there.
    
    
    if(menuBox != null && menuBox.isActive){            //if menu is active draw that on top.
        cx = width/2;
        cy = height/2;
        float menuWidth = boardSz*20.0f/19.0f, menuRowHeight = boardSz/2*0.2f;
        menuBox.draw(cx, cy, menuWidth, menuRowHeight);
    }
    if(clk > 0) clk--;                        //update timer
    return;
}

// event handling where mouse is pressed.
public void mousePressed(){
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
    return;
}

public void keyPressed(){
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
    return;
}



//// }
//// Think of this as end of class Main
//file for all enum classes

// enum for colors;
public enum COLOR{
    
    // final color lightPieceColor = color(255, 249, 244);
    // final color darkPieceColor = color(196, 0, 3);
    
    LIGHT(255<<24 | 255<<16 | 249<<8 | 244), DARK(255<<24 | 196<<16 | 0<<8 | 3);        //using integer masked color because enum won't allow color static, for values see above comment
    
    public int drawColor;            //color
 
    private COLOR(int drawColor){
        this.drawColor = drawColor;
    }
    
    //printing as string
    public String toString(){
        if(this == LIGHT) return "White";
        else              return "Red";
    }
    
    //opposite color that makes logical stuff easy
    public COLOR opposite(){
        if(this == LIGHT) return DARK;
        else              return LIGHT;
    }
    
    //sign in heuristic value, since heurstic is white - red.
    public int sign(){
        if(this == LIGHT) return 1;
        else              return -1;
    }
  
}

//enum for piece type.
public enum TYPE{
    SOLDIER(1000), KING(3000);
    
    public int value;    //value in heuristic
    
    private TYPE(int val){
        this.value = val;
    }
}

//enum for state of game.
public enum STATE{
    SETUP, PLAYING, FINISHED
}

//enum for text box type in menu
public enum BOXTYPE{
    TEXTONLY, BUTTON
}

//enum for opponent type.
public enum OPPONENT{
    PLAYER("Player"), AI("Computer");
    
    public String string;        //string that will be shown in menu
    
    private OPPONENT(String string){
        this.string = string;
    }
    
    //to print to menu
    public String toString(){
        return this.string;
    }
}

//button trigger enum
public enum TRIGGER{
    STARTMENU, STARTGAME, OPPONENTFLIP
}
//would have set these as static if processing'd let me -_-

// variables that should be static of game
final int lightCellColor = color(255, 238, 187);
final int darkCellColor = color(85, 136, 34);
final int highlightColor = color(255, 255, 0);
final int multijumpHighlightColor = color(248, 150, 0);
final int availableMoveColor = color(0, 0, 0);
final int gridSz = 8;
final COLOR startingColor = COLOR.DARK;

// game object
class Game{
    //game variables, the board, active pieces map with their positions, current playing color, winning Color, list of valid mvoes for current player
    //the board is assumed s.t. red pieces will be on row 0, 1, 2 and whites will be on 5, 6, 7
    Piece board[][];
    Map<Piece, int[]> activePieces;
    COLOR currentPlayingColor;
    ArrayList<Move> validMoves;
    COLOR winningColor;
    
    // Algorithm variables, heuristic for ai to use
    int heuristic;
    
    //drawing variables, bounding box, cell side length, border length, whether white is towards the front or not
    float xlo, ylo, xhi, yhi;
    boolean whiteFront;
    float cellSize, borderSpace;
    
    //IO variables, reference to a selected piece
    Piece highlightedPiece;
    
    //construct the game put everyone on board using utility functions.
    public Game(){
        board = new Piece[gridSz][gridSz];
        activePieces = new HashMap<Piece, int[]>();
        validMoves = new ArrayList<Move>();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){            //Initializing dark pieces on row 0, 1, 2 & light pieces on row 5, 6, 7
                if((i+j)%2 == 0) continue;
                if(i < 3) 
                    changePiecePosition(new Piece(COLOR.DARK, TYPE.SOLDIER, gridSz-1), null, new int[]{i, j});
                if(i >= gridSz-3) 
                    changePiecePosition(new Piece(COLOR.LIGHT, TYPE.SOLDIER, 0), null, new int[]{i, j});
            }    
        
        highlightedPiece = null;
        winningColor = null;
        
        whiteFront = (startingColor == COLOR.LIGHT);        //set whitefront accordingly, starting color is generally kept at front
        setPlayer(startingColor, null);        //set player to starting Color
    }
    
    //return a logical copy of the game, by using utility functions to set color and set pieces on board
    public Game copy(){
        Game clone = new Game();
        //cloning board
        clone.board = new Piece[gridSz][gridSz];
        clone.activePieces = new HashMap<Piece, int[]>();
        clone.validMoves = new ArrayList<Move>();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if(board[i][j] != null){
                    Piece clonePiece = board[i][j].copy();
                    clone.changePiecePosition(clonePiece, null, new int[]{i, j});
                }
            }
        clone.setPlayer(currentPlayingColor, null);
        //clone winning color
        clone.winningColor = winningColor;
        clone.heuristic = heuristic;
        return clone;
    }
    
    //draw function to be called with x, y bounds and board length
    public void draw(float centerX, float centerY, float boardSz){
        borderSpace = boardSz*0.011f;                    //calculating border space to be kept
        
        //calculating drawing varibales like inner dimensions and cell size 
        float innerBoardSz = boardSz - borderSpace*2; 
        xlo = centerX - innerBoardSz/2;
        xhi = centerX + innerBoardSz/2;
        ylo = centerY - innerBoardSz/2;
        yhi = centerY + innerBoardSz/2;
        cellSize = innerBoardSz / gridSz;
        
        //call to draw individual components, board, piece, highlights
        drawBoard();
        drawPieces();
        drawHighlights();
        return;
    }
    
    //draws board given bounding box
    private void drawBoard(){
        //drawing full board with border first, using current player color, so border will signify whose turn it is
        rectMode(CORNERS);
        fill(currentPlayingColor.drawColor);
        noStroke();
        rect(xlo - borderSpace, ylo - borderSpace, xhi + borderSpace, yhi + borderSpace);
        
        //draw the individual cells, alternatingly, using map to find center of each cell.
        rectMode(CENTER);
        noStroke();
        for(int i = 0; i<gridSz; i++)
            for(int j = 0; j<gridSz; j++){
                if((i+j)%2 == 0) fill(lightCellColor);
                else             fill(darkCellColor);
                
                float x = map(j+0.5f, 0, gridSz, xlo, xhi);
                float y = map(i+0.5f, 0, gridSz, ylo, yhi);
                rect(x, y, cellSize, cellSize);
            }
        
        return;
    }
    
    //draws pieces given bounding box of board.
    private void drawPieces(){
        //for each cell drawing a piece if it's there.
        for(int i = 0; i<board.length; i++)
            for(int j = 0; j<board[i].length; j++){
                Piece cellPiece = board[i][j];
                if(cellPiece != null){
                    //using center s.t. flipping is easier
                    float x = map(j+0.5f, 0, gridSz, xlo, xhi);
                    float y = map(i+0.5f, 0, gridSz, ylo, yhi);
                      
                     //if whitefront is false flip them
                    if(!whiteFront){
                        x = xlo + xhi - x;
                        y = ylo + yhi - y;
                    }
                     
                    cellPiece.draw(x, y, cellSize);     //call pieces to draw themselves
                }
            }
        return;
    }
    
    //drawing highlighted pieces and cells
    private void drawHighlights(){
        //for each valid move, highlight the moving pieces with available move color
        for(Move move : validMoves){
            board[move.from[0]][move.from[1]].highlight(availableMoveColor, false);
        }
        if(highlightedPiece == null) return;    //if no selected piece return
        
        highlightedPiece.highlight(highlightColor, true);    //call the highlighted piece to hightlight itself with highlight Color

        //get valid moves for highlighted piece to highlight those cells by drawing stroked border
        List<Move> highlightMoves = getValidMovesFor(highlightedPiece);
        for(Move move: highlightMoves){
            int i = move.to[0], j = move.to[1];
            float y = map(i+0.5f, 0, gridSz, ylo, yhi);
            float x = map(j+0.5f, 0, gridSz, xlo, xhi);
            
            //flip the x, y if not whitefront
            if(!whiteFront){
                x = xlo + xhi - x;
                y = ylo + yhi - y;
            }
            
            //draw the border to hightight
            noFill();
            //check if this will result in multijump, if it will use differentcolor
            if(!futureJumpPossible(move)) stroke(highlightColor);
            else                          stroke(multijumpHighlightColor);
            strokeJoin(ROUND);
            strokeWeight(cellSize*0.06f);
            rectMode(CENTER);
            rect(x, y, cellSize, cellSize);
        }        
        return;
    }
    
    //given a move checks whether this can result in multi jump
    private boolean futureJumpPossible(Move move){
        if(!move.isCapturing()) return false;    //if the move is not capturing return false
        
        //create a virtual board which will contain the same pieces, but moving around here won't affect real board
        Piece[][] virtualBoard = new Piece[gridSz][];
        for(int i = 0; i<gridSz; i++)
            virtualBoard[i] = board[i].clone();
        
        //positions of the moving piece and capturing piece 
        int[] oldP = move.from;
        int[] newP = move.to;
        int[] capP = new int[]{ (oldP[0] + newP[0])/2, (oldP[1] + newP[1])/2 };
        
        //move the pieces accoring to capture move
        Piece movingPiece = virtualBoard[oldP[0]][oldP[1]];
        virtualBoard[oldP[0]][oldP[1]] = null;
        virtualBoard[newP[0]][newP[1]] = movingPiece;
        virtualBoard[capP[0]][capP[1]] = null;
        
        //find moves for the piece using this virtual board and vitual position to see if another capture is possible
        //do not need to consider kingingk, since kinging stops the move and kinged soldier cannot move backwards anyway
        List<Move> futureMoveList = movingPiece.getMoves(virtualBoard, newP[0], newP[1]);
        for(Move futureMove: futureMoveList){
            if(futureMove.isCapturing())
                return true;
        }
        return false;    //no capturing move found : return false;
    }
    
    
    //reverse the view
    public void flipView(){
        whiteFront = !whiteFront;
        return;
    }
    
    //setiing current playing color, use this at beginning of each turn, the enforcedpiece is for when this is part of multijump
    //so only one piece will be allowed to move.
    private void setPlayer(COLOR nxtColor, Piece enforcedPiece){
        if(winningColor != null) return;        //if game is not over
        
        //set color, clear heuristic, compute validMoves, if empty this means game is over, make opposite color winning
        currentPlayingColor = nxtColor;
        heuristic = 0;
        computeValidMoves(enforcedPiece);
        if(validMoves.isEmpty()){
            winningColor = currentPlayingColor.opposite(); 
        }
        return;
    }
    
    //computing valid moves for current player, if enforcePiece is not null, add moves only valid for that piece
    private void computeValidMoves(Piece enforcedPiece){
        if(winningColor != null) return;            //if game is not over
        
        //clear valid moves
        validMoves.clear();
        
        //for each active piece find it's moves possible capturing or not, add only those which are for current color and use enforce piece (if not null)
        //during this process also add heuristics
        for(Map.Entry<Piece, int[]> entry: activePieces.entrySet()){        
            //get info on piece, use it to see whether this will get boost score for capturing
            int i = entry.getValue()[0], j = entry.getValue()[1];
            heuristic += entry.getKey().heuristic(i, j);
            int extraCaptureScore = (entry.getKey().pieceColor == currentPlayingColor)? 3 : 0;    //boost for capturing moves
            
            //find mvoes for the piece from piece's function
            //add to heuristic for each move, with capturing boost
            List<Move> movesForPiece = entry.getKey().getMoves(board, i, j);
            for(Move move : movesForPiece){
                if(move.isCapturing())
                    heuristic += entry.getKey().pieceColor.sign() * (15 + extraCaptureScore);
                else
                    heuristic += entry.getKey().pieceColor.sign() * 1;
            }
            
            //if color is wrong or not enforced to the input piece continue;
            if(entry.getKey().pieceColor != currentPlayingColor) continue;
            if(enforcedPiece != null && enforcedPiece != entry.getKey()) continue;
            
            //add moves
            validMoves.addAll(movesForPiece);
        }
        
        //make a new list for only capturing moves and populate it with the valid moves which are capturing
        ArrayList<Move> capturingMoves = new ArrayList<Move>();
        for(Move move : validMoves){
            if(move.isCapturing()){
                capturingMoves.add(move);
            }
        }
        
        //if capturing moves found use only those for valid moves
        if(!capturingMoves.isEmpty()){
            validMoves = capturingMoves;
        }
        return;
    }
    
    //utility function, get valid moves for one piece from precomputed validMoves
    private List<Move> getValidMovesFor(Piece piece){
        if(winningColor != null) return null;     //if game is not over
        
        //fill list of moves with valid moves form validmoves list where the moving piece is input piece
        List<Move> ret = new LinkedList<Move>();
        for(Move move: validMoves){
            int[] pos = move.from;
            if(board[pos[0]][pos[1]] == piece)
                ret.add(move);
        }
        return ret;        //return the list of moves.
    }
    
    
    //calling function when mouse interacted on (mx, my)
    public void interactMouse(float mx, float my){
        if(winningColor != null) return;        //if game is not over
        
        //if click was not inside board do nothing
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return;
        
        //flip the coordinates if not whitefront
        if(!whiteFront){
            mx = xlo + xhi - mx;
            my = ylo + yhi - my;
        }
        
        //map to the cell clicked on and interac with that cell
        float x = map(mx, xlo, xhi, 0, gridSz);
        float y = map(my, ylo, yhi, 0, gridSz);
        int j = Math.round(x-0.5f+0.001f);
        int i = Math.round(y-0.5f+0.001f);
        interactCell(i, j);
        
        return;
    }
    
    //calling function to directly interact with cell [i][j]
    public void interactCell(int i, int j){
        if(winningColor != null) return;        //if game is not over
        
        Piece cellPiece = board[i][j];         //the piece that is on cell [i][j]
        
        if(cellPiece != null){        //if the cell we clicked on, had a piece on it
            if(cellPiece == highlightedPiece){    //if it was hightlighted, un-highlight it
                highlightedPiece = null;
                return;
            }
            else if(cellPiece.pieceColor == currentPlayingColor && !getValidMovesFor(cellPiece).isEmpty()){    //if it was not highlighted and is of current color, highlight it 
                highlightedPiece = cellPiece;
                return;
            }
        }
        else{                        //if the cell we clicked on, was empty
            if(highlightedPiece != null){            //if some piece was hightlighted
                //get valid moves for highlighted piece to see if interacted cell was one of those moves' to position
                List<Move> interactableMoves = getValidMovesFor(highlightedPiece);
                
                for(Move move: interactableMoves){
                    if(move.to[0] == i && move.to[1] == j){        //if the interacted cell is of one of the moves, apply that move, clear highlighting
                        applyMove(move);
                        highlightedPiece = null;
                        return;
                    }
                }
            }
        }
        return;
    }
    
    
    //given a move, apply it.
    public void applyMove(Move move){
        if(winningColor != null) return ;         //if game is not over
        
        //get the moving piece, change it to 'to' position of move using utility
        Piece movingPiece = board[move.from[0]][move.from[1]];
        changePiecePosition(movingPiece, move.from, move.to);
        
        //if the move was capturing, change the captured piece's position to null, to remove it, using utillity
        if(move.isCapturing()){
            changePiecePosition(move.capturedPiece, activePieces.get(move.capturedPiece), null);
        }
        
        //if the moving piece was soldier and it got to it's kinging row, assign the move to be kinging
        //and update the piece's type to king
        if(movingPiece.type == TYPE.SOLDIER && move.to[0] == movingPiece.kingingRow){
            movingPiece.changeType(TYPE.KING);
            move.isKingingMove = true;
        }
        
        //check if the move will result in more jumps
        boolean multijump = false;
        //check if multi-jump is possible, only when this move itself was jumping and piece was not kinged this move
        //in which case get moves for that piece on the new board and see if any of those moves are capturing
        if(move.isCapturing() && !move.isKingingMove){            
            List<Move> moreMoves = movingPiece.getMoves(board, move.to[0], move.to[1]);
            for(Move newMove: moreMoves){
                if(newMove.isCapturing()){
                    multijump = true;
                    break;
                }
            }
        }
        
        if(multijump){            //if multijump is possible set the same color again, with moving piece being enforced
            setPlayer(currentPlayingColor, movingPiece);
        }
        else{                     //else set color to opposite for other color's turn with no enforcement piece 
            setPlayer(currentPlayingColor.opposite(), null);
        }
        return;
    }
    
    //given the last move and color that was before the last move, perform soft undo.
    //this is a soft undo, meaning that after the undo, validMoves list will not really be valid.
    public void softUndoMove(Move move, COLOR prvPlayerColor){
        if(winningColor != null) winningColor = null;                    //if game is over, undo it
        
        heuristic = 0;        //clear heuristi
        
        //get the moving piece from move and change it to soldier if the move was kinging
        Piece movingPiece = board[move.to[0]][move.to[1]];
        if(move.isKingingMove) movingPiece.changeType(TYPE.SOLDIER);
        
        //change the piece's position from 'to' to 'from'
        changePiecePosition(movingPiece, move.to, move.from);
        
        //if the move was capturing, put the capured piece back onto the board, computing the captured position
        if(move.isCapturing()){
            int[] capP = new int[]{(move.from[0] + move.to[0])/2, (move.from[1] + move.to[1])/2};
            changePiecePosition(move.capturedPiece, null, capP);
        }
        
        //set playing color to input color
        currentPlayingColor = prvPlayerColor;
        return;
    }
    
    //utility funciton, chaging piece position by inserting it, deleting it or just changing it.
    //if from is null, the piece is being added, if to is null, the piece is being deleted.
    private void changePiecePosition(Piece piece, int[] from, int to[]){
        if(winningColor!= null) return;             //if not game over
        
        /*
        //checking not necessary in current usage
        assert from != null || to != null;
        if(from != null) assert board[from[0]][from[1]] == piece;
        if(to != null) assert board[to[0]][to[1]] == null;
        */
        
        //if from was not null, remove piece from 'from' position on board
        if(from != null) 
            board[from[0]][from[1]] = null;
        
        //if to was not null, add the piece to 'to' postion, additonally remove it from active set
        //otherwise just using put inserts it too.
        if(to != null){ 
            board[to[0]][to[1]] = piece;
            activePieces.put(piece, to);
        }
        else
            activePieces.remove(piece);
        return;
    }
    
    //debug funticon, prints board to console, white side is considered to be at bottom.
    public void debugBoard(){
        for(int i = 0; i<gridSz; i++){
            for(int j = 0; j<gridSz; j++){
                if(board[i][j] == null) print(" - ");
                else if(board[i][j].pieceColor == COLOR.LIGHT) print(" L ");
                else print(" D ");
            }
            println();
        }
        println();
        println();
    }
    
}
//Class of game ai that decides what move to apply given the game
class GameAI{
    // logical variables; color of ai's side, copy of the virtual game, maximum depth of backtrack
    public COLOR playingColor;
    private Game virtualGame;
    private final int maxDepth = 9;
    
    // IO variables; delay done before interacting with the game, timer for that, queue of interacts, boolean to ignore first frame when ai is called
    // (this is to make sure the board is first drawn, before ai starts backtrack
    private int delay, timer;
    private Queue<int[]> clicks;
    private boolean oneFrameIgnore;
    
    //setting delay for each interactin in constructor
    public GameAI(int delay){
        this.delay = delay;
        this.clicks = new LinkedList<int[]>();
    }
    
    // assigning color to ai, however since this can occur inside the game, everything is cleared
    // the timer, frame ignore boolean, game, clicks everything
    public void setColor(COLOR playingColor){
        this.playingColor = playingColor;
        timer = 0;
        oneFrameIgnore = false;
        virtualGame = null;
        clicks.clear();
        return;
    }
    
    // Given the game object return the interaction cell via this function
    public int[] reply(Game game){
        if(timer == 0){                    //if timer is 0, then this is a new turn, so first find best move
            if(!oneFrameIgnore){           //however first see if one frame has been ignored, if not then ignore this call after setting to true
                oneFrameIgnore = true;
                return null;
            }
            
            //set timer for delay and make copy of game
            timer = delay;                
            virtualGame = game.copy();
            if(virtualGame.winningColor != null)    //if game is finished no interaction can be returned
                return null;
            
            Move chosenMove = findBestMove();    //find best move
            
            //add moves to queue, first from cell, then to cell; and return nothing (will return after timer is 1)
            clicks.add(chosenMove.from.clone());
            clicks.add(chosenMove.to.clone());
            return null;
        }
        else if(timer == 1){            //if timer = 1, it will reset, so before resetting return click from queue
            int[] ret = clicks.poll();
            if(clicks.isEmpty()){        //if queue is empty then interaction is finished let timer go to 0 and reset everything, otherwise reset timer to delay for next click
                timer--;
                virtualGame = null;
                oneFrameIgnore = false;
            }
            else{
                timer = delay;
            }
            return ret;
        }
        else{                        //otherwise timer is running let it decrease
            timer--;
            return null;
        }
    }
    
    //this function finds best move by starting the backtrack.
    //this uses minimax algo with alpha beta pruning, score beingh (white - red)
    private Move findBestMove(){
        boolean AIisMaximizing = (playingColor == COLOR.LIGHT);    //first figure out whether ai is the maximimizing player, if white maximizing, if red minimizing
        
        // make a copy of the valid moves and shuffle it for randomness in finding best move
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        
        if(validMoves.size() == 1){        //if only one move is allowed, nothing to compute return that move.
            return validMoves.get(0);
        }
        
        //setup variables for maintaining alpha beta and best move and best value;
        List<Move> goodMoves = new LinkedList<Move>();
        int bestVal = (AIisMaximizing)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        int alpha = Integer.MIN_VALUE, beta = Integer.MAX_VALUE;
        
        COLOR currentColor = virtualGame.currentPlayingColor;    //remember currentColor, because it will be used in soft undo
        for(Move move : validMoves){
            //apply move, backtrack, undo move
            virtualGame.applyMove(move);
            int possibleVal = backtrack(1, !AIisMaximizing, alpha, beta);
            virtualGame.softUndoMove(move, currentColor);
            
            if((AIisMaximizing && possibleVal > bestVal) || (!AIisMaximizing && possibleVal < bestVal)){    // if better value found clear current good moves and start with new good move
                bestVal = possibleVal;
                goodMoves.clear();
                goodMoves.add(move);
            }
            else if(possibleVal == bestVal){        // if equally good move found add move to good moves;
                goodMoves.add(move);
            }
            
            //update alpha beta range
            if(AIisMaximizing)
                alpha = Math.max(alpha, possibleVal);
            else
                beta = Math.min(beta, possibleVal);
        }
        
        //return a random good move among the found
        int randomIndex = (int) random(goodMoves.size());
        return goodMoves.get(randomIndex);
    }
    
    //the generic backtrack of minimax with alpha beta pruning that returns just best score
    private int backtrack(int depth, boolean maximizingPlayer, int alpha, int beta){
        if(depth == maxDepth || virtualGame.winningColor != null){        //if at maximum depth or end of game return the heuristic
            return virtualGame.heuristic;
        }

        //copy validmoves
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        
        //maintain best value seen
        int bestVal = (maximizingPlayer)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        
        //remember color for soft undo
        COLOR currentColor = virtualGame.currentPlayingColor;
        for(Move move : validMoves){
            //apply move, backtrack, undo move
            virtualGame.applyMove(move);
            int possibleVal = backtrack(depth+1, !maximizingPlayer, alpha, beta);
            virtualGame.softUndoMove(move, currentColor);
            
            //update if better value found
            if((maximizingPlayer && possibleVal > bestVal) || (!maximizingPlayer && possibleVal < bestVal)){
                bestVal = possibleVal;
            }
            
            //update alpha beta range
            if(maximizingPlayer)
                alpha = Math.max(alpha, possibleVal);
            else
                beta = Math.min(beta, possibleVal);
                
            //if alpha-beta range is squished, we have found the best value.  
            if(beta <= alpha)
                break;
        }
        
        return bestVal;    //return best value
    }
}
// Since I chose not to use any native GUI, this is just a a simple simulation of genenric menu or boxes.

// class to represent menus in startup, game and finish
class MenuBox{
    // drawing variabls
    private final int bodyColor = color(163, 74, 180);
    private float xlo, ylo, xhi, yhi;
    
    // IO variable, whether the menu is on or not
    public boolean isActive;
    
    // Container of textboxes
    private TextBox [][] boxes;
    
    //constructor that has arguments of whether the menu is on at first and the columns in each entry passed with varargs
    public MenuBox(boolean isActive , int ... rowsDesc){
        boxes = new TextBox[rowsDesc.length][];
        for(int i = 0; i<rowsDesc.length; i++)        //initialize only the rows, but the entries will be still null
            boxes[i] = new TextBox[rowsDesc[i]];
        this.isActive = isActive;
    }
    
    //setting string to textBox at [i][j] with type and return trigger
    public void set(int i, int j, String string, BOXTYPE type, TRIGGER trigger){
        try{
            boxes[i][j] = new TextBox(string, type, trigger);
        } catch (ArrayIndexOutOfBoundsException e){            //this is for catching bus
            e.printStackTrace();
        }
        return;
    }
    
    //changing string of textbox at [i][j], with given delay, that is this delay will be added on already present delay
    public void changeText(int i, int j, String string, int addedDelay){
        try{
            if(boxes[i][j] == null) return;
            boxes[i][j].changeText(string, addedDelay);
        } catch (ArrayIndexOutOfBoundsException e){           //this is for catching bugs
            e.printStackTrace();
        }
        return;
    }
    
    //drawing function given center coordinate and full width and individual row height
    public void draw(float cx, float cy, float menuWidth, float menuRowHeight){
        //calculate bounding box values
        float menuHeight = menuRowHeight * boxes.length;        //first calculate full menu height from row height
        xlo = cx - menuWidth/2;
        xhi = cx + menuWidth/2;
        ylo = cy - menuHeight/2;
        yhi = cy + menuHeight/2;
        
        //draw the rectangle body first
        rectMode(CORNERS);
        noStroke();
        fill(bodyColor);
        rect(xlo, ylo, xhi, yhi);
        
        //the space between textboxes are borderSpace, this is calculated using smaller dimension
        //using borderspace dimension for textbox is calculated and sent to textbox
        float borderSpace = Math.min(menuWidth, menuHeight) * 0.03f;
        float boxHeight = (yhi-ylo)/boxes.length - borderSpace * 2;
        for(int i = 0; i<boxes.length; i++){
            float boxCY = map(i+0.5f, 0, boxes.length, ylo, yhi);
            float boxWidth = (xhi-xlo)/boxes[i].length - borderSpace * 2;
            for(int j = 0; j<boxes[i].length; j++){
                if(boxes[i][j] == null) continue;
                float boxCX = map(j+0.5f, 0, boxes[i].length, xlo, xhi);
                boxes[i][j].draw(boxCX, boxCY, boxWidth, boxHeight);        //call textbox to draw itself giving cooridinates and dimensions
            }
        }
        return;
    }
    
    // check if mouse click at (mx, my) interacts with menu and if it does
    // return trigger.
    public TRIGGER interactMouse(float mx, float my){
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return null;     //if click is outside boundary return null
        
        //check each textbox for whether it got the click
        for(int i = 0; i<boxes.length; i++){
            for(int j = 0; j<boxes[i].length; j++){
                TextBox box = boxes[i][j];
                if(box == null || box.type != BOXTYPE.BUTTON) continue;    //only check on buton type boxes
                if(box.clickedOn(mx, my)){        //call box to check if it got click, if it did return that box's trigger.
                    return box.trigger;
                }
            }
        }
        return null;    //no click, return null
    }
}
//class to represent moves of pieces
class Move{
    public int[] from, to;            // moving piece's old and new position
    public boolean isKingingMove;     // was the moving piece kinged in this move
    public Piece capturedPiece;       // if any piece was captured keep a reference to it.
    
    //constructor with from and to positions, assuming the move is not kinging
    public Move(int fi, int fj, int ti, int tj){
        from = new int[]{ fi, fj };
        to = new int[]{ ti, tj };
        isKingingMove = false;
    }
    
    // given a copied board, returns a copy of this move for
    // capturedpiece's copy from the copied board is used.
    public Move copy(Piece[][] copiedBoard){
        Move clone = new Move(from[0], from[1], to[0], to[1]);
        clone.isKingingMove = isKingingMove;
        if(capturedPiece != null){
            int capI = (from[0]+to[0])/2, capJ = (from[1]+to[1])/2;
            clone.capturedPiece = copiedBoard[capI][capJ];
        }
        return clone;
    }
    
    //check if the move was capturing
    public boolean isCapturing(){
        return (capturedPiece != null);
    }
    
    //set the piece captured by this move.
    public void setCaptured(Piece cap){
        capturedPiece = cap;
        return;
    }
}
//class for piece
class Piece{
    
    //piece game properties, color, type, kinging row, movement directions
    int[][] movementVector;
    COLOR pieceColor;
    TYPE type;
    int kingingRow;
    
    //drawing variables
    float x, y;
    float diam;
    
    //constructor with color, type and kinging row
    public Piece(COLOR pieceColor, TYPE type, int kingingRow){
        this.pieceColor = pieceColor;
        this.kingingRow = kingingRow;
        changeType(type);
    }
    
    //return a logical copy of the piece
    public Piece copy(){
        Piece clone = new Piece(pieceColor, type, kingingRow);
        clone.movementVector = movementVector.clone();
        return clone;
    }
    
    //heuristic function, uses type based value and for soldiers additionally adds more if nearer to kinging row
    public int heuristic(int i, int j){
        int score = type.value;
        if(type == TYPE.SOLDIER){
            score += (gridSz-Math.abs(i-kingingRow))*100;
        }
        return score * pieceColor.sign();
    }
    
    // drawing the piece given center coordinate and cell side length
    public void draw(float cx, float cy, float cellSize){
        //calculate diameter
        x = cx;
        y = cy;
        diam = 0.75f*cellSize;
        
        //draw the circular boundary
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(diam*0.026f);

        //draw the circular piece with color
        fill(pieceColor.drawColor);
        ellipse(x, y, diam, diam);
        
        //if it's a king draw the crown.
        if(type == TYPE.KING){
            drawCrown();
        }
        return;
    }
    
    //drawing the crown for king pieces
    private void drawCrown(){
        //translate to center for ease of drawing
        pushMatrix();
        translate(x, y);
        
        //draw the crown with chosen scales.
        stroke(0);
        strokeWeight(diam * 0.026f);
        fill(255, 255, 0);
        
        float bottomHalf = 0.22f;
        float topHalf = 0.28f;
        float heightHalf = 0.15f;
        float crownMiddleHalf = 0.115f;
        
        //the crown is drawn clockwise from the lower left base point
        beginShape();
        //base of the crown
        vertex(-diam*bottomHalf, diam*heightHalf);
        vertex(diam*bottomHalf, diam*heightHalf);
        
        vertex(diam*topHalf, -diam*heightHalf);     //going up
        vertex(diam*crownMiddleHalf, 0);            //going down
        vertex(0, -diam*heightHalf);                //going up
        vertex(-diam*crownMiddleHalf, 0);           //going down
        vertex(-diam*topHalf, -diam*heightHalf);    //going up
        endShape(CLOSE);
        
        //translate back
        popMatrix();
        return;
    }
    
    //highlighting selected piece with given color and whether the piece is selected for movement
    public void highlight(int highlightColor, boolean isPieceSelected){
        ellipseMode(CENTER);
        noFill();
        stroke(highlightColor);
        if(isPieceSelected)  strokeWeight(diam * 0.077f);    //choose bigger stroke weight for selecting highlight
        else                 strokeWeight(diam * 0.052f);
        ellipse(x, y, diam, diam);
        return;
    }
    
    //get a list of legal moves considering other pieces.
    public List<Move> getMoves(Piece[][] board, int i, int j){
        List<Move> ret = new LinkedList<Move>();
        for(int [] vec: movementVector){
            int newi = i+vec[0], newj = j+vec[1];
            
            //check if new position is inside the board
            if(isInside(board, newi, newj)){
                if(board[newi][newj] == null){            //if new position is add the move to list
                    ret.add(new Move(i, j, newi, newj));
                }
                else if(board[newi][newj].pieceColor != this.pieceColor){     //if new position is not empty and is occupied by enemy color, check if it can be captured
                    int capi = newi+vec[0], capj = newj + vec[1];
                    
                    if(isInside(board, capi, capj) && board[capi][capj] == null){    //if capturing position is inside board and empty add the capturing move
                        Move move = new Move(i, j, capi, capj);
                        move.setCaptured(board[newi][newj]);
                        ret.add(move);
                    }
                }
            }
        }
        return ret;
    }
    
    //change the type of the piece, this updates movement vector too.
    public void changeType(TYPE newType){
        type = newType;
        if(type == TYPE.KING)
            movementVector = new int[][]{ {-1, 1}, {-1, -1}, {1, -1}, {1, 1} };
        else if(pieceColor == COLOR.LIGHT) 
            movementVector = new int[][]{ {-1, 1}, {-1, -1} };
        else
            movementVector = new int[][]{ {1, 1}, {1, -1} };
        return;
    }
    
    //helper fucntion, checks whether a cooridnate is inside the board.
    private boolean isInside(Piece[][] board, int i, int j){
        boolean ret = (0 <= i && i < board.length && 0 <= j && j < board[i].length); 
        return ret;
    }
}
// class textbox that will be in menubox, like buttons and texts 
class TextBox{
    // drawing variables
    private float xlo, ylo, xhi, yhi;                         //drawing bounding box
    private final int buttonColor = color(132, 54, 161);    //color of normal button
    private final int activatedColor = color(106, 18, 146); //color of clicked button
    private int timer;                                        //animation delay counter for clicked button going back to normal
    private String showText, newText;                         //text that is shown and text that will be shown after animation
    
    // logical variables;
    public BOXTYPE type;        //type of textbox
    public TRIGGER trigger;     //returned trigger
    
    //constructed with type, textshown and trigger
    public TextBox(String showText, BOXTYPE type, TRIGGER trigger){
        this.showText = showText;
        this.type = type;
        this.trigger = trigger;
    }
    
    //draw text box given the center coordinate and widht, height
    public void draw(float cx, float cy, float boxWidth, float boxHeight){
        
        if(timer == 0 && newText != null){        //if timer is 0 and there is a non-null newtext, put that in showtext's place and clear newtext
            this.showText = newText;
            newText = null;
        }
        
        //calculate bounding box from dimension and coordinates
        xlo = cx - boxWidth/2;
        ylo = cy - boxHeight/2;
        xhi = cx + boxWidth/2;
        yhi = cy + boxHeight/2;
        
        //if it is button type then boundary and color needs to be different
        if(type == BOXTYPE.BUTTON){
            if(timer == 0) fill(buttonColor);        //if normal time, use button color
            else           fill(activatedColor);     //if animatin delay is on, use activated color
            // draw boundary
            stroke(0);
            strokeWeight(Math.min(boxWidth, boxHeight)*0.02f);
            rectMode(CORNERS);
            rect(xlo, ylo, xhi, yhi);
        }
        
        // drawing the text
        fill(255);
        float scaleConst = 0.49f;
        textSize(boxHeight*scaleConst);    //using scaled sized
        textAlign(CENTER, CENTER);
        text(showText, cx, cy-boxHeight*scaleConst/8.0f);         //draw the text at center.
        
        if(timer > 0) timer--;            //update timer
        return;
    }
    
    //schedule a change of text with given addeddelay. This is mainly for textonly boxes that will work in tandem with buttons
    //this delay is added to already present delay
    public void changeText(String string, int addedDelay){
        newText = string;
        timer += addedDelay;
        return;
    }
    
    //check if mx, my that is mouse click coordinates were on this, if they were turn timer on for buttonColor animation
    public boolean clickedOn(float mx, float my){
        boolean res =  (mx == constrain(mx, xlo, xhi) && my == constrain(my, ylo, yhi));
        if(res){
            timer = animationUnit;
        }
        return res;
    }
}
    public void settings() {  size(1200, 900); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Checkers" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
