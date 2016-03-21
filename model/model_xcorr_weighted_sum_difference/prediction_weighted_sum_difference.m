



function [prediction sum_distance] = prediction_weighted_sum_difference(Label1, Label2, test, numTemplates,...
    wheretoplot1, wheretoplot2, wheretoplot3)

    addpath('../model_xcorr_avg_dynamic_template_selection') %needs filter_template_xcorr function from this dir
    
    
    persistent L1;
    persistent L2;
    
    persistent L1_xcorr_L1_table;
    persistent L1_xcorr_L2_table;
    
    persistent L2_xcorr_L2_table;
    persistent L2_xcorr_L1_table;
    
    
    NUMTEMPLATES = 10;
    
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

    [L1_rows L1_numcols] = size(L1);
    [L1_rows L2_numcols] = size(L2);

    subplot(wheretoplot1)
    title('L1 xcorr all templates')
    hold on
    for i=1:L1_numcols
    plot(ones(length(L1_numcols))*i, L1_xcorr_L1_table(:,i), 'ob')    
    plot(ones(length(L1_numcols))*i, L1_xcorr_L2_table(:,i), 'xr')
    end

    subplot(wheretoplot2)
    title('L2 xcorr all templates')
    hold on
    for i=1:L2_numcols
    plot(ones(length(L2_numcols))*i, L2_xcorr_L2_table(:,i), 'xr')    
    plot(ones(length(L2_numcols))*i, L2_xcorr_L1_table(:,i), 'ob')
    end
    
    L1_x_L1_sum = sum(L1_xcorr_L1_table);
    L1_x_L2_sum = sum(L1_xcorr_L2_table);
    L1_sum_difference_weight = L1_x_L1_sum - L1_x_L2_sum;
    
    L2_x_L2_sum = sum(L2_xcorr_L2_table);
    L2_x_L1_sum = sum(L2_xcorr_L1_table);
    L2_sum_difference_weight = L2_x_L2_sum - L2_x_L1_sum;
    
    L1_xcorr_test = L_xcorr_test(L1, test);
    L2_xcorr_test = L_xcorr_test(L2, test);
    
    subplot(wheretoplot3)
    %clf(wheretoplot3);
    %hold on
    plot(1:length(L1_xcorr_test), L1_xcorr_test, 'ob', 1:length(L2_xcorr_test), L2_xcorr_test, 'xr')
    %plot()
    title('xcorr test')
    %hold off
    
    L1_vote = sum(L1_xcorr_test.*L1_sum_difference_weight);
    L2_vote = sum(L2_xcorr_test.*L2_sum_difference_weight);
    
    sum_distance = abs(L1_vote - L2_vote)/numTemplates;
    prediction = ~(L1_vote > L2_vote) + 1;
    
    %{
    %counting votes from L1
    [L1_xcorr_L1_table_BELOW_L1_xcorr_test ... %b_o
     L1_xcorr_L1_table_ABOVE_L1_xcorr_test ... %t_o
     L1_xcorr_L2_table_ABOVE_L1_xcorr_test ... %t_x
     L1_xcorr_L2_table_BELOW_L1_xcorr_test]... %b_x
     = generate_top_and_bottom_counts(L1_xcorr_L1_table, L1_xcorr_L2_table, L1_xcorr_test);
 
    L1_vote_me_vector = (((L1_xcorr_L1_table_BELOW_L1_xcorr_test - L1_xcorr_L1_table_ABOVE_L1_xcorr_test) > (L1_numcols/2)) ...
                        & ...
                        ((L1_xcorr_L2_table_BELOW_L1_xcorr_test - L1_xcorr_L2_table_ABOVE_L1_xcorr_test) > (L1_numcols/2)));
    L1_vote_against_me_vector = (((L1_xcorr_L1_table_BELOW_L1_xcorr_test - L1_xcorr_L1_table_ABOVE_L1_xcorr_test) < (L1_numcols/2)) ...
                        & ...
                        ((L1_xcorr_L2_table_BELOW_L1_xcorr_test - L1_xcorr_L2_table_ABOVE_L1_xcorr_test) < (L1_numcols/2)));
                    
    num_votes_for_L1 = sum(L1_vote_me_vector + (-1)*L1_vote_against_me_vector);
    
    %counting votes from L2
    [L2_xcorr_L2_table_BELOW_L1_xcorr_test ... %b_x
     L2_xcorr_L2_table_ABOVE_L1_xcorr_test ... %t_x
     L2_xcorr_L1_table_ABOVE_L1_xcorr_test ... %t_o
     L2_xcorr_L1_table_BELOW_L1_xcorr_test]... %b_o
     = generate_top_and_bottom_counts(L2_xcorr_L2_table, L2_xcorr_L1_table, L1_xcorr_test);
 
    L2_vote_me_vector = (((L1_xcorr_L1_table_BELOW_L1_xcorr_test - L1_xcorr_L1_table_ABOVE_L1_xcorr_test) > (L1_numcols/2)) ...
                        & ...
                        ((L1_xcorr_L2_table_BELOW_L1_xcorr_test - L1_xcorr_L2_table_ABOVE_L1_xcorr_test) > (L1_numcols/2)));
    L2_vote_against_me_vector = (((L1_xcorr_L1_table_BELOW_L1_xcorr_test - L1_xcorr_L1_table_ABOVE_L1_xcorr_test) < (L1_numcols/2)) ...
                        & ...
                        ((L1_xcorr_L2_table_BELOW_L1_xcorr_test - L1_xcorr_L2_table_ABOVE_L1_xcorr_test) < (L1_numcols/2)));
                    
    num_votes_for_L2 = sum(L1_vote_me_vector + (-1)*L1_vote_against_me_vector);
    %}
    
    
end

function [L1_xcorr_L1_table_BELOW_L1_xcorr_test ...
          L1_xcorr_L1_table_ABOVE_L1_xcorr_test ...
          L1_xcorr_L2_table_ABOVE_L1_xcorr_test ...
          L1_xcorr_L2_table_BELOW_L1_xcorr_test] = ...
          generate_top_and_bottom_counts(L1_xcorr_L1_table, L1_xcorr_L2_table, L1_xcorr_test)
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
    end

end

function [L1_xcorr_L1_table L1_xcorr_L2_table] = generate_template_xcorr_spread_table(L1, L2)
    [L1_numrows L1_numcols] = size(L1);
    [L2_numrows L2_numcols] = size(L2);

    L1_xcorr_L1_table = zeros(L1_numcols, L1_numcols);
    L1_xcorr_L2_table = zeros(L2_numcols, L1_numcols);

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