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
        diam = 0.75*cellSize;
        
        //draw the circular boundary
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(diam*0.026);

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
        strokeWeight(diam * 0.026);
        fill(255, 255, 0);
        
        float bottomHalf = 0.22;
        float topHalf = 0.28;
        float heightHalf = 0.15;
        float crownMiddleHalf = 0.115;
        
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
    public void highlight(color highlightColor, boolean isPieceSelected){
        ellipseMode(CENTER);
        noFill();
        stroke(highlightColor);
        if(isPieceSelected)  strokeWeight(diam * 0.077);    //choose bigger stroke weight for selecting highlight
        else                 strokeWeight(diam * 0.052);
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
