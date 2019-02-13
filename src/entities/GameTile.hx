package entities;

enum GameTileTypeEnum {
    LANDMINE;
    HERO;
    PATH;
    LAST;
}

class GameTile {


    var game: Game;
    public var spr: h2d.Anim;
    public var type: GameTileTypeEnum = GameTileTypeEnum.PATH;
    public var isHidden: Bool = false;
    public var x: Int;
    public var y: Int;
    var graphic: h2d.Graphics;

    public function new(x: Int, y: Int, type: GameTileTypeEnum) {
        this.type = type;
        this.x = x;
        this.y = y;
        game = Game.instance;
        game.tiles[y][x] = this;
        show();
    }

    public function show() {
        graphic = new h2d.Graphics(game.s2d);
        graphic.setPosition((x * 67) + 215, (y * 67) + 215);
        graphic.beginFill(getTileColor());
        graphic.drawRect(0, 0, 64, 64);
        graphic.endFill();
    }

    public function hide() {
        graphic.remove();
    }
    public function update() {
        hide();
        show();
    }

    function getTileColor(): Int {
        if (isHidden) {
            return 0xFFFFFF;
        }
        switch(type) {
            case GameTileTypeEnum.LANDMINE: return 0xFF0000;
            case GameTileTypeEnum.LAST: return 0x00FF00;
            case GameTileTypeEnum.HERO: return 0x0000FF;
            default: return 0xFFFFFF;
        }
    }

    function toString(): String {
        return "Tile(" + x + ", " + y + ");";
    }
}
