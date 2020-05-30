// class textbox that will be in menubox, like buttons and texts 
class TextBox{
    // drawing variables
    float xlo, ylo, xhi, yhi;                         //drawing bounding box
    final color buttonColor = color(132, 54, 161);    //color of normal button
    final color activatedColor = color(106, 18, 146); //color of clicked button
    int timer;                                        //animation delay counter for clicked button going back to normal
    String showText, newText;                         //text that is shown and text that will be shown after animation
    
    // logical variables;
    BOXTYPE type;        //type of textbox
    TRIGGER trigger;     //returned trigger
    
    //constructed with type, textshown and trigger
    TextBox(String showText, BOXTYPE type, TRIGGER trigger){
        this.showText = showText;
        this.type = type;
        this.trigger = trigger;
    }
    
    //draw text box given the center coordinate and widht, height
    public void draw(float cx, float cy, float boxWidth, float boxHeight){
        
        if(timer == 0 && newText != null){        //if timer is 0 and there is a non-null newtext, put that in showtext's place and clear newtext
            this.showText = newText;
            newText = null;
        }
        
        //calculate bounding box from dimension and coordinates
        xlo = cx - boxWidth/2;
        ylo = cy - boxHeight/2;
        xhi = cx + boxWidth/2;
        yhi = cy + boxHeight/2;
        
        //if it is button type then boundary and color needs to be different
        if(type == BOXTYPE.BUTTON){
            if(timer == 0) fill(buttonColor);        //if normal time, use button color
            else           fill(activatedColor);     //if animatin delay is on, use activated color
            // draw boundary
            stroke(0);
            strokeWeight(Math.min(boxWidth, boxHeight)*0.02);
            rectMode(CORNERS);
            rect(xlo, ylo, xhi, yhi);
        }
        
        // drawing the text
        fill(255);
        float scaleConst = 0.49;
        textSize(boxHeight*scaleConst);    //using scaled sized
        textAlign(CENTER, CENTER);
        text(showText, cx, cy-boxHeight*scaleConst/8.0);         //draw the text at center.
        
        if(timer > 0) timer--;            //update timer
    }
    
    //schedule a change of text with given delay. This is mainly for textonly boxes that will work in tandem with buttons
    public void changeText(String string, int delay){
        newText = string;
        timer += delay;
    }
    
    //check if mx, my that is mouse click coordinates were on this, if they were turn timer on for buttonColor animation
    public boolean clickedOn(float mx, float my){
        boolean res =  (mx == constrain(mx, xlo, xhi) && my == constrain(my, ylo, yhi));
        if(res){
            timer = animationUnit;
        }
        return res;
    }
}
