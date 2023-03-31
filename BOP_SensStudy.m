function [] = BOP_SensStudy()

    %% BOP Sensitivity Study
    
    %% Takes in the BOP_Input struct and performs a sensitivity study on the given parameter, determined by the BOP_SensStudy struct
    %% The BOP_SensStudy struct contains the following fields:
    %% sensvar: the first sensitivity variable
    %% sensvar2: the second sensitivity variable
    
    %% Multivar: indicates whether the sensitivity study is multivariable or not
    %% sensrange 1 & 2: the range of the sensitivity variable
    %% sensvarmin 1 & 2: the minimum value of the sensitivity variable
    %% stepsize 1 & 2: the step size of the sensitivity variable

    %% To determine which parameter is being varied from sens var 1 and 2, see the following character array:
    %% SensStudyArray = {"Tmax" 'Tmin' 'Pmin' 'Pratio' 'Recupeff' 'NetWork' 'Reheat' 'iseneffturb' 'iseneffcomp' 'iseneffrcomp' 'UA', 'UAsplit' 'cLTR' 'cHTR'};
    

    %% Load the BOP_Input struct as the input struct
    InputStruct = load("BOP_Inputs.mat","BOP_Inputs");

    Params = InputStruct.BOP_Inputs.Parameters;
    CycleType = InputStruct.BOP_Inputs.CycleType;
    SolveType = InputStruct.BOP_Inputs.SolveType;
    Dyreby = InputStruct.BOP_Inputs.Dyreby;

    %% Load the BOP_SensStudy struct as the SensStudy struct
    SensStudyStruct = load("BOP_SensStudy.mat","BOP_SensStudy");

    SensVar = SensStudyStruct.BOP_SensStudy.sensvar;
    SensVar2 = SensStudyStruct.BOP_SensStudy.sensvar2;
    Multivar = SensStudyStruct.BOP_SensStudy.multivar;
    SensRange1 = SensStudyStruct.BOP_SensStudy.sensrange1;
    SensRange2 = SensStudyStruct.BOP_SensStudy.sensrange2;
    SensVarMin1 = SensStudyStruct.BOP_SensStudy.sensvarmin1;
    SensVarMin2 = SensStudyStruct.BOP_SensStudy.sensvarmin2;
    StepSize1 = SensStudyStruct.BOP_SensStudy.stepsize1;
    StepSize2 = SensStudyStruct.BOP_SensStudy.stepsize2;

    %% Create the sensitivity study vectors

    if Multivar == 0
        SensVar1 = SensVarMin1:StepSize1:SensRange1;
        SensVar2 = 0;
    else
        SensVar1 = SensVarMin1:StepSize1:SensRange1;
        SensVar2 = SensVarMin2:StepSize2:SensRange2;
    end

    %% Determine which parameter is being varied from sens var 1 and 2
    SensStudyArray = {"Tmax" 'Tmin' 'Pmin' 'Pratio' 'Recupeff' 'NetWork' 'Reheat' 'iseneffturb' 'iseneffcomp' 'iseneffrcomp' 'UA', 'UAsplit' 'cLTR' 'cHTR'};
    SensVar1Name = SensStudyArray(SensVar);

    %% Check if second sensitivity variable is being varied (sensVar2 ~= 0)
    if SensVar2 ~= 0
        SensVar2Name = SensStudyArray(SensVar2);
    end

    %% Create the sensitivity study matrix
    %% If single variable, the matrix will be a single column
    %% If multivariable, the matrix will be a 2D matrix
    SensStudyMatrix = zeros(length(SensVar1),length(SensVar2));

    %% Sets relevant parameters to the sensitivity study values
    %% Runs the BOP model
    %% Stores the results in the SensStudyMatrix

    %% Preallocate the results struct size
    Results = struct('Tmax',[],'Tmin',[],'Pmin',[],'Pratio',[],'Recupeff',[],'NetWork',[],'Reheat',[],'iseneffturb',[],'iseneffcomp',[],'iseneffrcomp',[],'UA',[],'UAsplit',[],'cLTR',[],'cHTR',[],'SensVar1',[],'SensVar2',[]);

    %% Loop through the sensitivity study matrix

    for i = 1:length(SensVar1)
        for j = 1:length(SensVar2)
            if SensVar2 ~= 0
                Params.(SensVar1Name) = SensVar1(i);
                Params.(SensVar2Name) = SensVar2(j);
            else
                Params.(SensVar1Name) = SensVar1(i);
            end
            [Results(i,j)] = BOP_Model(Params,CycleType,SolveType,Dyreby);
        end
    end

    %% Results struct contains the results of the sensitivity study, with each row corresponding to a different value of the first sensitivity variable and each column corresponding to a different value of the second sensitivity variable
    %% Deconstruct the results struct into the individual results
    %% Store the results in the BOP_Results struct

    %% Write results for each sensitivity variable to a csv file, indicating the current sensitivity variables for each set of results

    %% Check if BOP_SensStudyResults.csv exists, if it does, delete it
    if exist("BOP_Results.csv", 'file') == 2
        delete("BOP_Results.csv");
    end

    if SensVar2 ~= 0
        for i = 1:length(SensVar1)
            for j = 1:length(SensVar2)
                Results(i,j).SensVar1 = SensVar1(i);
                Results(i,j).SensVar2 = SensVar2(j);
            end
        end
        writetable(struct2table(Results), "BOP_SensStudyResults.csv");
    else
        for i = 1:length(SensVar1)
            Results(i).SensVar1 = SensVar1(i);
        end
        writetable(struct2table(Results), "BOP_SensStudyResults.csv");
    end

  
    %% Ask user if they want to plot the results
    PlotResults = input("Do you want to plot the results? (y/n): ", 's');

    %% check if valid input, not case sensitive
    while PlotResults ~= 'y' && PlotResults ~= 'Y' && PlotResults ~= 'n' && PlotResults ~= 'N'
        PlotResults = input("Invalid input. Do you want to plot the results? (y/n): ", 's');
    end



    %% Plot the results if user wants
      % Plot results if multivariable as 
        % figure;
        % surf(property,property2,effstudy)
        % xlabel(label);
        % ylabel(label2);
        % zlabel("efficiency (%)");

        % plot results if singe variable as 
        %figure(2);
        %% plot(property, massflowstudy)
        % xlabel(label);
        % ylabel('Mass Flow Rate kg/s');
       % grid on

    if PlotResults == 'y' || PlotResults == 'Y'

        BOP_PlotResults(Results,SensVar1,SensVar2,SensVar1Name,SensVar2Name)

    else
        return
    end


    %% End of main function
    %% Start of subfunctions

    function [] = BOP_PlotResults(Results,SensVar1,SensVar2,SensVar1Name,SensVar2Name)

    

        %% Results struct:
        %% [Results.StatePoints, Results.Massflow, Results.Wturb, Results.Wcomp, 
        %%Results.eff, Results.Qin, Results.Qout, Results.Preheat, Results.Recupeff, 
        %%Results.RecompFrac, Results.UA, Results.UAsplit, Results.Q_in, Results.c_ltr, Results.c_htr]

        %% Check if multivariable

        if SensVar2 ~= 0
            %% Plot the results against the sensitivity parameters as a 3D surface
            %% set all axes fixed at origin


            

            
            figure;
            surf(SensVar1,SensVar2,Results.eff);
            xlabel(SensVar1Name);
            ylabel(SensVar2Name);
            zlabel("Cycle Efficiency (%)");
            grid on

            figure;
            surf(SensVar1,SensVar2,Results.Wturb);
            xlabel(SensVar1Name);
            ylabel(SensVar2Name);
            zlabel("Turbine Work (MW)");
            grid on

            figure;
            surf(SensVar1,SensVar2,Results.Wcomp);
            xlabel(SensVar1Name);
            ylabel(SensVar2Name);
            zlabel("Compressor Work (MW)");
            grid on

            figure;
            surf(SensVar1,SensVar2,Results.Qin);
            xlabel(SensVar1Name);
            ylabel(SensVar2Name);
            zlabel("Heat Input (MW)");
            grid on

            figure;
            surf(SensVar1,SensVar2,Results.Qout);
            xlabel(SensVar1Name);
            ylabel(SensVar2Name);
            zlabel("Heat Output (MW)");
            grid on

            %% If Wrcomp exists, plot it

            if isfield(Results,'Wrcomp')
                figure;
                surf(SensVar1,SensVar2,Results.Wrcomp);
                xlabel(SensVar1Name);
                ylabel(SensVar2Name);
                zlabel("Recompression Work (MW)");
                grid on
            end
    
            %% if WReheatTurb exists, plot it

            if isfield(Results,'WReheatTurb')
                figure;
                surf(SensVar1,SensVar2,Results.WReheatTurb);
                xlabel(SensVar1Name);
                ylabel(SensVar2Name);
                zlabel("Reheat Turbine Work (MW)");
                grid on
            end

            %% if WReheatComp exists, plot it

            if isfield(Results,'WReheatComp')
                figure;
                surf(SensVar1,SensVar2,Results.WReheatComp);
                xlabel(SensVar1Name);
                ylabel(SensVar2Name);
                zlabel("Reheat Compressor Work (MW)");
                grid on
            end

            %% if RecompFrac exists, plot it

            if isfield(Results,'RecompFrac')
                figure;
                surf(SensVar1,SensVar2,Results.RecompFrac);
                xlabel(SensVar1Name);
                ylabel(SensVar2Name);
                zlabel("Recompression Fraction");
                grid on
            end
        else
            %% Plot the results as a 2D plot

            figure;
            plot(SensVar1,Results.eff);
            xlabel(SensVar1Name);
            ylabel("efficiency (%)");
            grid on

            figure;
            plot(SensVar1,Results.Wturb);
            xlabel(SensVar1Name);
            ylabel("Turbine Work (MW)");
            grid on

            figure;
            plot(SensVar1,Results.Wcomp);
            xlabel(SensVar1Name);
            ylabel("Compressor Work (MW)");
            grid on

            figure;
            plot(SensVar1,Results.Qin);
            xlabel(SensVar1Name);
            ylabel("Heat Input (MW)");
            grid on

            figure;
            plot(SensVar1,Results.Qout);
            xlabel(SensVar1Name);
            ylabel("Heat Output (MW)");
            grid on

            %% If Wrcomp exists, plot it

            if isfield(Results,'Wrcomp')
                figure;
                plot(SensVar1,Results.Wrcomp);
                xlabel(SensVar1Name);
                ylabel("Recompression Work (kW)");
                grid on
            end

            if isfield(Results,'WReheatTurb')
                figure;
                plot(SensVar1,Results.WReheatTurb);
                xlabel(SensVar1Name);
                ylabel("Reheat Turbine Work (kW)");
                grid on
            end

            if isfield(Results, 'RecompFrac')
                figure;
                plot(SensVar1,Results.RecompFrac);
                xlabel(SensVar1Name);
                ylabel("Recompression Fraction");
                grid on
            end
        
        end
        

    
      

    end


    function [Results] = BOP_Model(Params,CycleType,Dyreby)

        %% Runs the chosen cycle from CycleType

        %% BOP_Simple(Tmin, Tmax, Pmin,Pratio,iseneffturb,iseneffcomp,NetWork)
        %% BOP_Reheat(Tmin, Tmax, Pmin,Pratio,Preheat,iseneffturb,iseneffcomp,NetWork)
        %% BOP_Recup(Tmin, Tmax, Pmin,Pratio,Recupeff,iseneffturb,iseneffcomp,NetWork)
        %% BOP_RecompDyreby(Tmin, Tmax, Pmin,Pratio,RecompFrac,iseneffturb,iseneffcomp,iseneffrcomp,UA,UAsplit,NetWork)
        %% BOP_RecompText(Tmin, Tmax, Pmin, Pratio, Q_in,iseneffturb,iseneffcomp,iseneffrcomp, c_ltr, c_htr)



        switch CycleType

        case 1
            BOP_Simple(Params.Tmin, Params.Tmax, Params.Pmin,Params.Pratio,Params.iseneffturb,Params.iseneffcomp,Params.NetWork);
        case 2
            BOP_Reheat(Params.Tmin, Params.Tmax, Params.Pmin,Params.Pratio,Params.Preheat,Params.iseneffturb,Params.iseneffcomp,Params.NetWork);
        case 3
            BOP_Recup(Params.Tmin, Params.Tmax, Params.Pmin,Params.Pratio,Params.Recupeff,Params.iseneffturb,Params.iseneffcomp,Params.NetWork);
        case 4
            if Dyreby == 1
                BOP_RecompDyreby(Params.Tmin, Params.Tmax, Params.Pmin,Params.Pratio,Params.RecompFrac,Params.iseneffturb,Params.iseneffcomp,Params.iseneffrcomp,Params.UA,Params.UAsplit,Params.NetWork);
            else
                BOP_RecompText(Params.Tmin, Params.Tmax, Params.Pmin, Params.Pratio, Params.Q_in,Params.iseneffturb,Params.iseneffcomp,Params.iseneffrcomp, Params.cLTR, Params.cHTR);
            end

        end

        %% Store the outputs in the Results struct
        Results.StatePoints =  load('BOP_Output.mat','StatePoints');
        Results.Massflow = load('BOP_Output.mat','Massflow');
        Results.Wturb = load('BOP_Output.mat','Wturb');
        Results.Wcomp = load('BOP_Output.mat','Wcomp');
        Results.eff = load('BOP_Output.mat','eff');
        Results.Qin = load('BOP_Output.mat','Qin');
        Results.Qout = load('BOP_Output.mat','Qout');

        %% Some Cycles have additional outputs, so they are stored in the Results struct if they exist
        %% Reheat : Preheat, Recup: Recupeff, RecompDyreby: RecompFrac, UA, UAsplit, RecompText: Q_in, c_ltr, c_htr

        switch CycleType
        case 2
            Results.WReheatTurb = load('BOP_Output.mat','WReheatTurb');
        case 4
            if Dyreby ~= 1
               Results.RecompFrac = load('BOP_Output.mat','RecompFrac');
            end
        end

    end

    %% Resulting Results structure is: 
    %% [Results.StatePoints, Results.Massflow, Results.Wturb, Results.Wcomp, Results.eff, Results.Qin, Results.Qout, Results.Preheat, Results.Recupeff, Results.RecompFrac, Results.UA, Results.UAsplit, Results.Q_in, Results.c_ltr, Results.c_htr]





end









