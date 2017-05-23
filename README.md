# Instabug Challenge

I applied at [Instabug](https://instabug.com/) a while ago. I recently received this challenge to work on as part of the process.

---

## Challenge Statement
We will only write `docker-compose up` to run the whole stack if it doesn’t work the task fails.

In Instabug each company that subscribes is provided with an application token, when the SDK is deployed in their apps, it reports bugs using this token, this way we know which bugs belong to which application.
Each bug is given a bug number ( other than the database id), this number starts from 1 for each application token. And, is incremented for each new bug for each application.

We need you to create a RESTful API to simulate this behavior
Create two models:
- bug:
  We want to track these fields
    - application token ( the unique identifier for the application )
    - number ( unique number per application, this is not the database primary key )
    - status ( 'new', 'In-progress', 'closed' )
    - priority ( 'minor', 'major', 'critical' )
    - comment
    - state_id
- state: (one to one relation with Bug)
  Defines the state of the mobile while reporting the bug, we want to track these fields
    - device ( The device name, ex: 'iPhone 5' )
    - os ( the name of the operating system of the phone )
    - memory ( Number in mb, ex: '1024' )
    - storage ( Number in mb, example '20480' )


Create a Docker Compose file: (Use bridge networking or ports other than default)
1. Elasticsearch container.
2. Rabbitmq container.
3. Rails container.
4. DB container.

The requirements:
1. Working Docker-compose file (only `docker-compose up` to run the whole stack)
2. List of commands to test the app
3. Elasticsearch with partial filtering for comments field (All fields should match exactly except `comment` which should allow partial matching. similar to Mysql like query '%XYZ%'. Don't use the wildcard/regexp query.)
4. The `POST /bugs` endpoint doesn't need to write to the DB directly, but instead it should relay the insertion to RabbitMQ worker and use a consumer to process the published jobs in RabbitMQ, but it should still respond with the correct bug number. Make sure that bugs for the same application don't get duplicate numbers if two bugs are getting processed in the same time.
5. Create an endpoint `GET /bugs/[number]`, which fetches the bug using the number and application token, and returns the attributes in a JSON. Adjust the database indices to minimize the response time.

Bonus:
- Write specs to test the endpoints, add happy and unhappy scenarios.
- Api versioning.


## My Approach

I first started with [Austin Kabiru's Build a RESTful JSON API With Rails 5 - Part One](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one) as it was the most relative and easiest one I found. It had nested resources, his testing setup is very easy and nice using `rspec`.


> Create two models:
> - bug
> - state

In RoR this was as easy as

```
$ rails generate model Bug app_token:string number:integer status:string priority:string comment:text
```

```sh
$ rails generate model State device:string os:string memory:integer storage:integer bug:references
```

*Though I opted for having the foreign key on `State` side, as that seemed more logical with the [`has_one`](http://guides.rubyonrails.org/association_basics.html#the-has-one-association) relationship. Though I guess it is still doable with `state_id` on `Bug` side.*

---

> Each bug is given a bug number ( other than the database id), this number starts from 1 for each application token. And, is incremented for each new bug for each application.

Although this might have been doable in postgres without introducing any more components to the stack using [Two Level Gapless Sequence](http://www.varlena.com/GeneralBits/130.php), I opted for using [`redis`'s atomic increment](https://redis.io/commands/incr) operation that does exactly what I need.

---

> Elasticsearch with partial filtering for comments field (All fields should match exactly except `comment` which should allow partial matching. similar to Mysql like query '%XYZ%'. Don't use the wildcard/regexp query.)

After looking up the possible ways that this could be done, I guess using `Ngrams` is the right solution. Elasticsearch has a [nice tutorial about it](https://www.elastic.co/guide/en/elasticsearch/guide/current/ngrams-compound-words.html) on their guides.

---

> The `POST /bugs` endpoint doesn't need to write to the DB directly, but instead it should relay the insertion to RabbitMQ worker and use a consumer to process the published jobs in RabbitMQ, but it should still respond with the correct bug number. Make sure that bugs for the same application don't get duplicate numbers if two bugs are getting processed in the same time.

Again `redis` was a savior here too since `incr` operation in redis is atomic. On the web app side, only the validation and `number` generation on success were done. The rest was relayed to the worker running in the background by serializing bug and state into `JSON` object, throwing it in a `RabbitMQ` queue, using [PubSub scheme](https://www.rabbitmq.com/tutorials/tutorial-one-ruby.html)

---

> Create an endpoint `GET /bugs/[number]`, which fetches the bug using the number and application token, and returns the attributes in a JSON. Adjust the database indices to minimize the response time.

Getting the bug is just easy `find_by` operation, but I still need to figure out how to optimize the indicies, my guess would be to index both `app_token` and `number`

---

> Api versioning.

If I understood well, this could be done using `namespaces`, so you'll have `/api/v1` and then later you could've `/api/v2` also.

```ruby
namespace :api, defaults: {format: :json}  do
   namespace :v1 do
    resources :bugs, param: :number
  end
end
```

---

> Create a Docker Compose file: (Use bridge networking or ports other than default)
> 1. Elasticsearch container.
> 2. Rabbitmq container.
> 3. Rails container.
> 4. DB container.

This was a bit challenging. Getting `elasticsearch`, `rabbitmq`, and `postgres` containers up was somewhat easy as the images are already ready.

Getting Rails up, I faced some issues:

1. I first intended to base on ruby `alpine` image to keep image size to the minimum, but had to switch to a debain based image to overcome gem native build issues, I could've digged behind it and managed to get it running on alpine, but I opted for this solution to save time (my time).
2. Getting the rails container to wait for elasticsearch to be up was a bit challenging and I opted in for the hack you could see in `docker-compose` web service and `wait-curl.sh` as I wait until elasticsearch responds to curl request before starting the server.
3. Setting up `postgres` and `elasticsearch` indicies before any container.


### List of commands to test the app

I exposed rails api on port `4000` and elasticsearch on port `9300`

#### New bug

```sh
$ curl -X POST \
    http://localhost:4000/api/v1/bugs \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '{
  	"app_token":"ubertoken",
  	"status":"new",
  	"priority":"minor",
  	"comment":"ThisISjustA testC omment",
  	"state": {
  		"device":"LG G4",
  		"os":"Android 6.0",
  		"memory": 2048,
  		"storage": 4096
  	}
  }'
```

#### New bug with the same token

```sh
$ curl -X POST \
    http://localhost:4000/api/v1/bugs \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '{
  	"app_token":"ubertoken",
  	"status":"new",
  	"priority":"minor",
  	"comment":"My number should be hopefully 2 now",
  	"state": {
  		"device":"Samsung S3",
  		"os":"Android 4.0",
  		"memory": 2048,
  		"storage": 4096
  	}
  }'
```

#### New bug with a different token

```sh
$ curl -X POST \
    http://localhost:4000/api/v1/bugs \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '{
  	"app_token":"lyfttoken",
  	"status":"new",
  	"priority":"minor",
  	"comment":"New Token New Life",
  	"state": {
  		"device":"Samsung S3",
  		"os":"Android 4.0",
  		"memory": 2048,
  		"storage": 4096
  	}
  }'
```

#### Get a specific bug

```sh
$ curl -X GET \
  'http://localhost:4000/api/v1/bugs/1?app_token=lyfttoken' \
  -H 'cache-control: no-cache' \
```

#### Elasticsearch partial search in comment

```sh
$ curl -X POST \
    http://localhost:9300/instaapibugs/_search \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '{                  
      "query": {
          "match": {
              "comment": "is just"
          }
      }
  }'
```

#### Elasticsearch exact match

```sh
$ curl -X POST \
    http://localhost:9300/instaapibugs/_search \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '{                  
      "query": {
          "match": {
              "app_token": "ubertoken"
          }
      }
  }'
```

## TODO

- Model values validation
- Try to move foreign key in `State` to `Bug`
- Write specs to test the endpoints, add happy and unhappy scenarios.
