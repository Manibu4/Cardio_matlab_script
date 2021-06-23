clear all
close all
clc

% Load Data
struct = load('Patients.mat');
Patients = struct.Patients;
Vols = cell(1,length(Patients));

% Save all ROI Volumes in a new structure Vols; Vols{i} then contains the i-th volume curve
for i = 1:length(Patients)
    Vols{i} = Patients(i).ROI_Volume;
end

% Iterate over all patients
for i = 1:length(Patients)
	% Scaling of the values by 10^(-3)
    Vol = Vols{i}'/(10^3);
    % x axis equates to a normalised time vector
    x = [1:length(Vols{i})]';
    
    % Define global minimum as first point
    indMIN = find(Vol== min(Vol));
    if indMIN ~= length(Vol)
        Vol = [Vol(indMIN+1:end); Vol(1:indMIN)];
    end
    % Find global maximum
    [ES_Vol, ind_ES_Vol] = max(Vol);
    
    % First deal-breaker: More than 10 changes of sign
    % If yes, then the curve is too wobbly to do anything useful
    if nnz(diff(sign(diff(Vol)))) > 11
    
    	% plot/save curve and display numbers if desired
    	
        % f = figure('visible', 'off');
        % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', x(end), Vol(end), 'gp', 'markersize', 8)
        % hold on
        % plot(x, Vol, 'b--o', 'markersize', 3)
        % hold off
        % title({Patients(i).name, 'curve too wobbly,' 'no use searching anything here'})
        % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
        %        ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
        % legend('boxoff')
        % name = join(['figure',num2str(i)],'_');
        % saveas(f, name, 'jpeg')
        % close(f)
      	% disp([Patients(i).name ': bad (wobbly); ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
        %     num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
        %     num2str(Vol(ind_ES_Vol)-Vol(end))])

