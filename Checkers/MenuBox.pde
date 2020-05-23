class MenuBox{
    
    //TODO change font add textBoxes
    
    
    //final color bodyColor = color(132, 54, 161);
    final color bodyColor = color(163, 74, 180);
    
    float xlo, ylo, xhi, yhi;
    
    MenuBox(){
    }
    
    public void draw(float cx, float cy, float menuWidth, float menuHeight){
        xlo = cx - menuWidth/2;
        xhi = cx + menuWidth/2;
        ylo = cy - menuHeight/2;
        yhi = cy + menuHeight/2;
        
        rectMode(CORNERS);
        noStroke();
        fill(bodyColor);
        rect(xlo, ylo, xhi, yhi);
        
        fill(255);
        textSize(32);
        textAlign(CENTER, CENTER);
        text("WON", cx, cy);
        
        /*stroke(0);
        strokeWeight(1);
        line(0, cy, width, cy);
        line(cx, 0, cx, height);*/
    }
}
