clear;close all;clc;
%Tamaño y espaciado de ventanas
N = 160; M = 64;
%Umbral de inicio y final
INF         = .0000017;
SUP         = .00000001;

%Carga el modelo (los cuantizadores vectoriales etiquetados)
load codebooks.mat; %quantizer
Y_label = 1:10; %quantizer
ord = 12;

%Carga las muestras de validación
validacion = dir(".\voz_grabaciones\prueba\*.wav");
featExt = extraccionCaracteristicas(N,M,INF,SUP,ord);
pred = cell(length(dir),2);

%Predice una por una las muestras
    for i = 1:length(validacion)
        x = audioread(validacion(i).folder + "\" + validacion(i).name);
        %Extracción de características
        coef = featExt.extraer(x);
        %Por cada bloque
        dist = zeros(length(codebooks),1);
        for j = 1:size(coef,1)
            %Calcula la distancia a los centroides de entrenamiento
            for k = 1:length(codebooks)
                dist(k) = dist(k) + min( ...
                    featExt.itakuraSaito(coef(j,:),codebooks{k},ord), ...
                    [], "all");
            end
        end
        %La predicción es la palabra con menor distancia total
        [~, indx] = min(dist,[],"all");
        label = Y_label(indx);
        pred{i,1} = validacion(i).name;
        %Etiqueta verdadera
        trueLabel = validacion(i).name(8:9);
        if trueLabel(end) == '_'
            trueLabel = trueLabel(1);
        end
        pred{i,2} = str2num(trueLabel);
        %Etiqueta predicción
        pred{i,3} = label;
    end

cm = confusionmat([pred{:,2}], [pred{:,3}]);
confusionchart(cm)
