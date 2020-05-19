class Move{
    int[] from, to;
    Piece captured;
    
    
    Move(int fi, int fj, int ti, int tj){
        from = new int[]{ fi, fj };
        to = new int[]{ ti, tj };
    }
    
    public void setCaptured(Piece cap){
        captured = cap;
    }
}
