public enum COLOR{
    
    // final color lightPieceColor = color(255, 249, 244);
    // final color darkPieceColor = color(196, 0, 3);
    
    LIGHT(255<<24 | 255<<16 | 249<<8 | 244), DARK(255<<24 | 196<<16 | 0<<8 | 3);
    
    color drawColor;
    private COLOR(color drawColor){
        this.drawColor = drawColor;
    }
}
