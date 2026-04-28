%Calcula la distancia de itakura_saito exhaustiva d_is(x,y) entre 2 conjuntos
%de vectores
%Entradas
% X - Reales[N_x x M]; Conjunto de N_x vectores de tamaño M.
% Y - Reales[N_y x M]; Conjunto de N_y vectores de tamaño M.
%Salidas
% dist - Reales [N_x x N_y]; Donde dist(i,j) =
%                            dist_{Itakura_saito}(X_i,Y_j).
function dist = itakura_saito(X,Y)
    
    if size(X,2) ~= size(Y,2)
        error("Los vectores a comparar deben tener el mismo tamaño")
    end
    M = size(X,2);
    
    %uso extraccionCaracteristicas para calcular los vectores de 
    % autoCorre-lación
    import extraccionCaracteristicas.autoCorr;

       %N = M se usa para determinar dónde termina cada vector/bloque.

       %ord = M se usa para determinar el valor máximo de m del
       %vector de auto-correlación [r(0) r(1) ... r(m)], que
       %corresponde al orden del filtro LPC que es igual a M;
       featExt = extraccionCaracteristicas(M, 0, 0, 0, M);
       
       %Calculo vectores de autocorrelación;
       %Re-uso variables para ahorrar espacio
       X = featExt.featAutoCorr(X);
       Y = transpose(featExt.featAutoCorr(Y));

       % Basandóme en la formúla
       % d_is(X_i,Y_j) = r_{X_i}(0).r_{Y_j}(0) 
       %                 + 2 * sum^M_{k=1} [r_{X_i}(k)r_{Y_j}(k)] 
       % Uso multiplicacion de matrices para calcular 2 * sum^M_{k=0} para
       % todos los pares (X_i,Y_j) y luego le resto r_{X_i}(0).r_{Y_j}(0) a
       % cada par.
       dist = 2 .* (X * Y) - (X(:,1) * Y(1,:));
end
