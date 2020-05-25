// Since I chose not to use any native GUI, this is just a a simple simulation of genenric menu or boxes.

class MenuBox{
    
    //TODO change font add textBoxes
    
    final color bodyColor = color(163, 74, 180);
    float xlo, ylo, xhi, yhi;
    
    // maybe for more functionality the lists could be dynamic, but for my purposes static is okay
    TextBox [][] boxes;
    boolean interactable;
    
    MenuBox(int ... rowsDesc){
        boxes = new TextBox[rowsDesc.length][];
        for(int i = 0; i<rowsDesc.length; i++)
            boxes[i] = new TextBox[rowsDesc[i]];
        interactable = true;
    }
    
    public void set(int i, int j, String string, BOXTYPE type){
        try{
            boxes[i][j] = new TextBox(string, type);
        } catch (ArrayIndexOutOfBoundsException e){
            e.printStackTrace();
        }
    }
    
    public void setInteractibility(boolean interactable){
        this.interactable = interactable;
    }
    
    //drawing function given center coordinate and full width and indiv. row height
    public void draw(float cx, float cy, float menuWidth, float menuRowHeight){
        float menuHeight = menuRowHeight * boxes.length;
        xlo = cx - menuWidth/2;
        xhi = cx + menuWidth/2;
        ylo = cy - menuHeight/2;
        yhi = cy + menuHeight/2;
        
        rectMode(CORNERS);
        noStroke();
        fill(bodyColor);
        rect(xlo, ylo, xhi, yhi);
        
        // perhaps set the borders in a better way?
        float borderSpace = Math.min(menuWidth, menuHeight) * 0.03;
        float boxHeight = (yhi-ylo)/boxes.length - borderSpace * 2;
        for(int i = 0; i<boxes.length; i++){
            float boxCY = map(i+0.5, 0, boxes.length, ylo, yhi);
            float boxWidth = (xhi-xlo)/boxes[i].length - borderSpace * 2;
            for(int j = 0; j<boxes[i].length; j++){
                if(boxes[i][j] == null) continue;
                float boxCX = map(j+0.5, 0, boxes[i].length, xlo, xhi);
                boxes[i][j].draw(boxCX, boxCY, boxWidth, boxHeight);
            }
        }
    }
    
    public int[] interactMouse(float mx, float my){
        if(!interactable) return null;
        if(mx != constrain(mx, xlo, xhi) || my != constrain(my, ylo, yhi)) return null;
        for(int i = 0; i<boxes.length; i++){
            for(int j = 0; j<boxes[i].length; j++){
                TextBox box = boxes[i][j];
                if(box == null || box.type != BOXTYPE.BUTTON) continue;
                if(box.clickedOn(mx, my)){
                    return new int[]{i, j};
                }
            }
        }
        return null;
    }
}
