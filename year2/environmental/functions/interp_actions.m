function [inds, weights] = interp_actions(state, action_ind, S, A)
    
    next_state = state-A(action_ind);
    next_state(next_state < 0) = 0;

    [~,ind1] = find(S > next_state, 1, "first");
    inds = [ind1-1, ind1];

    if next_state < S(end)
        wt = (next_state - S(inds(2))) / (S(inds(1)) - S(inds(2)));
    elseif next_state == S(end)
        wt = 0;
        inds = [numel(S)-1,numel(S)];
    end
    weights = [wt, 1-wt];

end