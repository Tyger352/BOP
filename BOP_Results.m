function [] = BOP_Results()

%% BOP_Results is a function that interactively plots the results from BOP


%% Loads output structure from BOP to workspace
%% Each parameter can have any size array, but must be the same size as the other parameters
StatePoints = load('BOP_Output.mat','StatePoints');
Massflow = load('BOP_Output.mat','Massflow');
Wturb = load('BOP_Output.mat','Wturb');
Wcomp = load('BOP_Output.mat','Wcomp');
Wrcomp = load('BOP_Output.mat','Wrcomp');
eff = load('BOP_Output.mat','eff');

%% StatePoints contains four values, [T, P, H, S], or Temperature, Pressure, Enthalpy, and Entropy
%% Split components of StatePoints into four arrays

T = StatePoints(:,1);
P = StatePoints(:,2);
H = StatePoints(:,3);
S = StatePoints(:,4);

%% Stores values to a csv file named BOP Output in the current directory with the following named columns (in order):
% T, P, H, S, Massflow, Wturb, Wcomp, Wrcomp, eff using writematrix

writematrix([T, P, H, S, Massflow, Wturb, Wcomp, Wrcomp, eff],'BOP Output.csv','Delimiter',',');

% Checks if data has single row, if so, say data cannot be plotted
% after plotting data, asks user if they would like to plot another parameter or exit the function

if size(T,1) == 1

    disp('Data cannot be plotted because there is only one row of data.');

else

     % Prompts user to select which parameter to plot using indexing


    prompt = 'Would you like to plot the data? (Y/N) ';
    plot = input(prompt,'s');

    % Checks if user input is valid

    while plot ~= 'Y' && plot ~= 'y' && plot ~= 'N' && plot ~= 'n'

     prompt = 'Invalid input. Would you like to plot the data? (Y/N) ';

     plot = input(prompt,'s');

    end

    % If user would like to plot data, plots data

    if plot == 'Y' || plot == 'y'

        plot_data(plot);

    end

    prompt = 'Would you like to plot another parameter? (Y/N) ';

    plot = input(prompt,'s');

    % Checks if user input is valid

    while plot ~= 'Y' && plot ~= 'y' && plot ~= 'N' && plot ~= 'n'

        prompt = 'Invalid input. Would you like to plot another parameter? (Y/N) ';

    end

    % If user would like to plot another parameter, prompts user to select which parameter to plot using indexing

    if plot == 'Y' || plot == 'y'

        plot_data(plot);

    end


end

function [] = plot_data(plot)

    % Checks if user input is valid
    if plot == 'Y' || plot == 'y'

     prompt = 'Which parameter would you like to plot against eff? (1 = T, 2 = P, 3 = H, 4 = S, 5 = Massflow, 6 = Wturb, 7 = Wcomp, 8 = Wrcomp) ';

     plot = input(prompt);

    end

    % Checks if user input is valid

    while plot < 1 || plot > 8

        prompt = 'Invalid input. Which parameter would you like to plot against eff? (1 = T, 2 = P, 3 = H, 4 = S, 5 = Massflow, 6 = Wturb, 7 = Wcomp, 8 = Wrcomp) ';

        plot = input(prompt);

    end

    % Plot chosen parameter against eff (y-axis)

    plot(plot,eff);
    Labels = {'T','P','H','S','Massflow','Wturb','Wcomp','Wrcomp'};
    xlabel(Labels(plot));
    ylabel('eff');

end













