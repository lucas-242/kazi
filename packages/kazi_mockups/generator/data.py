"""Localized sample data for the Kazi mockups.

A single set of appointments (same seed) is generated for all three locales, with
local prices, names and formats. Every number on the screens comes from here, so
they all add up: month total, received/pending, daily and weekly bars, earnings
per service, per-client totals and catalog uses.
"""
import random
from datetime import date

TODAY = date(2026, 9, 26)          # Saturday
WORKDAYS = [d for d in range(1, 27) if date(2026, 9, d).weekday() in (1, 2, 3, 4, 5)]  # Tue–Sat
PENDING_FROM_DAY = 22              # the barbershop settles weekly on Saturday; the current week is still unpaid
LATE_PENDING = {(19, 6), (19, 7)}  # two week-3 services still unsettled (day, position)


def fmt_brl(v):
    s = f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return f"R$ {s}"

def fmt_pyg(v):
    s = f"{round(v):,}".replace(",", ".")
    return f"Gs. {s}"

def fmt_usd(v):
    return f"${v:,.2f}"

def pct_comma(p):  # 57,2%
    return f"{p:.1f}".replace(".", ",") + "%"

def pct_dot(p):
    return f"{p:.1f}%"

def int_pct(p):
    return f"{round(p * 100)}%"


