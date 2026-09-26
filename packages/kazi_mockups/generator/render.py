"""Renders the 6 Kazi screens as HTML and exports a 1080×2160 (2:1) PNG for each locale."""
import math, re, sys, pathlib
from datetime import date, timedelta
from collections import defaultdict
from data import build, LOCALES, TODAY, PENDING_FROM_DAY

HERE = pathlib.Path(__file__).parent
ICONS = HERE / "node_modules/lucide-static/icons"
FONTS = HERE / "node_modules/@fontsource/archivo/files"
OUT = HERE / "out"

def icon(name, size=24, sw=2.0, cls=""):
    svg = (ICONS / f"{name}.svg").read_text()
    inner = re.search(r"<svg[^>]*>(.*)</svg>", svg, re.S).group(1)
    c = f' class="{cls}"' if cls else ""
    return (f'<svg{c} width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
            f'stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{inner}</svg>')

KPATH = "M20 4H42V28L82 4V26L42 50L82 74V96L42 72V96H20Z"

def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;")

CSS = """
@font-face{font-family:Archivo;font-weight:400;src:url(FONTS/archivo-latin-400-normal.woff2)}
@font-face{font-family:Archivo;font-weight:500;src:url(FONTS/archivo-latin-500-normal.woff2)}
@font-face{font-family:Archivo;font-weight:600;src:url(FONTS/archivo-latin-600-normal.woff2)}
@font-face{font-family:Archivo;font-weight:700;src:url(FONTS/archivo-latin-700-normal.woff2)}
@font-face{font-family:Archivo;font-weight:800;src:url(FONTS/archivo-latin-800-normal.woff2)}
@font-face{font-family:Archivo;font-weight:400;src:url(FONTS/archivo-latin-ext-400-normal.woff2);unicode-range:U+0100-024F}
@font-face{font-family:Archivo;font-weight:600;src:url(FONTS/archivo-latin-ext-600-normal.woff2);unicode-range:U+0100-024F}
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:360px;height:720px;overflow:hidden}
body{background:#F3F1EC;color:#14120D;font-family:Archivo,sans-serif;font-size:14px;line-height:1.25;
  -webkit-font-smoothing:antialiased;font-feature-settings:"tnum" 1}
.scr{position:relative;width:360px;height:720px;overflow:hidden}
.g5{color:#6B675C}.g6{color:#57544B}
.caps{font-weight:700;font-size:10.2px;letter-spacing:.16em;text-transform:uppercase}
.amber{color:#A87400}
/* tab bar: KaziNavBar + KaziNavBarFab, light theme */
.tab{position:absolute;left:0;right:0;bottom:0;height:71px;background:#F3F1EC}
.tab>svg.bar{position:absolute;left:0;top:0;overflow:visible;filter:drop-shadow(0 0 1.5px rgba(20,18,13,.15))}
.tab .dest{position:absolute;inset:0 0 20px;display:grid;grid-template-columns:1fr 1fr 74px 1fr 1fr}
.tab .dest>div{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;color:#6B675C}
.tab .dest span{font-size:10px;line-height:1.1;font-weight:400;white-space:nowrap}
.tab .dest>div.on{color:#14120D}
.tab .dest>div.on span{font-weight:600}
.fab{position:absolute;left:153px;top:-27px;width:54px;height:54px;border-radius:50%;background:#FFCC31;color:#14120D;
  display:flex;align-items:center;justify-content:center;
  box-shadow:0 1px 3px rgba(20,18,13,.24),0 3px 6px rgba(20,18,13,.14)}
/* shared */
.hdr{display:flex;align-items:center;padding:0 15px}
.hdr h1{font-weight:600;font-size:18.5px;letter-spacing:-.02em;flex:1}
.hdr .ic{width:30px;display:flex;justify-content:center;color:#14120D}
.divider{height:1px;background:#DDD9CE}
.seg{margin:12px 15px 0;height:40px;border-radius:14px;background:#ECE9E2;padding:3.5px;display:grid;grid-template-columns:1fr 1fr}
.seg span{display:flex;align-items:center;justify-content:center;font-size:13.3px;font-weight:500;color:#6B675C;border-radius:11px}
.seg span.on{background:#fff;color:#14120D;font-weight:600;box-shadow:0 1px 2px rgba(20,18,13,.06)}
.chips{display:flex;gap:8px;margin:12px 15px 0;white-space:nowrap}
.chips span{height:33px;display:flex;align-items:center;padding:0 12.5px;border-radius:17px;font-size:11.8px;font-weight:500;
  background:#fff;border:1px solid #D8D4C8}
.chips span{font-weight:400}
.chips span.on{font-weight:500;background:#22201A;border-color:#22201A;color:#F4F2ED}
.card{background:#fff;border:1px solid #DDD9CE;border-radius:18px}
.svc{display:flex;align-items:center;min-height:88px;padding:10px 15px 10px 14px;background:#fff;border:1px solid #DDD9CE;border-radius:16px}
.svc .l{flex:1;min-width:0}
.svc .t{font-weight:600;font-size:14.7px;letter-spacing:-.01em}
.svc .s{margin-top:4px;font-size:11.7px;color:#6B675C}
.badge{display:inline-flex;align-items:center;height:22px;margin-top:5px;padding:0 7.5px;border-radius:11px;background:#FCEBD0;
  color:#7A4B00;font-weight:600;font-size:11.5px}
.svc .r{text-align:right;padding-left:10px}
.svc .v{font-weight:700;font-size:14.2px;letter-spacing:-.01em;white-space:nowrap}
.svc .o{margin-top:6px;font-size:11.7px;color:#6B675C;white-space:nowrap}
.bigbtn{margin:0 15px;height:47px;border-radius:17px;background:#FFCC31;display:flex;align-items:center;justify-content:center;gap:10px;
  font-weight:600;font-size:14.9px;letter-spacing:-.015em}
"""

