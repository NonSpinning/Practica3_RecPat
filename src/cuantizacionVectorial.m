%No necesito una clase en sí, 
% la uso para agrupar los métodos de cuantización vectorial.
classdef cuantizacionVectorial
    methods (Static)
        %Algoritmo de Lind-Buzo-Gray, con epsilon fija y aleatoria.
        %Entradas:
        % X - Reales[NxM]; Conjunto de N vectores de tamaño M a cuantizar.
        % k - Entero; Número máximo de regiones para la cuantización.
        % u - Real; Umbral de cambio (porcentaje) aceptable para detener etapa.
        % maxIter - Entero; Número máximo de iteraciones por etapa.
        % tipoDist - {"euclideana","itakura-saito"}; tipo de distancia a usar
        % para calcular regiones y distancia global.
        % EPSILON - Reales[1xM]; Perturbación que se aplica a los centroides, 
        %                  si es vacío se calculan al azar.
        %Salidas:
        % GAMMA - Reales[(2^i)xM] Codebook de 2^i <= k vectores código.
        % distGlobal - Real; Suma de la distancia entre cada vector y 
        % su código más cercano.
        function [GAMMA, distGlobal] = LBG(X, k, u, maxIter, tipoDist, EPSILON)
             %Tamaño de los vectores
             M = size(X,2);
             %2^i <= k --> i <= log_2(k)
             tamCodeBook = 2 .^ floor(log2(k));
             GAMMA = zeros(tamCodeBook,M);
             GAMMA(1,:) = mean(X,1);
             k_actual = 1;
    
             while k_actual < k
                %Duplica codebook con la perturbación.
                if ~exist('EPSILON','var') || isempty(EPSILON)
                    % rand/10 [0,.1] para hacer menos probable que los 
                    % centroides se salgan del área que contiene los
                    % puntos.
                    EPSILON = rand(1,M) ./ 10;   
                end
                temp = GAMMA(1:k_actual,:);
                GAMMA(1:k_actual,:) = temp + EPSILON;
                GAMMA((k_actual+1):(2*k_actual),:) = temp - EPSILON;
                k_actual = 2 * k_actual;
                
                [GAMMA(1:k_actual,:), distGlobal] = cuantizacionVectorial.lloyd(...
                X,GAMMA(1:k_actual,:),k_actual, u,maxIter,tipoDist);
             end
             if k == 1
               [~,distGlobal] = cuantizacionVectorial.calcRegiones( ...
                        X,GAMMA,1,tipoDist);
            end
        end

        %K-Medias, con codebook inicial aleatorio y k-medias++.
        %El algoritmo para k-medias++ lo saque de los docs de MATLAB
        %(función kmeans)
        %Entradas:
        % X - Reales[NxM]; Conjunto de N vectores de tamaño M a cuantizar.
        % k - Entero; Número de regiones para la cuantización.
        % u - Real; Umbral de cambio (porcentaje) aceptable para detener etapa.
        % maxIter - Entero; Número máximo de iteraciones por etapa.
        % tipoDist - {"euclideana","itakura-saito"}; tipo de distancia a usar
        % para calcular regiones y distancia global.
        % masmas - Booleano, true -> usa el método de Arthur &
        % Vassilvitskii para el codebook inicial, false -> toma vectores al
        % azar.
        %Salidas:
        % GAMMA - Reales[kxM] Codebook de k vectores código.
        % distGlobal - Real; Suma de la distancia entre cada vector y 
        % su código más cercano.
        function [GAMMA, distGlobal] = KMedias( ...
                X, k, u, maxIter, tipoDist, masmas)
            [N, M] = size(X);
            GAMMA = zeros(k,M);
            if masmas
                random = round((N - 1) .* rand(1,1));
                GAMMA(1,:) = X(random,:);
                for i = 2:k
                    %Calcula la distancia al centroide más cercano
                    [regiones, distGlobal] = cuantizacionVectorial.calcRegiones( ...
                        X,GAMMA,i-1,tipoDist);
                    %las distancias calculan todos los pares, y yo solo
                    %quiero 1-a-1, tengo que iterar.

                    dist = cuantizacionVectorial.calcDistancia( ...
                        X,GAMMA(regiones,:),tipoDist,"1v1");
                    %la probabilidad de elegir un vector es su distancia
                    %normalizada.
                    dist = dist ./ distGlobal;
                    %funcion de densidad acumulada
                    dist = cumsum(dist);
                    %elige basado en las probabilidades
                    GAMMA(i,:) = X(find(rand(1,1) < dist,1),:);
                end
            else 
                %elige uniformemente al azar
                randindx = sort(randperm(N));
                GAMMA = X(randindx(1:k),:);
            end
            [GAMMA, distGlobal] = cuantizacionVectorial.lloyd(...
                X,GAMMA,k, u,maxIter,tipoDist);
        end

        %Grafica las regiones generadas en X a partir del codebook GAMMA y
        %el tipo de distancia tipoDist.
        function grafRegiones(X, GAMMA, tipoDist)
            k = size(GAMMA,1);
            regiones = cuantizacionVectorial.calcRegiones( ...
                X,GAMMA,k,tipoDist);
            if k <= 16
            comap = bone(k);
            else
            comap = lines(k);
            end
            hold on;
            scatter(X(:,1),X(:,2),4,comap(regiones,:),".",'MarkerEdgeAlpha',.5);
            scatter(GAMMA(:,1),GAMMA(:,2),24,'k',"o","filled");
            hold off;
        end
        
        %Funciones Auxiliares
        %==================================================================
        %Algoritmo de LLoyd (K-means sin inicialización para reutilizarlo
        %en LBG)
        function [GAMMA, distGlobal] = lloyd(X,GAMMA,k,u,maxIter,tipoDist)
        %Itera hasta que se estabilize o exceda el máximo de
        %iteraciones
            [regiones, distGlobPast] = ...
            cuantizacionVectorial.calcRegiones(X,GAMMA,k,tipoDist);
                iter = 0;
                while iter < maxIter
                    GAMMA = cuantizacionVectorial.calcCentroides(X,regiones,k);
                    [regiones, distGlobAct] = ...
                        cuantizacionVectorial.calcRegiones(X,GAMMA,k,tipoDist);
                    %Para si la distancia actual cambio u% o menos al
                    %compararla con la distancia pasada.
                    if abs(1 - (distGlobAct/distGlobPast)) <= u  
                        break;
                    end
                    %Si no terminé me preparo para la siguiente iteración
                    iter = iter + 1;
                    distGlobPast = distGlobAct;
                end
            if k == 1
               [~,distGlobAct] = cuantizacionVectorial.calcRegiones( ...
                        X,GAMMA,1,tipoDist);
            end
                 distGlobal = distGlobAct;
        end
                 
        %Dado un conjunto de vectores y un codebook, devuelve el indice del
        %centroide más cercano a cada vector
        %Entradas:
        % X - Reales[NxM]; Conjunto de N vectores de tamaño M.
        % GAMMA - Reales[LxM]; Codebook de tamaño L con entradas vacias y k
        % entradas utiles.
        % k - Entero; Tamaño real del codebook.
        % tipoDist - {"euclideana","itakura-saito"}; Tipo de distancia a
        % usar para comparar los vectores
        %Salidas:
        % regiones - Enteros[Nx1] indice del código de vector más cercano a
        % cada uno de los vectores
        % distGlobal - Suma Suma de la distancia entre cada vector y 
        % su código más cercano.
        function [regiones, distGlobal] = calcRegiones(X,GAMMA,k,tipoDist)
            dist = cuantizacionVectorial.calcDistancia(X,GAMMA(1:k,:),tipoDist);
            [minDist, regiones] = min(dist,[],2);
            distGlobal = sum(minDist,"all");
        end
        
        %Dado un conjunto de vectores separados en k regiones, calcula los
        %nuevos centroides promedio
        %Entradas:
        % X - Reales[NxM]; Conjunto de N vectores de tamaño M.
        % regiones - Enteros[Nx1]; Etiquetas que marcan a que region
        % pertenece cada vector de X.
        % k - Entero; número de regiones;
        function GAMMA = calcCentroides(X, regiones, k)
            vecLength = size(X,2);
            %cuenta el número de vectores en cada región
            counts = accumarray(regiones, 1,[k 1]);
            %para evitar division por 0
            counts(counts == 0) = 1;
            %accumarray suma vectores columna, itero sobre cada elemento;
            %El vector conformado por el promedio de cada elemento es el 
            % vector promedio.
            GAMMA = zeros(k,vecLength);
            for i = 1:vecLength
                GAMMA(:,i) = accumarray(regiones, X(:,i), [k 1]) ./ counts;
            end
        end

        %Para no tener que estar haciendo if's en todas las funciones que
        %pueden variar el tipo de distancia.
        %Calcula la distancia exhaustiva (dist(i,j) = dist(X_i,X_j) de
        %acuerdo al tipo de distancia tipoDist
        function dist = calcDistancia(X,Y,tipoDist,varargin)
            import itakura_saito.*
            import euclideana.*
            if tipoDist == "euclideana"
                dist = euclideana(X,Y,varargin);
            elseif tipoDist == "itakura-saito"
                dist = itakura_saito(X,Y,varargin);
            else
                error("Tipo de distancia no reconocido.")
            end
        end

    end
end