LOCALES = {
    "pt-BR": dict(
        money=fmt_brl, pct=pct_comma, round_to=0.01,
        date=lambda d: d.strftime("%d/%m/%Y"),
        month="Setembro", today_short="26 Set",
        profile=("Rafael Moreira", "Cabelo e barbearia", "rafael.moreira@gmail.com", "RM"),
        catalog=[  # name, price, commission, color, weight
            ("Corte masculino", 50, .50, "#06B6D4", 30),
            ("Barba", 40, .50, "#65A30D", 20),
            ("Corte + barba", 80, .50, "#C42BB4", 18),
            ("Degradê", 60, .50, "#2F6FEB", 12),
            ("Sobrancelha", 20, .60, "#7C5CFC", 8),
            ("Pigmentação de barba", 60, .50, "#F97316", 4),
            ("Pezinho", 15, 1.0, "#0F766E", 8),
        ],
        clients=["Marcos Vinícius", "Thiago Rocha", "Felipe Andrade", "Gustavo Lima", "Bruno Carvalho",
                 "Rodrigo Nunes", "Eduardo Pires", "Lucas Martins", "Diego Ferreira", "João Pedro Alves",
                 "Caio Mendes", "Renan Souza", "Igor Barbosa", "Vitor Hugo", "Leandro Costa",
                 "Matheus Ribeiro", "André Luiz", "Paulo Henrique", "Henrique Dias", "Daniel Freitas",
                 "Fábio Teixeira", "Gabriel Rezende", "Otávio Prado", "Samuel Duarte"],
        t=dict(
            tabs=["Início", "Serviços", "Clientes", "Ajustes"],
            home_label="Seus ganhos este mês",
            today_line="{day} · Recebido {r} · Pendente {p}",
            received="Recebido", pending="Pendente",
            qa=["Novo serviço", "Adicionar cliente", "Catálogo"],
            home_today="Hoje · {n} serviços · {v}", see_all="Ver tudo",
            badge="Pendente", of="de {v}",
            services="Serviços", seg=["Lista", "Resumo"],
            chips=["Setembro", "Todas", "Pendentes", "Recebidos"],
            sum_label="{m} · seu ganho", count="{n} serviços",
            list_sub="{pct} de {g} gerados · {r} já recebidos · {p} pendentes",
            action="Marcar os {k} pendentes como recebidos · {p}",
            today_sec="Hoje · {n} serviços",
            summary_sub="{pct} de {g} cobrados dos clientes",
            legend=["recebido", "pendente", "seu ganho por semana"],
            by_service="Por serviço",
            clients="Clientes", add_client="Adicionar cliente",
            client_sub="Último em {d} · {n} serviços", client_sub1="Último em {d} · 1 serviço",
            settings="Ajustes", sec=["Ferramentas", "Preferências", "Privacidade"],
            catalog_row="Catálogo de serviços", items="{n} itens",
            cycle="Ciclo de pagamento", cycle_v=["Semanal", "Sábado"],
            currency="Moeda padrão", currency_v="BRL · R$",
            language="Idioma", language_v="Português",
            theme="Tema", theme_v="Claro",
            privacy="Ajudar a melhorar o Kazi",
            privacy_d="Envia eventos de uso anônimos para descobrirmos o que não está funcionando bem.",
            catalog="Catálogo", new_service="Novo serviço",
            cat_chips=["Todos", "Mais usados", "Sem comissão"],
            cat_sub="{v} · Comissão {c}", uses="{n} usos",
            service="Serviço", your_earnings="Seu ganho", commission_of_gross="{pct} de {v}",
            detail_rows=["Tipo de serviço", "Cliente", "Data", "Situação", "Observação"],
            status_pending="Pendente", mark_received="Marcar como recebido",
            detail_note="Degradê baixo, acabamento na navalha",
        ),
    ),
    "es-PY": dict(
        money=fmt_pyg, pct=pct_comma, round_to=1,
        date=lambda d: d.strftime("%d/%m/%Y"),
        month="Setiembre", today_short="26 set",
        profile=("Matías Benítez", "Peluquería y barbería", "matias.benitez@gmail.com", "MB"),
        catalog=[
            ("Corte clásico", 50000, .50, "#06B6D4", 30),
            ("Barba", 35000, .50, "#65A30D", 20),
            ("Corte + barba", 75000, .50, "#C42BB4", 18),
            ("Degradé", 60000, .50, "#2F6FEB", 12),
            ("Perfilado de cejas", 20000, .60, "#7C5CFC", 8),
            ("Tinte de barba", 50000, .50, "#F97316", 4),
            ("Contorno", 15000, 1.0, "#0F766E", 8),
        ],
        clients=["Rodrigo Giménez", "Hugo Aquino", "Sebastián Ortiz", "Diego Villalba", "Fernando Cáceres",
                 "Óscar Duarte", "Luis Ayala", "Nelson Riveros", "Gustavo Franco", "Alejandro Báez",
                 "Marcos Insfrán", "Derlis Ramírez", "Juan Carlos Rojas", "Víctor Martínez", "Cristian Acosta",
                 "Edgar Ferreira", "Ramón Galeano", "Andrés Maidana", "Julio Céspedes", "Fabián Vera",
                 "Hernán Sosa", "Pablo Encina", "Rubén Ojeda", "Tomás Zárate"],
        t=dict(
            tabs=["Inicio", "Servicios", "Clientes", "Ajustes"],
            home_label="Tus ganancias este mes",
            today_line="{day} · Recibido {r} · Pendiente {p}",
            received="Recibido", pending="Pendiente",
            qa=["Nuevo servicio", "Agregar cliente", "Catálogo"],
            home_today="Hoy · {n} servicios · {v}", see_all="Ver todo",
            badge="Pendiente", of="de {v}",
            services="Servicios", seg=["Lista", "Resumen"],
            chips=["Setiembre", "Todos", "Pendientes", "Recibidos"],
            sum_label="{m} · tu ganancia", count="{n} servicios",
            list_sub="{pct} de {g} generados · {r} ya recibidos · {p} pendientes",
            action="Marcar los {k} pendientes como recibidos · {p}",
            today_sec="Hoy · {n} servicios",
            summary_sub="{pct} de {g} cobrados a los clientes",
            legend=["recibido", "pendiente", "tu ganancia por semana"],
            by_service="Por servicio",
            clients="Clientes", add_client="Agregar cliente",
            client_sub="Último el {d} · {n} servicios", client_sub1="Último el {d} · 1 servicio",
            settings="Ajustes", sec=["Herramientas", "Preferencias", "Privacidad"],
            catalog_row="Catálogo de servicios", items="{n} ítems",
            cycle="Ciclo de pago", cycle_v=["Semanal", "Sábado"],
            currency="Moneda principal", currency_v="PYG · Gs.",
            language="Idioma", language_v="Español",
            theme="Tema", theme_v="Claro",
            privacy="Ayudar a mejorar Kazi",
            privacy_d="Envía datos de uso anónimos para descubrir qué no está funcionando bien.",
            catalog="Catálogo", new_service="Nuevo servicio",
            cat_chips=["Todos", "Más usados", "Sin comisión"],
            cat_sub="{v} · Comisión {c}", uses="{n} usos",
            service="Servicio", your_earnings="Tu ganancia", commission_of_gross="{pct} de {v}",
            detail_rows=["Tipo de servicio", "Cliente", "Fecha", "Situación", "Observación"],
            status_pending="Pendiente", mark_received="Marcar como recibido",
            detail_note="Degradé bajo, terminación a navaja",
        ),
    ),
    "en-US": dict(
        money=fmt_usd, pct=pct_dot, round_to=0.01,
        date=lambda d: d.strftime("%m/%d/%Y"),
        month="September", today_short="Sep 26",
        profile=("Anthony Moore", "Hair & barbering", "anthony.moore@gmail.com", "AM"),
        catalog=[
            ("Men's haircut", 35, .50, "#06B6D4", 30),
            ("Beard trim", 20, .50, "#65A30D", 20),
            ("Cut + beard", 50, .50, "#C42BB4", 18),
            ("Skin fade", 40, .50, "#2F6FEB", 12),
            ("Eyebrows", 12, .60, "#7C5CFC", 8),
            ("Beard color", 30, .50, "#F97316", 4),
            ("Line-up", 15, 1.0, "#0F766E", 8),
        ],
        clients=["Marcus Johnson", "Tyler Brooks", "Jordan Lee", "Chris Martinez", "Andre Williams",
                 "Kevin O'Brien", "Devon Carter", "Sam Patel", "Mike Russo", "Jake Thompson",
                 "Luis Ramirez", "Ethan Walker", "Darnell Hayes", "Ryan Cooper", "Brandon Kim",
                 "Josh Miller", "Nate Collins", "Omar Hassan", "Cole Bennett", "Aaron Price",
                 "DJ Reynolds", "Eli Foster", "Grant Sullivan", "Trevor Hughes"],
        t=dict(
            tabs=["Home", "Services", "Clients", "Settings"],
            home_label="Your earnings this month",
            today_line="{day} · Received {r} · Pending {p}",
            received="Received", pending="Pending",
            qa=["New service", "Add client", "Catalog"],
            home_today="Today · {n} services · {v}", see_all="See all",
            badge="Pending", of="of {v}",
            services="Services", seg=["List", "Summary"],
            chips=["September", "All", "Pending", "Received"],
            sum_label="{m} · your earnings", count="{n} services",
            list_sub="{pct} of {g} billed · {r} received · {p} pending",
            action="Mark {k} pending as received · {p}",
            today_sec="Today · {n} services",
            summary_sub="{pct} of {g} billed to clients",
            legend=["received", "pending", "your earnings by week"],
            by_service="By service",
            clients="Clients", add_client="Add client",
            client_sub="Last visit {d} · {n} services", client_sub1="Last visit {d} · 1 service",
            settings="Settings", sec=["Tools", "Preferences", "Privacy"],
            catalog_row="Service catalog", items="{n} items",
            cycle="Pay cycle", cycle_v=["Weekly", "Saturday"],
            currency="Default currency", currency_v="USD · $",
            language="Language", language_v="English",
            theme="Theme", theme_v="Light",
            privacy="Help improve Kazi",
            privacy_d="Sends anonymous usage events so we can find what isn't working well.",
            catalog="Catalog", new_service="New service",
            cat_chips=["All", "Most used", "No commission"],
            cat_sub="{v} · {c} commission", uses="{n} uses",
            service="Service", your_earnings="Your earnings", commission_of_gross="{pct} of {v}",
            detail_rows=["Service type", "Client", "Date", "Status", "Note"],
            status_pending="Pending", mark_received="Mark as received",
            detail_note="Low fade, straight-razor finish",
        ),
    ),
}


