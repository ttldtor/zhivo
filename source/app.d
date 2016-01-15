import std.typecons;
import std.stdio;
import consoled : drawVerticalLine, setCursorPos, drawHorizontalLine, writeAt, foreground, ConsolePoint, Fg, writecln, writec, 
    clearScreen, consoleSize = size, consoleWidth = width, consoleHeight = height;
import core.thread;
import std.random;
import std.algorithm.iteration;
import std.parallelism;
import std.ascii;
import std.format;

alias Tuple!(int, "width", int, "height") Size;
alias Tuple!(int, "x", int, "y") Pos;

void drawBorder(Pos begin, Pos end) {
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
    char[][][] maps_;
    int mapIndex_ = 0;
    Pos framePos_ = Pos(0, 0);
    long generation_ = 1;
    long population_ = 0;


    public {
        public this(Size size)
        in {
            assert(size.width > 0 && size.height > 0);
        } out {
            assert(maps_.length == 2);
            assert(maps_[0].length == size.height);
            assert(maps_[0][0].length == size.width);
        } body {
            size_ = size;
            maps_ = new char[][][](2, size.height, size.width);
        }

        void fill(char c)
        in {
            assert(c.isPrintable);
        } body {
            foreach (ref line; currentMap) {
                foreach (ref cell; line) {
                    cell = c;
                }
            }
        }

        void generate() {
            foreach (ref line; currentMap) {
                foreach (ref cell; line) {
                    cell = (dice(0.5, 0.5) == 1) ? '*' : ' ';
                }
            }
        }

        void render() {
            drawBorder(Pos(0, 0), Pos(consoleWidth - 1, consoleHeight - 2));

            foreach (y, line; currentMap[framePos.y .. framePos.y + visibleSize.height]) {
                writeAt(ConsolePoint(1, y + 1), line[framePos.x .. framePos.x + visibleSize.width]);
            }

            showGenerationAndPopulation();
        }

        int countNeighbours(int x, int y) {
            int result = 0;

            for (int j = -1; j <= 1; j++) {
                for (int i = -1; i <= 1; i++) {
                    if (i == 0 && j == 0) {
                        continue;
                    }

                    int ii = (x + i + size.width) % size.width;
                    int jj = (y + j + size.height) % size.height;

                    if (currentMap[jj][ii] == '*') {
                        result++;
                    }
                }
            }

            return result;
        }

        long applyRules() {
            population_ = 0;

            foreach (y, line; currentMap) {
                foreach (x, cell; line) {
                    int neighbours = countNeighbours(x, y);

                    if ((cell == '*' && (neighbours == 2 || neighbours == 3)) || (cell == ' ' && neighbours == 3)) {
                        tempMap[y][x] = '*';

                        population_++;
                    } else {
                        tempMap[y][x] = ' ';
                    }

                    Thread.getThis().yield();
                }
            }

            return population_;
        }

        void swapMaps() {
            mapIndex_ ^= 1;
        }

        void showGenerationAndPopulation() {
            setCursorPos(0, consoleHeight - 1);
            writec("G8n: ", Fg.green, format("%-10d", generation_), Fg.initial, "P8n: ", Fg.yellow, format("%-10d", population_), Fg.initial);
        }

        void start() {
            generate();

            for (;;) {
                render();
                if (applyRules() == 0) {
                    break;
                }
                swapMaps();

                Thread.sleep(dur!"msecs"(10));

                generation_++;
            }
        }

        @property {
            Size size() const {
                return size_;
            }

            Pos framePos() const {
                return framePos_;
            }

            int mapIndex() const {
                return mapIndex_;
            }

            ref char[][] currentMap() {
                return maps_[mapIndex];
            }

            ref char[][] tempMap() {
                return maps_[mapIndex ^ 1];
            }

            Size visibleSize() {
                return Size(consoleWidth - 2, consoleHeight - 3);
            }
        }
    }

};

void main() {
    auto fg = foreground;

    writecln("The game of ", Fg.yellow, "Life", Fg.initial, " on ", Fg.red, "D");
    
    foreground = fg;

    writeln(consoleSize);
    Thread.sleep(dur!"seconds"(2));

    clearScreen();

    auto g = new Game(Size(consoleWidth - 2, consoleHeight - 3));

    g.start;

    Thread.sleep(dur!"seconds"(10));
}
