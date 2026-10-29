#!/usr/bin/env python3
"""
리뷰용 미리보기 서버 (포트 8000) — 저장소 루트를 정적 서빙하고,
/front/medical/*.do 는 실제 데코레이터 JSP + 페이지 JSP 를 합성해 렌더링합니다.

- 실제 서비스(서블릿/DB/API)가 아니라 화면 검토용입니다. 동적 값(JSTL 반복, EL)은 비워집니다.
- 정적 페이지(회사소개·사업소개 등)는 실제와 같은 구조로 렌더링됩니다.
- 옵트인 스위치(<c:set>/<c:if>)는 데코레이터 JSP 에 적힌 그대로 평가합니다.
- 127.0.0.1 에만 바인딩하며 WEB-INF, .git 은 직접 접근을 막습니다.

사용:  python3 prototype-kogo/preview/serve.py [포트]
"""
import os, re, sys, urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
JSP = os.path.join(ROOT, 'WEB-INF', 'jsp')
NO_DECORATOR = {'clinicSearch', 'setting'}          # decorators.xml 의 excludes
MAIN_DECORATOR = {'/index.do', '/front/medical/index.do'}

def read(p):
    with open(p, encoding='utf-8', errors='replace') as f: return f.read()

# ── 아주 작은 EL 평가기: param.x, 변수, eq/ne/and/or/not, true/false, '문자열' ──
def eval_el(expr, params, vars_):
    tokens = re.findall(r"'[^']*'|\w+(?:\.\w+)?|\(|\)|\S", expr)
    out = []
    for tk in tokens:
        if tk.startswith("'"): out.append(repr(tk[1:-1]))
        elif tk in ('and', 'or', 'not', '(', ')'): out.append(tk)
        elif tk == 'eq': out.append('==')
        elif tk == 'ne': out.append('!=')
        elif tk == 'true': out.append('True')
        elif tk == 'false': out.append('False')
        elif tk.startswith('param.'): out.append(repr(params.get(tk[6:], '')))
        elif re.fullmatch(r'\w+', tk): out.append(repr(vars_.get(tk, '')) if tk in vars_ else "''")
        else: out.append(tk)
    try: return eval(' '.join(out), {'__builtins__': {}}, {})
    except Exception: return ''

def jsp_lite(text, params):
    vars_ = {}
    text = re.sub(r'<%@.*?%>', '', text, flags=re.S)
    text = re.sub(r'<%--.*?--%>', '', text, flags=re.S)
    text = re.sub(r'<%(?!@).*?%>', '', text, flags=re.S)
    def cset(m):
        v = re.search(r'value="([^"]*)"', m.group(0)); n = re.search(r'var="([^"]*)"', m.group(0))
        if n and v:
            val = v.group(1); mm = re.fullmatch(r'\$\{(.*)\}', val)
            vars_[n.group(1)] = eval_el(mm.group(1), params, vars_) if mm else val
            if vars_[n.group(1)] in ('true', 'false'): vars_[n.group(1)] = vars_[n.group(1)] == 'true'
        return ''
    text = re.sub(r'<c:set\b[^>]*/>', cset, text)
    # c:if (중첩 없음 가정)
    def cif(m):
        test = re.search(r'\$\{(.*)\}', m.group(1)); ok = bool(eval_el(test.group(1), params, vars_)) if test else False
        return m.group(2) if ok else ''
    text = re.sub(r'<c:if\s+test="([^"]*)"\s*>(.*?)</c:if>', cif, text, flags=re.S)
    text = re.sub(r'</?c:[a-zA-Z]+[^>]*>', '', text)       # 나머지 JSTL 은 태그만 제거
    text = re.sub(r'\$\{[^}]*\}', '', text)                # 남은 EL 은 비움
    return text

def split_page(html):
    title = re.search(r'<title>(.*?)</title>', html, re.S|re.I)
    head = re.search(r'<head[^>]*>(.*?)</head>', html, re.S|re.I)
    body = re.search(r'<body([^>]*)>(.*)</body>', html, re.S|re.I)
    head_in = head.group(1) if head else ''
    head_in = re.sub(r'<title>.*?</title>', '', head_in, flags=re.S|re.I)
    head_in = re.sub(r'<meta[^>]*(charset|viewport)[^>]*>', '', head_in, flags=re.I)
    cls = re.search(r'class="([^"]*)"', body.group(1)) if body else None
    return (title.group(1).strip() if title else ''), head_in, (body.group(2) if body else html), (cls.group(1) if cls else '')

def find_page_jsp(name):
    for sub in ('', 'footer'):
        p = os.path.join(JSP, 'front', 'medical', sub, name + '.jsp')
        if os.path.isfile(p): return p
    return None

def render(path, params):
    m = re.fullmatch(r'/front/medical/(\w+)\.do', path)
    if path == '/index.do': name = 'index'
    elif m: name = m.group(1)
    else: return None
    page = find_page_jsp(name)
    if not page: return None
    page_html = jsp_lite(read(page), params)
    if name in NO_DECORATOR: return page_html
    dec = 'default_medical.jsp' if path in MAIN_DECORATOR else 'default_medical_sub.jsp'
    title, head_in, body_in, body_cls = split_page(page_html)
    d = jsp_lite(read(os.path.join(JSP, 'decorators', dec)), params)
    d = re.sub(r'<decorator:title[^>]*default="([^"]*)"[^>]*/>', lambda mm: title or mm.group(1), d)
    d = re.sub(r'<decorator:head\s*/>', lambda mm: head_in, d)
    d = re.sub(r'<decorator:getProperty[^>]*/>', body_cls, d)
    d = re.sub(r'<decorator:body\s*/>', lambda mm: body_in, d)
    return d

class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k): super().__init__(*a, directory=ROOT, **k)
    def do_GET(self):
        u = urllib.parse.urlparse(self.path); p = urllib.parse.unquote(u.path)
        q = {k: v[0] for k, v in urllib.parse.parse_qs(u.query).items()}
        if p == '/': self.send_response(302); self.send_header('Location', '/prototype-kogo/preview/'); self.end_headers(); return
        if re.match(r'^/(WEB-INF|\.git|META-INF)(/|$)', p): self.send_error(404); return
        html = render(p, q)
        if html is not None:
            b = html.encode('utf-8'); self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8'); self.send_header('Content-Length', str(len(b)))
            self.send_header('Cache-Control', 'no-store'); self.end_headers(); self.wfile.write(b); return
        super().do_GET()
    def end_headers(self): self.send_header('Cache-Control', 'no-store'); super().end_headers()
    def log_message(self, f, *a): sys.stderr.write('%s\n' % (f % a))

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    print(f'미리보기 서버: http://localhost:{port}/   (저장소 루트: {ROOT})')
    ThreadingHTTPServer(('127.0.0.1', port), H).serve_forever()
