**Begin Session**
----
  Gets a new api key for the current session

* **URL**

       /api/sessions

* **Method:**

      `POST`

*  **HEADER Params**

       None

* **Data Params**

     **Required:**

      `email` <br />
      `password`

* **Success Response:**

      * **Code:** 201 CREATED <br />
      * **Content:** `{"user":{"email":"me@gmail.com",
      "api_key":"51407ba8e75c7b1819a12137d4df4ecb"}}`

* **Error Response:**

      * **Code:** 404 NOT FOUND <br />
        **Content:** ` {"success":false, "message":"email is blank"}`

    OR

      * **Code:** 404 NOT FOUND <br />
        **Content:** `{ "success":false, "message":"password missing"}`

    OR

      * **Code:** 422 UNPROCESSABLE ENTITY <br />
        **Content:** `{"success":false, "message":"Invalid email"}`

    OR

      * **Code:** 422 UNPROCESSABLE ENTITY <br />
        **Content:** `{"success":false, "message":"Invalid password"}`

* **Sample Call:**

      curl http://sms.knal.es/api/sessions -H 'content-type: application/json' -X
      POST -v -d '{"email":"me@gmail.com", "password":"secret"}'

**End Session**
----
  Deletes an api key and destroys current session

* **URL**

       /api/sessions

*  **Method:**

      `DELETE`

*  **HEADER Params**

      **Required:**

     `email` <br />
     `api_key`

* **Data Params**

      None

* **Success Response:**

       * **Code:** 200 <br />
         **Content:** `{"message":"Session deleted"}`

* **Error Response:**

       * **Code:** 404 NOT FOUND <br />
         **Content:** {"message":"email is missing"}`

    OR

       * **Code:** 404 NOT FOUND <br />
         **Content:** {"message":"api key is missing"}`

    OR

       * **Code:** 422 UNPROCESSABLE ENTITY <br />
         **Content:** `{"message":"Invalid email."}`

    OR

       * **Code:** 422 UNPROCESSABLE ENTITY <br />
         **Content:** `{"message":"Invalid api key."}`

* **Sample Call:**

       curl http://sms.knal.es/api/sessions -H 'content-type: application/json'        -H 'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb' -X
       DELETE

**Show User Balance**
----
  Returns current user balance

* **URL**

    /api/user/balance

* **Method:**

    `GET`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    None

* **Success Response:**

    * **Code:** 200 OK <br/>
      **Content:** `{"user":{"email":"me@gmail.com", "balance":"0.56"}}`

* **Error Response:**

    * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{"success":false, "message":"Invalid api key"}`

    OR

    * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{"success":false, "message":"Invalid email"}`

* **Sample Call:**

    curl http://sms.knal.es/api/user/balance -H 'content-type: application/json'
  -H 'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb'

**Sending Single Messages**
----
  Sends a single message to given numbers

* **URL**

    /api/single_messages

* **Method:**

    `POST`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    `single_message:`

    * `numbers`
    * `route`
    * `message`

    **Optional:**

    `single_message:`

    *  `backupSms`: Defaults to false
    *  `randomText`: Defaults to true

* **Success Response:**

    * **Code:** 200 OK<br />
      **Content:** `{"messsage":"Single message succesfully sent"}`