def page(body, css_extra=""):
    css = CSS.replace("FONTS", FONTS.as_uri())
    return f"<!doctype html><html><head><meta charset='utf-8'><style>{css}{css_extra}</style></head><body><div class='scr'>{body}</div></body></html>"

NAV_W, NAV_H = 360, 51
# The gesture-bar strip under the bar: BottomAppBar paints its own colour into that safe area.
BOTTOM_INSET = 20
FAB_R, NOTCH_MARGIN = 27, 8

def notch_path():
    """Flutter's CircularNotchedRectangle around the docked FAB, inflated by notchMargin."""
    r = FAB_R + NOTCH_MARGIN
    cx, s1, s2 = NAV_W / 2, 15.0, 1.0
    a = -r - s2
    p2x = r * r / a                      # the fab's centre sits on the bar's top edge, so b == 0
    p2y = math.sqrt(r * r - p2x * p2x)
    pts = [(a - s1, 0), (a, 0), (p2x, p2y), (-p2x, p2y), (-a, 0), (-a + s1, 0)]
    (x0, y0), (x1, y1), (x2, y2), (x3, y3), (x4, y4), (x5, y5) = [(cx + x, y) for x, y in pts]
    return (f"M0 0H{x0:.2f}Q{x1:.2f} {y1:.2f} {x2:.2f} {y2:.2f}A{r} {r} 0 0 0 {x3:.2f} {y3:.2f}"
            f"Q{x4:.2f} {y4:.2f} {x5:.2f} {y5:.2f}H{NAV_W}V{NAV_H + BOTTOM_INSET}H0Z")

def tabbar(t, active):
    icons = ["house", "list", "users", "settings"]
    cells = []
    for i, (ic, label) in enumerate(zip(icons, t["tabs"])):
        on = i == active
        cells.append(f'<div class="{"on" if on else ""}">{icon(ic, 21, 3 if on else 2)}<span>{esc(label)}</span></div>')
        if i == 1:
            cells.append("<div></div>")
    bar = (f'<svg class="bar" width="{NAV_W}" height="{NAV_H + BOTTOM_INSET}" viewBox="0 0 {NAV_W} {NAV_H + BOTTOM_INSET}">'
           f'<path d="{notch_path()}" fill="#fff"/></svg>')
    return (f'<nav class="tab">{bar}<div class="dest">{"".join(cells)}</div>'
            f'<span class="fab">{icon("plus", 32, 2)}</span></nav>')

