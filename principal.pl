% ============================================
% SISTEMA DE APOIO À DECISÃO PENAL
% ============================================
:- consult('entrada.txt').
:- consult('precedentes.pl').
:- consult('regras.pl').
:- consult('dosimetria.pl').
:- consult('decisao.pl').
:- consult('explicacao.pl').

main :-
    writeln('=== SISTEMA DE APOIO À DECISÃO PENAL ==='),
    writeln(''),
    open('saida.txt', write, Arquivo),
    write(Arquivo, '=== SISTEMA DE APOIO À DECISÃO PENAL ===\n\n'),

    % Processa cada caso
    findall(C, caso(C, _), Casos),
    processa_todos_casos(Casos, Arquivo),

    % Gera resumo
    gera_resumo(Arquivo),

    close(Arquivo),
    writeln(''),
    writeln('Análise completa! Veja o arquivo saida.txt').

% ============================================
% PROCESSAR CASOS
% ============================================
% Pega cada caso e manda processar

processa_todos_casos([], _).
processa_todos_casos([Caso|Resto], Arquivo) :-
    processa_um_caso(Caso, Arquivo),
    processa_todos_casos(Resto, Arquivo).

% ============================================
% PROCESSAR UM CASO
% ============================================
% Analisa um caso e escreve no arquivo

processa_um_caso(Caso, Arquivo) :-
    format(Arquivo, '=== CASO ~w ===~n', [Caso]),
    format('=== CASO ~w ===~n', [Caso]),

    % Classificação do crime
    classificacao_juridica(Caso, Tipo),
    format(Arquivo, 'Classificação: ~w~n', [Tipo]),
    format('Classificação: ~w~n', [Tipo]),

    % Mostra fatos importantes
    mostra_fatos_importantes(Caso, Arquivo),

    % Lista precedentes aplicáveis
    format(Arquivo, '~nPRECEDENTES APLICÁVEIS:~n', []),
    format('~nPRECEDENTES APLICÁVEIS:~n', []),
    lista_precedentes(Caso, Arquivo),

    % Decisão preliminar
    format(Arquivo, '~nDECISÃO: ', []),
    format('~nDECISÃO: ', []),
    decisao_preliminar(Caso, Decisao, Fundamentos),
    mostra_decisao(Decisao, Arquivo),

    % Fundamentos
    format(Arquivo, 'FUNDAMENTOS:~n', []),
    format('FUNDAMENTOS:~n', []),
    mostra_fundamentos(Fundamentos, Arquivo),

    format(Arquivo, '~n', []),
    format('~n', []).

% ============================================
% MOSTRAR FATOS IMPORTANTES
% ============================================
% Mostra valor, violência, se é primário, etc

mostra_fatos_importantes(Caso, Arquivo) :-
    (fatos_caso(Caso, valor_bem(V)) ->
        format(Arquivo, 'Valor do bem: R$ ~w~n', [V]),
        format('Valor do bem: R$ ~w~n', [V])
    ; true),

    (fatos_caso(Caso, violencia(Viol)) ->
        format(Arquivo, 'Violência: ~w~n', [Viol]),
        format('Violência: ~w~n', [Viol])
    ; true),

    (fatos_caso(Caso, primario(Prim)) ->
        format(Arquivo, 'Primário: ~w~n', [Prim]),
        format('Primário: ~w~n', [Prim])
    ; true),

    (fatos_caso(Caso, reincidente(Rein)) ->
        format(Arquivo, 'Reincidente: ~w~n', [Rein]),
        format('Reincidente: ~w~n', [Rein])
    ; true),

    (fatos_caso(Caso, qualificadora(Qual)) ->
        format(Arquivo, 'Qualificadora: ~w~n', [Qual]),
        format('Qualificadora: ~w~n', [Qual])
    ; true).

% ============================================
% LISTAR PRECEDENTES
% ============================================
% Lista todos os precedentes que se aplicam ao caso

