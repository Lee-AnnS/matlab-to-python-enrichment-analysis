%% Enrichment Plotter
% This function takes enrichment data for two clusters (e.g., Group1 and
% Group2) and generates horizontal bar plots for the top enrichment terms
% based on their Score. It dynamically adjusts the number of rows to plot
% based on the available data, allows custom colors and labels to be
% specified, and exports a summary table.
%
% Inputs:
%   - dataSet1      : Table containing enrichment terms and their associated Score for Group1.
%   - dataSet2      : Table containing enrichment terms and their associated Score for Group2.
%   - analysisTitle : A string used as part of the plot title (e.g., 'Biological Process').
%   - customColors  : (Optional) A 2x3 matrix specifying custom colors for the two clusters.
%   - barLabels     : (Optional) A cell array of names for labeling the two clusters (e.g., {'High', 'Low'}).
%
% Outputs:
%   - Group1Terms : A cell array of enrichment terms from Group1.
%   - Group2Terms : A cell array of enrichment terms from Group2.
%
% Additional Notes:
%   - The function automatically adjusts the number of rows to plot if the data has less than 15 rows.
%   - It creates a combined table of top enrichment terms from both clusters and writes this table
%     to an Excel file named 'Enrichment_Terms_Table.xlsx' (sheet 1).
%   - The bar plots are created in a single figure with two subplots.
%   - Each bar in the plots is annotated with the corresponding enrichment term.
%   - If an enrichment term contains six or more words, it is shortened by keeping the first four words,
%     followed by an ellipsis and a truncated final word.
%
% Usage:
%   [Group1Terms, Group2Terms] = enrichr_data_plotter(dataSet1, dataSet2, analysisTitle);
%   [Group1Terms, Group2Terms] = enrichr_data_plotter(dataSet1, dataSet2, analysisTitle, customColors, barLabels);

