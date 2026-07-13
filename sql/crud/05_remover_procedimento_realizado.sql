-- =========================================================================
-- 3.5 REMOVER UM PROCEDIMENTO REALIZADO
--     (apenas se ainda não houver faturamento associado)
-- =========================================================================
-- Usamos a flag "faturado" da tabela PROCEDIMENTO_REALIZADO como trava:
-- só é permitido excluir o registro se faturado = FALSE.

DO $$
DECLARE
    v_id_atendimento  INT := 5;
    v_id_procedimento INT := 6;
    v_faturado        BOOLEAN;
BEGIN
    SELECT faturado INTO v_faturado
    FROM PROCEDIMENTO_REALIZADO
    WHERE id_atendimento = v_id_atendimento
      AND id_procedimento = v_id_procedimento;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Procedimento realizado (atendimento %, procedimento %) não encontrado.',
            v_id_atendimento, v_id_procedimento;
    ELSIF v_faturado THEN
        RAISE EXCEPTION 'Não é possível remover: procedimento já faturado (faturado = TRUE).';
    ELSE
        DELETE FROM PROCEDIMENTO_REALIZADO
        WHERE id_atendimento = v_id_atendimento
          AND id_procedimento = v_id_procedimento;

        RAISE NOTICE 'Procedimento realizado removido com sucesso (atendimento %, procedimento %).',
            v_id_atendimento, v_id_procedimento;
    END IF;
END $$;