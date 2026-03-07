reference : 실전에서 바로 써먹는 Elasticsearch 입문 (인프런 강의) + 회사 업무

### 엘라스틱서치란?

- 오픈 소스, 분산, RESTful 검색 및 분석 엔진, 확장 가능한 데이터 저장소 및 벡터 데이터 베이스

⇒ 검색 및 데이터 분석에 최적화된 데이터베이스 

### 엘라스틱서치 주요 활용 사례

1. 데이터 수집 및 분석 
    1. 대규모 데이터(로그 등)를 수집 및 분석하는 데 최적화되어 있다.
    2. ELK = ElasticSearch(데이터 저장) + Logstash(데이터 수집 및 가공) + Kibaba(데이터 시각화)를 같이 활용해 데이터를 수집 및 분석한다. 

1. 검색 최적화 

### Elasticsearch 작동 방식

- REST API 방식으로 통신

**데이터 삽입** 

```jsx
curl -X POST "localhost:9200/users/_doc" -H 'Content-Type: application/json' -d '
	{
		"name" : "saul",
		"email":"test@naver.com"
	}'
```

- 로그인 및 https 설정이 붙어있는 경우 URL에 추가적인 인자 값들이 들어간다.

**데이터 조회** 

```jsx
curl -X GET "localhost:9200/users/_search" -H 'Content-Type: application/json' -d '
	{
		"query"{
			"match_all": {}
		}
	}'
```
