% Permet de lancer le programme (ne nécessite pas de paramètres, le programme interagit avec l'utilisateur via la console)
main:-
    getQuantities(Pieces), % On récupère la quantité de pièces disponible

    % On demande à l'utilisateur quelle somme il doit payer
    write('-------------------------------\n'),
    write('input exemple : \n200.\n\t=> 2euros\nCombien devez vous payer (centimes) ?\n'),
    read(AmountDue),
    write('-------------------------------\n'),
    % -----------------------------------------------------

    % On demande de quelle manière il va payer (combien de pièces de chaque type)
    write('Vous devez payer : '),
    write(AmountDue),
    write('cent\ninput exemple : \n[0,1,1,0,0,0]. \n\t=> 1euro 50cent\nCombien de pieces avez vous rentrez ?\n'),
    read(PEntered),
    write('-------------------------------\n'),
    % -----------------------------------------------------

    convertIntoCent([200, 100, 50, 20, 10, 5], PEntered, AmountEntered), % On convertit la liste en centimes
    AmountEntered >= AmountDue, % On vérifie que l'utilisateur a rentré au moins la somme qu'il doit payer
    
    calculate(  AmountEntered, 
                AmountDue, 
                [200, 100, 50, 20, 10, 5],
                Pieces, 
                Solution), % On effectue le calcul de la monnaie

    % On indique à l'utilisateur combien de pièces de chaque type la machine va lui rendre
    write('La machine vous rend :\n'),
    write(Solution),
    write('\n-------------------------------\n'),  
    % -----------------------------------------------------           

    updatePieces(Pieces, PEntered, Solution, Lr), % On calcule la nouvelle quantité de chaque pièce (dans Lr)
    updateQuantities(Lr). % On met à jours la machine (le fichier quantities.txt)
%------------------------------------------------------------------------------------------------------------------------

% Permet d'obtenir le nombre de pièces disponible pour chaque type de pièce 
% P200 : Nombre de pièces de 200cent (2euros)
% P100 : Nombre de pièces de 100cent (1euro)
% P50 : Nombre de pièces de 50cent
% P20 : Nombre de pièces de 20cent
% P10 : Nombre de pièces de 10cent
% P5 : Nombre de pièces de 5cent
getQuantities([P200, P100, P50, P20, P10, P5]) :-
    open('quantities.txt',read,In),
    read(In, P200),
    read(In, P100),
    read(In, P50),
    read(In, P20),
    read(In, P10),
    read(In, P5),
    close(In).
%------------------------------------------------------------------------------------------------------------------------

% Permet de mettre à jours le nombre de pièces disponible pour chaque type de pièce
% P200 : Nombre de pièces de 200cent (2euros)
% P100 : Nombre de pièces de 100cent (1euro)
% P50 : Nombre de pièces de 50cent
% P20 : Nombre de pièces de 20cent
% P10 : Nombre de pièces de 10cent
% P5 : Nombre de pièces de 5cent
updateQuantities([P200, P100, P50, P20, P10, P5]) :-
    open('quantities.txt',write,Out),
    writeFormatedData(Out, P200),
    writeFormatedData(Out, P100),
    writeFormatedData(Out, P50),
    writeFormatedData(Out, P20),
    writeFormatedData(Out, P10),
    writeFormatedData(Out, P5),
    close(Out).
%------------------------------------------------------------------------------------------------------------------------

% Permet de calculer la nouvelle quantité de chaque type de pièces
% [I|L1] : Liste initiale
% [E|L2] : Liste des pièces insérées par l'utilisateur
% [R|L3] : Liste des pièces rendues par la machine
% [S|L4] : Liste résultat (nouvelle quantité)
updatePieces([], [], [], []).
updatePieces([I|L1], [E|L2], [R|L3], [S|L4]) :-
    S is I+E-R,
    updatePieces(L1, L2, L3, L4).
%------------------------------------------------------------------------------------------------------------------------

% Permet de convertir une liste (de pièces) en un entier en centimes
% [Val|L1] : Valeur en centimes de chaque pièce
% [PE|L2] : Nombre de pièces de ce type
% Amount : Somme, calculée récursivement
convertIntoCent([], [], 0).
convertIntoCent([Val|L1], [PE|L2], Amount) :-
    convertIntoCent(L1, L2, Rest),
    Amount is Val*PE + Rest.
%------------------------------------------------------------------------------------------------------------------------

% Chaque valeur doit être sur une ligne différente et se terminer par un '.'
% Ce paquet permet de mettre en forme une donnée
% Out : Outpur (stream)
% Data : Donnée à mettre en forme
writeFormatedData(Out, Data) :-
    write(Out, Data),
    write(Out, '.\n').
%------------------------------------------------------------------------------------------------------------------------

% Permet de calculer, à l'aide de contraintes, les pièces à rendre
% Gave : Somme donnée par l'utilisateur
% Due : Somme à payer par l'utilisateur
% LVal : Valeur en centimes de chaque pièce
% LP : Nombre de pièces disponible pour chaque type de pièce
% LS : Liste des pièces à rendre à l'utilisateur
calculate(Gave, Due, LVal, LP, LS) :-
    % Définition des domaines
    domaines(LP, LS, LTmp),
    % -----------------------
    % Pose des contraintes
    piecesValue(LVal, LS, Cons, Score),
    Cons #= (Gave-Due),
    NbPieces #= Score,
    % -----------------------
    % Enumération des solutions
    fd_minimize(fd_labeling(LTmp), NbPieces). % On va choisir une unique solution à l'aide de fd_minimize, on prends le CSOP en se basant sur "NbPieces" (on veut rendre le minimum de pièces possible)
    % -----------------------
%------------------------------------------------------------------------------------------------------------------------

% Définit le domaine pour chaque type de pièces
% [P|L1] : Nombre de pièces disponible pour chaque type de pièce
% [X|L2] : Liste des solutions
% [X|L3] : Liste temporaires qui servira pour fd_labeling
domaines([],[],[]).
domaines([P|L1], [X|L2], [X|L3]) :-
    fd_domain(X,0,P), % Pour chaque pièces (solution) on peut rendre de 0 à P pièces (P étant le nombre de pièces restantes de ce type dans la machine)
    domaines(L1,L2,L3).
%------------------------------------------------------------------------------------------------------------------------

% On affecte la valeur aux pièces
% [Val|LVal] : Valeur en centimes de chaque pièce
% [X|L] : Liste des solutions
% Cons : Contrainte, si on l'écrivait comme dans SEND + MORE = MONEY on aurait :
/* [X|L] => [S200, S100, S50, S20, S10, S5]
   [Val|LVal] => [V200, V100, V50, V20, V10, V5]
      S200*V200 
    + S100*V100
    + S50*V50
    + S20*V20
    + S10*V10
    + S5*V5
    #= (Gave-Due)
*/
% Score : on peut associer ça à un fonction de coût qui correspondrait la somme du nombre de pièces, plus la score est faible meilleure est la solution
piecesValue([Val], [X], Val*X, X).
piecesValue([Val|LVal], [X|L], Val*X + Cons, X+Score) :- piecesValue(LVal, L, Cons, Score).
%------------------------------------------------------------------------------------------------------------------------