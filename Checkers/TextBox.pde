class TextBox{
    // drawing variables
    float xlo, ylo, xhi, yhi; 
    int timer;
    String showText;
    String newText;
    final color buttonColor = color(132, 54, 161);
    final color activatedColor = color(106, 18, 146);
    
    // logical variables;
    BOXTYPE type;
    
   
    TextBox(String showText, BOXTYPE type){
        this.showText = showText;
        this.type = type;
        //isActivated = false;
    }
    
    //draw text box
    public void draw(float cx, float cy, float boxWidth, float boxHeight){
        
        if(timer == 0 && newText != null){
            this.showText = newText;
            newText = null;
        }
        
        xlo = cx - boxWidth/2;
        ylo = cy - boxHeight/2;
        xhi = cx + boxWidth/2;
        yhi = cy + boxHeight/2;
        
        
        if(type == BOXTYPE.BUTTON){
            
            if(timer == 0) fill(buttonColor);
            else           fill(activatedColor);
            stroke(0);
            strokeWeight(Math.min(boxWidth, boxHeight)*0.02);
            rectMode(CORNERS);
            rect(xlo, ylo, xhi, yhi);
        }
        
        fill(255);
        textSize(32);
        textAlign(CENTER, CENTER);
        text(showText, cx, cy);
        
        if(timer > 0) timer--;
    }
    
    public void changeText(String string, int delay){
        newText = string;
        timer += delay;
    }
    
    public boolean clickedOn(float mx, float my){
        boolean res =  (mx == constrain(mx, xlo, xhi) && my == constrain(my, ylo, yhi));
        if(res){
            timer = animationUnit;
        }
        return res;
    }
}
