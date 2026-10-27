const regions = [
  { name: '춘천시', children: ['신북읍','동면','동산면','신동면','동내면','남면','남산면','서면','사북면','북산면','소양동','교동','조운동','약사명동','근화동','후평1동','후평2동','후평3동','효자1동','효자2동','효자3동','석사동','퇴계동','강남동','신사우동'] },
  { name: '원주시', children: ['문막읍','소초면','호저면','지정면','부론면','귀래면','흥업면','판부면','신림면','중앙동','원인동','개운동','명륜1동','명륜2동','단구동','일산동','학성동','단계동','우산동','태장1동','태장2동','봉산동','행구동','무실동','반곡관설동'] },
  { name: '강릉시', children: ['주문진읍','성산면','왕산면','구정면','강동면','옥계면','사천면','연곡면','홍제동','중앙동','옥천동','교1동','교2동','포남1동','포남2동','초당동','송정동','내곡동','강남동','성덕동','경포동'] },
  { name: '동해시', children: ['천곡동','송정동','북삼동','부곡동','동호동','발한동','묵호동','북평동','망상동','삼화동'] },
  { name: '태백시', children: ['황지동','황연동','삼수동','상장동','문곡소도동','장성동','구문소동','철암동'] },
  { name: '속초시', children: ['영랑동','동명동','금호동','교동','노학동','조양동','청호동','대포동'] },
  { name: '삼척시', children: ['도계읍','원덕읍','근덕면','하장면','노곡면','미로면','가곡면','신기면','남양동','성내동','교동','정라동'] },
  { name: '홍천군', children: ['홍천읍','화촌면','두촌면','내촌면','서석면','영귀미면','남면','서면','북방면','내면'] },
  { name: '횡성군', children: ['횡성읍','우천면','안흥면','둔내면','갑천면','청일면','공근면','서원면','강림면'] },
  { name: '영월군', children: ['영월읍','상동읍','산솔면','김삿갓면','북면','남면','한반도면','주천면','무릉도원면'] },
  { name: '평창군', children: ['평창읍','미탄면','방림면','대화면','봉평면','용평면','진부면','대관령면'] },
  { name: '정선군', children: ['정선읍','고한읍','사북읍','신동읍','화암면','남면','여량면','북평면','임계면'] },
  { name: '철원군', children: ['철원읍','김화읍','갈말읍','동송읍','서면','근남면'] },
  { name: '화천군', children: ['화천읍','간동면','하남면','상서면','사내면'] },
  { name: '양구군', children: ['양구읍','국토정중앙면','동면','방산면','해안면'] },
  { name: '인제군', children: ['인제읍','남면','북면','기린면','서화면','상남면'] },
  { name: '고성군', children: ['간성읍','거진읍','현내면','죽왕면','토성면'] },
  { name: '양양군', children: ['양양읍','서면','손양면','현북면','현남면','강현면'] }
];

const departments = ['내과','외과','정형외과','신경외과','신경과','소아청소년과','산부인과','비뇨의학과','안과','이비인후과','피부과','정신건강의학과','재활의학과','마취통증의학과','영상의학과','가정의학과','응급의학과','치과','한방','기타'];

const symptoms = [
  { name: '가려움증', category: '건강문제' }, { name: '간기능검사', category: '검사방법' },
  { name: '감기', category: '건강문제' }, { name: '갑상선검사', category: '검사방법' },
  { name: '건강검진(암 검진)', category: '검사방법' }, { name: '겨울철 저체온증 예방요령', category: '생활습관 관리' },
  { name: '고혈압', category: '건강문제' }, { name: '기침', category: '건강문제' },
  { name: '당뇨', category: '건강문제' }, { name: '두통', category: '건강문제' },
  { name: '발열', category: '건강문제' }, { name: '변비', category: '건강문제' },
  { name: '사전연명의료결정', category: '치료방법' }, { name: '소화불량', category: '건강문제' },
  { name: '액상형 전자담배', category: '생활습관 관리' }, { name: '어지럼증', category: '건강문제' },
  { name: '우울증', category: '건강문제' }, { name: '위염', category: '건강문제' },
  { name: '장기요양등급결정과 이용', category: '치료방법' }, { name: '장염', category: '건강문제' },
  { name: '재택의료/방문진료', category: '치료방법' }, { name: '중이염', category: '건강문제' },
  { name: '치통', category: '건강문제' }, { name: '통풍', category: '건강문제' },
  { name: '퇴행슬관절염', category: '건강문제' }, { name: '폐렴', category: '건강문제' },
  { name: '피부발진', category: '건강문제' }, { name: '허리디스크', category: '건강문제' }
];

const selected = { region: '', symptom: '', department: '' };
let openPanel = '';
let regionParent = '';
let symptomCategory = '전체';
let symptomQuery = '';

/* ====================== 공통 드롭다운 ====================== */
function escapeAttribute(value) {
  return value.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}

