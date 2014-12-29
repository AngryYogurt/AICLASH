importScripts('stdlib.js');
var game = {};

onmessage = function(sdata) {
    var data = sdata.data;
    if(data.type === 'init') {
        importScripts(data.src);
        game.src = data.src;
        game.width = data.width;
        game.height = data.height;
        game.map = {};
        game.map.data = [];
        game.map.visited = [];
        game.gnomes = [];
        for(var i = 0; i < game.width; i ++ ) {
            game.map.data[i] = [];
            game.map.visited[i] = [];
        }
    } else if(data.type === 'query') {
        for(var i in data.buf) {
            if(data.buf[i].type === 'gnome') {
                game.gnomes[data.buf[i].id] = {
                    x: data.buf[i].x,
                    y: data.buf[i].y,
                    vision: data.buf[i].vision
                };
            } else {
                game.map.data[data.buf[i].x][data.buf[i].y] = data.buf[i].data;
                game.map.visited[data.buf[i].x][data.buf[i].y] = data.buf[i].visited;
            }
        }
        postMessage({
            type: 'action',
            action: onMyTurn(game)
        });
    }
};

var onMyTurn = function() {
    return [0, 0, 0];
};
