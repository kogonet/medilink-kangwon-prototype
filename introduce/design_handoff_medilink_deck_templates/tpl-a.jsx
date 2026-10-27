// Template A — Clinical Grid (white, navy ink, single medical-blue accent)
const TA = { ink: '#0B1B3A', sub: '#5A6478', line: '#D9DEE7', acc: '#1F5EFF', bg: '#FFFFFF', soft: '#F3F5F9', red: '#E5372B' };

function TAHeader({ no, sec }) {
  return (
    <div style={{ position: 'absolute', left: 120, right: 120, top: 72, display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      fontSize: 22, fontWeight: 600, color: TA.sub, letterSpacing: '0.02em' }}>
      <div style={{ display: 'flex', gap: 20, alignItems: 'center' }}>
        <span style={{ color: TA.acc, fontVariantNumeric: 'tabular-nums' }}>{no}</span>
        <span style={{ width: 40, height: 2, background: TA.ink }} />
        <span style={{ color: TA.ink }}>{sec}</span>
      </div>
      <MlkLogo w={150} color={TA.ink} />
    </div>
  );
}
function TAFooter({ p }) {
  return (
    <div style={{ position: 'absolute', left: 120, right: 120, bottom: 56, display: 'flex', justifyContent: 'space-between',
      borderTop: `1px solid ${TA.line}`, paddingTop: 20, fontSize: 20, color: TA.sub }}>
      <span>메디링크 강원 제품소개서</span><span style={{ fontVariantNumeric: 'tabular-nums' }}>{p}</span>
    </div>
  );
}

function TACover() {
  return (
    <MlkSlide bg={TA.bg} color={TA.ink}>
      <MlkPhoto src="assets/cover-ai-hand.jpg" pos="30% center" style={{ position: 'absolute', right: 0, top: 0, width: 760, height: 1080 }} />
      <div style={{ position: 'absolute', left: 120, top: 96 }}><MlkLogo w={220} color={TA.ink} /></div>
      <div style={{ position: 'absolute', left: 120, top: 330, width: 960 }}>
        <div style={{ fontSize: 26, fontWeight: 700, color: TA.acc, letterSpacing: '0.12em' }}>AI MEDICAL PORTAL FOR GANGWON</div>
        <div style={{ fontSize: 112, fontWeight: 800, lineHeight: 1.12, marginTop: 36, letterSpacing: '-0.04em' }}>메디링크 강원<br/>제품소개서</div>
        <div style={{ fontSize: 38, fontWeight: 500, color: TA.sub, marginTop: 48, lineHeight: 1.5 }}>강원도민의 건강, 묻고 잇고 찾는 AI 의료 포털</div>
      </div>
      <div style={{ position: 'absolute', left: 120, bottom: 96, width: 920, display: 'flex', justifyContent: 'space-between',
        borderTop: `2px solid ${TA.ink}`, paddingTop: 24, fontSize: 22, color: TA.sub }}>
        <span>강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업</span><span>(주)센텀인터넷</span>
      </div>
    </MlkSlide>
  );
}

function TAProblem() {
  return (
    <MlkSlide bg={TA.bg} color={TA.ink}>
      <TAHeader no="02" sec="해결할 문제" />
      <div style={{ position: 'absolute', left: 120, top: 200, width: 1680, display: 'grid', gridTemplateColumns: '600px 1fr', gap: 120 }}>
        <div>
          <div style={{ fontSize: 68, fontWeight: 800, lineHeight: 1.25, letterSpacing: '-0.04em' }}>의료 정보는 많지만<br/><span style={{ color: TA.acc }}>도민에게는</span><br/>찾기 어렵다</div>
          <div style={{ fontSize: 28, color: TA.sub, marginTop: 40, lineHeight: 1.6 }}>정보는 기관별로 흩어져 있고,<br/>선택의 근거와 최신성은 부족합니다.</div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', borderTop: `2px solid ${TA.ink}` }}>
          {MLK.problems.map(([t, d], i) => (
            <div key={i} style={{ padding: '44px 40px 48px 0', borderBottom: `1px solid ${TA.line}`, paddingLeft: i % 2 ? 40 : 0,
              borderLeft: i % 2 ? `1px solid ${TA.line}` : 'none', minHeight: 300 }}>
              <div style={{ fontSize: 30, fontWeight: 700, color: TA.acc, fontVariantNumeric: 'tabular-nums' }}>0{i + 1}</div>
              <div style={{ fontSize: 38, fontWeight: 700, marginTop: 28 }}>{t}</div>
              <div style={{ fontSize: 26, color: TA.sub, marginTop: 18, lineHeight: 1.6, textWrap: 'pretty' }}>{d}</div>
            </div>
          ))}
        </div>
      </div>
      <TAFooter p="03" />
    </MlkSlide>
  );
}

function TAEmergency() {
  return (
    <MlkSlide bg={TA.bg} color={TA.ink}>
      <TAHeader no="06" sec="응급실 LIVE" />
      <div style={{ position: 'absolute', left: 120, top: 200, fontSize: 68, fontWeight: 800, lineHeight: 1.25, letterSpacing: '-0.04em' }}>
        지금 갈 수 있는 응급실을<br/>실시간으로 확인한다
      </div>
      <div style={{ position: 'absolute', left: 120, top: 460, width: 1680, height: 480, display: 'grid', gridTemplateColumns: '1fr 1fr 560px', gap: 40 }}>
        <MlkPhoto src="assets/ambulance.jpeg" style={{ gridColumn: 'span 1' }} />
        <div style={{ background: TA.soft, padding: 48, display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, fontSize: 24, fontWeight: 700, color: TA.red }}>
            <span style={{ width: 14, height: 14, borderRadius: 7, background: TA.red }} />LIVE 연계
          </div>
          <div style={{ fontSize: 36, fontWeight: 700, marginTop: 28, lineHeight: 1.4 }}>국립중앙의료원 공공데이터 실시간 연계</div>
          <div style={{ fontSize: 26, color: TA.sub, marginTop: 20, lineHeight: 1.6 }}>응급실 병상 가용 현황을 제공합니다.</div>
          <div style={{ marginTop: 'auto', fontSize: 22, color: TA.sub, lineHeight: 1.6, borderTop: `1px solid ${TA.line}`, paddingTop: 20 }}>
            병상 현황은 수시로 변동되므로 이용 전 문의가 필요합니다.
          </div>
        </div>
        <div style={{ background: TA.ink, color: '#fff', padding: 48, display: 'flex', flexDirection: 'column' }}>
          <div style={{ fontSize: 24, fontWeight: 600, opacity: .7 }}>빠른 전화 연결</div>
          <div style={{ marginTop: 'auto' }}>
            {MLK.phones.map(([n, l]) => (
              <div key={n} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', borderTop: '1px solid rgba(255,255,255,.2)', padding: '18px 0' }}>
                <span style={{ fontSize: 52, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>{n}</span>
                <span style={{ fontSize: 22, opacity: .7 }}>{l}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
      <TAFooter p="07" />
    </MlkSlide>
  );
}

Object.assign(window, { TACover, TAProblem, TAEmergency });
