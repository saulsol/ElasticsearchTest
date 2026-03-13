### 엘라스틱서치란?

- 오픈 소스, 분산, RESTful 검색 및 분석 엔진, 확장 가능한 데이터 저장소 및 벡터 데이터 베이스

⇒ 검색 및 데이터 분석에 최적화된 데이터베이스 

### 엘라스틱서치 주요 활용 사례

1. 데이터 수집 및 분석 
    1. 대규모 데이터(로그 등)를 수집 및 분석하는 데 최적화되어 있다.
    2. ELK = ElasticSearch(데이터 저장) + Logstash(데이터 수집 및 가공) + Kibaba(데이터 시각화)를 같이 활용해 데이터를 수집 및 분석한다. 

1. 검색 최적화 

### 엘라스틱서치의 분석이란?

"Elastic certification Guide” 이러한 문장이 있다고 가정해 보자.

이 텍스트가 analysis과정을 거치면 아래와 같이 변한다.

```jsx
elastic
certification
guide
```

```jsx
Elastic certification Guide
        ↓
소문자 변환
        ↓
elastic certification guide
        ↓
단어 분리 (tokenize)
        ↓
[elastic, certification, guide]
```

- 텍스트들을 변환하고 분리하는 과정을 거친다.

***. keyword ⇒ 분석을 하지 않고 텍스트 그대로 유지하라는 키워드*** 

### 1.1 Elasticsearch 작동 방식 (INTRO)

- REST API 방식으로 통신

**<클러스터에 대한 기본 정보>** 

```jsx
GET / 
```

response

```jsx
{
  "name" : "node1",
  "cluster_name" : "cluster1",
  "cluster_uuid" : "ZIZfXHjWQRyzJcBJTtiGww",
  "version" : {
    "number" : "8.1.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "39afaa3c0fe7db4869a161985e240bd7182d7a07",
    "build_date" : "2022-04-19T08:13:25.444693396Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

**<데이터 조회>**

```jsx
GET kibana_sample_data_ecommerce/_search
```

**<데이터 삽입 : RESTapi>**

```jsx
curl -X POST "localhost:9200/users/_doc" -H 'Content-Type: application/json' -d '
	{
		"name" : "saul",
		"email":"test@naver.com"
	}'
```

- 로그인 및 https 설정이 붙어있는 경우 URL에 추가적인 인자 값들이 들어간다.

**<데이터 조회 : RESTapi>**

```jsx
curl -X GET "localhost:9200/users/_search" -H 'Content-Type: application/json' -d '
	{
		"query"{
			"match_all": {}
		}
	}'
```

- 일치하는 데이터 중 10개의 문서를 리턴(default)

### Elasticsearch  구성 방식

![image.png](attachment:52f3ebed-101e-4090-bb62-8909b1ca589d:image.png)

**클러스터(Cluseter) :** 

- 노드들의 집합, 가장 큰 집합

**노드(Node) :** 

- 엘라스틱서치가 실행되고 있는 하나의 서버(인스턴스)
- 엘라스틱의 클러스터는 하나 이상의 노드로 이뤄지고, 이중 하나의 노드는 인덱스의 메타 데이터, 샤드의 위치와 같은 클러스터 상태(Cluster Status)정보를 관리하는 마스터 노드의 역할을 수행
- 클러스터가 1개의 노드로 이뤄지면, 1개의 노드가 마스터 노드가 됩니다.
- 가존 마스터 노드가 다운되면, 다른 마스터 후보 노드 중 하나가 마스터 노드로 선출이 되어 마스터 노드의 역할을 대신 수행합니다.
- 노드와 샤드의 개수가 많으면, 일부 노드만 마스터 노드 옵션을 true로 하고 나머지는 false로 두어 부하를 줄이도록 하는 게 좋다.

**인덱스(Index) :** 

- 도큐먼트(Row)의 집합

**샤드(Shard) :** 

- 인덱스를 나눈 조각 : 인덱스 → 샤드라는 단위로 구성
- 설정해주지 않으면, 디폴트로 1개 인덱스 per 1개 샤드
    - 즉 하나의 Index 안에는 여러 개의 Primary shard가 있고, 각 Primary마다 Replica shard가 존재한다.
    - Primary 샤드를 여러 개 두는 이유는 분산 처리 및 병렬 처리 그리고 데이터 무결성을 위해 사용한다.

### 1.2 Data In

1. Using the Elasticsearch API, index a document that meets these requirements:
    - is indexed into an index called `my_index`
    - has an ID of 1
    - contains one field called `my_field`
    - has one value for the `my_field` field: `Hello world!`

```jsx
PUT my_index/_doc/1
{
  "my_field":"hello world"
}
```

- URL  타입 : PUT {index}/_doc/{id}
    - type은 7.X 이후부터 _doc 하나만 사용한다.

1. Use the Elasticsearch Get by ID API to retrieve the document you have just indexed. (방금 추가한 문서를 ID 로 조회하세요)
    
    ```jsx
    GET my_index/_doc/1
    ```
    
- 조회도 마찬가지로 {idx}/타입/{id} 형식으로 조회한다.

 

### 1.3 Information Out

1. As an Elasticsearch engineer, the query language you will use most often is the query DSL. Let's use the query DSL to mimic the last query that you executed in Discover. Write a `match` query on the `blogs` index that searches for blogs with the word `certification` in the blog's `title` field. You should get 2 hits.

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "title": "certification"
    }
  }
}
```

- request.query.match.title = “certification”