def svc_card(D, s, show_badge=True, date_fmt=None):
    L, t = D["L"], D["L"]["t"]
    d = L["date"](date(2026, 9, s["day"]))
    client = L["clients"][s["client"]] if s["client"] is not None else None
    sub = f"{esc(client)} · {d}" if client else d
    badge = f'<span class="badge">{esc(t["badge"])}</span>' if (show_badge and not s["received"]) else ""
    return (f'<div class="svc" style="border-left:3.5px solid {s["color"]}">'
            f'<div class="l"><div class="t">{esc(s["name"])}</div><div class="s">{sub}</div>{badge}</div>'
            f'<div class="r"><div class="v">{L["money"](s["gain"])}</div><div class="o">{esc(t["of"].format(v=L["money"](s["price"])))}</div></div></div>')

def stats(D):
    S = D["services"]
    gain = sum(s["gain"] for s in S)
    gross = sum(s["price"] for s in S)
    rec = sum(s["gain"] for s in S if s["received"])
    pend = gain - rec
    npend = sum(1 for s in S if not s["received"])
    today = sorted([s for s in S if s["day"] == TODAY.day], key=lambda s: -s["time"])
    return dict(gain=gain, gross=gross, rec=rec, pend=pend, npend=npend, n=len(S), today=today,
                pct=gain / gross * 100)

def screen_home(D):
    L, t = D["L"], D["L"]["t"]; st = stats(D); m = L["money"]
    today_rec = sum(s["gain"] for s in st["today"] if s["received"])
    today_pend = sum(s["gain"] for s in st["today"] if not s["received"])
    byday = defaultdict(lambda: [0, 0])
    for s in D["services"]:
        byday[s["day"]][0 if s["received"] else 1] += s["gain"]
    mx = max(a + b for a, b in byday.values())
    bars = []
    for d in range(1, 31):
        r, p = byday.get(d, (0, 0))
        if r + p == 0:
            bars.append('<div class="bc"><i class="dot"></i></div>')
            continue
        hr, hp = r / mx * 29, p / mx * 29
        mark = '<i class="today"></i>' if d == TODAY.day else ""
        stack = (f'<i class="bp" style="height:{hp:.1f}px"></i>' if p else "") + (f'<i class="br" style="height:{hr:.1f}px"></i>' if r else "")
        bars.append(f'<div class="bc">{mark}{stack}</div>')
    cards = "".join(svc_card(D, s) for s in st["today"])
    today_caps = esc(t["home_today"].format(n=len(st["today"]), v="@@")).replace("@@", '<span style="text-transform:none">' + m(sum(s["gain"] for s in st["today"])) + "</span>")
    body = f'''
<div class="top"><div class="logo"><svg width="15" height="15" viewBox="16 0 70 100"><path d="{KPATH}" fill="#14120D"/></svg><span>kazi</span></div><span class="mo">{esc(L["month"])}</span></div>
<div class="dark">
  <div class="dt">
    <div class="lab">{esc(t["home_label"])}</div>
    <span class="chev">{icon("chevron-up", 20, 2.2)}</span>
    <div class="amt">{m(st["gain"])}</div>
    <div class="tl">{esc(t["today_line"].format(day=L["today_short"], r=m(today_rec), p=m(today_pend)))}</div>
    <div class="bars">{"".join(bars)}</div>
  </div>
  <div class="strip"><div><b>{m(st["rec"])}</b><span>{esc(t["received"])}</span></div><div><b>{m(st["pend"])}</b><span>{esc(t["pending"])}</span></div></div>
</div>
<div class="qa">
  <div><span class="c y">{icon("plus", 23, 2)}</span><span class="ql">{esc(t["qa"][0])}</span></div>
  <div><span class="c">{icon("user-plus", 21, 1.7)}</span><span class="ql">{esc(t["qa"][1])}</span></div>
  <div><span class="c">{icon("layout-grid", 21, 1.7)}</span><span class="ql">{esc(t["qa"][2])}</span></div>
</div>
<div class="panel">
  <div class="ph"><span class="caps">{today_caps}</span><span class="amber see">{esc(t["see_all"])}</span></div>
  <div class="list">{cards}</div>
</div>
{tabbar(t, 0)}'''
    css = """
.top{height:30px;margin-top:28px;padding:0 15px;display:flex;align-items:center;justify-content:space-between}
.logo{display:flex;align-items:center;gap:11px}
.logo span{font-weight:800;font-size:25.2px;letter-spacing:-.06em;line-height:1;margin-top:-3px}
.mo{font-size:13.4px;color:#6B675C}
.dark{margin:10px 15px 0;border-radius:21px;background:#14120D;color:#F4F2ED;overflow:hidden;box-shadow:0 10px 22px rgba(20,18,13,.2)}
.dt{position:relative;padding:21px 22px 0 23px}
.lab{font-size:13.5px;color:#C9C5B9}
.chev{position:absolute;right:37px;top:36px;color:#F4F2ED}
.amt{margin-top:8px;font-weight:700;font-size:30.7px;letter-spacing:-.035em;line-height:1.05}
.tl{margin-top:10px;font-size:11.7px;color:#A8A498;white-space:nowrap}
.bars{display:grid;grid-template-columns:repeat(30,1fr);height:32px;margin:7px -4px 17px -8px;align-items:end}
.bc{display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:32px}
.bc i{display:block;width:5px}
.bc .dot{width:4px;height:4px;border-radius:2px;background:#3D3A31}
.bc .br{background:#FFCC31;border-radius:1.5px}
.bc .bp{background:#6B675C;border-radius:1.5px 1.5px 0 0}
.bc .bp:last-child{border-radius:1.5px}
.bc .br:first-child{border-radius:1.5px}
.bc .today{width:4px;height:4px;border-radius:2px;background:#FFCC31;margin-bottom:3px}
.strip{display:grid;grid-template-columns:1fr 1fr;background:#22201A;height:63px;align-items:center}
.strip div{display:flex;flex-direction:column;gap:6px;padding-left:23px}
.strip div+div{border-left:1px solid #3A372F;padding-left:8px;height:40px;justify-content:center}
.strip b{font-weight:700;font-size:14.4px;letter-spacing:-.02em}
.strip span{font-size:11.5px;color:#A8A498}
.qa{display:grid;grid-template-columns:repeat(3,1fr);margin:19px 15px 0}
.qa>div{display:flex;flex-direction:column;align-items:center;gap:6px}
.qa .c{width:48px;height:48px;border-radius:50%;border:1px solid #D8D4C8;background:#F7F6F2;display:flex;align-items:center;justify-content:center}
.qa .c.y{background:#FFCC31;border-color:#FFCC31}
.ql{font-size:13.6px;white-space:nowrap}
.panel{margin:16px 15px 0;background:#ECE9E2;border-radius:20px;padding:25px 12px 12px}
.ph{display:flex;justify-content:space-between;align-items:center;padding:0 8px}
.see{font-weight:600;font-size:14.7px;letter-spacing:-.01em}
.list{display:flex;flex-direction:column;gap:8px;margin-top:12px}
"""
    return page(body, css)

