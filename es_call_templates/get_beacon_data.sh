#!/bin/sh

# Parameters surrounded by {{ }}:
# logstash, epoch_start, epoch_end, applicationid, metrictypeid, directory

curl -k -XGET 'https://logger:new$mission$2@es.doubledutch.me/logstash-2015.07.08/_search' -d '{
  "query": {
    "filtered": {
      "query": {
        "bool": {
          "should": [
            {
              "query_string": {
                "query": "*"
              }
            }
          ]
        }
      },
      "filter": {
        "bool": {
          "must": [
            {
              "range": {
                "@timestamp": {
                  "from": 1436313600000,
                  "to": 1436399999000
                }
              }
            },
            {
              "fquery": {
                "query": {
                  "query_string": {
                    "query": "CheckpointData.Type:seamlessloginsuccess"
                  }
                },
                "_cache": true
              }
            },
            {
              "fquery": {
                "query": {
                  "query_string": {
                    "query": "MetricTypeId:6"
                  }
                },
                "_cache": true
              }
            }
          ],
          "must_not": [
            {
              "fquery": {
                "query": {
                  "query_string": {
                    "query": "name:(\"PingdomBot\")"
                  }
                },
                "_cache": true
              }
            },
            {
              "fquery": {
                "query": {
                  "query_string": {
                    "query": "request:(\"/robots.txt\")"
                  }
                },
                "_cache": true
              }
            }
          ]
        }
      }
    }
  },
  "highlight": {
    "fields": {},
    "fragment_size": 2147483647,
    "pre_tags": [
      "@start-highlight@"
    ],
    "post_tags": [
      "@end-highlight@"
    ]
  },
  "size": 0,
  "sort": [
    {
      "@timestamp": {
        "order": "desc",
        "ignore_unmapped": true
      }
    }
  ]
}' > /home/jteruya/seamless_login/es_data/metrictypeid_6_logstash-2015.07.08.json