1. Change the query so that it searches for blogs with the words `Elastic certification` in the `title` field. How many hits did you get?

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "title": "Elastic certification"
    }
  }
}
```

- request.query.match.title = “Elastic certification”

```jsx
title : elastic OR title : certification
```

- match 쿼리는 Analyzer 가 토큰으로 만들어 분석한다.

**AND 조건으로 바꾸는 경우** 

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "title": {
        "query": "Elastic certificcation",
        "operator": "and"
      }     
    }
  }
}
```

- request.query.match.title.query : "Elastic certificcation"
- request.query.match.title.operator : "and"

1. Notice you get 1689 hits when you search for `Elastic certification` in the `title`. Why do you think there are 1687 additional hits?

⇒  or

1. Execute the following request to retrieve the top 10 authors:

```jsx
GET blogs/_search
{
  "size": 0,
  "aggregations": {
    "top_authors": {
      "terms": {
        "field": "authors.full_name.keyword"
      }
    }
  }
}
```

- request.size: 0
    - size 가 0개인 경우는 document가 필요 없다는 뜻이다.
    - 
- request.aggregations.top_authors.terms.field = "authors.full_name.keyword”
    - aggregations ⇒ 통계를 사용하겠다는 의미
    - top_authors ⇒ 임의로 붙인 변수 명

```jsx
"terms": {
  "field": "authors.full_name.keyword"
}
```

- authors.full_name ⇒ groupBy
- keyword ⇒ String 값 원본 그대로 사용하겠다(풀 네임으로 사용해야 통계가 올바르게 작동할 수 있다.)

### 2.1 Strings in Elasticsearch

1. Write a match query on the blogs index that searches for blogs with the name `Steve` as the `authors.first_name`. You should get 135 hits.

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "authors.first_name": "steve"
    }
  }
}
```

- request.query.match.authors.first_name = "steve"

1. Update the previous query to search for `steve` instead of `Steve`. How many hits are you expecting?

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "authors.first_name": "Steve"
    }
  }
}
```

- 대소문자는 관련이 없다.

1. pdate the query, to use the `authors.first_name.keyword` instead of the `authors.first_name` field. Why do you have zero result?

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "authors.first_name.keyword": "steve"
    }
  }
}
```

- .keyword 가 붙은 경우는 엘라스틱서치가 분석을 진행하지 않는다.
- 따라서 저장된 first_name은 “Steve” 인데 넘겨준 데이터는 분석을 하지 않기 때문에 일치하는 값이 없다.
    - 따라서 result 값은 0이 나온다.

1. Using they `keyword` field, update the query to get the same blogs as the first query.

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "authors.first_name.keyword": "Steve"
    }
  }
}
```

### 2.2 Overview of mappings

1. Index the following sample document, which also creates a new index called `sample_blog`:

```jsx
POST sample_blog/_doc
{
  "@timestamp": "2021-03-10T16:00:00.000Z",
  "abstract": "The Joy of Painting",
  "author": "Bob Ross",
  "body": "Painting should do one thing. It should put happiness in your heart. We'll take a little bit of Van Dyke Brown. Isn't that fantastic? You can just push a little tree out of your brush like that. Mix your color marbly don't mix it dead.",
  "body_word_count": 55,
  "category": "Painting",
  "title": "Making Happy Little Trees",
  "utl": "/blog/happy-little-trees",
  "published": true
}

```

1. View the default mappings that were created. Elasticsearch did its best to guess the data types - but notice a lot of the fields are of type `text` and `keyword`:

```jsx
GET sample_blog/_mapping
```

- sample_blog의 인덱스의 필드 구조와 타입을 보여달라는 명령어

```jsx
{
  "sample_blog" : {
    "mappings" : {
      "properties" : {
        "@timestamp" : {
          "type" : "date"
        },
        "abstract" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "author" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "body" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "body_word_count" : {
          "type" : "long"
        },
        "category" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "published" : {
          "type" : "boolean"
        },
        "title" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "utl" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    }
  }
}

```

1. Create a new index called `test_blogs` based on the `sample_blog` mapping. Configure `test_blogs` to satisfy the following requirements:
- `@timestamp` is a `date`
- `body_word_count` is an integer
- the `abstract`, `body`, and `title` fields are of type `text` only
- the `author`, `category` and `url` fields are of type `keyword` only
- `published` is of type `boolean`

```jsx
PUT test_blogs
{
  "mappings": {
    "properties": {
      "@timestamp" : {
        "type" : "date"
      },
      "abstract" : {
        "type" : "text"
      },
      "author": {
        "type": "keyword"
      },
      "body": {
        "type": "text"
      },
      "body_word_count" : {
        "type": "integer"
      },
      "category" : {
        "type": "keyword"
      },
      "published" : {
        "type": "boolean"
      },
      "title" : {
        "type": "text"
      }, 
      "utl" : {
        "type" : "boolean"
      }
    }
  }
}
```

1. Index the document from step 1 into your new `test_blogs` index. The document should be indexed without any issues with the mapping or data types.

```jsx
POST test_blogs/_doc
{
  "@timestamp": "2021-03-10T16:00:00.000Z",
  "abstract": "The Joy of Painting",
  "author": "Bob Ross",
  "body": "Painting should do one thing. It should put happiness in your heart. We'll take a little bit of Van Dyke Brown. Isn't that fantastic? You can just push a little tree out of your brush like that. Mix your color marbly don't mix it dead.",
  "body_word_count": 55,
  "category": "Painting",
  "title": "Making Happy Little Trees",
  "utl": "/blog/happy-little-trees",
  "published": "true"
}

```