def build(code):
    L = LOCALES[code]
    rng = random.Random(42)                       # same sequence for all three locales
    cat = L["catalog"]
    weights = [c[4] for c in cat]
    rnd = lambda v: round(v / L["round_to"]) * L["round_to"]

    services = []
    for d in WORKDAYS:
        sat = date(2026, 9, d).weekday() == 5
        n = 5 if d == TODAY.day else (rng.randint(8, 10) if sat else rng.randint(5, 8))
        minute = 9 * 60 + rng.choice([0, 15, 30])
        for i in range(n):
            ci = rng.choices(range(len(cat)), weights)[0]
            while d == TODAY.day and services and services[-1]["day"] == d and services[-1]["cat"] == ci:
                ci = rng.choices(range(len(cat)), weights)[0]   # today: never the same service twice in a row
            client = rng.randrange(len(L["clients"])) if rng.random() < .82 else None
            name, price, com, color, _ = cat[ci]
            services.append(dict(
                day=d, pos=i, time=minute, cat=ci, name=name, price=price, color=color,
                gain=rnd(price * com), client=client,
                received=d < PENDING_FROM_DAY and (d, i) not in LATE_PENDING,
            ))
            minute += rng.choice([35, 40, 45, 50, 60])

    # history before September (clients and catalog uses)
    hist_client = {}
    for ci in range(len(L["clients"])):
        k = rng.randint(0, 9)
        fav = rng.choices(range(len(cat)), weights, k=k)
        hist_client[ci] = (k, sum(cat[x][1] for x in fav), rng.randint(3, 80))  # count, value, days before Sep 1
    hist_uses = [rng.randint(60, 140) * w // 30 + rng.randint(2, 9) for w in weights]

    return dict(L=L, services=services, hist_client=hist_client, hist_uses=hist_uses)
