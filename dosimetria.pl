% ============================================
% PENA_BASE
% ============================================
% Pena inicial de cada tipo de crime (em meses)

pena_base(furto, 24).
pena_base(furto_qualificado(_), 36).
pena_base(roubo, 48).

% ============================================
% APLICA_REDUCAO
% ============================================
% Reduz a pena por um percentual
% PenaFinal = PenaInicial * (1 - Percentual)

aplica_reducao(PenaInicial, Percentual, PenaFinal) :-
    PenaFinal is PenaInicial * (1.0 - Percentual).

% ============================================
% ACUMULA_REDUCOES
% ============================================
% Aplica várias reduções uma depois da outra

% Caso base: sem mais reduções
acumula_reducoes(Pena, [], Pena).

% Caso recursivo: aplica uma redução e continua
acumula_reducoes(PenaInicial, [R|Rs], PenaFinal) :-
    aplica_reducao(PenaInicial, R, P1),
    acumula_reducoes(P1, Rs, PenaFinal).

% ============================================
% PERCENTUAL_CAUSA
% ============================================
% Converte causas em percentuais de redução

percentual_causa(confissao_espontanea, 0.33).
percentual_causa(devolucao_bem, 0.25).
percentual_causa(furto_privilegiado, 0.50).

% ============================================
% DOSIMETRIA
% ============================================
% Calcula a pena final do caso

dosimetria(Caso, PenaFinal) :-
    classificacao_juridica(Caso, Tipo),
    pena_base(Tipo, Base),
    causas_caso(Caso, Causas),
    findall(P,
            (member(C, Causas),
             percentual_causa(C, P)),
            ListaReducoes),
    acumula_reducoes(Base, ListaReducoes, PenaFinal).

% ============================================
% CALCULA_PENA_FINAL
% ============================================
% Alias para dosimetria (compatibilidade)

calcula_pena_final(Caso, PenaFinal) :-
    dosimetria(Caso, PenaFinal).