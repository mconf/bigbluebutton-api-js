root = exports ? this

class BigBlueButtonApi
  constructor: (url, salt, mobileKey) ->
    @url = url
    @salt = salt
    @mobileKey = mobileKey

  # Returns a list of supported parameters for a given API method
  # The return is an array of arrays composed by:
  #   [0] - RegEx or string with the parameter name
  #   [1] - true if the parameter is required, false otherwise
  paramsFor: (param) ->
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
        ]
      when "join"
        [ [ "fullName", true ]
          [ "meetingID", true ],
          [ "password", true ] ,
          [ "createTime", false ],
          [ "userID", false ],
          [ "webVoiceConf", false ],
        ]
      when "isMeetingRunning"
        [ [ "meetingID", true ] ]
      when "end"
        [ [ "meetingID", true ],
          [ "password", true ],
        ]
      when "getMeetingInfo"
        [ [ "meetingID", true ],
          [ "password", true ],
        ]
      when "getMeetings"
        [ [ "random", true ] ]
      when "getRecordings"
        [ [ "meetingID", true ],
          [ /meta_\w+/, false ],
        ]
      when "publishRecordings"
        [ [ "recordID", true ],
          [ "publish", true ]
        ]
      when "deleteRecordings"
        [ [ "recordID", true ] ]

  # Filter `params` to allow only parameters that can be passed
  # to the method `method`.
  # To use custom parameters, name them `custom_parameterName`.
  # The `custom_` prefix will be removed when generating the urls.
  filterParams: (params, method) ->
    filters = @paramsFor(method)
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

      # creates keys without "custom_" and deletes the ones with it
      for key, v of r
        if key.match(/^custom_/)
          r[key.replace(/^custom_/, "")] = v
      for key of r
        delete r[key] if key.match(/^custom_/)
      r

  # Returns an object with URLs to all methods in BigBlueButton' API.
  getUrls: (params, customCalls=null) ->
    params ?= {}
    params.random = Math.floor(Math.random() * 1000000000).toString()

    params.password = params.attendeePW
    joinAtt = @urlFor("join", params)
    joinAttMobile = @replaceMobileProtocol(joinAtt)
    params.password = params.moderatorPW
    joinMod = @urlFor("join", params)
    joinModMobile = @replaceMobileProtocol(joinMod)
    # for all other urls, the password will be moderatorPW

    ret =

      # standard API
      'create': @urlFor("create", params)
      'join (as moderator)': joinMod
      'join (as attendee)': joinAtt
      'isMeetingRunning': @urlFor("isMeetingRunning", params)
      'getMeetingInfo': @urlFor("getMeetingInfo", params)
      'end': @urlFor("end", params)
      'getMeetings': @urlFor("getMeetings", params)
      'getRecordings': @urlFor("getRecordings", params)
      'publishRecordings': @urlFor("publishRecordings", params)
      'deleteRecordings': @urlFor("deleteRecordings", params)

      # link to use in mobile devices
      'join from mobile (as moderator)': joinModMobile
      'join from mobile (as attendee)': joinAttMobile

      # mobile API
      'mobile: getTimestamp': @urlForMobileApi("getTimestamp", params)
      'mobile: getMeetings': @urlForMobileApi("getMeetings", params)
      'mobile: create': @urlForMobileApi("create", params)

    if customCalls?
      for call in customCalls
        ret[ 'custom call ' + call + ':'] =  @urlFor(call, params, false)

    ret

  # Returns a url for any `method` available in the BigBlueButton API
  # using the parameters in `params`.
  urlFor: (method, params, filter=true) ->
    params = @filterParams(params, method) if filter

    url = @url

    # list of params
    paramList = []
    for key, param of params
      if key? and param?
        paramList.push "#{encodeURIComponent(key)}=#{encodeURIComponent(param)}"
    query = paramList.join("&") if paramList.length > 0

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

  # Calls `urlFor` and changes the generated url to point
  # to the mobile API.
  urlForMobileApi: (method, params) ->
    url = @urlFor method, params, true

    # change the path
    oldPat = new RegExp("bigbluebutton\\/api\\/" + method + "\\?")
    url = url.replace(oldPat, "demo/mobile.jsp?action=" + method + "&")

    # removes the old checksum to add a new one later
    url = url.replace(/[&]?checksum=.*$/, "")

    # add the timestamp and the checksum
    unless url.match(/action=getTimestamp/)
      url = url + "&timestamp=" + new Date().getTime()
    query = ""
    matched = url.match(/\?(.*)$/)
    query = matched[1] if matched? and matched[1]?
    url = url + "&checksum=" + @checksum(method, query, true)

  # Replaces the protocol for `bigbluebutton://`.
  replaceMobileProtocol: (url) ->
    url.replace(/http[s]?\:\/\//, "bigbluebutton://")

  # Calculates the checksum for an API call `method` with
  # the params in `query`.
  checksum: (method, query, forMobile) ->
    query ||= ""
    if forMobile? and forMobile
      str = query + @mobileKey
    else
      str = method + query + @salt
    Crypto.SHA1(str)

# Ruby-like include() method for Objects
include = (input, _function) ->
  _obj = new Object
  _match = null
  for key, value of input
    if _function.call(input, key, value)
      _obj[key] = value
   _obj

root.BigBlueButtonApi = BigBlueButtonApi
