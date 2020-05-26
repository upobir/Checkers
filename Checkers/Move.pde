class Move{
    int[] from, to;
    boolean isKingingMove;
    Piece capturedPiece;
    
    Move(int fi, int fj, int ti, int tj){
        from = new int[]{ fi, fj };
        to = new int[]{ ti, tj };
        isKingingMove = false;
    }
    
    //return a logical copy of Move 
    public Move copy(Piece[][] board){
        Move clone = new Move(from[0], from[1], to[0], to[1]);
        clone.isKingingMove = isKingingMove;
        if(capturedPiece != null){
            int capI = (from[0]+to[0])/2, capJ = (from[1]+to[1])/2;
            clone.capturedPiece = board[capI][capJ];
        }
        return clone;
    }
    
    public boolean isCapturing(){
        return (capturedPiece != null);
    }
    
    public void setCaptured(Piece cap){
        capturedPiece = cap;
    }
}
