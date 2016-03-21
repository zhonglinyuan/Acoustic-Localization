

function [prediction] = prediction_probabilistic_count(Label1, Label2, test, ...
    meThreashold, notMeThreashold, label_no_decision_threashold, wheretoplot1, wheretoplot2, wheretoplot3)

    addpath('../model_xcorr_avg_dynamic_template_selection') %needs filter_template_xcorr function from this dir
    
    persistent L1;
    persistent L2;
    
    persistent L1_xcorr_L1_table;
    persistent L1_xcorr_L2_table;
    
    persistent L2_xcorr_L2_table;
    persistent L2_xcorr_L1_table;
    
    
    NUMTEMPLATES = 5;
    
    if nargin == 2
        [L1 L2] = filter_template_xcorr(Label1, Label2, NUMTEMPLATES);
        
        L1_numcols = size(L1, 2);
        L2_numcols = size(L2, 2);
        
        %build the L1_x_all table
        [L1_xcorr_L1_table L1_xcorr_L2_table] = generate_template_xcorr_spread_table(L1, L2);
        
        %build the L2_x_all table
        [L2_xcorr_L2_table L2_xcorr_L1_table] = generate_template_xcorr_spread_table(L2, L1);
        return;
    end

    %remember to force that you have the same number of templates

    [L1_numrows L1_numcols] = size(L1);
    [L2_numrows L2_numcols] = size(L2);
    
    %plots
    subplot(wheretoplot1)
    title('L1 xcorr all templates and test')
    hold on
    for i=1:L1_numcols
        plot(ones(length(L1_numcols))*i, L1_xcorr_L1_table(:,i), 'ob')    
        plot(ones(length(L1_numcols))*i, L1_xcorr_L2_table(:,i), 'xr')
    end
    
    %plots
    subplot(wheretoplot2)
    title('L2 xcorr all templates and test')
    hold on
    for i=1:L2_numcols
        plot(ones(length(L2_numcols))*i, L2_xcorr_L2_table(:,i), 'xr')    
        plot(ones(length(L2_numcols))*i, L2_xcorr_L1_table(:,i), 'ob')
    end
    
    
    %find L1_x_test
    L1_xcorr_test = L_xcorr_test(L1, test);
    %find L2_x_test
    L2_xcorr_test = L_xcorr_test(L2, test);
    subplot(wheretoplot3)
    title('L1 x test and L2 x test')
    plot(1:length(L1_xcorr_test), L1_xcorr_test, 'ob', 1:length(L2_xcorr_test), L2_xcorr_test, 'xr')
    
    %counting votes from L1
    [L1_xcorr_L1_table_BELOW_L1_xcorr_test ... %b_o
     L1_xcorr_L1_table_ABOVE_L1_xcorr_test ... %t_o
     L1_xcorr_L2_table_ABOVE_L1_xcorr_test ... %t_x
     L1_xcorr_L2_table_BELOW_L1_xcorr_test]... %b_x
     = generate_top_and_bottom_counts(L1_xcorr_L1_table, L1_xcorr_L2_table, L1_xcorr_test);
 
    %voting
    xcorr_per_col = L1_numcols*2;
    L1_me_probability = (L1_xcorr_L1_table_BELOW_L1_xcorr_test + L1_xcorr_L2_table_BELOW_L1_xcorr_test)/xcorr_per_col;
    
    L1_me_vote = zeros(1, length(L1_me_probability));
    for i=1:length(L1_me_probability)
        if (L1_me_probability(i) > meThreashold)
            L1_me_vote(i) = 1;
        elseif (L1_me_probability < notMeThreashold)
            L1_me_vote(i) = -1;
        else
            L1_me_vote(i) = 0;
        end
    end
    L1_belief = sum(L1_me_vote);
 
    %L1_probability = sum((L1_xcorr_L1_table_BELOW_L1_xcorr_test + L1_xcorr_L2_table_BELOW_L1_xcorr_test)/L1_numcols)/L1_numcols;
    %not_L1_probability = 1 - L1_probability;
 
    %counting votes from L2
    [L2_xcorr_L2_table_BELOW_L1_xcorr_test ... %b_x
     L2_xcorr_L2_table_ABOVE_L1_xcorr_test ... %t_x
     L2_xcorr_L1_table_ABOVE_L1_xcorr_test ... %t_o
     L2_xcorr_L1_table_BELOW_L1_xcorr_test]... %b_o
     = generate_top_and_bottom_counts(L2_xcorr_L2_table, L2_xcorr_L1_table, L2_xcorr_test);
 
    %voting L2
    xcorr_per_col = L2_numcols*2;
    L2_me_probability = (L2_xcorr_L2_table_BELOW_L1_xcorr_test + L2_xcorr_L1_table_BELOW_L1_xcorr_test)/xcorr_per_col;
    
    L2_me_vote = zeros(1, length(L2_me_probability));
    for i=1:length(L2_me_probability)
        if (L2_me_probability(i) > meThreashold)
            L2_me_vote(i) = 1;
        elseif (L2_me_probability < notMeThreashold)
            L2_me_vote(i) = -1;
        else
            L2_me_vote(i) = 0;
        end
    end
    L2_belief = sum(L2_me_vote);
    
    fprintf('L1_me_vote:')
    fprintf('%d ', L1_me_vote)
    fprintf('\nL2_me_vote:')
    fprintf('%d ', L2_me_vote)
    fprintf('\nL1_belief=%d L2_belief=%d\n', L1_belief, L2_belief);
    %fprintf('not_L1_probability=%f not_L2_probabilty=%f\n', not_L1_probability, not_L2_probability);
    
    prediction_no_threash=0;
    if (L1_belief > L2_belief)
        prediction_no_threash = 1;
    elseif (L1_belief < L2_belief)
        prediction_no_threash = 2;
    end
    fprintf('with no threashold would have guessed:%d\n', prediction_no_threash);
    
    
    if (length(find(L2_me_vote <= 0))==L2_numcols && length(find(L1_me_vote > 0))>L1_numcols/2)
        prediction = 1;
    elseif (length(find(L1_me_vote <= 0))==L1_numcols && length(find(L2_me_vote > 0))>L2_numcols/2)
        prediction = 2;
    elseif (abs(L1_belief - L2_belief)<=label_no_decision_threashold)
        prediction = 0;
    elseif (L1_belief > L2_belief)
        prediction = 1;
    elseif (L1_belief < L2_belief)
        prediction = 2;
    end
    
    
    
