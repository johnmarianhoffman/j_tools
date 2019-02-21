function who_won = tictactoe(tf_display)
% Script to simulate tic tac toe perfect opponent via brute force search
% TODO maybe make a GUI at some point?
% Eventually we're going to do a deep learning version of this.

% Initilialization
    global p1_play_mode;
    global p2_play_mode;    

    p1_play_mode = 'perfect';    
    p2_play_mode = 'perfect';
    
    if tf_display
        global f
        global ax
        global img

        f = figure('units','normalize');
        ax = axes('parent',f,'position',[0 0 1 1]);
        img = imshow(zeros(27,27),'parent',ax);
    end

    board = zeros(3,3);
    %board(2,2) = 1; % Save some time

    p1_hist = zeros(3,3,4); % Z direction is history
    p2_hist = zeros(3,3,4);

    p1_move_val = 1;
    p2_move_val = -1;

    % Main Game Loop
    if (tf_display)
        show(board);
        drawnow;
    end
    
    someone_won = false;
    while ~someone_won


        % Player 1 move
        move = p1_move(board);
        board = board + p1_move_val*move;
        p1_hist = add_move_to_history(move,p1_hist);
        if (tf_display)
            show(board);
        end

        [someone_won,~] = check_for_win(board);
        if someone_won
            break;
        end

        pause(1);


        % Player 2 move (assumes x played in center)
        move = p2_move(board);
        board = board + p2_move_val*move;
        p2_hist = add_move_to_history(move,p2_hist);
        if (tf_display)
            show(board);
        end
        [someone_won,~] = check_for_win(board);
        if someone_won
            break;
        end

        pause(1);                

    end

    [~,who_won] = check_for_win(board);
    switch who_won
      case 1
        who_won = [1,0,0];
      case 2
        who_won = [0,0,1];
      case 0
        who_won = [0,1,0];
    end
end

function move = choose_move_random(board)
    move = zeros(3,3);
    poss = find(board==0);
    rand_idx = randi(numel(poss));
    move(poss(rand_idx)) = 1;
end

function move = choose_move_perfect(board,move_val)
%fprintf('Evaluation best move options... ');

    fprintf('Current player: %d\n',move_val);
    fprintf('========================================\n');
    
    poss = find(board==0);
    poss = poss(randperm(numel(poss)));

    if move_val==-1
        best_result = 0;
    else
        best_result = 10000;
    end
    best_move = [];

    % Check if there is a move we can win with
    for i=1:numel(poss)
        tmp_board = board;
        tmp_board(poss(i)) = move_val;
        [someone_won,who_won]= check_for_win(tmp_board);
        if someone_won
            best_move = poss(i);
            move = zeros(3,3);
            move(best_move) = 1;
            return;
        end        
    end

    % If we can't win, ensure other player can't win
    for i=1:numel(poss)
        tmp_board = board;
        tmp_board(poss(i)) = -move_val;
        [someone_won,~]= check_for_win(tmp_board);
        if someone_won
            best_move = poss(i);
            move = zeros(3,3);
            move(best_move) = 1;
            return;
        end        
    end

    % If no winning move, Evaluate probability of winning recursively
    
    for i=1:numel(poss)
        curr_poss = poss(i);
        result = check_results(curr_poss,board,move_val,move_val);

        fprintf('%d: %s\n',curr_poss,mat2str(result));
        % Choose the play with the greatest number of win cases
        % ========================================
        if move_val ==-1            
            if result(1)>best_result % There is a case that results in more wins than the others 
                best_result = result(1);
                best_move = curr_poss;
                fprintf('***\n');                
            end
        end

        % Choose the play with the fewest number of losses
        % ========================================
        if move_val == 1
            if result(3)<best_result
                best_result = result(3);
                best_move = curr_poss;
                fprintf('***\n');                                
            end
        end

        % Play for the draw!
        % ========================================
        %if move_val ==-1
        %    if result(2)>best_result
        %        best_result = result(2);
        %        best_move = curr_poss;
        %        fprintf('***\n');
        %    end
        %end

    end

    move = zeros(3,3);
    if best_result==0 % Everything is equal, choose randomly
        best_move = poss(randi(numel(poss)));
    end
    move(best_move) = 1;
    fprintf('========================================\n')
    %   fprintf('DONE');