function closePanels() {
  document.querySelectorAll('.option_panel').forEach(panel => { panel.hidden = true; });
  document.querySelectorAll('.option_btn').forEach(button => {
    button.classList.remove('is_open');
    button.setAttribute('aria-expanded', 'false');
  });
  openPanel = '';
}

function togglePanel(type) {
  const panel = document.getElementById(`${type}_panel`);
  const button = document.getElementById(`${type}_btn`);
  const willOpen = openPanel !== type;
  closePanels();
  if (!willOpen) return;
  openPanel = type;
  panel.hidden = false;
  button.classList.add('is_open');
  button.setAttribute('aria-expanded', 'true');
}

/* 2026-09-30 선택 즉시 AI 상담으로 질문 전송 (태그로 담아두지 않음) */
function selectOption(type, value) {
  const queries = {
    region: `${value.startsWith('강원') ? value : `강원도 ${value}`} 병원 알려줘`,
    symptom: `${value}에 대해 알려줘`,
    department: `${value} 진료 병원 목록을 보여줘`
  };
  closePanels();
  location.href = '/gwtpax/ai-consult.do?q=' + encodeURIComponent(queries[type]);
}

function renderTags() {
  const labels = { region: '지역', symptom: '증상', department: '진료과' };
  const target = document.getElementById('selected_tags');
  target.innerHTML = Object.entries(selected).filter(([, value]) => value).map(([type, value]) =>
    `<span class="selected_tag"><b>${labels[type]}</b>${value}<button type="button" data-remove="${type}" aria-label="${value} 삭제">×</button></span>`
  ).join('');
}

/* ====================== 지역 드롭다운 ====================== */
function renderRegions() {
  const panel = document.getElementById('region_panel');
  if (!regionParent) {
    const cities = regions.filter(region => region.name.endsWith('시'));
    const counties = regions.filter(region => region.name.endsWith('군'));
    panel.innerHTML = `
      <div class="panel_head"><strong>지역별 검색</strong><span>시·군을 먼저 선택하세요</span></div>
      <button class="panel_all" type="button" data-region="강원특별자치도 전체">강원특별자치도 전체</button>
      <p class="panel_label">시</p>
      <div class="panel_grid">${cities.map(region => `<button class="panel_item" type="button" data-parent="${region.name}">${region.name}</button>`).join('')}</div>
      <p class="panel_label">군</p>
      <div class="panel_grid">${counties.map(region => `<button class="panel_item" type="button" data-parent="${region.name}">${region.name}</button>`).join('')}</div>`;
    return;
  }
  const current = regions.find(region => region.name === regionParent);
  panel.innerHTML = `
    <div class="panel_head panel_back"><button type="button" data-back>← 시·군 선택</button><strong>${regionParent}</strong></div>
    <button class="panel_all" type="button" data-region="${regionParent}">${regionParent} 전체</button>
    <p class="panel_label">읍·면·동</p>
    <div class="panel_grid emd_grid">${current.children.map(child => `<button class="panel_item" type="button" data-region="${regionParent} ${child}">${child}</button>`).join('')}</div>`;
}

/* ====================== 증상 드롭다운 ====================== */
function renderSymptoms() {
  const panel = document.getElementById('symptom_panel');
  const categories = ['전체','건강문제','치료방법','검사방법','생활습관 관리'];
  const items = symptoms.filter(item => {
    const matchedCategory = symptomCategory === '전체' || item.category === symptomCategory;
    const matchedQuery = item.name.includes(symptomQuery.trim());
    return matchedCategory && matchedQuery;
  });
  panel.innerHTML = `
    <div class="panel_head"><strong>증상별 검색</strong><span>총 ${items.length}건</span></div>
    <label class="panel_search"><span class="hidden_text">증상명 검색</span><input id="symptom_query" type="search" placeholder="증상명을 입력하세요" value="${escapeAttribute(symptomQuery)}"></label>
    <div class="category_list">${categories.map(category => `<button class="category_btn${symptomCategory === category ? ' is_active' : ''}" type="button" data-category="${category}">${category}</button>`).join('')}</div>
    <div class="symptom_list">${items.length ? items.map(item => `<button class="symptom_item" type="button" data-symptom="${item.name}"><span>${item.name}</span><small>${item.category}</small></button>`).join('') : '<p class="panel_empty">일치하는 증상이 없습니다.</p>'}</div>`;
}

/* ====================== 진료과 드롭다운 ====================== */
function renderDepartments() {
  const panel = document.getElementById('department_panel');
  panel.innerHTML = `
    <div class="panel_head"><strong>진료과별 검색</strong><span>진료과를 선택하세요</span></div>
    <div class="department_grid">${departments.map(department => `<button class="panel_item" type="button" data-department="${department}">${department}</button>`).join('')}</div>`;
}

