bigbluebutton-api-js
====================

`bigbluebutton-api-js` is a very simple Javascript library that
generates links to all methods in
[BigBlueButton's API](http://code.google.com/p/bigbluebutton/wiki/API).
It's written in [Coffeescript](http://coffeescript.org/) and should
work in the browser or in [Node.js](http://nodejs.org/) applications.

Usage
-----

This library requires:
* jQuery >= 1.7
* [CryptoJS](http://code.google.com/p/crypto-js/), that can be found
  in the `vendor` directory.

Once you add these libraries to your page, you can get the links with
(code in Coffeescript):

```coffeescript
# Create an API object passing the url, the salt and the mobile salt
api = new BigBlueButtonApi("http://test-install.blindsidenetworks.com/bigbluebutton/api/",
                           "8cd8ef52e8e101574e400365b55e11a6", "8cd8e")

# A hash of parameters.
# The parameter names are the same names BigBlueButton expects to
# receive in the API calls. The lib will make sure that, for each
# API call, only the parameters it support will be used.
params =
  name: "random-9998650"
  meetingID: "random-9998650"
  moderatorPW: "mp"
  attendeePW: "ap"
  welcome: "<br>Welcome to <b>%%CONFNAME%%</b>!"
  attendeePW: "ap"
  fullName: "User 8584148"
  meetingID: "random-9998650"
  moderatorPW: "mp"
  password: "mp"
  publish: false
  random: "416074726"
  record: false
  recordID: "random-9998650"
  voiceBridge: "75858"
urls = api.getUrls(params)

# Will return an object with all URLs, similar to:
{
    create: "http://test-install.blindsidenetworks.com/bigbluebutton/api/create?name=random-266119&meetingID=random-266119&moderatorPW=mp&attendeePW=ap&welcome=%3Cbr%3EWelcome%20to%20%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E!&voiceBridge=76262&record=false&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4"
  , end: "http://test-install.blindsidenetworks.com/bigbluebutton/api/end?meetingID=random-266119&password=mp&checksum=4f0df85832063a4606786a8f4207a6629fcc"
  , getMeetings: "http://test-install.blindsidenetworks.com/bigbluebutton/api/getMeetings?random=446147049&checksum=94ba109ea7348ea7d89239855812fdd7bdaf"
  ...
}
```

Development
-----------

At first install [Node.js](http://nodejs.org/), see `package.json` for
the specific version required.

Install the dependencies with:

    npm install -d

Then, to compile the coffee files into javascript, run:

    cake build

This will compile all `*.coffee` files in `/src` to javascript files
in `/lib/`.

To watch for changes and compile the files automatically run:

    cake watch