1. Now let's make some changes to the `blogs` index. First, create a new `blogs_fixed` index.

```jsx
PUT blogs_fixed
```

1. Reindex all of the documents from the `blogs` index into your new `blogs_fixed` index.

```jsx
PUT blogs_fixed/_mapping
{
  "_meta": {
    "created_by": "Elastic Student"
  },
  "properties": {
    "authors": {
      "properties": {
        "company": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "first_name": {
          "type": "keyword"
        },
        "full_name": {
          "type": "text"
        },
        "job_title": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "last_name": {
          "type": "keyword"
        },
        "uid": {
          "type": "keyword"
        }
      }
    },
    "category": {
      "type": "keyword"
    },
    "content": {
      "type": "text"
    },
    "locale": {
      "type": "keyword"
    },
    "publish_date": {
      "type": "date",
      "format": "iso8601"
    },
    "tags": {
      "properties": {
        "elastic_stack": {
          "type": "keyword"
        },
        "industry": {
          "type": "keyword"
        },
        "level": {
          "type": "keyword"
        },
        "product": {
          "type": "keyword"
        },
        "tags": {
          "type": "keyword"
        },
        "topic": {
          "type": "keyword"
        },
        "use_case": {
          "type": "keyword"
        },
        "use_cases": {
          "type": "keyword"
        }
      }
    },
    "title": {
      "type": "text"
    },
    "url": {
      "type": "keyword"
    }
  }
}

POST _reindex
{
  "source": {
    "index": "blogs"
  }, 
  "dest": {
    "index": "blogs_fixed"
  }
}
```

- The reindex request will take a few moments, but should run fairly quickly. If it times out, do not panic and *do not run the reindex command again*.
- It just means it took more than 1 minute, and Console stopped waiting for the response. The request will continue to run in the background though.
- 기존 인덱스를 기반으로 다른 인덱스에 문서를 저장하는 명령어를 위와같이 사용한다.

1. Run the following command to see how many documents are in `blogs_fixed`. You will know the reindexing is complete when `blogs_fixed` has 4,719 documents.

```jsx
GET blogs_fixed/_count
```

1. Run the previous query for "security analytics" on the original `blogs` index. You should get 598 hits. Why are there so many more hits?

```jsx
GET blogs/_search
{
  "query": {
    "match": {
      "tags.use_case": "security analytics"
    }
  }
}

hits -> 216

GET blogs_fixed/_search
{
  "query": {
    "match": {
      "tags.use_case": "security analytics"
    }
  }
}

hits -> 598
```

- 왜 새로 생성된 인덱스는 다른 결과를 나타낼까?
- blogs 인덱스의 tags.use_case 같은 경우

```jsx
"use_cases" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
```

- blog_fixed 인덱스의 tags.use_case 같은 경우

```jsx
"use_case" : {
              "type" : "keyword"
            },
```

- blogs 인덱스의 tags.use_case가 잘못 설계되었다고 생각할 수 있지만 저런 식으로 하나의 필드에 여러 인덱싱 방식을 적용할 수 있다.

```jsx
{
  "title": {
    "type": "text",
    "fields": {
      "keyword": {
        "type": "keyword"
      }
    }
  }
}
```

title
title.keyword

- 이렇게 두 개의 필드가 생기고 두 필드의 용도는 다르다.

| 필드 | 용도 |
| --- | --- |
| title | full-text search |
| title.keyword | 정렬 / aggregation |

### 2.3 Text analysis

1. Elasticsearch provides an `_analyze` API. For example, to see what would happen to the string `"United Kingdom"` if you applied the `standard` analyzer, you can use the following in Console:

```jsx
GET _analyze
{
  "text": "United Kingdom",
  "analyzer": "standard"
}
```

response 

```jsx
{
  "tokens" : [
    {
      "token" : "united",
      "start_offset" : 0,
      "end_offset" : 6,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "kingdom",
      "start_offset" : 7,
      "end_offset" : 14,
      "type" : "<ALPHANUM>",
      "position" : 1
    }
  ]
}
```

- 분석을 진행한 경우 대문자는 소문자로 변환되는 것을 확인할 수 있다.
- 그리고 띄어쓰기 단위로 잘라진 것을 확인할 수 있다.

1. Let's take a closer look at analyzers. Compare the output of the `_analyze` API on the string `"Nodes and Shards"` using the `standard` analyzer and using the `english` analyzer.

```jsx
GET _analyze
{
  "text": "Nodes and Shards",
  "analyzer": "standard"
}

---- response ----
{
  "tokens" : [
    {
      "token" : "nodes",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "and",
      "start_offset" : 6,
      "end_offset" : 9,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "shards",
      "start_offset" : 10,
      "end_offset" : 16,
      "type" : "<ALPHANUM>",
      "position" : 2
    }
  ]
}

GET _analyze
{
  "text": "Nodes and Shards",
  "analyzer": "english"
}

---- response ----
{
  "tokens" : [
    {
      "token" : "node",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "shard",
      "start_offset" : 10,
      "end_offset" : 16,
      "type" : "<ALPHANUM>",
      "position" : 2
    }
  ]
}

```

- 각 analyzer 마다 텍스트를 분석하는 것이 다릅니다.
    - stopword 삭제 여부
    - 소문자 변환 수행

<stop word?>

```jsx
and
the
a
is
in
of
```

- 의미 전달에 크게 기여하지 않는 단어