* **Error Response:**

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"route is blank"}'

    OR

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"message is blank"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":"Number 5335422890562 is not a valid Cubacel number"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":"Message can't be blank"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":"Not enough balance to cover a 0.05 expense"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":"Invalid route"}`

* **Sample Call:**

    curl http://sms.knal.es/api/single\_messages -H
  'content-type:application/json' -H 'email:me@gmail.com' -H
  'api\_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST -v -d
  '{"single\_message":{"numbers":["5352644047"], "route":"Prueba",
  "message":"Testing single message via api"}}'

* **Sample Call Without Random Text:**

    curl http://sms.knal.es/api/single\_messages -H
  'content-type:application/json' -H 'email:me@gmail.com' -H
  'api\_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST -v -d
  '{"single\_message":{"numbers":["5352644047"], "route":"Prueba",
  "message":"Testing message without random text via api", "randomText":
  false}}'

* **Notes:**

    Numbers **must** be an array

**Index Single Messages**
----
 Shows single messages of current user

* **URL**

    /api/single_messages

* **Method:**

    `GET`

* **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    None

* **Success Response:**

    * **Code:** 200 <br />
      **Content:** `{"messages": [{"message":"message 1","destinatarios":1,"identifier":45},{"message":"message x","destinatarios":1,"identifier":46}, ...]}`

  * **Sample Call:**

    curl http://sms.knal.es/api/single_messages -H 'Content-Type:application/json' -H 'email:me@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d'

**Show Single Message**
----
 Shows current user :id single message

* **URL**

    /api/single_messages/:id

* **Method:**

    `GET`

* **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    None

* **Success Response:**

    * **Code:** 200 <br />
      **Content:** `{"message":"message for documentation","number":["5355554444"],"identifier":"1"}`

* **Error Response:**

    * **Code:** 422 NOT FOUND <br />
      **Content:** `{"message":"invalid indentifier: 1"}'

  * **Sample Call:**

    curl http://sms.knal.es/api/single_messages/1 -H 'Content-Type:application/json' -H 'email:me@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d'

**Destroy Single Message**
----
 Destroys current user :id single message

* **URL**

    /api/single_messages/:id

* **Method:**

    `DELETE`

* **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    None

* **Success Response:**

    * **Code:** 301 Moved Permanently <br />
      **Content:** `{"message":"removed single message succefully"}`

* **Error Response:**

    * **Code:** 422 UNPROCESSABLE ENTITY<br />
      **Content:** `{"message":"invalid identifier: 1"}`

    OR

    * **Code:** 401 UNAUTHORIZED<br />
      **Content:** `{"message":"permission denied"}`

  * **Sample Call:**

    curl http://localhost:3000/api/single_messages/1 -H 'Content-Type:application/json' -H 'email:admin1@gmail.com' -H 'api_key: 2eefbf7dfab595e6d2339a21d42983bb' -X DELETE

**Index User Lists**
----
  Shows lists of current user

* **URL**

    /api/lists/searchs

* **Method:**

    `GET`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    None

* **Success Response:**

    * **Code:** 200 OK <br />
      **Content:** `{"lists":{"count":2, "data":[{"date":"2015-08-16",
  "name":"foo", "identifier":100}, {"date":"2015-10-18", "name":"bar",
  "identifier":192}]}}`

* **Error Response:**

    * **Code:** 400 BAD REQUEST<br />
      **Content:** `{"success":false, "message":"Invalid email"}`

    OR

    * **Code:** 401 UNAUTHORIZED <br />
      **Content:** `{"success":false, "message":"Invalid api key"}`


* **Sample Call:**

    curl http://sms.knal.es/api/lists/searchs -H 'content-type:application/json'
   -H 'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb'

**Retrieving Lists**
----
  Searchs a given list

* **URL**

    /api/list/searchs

* **Method:**

    `POST`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    `lists:`

    * `name`

* **Success Response:**

    * **Code:** 200 OK <br/>
      **Content:** `{"lists":[{"name":"foo", "numbers":["5352644047",
  "5352642266"]}]}`

