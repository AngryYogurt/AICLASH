that = this

onMyTurn = do ->
  if not that.console?
    that.console =
      log: -> null
      table: -> null
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
  lastDir = 2
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
    #debugger
    prune(map)
    pruneJingWeiTianHai(map, 0)

    myWay.push({i: gnome.i, j: gnome.j} for gnome in game.gnomes)


    if ii == 1000
      console.table(mapC)

    action = []
    gi = game.gnomes[0].i
    gj = game.gnomes[0].j
    v = map[gi][gj]

    if v == 0
      debugger
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
      powers[d] += 10000 if game.map.visited.get(ngi, ngj) # TODO: 只对部分地精生效


    nd = _.chain(powers)
    .pairs()
    .sortBy((x) -> -x[1])
    .map((x) -> x[0])
    .find((x) -> (v & x) > 0)
    .value()
    action[0] = nd
    action[1] = nd
    action[2] = action[0]

    lastDir = action[0]
    if not isStartAtLeftTop
      action = _.map(action, (v) -> backDir[v])
    return action

  pruneJingWeiTianHai = (map, T_T) ->
    gnome = game.gnomes[T_T]
    gi = gnome.i
    gj = gnome.j

    rightAlwaysWall = true
    for j in [gj+1..mapW-1]
      if map[gi][j] != 0
        rightAlwaysWall = false
        break
    if rightAlwaysWall
      log(gnome)
      for j in [gj..mapW-1]
        myVisited[gi][j]++

      bfsVisited = []
      for i in [0..mapH-1]
        bfsVisited[i] = []
      travels = [{i:0, j:mapW-1, cameFrom:0}]
      while travels.length > 0
        t = travels.shift()
        map[t.i][t.j] = 0
        for d in [1,2,4,8]
          switch d
            when 1
              ngi = t.i - 1
              ngj = t.j
            when 2
              ngi = t.i
              ngj = t.j + 1
            when 4
              ngi = t.i + 1
              ngj = t.j
            when 8
              ngi = t.i
              ngj = t.j - 1
          if ngi < 0 or ngi >= mapH or ngj < 0 or ngj >= mapW or bfsVisited[ngi][ngj]
            continue
          if myVisited[ngi][ngj]
            if (map[ngi][ngj] & backDir[d]) > 0
              map[ngi][ngj] -= backDir[d]
          else
            bfsVisited[ngi][ngj] = true
            travels.push({i:ngi, j:ngj, cameFrom:backDir[d]})

    downAlwaysWall = true
    for i in [gi+1..mapH-1]
      if map[i][gj] != 0
        downAlwaysWall = false
        break
    if downAlwaysWall
      for i in [gi..mapH-1]
        myVisited[i][gj]++

      bfsVisited = []
      for i in [0..mapH-1]
        bfsVisited[i] = []
      travels = [{i:mapH-1, j:0, cameFrom:0}]
      while travels.length > 0
        t = travels.shift()
        map[t.i][t.j] = 0
        for d in [1,2,4,8]
          switch d
            when 1
              ngi = t.i - 1
              ngj = t.j
            when 2
              ngi = t.i
              ngj = t.j + 1
            when 4
              ngi = t.i + 1
              ngj = t.j
            when 8
              ngi = t.i
              ngj = t.j - 1
          if ngi < 0 or ngi >= mapH or ngj < 0 or ngj >= mapW or bfsVisited[ngi][ngj]
            continue
          if myVisited[ngi][ngj]
            if (map[ngi][ngj] & backDir[d]) > 0
              map[ngi][ngj] -= backDir[d]
          else
            bfsVisited[ngi][ngj] = true
            travels.push({i:ngi, j:ngj, cameFrom:backDir[d]})



  prune = (map) ->
    cutVisited = []
    for i in [0..mapH - 1]
      cutVisited[i] = []

    pruneTravel = (i, j, cameFrom) ->
      cutVisited[i][j] = 1

      if cameFrom == 0
        powers = _.object([1, 2, 4, 8], [0, 0, 0, 0])
        powers[2] += 100
        powers[4] += 100
        powers[backDir[lastDir]] -= 10000
        dirs = _.chain(powers)
        .pairs()
        .sortBy((x) -> -x[1])
        .map((x) -> x[0] - 0)
        .value()
      else
        dirs = [2, 4, 1, 8]

      for d in dirs
        if (map[i][j] & d) > 0 and cameFrom != d
          switch d
            when 1
              ngi = i - 1
              ngj = j
            when 2
              ngi = i
              ngj = j + 1
            when 4
              ngi = i + 1
              ngj = j
            when 8
              ngi = i
              ngj = j - 1
          if map[i][j] == undefined
            continue
          if cutVisited[ngi][ngj]?
            if map[i][j] == cameFrom + d
              map[i][j] -= d
              map[ngi][ngj] -= backDir[d]
            break
          pruneTravel(ngi, ngj, backDir[d])
      cutVisited[i][j] = undefined


    for gnome in game.gnomes
      pruneTravel(gnome.i, gnome.j, 0)

  return onMyTurn