1. Using the `_analyze` API, see what the `standard` analyzer does with the following HTML snippet:

```jsx
GET _analyze
{
  "analyzer": "standard",
  "text":     "<b>Is</b> this <a href='/blogs'>clean</a> text?"
}
```

```jsx
{
  "tokens" : [
    {
      "token" : "b",
      "start_offset" : 1,
      "end_offset" : 2,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "b",
      "start_offset" : 7,
      "end_offset" : 8,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "href",
      "start_offset" : 18,
      "end_offset" : 22,
      "type" : "<ALPHANUM>",
      "position" : 5
    },
    {
      "token" : "blog",
      "start_offset" : 25,
      "end_offset" : 30,
      "type" : "<ALPHANUM>",
      "position" : 6
    },
    {
      "token" : "clean",
      "start_offset" : 32,
      "end_offset" : 37,
      "type" : "<ALPHANUM>",
      "position" : 7
    },
    {
      "token" : "text",
      "start_offset" : 42,
      "end_offset" : 46,
      "type" : "<ALPHANUM>",
      "position" : 9
    }
  ]
}
```

- HTML 태그도 일반 텍스트처럼 인덱싱됨.
- elastic search는 기본적으로 HTML을 이해하지 못합니다.

1. **EXAM PREP:** The `html_strip` character filter strips out HTML code before indexing the data. As a result, you will have cleaner data to search against. To use this filter, you need to create a custom analyzer. Create a new index named `blogs_test` that defines an `analyzer` named `content_analyzer` that uses:
- the `html_strip` character filter
- the `standard` tokenizer
- the `lowercase` filter

- 따라서 custom analyzer를 만들어서 문제를 해결하는 방식으로 진행할 수 있다.

```jsx
PUT blogs_test
{
  "settings": {
    "analysis": {
      "analyzer": {
        "content_analyzer" : {
          "tokenizer" : "standard",
          "filter" : ["lowercase"],
          "char_filter" : ["html_strip"]
        }
      }
    }
  }
}
```

- blogs_test라는 인덱스에 “content_analyzer” 라는 analyzer 를 생성.

```jsx
GET blogs_test/_analyze
{
  "text": "<b>Is</b> this <a href='/blogs'>clean</a> text?",
  "analyzer": "content_analyzer"
}
```

```jsx
{
  "tokens" : [
    {
      "token" : "is",
      "start_offset" : 3,
      "end_offset" : 9,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "this",
      "start_offset" : 10,
      "end_offset" : 14,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "clean",
      "start_offset" : 32,
      "end_offset" : 41,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "text",
      "start_offset" : 42,
      "end_offset" : 46,
      "type" : "<ALPHANUM>",
      "position" : 3
    }
  ]
}
```

### 2.4 Types and parameters

1. In the previous lab, you changed the `tags` fields (`tags.elastic_stack`, `tags.industry`, `tags.level`, etc.) into `keyword` fields. Querying all these separate fields is possible, but not optimal. Let's copy all the individual `tags` fields into one `search_tags` field that can be queried with a simple `match` query. At the same time, let's also apply the `content_analyzer` to the `content` field.
    - create a new index named `blogs_fixed2`. Use the mapping and settings of `blogs_fixed` as the starting point
    - add a new `keyword` field to the `blogs_fixed2` mapping named `search_tags`
    - using `copy_to`, copy the values of all the `tags` to `search_tags`
    - disable doc values for the new `search_tags` field (it will not be used for sorting or aggregations)
    - completely disable the `authors.uid` field
    - apply the custom `content_analyzer` from lab 2.3 to the `content` field (don't forget that the analyzer needs to be defined in the settings!)

```jsx
PUT blogs_fixed2
{
  "settings": {
    "analysis": {
      "analyzer": {
        "content_analyzer": {
          "tokenizer": "standard",
          "filter": ["lowercase"],
          "char_filter": ["html_strip"]
        }
      }
    }
  },
  "mappings": {
    "_meta": {
      "created_by": "Elastic Student"
    },
    "properties": {
      "authors": {
        "properties": {
          "company": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "first_name": {
            "type": "keyword"
          },
          "full_name": {
            "type": "text"
          },
          "job_title": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "last_name": {
            "type": "keyword"
          },
          "uid": {
            "enabled": false
          }
        }
      },
      "category": {
        "type": "keyword"
      },
      "content": {
        "type": "text",
        "analyzer": "content_analyzer"
      },
      "locale": {
        "type": "keyword"
      },
      "publish_date": {
        "type": "date",
        "format": "iso8601"
      },
      "search_tags": {
        "type": "keyword",
        "doc_values": false
      },
      "tags": {
        "properties": {
          "elastic_stack": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "industry": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "level": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "product": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "tags": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "topic": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --**
          },
          "use_case": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --** 
          },
          "use_cases": {
            "type": "keyword",
            **"copy_to": "search_tags"  -- ! --** 
          }
        }
      },
      "title": {
        "type": "text"
      },
      "url": {
        "type": "keyword"
      }
    }
  }
}

```

- 코드를 보면 **"copy_to": "search_tags" 를 tags 하위 필드에서 볼 수 있는데 즉 여러 필드의 값을 search_tags 라는 하나의 필드로 복사해서 그 필드 하나만을 검색하도록 만드는 것이다.**

- 따라서 아래와 같은 요청을 날릴 수 있다.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match": {
      "search_tags": "logstash"
    }
  }
}
```

- 즉 모든 tag.~ 필드를 한 번에 검색하는 효과이다.

1. Run the following aggregation on the `search_tags` field:

```jsx
GET blogs_fixed2/_search
{
  "size": 0,
  "aggs": {
    "top_job_titles": {
      "terms": {
        "field": "search_tags",
        "size": 10
      }
    }
  }
}
```

- The `search_tags` field does not have doc values enabled. As a result, you cannot aggregate on that field. ⇒ error
    - copy to로 생성한 값은 통계를 진행할 수 없다.

1. Run the following aggregation on the `authors.uid` field:

```jsx
GET blogs_fixed2/_search
{
  "size": 0,
  "aggs": {
    "top_author_uids": {
      "terms": {
        "field": "authors.uid",
        "size": 10
      }
    }
  }
}
```

⇒ 결과 없음 ⇒ 

- The `authors.uid` field has been disabled. From a query and aggregation perspective, it's as if that field does not exist.
- "enabled": false ⇒ 맵핑 진행 시 해당 값을 주게되면 검색이나 집계에서는 그 필드가 없는 것처럼 동작한다.

```jsx
"authors": {
  "properties": {
    "uid": {
      "type": "keyword",
      ***"enabled": false***
    }
  }
}
```

### 3.1 Searching with the QueryDSL

1. Using **Console**, write and execute a query that finds all the documents in the `blogs_fixed2` index. You should have a total of 4719 hits.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match_all": {
      
    }
  }
}

GET blogs_fixed2/_search
```

