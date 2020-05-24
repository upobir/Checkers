// Since I chose not to use any native GUI, this is just a a simple simulation of genenric menu or boxes.

class MenuBox{
    
    //TODO change font add textBoxes
    
    //final color bodyColor = color(132, 54, 161);
    final color bodyColor = color(163, 74, 180);
    
    float xlo, ylo, xhi, yhi;
    
    // maybe for more functionality the lists could be dynamic, but for my purposes static is okay
    TextBox [][] boxes;
    
    MenuBox(int ... rowsDesc){
        boxes = new TextBox[rowsDesc.length][];
        for(int i = 0; i<rowsDesc.length; i++)
            boxes[i] = new TextBox[rowsDesc[i]];
        
    }
    
    public void set(int i, int j, TextBox textBox){
        try{
            boxes[i][j] = textBox;
        } catch (ArrayIndexOutOfBoundsException e){
            e.printStackTrace();
        }
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
        
        // perhaps set the borders in a better way?
        float scaleSpace = 0.95;
        float boxHeight = (yhi-ylo)/boxes.length * scaleSpace;
        for(int i = 0; i<boxes.length; i++){
            float boxCY = map(i+0.5, 0, boxes.length, ylo, yhi);
            float boxWidth = (xhi-xlo)/boxes[i].length * scaleSpace;
            for(int j = 0; j<boxes[i].length; j++){
                if(boxes[i][j] == null) continue;
                float boxCX = map(j+0.5, 0, boxes[i].length, xlo, xhi);
                boxes[i][j].draw(boxCX, boxCY, boxWidth, boxHeight);
            }
        }
    }
}
