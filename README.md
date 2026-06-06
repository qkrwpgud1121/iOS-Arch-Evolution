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
* **Goal:** 네트워크 통신, 데이터 파싱, UI 업데이트 등 모든 로직을 `ViewController`에 집중시켜 스파게티 코드와 강한 결합이 유발하는 유지보수의 한계를 의도적으로 재현합니다.

### Phase 2: MVVM
* **Architecture:** MVVM
* **UI:** Programmatic UIKit
* **API Key:** `.xcconfig` + `Info.plist`
  - 방식: API Key를 Swift 코드에서 완전히 분리하여 `.xcconfig`로 분리하고 이를 `Info.plist`를 거쳐 접근하도록 개선합니다.
  - 의도: 뷰와 로직이 분리되는 `MVVM`의 도입에 맞춰, 코드와 설정도 물리적으로 분리합니다.
* **Goal:** Storyboard를 제거하고 코드로 UI를 구성합니다. 비즈니스 로직(ViewModel)과 뷰(View)를 분리하여 역할의 경계를 명확히 합니다.

### Phase 3: Clean Architecture + Coordinator
* **Architecture:** MVVM-C + Clean Architecture
* **API Key:** 의존성 주입을 통한 구성 숨김
  - 방식: `Info.plist`에서 Key를 읽어오는 책임을 `ConfigurationProtocol`로 추상화 하고, 이를 네트워크 계층에 주입합니다.
  - 의도: `Domain`, `Presentation`계층에서는 API Key의 존재 자체를 모르게 만들어 의존성 역전 원칙을 준수해 외부설정이 내부 로직에 영향을 주지 않도록 분리합니다.
* **Goal:** Coordinator 패턴을 도입해 화면 간의 라우팅 의존성을 제거합니다. 의존성 역전 원칙(DIP)을 적용하여 네트워크 계층을 추상화하고, Mock 데이터를 활용한 독립적인 테스트 환경을 구축합니다.

### Phase 4: Modular Architecture
* **Architecture:** Modular Architecture
* **Tools:** Tuist, SPM
* **API Key:** Tuist 환경변수 및 동적 스크립트 주입
  - 방식: Tuist의 `Project.swift`설정 시 로컬의 환경변수, CI/CD 파이프라인에서 API Key를 읽어와 모듈 생성 빌드에 주입합니다.
  - 의도: 다중 모듈 환경에서 개별 모듈이 `.xcconfig`에 의존 하지 않도록 합니다.
* **Goal:** 단일 프로젝트를 `Feature`, `Domain`, `Data` 등 다중 모듈로 물리적 분리합니다. 빌드 속도를 개선하고, 각 기능이 독립적으로 실행 가능한 환경(Micro Feature)을 구성합니다.

### Phase 5: UI Framework Migration (SwiftUI)
* **UI:** SwiftUI
* **Goal:** Clean Architecture의 분리 효과를 검증합니다. 내부 비즈니스 로직(Domain) 코드는 수정하지 않은 채, 프레젠테이션 계층의 UI만 UIKit에서 SwiftUI로 교체합니다.

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

