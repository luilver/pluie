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
    **Content:** `{"user":{"email":"me@gmail.com",
    "api_key":"51407ba8e75c7b1819a12137d4df4ecb"}}`

* **Error Response:**

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{"success":false, "message":"Invalid password"}`


* **Sample Call:**

  curl http://sms.knal.es/api/sessions -H 'content-type: application/json' -X
  POST -v -d '{"email":"me@gmail.com", "password":"secret"}'

**End Session**
----
  Deletes an api key and destroys current session

* **URL**

  /api/sessions

* **Method:**

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
    **Content:** `{"message":"Invalid email."}`

  OR
  * **Code:** 404 NOT FOUND <br />
    **Content:** `{"message":"Invalid api key."}`

* **Sample Call:**

  curl http://sms.knal.es/api/sessions -H 'content-type: application/json' -X
  DELETE -v -d '{"email":"me@gmail.com", "password":"secret"}'

**Show User Balance**
----
  Returns current user balance

* **URL**

  /api/user/balance

* **Method:**

  `GET`

*  **HEADER Params**

   None

* **Data Params**

   None

* **Success Response:**

    **Content:** `"2.123"`

* **Error Response:**

  **Content:** `{"success":false, "message":"Invalid api key"}`

  OR

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
   *  `numbers`
   *  `route`
   *  `message`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{"messsage":"Single message succesfully sent"}`

* **Error Response:**

  * **Code:** 422 UNPROCESSABLE ENTRY <br />
    **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  * **Code:** 422 UNPROCESSABLE ENTRY <br />
    **Content:** `{"success":false, "message":"Invalid password"}`

  OR

  * **Code:** 404 <br />
    **Content:** `{"message":"Invalid route"}`

* **Sample Call:**

  curl http://sms.knal.es/api/single\_messages -H
  'content-type:application/json' -H 'email:me@gmail.com' -H
  'api\_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST -v -d
  '{"single\_message":{"numbers":["5352644047"], "route":"Prueba",
  "message":"Testing single meesage via api"}}'

* **Notes:**

  Numbers **must** be an array

**Index User Lists**
----
  Shows lists of current user

* **URL**

  /api/lists/searchs

* **Method:**

  `GET`

*  **HEADER Params**

  None

* **Data Params**

  None

* **Success Response:**

  **Content:** `{"lists":{"count":2, "data":[{"date":"2015-08-16",
  "name":"foo", "identifier":100}, {"date":"2015-10-18", "name":"bar",
  "identifier":192}]}}`

* **Error Response:**

  **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  **Content:** `{"success":false, "message":"Invalid password"}`

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
   *  `name`

* **Success Response:**

  **Content:** `{"lists":[{"name":"foo", "numbers":["5352644047",
  "5352642266"]}]}`

* **Error Response:**

  **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  **Content:** `{"success":false, "message":"Invalid password"}`

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

   `lists:`
   *  `numbers`
   *  `name`

* **Success Response:**

  **Content:** `{"message":"The list was successfully created"}`

* **Error Response:**

  **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  **Content:** `{"success":false, "message":"Invalid password"}`

* **Sample Call:**

  curl http://sms.knal.es/api/lists -H 'content-type:application/json' -H
  'email:me@gmail.com' -H 'api_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST
  -v -d '{"list": {"numbers":["5352644047"], "name": "bar"}}'

* **Notes:**

  Numbers **must** be an array

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

  * **Code:** 200 <br />
    **Content:** `{"messsage":"Bulk message succesfully sent"}`

* **Error Response:**

  * **Code:** 422 UNPROCESSABLE ENTRY <br />
    **Content:** `{"success":false, "message":"Invalid email"}`

  OR

  * **Code:** 422 UNPROCESSABLE ENTRY <br />
    **Content:** `{"success":false, "message":"Invalid password"}`

  OR

  * **Code:** 404 <br />
    **Content:** `{"message":"Invalid route"}`

  OR

  * **Code:** 404 <br />
    **Content:** `{"message":"Invalid list"}`

* **Sample Call:**

  curl http://sms.knal.es/api/bulk\_messages -H
  'content-type:application/json' -H 'email:me@gmail.com' -H
  'api\_key:51407ba8e75c7b1819a12137d4df4ecb' -X POST -d '{"bulk\_message":
  {"route":"Prueba", "message": "Testing bulk messages via api", "list_names":
  ["bar"]}}'

* **Notes:**

  ListNames **must** be an array