* **Error Response:**


    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"list name is blank"}`

    OR

    * **Code:** 400 BAD REQUEST <br/>
      **Content:** `{"success":false, "message":"Invalid email"}`

    OR

    * **Code:** 401 UNAUTHORIZED <br/>
      **Content:** `{"success":false, "message":"Invalid api key"}`

* **Sample Call:**

    curl http://sms.knal.es/api/lists/searchs -H 'content-type:application/json'
  -H 'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb' -X
  POST -v -d '{"lists": {"name": ["foo"]}}'

* **Notes:**

    Name **must** be an array

**Creating Lists**
----
  Creates a given list

* **URL**

    /api/lists

* **Method:**

    `POST`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    `list:`

    *  `numbers`
    *  `name`

* **Success Response:**

    * **Code:** 201 Created
      **Content:** `{"message":"List was successfully created"}`

* **Error Response:**

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"name is blank"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":"numbers is empty"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"message":" name list invalid"}'

* **Sample Call:**

    curl http://sms.knal.es/api/lists -H 'content-type:application/json' -H
  'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST
  -v -d '{"list": {"numbers":["5352644047"], "name": "bar"}}'

* **Notes:**

    Numbers **must** be an array

**Show List**
----
  Show a list of current user

* **URL**

    /api/lists/45

* **Method:**

    `GET`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    None

* **Success Response:**

    * **Code:** 200 OK <br/>
      **Content:** `{"list":{"name":"list45","numbers":["5354567890"],"created_at":"2015-11-01T15:55:39.878-05:00"}}`

* **Error Response:**

    * **Code:** 422 UNPROCESSABLE ENTITY <br />
      **Content:** `{"error":"identifier 45 invalid"}'

* **Sample Call:**

    curl http://sms.knal.es/api/lists/45 -H 'Content-Type:application/json' -H 'email:me@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d'

**Update List**
----
  Update a list of current user

* **URL**

    /api/lists/45

* **Method:**

    `PUT`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    ** Required:**

    `list:`

    *  `numbers`
    *  `name`
    *  `remove`

* **Success Response:**

    * **Code:** 200 OK <br/>
      **Content:** `{"message":"The list was successfully update","option":"add"}`

* **Error Response:**

    * **Code:** 404 NOT FOUND<br />
      **Content:** `{"message":"name is blank"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY<br />
      **Content:** `{"message":"invalid name"}'

* **Sample Call:**

    curl http://sms.knal.es/api/lists -H 'Content-Type:application/json' -H 'email:me@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"list": {"name":"list1","numbers": ["5356782464"],"remove":false}}' -X PUT

* **Notes:**

    remove **must** be a boolean

**Destroy List**
----
  Destroy a list of current user

* **URL**

    /api/lists/45

* **Method:**

    `DELETE`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    ** Required:**

    `list:`

    *  `name`

* **Success Response:**

    * **Code:** 301 MOVED PERMANENTLY  <br/>
      **Content:** `{"message":"List: sms1 removed succefully "}`

* **Error Response:**

    * **Code:** 404 NOT FOUND<br />
      **Content:** `{"message":"name is blank"}'

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY<br />
      **Content:** `{"message":"invalid name"}'

* **Sample Call:**

    curl http://localhost:3000/api/lists -H 'Content-Type:application/json' -H 'email:me@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"list": {"name":"sms1"}}' -X DELETE

**Sending Bulk Messages**
----
  Sends bulk messages to given lists

* **URL**

    /api/bulk_messages

* **Method:**

    `POST`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    **Required:**

    `bulk_message:`

    *  `route`
    *  `message`
    *  `list_names`

* **Success Response:**

  * **Code:** 201 CREATED <br />
    **Content:** `{"messsage":"Send succefully"}`

