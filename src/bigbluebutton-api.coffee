root = exports ? this

class BigBlueButtonApi

  # `url`: The complete URL to the server's API, e.g. `http://server.com/bigbluebutton/api`
  # `salt`: The shared secret of your server.
  # `debug`: Turn on debug messages, printed to `console.log`.
  constructor: (url, salt, debug=false) ->
    @url = url
    @salt = salt
    @debug = debug

  # Returns an array with object containing the URLs and description of all methods in
  # BigBlueButton's API.
  #
  # The objects inside the array are in the following format:
  #   {
  #     name: 'join'
  #     description: 'join (as moderator)'
  #     url: 'http://test-install.blindsidenetworks.com/bigbluebutton/api/create?name=random-266119&meetingID=random-266119&moderatorPW=mp&attendeePW=ap&welcome=%3Cbr%3EWelcome%20to%20%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E!&voiceBridge=76262&record=false&checksum=6c529b6e31fbce9668fd66d99a09da7a78f4'
  #   }
  #
  # Where:
  # * `name`: the name of the API method
  # * `description`: a description of the method, usually its name only or the name plus a small
  #   description if it's an specific call for the target method
  # * `url`: the URL to call the method
  #
  # Parameters received:
  # * `params`: An object with pairs of `parameter`:`value`. The parameters will be used only in the
  #             API calls they should be used. If a parameter name starts with `custom_`, it will
  #             be used in all API calls, removing the `custom_` prefix.
  #             Parameters to be used as metadata should use the prefix `meta_`.
  # * `customCalls`: An array of strings that represent the name of custom API calls that should
  #                  also be returned. Can be any string and will always be returned. All the
  #                  parameters in `params` will be applied to these calls.
  getUrls: (params, customCalls=null) ->
    params ?= {}

    params.password = params.attendeePW
    joinAtt = @urlFor("join", params)
    joinAttMobile = replaceMobileProtocol(joinAtt)
    params.password = params.moderatorPW
    joinMod = @urlFor("join", params)
    joinModMobile = replaceMobileProtocol(joinMod)
    # for all other urls, the password will be moderatorPW

    _elem = (name, desc, url) ->
      { name: name, description: desc, url: url }

    ret = [
      _elem('root', 'root', @urlFor("", params)),
      _elem('create', 'create', @urlFor("create", params)),
      _elem('join', 'join (as moderator)', joinMod),
      _elem('join', 'join (as attendee)', joinAtt),
      _elem('isMeetingRunning', 'isMeetingRunning', @urlFor("isMeetingRunning", params))
      _elem('getMeetingInfo', 'getMeetingInfo', @urlFor("getMeetingInfo", params))
      _elem('end', 'end', @urlFor("end", params))
      _elem('getMeetings', 'getMeetings', @urlFor("getMeetings", params))
      _elem('getDefaultConfigXML', 'getDefaultConfigXML', @urlFor("getDefaultConfigXML", params))
      _elem('setConfigXML', 'setConfigXML', @urlFor("setConfigXML", params))
      _elem('getRecordings', 'getRecordings', @urlFor("getRecordings", params))
      _elem('publishRecordings', 'publishRecordings', @urlFor("publishRecordings", params))
      _elem('deleteRecordings', 'deleteRecordings', @urlFor("deleteRecordings", params))

      # link to use in mobile devices
      _elem('join', 'join from mobile (as moderator)', joinModMobile)
      _elem('join', 'join from mobile (as attendee)', joinAttMobile)
    ]

    if customCalls?
      for call in customCalls
        ret.push _elem(call, "custom call: #{call}", @urlFor(call, params, false))

    ret

  # Returns a list of supported parameters in the URL for a given API method.
  # The return is an array of arrays composed by:
  #   [0] - RegEx or string with the parameter name
  #   [1] - true if the parameter is required, false otherwise
  urlParamsFor: (param) ->
    switch param
      when "create"
        [ [ "meetingID", true ]
          [ "name", true ],
          [ "attendeePW", false ] ,
          [ "moderatorPW", false ],
          [ "welcome", false ],
          [ "dialNumber", false ],
          [ "voiceBridge", false ],
          [ "webVoice", false ],
          [ "logoutURL", false ],
          [ "maxParticipants", false ],
          [ "record", false ],
          [ "duration", false ],
          [ /meta_\w+/, false ],
          [ "redirectClient", false ],
          [ "clientURL", false ]
        ]
      when "join"
        [ [ "fullName", true ]
          [ "meetingID", true ],
          [ "password", true ] ,
          [ "createTime", false ],
          [ "userID", false ],
          [ "webVoiceConf", false ],
          [ "configToken", false ],
          [ "avatarURL", false ]
        ]
      when "isMeetingRunning"
        [ [ "meetingID", true ] ]
      when "end"
        [ [ "meetingID", true ],
          [ "password", true ]
        ]
      when "getMeetingInfo"
        [ [ "meetingID", true ],
          [ "password", true ]
        ]
      when "getRecordings"
        [ [ "meetingID", true ],
          [ /meta_\w+/, false ]
        ]
      when "publishRecordings"
        [ [ "recordID", true ],
          [ "publish", true ]
        ]
      when "deleteRecordings"
        [ [ "recordID", true ] ]
      when "setConfigXML"
        [ [ "meetingID", true ],
          [ "configXML", true ] ]

  # Filter `params` to allow only parameters that can be passed
  # to the method `method`.
  # To use custom parameters, name them `custom_parameterName`.
  # The `custom_` prefix will be removed when generating the urls.
  filterParams: (params, method) ->
    filters = @urlParamsFor(method)
    if not filters? or filters.length is 0
      {}
    else
      r = include params, (key, value) ->
        for filter in filters
          if filter[0] instanceof RegExp
            return true if key.match(filter[0]) or key.match(/^custom_/)
          else
            return true if key.match("^#{filter[0]}$") or key.match(/^custom_/)
        return false

    filterCustomParameters(r)

  # Returns a url for any `method` available in the BigBlueButton API
  # using the parameters in `params`.
  urlFor: (method, params, filter=true) ->
    console.log "Generating URL for", method if @debug
    if filter
      params = @filterParams(params, method)
    else
      params = filterCustomParameters(params)

    url = @url

    # mounts the string with the list of parameters
    paramList = []
    if params?
      # add the parameters in alphabetical order to prevent checksum errors
      # (happens in setConfigXML)
      keys = []
      keys.push(property) for property of params
      keys = keys.sort()
      for key in keys
        param = params[key] if key?
        paramList.push "#{@encodeForUrl(key)}=#{@encodeForUrl(param)}" if param?
      query = paramList.join("&") if paramList.length > 0
    else
      query = ''

    # calculate the checksum
    checksum = @checksum(method, query)

    # add the missing elements in the query
    if paramList.length > 0
      query = method + "?" + query
      query += "&"
    else
      query = method + "?"
    query += "checksum=" + checksum

    url + "/" + query

  # Calculates the checksum for an API call `method` with
  # the params in `query`.
  checksum: (method, query) ->
    query ||= ""
    console.log "- Calculating the checksum using: '#{method}', '#{query}', '#{@salt}'" if @debug
    str = method + query + @salt
    c = Crypto.SHA1(str)
    console.log "- Checksum calculated:", c if @debug
    c

  # Encodes a string to set it in the URL. Has to encode it exactly like BigBlueButton does!
  # Otherwise the validation of the checksum might fail at some point.
  encodeForUrl: (value) ->
    encodeURIComponent(value)
      .replace(/%20/g, '+') # use + instead of %20 for space to match what the Java tools do.
      .replace(/[!'()]/g, escape) # encodeURIComponent doesn't escape !'()* but browsers do, so manually escape them.
      .replace(/\*/g, "%2A")

# Ruby-like include() method for Objects
include = (input, _function) ->
  _obj = new Object
  _match = null
  for key, value of input
    if _function.call(input, key, value)
      _obj[key] = value
   _obj

# Replaces the protocol for `bigbluebutton://`.
replaceMobileProtocol = (url) ->
  url.replace(/http[s]?\:\/\//, "bigbluebutton://")

root.BigBlueButtonApi = BigBlueButtonApi

# creates keys without "custom_" and deletes the ones with it
filterCustomParameters = (params) ->
  for key, v of params
    if key.match(/^custom_/)
      params[key.replace(/^custom_/, "")] = v
  for key of params
    delete params[key] if key.match(/^custom_/)
  params