1. Your previous query matched all documents, but Elasticsearch returned not all blogs - only ten documents are returned by default. Rerun your last query, but this time have it return 50 documents.

```jsx
GET blogs_fixed2/_search
{
  "size": 50, 
  "query": {
    "match_all": {}
  }
}

GET blogs_fixed2/_search?size=50
```

1. The `_source` parameter filters the fields that get returned in the hits, but keep in mind that this is done by parsing the JSON document source, resulting in additional overhead for Elasticsearch (although the amount of data transferred over the network decreases). Modify your previous `match_all` query, but have the response only contain each hit's `title` field.

```jsx
GET blogs_fixed2/_search
{
  "_source": "title",         // SELECT 절 
  "query": {                  //  WHERE 절 
    "match_all": {}
  }
}
```

- SELECT _source.title FROM blogs_fixed WHERE 1=1;

1. If you just want specific fields from hits, the `fields` parameter is more efficient than using `_source`. Modify your `match_all` query so that the `fields` parameter is `title` and set `_source` to **false** (so that `_source` does not get returned).
    - hits 필드에서 특정 필드만 필요하다면 _source 를 사용하는 것보다 fields 파라미터가 더 효율적이다.

| 방식 | 동작 |
| --- | --- |
| `_source` | 전체 JSON을 읽은 뒤 필터링 |
| `fields` | 필요한 필드만 직접 가져옴 |

```jsx
GET blogs_fixed2/_search
{
  "size": 50, 
  "_source": false,
  "fields": ["title", "authors.company"],
  "query": {
    "match_all": {}
  }
}

=> 
{
  "_index" : "blogs_fixed2",
  "_id" : "edfpwJwBvLaQLVMUnugn",
  "_score" : 1.0,
  "fields" : {
     "authors.company" : [
         "Elastic",
         "Elastic",
         "Elastic"
     ],
     "title" : [
       "EQL for the masses"
     ]
  }
}
```

- 사용하고 싶은 필드만 이런 식으로 뽑아서 사용할 수 있다.
- _source는 데이터가 들어가 있는 필드입니다.

1. Run a `match` query on the `blogs_fixed2` index for the terms "open source" in the `content` field. You should get 1725 hits.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match": {
      "content": "open source"
    }
  }
}
```

1. Update the previous query to search for blogs that contains "open" **and** "source" (instead of "open" **or** "source). You should get 772 hits.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match": {
      "content": {
        "query": "open source",
        "operator": "and"
      }
    }
  }
}
```

1. In the previous query, you will match blogs where the terms "open" and "source" are not necessarily next to each other. Run a query to get the blogs that contain the exact phrase "open source". You should get 604 hits. 

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match_phrase": {
      "content": "open source"
    }
  }
}
```

- match_phrase는 단어 기반이 아닌 문장 기반으로 검색.
- 문자을 토크나이징하지만 해당 토큰의 순서까지 고려한다.

1. **EXAM PREP:** By default, the `hits` are sorted by **score**. Update the previous query to satisfy the following requirements:
    ◦ Sort the results by `publish_date` with the most recent first.
    ◦ Get the five most recent blogs
    ◦ Filter the `_source` to display only the `title` and the `publish_date`.**Solution**

```jsx
GET blogs_fixed2/_search
{
  "_source": ["title", "publish_date"], 
  "size": 5,
  "sort": [
    {
      "publish_date": {
        "order": "desc"
      }
    }
  ], 
  "query": {
    "match_phrase": {
      "content": "open source"
    }
  }
}
```

- 5번 이후의 쿼리는 아래와 같이 사용한다.

```jsx
GET blogs_fixed2/_search
{
  "_source": ["title", "publish_date"], 
  "from": 5, 
  "size": 5,
  "sort": [
    {
      "publish_date": {
        "order": "desc"
      }
    }
  ], 
  "query": {
    "match_phrase": {
      "content": "open source"
    }
  }
}
```

### 3.2 More qeuries

1. Write a query to get the blogs written since 2018. Filter the `_source` to display only the `title` and `publish_date`. You should get 2770 hits.

```jsx
GET blogs_fixed2/_search
{
  "_source": ["title", "publish_date"],
  "query": {
    "range": {
      "publish_date": {
        "gte": "2018-01-01"      
      }
    }
  }
}
```

- range : 범위 검색
    - gte : 이상
    - lte : 이하

1. Update the previous query to get the blogs written in 2018. You should get 701 hits.

```jsx
GET blogs_fixed2/_search
{
  "_source": ["publish_date", "title"],
  "query": {
    "range": {
      "publish_date": {
        "gte": "2018-01-01",
        "lt": "2019-01-01"
      }
    }
  }
}
```

1. Run a `match` query on the `blogs_fixed2` index for the terms "Shay Banon" in the `content` field. You should get 165 hit.

```jsx
GET blogs_fixed/_search
{
  "query": {
    "match": {
      "content": "Shay Banon"
    }
  }
}

