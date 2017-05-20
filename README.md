# Progress

We will only write `docker-compose up` to run the whole stack if it doesn’t work the task fails.

In Instabug each company that subscribes is provided with an application token, when the SDK is deployed in their apps, it reports bugs using this token, this way we know which bugs belong to which application.
Each bug is given a bug number ( other than the database id), this number starts from 1 for each application token. And, is incremented for each new bug for each application. **[DONE]**

We need you to create a RESTful API to simulate this behavior **[DONE?State]**
Create two models:
- bug:
  We want to track these fields
    - application token ( the unique identifier for the application ) **[DONE]**
    - number ( unique number per application, this is not the database primary key ) **[DONE]**
    - status ( 'new', 'In-progress', 'closed' ) **[DONE?Verification]**
    - priority ( 'minor', 'major', 'critical' ) **[DONE?Verification]**
    - comment **[DONE]**
    - state_id **[NOT REALLY]**
- state: (one to one relation with Bug) []
  Defines the state of the mobile while reporting the bug, we want to track these fields
    - device ( The device name, ex: 'iPhone 5' ) **[DONE]**
    - os ( the name of the operating system of the phone ) **[DONE]**
    - memory ( Number in mb, ex: '1024' ) **[DONE]**
    - storage ( Number in mb, example '20480' ) **[DONE]**


Create a Docker Compose file: (Use bridge networking or ports other than default) **[DONE?nokogiri_build_issues]**
1. Elasticsearch container.
2. Rabbitmq container.
3. Rails container.
4. DB container.

The requirements:
1. Working Docker-compose file (only `docker-compose up` to run the whole stack) **[DONE]**
2. List of commands to test the app **[]**
3. Elasticsearch with partial filtering for comments field (All fields should match exactly except `comment` which should allow partial matching. similar to Mysql like query '%XYZ%'. Don't use the wildcard/regexp query.) **[DONE]**
4. The `POST /bugs` endpoint doesn't need to write to the DB directly, but instead it should relay the insertion to RabbitMQ worker and use a consumer to process the published jobs in RabbitMQ, but it should still respond with the correct bug number. Make sure that bugs for the same application don't get duplicate numbers if two bugs are getting processed in the same time. **[DONE]**
5. Create an endpoint `GET /bugs/[number]`, which fetches the bug using the number and application token, and returns the attributes in a JSON **[DONE?]**. Adjust the database indices to minimize the response time. **[]**

Bonus:
- Write specs to test the endpoints, add happy and unhappy scenarios. **[]**
- Api versioning. **[]**