end

function [L1_xcorr_L1_table_BELOW_L1_xcorr_test ...
          L1_xcorr_L1_table_ABOVE_L1_xcorr_test ...
          L1_xcorr_L2_table_ABOVE_L1_xcorr_test ...
          L1_xcorr_L2_table_BELOW_L1_xcorr_test] = ...
          generate_top_and_bottom_counts(L1_xcorr_L1_table, L1_xcorr_L2_table, L1_xcorr_test)
      
    [L1_numrows L1_numcols] = size(L1_xcorr_L1_table);
    L1_xcorr_L1_table_BELOW_L1_xcorr_test = zeros(1, L1_numcols); %b_o
    L1_xcorr_L1_table_ABOVE_L1_xcorr_test = zeros(1, L1_numcols); %t_o
    L1_xcorr_L2_table_ABOVE_L1_xcorr_test = zeros(1, L1_numcols); %t_x
    L1_xcorr_L2_table_BELOW_L1_xcorr_test = zeros(1, L1_numcols); %b_x
    for L1_spread_col_index = 1:L1_numcols
        %number of L1_xcorr_L1_table below L1_xcorr_test = bo
        L1_xcorr_L1_table_BELOW_L1_xcorr_test(1,L1_spread_col_index) = ...
            length(find(L1_xcorr_L1_table(:,L1_spread_col_index)<L1_xcorr_test(L1_spread_col_index)));
        
        %number of L1_xcorr_L1_table above L1_xcorr_test = to
        L1_xcorr_L1_table_ABOVE_L1_xcorr_test(1,L1_spread_col_index) = ...
            length(find(L1_xcorr_L1_table(:,L1_spread_col_index)>=L1_xcorr_test(L1_spread_col_index)));
        
        %number of L1_xcorr_L2_table above L1_xcorr_test = tx
        L1_xcorr_L2_table_ABOVE_L1_xcorr_test(1,L1_spread_col_index) = ...
            length(find(L1_xcorr_L2_table(:,L1_spread_col_index)>L1_xcorr_test(L1_spread_col_index)));
        
        %number of L1_xcorr_L2_table below L1_xcorr_test = bx
        L1_xcorr_L2_table_BELOW_L1_xcorr_test(1,L1_spread_col_index) = ...
            length(find(L1_xcorr_L2_table(:,L1_spread_col_index)<=L1_xcorr_test(L1_spread_col_index)));
    end
end

function [L_xcorr_test] = L_xcorr_test(L, test)

    [L_numrows L_numcols] = size(L);

    L_xcorr_test = zeros(1, L_numcols);
    
    for L_template = 1:L_numcols
        L_xcorr_test(1, L_template) = ...
            max(xcorr(L(:,L_template),test,'coeff'));
        
        %L(:,L_template)
    end

end

function [L1_xcorr_L1_table L1_xcorr_L2_table] = generate_template_xcorr_spread_table(L1, L2)
    [L1_numrows L1_numcols] = size(L1);
    [L2_numrows L2_numcols] = size(L2);

    L1_xcorr_L1_table = zeros(L1_numcols, L1_numcols);
    L1_xcorr_L2_table = zeros(L2_numcols, L2_numcols);

    for fixed_from_L1 = 1:L1_numcols

        for L1_template_index = 1:L1_numcols
            L1_xcorr_L1_table(L1_template_index, fixed_from_L1) = ...
                max(xcorr(L1(:,fixed_from_L1), L1(:,L1_template_index), 'coeff'));
        end

        for L2_template_index = 1:L2_numcols
            L1_xcorr_L2_table(L2_template_index, fixed_from_L1) = ...
                max(xcorr(L1(:,fixed_from_L1), L2(:,L2_template_index), 'coeff'));
        end
    end
end