# iOS Architecture Evolution

동일한 요구사항을 가진 앱의 구조를 MVC부터 Modular + Clean Architecture까지 점진적으로 개선하며, 각 아키텍처의 도입 배경과 트레이드오프를 기록하는 프로젝트입니다.

## 프로젝트 개요
단순히 여러 아키텍처의 패턴을 나열하는 것이 아닌, 앱이 확장되면서 발생하는 **강한 결합(Tight Coupling)**과 **유지보수의 한계**를 직접 마주하고 이를 해결해 나가는 과정을 코드로 증명합니다. 

## 로드맵 (Evolution Roadmap)

본 프로젝트는 아래의 단계를 거치며, 각 Phase는 별도의 브랜치 및 폴더를 통해 히스토리가 관리됩니다.

### Phase 1: MVC (Massive View Controller)
* **Architecture:** MVC 
* **UI:** Storyboard + UIKit
* **API Key:** `Secrets.swift` + `.gitignore`
  - 방식: Swift 파일 내부에 Key를 `static let`으로 하드 코딩하고, 해당 파일을 `.gitignore`에서 제거합니다.
  - 의도: 코드의 강한 결합을 유발하는 `MVC`의 특성을 살려, `ViewController`가 API Key를 직접 가져다 쓰는 가장 단순한 방식을 사용합니다.
* **목표:** 스토리보드로 화면을 구성하고, 네트워크 통신, 데이터 파싱, UI 업데이트 등 모든 로직을 `ViewController`에 집중시켜 구현합니다.
* **이유:** 코드의 강한 겹합을 유발하는 `MVC`의 특징을 살려 `ViewController`가 비대해지는 `Massive VC`와 유지보수의 한계를 의도적으로 재현하고 체감하기 위해서 입니다.
* **다음 단계:** 로직이 엉켜 단위 테스트가 불가능해지는 문제를 해결하기 위해, 비즈니스 로직과 상태 관리를 전담할 `ViewModel`을 분리하는 `MVVM` 패턴으로 넘어갑니다.

### Phase 2: MVVM
* **Architecture:** MVVM
* **UI:** Programmatic UIKit
* **API Key:** `.xcconfig` + `Info.plist`
  - 방식: API Key를 Swift 코드에서 완전히 분리하여 `.xcconfig`로 분리하고 이를 `Info.plist`를 거쳐 접근하도록 개선합니다.
  - 의도: 뷰와 로직이 분리되는 `MVVM`의 도입에 맞춰, 코드와 설정도 물리적으로 분리합니다.
* **목표:** `Storyboard`를 제거하고 코드로 UI를 구성합니다. 비즈니스 로직(`ViewModel`)과 뷰(`View`)를 분리하여 역할의 경계를 명확히 합니다.
* **이유:** 협업시에 발생하는 `Storyboard` 병합 충돌을 방지하고, `ViewController`는 UI를 그리는데에만 집중하게 만들어 코드의 가독성과 테스트 가능성을 확보하기 위해서 입니다.
* **다음 단계:** 로직은 분리되었으나 화면 이동에 대한 코드가 여전히 `ViewController`에 남아있어 이를 제거하고 외부 통신 의존성을 끊어낼 `Clean Architecture`와 `Coordinator`패턴 도입이 필요해 집니다.

### Phase 3: Clean Architecture + Coordinator
* **Architecture:** MVVM-C + Clean Architecture
* **API Key:** 의존성 주입을 통한 구성 숨김
  - 방식: `Info.plist`에서 Key를 읽어오는 책임을 `ConfigurationProtocol`로 추상화 하고, 이를 네트워크 계층에 주입합니다.
  - 의도: `Domain`, `Presentation`계층에서는 API Key의 존재 자체를 모르게 만들어 의존성 역전 원칙을 준수해 외부설정이 내부 로직에 영향을 주지 않도록 분리합니다.
* **목표:** `Coordinator` 패턴을 도입해 화면 간의 라우팅 의존성을 제거합니다. 의존성 역전 원칙(`DIP`)을 적용하여 네트워크 계층을 추상화하고, Mock 데이터를 활용한 독립적인 테스트 환경을 구축합니다.
* **이유:** 핵심 도메인 로직이 외부 프레임워크의 영향을 받지 않도록 완벽히 분리하고, 화면 전환을 외부에서 제어하여 `ViewController`의 독립성과 재사용성을 극대화하기 위해서 입니다.
* **다음 단계:** 단일 프로젝트 내에 코드가 많아지면서 수정 시 빌드 시간이 오래 걸리는 병목 현상이 발생함으로 물리적인 모듈 분리 작업이 요구됩니다.

