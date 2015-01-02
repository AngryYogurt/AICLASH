log = console.log

mapH = 24
mapW = 32
map = []
_game = {}
for i in [0..mapH - 1]
  map[i] = []

lastDir = 0

isStartAtLeftTop = true

ii = 0

remember = ->
  travelVisions (i, j) ->
    if map[i][j] == undefined
      map[i][j] = _game.map.data.get(i, j)

travelVision = (gnome, callback) ->
  vision = gnome.vision
  top = Math.max(gnome.getR() - vision, 0)
  bottom = Math.min(gnome.getR() + vision, mapH - 1)
  for i in [top..bottom]
    len = vision - Math.abs(i - gnome.getR())
    left = Math.max(gnome.getC() - len, 0)
    right = Math.min(gnome.getC() + len, mapW - 1)
    for j in [left..right]
      callback(i, j)

travelVisions = (callback) ->
  for gnome in _game.gnomes
    travelVision(gnome, callback)

isDeadEnd = (v) ->
  return v in [1, 2, 4, 8]

isGnome = (i, j)->
  return _.any(_game.gnomes, (gnome) -> gnome.getR() == i and gnome.getC() == j)

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
  #console.log(i, j, map[i][j], "m--m", d, "equal",)
  console.table(map)

_mapGet = (i, j) ->
  if not isStartAtLeftTop
    x = mapH - i - 1
    y = mapW - j - 1
  else
    x = i
    y = j
  return this[y][x]

_getR = ->
  if not isStartAtLeftTop
    r = mapH - this.y - 1
  else
    r = this.y
  return r

_getC = ->
  if not isStartAtLeftTop
    c = mapW - this.x - 1
  else
    c = this.x
  return c

backDir =
  1: 4
  4: 1
  2: 8
  8: 2

init = _.once ->
  isStartAtLeftTop = _game.gnomes[0].x == 0 and _game.gnomes[0].y == 0

onMyTurn = (game) ->
  game.map.data.get = _mapGet
  game.map.visited.get = _mapGet
  for gnome in game.gnomes
    gnome.getR = _getR
    gnome.getC = _getC
  _game = game
  init()

  #  if ii < 20
  remember()
  simplifyMap()
  #    if ii == 1
  #      console.table(map)


  ii++
  if ii == 1000
    console.table(map)
  #
  action = []
  v = map[game.gnomes[0].getR()][game.gnomes[0].getC()]
  if v == 0
    debugger
  dirs = [2, 4, 1, 8]
  dirs = _.without(dirs, backDir[lastDir])
  dirs.push(backDir[lastDir])
  action[0] = _.find(dirs, (x) -> (v & x) > 0)

  lastDir = action[0]
  #
  action[1] = action[2] = action[0]
  if not isStartAtLeftTop
    action = _.map(action, (v) -> backDir[v])
  console.log(game.gnomes[0].getR(), game.gnomes[0].getC())
  console.log(dirs)
  console.log(action)
  return action


turnLeft = (dir) ->
  dir >>= 1
  dir = 8 if dir == 0
  return dir

turnRight = (dir) ->
  dir <<= 1
  dir = 1 if dir > 8
  return dir

check = (_game, src, dir) ->
  return (_game.map.data[src.x][src.y] & dir) > 0
