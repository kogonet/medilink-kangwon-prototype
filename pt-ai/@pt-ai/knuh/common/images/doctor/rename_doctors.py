"""
의사 사진 파일명 정리 스크립트
형식: 진료과-이름.확장자
"""

import os
import re

FOLDER = os.path.dirname(os.path.abspath(__file__))

# 진료과 목록 (긴 것 우선)
DEPT_NAMES = [
    '소아정신건강의학과', '방사선종양학과', '마취통증의학과', '소아흉부외과',
    '류마티스내과', '정신건강의학과', '소화기내과', '비뇨의학과',
    '진단검사의학과', '직업환경의학과', '신경외과', '내분비내과',
    '이비인후과', '가정의학과', '영상의학과', '재활의학과',
    '정형외과', '호흡기내과', '혈액종양내과', '감염내과',
    '흉부외과', '응급의학과', '핵의학과', '신경과',
    '신장내과', '심장내과', '병리과', '산부인과',
    '성형외과', '안과', '외과', '치과',
    '피부과', '마취통증',
]
DEPT_NAMES.sort(key=len, reverse=True)

STOP_WORDS = [
    '홈페이지용', '홈페이지', '교수님', '선생님', '센터장님',
    '교수', '선생', '센터장', '직접제공', '프로필', '사진',
]

def extract_name(s):
    s = s.lstrip('_- ')
    for sw in STOP_WORDS:
        s = s.replace(sw, ' ')
    matches = re.findall(r'[가-힣]+', s)
    for m in matches:
        if 2 <= len(m) <= 4:
            return m
    if matches:
        return matches[0]
    return None

def parse_filename(stem):
    # 진료과가 끝에 있는 경우
    for dept in DEPT_NAMES:
        if stem.endswith(dept):
            remainder = stem[:-len(dept)].rstrip('_- ')
            name = extract_name(remainder)
            if name:
                return dept, name

    # 앞에 숫자 prefix 제거
    stem_clean = re.sub(r'^\d+[_\-\s]+', '', stem)

    # 진료과가 앞에 있는 경우
    for dept in DEPT_NAMES:
        if stem_clean.startswith(dept):
            remainder = stem_clean[len(dept):]
            remainder = remainder.lstrip('_- ')
            name = extract_name(remainder)
            if name:
                return dept, name

    return None, None

def main(dry_run=False):
    files = [f for f in os.listdir(FOLDER)
             if os.path.isfile(os.path.join(FOLDER, f))
             and not f.endswith('.py') and not f.endswith('.bat')]

    rename_map = {}
    failed = []
    conflicts = {}

    for fname in sorted(files):
        stem, ext = os.path.splitext(fname)
        dept, name = parse_filename(stem)
        if dept and name:
            new_name = f"{dept}-{name}{ext}"
            rename_map[fname] = new_name
            conflicts.setdefault(new_name, []).append(fname)
        else:
            failed.append(fname)

    conflict_found = False
    for new_name, old_list in conflicts.items():
        if len(old_list) > 1:
            conflict_found = True
            print(f"[충돌] {new_name} <- {old_list}")

    if conflict_found:
        print("\n충돌이 있습니다. 수동으로 확인 후 다시 실행하세요.")
        input("\nEnter를 눌러 종료...")
        return

    print(f"=== {'미리보기' if dry_run else '실제 변경'} ===\n")
    count = 0
    for old_name, new_name in sorted(rename_map.items()):
        if old_name == new_name:
            continue
        print(f"  {old_name}")
        print(f"  -> {new_name}\n")
        if not dry_run:
            old_path = os.path.join(FOLDER, old_name)
            new_path = os.path.join(FOLDER, new_name)
            if os.path.exists(new_path):
                print(f"  [건너뜀] 이미 존재: {new_name}")
                continue
            os.rename(old_path, new_path)
        count += 1

    print(f"\n{'미리보기' if dry_run else '완료'}: {count}개 파일")

    if failed:
        print(f"\n[처리 불가] {len(failed)}개 파일:")
        for f in failed:
            print(f"  {f}")

    input("\nEnter를 눌러 종료...")

if __name__ == "__main__":
    import sys
    dry = "--dry" in sys.argv or "-n" in sys.argv
    if dry:
        print("** 미리보기 모드 (실제 변경 없음) **\n")
    main(dry_run=dry)