```

1. Now run a second `match` query for "Shay Banon" on the `authors.full_name` field. You should get 204 hits.

```jsx
GET blogs_fixed/_search
{
  "query": {
    "match": {
      "authors.full_name": "Shay Banon"
    }
  }
}
```

```jsx
GET <index_name>/_search
{
  "query": {
    "match": {
      "<field_name>": "<search_text>"
    }
  }
}
```

1. Run a `multi_match` query that searches both the `authors.full_name` and `content` fields for "Shay Banon". Does the `multi_match` deliver more or fewer hits?

```jsx
GET blogs_fixed/_search
{
  "query": {
    "multi_match": {
      "query": "Shay Banon",
      "fields": [
        "content",
        "authors.full_name"
      ]
    }
  }
}
```

```jsx
GET <index_name>/_search
{
  "query": {
    "multi_match": {
      "query": "<search_text>",
      "fields": [
        "<field1>",
        "<field2>",
        "<field3>"
      ]
    }
  }
}
```

1. **EXAM PREP:** Write a query on the `blogs_fixed2` index that satisfies the following requirements:
    - the term "meetups" appears in either the `title` or `content` fields of the blog
    - the blog was published within two years of today's date. You should get 14 hits.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "meetups",
            "fields": [
              "content",
              "title"
            ]
          }
        }
      ],
      "filter": [
        {
          "range": {
            "publish_date": {
              "gte": "now/d-2y"
            }
          }
        }
      ]
    }
  }
}

```

- 엘라스틱서치에서 “query” 객체 안에 항상 하나의 객체가 있어야 한다.
- 따라서 여러 조건을 넣기 위해서 “bool” 객체를 사용합니다.
    - bool 객체 안에는 여러 조건을 담을 수 있음.

1. **EXAM PREP:** Write a query on the `blogs_fixed2` index that satisfies the following requirements:
    - get the blogs that mention "ingestion" in the `content` field.
    - the term "logstash" must not be in the `content` field.
    - the blogs are written in French (use the `fr-fr` locale)

You should get 18 hits.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "content": "ingestion"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "content": "logstash"
          }
        }
      ],
      "filter": [
        {
          "match": {
            "locale": "fr-fr"
          }
        }
      ]
    }
  }
}

```

### 3.3 Developing search applications

1. Let's start with the query for which we want to create a template. Write a search on the `blogs_fixed2` index that finds the blogs for a one-week period starting April 1, 2021. (Hint: When anchoring dates, a `||` needs to be appended as a separator between the anchor and the range.)
    - 특정 기간을 찾는 문제.
    - 엘라스틱서치에서 날짜 계산을 하는 경우 ‘기준날짜||+시간’ 식으로 진행합니다.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "publish_date": {
              "gte": "2021-04-01",
              "lt": "2021-04-01||+1w"
            }
          }
        }
      ]
    }
  }
}
```

1. **EXAM PREP:** Create a search template called `weekly_blogs` that satisfies the following requirement:
- the starting date for the one-week period is a parameter named `start_date`