* **Error Response:**

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"route is blank"}`

    OR

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"message is blank"}`

    OR

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"list_names is blank"}`

    OR

    * **Code:** 422 UNPROCESSABLE ENTRY <br />
      **Content:** `{"message":["errors",....]}`

    OR

    * **Code:** 422 UNPROCESSABLE ENTRY <br />
      **Content:** `{"message":"Invalid route"}`


* **Sample Call:**

    curl http://sms.knal.es/api/bulk\_messages -H
  'content-type:application/json' -H 'email:me@gmail.com' -H
  'api\_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST -d '{"bulk\_message":
  {"route":"Prueba", "message": "Testing bulk messages via api", "list_names":
  ["bar"]}}'

* **Notes:**

    ListNames **must** be an array

**Index Bulk Messages**
----
  Index bulk messages of current user

* **URL**

    /api/bulk_messages

* **Method:**

    `GET`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    None

* **Success Response:**

    * **Code:** 200 OK <br />
    **Content:** `{"bulk_messages":[{"messages":"message to all","lists":3,"numbers":10,"identifier":17},..]}`

* **Sample Call:**

    curl http://sms.knal.es/api/bulk_messages -H 'Content-Type:application/json' -H 'email:ab5@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"bulk_message": {"list_names":["aaaa"],"route":"bronce125","message": "mesage"}}' -X GET

**Show Bulk Messages**
----
  Show bulk messages of current user

* **URL**

    /api/bulk_messages/27

* **Method:**

    `GET`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    None

* **Success Response:**

    * **Code:** 200 OK <br />
      **Content:** `{"bulk_message":{"message":"asfasdfas","route":"Bron1","lists":1,"numbers":1,"list_names":["listOne"]}}`

* **Error Response:**

    * **Code:** 404 NOT FOUND <br />
      **Content:** `{"message":"Identifier (id: 527) invalid"}`


* **Sample Call:**

    curl http://sms.knal.es/api/bulk_messages/27 -H 'Content-Type:application/json' -H 'email:ab5@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"bulk_message": {"list_names":["aaaa"],"route":"bronce125","message": "mesage"}}' -X GET

**Destroy Bulk Messages**
----
  Destroy bulk messages of current user

* **URL**

    /api/bulk_messages/27

* **Method:**

    `DELETE`

*  **HEADER Params**

     **Required:**

     `email` <br />
     `api_key`

* **Data Params**

    None

* **Success Response:**

    * **Code:** 301 OK <br />
      **Content:** `{"bulk_message":{"message":"removed single message succefully"}`

* **Error Response:**


* **Error Response:**

    * **Code:** 401 UNAUTHORIZED<br />
      **Content:** `{"message":"permission denied"}`

    OR

    * **Code:** 422 UNPROCESSABLE ENTITY<br />
      **Content:** `{"message":"invalid identifier: 27"}`

* **Sample Call:**

    curl http://sms.knal.es/api/bulk_messages/527 -H 'Content-Type:application/json' -H  email:ab5@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"bulk_message":  {"list_names":["aaaa"],"route":"bronce125","message": "mesage"}}' -X DELETE

* **Sample Call:**

    curl http://sms.knal.es/api/bulk_messages/527 -H 'Content-Type:application/json' -H  email:ab5@gmail.com' -H 'api_key: ceb372b3e5c8c913eb036efb0575504d' -d '{"bulk_message":  {"list_names":["aaaa"],"route":"bronce125","message": "mesage"}}' -X DELETE

**Authentication in entity body of the Api**
----
  Authentication in the body of the http request

* **URL**

       /api/single_messages

* **Method:**

      `POST`

*  **HEADER Params**

       None

* **Data Params**

     **Required:**

      `authenticate_api:`

    *  `email`
    *  `api_key`

* **Sample Call:**

      curl http://sms.knal.es/api/single_messages  -H  'content-type: application/json'  -d  '{"authenticate_api":{"email":"me@mail.com","api_key":"2eefbf7dyg4zax05e6d2339a21d42983bb"},"single_message":{"route":"Gold","numbers":["5356789044"],"message":"test authenticate in body of sms.knal.es"}}'  -X POST -v

**Generate Users id@knal.es**
----
  Generate users automatic with id@knal.es design

* **URL**

       /api/users/create_user_api 

* **Method:**

      `POST`

*  **HEADER Params**

       None

* **Data Params**

       None

* **Sample Call:**

      curl http://sms.knal.es/api/users/create_user_api  -H 'Content-Type:application/json' -H 'email:admin1@gemail.com' -H 'api_key:5282e99a1fe5e5711b0082eef4a8338a'  -X POST

* **Notes:**

    Only users with privileges admin