def services_head(t):
    return f'''
<div class="hdr" style="height:32px;margin-top:27px"><h1>{esc(t["services"])}</h1>
<span class="ic">{icon("search", 20, 1.9)}</span><span class="ic">{icon("arrow-up-down", 19, 1.9)}</span><span class="ic">{icon("funnel", 19, 1.9)}</span></div>
<div class="divider" style="margin-top:10px"></div>'''

def seg(t, active):
    return '<div class="seg">' + "".join(f'<span class="{"on" if i == active else ""}">{esc(x)}</span>' for i, x in enumerate(t["seg"])) + "</div>"

def chips(labels, on):
    return '<div class="chips">' + "".join(f'<span class="{"on" if i in on else ""}">{esc(x)}</span>' for i, x in enumerate(labels)) + "</div>"

SUM_CSS = """
.sum{margin:12px 15px 0;padding:16px 16px 0}
.sum .row{display:flex;justify-content:space-between;align-items:center}
.sum .cnt{font-weight:600;font-size:10.6px;letter-spacing:.14em}
.sum .caps{font-weight:600;font-size:10.6px}
.sum .amt{margin-top:8px;font-weight:800;font-size:29.7px;letter-spacing:-.04em;line-height:1.05}
.sum .sub{margin-top:5px;font-size:11.6px;line-height:16px}
.sum hr{border:0;height:1px;background:#DDD9CE;margin:0}
.act{display:flex;gap:11px;align-items:flex-start;padding:15px 0 22px}
.act svg{flex-shrink:0;margin-top:4px}
.act span{font-weight:600;font-size:15.4px;line-height:18.4px;letter-spacing:-.01em;color:#A87400}
"""

