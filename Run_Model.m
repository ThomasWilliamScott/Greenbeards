% This script runs our multi-locus population genetic model of greenbeard
% evolution, for a given set of parameter values. It records equilibrium
% data in matrix form, with a given parameter varying in one dimension, and
% another parameter varying in the other dimension. These results matrices
% can be fed into the "Generate_Figures.m" script to generate heatmaps, 
% which are the basis of the summary figures of the manuscript (Figures 2 
% & 3). 

clearvars
clc

% SPECIFY PARAMETER VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LmaxR=10; % Number of beard colours.
mu=0.0005; % Trait mutation rate.
maj1 = 0.9; % Initial frequency of nonbeards.
maj2 = 0.9; % Initial proportion of 1st beard colour amongst all beard colours.
helpini = 0.1; % Initial frequency of the helping allele.
alpha=0.01; % Social encounter parameter.
c=0.1; % Cost of helping.
T=100000; % Number of generations in each trial.
d=0.01; % Downstream pleiotropic benefit.
s=0.01; % Cost of growing a beard (signal).
csearch= 0; % Cost of abandoning social partner for a new encounter. This 
% parameter should be fixed at zero, since in the manuscript, it is not
% mentioned, so is implicitly assumed to be zero. We leave this parameter
% in the code to allow interested readers to generate results for csearch>0
% should they wish. See also Scott, Grafen & West (Nat. Commun. 2022) and
% Scott (J. Theor. Biol. 2024) for prior analyses of csearch>0 scenarios in
% similar models of tag-based cooperation.

% For the following two parameters, we consider a range of values, rather
% than just one. "Range" is represented by the "R" notation. By considering
% a range of b and F values, we can generate data underpinning Fig. 3A,
% which has F varying along the x axis and b/c varying along the y axis. To
% generate data underpinning Fig. 2, the parameters that are varied should
% be changed to alpha and d. To generate data underpinning Fig. 3B, the 
% parameters that are varied should be changed to d and F. To generate data
% underpinning Fig. 3C, the parameters that are varied should be changed to
% r (recombination) and alpha. 
bR=[0.05:0.01:0.5]; % Benefit of helping.
FR=[0:0.025:1]; % Population viscosity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We define the following empty arrays, which we will populate with
% results.
resalt  = zeros(length(bR),length(FR)); % Equilibrium altruist frequency.
avgtagfreq  = zeros(length(bR),length(FR)); % Average equilibrium beard-colour frequency 
nonbeardfreq = zeros(length(bR),length(FR)); % Equilibrium nonbeard frequency

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following lines are for initiating the population genotype
% frequencies. They ensure that nonbeard frequency is initially maj1 and 
% helper frequency is initially helpini. They also ensure that one beard 
% colour has an initial frequency amongst bearded individuals of maj2, with
% the remaining 1-maj2 being randomly distributed amongst the remaining 
% L_max-1 beard colours.

for cur_Lmax = 1:length(LmaxR)

    Lmax = LmaxR(cur_Lmax);
    tag = Lmax + 1; % total number of tag states (1 nonbeard + Lmax beard colours).

    popIni = zeros(2,6,tag);

% random distribution into each tag
popIni(1,1,:) = rand(1,tag); 

if Lmax==1 % one beard colour (meaning beards and nonbeards)

% normalise so all tags except 1st one sum to 1-maj1
popIni(1,1,:) = popIni(1,1,:) ./ ( sum(sum(popIni(1,1,:)))-popIni(1,1,1) ) .* (1-maj1)  ;

% 1st tag equals maj1
popIni(1,1,1) = maj1 ;

else

% normalise so all tags except 1st & 2nd sum to 1 - maj1 - (1-maj1)*maj2
popIni(1,1,:) = popIni(1,1,:) ./ ( sum(sum(popIni(1,1,:)))-popIni(1,1,1) -popIni(1,1,2) ) .* (1 - maj1 - (1-maj1).*maj2)  ;

% 1st tag equals maj1
popIni(1,1,1) = maj1 ;

% 2nd tag equals (1-maj1)*maj2
popIni(1,1,2) = (1-maj1)*maj2 ;

end

% redistribute into helper and nonhelper categories
popIni(1,1,:) = popIni(1,1,:) .* (1-helpini);
popIni(2,1,:) = (popIni(1,1,:) ./ (1-helpini) ) .* helpini;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% The following loop across 'scenarios' is used to generate results for the
% case where: (1) There is no recombination between the tag (beard) and the
% helping locus (r=0). This scenario represents a candidate greenbeard. (2)
% There is free recombination between the tag (beard) and the helping locus
% (r=0.5). This scenario represents the 'no linkage' scenario described in
% the main manuscript, used to evaluate the 'Linkage Condition' for 
% greenbeard adaptations. (3) There is no recombination between the tag 
% (beard) and the helping locus (r=0), and there is no cost or benefit of 
% helping (b=c=0). This scenario represents the 'no altruism' scenario 
% described in the main manuscript, used to evaluate the 'Altruism 
% Condition' for greenbeard adaptations.
for scenario = 1:3

    if scenario == 1

        r=0;

    elseif scenario == 2

        r=0.5;

    elseif scenario == 3

        bR = zeros(size(bR));
        c=0;
        r=0;

    end

    

for cur_b = 1:length(bR) % This loops over one of the parameters that we chose to vary (in this case, 'b').
    
    b = bR(cur_b);
    
for cur_F = 1:length(FR) % This loops over the other of the parameters that we chose to vary (in this case, 'F').
    
    F = FR(cur_F);
    
