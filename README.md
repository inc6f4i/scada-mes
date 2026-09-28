# TEAM 2 MES

학습용 제조 실행 시스템입니다. OPC UA 설비 태그를 MySQL에 저장하고, SCADA 주문과 MES 주문·제품 추적을 연결합니다.

## 주요 기능

- 로봇·비전·주문·라인의 OPC UA 태그 수집과 이력 저장
- 작업자·관리자 GUI, 공정테스트/생산 모드별 기록
- 주문번호와 제품 추적번호 생성
- 램프·시트 NG 시 동일 부품 1개 재공급 및 재검사
- 밴의 시트 2개 독립 검사·조립
- 최종 NG 시 다음 예정 제품 뒤에 우선 재생산 배치
- 최종검사 OK 시 기본승인과 한글 PDF 발행
- SCADA 기존 주문 TEST 가져오기, 신규 주문 GUI 모드 적용, 중복 방지
- 32비트 MySQL ODBC 5.3 Unicode 연결용 스크립트

## 구성

```text
team2-mes/
├── README.md
├── requirements.txt
├── setup.cmd / setup.ps1
├── init-db.ps1
├── start.cmd / stop.cmd
├── docs/
│   └── SCADA_MES_INTEGRATION.md
└── manufacturing/
    ├── collector.py
    ├── schema.sql
    ├── queries.sql
    ├── config.example.json
    ├── mysql-client.example.ini
    ├── register-dsn.ps1
    └── mes/
        ├── app.py
        ├── scada_sync.py
        ├── index.html
        ├── app.js
        ├── style.css
        ├── schema.sql
        ├── scada-source.example.json
        ├── scada-client.example.ini
        └── web-config.example.json
```

## 실행 환경

- Windows, Python 3.11 이상 권장 (개발 PC에서는 Python 3.14 사용)
- MySQL 8.4 서버: SQL 스키마에는 JSON 및 윈도 함수 사용
- MES CLI: MySQL Workbench 6.3 CE에 포함된 `mysql.exe`
- 원본 SCADA CLI: `caching_sha2_password` 인증을 지원하는 최신 MySQL CLI
- OPC UA: 익명 접속, Security None
- 선택 사항: 32비트 MySQL ODBC 5.3 Unicode Driver

MySQL 서버·ODBC 드라이버·Workbench·DB 데이터는 저장소에 포함하지 않습니다.

## 설치

1. MySQL 서버와 필요한 CLI를 준비합니다.
2. `setup.cmd`를 실행합니다. 가상환경·Python 의존성을 설치하고 로컬 설정 예제를 복사합니다.
3. 아래 파일을 PC 환경에 맞게 수정합니다. 실제 설정 파일은 Git에서 제외됩니다.

| 로컬 설정 파일 | 설정 내용 |
|---|---|
| `manufacturing/config.json` | OPC UA 주소, MES용 CLI 경로 |
| `manufacturing/mysql-client.ini` | MES MySQL 접속 계정 |
| `manufacturing/mes/scada-source.json` | 원본 DB 수집 활성화, 최신 CLI 경로 |
| `manufacturing/mes/scada-client.ini` | 원본 읽기 계정 접속 정보 |
| `manufacturing/mes/web-config.json` | GUI 수신 주소, 접속 허용 PC, 요청 Origin |

4. MES DB 생성 권한이 있는 계정으로 `manufacturing/mysql-client.ini`를 설정하고 실행합니다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\init-db.ps1
```

5. `start.cmd`를 실행하고 `http://127.0.0.1:8765`에 접속합니다.
6. GUI와 수집기를 종료하려면 `stop.cmd`를 실행합니다. MySQL 서버는 종료하지 않습니다.

이 저장소의 실행 스크립트는 기존 운영 폴더 및 Codex 런타임 경로에 의존하지 않습니다. Python 가상환경은 저장소의 `.venv`를 사용합니다. PDF 한글 폰트는 Windows 맑은 고딕을 사용합니다.

## SCADA 원본 연결

예제 원본은 `10.10.24.170:3306 / smart_factory`입니다. 접속 계정에는 원본 DB의 SELECT 권한이 필요합니다.
`scada-client.ini`에 로컬 접속 정보를 설정하고 `scada-source.json`의 `enabled`를 `true`로 변경합니다. 최초 연결 당시 존재한 주문은 TEST, 이후 신규 주문은 GUI 모드로 등록합니다.

최초 가져오기 경계는 런타임 설정에 기록합니다. 이미 연결한 주문은 GUI 모드를 바꿔도 다시 등록하지 않습니다. 가져오기 전 원본 DB와 제품 옵션 규칙을 확인하세요.

구현과 실제 개발 환경 검증 결과는 [SCADA 연동 기록](docs/SCADA_MES_INTEGRATION.md)을 참고하세요. 해당 기록의 104건은 개발 PC에서 수행한 검증 결과이며 이 저장소에 실제 주문 데이터가 포함되어 있다는 뜻이 아닙니다.

## 원격 GUI

기본 설정은 로컬 PC 접속입니다. 기존 실습 환경에서는 서버 `10.10.24.174`, 클라이언트 `10.10.24.170`을 사용했습니다.
원격 접속 시 `web-config.json`의 수신 주소·허용 클라이언트·허용 Origin을 해당 환경으로 설정하고, GUI 포트 8765의 방화벽 규칙을 적용합니다.
MySQL 3306 포트를 GUI 접속 때문에 개방할 필요는 없습니다.

## 현재 연동 범위

SCADA 주문·결과 읽기는 구현되어 있습니다. SCADA 큐 쓰기와 PLC 주문 전송은 자동 실행하지 않으며 연결 정보·START/ACK 정의가 필요합니다.
제품별 설비 신호 자동 대응이 확정되기 전 공정 완료·재고는 작업자 확인으로 기록합니다. ERP 보고서 전송은 대기 기록으로 남깁니다.

## Git 업로드

업로드 전용 저장소입니다. 계정 비밀번호, 실제 설정, 주문 데이터, 로그, PDF, DB 파일, 가상환경은 `.gitignore`로 제외합니다. 실제 비밀번호는 `.example` 파일에도 넣지 마세요.

원격 저장소가 설정되어 첫 커밋이 만들어진 뒤 업로드합니다.

```powershell
git push
```

원격 설정은 저장소 소유자가 제공한 URL을 사용합니다. GitHub 인증은 PC의 기존 Git 자격 증명 관리자를 사용합니다.
