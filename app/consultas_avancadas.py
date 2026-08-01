# consultas_avancadas.py
"""
Item 5 da Etapa 2 — Consultas avançadas com ORM (Flask-SQLAlchemy), usando a
DSL de queries (join/filter/group_by), sem nenhum SQL cru.

Cada função devolve os objetos já prontos para os templates usarem os
relacionamentos (ex: `atendimento.paciente.pessoa.nome`), exatamente como o
resto do app.py já faz.
"""
from sqlalchemy import case, func

from models import Atendimento, Paciente, Pessoa, Preceptor, Procedimento, ProcedimentoRealizado, Residente, db


# -----------------------------------------------------------------------
# 5.1 — Preceptores que supervisionaram residentes que atenderam pacientes
#       flamenguistas (is_flamengo = TRUE)
# -----------------------------------------------------------------------
def preceptores_de_atendimentos_a_flamenguistas():
    """Lista (sem repetição) os Preceptor que aparecem em pelo menos um
    Atendimento cujo paciente tem is_flamengo = True."""
    return (
        db.session.query(Preceptor)
        .join(Preceptor.atendimentos)
        .join(Atendimento.paciente)
        .join(Paciente.pessoa)
        .filter(Pessoa.is_flamengo.is_(True))
        .distinct()
        .all()
    )


# -----------------------------------------------------------------------
# 5.2 — Para cada paciente, o último atendimento (data_hora, residente,
#       preceptor, lista de procedimentos)
# -----------------------------------------------------------------------
def ultimo_atendimento_por_paciente():
    """Para cada paciente que já teve pelo menos um atendimento, devolve o
    objeto Atendimento correspondente à data_hora mais recente dele."""
    ultima_data = (
        db.session.query(
            Atendimento.id_paciente,
            func.max(Atendimento.data_hora).label("max_data_hora"),
        )
        .group_by(Atendimento.id_paciente)
        .subquery()
    )

    return (
        db.session.query(Atendimento)
        .join(
            ultima_data,
            (Atendimento.id_paciente == ultima_data.c.id_paciente)
            & (Atendimento.data_hora == ultima_data.c.max_data_hora),
        )
        .order_by(Atendimento.id_paciente)
        .all()
    )


# -----------------------------------------------------------------------
# 5.3 — Percentual de procedimentos de alto risco realizados por cada
#       residente
# -----------------------------------------------------------------------
def percentual_alto_risco_por_residente():
    """Devolve uma lista de dicionários:
    {nome, ano_residencia, total_procedimentos, total_alto_risco, percentual}
    """
    total_alto = func.sum(case((Procedimento.nivel_risco == "ALTO", 1), else_=0))
    total_geral = func.count(ProcedimentoRealizado.id_procedimento)

    linhas = (
        db.session.query(Residente, total_geral.label("total"), total_alto.label("total_alto"))
        .join(Atendimento, Atendimento.id_residente == Residente.id_profissional)
        .join(ProcedimentoRealizado, ProcedimentoRealizado.id_atendimento == Atendimento.id_atendimento)
        .join(Procedimento, Procedimento.id_procedimento == ProcedimentoRealizado.id_procedimento)
        .group_by(Residente.id_profissional)
        .order_by(total_alto.desc())
        .all()
    )

    resultado = []
    for residente, total, total_alto_valor in linhas:
        total_alto_valor = total_alto_valor or 0
        percentual = round((total_alto_valor / total) * 100, 2) if total else 0.0
        resultado.append(
            {
                "residente": residente,
                "nome": residente.pessoa.nome,
                "ano_residencia": residente.ano_residencia,
                "total_procedimentos": total,
                "total_alto_risco": total_alto_valor,
                "percentual": percentual,
            }
        )
    return resultado