def sum_card(D, sub, extra=""):
    L, t = D["L"], D["L"]["t"]; st = stats(D); m = L["money"]
    return f'''
<div class="card sum">
  <div class="row"><span class="caps g6">{esc(t["sum_label"].format(m=L["month"]))}</span><span class="cnt g6">{esc(t["count"].format(n=st["n"]))}</span></div>
  <div class="amt">{m(st["gain"])}</div>
  <div class="sub g6">{sub}</div>
  {extra}
  <hr>
  <div class="act">{icon("check-check", 18, 2, "amber")}<span>{esc(t["action"].format(k=st["npend"], p=m(st["pend"])))}</span></div>
</div>'''

def screen_list(D):
    L, t = D["L"], D["L"]["t"]; st = stats(D); m = L["money"]
    sub = esc(t["list_sub"].format(pct=L["pct"](st["pct"]), g=m(st["gross"]), r=m(st["rec"]), p=m(st["pend"])))
    cards = "".join(svc_card(D, s) for s in st["today"])
    body = f'''{services_head(t)}{seg(t, 0)}{chips(t["chips"], {0, 1})}
{sum_card(D, sub, '<div style="height:18px"></div>')}
<div class="sh"><span class="caps g6">{esc(t["today_sec"].format(n=len(st["today"])))}</span>{icon("chevron-up", 22, 2)}</div>
<div class="list">{cards}</div>
{tabbar(t, 1)}'''
    css = SUM_CSS + """
.sh{display:flex;justify-content:space-between;align-items:center;margin:17px 15px 0 16px;padding-right:9px}
.list{display:flex;flex-direction:column;gap:8px;margin:11px 15px 0}
"""
    return page(body, css)

def screen_summary(D):
    L, t = D["L"], D["L"]["t"]; st = stats(D); m = L["money"]
    weeks = [(1, 5), (8, 12), (15, 19), (22, 26)]
    wv = []
    for a, b in weeks:
        ss = [s for s in D["services"] if a <= s["day"] <= b]
        wv.append((sum(s["gain"] for s in ss if s["received"]), sum(s["gain"] for s in ss if not s["received"])))
    mx = max(r + p for r, p in wv)
    bars = ""
    for r, p in wv:
        hr, hp = r / mx * 67, p / mx * 67
        top_r = "4px 4px 0 0" if not p else "0"
        bars += (f'<div class="wb"><i class="p" style="height:{hp:.1f}px"></i>'
                 f'<i class="r" style="height:{hr:.1f}px;border-radius:{top_r}"></i></div>')
    chart = f'''<div class="wk">{bars}</div>
<div class="lg"><span><i class="sq d"></i>{esc(t["legend"][0])}</span><span><i class="sq l"></i>{esc(t["legend"][1])}</span><span class="rt">{esc(t["legend"][2])}</span></div>'''
    sub = esc(t["summary_sub"].format(pct=L["pct"](st["pct"]), g=m(st["gross"])))
    per = defaultdict(float); color = {}; name = {}
    for s in D["services"]:
        per[s["cat"]] += s["gain"]; color[s["cat"]] = s["color"]; name[s["cat"]] = s["name"]
    order = sorted(per, key=lambda c: -per[c])
    mxs = per[order[0]]
    rows = "".join(f'<div class="ps"><div class="pr"><span>{esc(name[c])}</span><b>{m(per[c])}</b></div>'
                   f'<div class="track"><i style="width:{per[c] / mxs * 100:.1f}%;background:{color[c]}"></i></div></div>' for c in order)
    body = f'''{services_head(t)}{seg(t, 1)}{chips(t["chips"], {0, 1})}
{sum_card(D, sub, chart)}
<div class="sh"><span class="caps g6">{esc(t["by_service"])}</span></div>
<div class="card per">{rows}</div>
{tabbar(t, 1)}'''
    css = SUM_CSS + """
.wk{display:grid;grid-template-columns:repeat(4,53.3px);gap:7.7px;height:67px;margin-top:16px;align-items:end}
.wb{display:flex;flex-direction:column;justify-content:flex-end;height:67px}
.wb i{display:block}
.wb .r{background:#22201A}
.wb .p{background:#E9E6DD;border-radius:4px 4px 0 0}
.lg{display:flex;gap:14px;align-items:center;margin:14px 0 22px;font-size:11.6px;color:#57544B;white-space:nowrap}
.lg span{display:flex;align-items:center;gap:7px}
.lg .rt{margin-left:auto}
.sq{display:inline-block;width:9px;height:9px;border-radius:2px}
.sq.d{background:#22201A}.sq.l{background:#E9E6DD;border:1px solid #DDD9CE}
.sh{margin:20px 16px 0}
.per{margin:14px 15px 0;padding:14px 16px 6px}
.ps{padding-bottom:12px}
.pr{display:flex;justify-content:space-between;font-size:11.4px;margin-bottom:6px}
.pr b{font-weight:700;font-size:11px;letter-spacing:.01em}
.track{height:5.5px;border-radius:3px;background:#E9E6DD;overflow:hidden}
.track i{display:block;height:100%;border-radius:3px}
"""
    return page(body, css)

