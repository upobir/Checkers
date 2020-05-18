CheckersGame game;
float boardsz = 850; //board size for drawing

void setup(){
    size(1200, 900);
    background(50);
    game = new CheckersGame();
}

void draw(){
    background(50);
    float cx = width/2, cy = height/2;
    game.draw(cx-boardsz/2, cy-boardsz/2, cx+boardsz/2, cy+boardsz/2, true);
}