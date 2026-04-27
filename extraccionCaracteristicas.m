classdef extraccionCaracteristicas
    properties
        N {mustBeInteger}
        M {mustBeInteger}
        inf {mustBeNumeric}
        sup {mustBeNumeric}
        ord {mustBeInteger}
    end
    methods (Static)
        %Distancia de Itakura-Saito, dada una matriz de vectores de muestras X y una
        %matriz de vectores fila de modelo Y; regresa una matriz Z(i,j) = dist(X_i,Y_j)
        function dist = itakuraSaito(X, Y, ord)
            %uso featExt para calcular la autocorrelación
            featExt = extraccionCaracteristicas(size(X,2), 0, 0, 0, ord);
            if size(X,2) ~= size(Y,2)
                error("Los vectores a comparar deben tener el mismo tamaño")
            end
            R_X = featExt.autoCorr(X);
            Rt_Y = transpose(featExt.autoCorr(Y));
            dist = 2 .* (R_X * Rt_Y) - (R_X(:,1) * Rt_Y(1,:));
        end
    end
    methods
        %Constructor
        function featExt = extraccionCaracteristicas(N, M, inf, sup, ord)
            featExt.N = N;
            featExt.M = M;
            featExt.inf = inf;
            featExt.sup = sup;
            featExt.ord = ord;
        end

        %Junta toda la extracción de vectores característicos, es decir, dada una
        %señal devuelve los coeficientes de Wiener de los bloques
        %N = tamaño de bloques, M = separación de bloques, [inf, sup] = limites de
        %umbralización, ord = orden del filtro de Wiener.
        function featVec = extraer(featExt, senal)
            senal = featExt.highPass(senal);
            bloques = featExt.hamming(senal);
            bloques = featExt.umbralizacion(bloques);
            vecAutoCorr = featExt.autoCorr(bloques);
            featVec = featExt.Weiner(vecAutoCorr);
        end

        %Filtro paso altas
        function hp = highPass(~,z)
            hp = [z(1); z(2:end) - 0.95 * z(1:end-1)]; 
        end

        %Ventana de Hamming
        function bloques = hamming(featExt, z)
            numMuestras = size(z,1);
            numBloques = 1 + floor((numMuestras - featExt.N) ./ featExt.M);
            bloques = zeros(numBloques, featExt.N);
            for j = 1:numBloques
                w = 0.56 - 0.46 * cos(2 * pi * (0 : (featExt.N - 1))' ...
                    ./ (featExt.N - 1));
                bloques(j,:) = z((featExt.M * (j-1) + 1): ...
                    (featExt.M * (j - 1) + featExt.N)) .* w;
            end
        end

        %Devuelve los bloques dentro de los umbrales (¿.001 y .000008?)
        function bloques = umbralizacion(featExt, bloques)
            pow = sum(bloques .^2, 2)/featExt.N;
            start = find(pow >= featExt.inf);
            if isempty(start)
                error("Nunca se supera el umbral de inicio");
            else 
                start = start(1);
            end
            finish = find(pow <= featExt.sup);
            finish = finish(finish > start);
            if isempty(finish)
                finish = size(bloques,1);
            else
                finish = finish(1);
            end        
            bloques = bloques(start:finish,:);
        end

        %Dada una matriz donde cada fila es el vector de autocorrelacion de un
        %bloque devuelve los coeficientes del filtro de Weiner
        function coef = Weiner(featExt, vecAutoCorr)
            numBloques = size(vecAutoCorr,1);
            coef = zeros(numBloques,featExt.ord);
            for i = 1:numBloques
                r = vecAutoCorr(i,2:(featExt.ord+1));
                R = featExt.matCorr(vecAutoCorr(i,:));
                coef(i,:) = R\r';
            end
        end

        %Genera una matriz donde cada fila es un vector de autocorrelación de orden
        % ord a partir cada uno de los bloques dados como fila de una matriz.
        function vec = autoCorr(featExt, bloques)
            numBloques = size(bloques,1);
            vec = zeros(numBloques,featExt.ord+1);
                for i = 1:numBloques
                    for j = 0:featExt.ord
                        vec(i,j+1) = sum(bloques(i,1:(featExt.N-j)) ...
                            .* bloques(i,(j+1):featExt.N));
                    end
                end
        end

        %A partir de un vector de autocorrelación genera la matriz de
        %autocorrelación de orden n
        function R = matCorr(featExt, vecAutoCorr)
            R = zeros(featExt.ord);
            for i = 1:featExt.ord
                for j = 1:featExt.ord
                    R(i,j) = vecAutoCorr(abs(j - i) + 1);
                end
            end
        end
    end

end