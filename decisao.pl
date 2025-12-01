% ============================================
% FUNDAMENTOS
% ============================================
% Coleta todos os fundamentos relevantes do caso

fundamentos(Caso, ListaFundamentos) :-
    % Precedentes aplicáveis
    findall(precedente(Trib, Tema, Tese),
            aplica_precedente(Caso, Tema, Trib, Tese),
            LPrecedentes),
    
    % Causas de redução
    causas_caso(Caso, Causas),
    
    % Qualificadoras
    findall(qualificadora(Q),
            tem_qualificadora(Caso, Q),
            LQualif),
    
    % Primariedade
    (fatos_caso(Caso, primario(sim)) ->
        LPrim = [primariedade]
    ;   
        LPrim = []
    ),
    
    % Reincidência
    (fatos_caso(Caso, reincidente(sim)) ->
        LReinc = [reincidencia]
    ;   
        LReinc = []
    ),
    
    % Junta tudo
    append(LPrecedentes, Causas, T1),
    append(T1, LQualif, T2),
    append(T2, LPrim, T3),
    append(T3, LReinc, LBruta),
    sort(LBruta, ListaFundamentos).

% ============================================
% DECISAO_PRELIMINAR
% ============================================
% Define o tipo de decisão para o caso
% Ordem de prioridade:
% 1. Insignificância (melhor pro réu)
% 2. Furto privilegiado
% 3. Dosimetria normal

decisao_preliminar(Caso, absolver_por_insignificancia, Fundamentos) :-
    regra_insignificancia(Caso),
    fundamentos(Caso, Fundamentos),
    !.

decisao_preliminar(Caso, reduzir_pena_por_privilegio, Fundamentos) :-
    \+ regra_insignificancia(Caso),
    regra_furto_privilegiado(Caso),
    fundamentos(Caso, Fundamentos),
    !.

decisao_preliminar(Caso, dosimetria(PenaFinal), Fundamentos) :-
    dosimetria(Caso, PenaFinal),
    fundamentos(Caso, Fundamentos).

% ============================================
% FUNDAMENTOS_INSIGNIFICANCIA
% ============================================
% Fundamentos para absolvição (compatibilidade)

fundamentos_insignificancia(Caso, Fundamentos) :-
    fundamentos(Caso, Fundamentos).

% ============================================
% FUNDAMENTOS_PRIVILEGIO
% ============================================
% Fundamentos para privilégio (compatibilidade)

fundamentos_privilegio(Caso, Fundamentos) :-
    fundamentos(Caso, Fundamentos).

% ============================================
% FUNDAMENTOS_DOSIMETRIA
% ============================================
% Fundamentos para dosimetria (compatibilidade)

fundamentos_dosimetria(Caso, Fundamentos) :-
    fundamentos(Caso, Fundamentos).