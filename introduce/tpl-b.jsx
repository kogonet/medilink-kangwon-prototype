// Template B — Midnight Signal (deep navy, data-console feel, cyan signal + coral alert)
const TB = { bg: '#07122B', panel: '#0E1D40', line: 'rgba(160,190,255,.16)', ink: '#F2F5FB', sub: '#93A3C4', acc: '#4FD1FF', alert: '#FF5D4F' };

function TBHeader({ no, sec, en }) {
  return (
    <div style={{ position: 'absolute', left: 120, right: 120, top: 72, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 18, fontSize: 22, fontWeight: 600 }}>
        <span style={{ border: `1px solid ${TB.acc}`, color: TB.acc, padding: '6px 14px', fontFamily: "'JetBrains Mono', monospace", fontSize: 20 }}>{no}</span>
        <span>{sec}</span><span style={{ color: TB.sub, fontWeight: 400, letterSpacing: '0.08em', fontSize: 18 }}>{en}</span>
      </div>
      <MlkLogo w={150} color={TB.ink} />
    </div>
  );
}

function TBCover() {
  return (
    <MlkSlide bg={TB.bg} color={TB.ink}>
      <MlkPhoto src="assets/cover-ai-hand.jpg" pos="20% center" style={{ position: 'absolute', inset: 0, opacity: .55 }} />
      <div style={{ position: 'absolute', inset: 0, background: `linear-gradient(90deg, ${TB.bg} 0%, ${TB.bg}00 70%)` }} />
      <div style={{ position: 'absolute', right: 120, top: 96 }}><MlkLogo w={220} color={TB.ink} /></div>
      <div style={{ position: 'absolute', right: 120, top: 360, textAlign: 'right' }}>
        <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 24, color: TB.acc, letterSpacing: '0.1em' }}>AI MEDICAL PORTAL FOR GANGWON</div>
        <div style={{ fontSize: 120, fontWeight: 800, lineHeight: 1.1, marginTop: 36, letterSpacing: '-0.045em' }}>메디링크 강원</div>
        <div style={{ fontSize: 120, fontWeight: 200, lineHeight: 1.1, letterSpacing: '-0.045em' }}>제품소개서</div>
        <div style={{ fontSize: 34, color: TB.sub, marginTop: 44 }}>강원도민의 건강, 묻고 잇고 찾는 AI 의료 포털</div>
      </div>
      <div style={{ position: 'absolute', left: 120, right: 120, bottom: 80, display: 'flex', justifyContent: 'space-between', fontSize: 22, color: TB.sub,
        borderTop: `1px solid ${TB.line}`, paddingTop: 24 }}>
        <span>강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업 공급기업 서비스</span><span>(주)센텀인터넷</span>
      </div>
    </MlkSlide>
  );
}

function TBProblem() {
  return (
    <MlkSlide bg={TB.bg} color={TB.ink}>
      <TBHeader no="02" sec="해결할 문제" en="PROBLEM" />
      <div style={{ position: 'absolute', left: 120, top: 210, fontSize: 72, fontWeight: 800, lineHeight: 1.2, letterSpacing: '-0.045em' }}>
        의료 정보는 많지만<br/><span style={{ color: TB.acc }}>도민에게는 찾기 어렵다</span>
      </div>
      <div style={{ position: 'absolute', left: 120, right: 120, top: 520, bottom: 110, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 2, background: TB.line }}>
        {MLK.problems.map(([t, d], i) => (
          <div key={i} style={{ background: TB.panel, padding: '48px 40px', display: 'flex', flexDirection: 'column' }}>
            <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 22, color: TB.acc }}>/0{i + 1}</div>
            <div style={{ marginTop: 'auto', fontSize: 36, fontWeight: 700, lineHeight: 1.3 }}>{t}</div>
            <div style={{ fontSize: 24, color: TB.sub, marginTop: 18, lineHeight: 1.6, textWrap: 'pretty' }}>{d}</div>
          </div>
        ))}
      </div>
    </MlkSlide>
  );
}

function TBEmergency() {
  const rows = [['강원대학교병원', '춘천', 7], ['원주세브란스기독병원', '원주', 4], ['강릉아산병원', '강릉', 2]];
  return (
    <MlkSlide bg={TB.bg} color={TB.ink}>
      <TBHeader no="06" sec="응급실 LIVE" en="REAL-TIME ER" />
      <div style={{ position: 'absolute', left: 120, top: 210, width: 760 }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 12, fontSize: 22, fontWeight: 700, color: TB.alert, border: `1px solid ${TB.alert}`, padding: '8px 16px' }}>
          <span style={{ width: 12, height: 12, borderRadius: 6, background: TB.alert }} />LIVE
        </div>
        <div style={{ fontSize: 68, fontWeight: 800, lineHeight: 1.22, marginTop: 32, letterSpacing: '-0.045em' }}>지금 갈 수 있는 곳을<br/>실시간으로 확인한다</div>
        <div style={{ fontSize: 28, color: TB.sub, marginTop: 36, lineHeight: 1.6 }}>국립중앙의료원 공공데이터 실시간 연계로<br/>응급실 병상 가용 현황을 제공합니다.</div>
        <div style={{ display: 'flex', gap: 2, marginTop: 64, background: TB.line }}>
          {MLK.phones.map(([n, l]) => (
            <div key={n} style={{ flex: 1, background: TB.panel, padding: '28px 28px' }}>
              <div style={{ fontSize: 40, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>{n}</div>
              <div style={{ fontSize: 20, color: TB.sub, marginTop: 8 }}>{l}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ position: 'absolute', right: 120, top: 210, width: 820, bottom: 110, background: TB.panel, border: `1px solid ${TB.line}`, padding: 48, display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 22, color: TB.sub, fontFamily: "'JetBrains Mono', monospace" }}>
          <span>ER BED STATUS · 예시 화면</span><span>갱신 14:32</span>
        </div>
        {rows.map(([h, c, n]) => (
          <div key={h} style={{ display: 'flex', alignItems: 'center', borderTop: `1px solid ${TB.line}`, padding: '34px 0', marginTop: h === rows[0][0] ? 32 : 0 }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 32, fontWeight: 700 }}>{h}</div>
              <div style={{ fontSize: 22, color: TB.sub, marginTop: 6 }}>{c}</div>
            </div>
            <div style={{ fontSize: 64, fontWeight: 800, color: n <= 2 ? TB.alert : TB.acc, fontVariantNumeric: 'tabular-nums' }}>{n}</div>
            <div style={{ fontSize: 22, color: TB.sub, marginLeft: 12, width: 50 }}>병상</div>
          </div>
        ))}
        <div style={{ marginTop: 'auto', fontSize: 20, color: TB.sub, lineHeight: 1.6 }}>병상 현황은 수시로 변동됩니다. 이용 전 문의가 필요합니다.</div>
      </div>
    </MlkSlide>
  );
}

Object.assign(window, { TBCover, TBProblem, TBEmergency });
