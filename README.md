# <div align="center">Sample Camera Applicaion</div>

## <div align="center">시연 영상</div>
<p align="center"><img src="https://user-images.githubusercontent.com/51852940/212024329-6a861edc-c073-4cc4-80c3-0da5ce86614a.gif"></p>

## 제작 배경
일본인 아내와 함께 병원에 갈 수 있다면 문제될 것이 없지만, 혹시라도 근무 중에 아내에게 문제가 생기는 경우 혼자서 병원을 가야할텐데 
의료 용어는 일상 회화에서 등장하는 표현이 아닐 수 있기에 낯설고 두려움을 느낄 수 있겠다고 판단해서, 대구 내에 있는 병원들의 정보를 
정리해서 보여줄 수 있으면 좋겠다는 마음에 일본어 표기로 각 병원들의 정보들을 보여주는 어플

## 구현 기능
- Firebase/Realtime Database와 연동해서 병원리스트 호출
- MapKit를 활용하여 병원의 위치를 이미지로 보여줌
- 주소 클릭 시 아이폰에 기본적으로 내장되어 있는 Apple Map 어플로 이동
- 전화번호 클릭 시 아이폰에 내장되어 있는 기본 전화 앱으로 이동
- 홈페이지 클릭 시 해당 병원의 웹 페이지로 이동

## 자료출처
[메디시티대구](https://www.medicitydaegu.com/main/site/organization/medical/list.do)

## 앱스토어
[App Store](https://apps.apple.com/kr/app/%EB%B3%91%EC%9B%90%EB%AA%A8%EC%95%84/id1663649902)

## 제작 및 등록 과정에서의 에러 사항
1. 제작 과정
    1) Type 'OOOO' does not conform to protocol 'OOOO'
        (https://hirodaegu.tistory.com/471)
        
    2) Info.plist 없어짐 또는 Key가 안보임
        (https://hirodaegu.tistory.com/472)
        
    3) Decoding Error(The data couldn’t be read because it is missing)
        (https://hirodaegu.tistory.com/479)
        
    4) this class is not key value coding-compliant for the key OOO
        (https://hirodaegu.tistory.com/480)
        
    5) NSInternalInconsistencyException, reason: Invalid parameter not satisfying: constraint isKindOfClass:NSLayoutConstraint class
        (https://hirodaegu.tistory.com/481)
        
    6) Initializer for conditional binding must have Optional type, not 'OOO'
        (https://hirodaegu.tistory.com/492)
        
2. 등록 과정(Reject Issue)
    1) Guideline 1.5 - Safety - Developer Information
    
        개발자 정보가 포함된 링크가 연결되지 않아서 생긴 거절 사유 -> 연결이 되는 링크로 변경 후 통과
        
    2) Guideline 4.2 - Design - Minimum Functionality
    
        처음에는 해당 어플에 기능이 많이 없어서 거절당했다고 판단해서, 넣을 수 있는 기능을 추가했었으나 똑같은 이유로 거절을 당했고
        답답한 마음에 직접 물어봤고 담당자가 참고하라고 알려준 것은 HIG(https://developer.apple.com/design/human-interface-guidelines/guidelines/overview),
            Essential Design Principles(https://developer.apple.com/videos/play/wwdc2017/802/),
            Design Tips for Great Games(https://developer.apple.com/videos/play/design/811/)
        세 가지였고, UI 부분이 Apple의 기준과 맞지 않아서 거절했던 것으로 확인했고, App Store의 디자인을 참고해서 수정하고 제출해서 통과