/* ====================== 이벤트 ====================== */
document.getElementById('region_btn').addEventListener('click', () => togglePanel('region'));
document.getElementById('symptom_btn').addEventListener('click', () => togglePanel('symptom'));
document.getElementById('department_btn').addEventListener('click', () => togglePanel('department'));

document.getElementById('region_panel').addEventListener('click', event => {
  event.stopPropagation();
  const parent = event.target.closest('[data-parent]');
  const region = event.target.closest('[data-region]');
  if (event.target.closest('[data-back]')) {
    regionParent = '';
    renderRegions();
  } else if (parent) {
    regionParent = parent.dataset.parent;
    renderRegions();
    openPanel = 'region';
    document.getElementById('region_panel').hidden = false;
    document.getElementById('region_btn').classList.add('is_open');
    document.getElementById('region_btn').setAttribute('aria-expanded', 'true');
  } else if (region) {
    selectOption('region', region.dataset.region);
  }
});

document.getElementById('symptom_panel').addEventListener('input', event => {
  event.stopPropagation();
  if (event.target.id !== 'symptom_query') return;
  symptomQuery = event.target.value;
  renderSymptoms();
  const input = document.getElementById('symptom_query');
  input.focus();
  input.setSelectionRange(input.value.length, input.value.length);
});

document.getElementById('symptom_panel').addEventListener('click', event => {
  event.stopPropagation();
  const category = event.target.closest('[data-category]');
  const symptom = event.target.closest('[data-symptom]');
  if (category) {
    symptomCategory = category.dataset.category;
    renderSymptoms();
  } else if (symptom) {
    selectOption('symptom', symptom.dataset.symptom);
  }
});

document.getElementById('department_panel').addEventListener('click', event => {
  event.stopPropagation();
  const department = event.target.closest('[data-department]');
  if (department) selectOption('department', department.dataset.department);
});

document.getElementById('selected_tags').addEventListener('click', event => {
  const button = event.target.closest('[data-remove]');
  if (!button) return;
  selected[button.dataset.remove] = '';
  renderTags();
});

/* ====================== AI 검색 (기존 index.jsp doAISearch 이관) ====================== */
function buildSearchQuery() {
  const text = document.getElementById('medical_search').value.trim();
  const region = selected.region ? (selected.region.startsWith('강원') ? selected.region : `강원도 ${selected.region}`) : '';
  const condition = [region, selected.department, selected.symptom].filter(Boolean).join(' ');
  if (text) return condition ? `${condition} ${text}` : text;
  if (!condition) return '';
  if (selected.symptom && !selected.department) return `${condition} 증상일 때 갈 수 있는 병원 알려줘`;
  return `${condition} 병원 알려줘`;
}

document.querySelector('.search_form').addEventListener('submit', event => {
  event.preventDefault();
  const query = buildSearchQuery();
  if (!query) {
    searchInput.focus();
    return;
  }
  location.href = '/gwtpax/ai-consult.do?q=' + encodeURIComponent(query);
});

/* ?q= 로 진입하면 검색창에 채워둠 */
(function fillQueryParam() {
  const q = new URLSearchParams(location.search).get('q');
  if (!q) return;
  const input = document.getElementById('medical_search');
  input.value = q;
  input.focus();
})();
document.addEventListener('click', event => {
  if (!event.target.closest('.option_wrap')) closePanels();
});
document.addEventListener('keydown', event => {
  if (event.key === 'Escape') closePanels();
});

/* ====================== 검색 예시 애니메이션 ====================== */
const searchExamples = [
  '허리 통증이 있을 땐 어떤 과를 가야 해?',
  '춘천에서 지금 진료 가능한 소아과는?',
  '원주에서 야간에 문 여는 약국은?',
  '가까운 응급실 병상 현황을 알려줘'
];
const searchInput = document.getElementById('medical_search');
let exampleIndex = 0;
let characterIndex = 0;
let isDeleting = false;

function animatePlaceholder() {
  if (document.activeElement === searchInput || searchInput.value) {
    window.setTimeout(animatePlaceholder, 300);
    return;
  }
  const example = searchExamples[exampleIndex];
  searchInput.placeholder = `${example.slice(0, characterIndex)}│`;
  if (!isDeleting && characterIndex < example.length) {
    characterIndex += 1;
    window.setTimeout(animatePlaceholder, 75);
    return;
  }
  if (!isDeleting) {
    isDeleting = true;
    window.setTimeout(animatePlaceholder, 1600);
    return;
  }
  if (characterIndex > 0) {
    characterIndex -= 1;
    window.setTimeout(animatePlaceholder, 35);
    return;
  }
  isDeleting = false;
  exampleIndex = (exampleIndex + 1) % searchExamples.length;
  window.setTimeout(animatePlaceholder, 350);
}

if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  searchInput.placeholder = searchExamples[0];
} else {
  searchInput.placeholder = '│';
  window.setTimeout(animatePlaceholder, 500);
}

renderRegions();
renderSymptoms();
renderDepartments();
