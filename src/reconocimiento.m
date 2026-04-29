classdef reconocimiento
    properties
        %Hiper-parametros
        % Tamaño de las ventanas
        N int16
        % Separación de las ventanas
        M int16 
        % Umbral de inicio
        INF double
        % Umbral de final
        SUP double 
        % Orden de LPC
        ORD int8
        % tipoDeCuantizador
        tipoCuan string {mustBeMember(tipoCuan, ...
            ["LBGFijo","LBGAleatorio","KMedias","KMedias++"])}
        % porcentaje de paro del algoritmo de cuantización
        U double
        % número máximo de iteraciones del algoritmo de cuantización
        MAXITER int16
        % tamaño codebook
        k single
        %Memoria
        % Objeto de extraccionCaracteristicas
        featEx extraccionCaracteristicas
        % Codebooks
        cb
        % Etiquetas de cada codebook
        tag
    end
    methods
        %Constructor
        function rec = reconocimiento(n,m,inf,sup,ord,tipoCuan,k,u,maxIter)
            import extraccionCaracteristicas.*
            rec.N = n;
            rec.M = m;
            rec.INF = inf;
            rec.SUP = sup;
            rec.tipoCuan = tipoCuan;
            rec.ORD = ord;
            rec.U = u;
            rec.MAXITER = maxIter;
            rec.k = k;
            rec.featEx = extraccionCaracteristicas(n,m,inf,sup,ord);
        end

        %Entrenamiento, a partir del conjunto de señales X
        %  y sus clases correspondientes Y; genera un codebook de k códigos
        %para cada una de las clases, el cuál almacena internamente
        function rec = entrenamiento(rec,X,Y)
             if size(X,1) ~= size(Y,1)
                error("El número de muestras y etiquetas no es igual")
             end
             J = size(X,1);
             Xmat = [];
             for i = 1:J
                %Normalizar audio
                X{i,:} = X{i,:} ./ max(abs(X{i,:}));
                %extracción de características
                A = rec.featEx.extraer(X{i,:});
                A(:,end+1) = Y(i);
                Xmat = [Xmat; A];
             end
             %preparar cuantificador
             f = rec.prepararCuantificador();
             %acumular y cuantificar por clase
             rec.tag = sort(unique(Y));
             Xmat = sortrows(Xmat,rec.ORD+1,"ascend");
             for i = 1:size(rec.tag,1)
                 cuant = f(Xmat((Xmat(:,rec.ORD+1)==i),1:rec.ORD));
                 rec.cb{i} = cuant;
             end
        end

        function [pred, trueLabel] = inferencia(rec, dirVal)
            import itakura_saito.*
            validacion = dir(dirVal+"\*.wav");
            pred = zeros(length(validacion),1);
            for i = 1:length(validacion)
                x = audioread(validacion(i).folder + "\" + validacion(i).name);
                %etiqueta verdadera
                clase = validacion(i).name(8:9);
                if clase(end) == "_"
                    clase = clase(1);
                end
                trueLabel(i) = str2double(clase);
                %Normalizar audio
                x = x ./ max(abs(x));
                %Extracción de características
                coef = rec.featEx.extraer(x);
                %Por cada bloque
                dist = zeros(length(rec.cb),1);
                for j = 1:size(coef,1)
                    %Calcula la distancia a los centroides de entrenamiento
                    for g = 1:length(rec.cb)
                        dist(g) = dist(g) + min( ...
                            itakura_saito(coef(j,:),rec.cb{g},rec.ORD), ...
                            [], "all");
                    end
                end
                %La predicción es la palabra con menor distancia total
                [~, indx] = min(dist,[],"all");
                pred(i) = rec.tag(indx);
            end
        end

        function evaluacion()
        end
        function matrizConf()
        end

        %Función auxiliar para definir método de cuantificación del tipo pedido
        function f = prepararCuantificador(rec)
            import cuantizacionVectorial.*
            switch rec.tipoCuan
                case "LBGFijo"
                    f = @(x) cuantizacionVectorial.LBG(x,rec.k,rec.U, ...
                        rec.MAXITER,"euclideana",repmat(.0001,1,12));
                case "LBGAleatorio"
                    f = @(x) cuantizacionVectorial.LBG(x,rec.k,rec.U, ...
                        rec.MAXITER,"itakura-saito",[]);
                case "KMedias"
                    f = @(x) cuantizacionVectorial.KMedias(x,rec.k,rec.U, ...
                        rec.MAXITER,"itakura-saito",false);
                case "KMedias++"
                    f = @(x) cuantizacionVectorial.KMedias(x,rec.k,rec.U, ...
                        rec.MAXITER,"itakura-saito",true);
                otherwise
                    error("Algoritmo de cuantificación no reconocido")
            end
        end
    end
end






















