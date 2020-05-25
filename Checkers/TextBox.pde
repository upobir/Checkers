class TextBox{
    float xlo, ylo, xhi, yhi; 
    String showText;
    BOXTYPE type;
    boolean isActivated;
    color activatedColor;
   
    TextBox(String showText, BOXTYPE type, color activatedColor){
        this.showText = showText;
        this.type = type;
        isActivated = false;
        this.activatedColor = activatedColor;
    }
    
    public void draw(float cx, float cy, float boxWidth, float boxHeight){
        xlo = cx - boxWidth/2;
        ylo = cy - boxHeight/2;
        xhi = cx + boxWidth/2;
        yhi = cy + boxHeight/2;
        
        
        if(type == BOXTYPE.BUTTON){
            if(!isActivated) noFill();
            else             fill(activatedColor);
            stroke(0);
            strokeWeight(Math.min(boxWidth, boxHeight)*0.02);
            rectMode(CORNERS);
            rect(xlo, ylo, xhi, yhi);
        }
        
        fill(255);
        textSize(32);
        textAlign(CENTER, CENTER);
        text(showText, cx, cy);
        
    }
}
