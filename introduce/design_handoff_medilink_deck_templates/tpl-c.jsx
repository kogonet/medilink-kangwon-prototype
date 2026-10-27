// Template C — Gangwon Care (warm paper, deep forest green, photo-led, humane)
const TC = { bg: '#F5F2EC', ink: '#13261F', sub: '#5F6B64', line: '#D8D2C6', acc: '#1E5B47', mint: '#CFE6D8', warm: '#E8E1D3', alert: '#C8452F' };
const TCserif = "'Noto Serif KR', serif";

function TCHeader({ sec }) {
  return (
    <div style={{ position: 'absolute', left: 120, right: 120, top: 72, display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: 22, color: TC.sub }}>
      <span style={{ fontWeight: 600, color: TC.acc }}>{sec}</span>
      <MlkLogo w={150} color={TC.acc} />
    </div>
  );
}

function TCCover() {
  return (
    <MlkSlide bg={TC.bg} color={TC.ink}>
      <MlkPhoto src="assets/senior-phone.jpeg" pos="center 30%" style={{ position: 'absolute', left: 0, top: 0, width: 860, height: 1080 }} />
      <div style={{ position: 'absolute', left: 980, top: 96 }}><MlkLogo w={220} color={TC.acc} /></div>
      <div style={{ position: 'absolute', left: 980, top: 340, width: 820 }}>
        <div style={{ fontSize: 24, fontWeight: 600, color: TC.acc, letterSpacing: '0.1em' }}>AI MEDICAL PORTAL FOR GANGWON</div>
        <div style={{ fontFamily: TCserif, fontSize: 80, fontWeight: 600, lineHeight: 1.3, marginTop: 40, letterSpacing: '-0.03em' }}>강원도민의 건강,<br/>묻고 잇고 찾는<br/>AI 의료 포털</div>
        <div style={{ fontSize: 36, fontWeight: 700, marginTop: 48 }}>메디링크 강원 제품소개서</div>
      </div>
      <div style={{ position: 'absolute', left: 980, right: 120, bottom: 96, fontSize: 22, color: TC.sub, lineHeight: 1.6, borderTop: `1px solid ${TC.line}`, paddingTop: 24 }}>
        강원 바이오·헬스케어 AI 대전환(AX) 실증기업 지원사업 공급기업 서비스 · (주)센텀인터넷
      </div>
    </MlkSlide>
  );
}

function TCProblem() {
  return (
    <MlkSlide bg={TC.bg} color={TC.ink}>
      <TCHeader sec="해결할 문제" />
      <div style={{ position: 'absolute', left: 120, top: 200, fontFamily: TCserif, fontSize: 68, fontWeight: 600, lineHeight: 1.35, letterSpacing: '-0.03em' }}>
        의료 정보는 많지만, 도민에게는 찾기 어렵다
      </div>
      <div style={{ position: 'absolute', left: 120, right: 120, top: 400, bottom: 110, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 32 }}>
        {MLK.problems.map(([t, d], i) => (
          <div key={i} style={{ background: i === 2 ? TC.acc : '#fff', color: i === 2 ? '#fff' : TC.ink, borderRadius: 24, padding: '48px 40px', display: 'flex', flexDirection: 'column' }}>
            <div style={{ fontFamily: TCserif, fontSize: 80, fontWeight: 600, lineHeight: 1, color: i === 2 ? TC.mint : TC.acc }}>{i + 1}</div>
            <div style={{ marginTop: 'auto', fontSize: 36, fontWeight: 700, lineHeight: 1.3 }}>{t}</div>
            <div style={{ fontSize: 25, marginTop: 18, lineHeight: 1.65, opacity: i === 2 ? .85 : 1, color: i === 2 ? '#fff' : TC.sub, textWrap: 'pretty' }}>{d}</div>
          </div>
        ))}
      </div>
    </MlkSlide>
  );
}

function TCEmergency() {
  return (
    <MlkSlide bg={TC.bg} color={TC.ink}>
      <MlkPhoto src="assets/ambulance.jpeg" style={{ position: 'absolute', right: 0, top: 0, width: 800, height: 1080 }} />
      <TCHeader sec="응급실 LIVE" />
      <div style={{ position: 'absolute', left: 120, top: 200, width: 880 }}>
        <div style={{ fontFamily: TCserif, fontSize: 68, fontWeight: 600, lineHeight: 1.35, letterSpacing: '-0.03em' }}>지금 갈 수 있는 곳을<br/>먼저 확인합니다</div>
        <div style={{ fontSize: 28, color: TC.sub, marginTop: 36, lineHeight: 1.65 }}>국립중앙의료원 공공데이터와 실시간 연계해<br/>응급실 병상 가용 현황을 제공합니다.</div>
        <div style={{ marginTop: 72, display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 20 }}>
          {MLK.phones.map(([n, l], i) => (
            <div key={n} style={{ background: i === 0 ? TC.alert : '#fff', color: i === 0 ? '#fff' : TC.ink, borderRadius: 20, padding: '32px 28px' }}>
              <div style={{ fontSize: 44, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>{n}</div>
              <div style={{ fontSize: 21, marginTop: 8, opacity: .8 }}>{l}</div>
            </div>
          ))}
        </div>
        <div style={{ marginTop: 56, fontSize: 22, color: TC.sub, borderTop: `1px solid ${TC.line}`, paddingTop: 24, lineHeight: 1.6 }}>
          병상 현황은 수시로 변동됩니다. 표시 정보를 확인하고 이용 전 문의가 필요합니다.
        </div>
      </div>
    </MlkSlide>
  );
}

Object.assign(window, { TCCover, TCProblem, TCEmergency });