% Old deal-breaker. Not in use anymore
%      elseif ES_Vol < 20 || median(Vol) < 20% 
%         figure(i)
%         plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', x(end), Vol(end), 'gp', 'markersize', 8)
%         hold on
%         plot(x, Vol, 'b--o', 'markersize', 3)
%         hold off
%         title('very small values in general')
%         legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
%                ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
%         legend('boxoff')
%         disp([Patients(i).name ': bad (smallvals); ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
%               num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
%               num2str(Vol(ind_ES_Vol)-Vol(end))])

	% Second deal-breaker: Maximum too far to the back
	% If this is the case there is too little data after the maximum to produce anything useful
    elseif ind_ES_Vol > (2/3)*length(Vol)

		% plot/save curve and display numbers if desired   
		
        % f = figure('visible', 'off');
        % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', x(end), Vol(end), 'gp', 'markersize', 8)
        % hold on
        % plot(x, Vol, 'b--o', 'markersize', 3)
        % hold off
        % title({Patients(i).name 'those indices will be too close' 'as the max is already very close to the end'})
        % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
        %        ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
        % legend('boxoff')
        % name = join(['figure',num2str(i)],'_');
        % saveas(f, name, 'jpeg')
        % close(f)
        % disp([Patients(i).name ': bad (closetoend); ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', '...
        %       num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', '...
        %       num2str(Vol(ind_ES_Vol)-Vol(end))])

	% If all the above don't apply, we start looking for PreA and ZwMin	       
    else
        % Only look at the values between the maximum and the end of the curve
        % Are there changes of sign? If yes then there are extrema to be found
        Abl = diff(Vol(ind_ES_Vol:end));
        % Preset PreA and ZwMax to the Endpoint
        ind_PreA = length(Vol);
        ind_ZW_Vol = ind_PreA;
        % First, find PreA
        % If there is no change of sign, check if there is a plateau
        if length(groupcounts(sign(Abl(1:end-1)))) == 1
            % Start from the end and chek if there is a significant change in steepness (= plateau)
            for j = length(Abl)-1:-1:1
                if abs(Abl(j)) < abs(max(Abl))/12
                    ind_PreA = j+ind_ES_Vol;
                    break;
                end
            end
        % If there are one or more changes of sign
        else
            for j = length(Abl)-1:-1:2
            	% Steepnesscriterium               or change of sign
                if abs(Abl(j)) < 0.2*abs(Abl(j+1)) || sign(Abl(j)) ~= sign(Abl(j+1))
                    ind_PreA = j+ind_ES_Vol;
                    break;
                end
            end
            % Set local minimum to the minimum between Max and PreA
            [~, blu] = min(Vol(ind_ES_Vol:ind_PreA));
            ind_ZW_Vol = ind_ES_Vol + blu-1;
        end
    	% When we are here, we have found values and indices for Max, PreA and ZwMin
    	% Check if there are any problematic constellations of these 3
    	
    	% First: ZwMin and PreA too close to each other or PreA too close to end
        if (ind_ZW_Vol-ind_PreA) < 3 && abs(Vol(ind_PreA)-Vol(end)) < 5
        
        	% plot/save curve and display numbers if desired
        	
            % f = figure('visible', 'off');
            % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', ind_PreA, Vol(ind_PreA), 'kp',...
            %      x(end), Vol(end), 'gp', ind_ZW_Vol, Vol(ind_ZW_Vol), 'cp', 'markersize', 8)
            % hold on
            % plot(x, Vol, 'b--o', 'markersize', 3)
            % hold off
            % title('Einzelner Ausreisser in Plateau')
            % title({Patients(i).name, 'pol2 (ptstooclose)'})
            % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
            %        ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
            % legend('boxoff')
            % name = join(['figure',num2str(i)],'_');
            % saveas(f, name, 'jpeg')
            % close(f)
            % disp([Patients(i).name ': pol2 (ptstooclose); ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
            % num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
            % num2str(Vol(ind_ES_Vol)-Vol(end))])
        % Second: PreA has to be 'more to the back' (i.e. larger index) than ZwMin
        elseif ind_PreA <= ind_ZW_Vol
            
            % plot/save curve and display numbers if desired
            
            % f = figure('visible', 'off');
            % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', ind_PreA, Vol(ind_PreA), 'kp',...
            %      x(end), Vol(end), 'gp', ind_ZW_Vol, Vol(ind_ZW_Vol), 'cp', 'markersize', 8)
            % hold on
            % plot(x, Vol, 'b--o', 'markersize', 3)
            % hold off
            % title({Patients(i).name,'PreA <= zwVol'})
            % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
            %        ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
            % legend('boxoff')
            % name = join(['figure',num2str(i)],'_');
            % saveas(f, name, 'jpeg')
            % close(f)
            % disp([Patients(i).name ': pol2; ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
            %   num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
            %   num2str(Vol(ind_ES_Vol)-Vol(end))])
		
		% PreA too close to max (there has to be a min in between)
        elseif ind_PreA - ind_ES_Vol < 4
            
            % plot/save curve and display numbers if desired
            
            % f = figure('visible', 'off');
            % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', ind_PreA, Vol(ind_PreA), 'kp',...
            %      x(end), Vol(end), 'gp', ind_ZW_Vol, Vol(ind_ZW_Vol), 'cp', 'markersize', 8)
            % hold on
            % plot(x, Vol, 'b--o', 'markersize', 3)
            % hold off
            % title({Patients(i).name,'Points are too close together!!'})
            % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
            %        ['ED Vol = ', num2str(Vol(end))], 'location', 'South','NumColumns',2)
            % legend('boxoff')
            % name = join(['figure',num2str(i)],'_');
            % saveas(f, name, 'jpeg')
            % close(f)
            % disp([Patients(i).name ': pol2 (ptstooclose); ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
            %   num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
            %   num2str(Vol(ind_ES_Vol)-Vol(end))])
		
		% If all of the above does not apply, we assume a good curve
        else
        
        	% plot/save curve and display numbers if desired

            % f = figure('visible', 'off');
            % plot(ind_ES_Vol, Vol(ind_ES_Vol), 'rp', ind_PreA, Vol(ind_PreA), 'kp',...
            %      x(end), Vol(end), 'gp', ind_ZW_Vol, Vol(ind_ZW_Vol), 'cp', 'markersize', 8)
            % text(ind_ES_Vol+3, Vol(ind_ES_Vol), ['MaxVol - MinVol = ', num2str(abs(Vol(ind_ES_Vol)-Vol(end)))])
            % text(ind_ES_Vol+3, Vol(ind_ES_Vol)-0.1*(Vol(ind_ES_Vol)-min(Vol(ind_ZW_Vol), Vol(ind_PreA))), ['MaxVol - PreAVol = ', num2str(abs(Vol(ind_ES_Vol)-Vol(ind_PreA)))])
            % text(ind_ES_Vol+3, Vol(ind_ES_Vol)-0.2*(Vol(ind_ES_Vol)-min(Vol(ind_ZW_Vol), Vol(ind_PreA))), ['PreAVol - MinVol = ', num2str(abs(Vol(ind_PreA)-Vol(end)))])
            % hold on
            % plot(x, Vol, 'b--o', 'markersize', 3)
            % hold off
            % title({Patients(i).name,'This should be a good curve'})
            % legend(['ES Vol = ', num2str(Vol(ind_ES_Vol))],...
            %        ['PreA Vol = ', num2str(Vol(ind_PreA))],...
            %        ['ED Vol = ', num2str(Vol(end))],...
            %        ['Vol locMin = ', num2str(Vol(ind_ZW_Vol))], 'location', 'South','NumColumns',2)
            % legend('boxoff')
            % name = join(['figure',num2str(i)],'_');
            % saveas(f, name, 'jpeg')
            % close(f)
            % disp([Patients(i).name ': good-ish/plateau; ' num2str(ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)) ', ' ...
            %    num2str(x(end)) ', ' num2str(Vol(end)) ', ' num2str(x(end)-ind_ES_Vol) ', ' ...
            %    num2str(Vol(ind_ES_Vol)-Vol(end)) ', ' ...
            %    num2str(ind_ZW_Vol) ', ' num2str(Vol(ind_ZW_Vol)) ', ' ...
            %    num2str(ind_PreA) ', ' num2str(Vol(ind_PreA)) ', ' ...
            %    num2str(ind_PreA-ind_ES_Vol) ', ' num2str(Vol(ind_ES_Vol)-Vol(ind_PreA)) ', '...
            %    num2str(x(end)-ind_PreA) ', ' num2str(Vol(ind_PreA)-Vol(end))])
        end
    end
end