end

function results = check_results(poss,board,curr_move,tally_move)
    
    results = [0,0,0]; % [wins,draws,losses] for current player
    
    for i=1:numel(poss)
        curr_poss = poss(i);
        %fprintf('Checking move %d\n',curr_poss);
        tmp_board = board;
        tmp_board(curr_poss) = curr_move;
        poss_curr_board = find(tmp_board==0);
        [someone_won,who_won] = check_for_win(tmp_board);
        if ~someone_won
            results = results + check_results(poss_curr_board,tmp_board,-curr_move,tally_move);
        else
            if (who_won == tally_move)
                results(1) = results(1) + 1;
            elseif (who_won == -tally_move)
                results(3) = results(3) + 1;
            elseif (who_won == 0)
                results(2) = results(2) + 1;
            else
                disp('Something''s gone horribly wrong!')
            end
        end 
    end    
end

function one_hot_move = p1_move(board)
    global p1_play_mode;
    switch p1_play_mode
      case 'random'
        one_hot_move=choose_move_random(board);
      case 'perfect'
        one_hot_move=choose_move_perfect(board,1);        
    end    
end
function one_hot_move = p2_move(board)
    global p2_play_mode;
    switch p2_play_mode
      case 'random'
        one_hot_move=choose_move_random(board);
      case 'perfect'
        one_hot_move=choose_move_perfect(board,-1);        
    end        
end

function history = add_move_to_history(move,history)
% Lots of memory copying (ok for tictac toe, not good for anything else)
    history(:,:,2:end) = history(:,:,1:(end-1));
    history(:,:,1) = move;
end


function [tf,w]= check_for_win(board)
    
    tf = false;
    w=0;

    % Check p1 win
    if ismember(3,sum(board,1)) || ismember(3,sum(board,2)) || (trace(board)==3) || (trace(flipud(board))==3)
        tf = true;
        w = 1;
        return;        
    end

    % Check p2 win    
    if ismember(-3,sum(board,1)) || ismember(-3,sum(board,2)) || (trace(board)==-3) || (trace(flipud(board))==-3)
        tf = true;
        w = -1;
        return
    end

    % Check draw
    poss = ismember(board,0);
    if sum(poss(:))==0
        tf = true;
        w = 0;
    end
    
end

function show(board)

    x = [ 0 0 0 0 0 0 0 0 0 ;
          0 1 0 0 0 0 0 1 0 ;
          0 0 1 0 0 0 1 0 0 ;
          0 0 0 1 0 1 0 0 0 ;
          0 0 0 0 1 0 0 0 0 ;
          0 0 0 1 0 1 0 0 0 ;
          0 0 1 0 0 0 1 0 0 ;
          0 1 0 0 0 0 0 1 0 ;
          0 0 0 0 0 0 0 0 0 ;];
    
    o = [ 0 0 0 0 0 0 0 0 0 ;
          0 0 0 1 1 1 0 0 0 ;
          0 0 1 0 0 0 1 0 0 ;
          0 1 0 0 0 0 0 1 0 ;
          0 1 0 0 0 0 0 1 0 ;
          0 1 0 0 0 0 0 1 0 ;
          0 0 1 0 0 0 1 0 0 ;
          0 0 0 1 1 1 0 0 0 ;
          0 0 0 0 0 0 0 0 0 ;];

    tile_size = 9;

    disp_board = zeros(tile_size*3,tile_size*3);

    for i=1:3
        for j=1:3
            if board(i,j)==1
                disp_board((i-1)*tile_size+1:i*tile_size,(j-1)*tile_size+1:j*tile_size) = x;
            elseif board(i,j)==-1
                disp_board((i-1)*tile_size+1:i*tile_size,(j-1)*tile_size+1:j*tile_size) = o;
            end
        end
    end

    global img
    set(img,'cdata',disp_board);

end