def client_rows(D):
    L = D["L"]; rows = []
    by = defaultdict(list)
    for s in D["services"]:
        if s["client"] is not None:
            by[s["client"]].append(s)
    for ci, nm in enumerate(L["clients"]):
        hk, hv, hdays = D["hist_client"][ci]
        ss = by.get(ci, [])
        n = len(ss) + hk
        if n == 0:
            continue
        total = sum(s["price"] for s in ss) + hv
        last = date(2026, 9, max(s["day"] for s in ss)) if ss else date(2026, 9, 1) - timedelta(days=hdays)
        lasttime = max(s["time"] for s in ss) if ss else 0
        rows.append(dict(name=nm, n=n, total=total, last=last, lt=lasttime))
    rows.sort(key=lambda r: (r["last"], r["lt"]), reverse=True)
    return rows

def screen_clients(D):
    L, t = D["L"], D["L"]["t"]; m = L["money"]
    rows = client_rows(D)
    cards = ""
    for r in rows[:8]:
        sub = (t["client_sub1"] if r["n"] == 1 else t["client_sub"]).format(d=L["date"](r["last"]), n=r["n"])
        cards += (f'<div class="card cl"><div class="l"><div class="n">{esc(r["name"])}</div><div class="s g5">{esc(sub)}</div></div>'
                  f'<b>{m(r["total"])}</b></div>')
    body = f'''
<div class="hdr" style="height:40px;margin-top:33px"><h1 style="font-size:18.6px">{esc(t["clients"])}</h1>
<span class="cn g5">{len(rows)}</span><span class="ic">{icon("search", 20, 1.9)}</span><span class="ic">{icon("arrow-up-down", 19, 1.9)}</span><span class="ic" style="width:40px">{icon("ellipsis", 21, 2.4)}</span></div>
<div class="divider" style="margin-top:14px"></div>
<div class="bigbtn" style="margin-top:26px">{icon("plus", 19, 2)}<span>{esc(t["add_client"])}</span></div>
<div class="cls">{cards}</div>
{tabbar(t, 2)}'''
    css = """
.cn{font-weight:600;font-size:12px;margin-right:8px}
.cls{display:flex;flex-direction:column;gap:8px;margin:15px 15px 0}
.cl{display:flex;align-items:center;height:64px;padding:0 16px}
.cl .l{flex:1;min-width:0}
.cl .n{font-weight:600;font-size:14.8px;letter-spacing:-.015em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.cl .s{margin-top:7px;font-size:11.7px;white-space:nowrap}
.cl b{font-weight:700;font-size:13.9px;letter-spacing:-.015em;padding-left:10px;white-space:nowrap}
"""
    return page(body, css)

