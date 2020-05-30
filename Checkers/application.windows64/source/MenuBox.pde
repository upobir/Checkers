// Since I chose not to use any native GUI, this is just a a simple simulation of genenric menu or boxes.

// class to represent menus in startup, game and finish
class MenuBox{
    // drawing variabls
    private final color bodyColor = color(163, 74, 180);
    private float xlo, ylo, xhi, yhi;
    
    // IO variable, whether the menu is on or not
    public boolean isActive;
    
    // Container of textboxes
    private TextBox [][] boxes;
    
    //constructor that has arguments of whether the menu is on at first and the columns in each entry passed with varargs
    public MenuBox(boolean isActive , int ... rowsDesc){
        boxes = new TextBox[rowsDesc.length][];
        for(int i = 0; i<rowsDesc.length; i++)        //initialize only the rows, but the entries will be still null
            boxes[i] = new TextBox[rowsDesc[i]];
        this.isActive = isActive;
    }
    
    //setting string to textBox at [i][j] with type and return trigger
    public void set(int i, int j, String string, BOXTYPE type, TRIGGER trigger){
        try{
            boxes[i][j] = new TextBox(string, type, trigger);
        } catch (ArrayIndexOutOfBoundsException e){            //this is for catching bus
            e.printStackTrace();
        }
        return;
    }
    
    //changing string of textbox at [i][j], with given delay, that is this delay will be added on already present delay
    public void changeText(int i, int j, String string, int addedDelay){
        try{
            if(boxes[i][j] == null) return;
            boxes[i][j].changeText(string, addedDelay);
        } catch (ArrayIndexOutOfBoundsException e){           //this is for catching bugs
            e.printStackTrace();
        }
        return;
    }
    
    //drawing function given center coordinate and full width and individual row height
    public void draw(float cx, float cy, float menuWidth, float menuRowHeight){
        //calculate bounding box values
        float menuHeight = menuRowHeight * boxes.length;        //first calculate full menu height from row height
        xlo = cx - menuWidth/2;
        xhi = cx + menuWidth/2;
        ylo = cy - menuHeight/2;
        yhi = cy + menuHeight/2;
        
        //draw the rectangle body first
        rectMode(CORNERS);
        noStroke();
        fill(bodyColor);
        rect(xlo, ylo, xhi, yhi);
        
        //the space between textboxes are borderSpace, this is calculated using smaller dimension
        //using borderspace dimension for textbox is calculated and sent to textbox
        float borderSpace = Math.min(menuWidth, menuHeight) * 0.03;
        float boxHeight = (yhi-ylo)/boxes.length - borderSpace * 2;
        for(int i = 0; i<boxes.length; i++){
            float boxCY = map(i+0.5, 0, boxes.length, ylo, yhi);
            float boxWidth = (xhi-xlo)/boxes[i].length - borderSpace * 2;
            for(int j = 0; j<boxes[i].length; j++){
                if(boxes[i][j] == null) continue;
                float boxCX = map(j+0.5, 0, boxes[i].length, xlo, xhi);
                boxes[i][j].draw(boxCX, boxCY, boxWidth, boxHeight);        //call textbox to draw itself giving cooridinates and dimensions
            }
        }
        return;
    }
    
    // check if mouse click at (mx, my) interacts with menu and if it does
    // return trigger.
    public TRIGGER interactMouse(float mx, float my){
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return null;     //if click is outside boundary return null
        
        //check each textbox for whether it got the click
        for(int i = 0; i<boxes.length; i++){
            for(int j = 0; j<boxes[i].length; j++){
                TextBox box = boxes[i][j];
                if(box == null || box.type != BOXTYPE.BUTTON) continue;    //only check on buton type boxes
                if(box.clickedOn(mx, my)){        //call box to check if it got click, if it did return that box's trigger.
                    return box.trigger;
                }
            }
        }
        return null;    //no click, return null
    }
}
