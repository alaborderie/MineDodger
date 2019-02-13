import hxd.Key;

enum HeroDirectionEnum {
    DOWN;
    LEFT;
    UP;
    RIGHT;
}

@:publicFields
class Game extends hxd.App {

    public static var instance:Game;

    var currentLevel:Int = 0;
    var maxLevel: Int = 0;
    public var tiles:Array<Array<entities.GameTile>> = [
        [null, null, null, null, null, null],
        [null, null, null, null, null, null],
        [null, null, null, null, null, null],
        [null, null, null, null, null, null],
        [null, null, null, null, null, null],
        [null, null, null, null, null, null]
    ];
    var world:h2d.Layers;
    var startButton: h2d.Text;
    var currentLevelText: h2d.Text;
    var maxLevelText: h2d.Text;
    var hero: entities.Hero;

    override function init() {
        super.init();

        currentLevelText = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        currentLevelText.setPosition(100, 50);

        maxLevelText = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        maxLevelText.setPosition(600, 50);

        startButton = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        startButton.setPosition(300, 300);
        startButton.text = 'Click here to start playing';
        new h2d.Interactive(300, 100, startButton).onClick = function(event:hxd.Event) {
            startGame();
        }
    }

    static function main() {
        instance = new Game();
    }

    function startGame() {
        startButton.remove();
        currentLevel = 1;
        startLevel();
    }

    function updateScores() {
        currentLevelText.text = 'Current level: ' + currentLevel;
        maxLevelText.text = 'Max level reached: ' + maxLevel;
    }

    function startLevel() {
        updateScores();
        hero = new entities.Hero(0,0);
        for (y in [0, 1, 2, 3, 4, 5]) {
            for (x in [0, 1, 2, 3, 4, 5]) {
                var tileType = entities.GameTile.GameTileTypeEnum.PATH;
                if (x == 0 && y == 0) {
                    tileType = entities.GameTile.GameTileTypeEnum.HERO;
                } else if (x == 5 && y == 5) {
                    tileType = entities.GameTile.GameTileTypeEnum.LAST;
                } else {
                    tileType = entities.GameTile.GameTileTypeEnum.LANDMINE;
                }
                new entities.GameTile(x, y, tileType);
            }
        }
        generatePath();
    }

    function generatePath() {
        var x = 0;
        var y = 0;
        while (x != 5 || y != 5) {
            if (x != 0 || y != 0)
                tiles[y][x].type = entities.GameTile.GameTileTypeEnum.PATH;
            var direction = Std.random(10);
            if (direction == 0 && x > 0) {
                x--;
            }
            if (direction == 1 && y > 0) {
                y--;
            }
            if (direction > 1 && direction < 6 && x < 5){
                x++;
            }
            if (direction >= 6 && y < 5) {
                y++;
            }
        }
        updateTiles();
        haxe.Timer.delay(function() {
            hideLandMines();
            handleKeyboardInput();
        }, 3000);
    }

    function updateTiles() {
        for (row in tiles) {
            for (tile in row) {
                tile.update();
            }
        }
    }

    function hideLandMines() {
        for (row in tiles) {
            for (tile in row) {
                if (tile.type == entities.GameTile.GameTileTypeEnum.LANDMINE) {
                    tile.isHidden = true;
                    tile.update();
                }
            }
        }
    }

    function onEvent(event: hxd.Event) {
        if (event.kind == hxd.Event.EventKind.EKeyDown) {
            if (event.keyCode == Key.DOWN && hero.y < 5) {
                moveHero(HeroDirectionEnum.DOWN);
            }
            if (event.keyCode == Key.LEFT && hero.x > 0) {
                moveHero(HeroDirectionEnum.LEFT);
            }
            if (event.keyCode == Key.UP && hero.y > 0) {
                moveHero(HeroDirectionEnum.UP);
            }
            if (event.keyCode == Key.RIGHT && hero.x < 5) {
                moveHero(HeroDirectionEnum.RIGHT);
            }
        }
    }

    function handleKeyboardInput() {
        hxd.Window.getInstance().addEventTarget(onEvent);
    }

    function moveHero(direction: HeroDirectionEnum) {
        tiles[hero.y][hero.x].type = entities.GameTile.GameTileTypeEnum.PATH;
        tiles[hero.y][hero.x].update();
        switch(direction) {
            case HeroDirectionEnum.UP: hero.y--;
            case HeroDirectionEnum.DOWN: hero.y++;
            case HeroDirectionEnum.LEFT: hero.x--;
            case HeroDirectionEnum.RIGHT: hero.x++;
        }
        if (tiles[hero.y][hero.x].type == entities.GameTile.GameTileTypeEnum.LANDMINE) {
            tiles[hero.y][hero.x].isHidden = false;
            tiles[hero.y][hero.x].update();
            boom();
        } else if (tiles[hero.y][hero.x].type == entities.GameTile.GameTileTypeEnum.LAST) {
            nextLevel();
        } else {
            tiles[hero.y][hero.x].type = entities.GameTile.GameTileTypeEnum.HERO;
            tiles[hero.y][hero.x].update();
        }
    }

    function boom() {
        hxd.Window.getInstance().removeEventTarget(onEvent);
        maxLevel = currentLevel > maxLevel ? currentLevel : maxLevel;
        currentLevel = 1;
        startLevel();
    }

    function nextLevel() {
        hxd.Window.getInstance().removeEventTarget(onEvent);
        currentLevel++;
        startLevel();
    }

}