% We create a matrix 'pop' to track the population frequency of each 
% genotype within and across generations. 'pop' has the following 
% characteristics: 
% DIMENSION 1 TRAIT ID
% DIMENSION 2 COLUMN 1 GENOTYPE FREQ AT START OF GENERATION
%                    2 TRAIT (1 if helper; 0 if nonhelper)
%                    3 GENOTYPE FREQ AFTER SELECTION
%                    4 FREQ AFTER RECOMBINATION
%                    5 BEARD VERSUS NO BEARD - EQUALS ONE IF TAG ID 2 OR
%                      HIGHER.
%                    6 GET EXTRA BENEFIT D (EQUALS ONE IF EXHIBIT ALTRUISM 
%                      AND R=0; ZERO OTHERWISE)
% DIMENSION 3 TAG ID
% DIMENSION 4 GENERATION

    pop = zeros(2,6,tag,T+1); % define entry matrix to populate.
    pop(:,:,:,1) = popIni; % this inputs initial genotype frequencies, which we computed above.
    pop(2,2,:,:) = 1;  % helpers given '1' entries.
    pop(:,5,2:tag,:) = 1;  % those who grow beard (everyone except for tag 1) are given '1' entries.
    if r==0
    pop(2,6,:,:) = 1;  % those who get the direct pleiotropic greenbeard benefit 'd' are given '1' entries.
    end
    
for t=1:T % This loops over generations

% This populates the 3rd column of the second dimension of 'pop' with
% genotype frequencies after selection. It applies Equation 1 of the
% Supplementary Information.
pop(:,3,:,t) = pop(:,1,:,t) .* (1 - s .* pop(:,5,:,t) +  pop(:,5,:,t) .*... 
                  ((-csearch .* (1-F) .* alpha .* (1-sum(pop(:,1,:,t)))  + ...  
                  b .*  (F .* pop(:,2,:,t) + (1-F) .* (sum(pop(:,1,:,t) .* pop(:,2,:,t)) ))  - ...    
              ...
                (c - d ) .*  pop(:,2,:,t) .* (F + (1-F) .* sum(pop(:,1,:,t)) )) ... 
                  ./ (1-alpha .*(1-sum(pop(:,1,:,t))).*(1-F)))) ;

% Division through by population average fecundity ensures genotype 
% frequencies sum to one (see Equation 1 of the Supplementary Information).
pop(:,3,:,t) = pop(:,3,:,t) ./ sum(sum(pop(:,3,:,t))) ; 

% The following lines generate the population frequency of each genotype 
% after recombination has occurred. It applies Equation 2 of the
% Supplementary Information.
pop(:,4,:,t) = pop(:,3,:,t) .* (pop(:,3,:,t) + (sum(pop(:,3,:,t))-pop(:,3,:,t)) + (sum(pop(:,3,:,t),3) - pop(:,3,:,t)) + ...  % individual with both tag and trait mating with individual with one or both of tag and trait 
    (1-r) .* (1-sum(pop(:,3,:,t))-sum(pop(:,3,:,t),3) + pop(:,3,:,t))) + ... % individual with tag and trait mating but not recombining with individual lacking both tag and trait
    r .* (sum(pop(:,3,:,t))-pop(:,3,:,t)) .* (sum(pop(:,3,:,t),3) - pop(:,3,:,t)); % individual with one of tag and trait mating and recombining with individual with the other of the tag / trait

% This  line is just to stop the proliferation of rounding errors.
pop(:,4,:,t) = pop(:,4,:,t) ./ sum(sum(pop(:,4,:,t))) ;

% The following lines generate the population frequency of each genotype 
% after trait mutation has occurred. It applies Equation 3 of the
% Supplementary Information. 
pop(1,1,:,t+1) = pop(2,4,:,t) .* (mu) + pop(1,4,:,t) .* (1-mu);  
pop(2,1,:,t+1) = pop(1,4,:,t) .* (mu) + pop(2,4,:,t) .* (1-mu);  

% This  line is just to stop the proliferation of rounding errors.
pop(:,1,:,t+1) = pop(:,1,:,t+1) ./ sum(sum(pop(:,1,:,t+1))) ;

end

% This matrix records the equilibrium helper frequency for each specific 
% combination of our varying parameters (here, b and F).
resalt(cur_b,cur_F) = mean(sum(sum ( pop(:,1,:,round(T/2) : T) .* pop(:,2,:,round(T/2) : T) ))) ; % altruist genotypes

% The 'avgtagfreq' matrix gives the equilibrium 
% average-over-time-and-over-tags tag frequency. We obtain it in three
% steps.
tagfreqs = sum(pop(:,1,2:tag,round(T/2): T));
propgens = 1/numel(round(T/2): T);
avgtagfreq(cur_b,cur_F) = sum(sum((tagfreqs.*(tagfreqs./sum(tagfreqs))) .* propgens));

% The 'nonbeardfreq' matrix gives the equilibrium nonbeard frequency.
nonbeardfreq(cur_b,cur_F) = sum(sum(pop(:,1,1,round(T/2): T)) .* propgens);

% This deletes the matrices that we defined in intermediary steps to 
% calculate our summary statistics. 
clear tagfreqs propgens

end
end

% This saves the results. It saves a separate .mat file for each of the 
% three scenarios: (1) Candidate greenbeard; (2) No Linkage; (3) No 
% altruism. With one of these .mat files loaded into the Workspace, the
% "Generate_Figures" script can be run to convert this data into visual
% heatmaps, which are the basis of the summary figures (2 & 3) of the main
% text. Note that the pop and popIni matrices are not saved.
vars = setdiff(who, {'pop','popIni'});
save("Results_Data_Scenario="+scenario+".mat", vars{:})

end
end