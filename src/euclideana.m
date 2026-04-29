%Calcula la distancia euclideana al cuadrado exhaustiva entre 2 conjuntos
%de vectores.
%Entradas
% X - Reales[N_x x M]; Conjunto de N_x vectores de tamaño M.
% Y - Reales[N_y x M]; Conjunto de N_y vectores de tamaño M.
%Si se le agrega la cadena "1v1", calcula solo la distancias
% entre d(X_i,Y_i) i.e. fila por fila.
%Salidas
% dist - Reales [N_x x N_y]; Donde dist(i,j) = dist_euclideana(X_i,Y_j)
function dist = euclideana(X,Y,varargin)
    if size(X,2) ~= size(Y,2)
        error("Los vectores a comparar deben tener el mismo tamaño")
    end
     %Usando la distancia euclideana al cuadrado:
     %dist(x_i, y_j) = ||x_i - y_j||^2
     %Expandiendo por producto punto:
     %||x_i - y_j||^2 = x_i . x_i - 2(x_i . y_j) 
     % + y_j . y_j
     %||x_i||^2 + ||y_j||.^2 -2(x_i . y_j)
    sqrNormX = sum(X.^2,2);
    sqrNormY = sum(Y.^2,2);
    if ~isempty(varargin{1}) && (string(varargin{1}) == "1v1")
        if size(X,1) ~= size(Y,1)
            error("La longitud de los conjuntos no es igual, no se " + ...
                  "pueden calcular distancias 1vs1")
        end
        dist = sqrNormX + sqrNormY - 2.*dot(X,Y,2);
    else
     %Transponer Y crea una matriz de [N_x x N_y]
    dist = sqrNormX + sqrNormY' - 2.*(X * Y');
    end
end