const fs = require('fs');
const path = require('path');

const folder = __dirname;

const depts = [
    '소아정신건강의학과','방사선종양학과','마취통증의학과','소아흉부외과',
    '류마티스내과','정신건강의학과','소화기내과','비뇨의학과',
    '진단검사의학과','직업환경의학과','신경외과','내분비내과',
    '이비인후과','가정의학과','영상의학과','재활의학과',
    '정형외과','호흡기내과','혈액종양내과','감염내과',
    '흉부외과','응급의학과','핵의학과','신경과',
    '신장내과','심장내과','병리과','산부인과',
    '성형외과','안과','외과','치과','피부과','마취통증'
].sort((a,b) => b.length - a.length);

const stopWords = ['홈페이지용','홈페이지','교수님','선생님','센터장님','교수','선생','센터장','직접제공','프로필','사진'];

function extractName(s) {
    s = s.replace(/^[_\- ]+/, '');
    for (const sw of stopWords) s = s.split(sw).join(' ');
    const matches = s.match(/[가-힣]+/g) || [];
    for (const m of matches) {
        if (m.length >= 2 && m.length <= 4) return m;
    }
    return matches[0] || null;
}

function parseFilename(stem) {
    // 진료과가 끝에 있는 경우
    for (const dept of depts) {
        if (stem.endsWith(dept)) {
            const remainder = stem.slice(0, -dept.length).replace(/[_\- ]+$/, '');
            const name = extractName(remainder);
            if (name) return [dept, name];
        }
    }
    // 앞 숫자 제거
    const stemClean = stem.replace(/^\d+[_\-\s]+/, '');
    // 진료과가 앞에 있는 경우
    for (const dept of depts) {
        if (stemClean.startsWith(dept)) {
            const remainder = stemClean.slice(dept.length).replace(/^[_\- ]+/, '');
            const name = extractName(remainder);
            if (name) return [dept, name];
        }
    }
    return [null, null];
}

const imageExts = new Set(['.jpg','.jpeg','.png','.gif','.bmp','.webp']);
const files = fs.readdirSync(folder).filter(f => {
    const ext = path.extname(f).toLowerCase();
    return imageExts.has(ext) && fs.statSync(path.join(folder, f)).isFile();
});

let count = 0;
const failed = [];

for (const fname of files.sort()) {
    const ext = path.extname(fname);
    const stem = path.basename(fname, ext);
    const [dept, name] = parseFilename(stem);
    if (dept && name) {
        const newName = `${dept}-${name}${ext}`;
        if (newName === fname) continue;
        const newPath = path.join(folder, newName);
        if (fs.existsSync(newPath)) {
            console.log(`[건너뜀] 이미 존재: ${newName}`);
            continue;
        }
        console.log(`${fname}\n  -> ${newName}`);
        fs.renameSync(path.join(folder, fname), newPath);
        count++;
    } else {
        failed.push(fname);
    }
}

console.log(`\n완료: ${count}개 파일 변경`);
if (failed.length > 0) {
    console.log(`\n[처리 불가] ${failed.length}개:`);
    failed.forEach(f => console.log(`  ${f}`));
}
