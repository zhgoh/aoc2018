import std.file;
import std.stdio;
import std.conv;
import std.string;
import std.regex;

void main()
{
    auto rects = read_from_file("input.txt");
    writeln(part1(rects));
    writeln(part2(rects));
}

struct Vec2
{
    int x;
    int y;
}

struct Rect
{
    Vec2 pos;
    Vec2 size;
}

Rect[] read_from_file(string fileName)
{
    // Read all numbers from file into an array
    Rect[] rects;
    char[] buf;

    auto file = File(fileName);
    
    auto r = regex(r"#[0-9]+ @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)");
    while (!file.eof())
    {
        file.readln(buf);
        string line = to!string(buf);
        line = strip(chomp(line));
        if (line.empty())
            break;
        
        Rect rect;
        foreach (c; matchAll(line, r))
        {
          rect.pos.x = to!int(c[1]);
          rect.pos.y = to!int(c[2]);
          rect.size.x = to!int(c[3]);
          rect.size.y = to!int(c[4]);
        }
        
        rects[rects.length++] = rect;
    }
    return rects;
}

immutable int BOARD_WIDTH = 1000;
immutable int BOARD_HEIGHT = 1000;

int part1(Rect[] rects)
{   
    int[] board = new int[BOARD_WIDTH * BOARD_HEIGHT];
    for (int i = 0; i < rects.length; ++i)
    {
        immutable Rect rect = rects[i];
        for (int y = rect.pos.y; y < (rect.pos.y + rect.size.y); ++y)
            for (int x = rect.pos.x; x < (rect.pos.x + rect.size.x); ++x)
                ++board[y * BOARD_WIDTH + x];
    }
    
    int overlapped = 0;
    for (int i = 0; i < BOARD_HEIGHT; ++i)
        for (int j = 0; j < BOARD_WIDTH; ++j)
            if (board[i * BOARD_WIDTH + j] > 1)
                ++overlapped;
    return overlapped;
}

// True if not overlapping
bool AABB(Rect firstRect, Rect secondRect)
{
    return firstRect.pos.x < (secondRect.pos.x + secondRect.size.x) &&
           firstRect.pos.y < (secondRect.pos.y + secondRect.size.y) &&
           (firstRect.pos.x + firstRect.size.x) > secondRect.pos.x && 
           (firstRect.pos.y + firstRect.size.y) > secondRect.pos.y;
}

int part2(Rect[] rects)
{
    int overlapped = 0;
    for (int i = 0; i < rects.length; ++i)
    {
        for (int j = 0; j < rects.length; ++j)
        {
            if (i == j)
                continue;
            
            immutable Rect firstRect = rects[i];
            immutable Rect secondRect = rects[j];
            
            if (AABB(firstRect, secondRect))
            {
                ++overlapped;
            }
        }
    }
    return overlapped;
}
