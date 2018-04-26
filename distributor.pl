main:-
    getQuantities(Pieces),

    write('-------------------------------\n'),
    write('input exemple : \n200.\n\t=> 2euros\nCombien devez vous payer (centimes) ?\n'),
    read(AmountDue),
    write('-------------------------------\n'),

    write('Vous devez payer : '),
    write(AmountDue),
    write('cent\ninput exemple : \n[0,1,1,0,0,0]. \n\t=> 1euro 50cent\nCombien de pieces avez vous rentrez ?\n'),
    read(PEntered),
    write('-------------------------------\n'),
    convertIntoCent([200, 100, 50, 20, 10, 5], PEntered, AmountEntered),
    AmountEntered >= AmountDue,
    
    calculate(  AmountEntered, 
                AmountDue, 
                [200, 100, 50, 20, 10, 5],
                Pieces, 
                Solution),

    write('La machine vous rend :\n'),
    write(Solution),
    write('\n-------------------------------\n'),             

    updatePieces(Pieces, PEntered, Solution, Lr),
    updateQuantities(Lr).

getQuantities([P_200_centimes, P_100_centimes, P_50_centimes, P_20_centimes, P_10_centimes, P_5_centimes]) :-
    open('quantities.txt',read,In),
    read(In, P_200_centimes),
    read(In, P_100_centimes),
    read(In, P_50_centimes),
    read(In, P_20_centimes),
    read(In, P_10_centimes),
    read(In, P_5_centimes),
    close(In).

updateQuantities([P200, P100, P50, P20, P10, P5 |_]) :-
    open('quantities.txt',write,Out),
    writeFormatedData(Out, P200),
    writeFormatedData(Out, P100),
    writeFormatedData(Out, P50),
    writeFormatedData(Out, P20),
    writeFormatedData(Out, P10),
    writeFormatedData(Out, P5),
    close(Out).

updatePieces([], [], [], []).
updatePieces([I|L1], [E|L2], [R|L3], [S|L4]) :-
    S is I+E-R,
    updatePieces(L1, L2, L3, L4).

convertIntoCent([], [], 0).
convertIntoCent([Val|L1], [PE|L2], Amount) :-
    convertIntoCent(L1, L2, Rest),
    Amount is Val*PE + Rest.

writeFormatedData(Out, Data) :-
    write(Out, Data),
    write(Out, '.\n').

calculate(Gave, Due, LVal, LP, LS) :-
    domaines(LP, LS, LTmp),
    piecesValue(LVal, LS, Cons, Score),
    Cons #= (Gave-Due),
    NbPieces #= Score,
    fd_minimize(fd_labeling(LTmp), NbPieces).

domaines([],[],[]).
domaines([P|L1], [X|L2], [X|L3]) :-
    fd_domain(X,0,P),
    domaines(L1,L2,L3).

piecesValue([Val], [X], Val*X, X).
piecesValue([Val|LVal], [X|L], Val*X + Cons, X+Score) :- piecesValue(LVal, L, Cons, Score).