function [Group1Terms, Group2Terms] = enrichr_data_plotter2(dataSet1, dataSet2, analysisTitle, customColors, barLabels)

    % ---------------------------------------------------------------------
    % Define the Number of Rows to Plot
    % ---------------------------------------------------------------------
    % Default number of rows (enrichment terms) to plot is 15.
    numRows = 15; 

    % Adjust the number of rows if either dataset has fewer than 15 rows.
    if height(dataSet1) < 15 || height(dataSet2) < 15 
       if height(dataSet1) <= height(dataSet2)
           numRows = height(dataSet1);
       else
           numRows = height(dataSet2);
       end
    end

    % ---------------------------------------------------------------------
    % Combine the Data from Both Clusters
    % ---------------------------------------------------------------------
    % Create a cell array to label each entry by its cluster.
    % The first numRows entries will be labeled 'Group1', and the next
    % numRows entries as 'Group2'.
    clusterLabels = [ repmat({'Group1'}, numRows, 1); ...
        repmat({'Group2'}, numRows, 1) ];
    
    % Concatenate the top numRows rows from both tables.
    % Here, it is assumed that column 1 contains the enrichment term and
    % column 8 contains the Score.
    combinedTable = [ dataSet1(1:numRows, [1, 8]); ...
        dataSet2(1:numRows, [1, 8])];

    % Create a combined table by prepending the clusterLabels column.
    combinedData = [clusterLabels, combinedTable];
    % Rename the first column to 'Cluster' for clarity.
    combinedData.Properties.VariableNames(1) = {'Cluster'};

    % ---------------------------------------------------------------------
    % Data Conversion
    % ---------------------------------------------------------------------
    % Ensure that the 'Score' column is numeric.
    if iscell(combinedData.CombinedScore)
        combinedData.CombinedScore = str2double(combinedData.CombinedScore);
    end

    % ---------------------------------------------------------------------
    % Sort the Data for Better Visualization
    % ---------------------------------------------------------------------
    % Sort the table in ascending order based on the Score.
    combinedData = sortrows(combinedData, 'CombinedScore', 'ascend');
    
    % Create an index vector to differentiate between clusters.
    % For entries where Cluster equals 'Group2', index will be 2; otherwise, 1.
    clusterIndex = strcmpi(combinedData.Cluster, 'Group2') + 1;

    % ---------------------------------------------------------------------
    % Set Plot Colors and Bar Labels
    % ---------------------------------------------------------------------
    % Set default colors if custom colors are not provided.
    if nargin == 3
        plotColors = [0.301 0.7450 0.933; 0.9705 0.5901 0];
    elseif nargin <= 4
        plotColors = customColors;
    end

    % Set default bar labels for the subplots.
    defaultLabels = {'High', 'Low'};
    % If barLabels argument is provided, override the default names.
    if nargin == 5
        defaultLabels = barLabels;
        plotColors = customColors;
    end

    % ---------------------------------------------------------------------
    % Plotting the Enrichment Terms
    % ---------------------------------------------------------------------
    % Create a new figure and clear any previous content.
    figure();
    clf
    % Set the position and size of the figure window.
    set(gcf, 'position', [616 560 1000 457]);

    % Loop over the two clusters to create subplots.
    for jj = 1:2
        % Create a subplot for the current cluster.
        subplot(1, 2, jj)
        % Extract the rows from the combined table corresponding to the
        % current cluster.
        plotData = combinedData(clusterIndex == jj, :);
        
        % Create a horizontal bar plot of the Score.
        % The bar color is chosen from plotColors and set to
        % semi-transparent (FaceAlpha 0.6).
        barh(plotData.CombinedScore, 'FaceColor', plotColors(jj, :), ...
            'FaceAlpha', 0.6)
        hold on
        
        % -----------------------------------------------------------------
        % Annotate the Bars with Enrichment Terms
        % -----------------------------------------------------------------
        % Loop through each bar (row) in the current subset of data.
        for ii = 1:size(plotData, 1)
            % Retrieve the enrichment term from the current row.
            enrichmentTerm = plotData.Term{ii};
            
            % If the enrichment term contains six or more words, shorten it.
            if numel(strsplit(enrichmentTerm)) >= 6
                enrichmentTerm = split(enrichmentTerm);
                % Shorten the term: combine the first four words with an
                % ellipsis and a truncated final word.
                termEnd = eraseBetween(enrichmentTerm(end)', 1, '-');
                enrichmentTerm = strjoin([enrichmentTerm(1:4)', '...', termEnd]);
            end
            
            % Add the enrichment term as a text annotation next to the
            % corresponding bar.
            text(1, ii, enrichmentTerm, 'FontSize', 13, 'FontWeight', 'bold');
        end
        
        % -----------------------------------------------------------------
        % Customize Axes and Labels
        % -----------------------------------------------------------------
        
        % Remove the y-axis tick labels, set box style, line width, and
        % font settings. Adjust the y-axis limits based on the number of
        % rows and x-axis limit based on maximum Score.
        set(gca, 'Box', 'off', 'LineWidth', 1.5, 'FontSize', 14,...
            'FontWeight', 'bold', 'YTickLabel', [], 'YTick', [], ...
            'YLim', [0.5, numRows+0.5], ...
            'XLim', [0, max(plotData.CombinedScore)]);
        % Set the subplot title combining the analysis title and the
        % corresponding bar label.
        title([analysisTitle, ': ', defaultLabels{jj}], 'FontSize', 15);
        % Label the x-axis.
        xlabel('\bf Score', 'FontSize', 13);
        hold off
    end

    % ---------------------------------------------------------------------
    % Cleanup and Return Enrichment Terms
    % ---------------------------------------------------------------------
    % Clear temporary variables to avoid cluttering the workspace.
    clear plotData jj ii clusterIndex plotColors numRows enrichmentTerm ...
        clusterLabels combinedTable

    % Return the enrichment terms from both input datasets for downstream
    % analysis.
    Group1Terms = dataSet1.Term;
    Group2Terms = dataSet2.Term;
end
