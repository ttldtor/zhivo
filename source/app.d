import std.typecons, std.stdio, consoled, core.thread;

alias Tuple!(int, "width", int, "height") Size;

void drawBorder(ConsolePoint begin, ConsolePoint end) {
    drawVerticalLine(begin, end.y - begin.y, '|');
    drawVerticalLine(ConsolePoint(end.x, begin.y), end.y - begin.y, '|');
    drawHorizontalLine(begin, end.x - begin.x, '-');
    drawHorizontalLine(ConsolePoint(begin.x, end.y), end.x - begin.x, '-');
    writeAt(begin, '+');
    writeAt(ConsolePoint(end.x, begin.y), '+');
    writeAt(ConsolePoint(begin.x, end.y), '+');
    writeAt(end, '+');
}

class Game {
    Size size_;


    public {
        public this(Size size) {
            size_ = size;
        }

        void render() {
            drawBorder(ConsolePoint(0, 0), ConsolePoint(size_.width - 1, size_.height - 1));
        }

        Size size() @property {
            return size_;
        }
    }

};

void main() {
    auto fg = foreground;

    writecln("The game of ", Fg.yellow, "Life", Fg.initial, " on ", Fg.red, "D");
    
    foreground = fg;

    writeln(size);
    Thread.sleep(dur!"seconds"(5));

    clearScreen();

    auto g = new Game(Size(width, height - 1));

    g.render;

    Thread.sleep(dur!"seconds"(10));
}
