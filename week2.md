<img width="791" height="664" alt="image" src="https://github.com/user-attachments/assets/ef7b7a77-3f43-4b7c-9d51-5dfa1c235d1a" />

안드로이드 버전에서 사용하지 않을 것 이기 때문에 오류의 내용은 문제가 되지 않음.

device 명령어 실행 중 발생한 오류는 devices 명령어 오타임. 이후에 정상 적으로 작동 확인

<img width="1288" height="661" alt="image" src="https://github.com/user-attachments/assets/d7368ecf-5daf-46f9-8f84-b02758d324a4" />

<img width="1123" height="216" alt="image" src="https://github.com/user-attachments/assets/3f94650c-48eb-42b9-bd6d-ef3b79e64650" />

commit id 가 일치하는 지 확인 성공

목표 | 어느 대상에서 무엇을 실행하려 했는가? CMD 에서 Flutter 프로젝트 생성 및 VSCode에서의 실행
관찰 | doctor에서 사용할 수 있는 디바이스를 보았고 실행에서는 내가 변경한 문구가 정상적으로 실행
원인 | Flutter 실행 간 문제는 없었으나 github와 연동하는 과정에서 오류가 있었으나 정상적으로 연동 완료
행동 | 주소를 잘못 등록하여 git remote remove origin 으로 주소 를 지우고 git remote add origin 주소 입력으로 정상 등록함
결과 | 인식이 되지 않던 주소를 수정하여 정상적으로 주소 이동이 가능해짐
다음 | 내용 변경 후 에도 정상적으로 연동이 되는가?
  
