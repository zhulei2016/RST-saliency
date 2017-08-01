    % ----------------------------------------------------------------
    % function CalScale
    % input:  I ...........Input image
    % output: ScaleMap.....Output Scale Map
    % implementation described in the paper:
    % Peng Jiang, Haibin Ling, Jingyi Yu, Jingliang Peng
    % Salient Region Detection by UFO: Uniqueness, Focusness and Objectness
    % ICCV 2013
    % ----------------------------------------------------------------

    function [ ScaleMap ] = CalScale( Igray )
    
        [minH minW] = size(Igray);
        scale = 1:0.5:16;%list of scale value 1:0.25:16
        ScaleMap=zeros(minH,minW);
        gradp=zeros(minH,minW);
        graddp=zeros(minH,minW);       
        
        for s=1:length(scale)

            sigma = scale(s);
            w = 2*sigma;  % 4
            x=-w:1:w; %filter window width

            s1sq = sigma.^2;
            smoothfilter = (1./(sqrt(2*pi)*sigma)) .* exp(-(x.^2 )./(2*s1sq));
            differfilter = (-x./(sqrt(2*pi)*sigma)) .* exp(-(x.^2 )./(2*s1sq));
            smoothfilter = smoothfilter/sum(smoothfilter);
            differfilter = differfilter/sum(abs(differfilter));

            %compute DOG responses along the x and y directions respectively.       
            smoothIx=filter2(smoothfilter,Igray,'valid');
            smoothIx=padarray(smoothIx,[0 w],'replicate','both');
            gradIy=filter2(differfilter',smoothIx,'valid');
            gradIy=padarray(gradIy,[w 0],'replicate','both');
             
            smoothIy=filter2(smoothfilter',Igray,'valid');
            smoothIy=padarray(smoothIy,[w 0],'replicate','both');
            gradIx=filter2(differfilter,smoothIy,'valid');
            gradIx=padarray(gradIx,[0 w],'replicate','both');      

            gradI=(gradIx.^2+gradIy.^2).^0.5;

            gradd=gradI-gradp;
            gradd(gradd<0)=0;
                               
            gradp=gradI;  
                  
            if s>2
               ScaleMap(gradd>graddp)=sigma;
            end

            graddp=gradd;
            
        end

        ScaleMap(ScaleMap==0)=max(scale);
        ScaleMap=0.5*2^0.5*ScaleMap;
          
        ScaleMap(1,:)=-0.2;
        ScaleMap(minH,:)=-0.2;
        ScaleMap(:,1)=-0.2;
        ScaleMap(:,minW)=-0.2;

    end
