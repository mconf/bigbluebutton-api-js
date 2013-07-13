bigbluebutton-api-js
====================

`bigbluebutton-api-js` is a very simple Javascript library that
generates links to all methods in
[BigBlueButton's API](http://code.google.com/p/bigbluebutton/wiki/API).
It's written in [Coffeescript](http://coffeescript.org/) and should
work in the browser or in [Node.js](http://nodejs.org/) applications.

Example
-------

Open `example/index.html` or check http://mconf.github.com/bigbluebutton-api-js
for a quick example of what this lib does.

Features
--------

* Gives you links to all API methods.
* No matter what parameters you pass to it, the lib will only use the parameters that are supported for each API call.
* You can pass meta parameters to `create` using the prefix `meta_`.
* You can pass any custom parameters to all API calls with the prefix `custom_`.
* You can get links for custom API calls. This is useful when developing new API methods.
* You can also get links to a single method or just get the checksum for a call.

Usage
-----

This library requires:
* [CryptoJS](http://code.google.com/p/crypto-js/), that can be found
  in the `vendor` directory.

Add these libraries and `bigbluebutton-api.js` to your page, and then get the links with
(code in Coffeescript):

```coffeescript
# Create an API object passing the url, the salt and the mobile salt
api = new BigBlueButtonApi("http://test-install.blindsidenetworks.com/bigbluebutton/api/",
                           "8cd8ef52e8e101574e400365b55e11a6", "03b07")

# A hash of parameters.
# The parameter names are the same names BigBlueButton expects to receive in the API calls.
# The lib will make sure that, for each API call, only the parameters supported will be used.
params =
  name: "random-123"
  meetingID: "random-123"
  moderatorPW: "mp"
  attendeePW: "ap"
  password: "mp" # usually equals "moderatorPW"
  welcome: "<br>Welcome to <b>%%CONFNAME%%</b>!"
  fullName: "User 8584148"
  publish: false
  random: "416074726"
  record: false
  recordID: "random-9998650"
  voiceBridge: "75858"
  meta_anything: "My Meta Parameter"
  custom_customParameter: "Will be passed as 'customParameter' to all calls"
urls = api.getUrls(params)
```

This call will return an object with all URLs, similar to the examples below (not real examples, they don't have
all parameters specified above):

```coffeescript
{
    create: "http://test-install.blindsidenetworks.com/bigbluebutton/api/create?name=random-123&meetingID=random-123&moderatorPW=mp&attendeePW=ap&welcome=%3Cbr%3EWelcome%20to%20%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E!&voiceBridge=76262&record=false&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
  , end: "http://test-install.blindsidenetworks.com/bigbluebutton/api/end?meetingID=random-123&password=mp&checksum=4f0df85832063a4606786a8f4207a6629fcc"
  , getMeetings: "http://test-install.blindsidenetworks.com/bigbluebutton/api/getMeetings?random=123&checksum=94ba109ea7348ea7d89239855812fdd7bdaf"
  ...
}
```

### Custom parameters

You can pass custom parameters using the prefix `custom_`. These parameters will be included in
**all** API calls.


```coffeescript
params =
  name: "random-123"
  meetingID: "random-123"
  custom_customParameter: "random"
  custom_another: 123
urls = api.getUrls(params)
```

Will return URLs such as:

```coffeescript
"http://server.com/bigbluebutton/api/create?name=random-123&meetingID=random-123&customParameter=random&another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
```

### Metadata

Pass metadata parameters using the prefix `meta_`. These parameters will be included in only in the API calls
that support metadata.

```coffeescript
params =
  name: "random-9998650"
  meetingID: "random-9998650"
  meta_any: "random"
  meta_another: 123
urls = api.getUrls(params)
```

Will return URLs such as:

```coffeescript
"http://server.com/bigbluebutton/api/create?name=random-123&meetingID=random-123&meta_any=random&meta_another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
```

### Custom API calls

You can pass an array of custom API calls to `getUrls()`. This array should contain strings with the name of your
custom API calls. **All** the parameters will be used in **all** the custom API calls.


```coffeescript
params =
  meetingID: "random-9998650"
  meta_any: "random"
  custom_another: 123
urls = api.getUrls(params, ["customApiCall", "anotherCall"])
```

Will return URLs such as:

```coffeescript
"http://server.com/bigbluebutton/api/customApiCall?meetingID=random-123&meta_any=random&another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
"http://server.com/bigbluebutton/api/anotherCall?meetingID=random-123&meta_any=random&another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
```

### More

* If you want only the URL for a single API method, use the methods `urlFor`. For example: `api.urlFor("isMeetingRunning", params)`.
* To get just the checksum for a call you can use the method `checksum`. For example: `api.checksum("isMeetingRunning", "meetingID=mymeeting&custom=1", false)`.


Development
-----------

At first, install [Node.js](http://nodejs.org/) (see `package.json` for the specific version required).

Install the dependencies with:

    npm install

Then, to compile the coffee files into javascript, run:

    cake build

This will compile all `*.coffee` files in `/src` to javascript files in `/lib`.

To watch for changes and compile the files automatically run:

    cake watch

License
-------

Distributed under The MIT License (MIT), see `LICENSE`.
