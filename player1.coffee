mapH = 24
mapW = 32
gnomeDir = []
map = []
_game = {}
for i in [0..mapH - 1]
  map[i] = []

first = true
isStartAtLeftTop = true

ii = 0

remember = ->
  travelVisions (i, j) ->
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
  return _.any(_game.gnomes, (gnome) -> gnome.y == i and gnome.x == j)

isDest = (i, j) ->
  return i == mapH - 1 and j == mapW - 1

simplifyMap = ->
  travelVisions (i, j) ->
    while isDeadEnd(map[i][j])
      if isGnome(i, j) or isDest(i, j)
        break
      if ii == 1
        console.log("find dead", i, j, map[i][j], "go to")
      v = map[i][j]
      map[i][j] = 0
      switch v
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
        map[i][j] -= d
      if ii == 1
        console.log(i, j, map[i][j], "m--m", d, "equal",)

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
  if ii == 12
    console.table(map)
  #
  action = []
  gnomeDir[0] = turnRight(gnomeDir[0])
  while not check(_game, _game.gnomes[0], gnomeDir[0])
    gnomeDir[0] = turnLeft(gnomeDir[0])
  action[0] = gnomeDir[0]
  gnomeDir[1] = turnLeft(gnomeDir[1])
  while not check(_game, _game.gnomes[1], gnomeDir[1])
    gnomeDir[1] = turnRight(gnomeDir[1])
  action[1] = gnomeDir[1]
  availableActions = []
  for i in [1, 2, 4, 8]
    if check(_game, _game.gnomes[2], i)
      availableActions.push(i)
  action[2] = availableActions[Math.floor(Math.random() * availableActions.length)]
  #
  if not isStartAtLeftTop
    dirMap = {1: 4, 4: 1, 2: 8, 8: 2}
    action = _.map(action, (v) -> dirMap[v])
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