### Phase 4: Modular Architecture
* **Architecture:** Modular Architecture
* **Tools:** Tuist, SPM
* **API Key:** Tuist 환경변수 및 동적 스크립트 주입
  - 방식: Tuist의 `Project.swift`설정 시 로컬의 환경변수, CI/CD 파이프라인에서 API Key를 읽어와 모듈 생성 빌드에 주입합니다.
  - 의도: 다중 모듈 환경에서 개별 모듈이 `.xcconfig`에 의존 하지 않도록 합니다.
* **목표:** 단일 프로젝트를 `Feature`, `Domain`, `Data` 등 다중 모듈로 물리적 분리합니다. API Key는 로컬 환경변수나 CI/CD를 통해 빌드 시점에 주입되도록 구성합니다.
* **이유:** 다수의 개발자가 참여하는 환경에서 필수적인 빌드 속도 개선과 코드 충돌 방지를 위함입니다. 특정한 모듈만 단독으로 실행(**Micro Feature**)할 수 있어 굉장한 개발 효율을 기대할 수 있습니다.
* **다음 단계:** 다중 모듈과 아키텍처가 의존성 규칙을 잘 지키고 있는지 검증하기 위해, 내부 비즈니스 로직은 그대로 둔 채 사용자 화면 프레임워크 자체를 교체해 보는 테스트를 진행합니다.

### Phase 5: UI Framework Migration (SwiftUI)
* **UI:** SwiftUI
* **목표:** Clean Architecture의 분리 효과를 검증합니다. 내부 비즈니스 로직(Domain) 코드는 수정하지 않은 채, 프레젠테이션 계층의 UI만 UIKit에서 SwiftUI로 교체합니다.
* **이유:** 최신의 기술인 선언형 UI를 경험하는 동시에 견고하게 설계된 아키텍처는 언제든 UI 프레임워크를 부작용 없이 교체 할 수 있다는 아키텍처의 실증하기 위함입니다.

---

## 기술 스택 (Tech Stack)

프로젝트 고도화 단계에 따라 아래의 기술들을 순차적으로 도입합니다.

* **UI:** UIKit (Storyboard &rarr; Code / SnapKit) &rarr; SwiftUI
* **Reactive/Async:** Completion Handlers &rarr; Combine & Swift Concurrency (async/await)
* **Architecture:** MVC &rarr; MVVM &rarr; Clean Architecture &rarr; Modular + Clean Architecture
* **Dependency Injection:** Manual DI &rarr; Needle or Factory (DI Framework)
* **Project Management:** Tuist & SPM
* **Network Debugging:** Proxyman
* **Testing** XCTest 
* **CI/CD:** Fastlane & GitHub Actions

## ADR (Architecture Decision Record)
구조가 변경되거나 새로운 기술을 도입할 때, 해당 의사결정의 배경과 논리적 근거를 기록합니다.

## Troubleshooting

### MVC

1. CollectionView Cell `Estimate Size`
    - 문제: 코드를 사용해 컬렉션뷰 셀의 크기를 지정 하였으나 시뮬레이터 빌드 시 영화 포스터들이 바둑판 모양으로 뭉쳐나와 가로 스크롤이 되지 않는 현상이 발생했다.
    
    - 원인: 
        1. `Story Board`에서는 컴포넌트의 Auto Layout 기반으로 Cell의 크기를 자동으로 연산하는 `Estimate Size: Automatic`이 기본값으로 설정되어 있다.
        
        2. 내부 이미지뷰가 Auto Layout 계산에 실패하여 강제로 이미지 뷰를 압축하는 현상이 발생한다.
        
    - 해결 방법: `Story Board`에서 Collection View의 `Estimate Size`의 속성값을 `None`으로 변경하여 자동 연산 을 차단하였다.
    
2. UI 렌더링 타이밍과 비동기 통신의 엇갈림
    - 문제: API 네트워크 통신 코드가 정상적으로 호출이 되었음에도 불구하고, 앱 실행 초기 하단의 영화 리스트가 렌더링 되지 않는 현상이 발생했다.
    
    - 원인: `viewDidLoad` 시점에 UI를 렌더링하는 메인 스레드의 처리 속도가 네트워크 비동기 통신의 응답 속도보다 빨라 테이터 배열이 비어있는 상태에서 테이블뷰 그리기가 먼저 종료되었다.
    
    - 해결 방법: API 응답 처리가 완료되는 비동기 클로저 내부에서 `DispatchQueue.main.async`를 사용해 메인 스레드에서 `tableView.reloadData()`를 호출하여 강제로 UI 렌더링 타이밍을 동기화 하였다.