def screen_settings(D):
    L, t = D["L"], D["L"]["t"]
    name, prof, mail, ini = L["profile"]
    def row(ic, title, meta, tall=False):
        mt = f'<span class="mt">{meta}</span>'
        return (f'<div class="card sr{" tall" if tall else ""}"><span class="si">{icon(ic, 21.5, 1.7)}</span>'
                f'<span class="st">{esc(title)}</span>{mt}<span class="cv">{icon("chevron-right", 17, 2)}</span></div>')
    body = f'''
<div class="hdr" style="height:36px;margin-top:25px"><h1 style="font-size:18.6px">{esc(t["settings"])}</h1></div>
<div class="divider" style="margin-top:5px"></div>
<div class="card prof"><span class="av">{ini}</span><div><div class="pn">{esc(name)}</div><div class="pp g5">{esc(prof)}</div><div class="pm g5">{esc(mail)}</div></div></div>
<div class="sec caps g6" style="margin-top:23px">{esc(t["sec"][0])}</div>
<div class="rows">{row("tag", t["catalog_row"], esc(t["items"].format(n=len(L["catalog"]))))}
{row("calendar-clock", t["cycle"], esc(t["cycle_v"][0]) + "<br>" + esc(t["cycle_v"][1]), True)}</div>
<div class="sec caps g6">{esc(t["sec"][1])}</div>
<div class="rows">{row("wallet", t["currency"], esc(t["currency_v"]))}{row("languages", t["language"], esc(t["language_v"]))}{row("moon", t["theme"], esc(t["theme_v"]))}</div>
<div class="sec caps g6">{esc(t["sec"][2])}</div>
<div class="card pv"><span class="si">{icon("activity", 21.5, 1.7)}</span><div class="pt"><div class="st">{esc(t["privacy"])}</div><div class="pd g5">{esc(t["privacy_d"])}</div></div><span class="tg"><i></i></span></div>
{tabbar(t, 3)}'''
    css = """
.prof{display:flex;align-items:center;gap:14px;margin:12px 15px 0;height:88px;padding:0 16px}
.av{width:41px;height:41px;border-radius:50%;background:#22201A;color:#F4F2ED;display:flex;align-items:center;justify-content:center;
  font-weight:700;font-size:15px;letter-spacing:.02em;flex-shrink:0}
.pn{font-weight:600;font-size:14.8px;letter-spacing:-.015em}
.pp{margin-top:5px;font-size:13.6px}
.pm{margin-top:4px;font-size:11.6px}
.sec{margin:30px 16px 0;font-weight:600;font-size:10.5px}
.rows{display:flex;flex-direction:column;gap:8px;margin:11px 15px 0}
.sr{display:flex;align-items:center;height:46px;padding:0 16px 0 15px;border-radius:16px}
.sr.tall{height:54px}
.si{width:28px;display:flex;justify-content:center;color:#57544B;flex-shrink:0}
.st{font-weight:600;font-size:15px;letter-spacing:-.02em;margin-left:14px;flex:1;white-space:nowrap}
.mt{font-size:11.6px;color:#6B675C;text-align:right;line-height:15px}
.cv{color:#57544B;margin-left:10px;display:flex}
.pv{display:flex;align-items:flex-start;margin:11px 15px 0;padding:15px 16px 18px 15px}
.pv .si{margin-top:2px}
.pt{flex:1;margin-left:14px}
.pt .st{margin-left:0;white-space:normal}
.pd{margin-top:7px;font-size:13.6px;line-height:20px}
.tg{width:41px;height:24px;border-radius:12px;background:#22201A;flex-shrink:0;position:relative;margin-left:12px;margin-top:2px}
.tg i{position:absolute;right:3px;top:3px;width:18px;height:18px;border-radius:50%;background:#FFCC31}
"""
    return page(body, css)

def screen_catalog(D):
    L, t = D["L"], D["L"]["t"]; m = L["money"]
    uses = [0] * len(L["catalog"])
    for s in D["services"]:
        uses[s["cat"]] += 1
    uses = [u + h for u, h in zip(uses, D["hist_uses"])]
    cards = ""
    for i, (nm, price, com, color, _) in enumerate(L["catalog"]):
        cards += (f'<div class="svc ct" style="border-left:3.5px solid {color}"><div class="l"><div class="t">{esc(nm)}</div>'
                  f'<div class="s">{esc(t["cat_sub"].format(v=m(price), c=f"{round(com * 100)}%"))}</div></div>'
                  f'<span class="u g5">{esc(t["uses"].format(n=uses[i]))}</span></div>')
    body = f'''
<div class="hdr" style="height:40px;margin-top:33px;padding-left:18px"><span style="display:flex;margin-right:13px">{icon("chevron-left", 22, 2.2)}</span><h1 style="font-size:18.7px">{esc(t["catalog"])}</h1>
<span class="cn g5">{len(L["catalog"])}</span><span class="ic">{icon("search", 20, 1.9)}</span><span class="ic" style="width:40px">{icon("ellipsis", 21, 2.4)}</span></div>
<div class="bigbtn" style="margin-top:18px">{icon("plus", 19, 2)}<span>{esc(t["new_service"])}</span></div>
{chips(t["cat_chips"], {0})}
<div class="cts">{cards}</div>
{tabbar(t, 3)}'''
    css = """
.cn{font-weight:600;font-size:12px;margin-right:8px}
.chips{margin-top:15px}
.cts{display:flex;flex-direction:column;gap:8px;margin:15px 15px 0}
.ct{min-height:62px;height:62px}
.ct .t{font-size:14.7px}
.ct .s{margin-top:7px;font-size:11.7px}
.u{font-size:11.4px;padding-left:10px;white-space:nowrap}
"""
    return page(body, css)

