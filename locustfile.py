from locust import HttpUser, task, between

class LoadBalancerTest(HttpUser):
    # 사용자 대기 시간 설정 (초)
    wait_time = between(1, 3)
    
    @task
    def get_index(self):
        # 기본 경로 요청
        self.client.get("/")
    
    # @task(2)  # 가중치 2를 주어 다른 태스크보다 두 배 더 자주 실행
    # def get_health_check(self):
    #     # 헬스 체크 경로 요청
    #     self.client.get("/health")

    # @task
    # def post_data(self):
    #     # POST 요청 예시
    #     payload = {"key": "value"}
    #     self.client.post("/api/data", json=payload)