class GameAI{
    COLOR playingColor;
    int delay, timer;
    Game virtualGame;
    Queue<int[]> clicks;
    
    GameAI(int delay){
        this.delay = delay;
        this.clicks = new LinkedList<int[]>();
    }
    
    public void setColor(COLOR playingColor){
        this.playingColor = playingColor;
    }
    
    int[] reply(Game game){
        
        if(timer == 0){
            timer = delay;
            virtualGame = game.copy();
            int moveCnt = virtualGame.validMoves.size();
            int chosenMoveIndex = (int) random(moveCnt);
            Move chosenMove = virtualGame.validMoves.get(chosenMoveIndex);
            clicks.add(chosenMove.from.clone());
            clicks.add(chosenMove.to.clone());
            return null;
        }
        else if(timer == 1){
            int[] ret = clicks.poll();
            if(clicks.isEmpty()){
                timer--;
                virtualGame = null;
            }
            else{
                timer = delay;
            }
            return ret;
        }
        else{
            timer--;
            return null;
        }
    }
}