lista_precedentes(Caso, Arquivo) :-
    findall(
        prec(Trib, Tema, Tese),
        aplica_precedente(Caso, Tema, Trib, Tese),
        Precedentes
    ),
    (Precedentes = [] ->
        format(Arquivo, '  Nenhum precedente específico~n', []),
        format('  Nenhum precedente específico~n', [])
    ;
        mostra_lista_precedentes(Precedentes, Arquivo)
    ).

mostra_lista_precedentes([], _).
mostra_lista_precedentes([prec(Trib, _Tema, Tese)|Resto], Arquivo) :-
    atom_string(Trib, TribStr),
    upcase_atom(TribStr, TribUpper),
    format(Arquivo, '  [~w] ~w~n', [TribUpper, Tese]),
    format('  [~w] ~w~n', [TribUpper, Tese]),
    mostra_lista_precedentes(Resto, Arquivo).

% ============================================
% MOSTRAR DECISÃO
% ============================================
% Mostra o tipo de decisão tomada

mostra_decisao(absolver_por_insignificancia, Arquivo) :-
    format(Arquivo, 'ABSOLVER POR INSIGNIFICÂNCIA~n', []),
    format('ABSOLVER POR INSIGNIFICÂNCIA~n', []).

mostra_decisao(reduzir_pena_por_privilegio, Arquivo) :-
    format(Arquivo, 'REDUZIR PENA POR PRIVILÉGIO~n', []),
    format('REDUZIR PENA POR PRIVILÉGIO~n', []).

mostra_decisao(dosimetria(Pena), Arquivo) :-
    PenaInt is round(Pena),
    format(Arquivo, 'DOSIMETRIA (pena: ~w pontos)~n', [PenaInt]),
    format('DOSIMETRIA (pena: ~w pontos)~n', [PenaInt]).

% ============================================
% MOSTRAR FUNDAMENTOS
% ============================================
% Lista os fundamentos da decisão

mostra_fundamentos([], _).
mostra_fundamentos([F|Resto], Arquivo) :-
    format(Arquivo, '  - ~w~n', [F]),
    format('  - ~w~n', [F]),
    mostra_fundamentos(Resto, Arquivo).

% ============================================
% RESUMO
% ============================================
% Conta quantas decisões de cada tipo

gera_resumo(Arquivo) :-
    format(Arquivo, '~n=== RESUMO ===~n', []),
    format('~n=== RESUMO ===~n', []),

    % Total de casos
    findall(C, caso(C, _), Casos),
    length(Casos, Total),
    format(Arquivo, 'Total de casos: ~w~n', [Total]),
    format('Total de casos: ~w~n', [Total]),

    % Absolvições
    findall(C, decisao_preliminar(C, absolver_por_insignificancia, _), Absolv),
    length(Absolv, NumAbsolv),
    format(Arquivo, 'Absolvições: ~w~n', [NumAbsolv]),
    format('Absolvições: ~w~n', [NumAbsolv]),

    % Reduções
    findall(C, decisao_preliminar(C, reduzir_pena_por_privilegio, _), Reduc),
    length(Reduc, NumReduc),
    format(Arquivo, 'Reduções: ~w~n', [NumReduc]),
    format('Reduções: ~w~n', [NumReduc]),

    % Dosimetrias
    findall(C, (decisao_preliminar(C, D, _), D = dosimetria(_)), Dosim),
    length(Dosim, NumDosim),
    format(Arquivo, 'Dosimetria: ~w~n', [NumDosim]),
    format('Dosimetria: ~w~n', [NumDosim]).

% ============================================
% FUNÇÕES AUXILIARES
% ============================================
upcase_atom(Atom, Upper) :-
    atom_codes(Atom, Codes),
    maplist(to_upper, Codes, UpperCodes),
    atom_codes(Upper, UpperCodes).

to_upper(Lower, Upper) :-
    Lower >= 97, Lower =< 122, !,
    Upper is Lower - 32.
to_upper(Code, Code).

% ============================================
% INICIALIZAÇÃO
% ============================================
% Roda automaticamente quando carrega o arquivo
:- initialization(main).
