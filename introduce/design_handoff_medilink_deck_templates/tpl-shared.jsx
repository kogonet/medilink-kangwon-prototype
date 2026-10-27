// Shared content + primitives for template studies
const MLK = {
  problems: [
    ['흩어진 정보', '병원·약국·응급실 정보가 기관별로 흩어져 있어 필요한 정보를 따로 찾아야 합니다.'],
    ['부족한 판단 근거', '증상에서 진료과, 병원 선택까지 이어지는 과정에 판단 근거가 부족합니다.'],
    ['지역마다 다른 이동 여건', '산간·원거리 지역에서는 이동 거리와 응급 대응 여건이 중요한 변수입니다.'],
    ['급할수록 중요한 최신성', '지금 이용할 수 있는 곳을 판단하려면 정확한 최신 정보가 필요합니다.'],
  ],
  phones: [['119', '화재·구조·구급'], ['1339', '응급의료 상담'], ['1577-1000', '보건복지상담센터']],
};

function MlkLogo({ w = 200, color = '#fff' }) {
  const m = 'url(assets/logo.svg) no-repeat left center / contain';
  return <div style={{ width: w, height: w * 48 / 194.6, background: color, WebkitMask: m, mask: m, flex: 'none' }} />;
}

function MlkSlide({ bg, color, font, children, style }) {
  return (
    <div style={{ width: 1920, height: 1080, position: 'relative', overflow: 'hidden', background: bg, color,
      fontFamily: font || "'Pretendard Variable', Pretendard, sans-serif", letterSpacing: '-0.02em', ...style }}>
      {children}
    </div>
  );
}

function MlkPhoto({ src, style, pos = 'center' }) {
  return <div style={{ backgroundImage: `url(${src})`, backgroundSize: 'cover', backgroundPosition: pos, ...style }} />;
}

Object.assign(window, { MLK, MlkLogo, MlkSlide, MlkPhoto });
