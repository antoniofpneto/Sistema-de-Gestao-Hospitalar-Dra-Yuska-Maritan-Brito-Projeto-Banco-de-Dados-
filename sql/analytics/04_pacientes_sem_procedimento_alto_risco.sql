-- =========================================================================
-- 4.4 PACIENTES SEM PROCEDIMENTO DE ALTO RISCO
--     (Utiliza subconsulta para encontrar quem já fez risco ALTO e
--      exclui esses pacientes da lista principal com NOT IN)
-- =========================================================================
SELECT 
    p.nome           AS nome_paciente,
    pac.num_convenio AS convenio
FROM PESSOA p
JOIN PACIENTE pac 
    ON p.id_pessoa = pac.id_pessoa
WHERE pac.id_pessoa NOT IN (
    -- Subconsulta: Retorna os IDs dos pacientes que JÁ fizeram procedimento ALTO
    SELECT a.id_paciente
    FROM ATENDIMENTO a
    JOIN PROCEDIMENTO_REALIZADO pr 
        ON a.id_atendimento = pr.id_atendimento
    JOIN PROCEDIMENTO proc 
        ON pr.id_procedimento = proc.id_procedimento
    WHERE proc.nivel_risco = 'ALTO'
)
ORDER BY 
    p.nome ASC;