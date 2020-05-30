//Class of game ai that decides what move to apply given the game
class GameAI{
    // logical variables; color of ai's side, copy of the virtual game, maximum depth of backtrack
    public COLOR playingColor;
    private Game virtualGame;
    private final int maxDepth = 9;
    
    // IO variables; delay done before interacting with the game, timer for that, queue of interacts, boolean to ignore first frame when ai is called
    // (this is to make sure the board is first drawn, before ai starts backtrack
    private int delay, timer;
    private Queue<int[]> clicks;
    private boolean oneFrameIgnore;
    
    //setting delay for each interactin in constructor
    public GameAI(int delay){
        this.delay = delay;
        this.clicks = new LinkedList<int[]>();
    }
    
    // assigning color to ai, however since this can occur inside the game, everything is cleared
    // the timer, frame ignore boolean, game, clicks everything
    public void setColor(COLOR playingColor){
        this.playingColor = playingColor;
        timer = 0;
        oneFrameIgnore = false;
        virtualGame = null;
        clicks.clear();
        return;
    }
    
    // Given the game object return the interaction cell via this function
    public int[] reply(Game game){
        if(timer == 0){                    //if timer is 0, then this is a new turn, so first find best move
            if(!oneFrameIgnore){           //however first see if one frame has been ignored, if not then ignore this call after setting to true
                oneFrameIgnore = true;
                return null;
            }
            
            //set timer for delay and make copy of game
            timer = delay;                
            virtualGame = game.copy();
            if(virtualGame.winningColor != null)    //if game is finished no interaction can be returned
                return null;
            
            Move chosenMove = findBestMove();    //find best move
            
            //add moves to queue, first from cell, then to cell; and return nothing (will return after timer is 1)
            clicks.add(chosenMove.from.clone());
            clicks.add(chosenMove.to.clone());
            return null;
        }
        else if(timer == 1){            //if timer = 1, it will reset, so before resetting return click from queue
            int[] ret = clicks.poll();
            if(clicks.isEmpty()){        //if queue is empty then interaction is finished let timer go to 0 and reset everything, otherwise reset timer to delay for next click
                timer--;
                virtualGame = null;
                oneFrameIgnore = false;
            }
            else{
                timer = delay;
            }
            return ret;
        }
        else{                        //otherwise timer is running let it decrease
            timer--;
            return null;
        }
    }
    
    //this function finds best move by starting the backtrack.
    //this uses minimax algo with alpha beta pruning, score beingh (white - red)
    private Move findBestMove(){
        boolean AIisMaximizing = (playingColor == COLOR.LIGHT);    //first figure out whether ai is the maximimizing player, if white maximizing, if red minimizing
        
        // make a copy of the valid moves and shuffle it for randomness in finding best move
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        
        if(validMoves.size() == 1){        //if only one move is allowed, nothing to compute return that move.
            return validMoves.get(0);
        }
        
        //setup variables for maintaining alpha beta and best move and best value;
        List<Move> goodMoves = new LinkedList<Move>();
        int bestVal = (AIisMaximizing)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        int alpha = Integer.MIN_VALUE, beta = Integer.MAX_VALUE;
        
        COLOR currentColor = virtualGame.currentPlayingColor;    //remember currentColor, because it will be used in soft undo
        for(Move move : validMoves){
            //apply move, backtrack, undo move
            virtualGame.applyMove(move);
            int possibleVal = backtrack(1, !AIisMaximizing, alpha, beta);
            virtualGame.softUndoMove(move, currentColor);
            
            if((AIisMaximizing && possibleVal > bestVal) || (!AIisMaximizing && possibleVal < bestVal)){    // if better value found clear current good moves and start with new good move
                bestVal = possibleVal;
                goodMoves.clear();
                goodMoves.add(move);
            }
            else if(possibleVal == bestVal){        // if equally good move found add move to good moves;
                goodMoves.add(move);
            }
            
            //update alpha beta range
            if(AIisMaximizing)
                alpha = Math.max(alpha, possibleVal);
            else
                beta = Math.min(beta, possibleVal);
        }
        
        //return a random good move among the found
        int randomIndex = (int) random(goodMoves.size());
        return goodMoves.get(randomIndex);
    }
    
    //the generic backtrack of minimax with alpha beta pruning that returns just best score
    private int backtrack(int depth, boolean maximizingPlayer, int alpha, int beta){
        if(depth == maxDepth || virtualGame.winningColor != null){        //if at maximum depth or end of game return the heuristic
            return virtualGame.heuristic;
        }

        //copy validmoves
        ArrayList<Move> validMoves = new ArrayList<Move>();
        for(Move move : virtualGame.validMoves){
            validMoves.add(move);
        }
        
        //maintain best value seen
        int bestVal = (maximizingPlayer)? Integer.MIN_VALUE : Integer.MAX_VALUE;
        
        //remember color for soft undo
        COLOR currentColor = virtualGame.currentPlayingColor;
        for(Move move : validMoves){
            //apply move, backtrack, undo move
            virtualGame.applyMove(move);
            int possibleVal = backtrack(depth+1, !maximizingPlayer, alpha, beta);
            virtualGame.softUndoMove(move, currentColor);
            
            //update if better value found
            if((maximizingPlayer && possibleVal > bestVal) || (!maximizingPlayer && possibleVal < bestVal)){
                bestVal = possibleVal;
            }
            
            //update alpha beta range
            if(maximizingPlayer)
                alpha = Math.max(alpha, possibleVal);
            else
                beta = Math.min(beta, possibleVal);
                
            //if alpha-beta range is squished, we have found the best value.  
            if(beta <= alpha)
                break;
        }
        
        return bestVal;    //return best value
    }
}
