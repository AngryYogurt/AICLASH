
gnomeDir = []
ifFirstMove = true

turnLeft = (dir) ->
  dir >>= 1
  dir = 8 if dir is 0
  return dir

turnRight = (dir) ->
  dir <<= 1
  dir = 1 if dir > 8
  return dir

check = (game, src, dir) ->
  return (game.map.data[src.x][src.y] & dir) > 0

onMyTurn = (game) ->
  if ifFirstMove
    ifFirstMove = false
    if game.gnomes[0].x == 0
      gnomeDir[0] = 2
      gnomeDir[1] = 4
    else
      gnomeDir[0] = 1
      gnomeDir[1] = 8
  action = []
  gnomeDir[0] = turnRight(gnomeDir[0])
  while not check(game, game.gnomes[0], gnomeDir[0])
  	gnomeDir[0] = turnLeft(gnomeDir[0])
  action[0] = gnomeDir[0]
  gnomeDir[1] = turnLeft(gnomeDir[1])
  while not check(game, game.gnomes[1], gnomeDir[1])
  	gnomeDir[1] = turnRight(gnomeDir[1])
  action[1] = gnomeDir[1]
  availableActions = []
  for i in [1, 2, 4, 8]
    if check(game, game.gnomes[2], i)
    	availableActions.push(i)
  action[2] = availableActions[Math.floor(Math.random() * availableActions.length)]
  return action
