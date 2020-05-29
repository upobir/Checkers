class GameAI{
    COLOR playingColor;
    int delay, timer;
    Game virtualGame;
    final int maxDepth = 8;
    Queue<int[]> clicks;
    boolean oneFrameIgnore;
    
    GameAI(int delay){
        this.delay = delay;
        this.clicks = new LinkedList<int[]>();
    }
    
    public void setColor(COLOR playingColor){
        this.playingColor = playingColor;
    }
    
    int[] reply(Game game){
        if(timer == 0){
            if(!oneFrameIgnore){
                oneFrameIgnore = true;
                return null;
            }
            timer = delay;
            virtualGame = game.copy();
            
            /*
            int moveCnt = virtualGame.validMoves.size();
            int chosenMoveIndex = (int) random(moveCnt);
            Move chosenMove = virtualGame.validMoves.get(chosenMoveIndex);
            */
            
            
            Move chosenMove = findBestMove();
            
            
            clicks.add(chosenMove.from.clone());
            clicks.add(chosenMove.to.clone());
            return null;
        }
        else if(timer == 1){
            int[] ret = clicks.poll();
            if(clicks.isEmpty()){
                timer--;
                virtualGame = null;
                oneFrameIgnore = false;
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
    
    private Move findBestMove(){
        boolean AIisMaximizing = (playingColor == COLOR.LIGHT);
        
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        
        if(validMoves.size() == 1){
            return validMoves.get(0);
        }
        
        List<Move> goodMoves = new LinkedList<Move>();
        int bestVal = (AIisMaximizing)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        
        COLOR currentColor = virtualGame.currentPlayingColor;
        for(Move move : validMoves){
            
            virtualGame.applyMove(move);
            int possibleVal = backtrack(1, !AIisMaximizing);
            virtualGame.softUndoMove(move, currentColor);
            
            if((AIisMaximizing && possibleVal > bestVal) || (!AIisMaximizing && possibleVal < bestVal)){
                bestVal = possibleVal;
                goodMoves.clear();
                goodMoves.add(move);
            }
            else if(possibleVal == bestVal){
                goodMoves.add(move);
            }
        }
        int randomIndex = (int) random(goodMoves.size());
        println(goodMoves.size());
        return goodMoves.get(randomIndex);
    }
    
    private int backtrack(int depth, boolean maximizingPlayer){
        if(depth == maxDepth || virtualGame.winningColor != null){
            return virtualGame.heuristic;
        }
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        int bestVal = (maximizingPlayer)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        
        COLOR currentColor = virtualGame.currentPlayingColor;
        for(Move move : validMoves){
            virtualGame.applyMove(move);
            int possibleVal = backtrack(depth+1, !maximizingPlayer);
            virtualGame.softUndoMove(move, currentColor);
            
            if((maximizingPlayer && possibleVal > bestVal) || (!maximizingPlayer && possibleVal < bestVal)){
                bestVal = possibleVal;
            }
        }
        return bestVal;
    }
}
