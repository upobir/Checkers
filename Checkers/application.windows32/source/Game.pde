//would have set these as static if processing'd let me -_-

// variables that should be static of game
final color lightCellColor = color(255, 238, 187);
final color darkCellColor = color(85, 136, 34);
final color highlightColor = color(255, 255, 0);
final color multijumpHighlightColor = color(248, 150, 0);
final color availableMoveColor = color(0, 0, 0);
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
        borderSpace = boardSz*0.011;                    //calculating border space to be kept
        
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
                
                float x = map(j+0.5, 0, gridSz, xlo, xhi);
                float y = map(i+0.5, 0, gridSz, ylo, yhi);
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
                    float x = map(j+0.5, 0, gridSz, xlo, xhi);
                    float y = map(i+0.5, 0, gridSz, ylo, yhi);
                      
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
            float y = map(i+0.5, 0, gridSz, ylo, yhi);
            float x = map(j+0.5, 0, gridSz, xlo, xhi);
            
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
            strokeWeight(cellSize*0.06);
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
        int j = Math.round(x-0.5+0.001);
        int i = Math.round(y-0.5+0.001);
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
