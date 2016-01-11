import std.stdio, consoled, core.thread;

class Game {};

void main() {
    auto fg = foreground;

    writecln("The game of ", Fg.yellow, "Life", Fg.initial, " on ", Fg.red, "D");
    
    foreground = fg;
    Thread.sleep(dur!"seconds"(5));
}
