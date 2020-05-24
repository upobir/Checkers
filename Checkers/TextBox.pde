class TextBox{
    float xlo, ylo, xhi, yhi; 
    String showText;
   
    TextBox(String showText){
        this.showText = showText;
    }
    
    public void draw(float cx, float cy, float boxWidth, float boxHeight){
        xlo = cx - boxWidth/2;
        ylo = cy - boxHeight/2;
        xhi = cx + boxWidth/2;
        yhi = cy + boxHeight/2;
        
        
        fill(255);
        textSize(32);
        textAlign(CENTER, CENTER);
        text(showText, cx, cy);
        
        noFill();
        stroke(0);
        strokeWeight(Math.min(boxWidth, boxHeight)*0.02);
        rect(xlo, ylo, xhi, yhi);
    }
}
