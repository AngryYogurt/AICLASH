onMyTurn = do ->
  log = -> console.log(arguments)

  game = {}
  mapH = 24
  mapW = 32
  map = []
  for i in [0..mapH - 1]
    map[i] = []
  lastDir = 0
  isStartAtLeftTop = true

  ii = 0

  rememberMap = ->
    travelVisions (i, j) ->
      if map[i][j] == undefined
        map[i][j] = game.map.data.get(i, j)

  travelVision = (gnome, callback) ->
    vision = gnome.vision
    top = Math.max(gnome.i - vision, 0)
    bottom = Math.min(gnome.i + vision, mapH - 1)
    for i in [top..bottom]
      len = vision - Math.abs(i - gnome.i)
      left = Math.max(gnome.j - len, 0)
      right = Math.min(gnome.j + len, mapW - 1)
      for j in [left..right]
        callback(i, j)

  travelVisions = (callback) ->
    for gnome in game.gnomes
      travelVision(gnome, callback)

  isDeadEnd = (v) ->
    return v in [1, 2, 4, 8]

  isGnome = (i, j)->
    return _.any(game.gnomes, (gnome) -> gnome.i == i and gnome.j == j)

  isDest = (i, j) ->
    return i == mapH - 1 and j == mapW - 1

  simplifyMap = ->
    travelVisions (i, j) ->
      while isDeadEnd(map[i][j])
        if isGnome(i, j) or isDest(i, j)
          break
        #console.log("find dead", i, j, map[i][j], "go to")
        _i = i
        _j = j
        switch map[i][j]
          when 1
            i--
            d = 4
          when 2
            j++
            d = 8
          when 4
            i++
            d = 1
          when 8
            j--
            d = 2
        if map[i][j] != undefined
          map[_i][_j] = 0
          map[i][j] -= d
          if map[i][j] < 0
            debugger
            return
    #log(i, j, map[i][j], "m--m", d, "equal",)

  _mapGet = (i, j) ->
    if not isStartAtLeftTop
      x = mapH - i - 1
      y = mapW - j - 1
    else
      x = i
      y = j
    return this[y][x]

  backDir =
    1: 4
    4: 1
    2: 8
    8: 2

  init = _.once ->
    isStartAtLeftTop = game.gnomes[0].x == 0 and game.gnomes[0].y == 0

  onMyTurn = (g) ->
    game = g
    ii++

    game.map.data.get = _mapGet
    game.map.visited.get = _mapGet
    for gnome in game.gnomes
      if not isStartAtLeftTop
        gnome.i = mapH - gnome.y - 1
        gnome.j = mapW - gnome.x - 1
      else
        gnome.i = gnome.y
        gnome.j = gnome.x

    init()

    rememberMap()
    simplifyMap()

    if ii == 1000
      console.table(map)

    action = []
    v = map[game.gnomes[0].i][game.gnomes[0].j]
    if v == 0
      debugger
    dirs = [2, 4, 1, 8]
    dirs = _.without(dirs, backDir[lastDir])
    dirs.push(backDir[lastDir])
    action[0] = _.find(dirs, (x) -> (v & x) > 0)
    action[1] = action[2] = action[0]

    lastDir = action[0]
    if not isStartAtLeftTop
      action = _.map(action, (v) -> backDir[v])

    log(game.gnomes[0].i, game.gnomes[0].j)
    log(dirs)
    log(action)

    return action

  return onMyTurn
