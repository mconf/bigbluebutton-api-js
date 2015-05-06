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

Add these libraries and `bigbluebutton-api.js` to your page. Then you can get the links to the API calls
with a code similar to this example (code in Coffeescript):

```coffeescript
# Create an API object passing the url and the shared secret
api = new BigBlueButtonApi("http://test-install.blindsidenetworks.com/bigbluebutton/api/",
                           "8cd8ef52e8e101574e400365b55e11a6")

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

urls = []
for method in api.availableApiCalls()
  urls.push { name: method, url: api.urlFor(method, params) }
```

This call will create an array with several objects, each one defining a single API call. These objects have the following format:

```coffeescript
{
  name: 'join'
  url: 'http://test-install.blindsidenetworks.com/bigbluebutton/api/create?name=random-266119&meetingID=random-266119&moderatorPW=mp&attendeePW=ap&voiceBridge=76262&record=false&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4'
}
```

Where:

* `name`: the name of the API method.
* `url`: the URL to call the method, as returned by `bigbluebutton-api-js`.



### Custom parameters

You can pass custom parameters using the prefix `custom_`. These parameters will be included in
**all** API calls.


```coffeescript
params =
  name: "random-123"
  meetingID: "random-123"
  custom_customParameter: "random"
  custom_another: 123
url = api.urlFor('join', params)
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
url = api.urlFor('create', params)
```

Will return URLs such as:

```coffeescript
"http://server.com/bigbluebutton/api/create?name=random-123&meetingID=random-123&meta_any=random&meta_another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
```

### Custom API calls

You can pass any method you'd like to `urlFor()`, even if it's not a method supported
by default on BigBlueButton's API. **All** the parameters passed to `urlFor` will be
added to the API call.


```coffeescript
params =
  meetingID: "random-9998650"
  meta_any: "random"
  custom_another: 123
url = api.urlFor('customApiCall', params)
```

Will return URLs such as:

```coffeescript
"http://server.com/bigbluebutton/api/customApiCall?meetingID=random-123&meta_any=random&another=123&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"

### More

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
