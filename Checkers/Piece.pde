class Piece{
    
    //piece game properties
    int[][] movementVector;
    COLOR pieceColor;
    TYPE type;
    int kingingRow;
    
    //drawing variables
    float x, y;
    float diam;
    
    
    Piece(COLOR pieceColor_, TYPE type_, int kingingRow_){
        pieceColor = pieceColor_;
        kingingRow = kingingRow_;
        changeType(type_);
    }
    
    //return a logical copy of the piece
    public Piece copy(){
        Piece clone = new Piece(pieceColor, type, kingingRow);
        clone.movementVector = movementVector.clone();
        return clone;
    }
    
    //heuristic function
    public int heuristic(int i, int j){
        int score = type.value;
        if(type == TYPE.SOLDIER){
            score += Math.abs(i-kingingRow);
        }
        return score * pieceColor.sign();
    }
    
    //to draw the pieces.
    public void draw(float x_, float y_, float cellSize){
        x = x_;
        y = y_;
        diam = 0.75*cellSize;
        
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(diam*0.026);            //TODO make strokeWeight varying

        fill(pieceColor.drawColor);
        ellipse(x, y, diam, diam);
        
        if(type == TYPE.KING){
            drawCrown();
        }
    }
    
    //drawing the crown for king pieces
    private void drawCrown(){
        pushMatrix();
        translate(x, y);
        stroke(0);
        strokeWeight(diam * 0.026);
        fill(255, 255, 0);
        
        float bottomHalf = 0.22;
        float topHalf = 0.28;
        float heightHalf = 0.15;
        float crownMiddleHalf = 0.115;
        
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
        
        popMatrix();
    }
    
    //highlight selected piece
    public void highlight(color highlightColor, boolean isPieceSelected){
        ellipseMode(CENTER);
        noFill();
        stroke(highlightColor);
        if(isPieceSelected)  strokeWeight(diam * 0.077);
        else                 strokeWeight(diam * 0.052);
        ellipse(x, y, diam, diam);
    }
    
    //get a list of legal moves considering other pieces.
    public List<Move> getMoves(Piece[][] board, int i, int j){
        List<Move> ret = new LinkedList<Move>();
        for(int [] vec: movementVector){
            int newi = i+vec[0], newj = j+vec[1];
            
            if(isInside(board, newi, newj)){
                if(board[newi][newj] == null){
                    ret.add(new Move(i, j, newi, newj));
                }
                else if(board[newi][newj].pieceColor != this.pieceColor){
                    int capi = newi+vec[0], capj = newj + vec[1];
                    
                    if(isInside(board, capi, capj) && board[capi][capj] == null){
                        Move move = new Move(i, j, capi, capj);
                        move.setCaptured(board[newi][newj]);
                        ret.add(move);
                    }
                }
            }
        }
        return ret;
    }
    
    
    //updating to king
    void changeType(TYPE newType){
        type = newType;
        if(type == TYPE.KING)
            movementVector = new int[][]{ {-1, 1}, {-1, -1}, {1, -1}, {1, 1} };
        else if(pieceColor == COLOR.LIGHT) 
            movementVector = new int[][]{ {-1, 1}, {-1, -1} };
        else
            movementVector = new int[][]{ {1, 1}, {1, -1} };
    }
    
    //helper fucntion
    private boolean isInside(Piece[][] board, int i, int j){
        boolean ret = (0 <= i && i < board.length && 0 <= j && j < board[i].length); 
        return ret;
    }
}
