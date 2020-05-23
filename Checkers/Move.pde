class Move{
    int[] from, to;
    boolean isKingingMove;
    Piece capturedPiece;
    
    Move(int fi, int fj, int ti, int tj){
        from = new int[]{ fi, fj };
        to = new int[]{ ti, tj };
        isKingingMove = false;
    }
    
    public boolean isCapturing(){
        return (capturedPiece != null);
    }
    
    public void setCaptured(Piece cap){
        capturedPiece = cap;
    }
}
