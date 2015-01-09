onMyTurn = do ->
  log = -> console.log(arguments)

  game = {}
  mapH = 75
  mapW = 100
  map = []
  myVisited = []
  myLooked = []
  mapPower = []
  myWay = []

  for i in [0..mapH - 1]
    map[i] = []
    myVisited[i] = []
    myLooked[i] = []
    mapPower[i] = []
    for j in [0..mapW - 1]
      myVisited[i][j] = 0
      mapPower[i][j] = (i + j) * 100

  mapPower[mapH - 1][mapW - 1] += 999999
  mapPower[0][mapW - 1] += 10000
  mapPower[mapH - 1][0] += 10000
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
          myVisited[_i][_j]++
          if (map[i][j] & d) > 0
            map[i][j] -= d
  #log(i, j, map[i][j], "m--m", d, "equal",)

  simplifyMapC = (m) ->
    for i in [0..mapH - 1]
      for j in [0..mapW - 1]
        do (i, j) ->
          while isDeadEnd(m[i][j])
            #console.log("find dead", i, j, map[i][j], "go to")
            __i = i
            __j = j
            switch m[i][j]
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
            if m[i][j] != undefined
              m[__i][__j] = 0
              if (map[i][j] & d) > 0
                m[i][j] -= d

  _mapGet = (i, j) ->
    if not isStartAtLeftTop
      x = mapH - i - 1
      y = mapW - j - 1
      return backDir[this[y][x]]
    else
      x = i
      y = j
      return this[y][x]

  backDir =
    0: 0
    1: 4
    2: 8
    3: 12
    4: 1
    5: 5
    6: 9
    7: 13
    8: 2
    9: 6
    10: 10
    11: 14
    12: 3
    13: 7
    14: 11
    15: 15

  init = _.once ->
    isStartAtLeftTop = game.gnomes[0].x == 0 and game.gnomes[0].y == 0
    mapH = game.height
    mapW = game.width

  onMyTurn = (g) ->
    game = g
    ii++

    init()

    game.map.data.get = _mapGet
    game.map.visited.get = _mapGet
    for gnome in game.gnomes
      if not isStartAtLeftTop
        gnome.i = mapH - gnome.y - 1
        gnome.j = mapW - gnome.x - 1
      else
        gnome.i = gnome.y
        gnome.j = gnome.x

    rememberMap()
    simplifyMap()
    mapC = _.map(map, (row) -> row.slice(0))
    simplifyMapC(mapC)

    myWay.push({i: gnome.i, j: gnome.j} for gnome in game.gnomes)


    if ii == 1000
      console.table(mapC)

    action = []
    gi = game.gnomes[0].i
    gj = game.gnomes[0].j
    v = map[gi][gj]

    if v == undefined
      debugger
    dirs = [2, 4, 1, 8]
    myVisited[gi][gj]++
    powers = _.object([1, 2, 4, 8], [0, 0, 0, 0])

    powers[2] += 100
    powers[4] += 100

    powers[backDir[lastDir]] -= 10000

    for d in _.filter([1, 2, 4, 8], (x) -> (v & x) > 0)
      switch d
        when 1
          ngi = gi - 1
          ngj = gj
        when 2
          ngi = gi
          ngj = gj + 1
        when 4
          ngi = gi + 1
          ngj = gj
        when 8
          ngi = gi
          ngj = gj - 1
      powers[d] -= myVisited[ngi][ngj] * 100
      powers[d] += 10000 if game.map.visited.get(ngi, ngj)  # TODO: 只对部分地精生效



    nd = _.chain(powers)
    .pairs()
    .sortBy((x) -> -x[1])
    .map((x) -> x[0])
    .find((x) -> (v & x) > 0)
    .value()
    action[0] = nd
    action[1] = action[2] = action[0]

    lastDir = action[0]
    if not isStartAtLeftTop
      action = _.map(action, (v) -> backDir[v])
    return action

  return onMyTurn

  pruneJingWeiTianHai = (map, part, i) ->
    if part == 'up'
      for p in myWay
        j = 0
        while myVisited[j][i] == 0
          map[j][i] = 0
          j++
      map[j + 1] -= 1
    else if part == 'left'
      for i in [0..mapH - 1]
        j = 0
        while myVisited[i][j] == 0
          map[i][j] = 0
          j++
      map[j + 1] -= 8

  prune = (map) ->
    for i in [0..mapH - 1]
      for j in [0..mapW - 1]
        do (i, j) ->
          while map[i][j] != 0
            __i = i
            __j = j
            switch map[i][j]
              when 1
                i--
              when 2
                j++
              when 4
                i++
              when 8
                j--
            if myLooked[i][j]
              while not (map[i][j] in [3, 5, 9, 6, 10, 12])
                return
            myLooked[__i][__j] = true


# TODO: jingweitianhai