function [U,D] = gevd(Cx , Cy)

% U' Cx U = I
% U' Cy U = D
[Ux,Landax] = eig( Cx ) ;
A1 = (Landax)^(-0.5)* Ux' ;

Cy1 = A1 * Cy * A1' ;

[Uy1,Landay1] = eig( Cy1 ) ;

D = Landay1;

U = (Uy1' * A1)' ;
