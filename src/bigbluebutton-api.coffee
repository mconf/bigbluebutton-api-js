root = exports ? this

class BigBlueButtonApi

  # `url`: The complete URL to the server's API, e.g. `http://server.com/bigbluebutton/api`
  # `salt`: The shared secret of your server.
  # `debug`: Turn on debug messages, printed to `console.log`.
  constructor: (url, salt, debug=false) ->
    @url = url
    @salt = salt
    @debug = debug

  # Returna a list with the name of all available API calls.
  availableApiCalls: ->
    [ '/',
      'create',
      'join',
      'isMeetingRunning',
      'getMeetingInfo',
      'end',
      'getMeetings',
      'getDefaultConfigXML',
      'setConfigXML',
      'enter',
      'configXML',
      'signOut',
      'getRecordings',
      'publishRecordings',
      'deleteRecordings',
      'updateRecordings'
    ]

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
          [ "moderatorOnlyMessage", false ],
          [ "autoStartRecording", false ],
          [ "allowStartStopRecording", false ],
          [ /meta_\w+/, false ]
        ]
      when "join"
        [ [ "fullName", true ]
          [ "meetingID", true ],
          [ "password", true ] ,
          [ "createTime", false ],
          [ "userID", false ],
          [ "webVoiceConf", false ],
          [ "configToken", false ],
          [ "avatarURL", false ],
          [ "redirect", false ],
          [ "clientURL", false ]
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
        [ [ "meetingID", false ],
          [ "recordID", false ],
          [ "state", false ],
          [ /meta_\w+/, false ]
        ]
      when "publishRecordings"
        [ [ "recordID", true ],
          [ "publish", true ]
        ]
      when "deleteRecordings"
        [ [ "recordID", true ] ]
      when "updateRecordings"
        [ [ "recordID", true ],
          [ /meta_\w+/, false ]
        ]

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
  # Parameters received:
  # * `method`: The name of the API method
  # * `params`: An object with pairs of `parameter`:`value`. The parameters will be used only in the
  #             API calls they should be used. If a parameter name starts with `custom_`, it will
  #             be used in all API calls, removing the `custom_` prefix.
  #             Parameters to be used as metadata should use the prefix `meta_`.
  # * `filter`: Whether the parameters in `params` should be filtered, so that the API
  #             calls will contain only the parameters they accept. If false, all parameters
  #             in `params` will be added to the API call.
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
      query = "#{method}?#{query}"
      sep = '&'
    else
      query = method unless method is '/'
      sep = '?'
    unless method in noChecksumMethods()
      query = "#{query}#{sep}checksum=#{checksum}"

    "#{url}/#{query}"

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

  # Replaces the protocol for `bigbluebutton://`.
  setMobileProtocol: (url) ->
    url.replace(/http[s]?\:\/\//, "bigbluebutton://")

# Ruby-like include() method for Objects
include = (input, _function) ->
  _obj = new Object
  _match = null
  for key, value of input
    if _function.call(input, key, value)
      _obj[key] = value
   _obj

root.BigBlueButtonApi = BigBlueButtonApi

# creates keys without "custom_" and deletes the ones with it
filterCustomParameters = (params) ->
  for key, v of params
    if key.match(/^custom_/)
      params[key.replace(/^custom_/, "")] = v
  for key of params
    delete params[key] if key.match(/^custom_/)
  params

noChecksumMethods = ->
  ['setConfigXML', '/', 'enter', 'configXML', 'signOut']
