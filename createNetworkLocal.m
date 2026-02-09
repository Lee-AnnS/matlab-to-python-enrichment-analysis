%% Internal Function: createNetworkLocal

% This function takes a list of gene symbols (pathwayData) and constructs a
% network using a human interactome. It filters the interactome to include
% only the interactions where both proteins are in the provided gene list,
% removes self-loops, annotates the interactions with differential
% expression information, and finally creates and plots the network graph.
%
% Usage:
%    filteredNetwork = createNetworkLocal(inputGenes);
%
% Input:
%    pathwayData - A list (e.g., cell array or table column) of gene
%    symbols of interest.
%
% Output:
%    pathwayData - A table containing the filtered network interactions
%    with additional annotations and corrections applied.

function pathwayData = createNetworkLocal(pathwayData)

    % --------------------------------------------------------------------
    % Step 1: Load the Human Interactome Data
    % --------------------------------------------------------------------
    % Read the human interactome data from an Excel file.
    % Note: The interactome may not be comprehensive.
    fprintf('\n Reading the Human Interactome Data \n')
    interactome = readtable('Human_Interactome.xlsx');

    % --------------------------------------------------------------------
    % Step 2: Filter Interactome for Relevant Genes
    % --------------------------------------------------------------------
    % Store a copy of the input gene list for later comparison.
    networkGenes = pathwayData;
    
    % Filter the interactome to retain only the interactions where both
    % proteins (columns 'Protein1' and 'Protein2') are present in the input
    % gene list.
    pathwayData = interactome( ...
        ismember(interactome.Protein1, pathwayData) & ...
        ismember(interactome.Protein2, pathwayData) , :);
    
    % --------------------------------------------------------------------
    % Step 3: Remove Self-Loop Interactions
    % --------------------------------------------------------------------
    % Identify self-loop interactions where the same protein appears as 
    % both the source and target.
    selfLoop = strcmpi(pathwayData.Protein1, pathwayData.Protein2);
    
    % Remove these self-loop rows from the filtered interactome.
    pathwayData(selfLoop, :) = [];
    
    % --------------------------------------------------------------------
    % Step 4: Annotate Differential Expression
    % --------------------------------------------------------------------
    % Create a new column 'DiffExpressed' to indicate whether Protein1 is
    % part of the original gene list. This can later be used to color-code
    % nodes in the network.
    ogProteins = contains(pathwayData.Protein1, networkGenes);
    pathwayData.DiffExpressed = double(ogProteins);
    
    % ---------------------------------------------------------------------
    % Step 5: Clean Up Interaction Data
    % ---------------------------------------------------------------------
    % Occasionally, the 'Interaction' field may contain an incorrect arrow
    % format. Replace any occurrence of '-t>' with the corrected arrow
    % '->t'.
    bad = contains(pathwayData.Interaction, '-t>');
    pathwayData.Interaction(bad, 1) = {'->t'};
    
    % ---------------------------------------------------------------------
    % Step 6: Create the Network Graph
    % ---------------------------------------------------------------------
    % Build a directed graph using the filtered interactions.
    % Nodes are defined by the proteins in 'Protein1' and 'Protein2'.
    networkGraph = digraph(pathwayData.Protein1, pathwayData.Protein2);
    
    % Attach the Interaction types to the edges of the graph.
    networkGraph.Edges.Interaction = pathwayData.Interaction;
    
    % Plot the network graph using a force-directed layout. The
    % 'usegravity' option and parameters like MarkerSize and ArrowSize
    % improve the visualization.
    figure()
    theGraph = plot(networkGraph, 'layout', 'force', 'usegravity', true, ...
                    'MarkerSize', 15, 'ArrowSize', 6, 'EdgeAlpha', 0.80, ...
                    'LineWidth', 0.5000);
    % Adjust axes properties for better visual clarity.
    set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'visible', 'off')
    title('mTOR-Network', 'FontSize', 18)
    
    % ---------------------------------------------------------------------
    % Step 7: Highlight Specific Interaction Types
    % ---------------------------------------------------------------------
    % Hold the current plot to add additional highlighting.
    hold on
    
    % Identify all unique interaction types in the network.
    allInters = unique(networkGraph.Edges.Interaction);
    % Loop through each interaction type to highlight edges differently.
    for ii = 1:length(allInters)
        % Get the current interaction type.
        cur_inter = allInters(ii, 1);
        % Find the edges corresponding to the current interaction type.
        locsG = contains(networkGraph.Edges.Interaction, cur_inter);
        % Get the source and target indices of all edges.
        [sOut, tOut] = findedge(networkGraph);
        allEdges = [sOut, tOut];
        % Extract the subset of edges for the current interaction type.
        subGraph = allEdges(locsG, :);
        % Reshape the edge indices into a vector for the highlight function.
        subGraph = reshape(subGraph', 1, []);
        
        % Highlight edges based on the type of interaction:
        % - '->i' indicates simple protein-protein interactions.
        if strcmp(cur_inter, '->i')
            highlight(theGraph, subGraph, 'EdgeColor', [0.73 0.49 0.43],...
                      'LineWidth', 1.5, 'LineStyle', '--');
        % - '->p' indicates phosphorylation events.
        elseif strcmp(cur_inter, '->p')
            highlight(theGraph, subGraph, 'EdgeColor', 'b', 'LineWidth',2);
        % - '-a>' indicates activation interactions.
        elseif strcmp(cur_inter, '-a>')
            highlight(theGraph, subGraph, 'EdgeColor', ...
                [0.32 0.79 0.43], 'LineWidth', 2);
        % - '-a|' indicates inhibition interactions.
        elseif strcmp(cur_inter, '-a|')
            highlight(theGraph, subGraph, 'EdgeColor', 'r', 'LineWidth',2);
        % - All other interactions get a neutral color.
        else
            highlight(theGraph, subGraph, 'EdgeColor', [0.5 0.5 0.5],...
                'LineWidth', 1.5);
        end
    end
    
    % Release the hold on the current plot.
    hold off
end
