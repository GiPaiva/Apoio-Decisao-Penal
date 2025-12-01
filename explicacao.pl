% ============================================
% DESCRICAO_TIPO
% ============================================
% Traduz tipo penal para texto legível

descricao_tipo(furto, 'furto simples').
descricao_tipo(furto_qualificado(Q), Texto) :-
    format(atom(Texto), 'furto qualificado (~w)', [Q]).
descricao_tipo(roubo, 'roubo').

% ============================================
% EXPLICACAO
% ============================================
% Gera lista de mensagens explicativas

explicacao(Caso, Mensagens) :-
    classificacao_juridica(Caso, Tipo),
    descricao_tipo(Tipo, TextoTipo),
    format(atom(M1), 'Classificacao do fato: ~w', [TextoTipo]),
    decisao_preliminar(Caso, Resultado, _),
    explicacoes_por_decisao(Caso, Resultado, MsDec),
    Mensagens = [M1 | MsDec].

% ============================================
% EXPLICACOES_POR_DECISAO
% ============================================
% Gera mensagens específicas por tipo de decisão

% Para absolvição por insignificância
explicacoes_por_decisao(Caso, absolver_por_insignificancia, Mensagens) :-
    fatos_caso(Caso, valor_bem(V)),
    limite_irrisorio(Lim),
    format(atom(M2),
           'Valor irrisorio (R$~w < 10%% do salario minimo ~2f)',
           [V, Lim]),
    (fatos_caso(Caso, violencia(nao)) ->
        M3 = 'Ausencia de violencia ou grave ameaca'
    ;   
        M3 = 'Violencia presente (nao ha insignificancia)'
    ),
    (fatos_caso(Caso, primario(sim)) ->
        M4 = 'Reu primario e nao reincidente'
    ;   
        M4 = 'Reu com antecedentes/reincidencia'
    ),
    M5 = 'Decisao: absolvicao pelo principio da insignificancia',
    Mensagens = [M2, M3, M4, M5].

% Para redução por privilégio
explicacoes_por_decisao(Caso, reduzir_pena_por_privilegio, Mensagens) :-
    classificacao_juridica(Caso, Tipo),
    pena_base(Tipo, Base),
    dosimetria(Caso, PenaFinal),
    format(atom(M2), 'Pena-base fixada em ~2f meses', [Base]),
    format(atom(M3), 'Pena final apos reducoes: ~2f meses', [PenaFinal]),
    M4 = 'Furto privilegiado: primariedade, pequeno valor e ausencia de violencia',
    Mensagens = [M2, M3, M4].

% Para dosimetria normal
explicacoes_por_decisao(Caso, dosimetria(PenaFinal), Mensagens) :-
    classificacao_juridica(Caso, Tipo),
    pena_base(Tipo, Base),
    format(atom(M2), 'Pena-base fixada em ~2f meses', [Base]),
    format(atom(M3), 'Pena final apos atenuantes/agravantes: ~2f meses', [PenaFinal]),
    Mensagens = [M2, M3].

% ============================================
% EXPLICACAO_COMPLETA
% ============================================
% Gera explicação completa formatada

explicacao_completa(Caso, Texto) :-
    explicacao(Caso, Mensagens),
    atomic_list_concat(Mensagens, '\n  - ', TextoTemp),
    format(atom(Texto), 'EXPLICAÇÃO DO CASO ~w:\n  - ~w', [Caso, TextoTemp]).

% ============================================
% MENSAGEM_EXPLICATIVA
% ============================================
% Mensagens individuais (para compatibilidade)

mensagem_explicativa(Caso, Msg) :-
    explicacao(Caso, Mensagens),
    member(Msg, Mensagens).

% ============================================
% TRADUTORES
% ============================================

% Traduz tipos de crime
traduz_tipo(Tipo, Texto) :- descricao_tipo(Tipo, Texto).

% Traduz qualificadoras
traduz_qualificadora(rompimento_obstaculo, 'rompimento de obstáculo (arrombamento)').
traduz_qualificadora(escalada, 'escalada (subir muro/janela)').
traduz_qualificadora(chave_falsa, 'uso de chave falsa').
traduz_qualificadora(concurso_pessoas, 'concurso de pessoas (mais de um autor)').
traduz_qualificadora(arma, 'uso de arma').

% Traduz decisões
traduz_decisao(absolver_por_insignificancia, 'ABSOLVER por insignificância').
traduz_decisao(reduzir_pena_por_privilegio, 'REDUZIR PENA por furto privilegiado').
traduz_decisao(dosimetria(Pena), Msg) :-
    PenaInt is round(Pena),
    Anos is PenaInt // 12,
    Meses is PenaInt mod 12,
    format(atom(Msg), 'CONDENAR à pena de ~w anos e ~w meses', [Anos, Meses]).

% ============================================
% POR_QUE_NAO
% ============================================
% Explica por que uma regra NÃO se aplicou

por_que_nao(Caso, insignificancia, Motivo) :-
    \+ regra_insignificancia(Caso),
    (
        \+ valor_irrisorio(Caso) ->
            Motivo = 'Valor não é irrisório (> 10% SM)'
        ;
        fatos_caso(Caso, violencia(sim)) ->
            Motivo = 'Houve violência'
        ;
        tem_qualificadora(Caso, _) ->
            Motivo = 'Crime tem qualificadora'
        ;
        excecao_insignificancia(Caso) ->
            Motivo = 'Exceção aplicável (reincidência)'
        ;
            Motivo = 'Motivo não identificado'
    ).

por_que_nao(Caso, furto_privilegiado, Motivo) :-
    \+ regra_furto_privilegiado(Caso),
    (
        \+ caso(Caso, furto) ->
            Motivo = 'Não é furto'
        ;
        fatos_caso(Caso, primario(nao)) ->
            Motivo = 'Réu não é primário'
        ;
        \+ pequeno_valor(Caso) ->
            Motivo = 'Valor não é pequeno'
        ;
        fatos_caso(Caso, violencia(sim)) ->
            Motivo = 'Houve violência'
        ;
            Motivo = 'Motivo não identificado'
    ).