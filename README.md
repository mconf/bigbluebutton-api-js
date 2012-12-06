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

Usage
-----

This library requires:
* [jQuery](http://jquery.com/) >= 1.7
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
  name: "random-9998650"
  meetingID: "random-9998650"
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

# Will return an object with all URLs, similar to:
{
    create: "http://test-install.blindsidenetworks.com/bigbluebutton/api/create?name=random-266119&meetingID=random-266119&moderatorPW=mp&attendeePW=ap&welcome=%3Cbr%3EWelcome%20to%20%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E!&voiceBridge=76262&record=false&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
  , end: "http://test-install.blindsidenetworks.com/bigbluebutton/api/end?meetingID=random-266119&password=mp&checksum=4f0df85832063a4606786a8f4207a6629fcc"
  , getMeetings: "http://test-install.blindsidenetworks.com/bigbluebutton/api/getMeetings?random=446147049&checksum=94ba109ea7348ea7d89239855812fdd7bdaf"
  ...
}
```

Features
--------

* No matter what parameters you pass to `getUrls`, the lib will only use the parameters that are supported for each API call.
* You can pass meta parameters to `create`, just use `meta_*`, for example: `meta_myParam`, `meta_HELLO`.
* You can pass custom parameters with `custom_*`. The prefix `custom_` will be removed and the parameter will be passed to **all** API calls. So, for example, `custom_isGuest` will become `isGuest`, and will be passed to all API calls. This is useful when developing new API features.
* If you want only the URL for a single API method, use the methods `urlFor`. For example: `api.urlFor("isMeetingRunning", params)`.


Development
-----------

At first, install [Node.js](http://nodejs.org/) (see `package.json` for
the specific version required).

Install the dependencies with:

    npm install -d

Then, to compile the coffee files into javascript, run:

    cake build

This will compile all `*.coffee` files in `/src` to javascript files
in `/lib`.

To watch for changes and compile the files automatically run:

    cake watch

License
-------

Distributed under The MIT License (MIT), see `LICENSE`.