```jsx
PUT _scripts/weekly_blogs
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "bool": {
          "filter": [
            {
              "range": {
                "publish_date": {
                  "gte": "{{start_date}}",
                  "lt": "{{start_date}}||+1w"
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

- 엘라스틱서치에서는 Search Template 기능이 있어서 쿼리를 템플릿으로 저장할 수 있다.

1. Verify that your search template works by writing a query that returns the top 5 blogs for the week of April 1, 2021. You should get the same response as the query from Step 1.

```jsx
GET blogs_fixed2/_search/template
{
  "id": "weekly_blogs",
  "params": {
    "start_date" : "2021-04-01"
  }
}
```

1. **EXAM PREP:** Define a new search template named `top_blogs` similar to the `weekly_blogs` template that satisfies the following requirements:
- the date range is flexible using `start_date` and `end_date` parameters
- if an `end_date` parameter is not provided in the search, then search for one week of blogs

```jsx
PUT _scripts/top_blogs
{
  "script":{
    "lang" : "mustache",
    "source" : {
      "query": {
        "bool":{
          "filter": [
            {
              "range": {
                "publish_date": {
                  "gte": "{{start_date}}",
                  "lt": "{{end_date}}{{^end_date}}{{start_date}}||+1w{{/end_date}}"
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

- end_date가 없으면 start_date + 1주 사용

| 문법 | 의미 |
| --- | --- |
| `{{variable}}` | 변수 출력 |
| `{{#variable}}` | variable이 있으면 실행 |
| `{{^variable}}` | variable이 없으면 실행 |
| `{{/variable}}` | 조건 종료 |

1. Verify your template is working by writing a query using the `top_blogs` template that returns the blogs from April 10, 2021, to April 15, 2021.

```jsx
GET blogs_fixed2/_search/template
{
  "id" : "top_blogs",
  "params": {
    "start_date": "2021-04-10",
    "end_date": "2021-04-15"
  }
}
```

1. Verify that you can send a query without an `end_date` by removing the `end_date` parameter from your previous query to get the blogs for the week of April 10, 2021.

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "match": {
      "title": "security"
    }
  },
  "highlight": {
    "fields": {
      "title": {}
    },
    "pre_tags": [
      "<strong>"
    ],
    "post_tags": [
      "</strong>"
    ]
  }
}
```

1. Now, let's try to run an asynchronous search. Run the following `function_score` query. (Use `function_score` to customize how Elasticsearch computes the `_score` for each document.)

```jsx
GET blogs_fixed2/_search
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "content": "to the blog and your query: you are both enjoying being on Elasticsearch "
        }
      },
      "script_score": {
        "script": """
        int m = 1; 
        double u = 1.0;
        for (int x = 0; x < m; ++x) 
          for (int y = 0; y < 10000; ++y) 
            u=Math.log(y);
        return u
        """
      }
    }
  }
}

```

- script_score를 사용하면 사용자 정의 함수를 사용할 수 있다.

1. Take a look at the `took` time after executing this query. Increasing the value of `m` increases the `took` time. So if `m = 1` takes about 1000ms, then `m=30` should take about 30000ms or 30 seconds. Figure out what `m` value you would need for this query to take approximately 30 seconds.
- 엘라스틱 서치에서 비동기 검색을 진행할 수 있다.
- 비동기로 진행되는 경우 키바나에서 실행되고 있는 쿼리의 id를 넘겨주는데 이 id 를 바탕으로 나중에 결과를 조회할 수 있다.

```jsx
GET _async_search/<your_search_ID_here>
```

### 4.1 Changing data

- 엘라스틱서치에서 말하는 파이프라인(Pipeline)은 정확히는 Ingest Pipeline을 의미한다.

⇒ 데이터 전처리 파이프라인 

- 이는 문서가 인덱스에 저장되기 전에 데이터를 가공하는 단계이다.
- document 및 리인덱싱하는 경우에 적용할 수 있습니다.

```jsx
데이터 입력
   ↓
Ingest Pipeline
   ↓
Processor 실행 (데이터 변환)
   ↓
Index 저장
```

- 즉 Logstash 없이 Elasticsearch 내부에서 데이터를 가공할 수 있는 기능이다.
- 파이프라인은 프로세서들의 집합

```jsx
Pipeline
 ├─ processor(set)
 ├─ processor(rename)
 └─ processor(...)
```

- 각기 다른 역할의 프로세서들이 하나로 합쳐진 것이 파이프라인이다.

**Manipulate fields processors**

- set
- remove
- rename
- dot_expander

**manipulate values**

- split
- grok
- dissect
- gsub

**Special operations** 

- csv/json
- geoip
- user_agent
- script
- pipeline

***어떤 상황에서 사용할까?*** 

- Apply a pipeline to documents in indexing requests. ()
- Set a default pipeline. (최초로 파이프라인 생성하는 경우)
- Set a pipeline with Update by Query or Reindex APIs. (리인덱스 상황에서)

**파이프라인 생성**

```jsx
PUT _ingest/pipeline/my_pipeline
{
  "description": "example pipeline",
  "processors": [
    {
      "set": {
        "field": "status",
        "value": "processed"
      }
    }
  ]
}
```

- 도큐먼트가 들어오면 status 필드를 자동 추가

**문서 저장** 

```jsx
{
  "name" : "LIM"
}
```

- 파이프라인을 거칩니다.

```jsx
{
    "_index" : "my_index",
    "_id" : "RldK4JwBVgHAqt4zIoQM",
    "_score" : 1.0,
    "_source" : {
       "name" : "LIM",
        "status" : "processed"
      }
}
```

- stasus 필드가 생성된 것을 확인할 수 있습니다.

**특정 파이프라인이 실행된 이후 실행되게 하고 싶다면 어떻게 해야할까?** 

```jsx
PUT _ingest/pipeline/pipeline_2
{
  "description": "second pipeline",
  "processors": [
    {
      "set": {
        "field": "step2",
        "value": "done"
      }
    }
  ]
}
```

파이프라인 1 생성

```jsx
PUT _ingest/pipeline/pipeline_1
{
  "description": "first pipeline", 
  "processors": [
    {
      "set": {
        "field": "step1",
        "value": "done"
      }, 
      "pipeline": {
        "name": "pipeline_2"
      }
    }
  ]
}
```

```jsx
POST my_index/_doc?pipeline=pipeline_1
{
  "name": "kim"
}

{
    "_index" : "my_index",
    "_id" : "E1dl4JwBVgHAqt4znJrK",
    "_score" : 1.0,
     "_source" : {
        "name" : "kim",
        "step2" : "done",
        "step1" : "done"
       }
 }

```

**Dissect Processor**

- 문자열을 일정한 패턴으로 잘라서 여러 필드로 분리하는 Ingest Pipeline processor이다.
- 예를 들어 이런 로그가 있다고 가정했을 때
    
    `2026-03-12 INFO User login success`
    

```jsx
timestamp: 2026-03-12
level: INFO
message: User login success
```

- 이런 식으로 나누고 싶을 때 사용한다.

**파이프라인 생성** 

```jsx
PUT _ingest/pipeline/my_dissect_pipeline
{
  "processors": [
    {
      "dissect": {
        "field": "message",
        "pattern": "%{date} %{level} %{content}"
      }
    }
  ]
}
```

**데이터 저장** 

```jsx
{
  "processors": [
    {
      "dissect": {
        "field": "message",
        "pattern": "%{date} %{level} %{content}"
      }
    }
  ]
}
```

**데이터 저장 형식**

```jsx
{
   "_index" : "logs",
   "_id" : "t1eQ4JwBVgHAqt4zQrWw",
   "_score" : 1.0,
   "_source" : {
      "date" : "2026-03-12",
      "level" : "INFO",
      "message" : "2026-03-12 INFO login_success",
      "content" : "login_success"
   }
}
```

엘라스틱 서치에서 인덱스의 셋팅을 변경하는 방법은 두 가지 방법이 있다.

1. _reindex
2. _update_by_query **

**Reindex (기존에 존재하는 인덱스를 기준하여 새로운 인덱스를 생성)**

```jsx
POST _reindex 
{
  "max_docs" : 100, // 최대 100개의 도큐먼트를 복사
  "source" : {
    "index": "blogs",
    "query": {
      "match": {
        "category": "Engineering" // 조건이 category에 Engineering이 들어가는 도큐먼트만 
      }
    }
  },
  "dest": {
    "index": "blog_fixed"
  }
}
```

**Reindex from a remote cluster**

- 원격의 인덱스에서 복사를 진행할 수 있는 기능을 만들 수 있다.

```jsx
POST _reindex 
{
  "source" : {
		  "remote": {
			  "host": "http://otherhost:9200",
			  "username" : "user",
			  "password" : "pass"
		  },
		  "index": "remote_index"
  },
  "dest": {
    "index": "blog_fixed"
  }
}
```

**update by query** 

- 특정 조건에 맞는 여러 문서를 한 번에 업데이트하는 API이다.

```jsx
조건 검색
   ↓
검색된 문서들
   ↓
일괄 업데이트
```

보통 문서 업데이트는 아래와 같이 한다. 하지만 한개의 문서만 업데이트 한다. 

```jsx
POST my_index/_update/1
{
  "doc": {
    "status": "done"
  }
}
```

**기본 구조** 

```jsx
POST index_name/_update_by_query
{
  "query": {
    ...
  },
  "script": {
    ...
  }
}
```

- query → 대상 문서 찾기 → script → 업데이트 수행

```jsx
POST logs/_update_by_query
{
  "query": {
    "match": {
      "level": "INFO"
    }
  }
}
```

**delete by query**

```jsx
POST logs/_delete_by_query
{
  "query": {
    "match": {
      "level": "DEBUG"
    }
  }
}
```

- match 되는 도큐먼트들 일괄 삭제

### 4.2 Enriching Data

- Enriching Data 는 기존 문서에 다른 인덱스의 데이터를 자동으로 붙여서(보강해서) 저장하는 기능을 의미한다.
- 즉 문서에 없는 정보를 다른 데이터에서 찾아서 자동으로 추가하는 것
1. Set up an enrich policy
2. Create an enrich index for the policy
3. Create an ingest pipeline with an enrich processor
4. Set up your index to use the pipeline 

1. **Set up an enrich policy** 

```jsx
PUT /_enrich/policy/user-policy
{
  "match": {
    "indices": "users",
    "match_field": "user_id",
    "enrich_fields": ["name", "company"]
  }
}
```

- user index에서 user_id로 매칭해서 name, company 가져오기

1. **Enrich Polish 실행(lookup index 실행)**

```jsx
POST /_enrich/policy/user-policy/_execute
```

1. **파이프라인 활용하여 저장** 

```jsx
POST logs/_doc?pipeline=user-enrich-pipeline
{
  "user_id": "A123",
  "action": "login"
}
```

1. **문서 저장** 

```jsx
POST logs/_doc?pipeline=user-enrich-pipeline
{
  "user_id": "A123",
  "action": "login"
}
```

1. **파이프라인을 거친 문서 확인** 

```jsx
{
   "_index" : "logs",
   "_id" : "L1jL5JwBVgHAqt4zFLXZ",
   "_score" : 1.0,
   "_source" : {
      "user_id" : "A123",
      "action" : "login",
      "user" : {
         "name" : "Saul",
         "company" : "Elastic",
         "user_id" : "A123"
   }
}
```

The `blogs` index on the remote cluster `cluster2` contains 7 documents. Index those 7 documents into your existing `blogs_fixed2` index on `cluster1` using the Reindex API. You will need the following details:

- the username is `training`
- the password is `nonprodpwd`
- the hostname for `cluster2` is `node5` and is using SSL on port 9204

Note that the `elasticsearch.yml` file on `cluster1` has all the necessary settings, so you will not need to change it. Here are the settings that were added for the remote reindex to work:

`reindex.remote.whitelist: node5:9204
reindex.ssl.certificate_authorities: /usr/share/elasticsearch/config/certificates/ca/ca.crt
reindex.ssl.verification_mode: none`

You can view the entire file by running the following command in the terminal:

```jsx
POST _reindex
{
  "source": {
    "remote": {
      "host": "https://node5:9204",
      "username": "training",
      "password": "nonprodpwd"
    },
    "index": "blogs"
  },
  "dest": {
    "index": "new_blogs"
  }
}

```
