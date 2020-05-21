class Move{
    int[] from, to;
    Piece capturedPiece;
    
    Move(int fi, int fj, int ti, int tj){
        from = new int[]{ fi, fj };
        to = new int[]{ ti, tj };
    }
    
    public boolean isCapturing(){
        return (capturedPiece != null);
    }
    
    public void setCaptured(Piece cap){
        capturedPiece = cap;
    }
}
