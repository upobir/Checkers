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