DEGRADE = 3

def screen_details(D):
    L, t = D["L"], D["L"]["t"]; m = L["money"]
    sv = next(s for s in stats(D)["today"] if s["cat"] == DEGRADE)
    when = f'{L["date"](date(2026, 9, sv["day"]))} · {sv["time"] // 60:02d}:{sv["time"] % 60:02d}'
    com = round(L["catalog"][sv["cat"]][2] * 100)
    values = [sv["name"], L["clients"][sv["client"]], when, t["status_pending"], t["detail_note"]]
    rows = ""
    for i, (label, value) in enumerate(zip(t["detail_rows"], values)):
        edge = f' style="border-left:3.5px solid {sv["color"]}"' if i == 0 else ""
        rows += f'<div class="card dr"{edge}><span class="g5">{esc(label)}</span><b>{esc(value)}</b></div>'
    body = f'''
<div class="hdr" style="height:40px;margin-top:33px;padding-left:18px"><span style="display:flex;margin-right:13px">{icon("chevron-left", 22, 2.2)}</span><h1 style="font-size:18.7px">{esc(t["service"])}</h1>
<span class="ic" style="width:38px">{icon("pencil", 16.5, 2)}</span><span class="ic" style="width:40px">{icon("ellipsis", 16.5, 2.4)}</span></div>
<div class="divider" style="margin-top:14px"></div>
<div class="earn">
  <div class="el">{esc(t["your_earnings"])}</div>
  <div class="ea">{m(sv["gain"])}</div>
  <div class="eg">{esc(t["commission_of_gross"].format(pct=f"{com}%", v=m(sv["price"])))}</div>
</div>
<div class="drs">{rows}</div>
<div class="foot"><div class="cta">{esc(t["mark_received"])}</div></div>'''
    css = """
.earn{margin:22px 15px 0;padding:15px;border-radius:13px;background:#14120D;color:#F4F2ED}
.el{font-weight:600;font-size:11px;line-height:1.33;letter-spacing:1.1px;text-transform:uppercase;color:#A8A498}
.ea{margin-top:7px;font-weight:800;font-size:29.5px;line-height:1;letter-spacing:-1.18px}
.eg{margin-top:4px;font-size:11px;line-height:1.4;color:#FFCC31}
.drs{display:flex;flex-direction:column;gap:7px;margin:11px 15px 0}
.dr{display:flex;align-items:center;gap:11px;padding:11px 15px;border-radius:11px}
.dr span{flex:2;font-size:12.9px;line-height:20px}
.dr b{flex:3;text-align:right;font-weight:600;font-size:14.7px;line-height:1.25;letter-spacing:-.01em}
.foot{position:absolute;left:0;right:0;bottom:0;padding:11px 22px 35px;background:#F3F1EC;border-top:1px solid #DDD9CE}
.cta{height:44px;border-radius:11px;background:#14120D;color:#F4F2ED;display:flex;align-items:center;justify-content:center;
  font-weight:600;font-size:14.7px;letter-spacing:-.3px}
"""
    return page(body, css)

SCREENS = [("01_home", screen_home), ("02_services_list", screen_list), ("03_services_summary", screen_summary),
           ("04_clients", screen_clients), ("05_settings", screen_settings), ("06_catalog", screen_catalog),
           ("07_service_details", screen_details)]

def main(only=None):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        b = p.chromium.launch()
        pg = b.new_page(viewport={"width": 360, "height": 720}, device_scale_factor=3)
        for code in LOCALES:
            if only and code not in only:
                continue
            D = build(code)
            (OUT / code).mkdir(parents=True, exist_ok=True)
            (OUT / "html" / code).mkdir(parents=True, exist_ok=True)
            for slug, fn in SCREENS:
                html = fn(D)
                f = OUT / "html" / code / f"{slug}.html"
                f.write_text(html)
                pg.goto(f.as_uri())
                pg.evaluate("document.fonts.ready")
                pg.wait_for_timeout(150)
                pg.screenshot(path=str(OUT / code / f"{slug}.png"), clip={"x": 0, "y": 0, "width": 360, "height": 720})
                print(code, slug)
        b.close()

if __name__ == "__main__":
    main(sys.argv[1:] or None)
