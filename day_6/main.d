import std.file;
import std.stdio;
import std.conv;
import std.string;
import std.ascii;
import std.regex;
import std.math;
import std.algorithm.searching;

void main()
{
    auto time = read_from_file("input.txt");
    // auto time = read_from_file("test_input.txt");
    
    writeln(part1(time));
    writeln(part2(time, 10000));
}

struct Pos
{
    int x;
    int y;
}

Pos[] read_from_file(string fileName)
{
    Pos[] pos;
    auto file = File(fileName);
    
    const auto r = regex(r"(\d+), (\d+)"); 
    while (!file.eof())
    {
        char[] buf;
        file.readln(buf);

        string line = to!string(buf);
        line = strip(chomp(line));
        
        if (line.empty())
            break;

        foreach (m; matchAll(line, r))
        {
            Pos currentPos = Pos(to!int(m[1]), to!int(m[2]));
            pos ~= currentPos;
        }
    }
    return pos;
}

Pos[2] get_size(const Pos[] pos)
{
    Pos[2] rects = [pos[0], pos[0]]; 
    for (int i = 1; i < pos.length; ++i)
    {
        immutable currentPos = pos[i];
        rects[0].x = currentPos.x < rects[0].x ? currentPos.x : rects[0].x;
        rects[0].y = currentPos.y < rects[0].y ? currentPos.y : rects[0].y;
        rects[1].x = currentPos.x > rects[1].x ? currentPos.x : rects[1].x;
        rects[1].y = currentPos.y > rects[1].y ? currentPos.y : rects[1].y;
    }
    // writeln("Rects: ", rects);
    return rects; 
}

int get_manhattan(const Pos p1, const Pos p2)
{
    return abs(p2.y - p1.y) + abs(p2.x - p1.x);
}

int is_closest(const Pos currentPos, const Pos[] pos)
{
    int[] manhattanDist = new int[pos.length];
    for (int i = 0; i < pos.length; ++i)
    {
        manhattanDist[i] = get_manhattan(pos[i], currentPos);
    }
    // writeln("Manhattan: ", manhattanDist);

    // Make sure only one max element in manhattan
    int count = 0;
    int min = int.max;
    int index = -1;
    int i = 0;
    foreach (dist; manhattanDist)
    {
        if (dist < min)
        {
            count = 1;
            min = dist;
            index = i;
        }
        else if (dist == min)
            ++count;
        ++i;
    }
    // writeln("Count: ", count, " index: ", index);
    if (count == 1)
        return index + 1;
    return 0;
}

int part1(const ref Pos[] pos)
{
    immutable auto rects = get_size(pos);
    immutable auto width = rects[1].x - rects[0].x + 1;
    immutable auto height = rects[1].y - rects[0].y + 1;
    // writeln("Size: ", width * height);
    auto grid = new int[width * height];
    for (int y = rects[0].y; y <= rects[1].y; ++y)
    {
        for (int x = rects[0].x; x <= rects[1].x; ++x)
        {
            // writeln("X: ", x, " Y: ", y);
            immutable auto currentPos = Pos(x, y);
            immutable auto i = is_closest(currentPos, pos);
            if (i != -1)
            {
                immutable int id = (y - rects[0].y) * width + (x - rects[0].x);
                grid[id] = i;
            }
        }
    }

    bool[int] infiniteList;
    for (int y = 0; y < height; ++y)
    {
        for (int x = 0; x < width; ++x)
        {
            // write(grid[y * width + x]);
            auto id = grid[y * width + x];
            if (id in infiniteList)
                continue;

            if (x == 0 || y == 0 || x == width -1 || y == height - 1)
            {
                infiniteList[id] = true;
                continue;
            }
        }
        // writeln();
    }

    foreach (ref id; grid)
    {
        if (id in infiniteList)
            id = -1;
    }

    immutable auto max = maxElement(grid);
    return count(grid, max);
}

int distance_to_coordinates(const Pos currentPos, const Pos[] pos)
{
    int dist;
    foreach (p; pos)
        dist += get_manhattan(p, currentPos); 
    return dist;
}

int part2(const Pos[] pos, const int maxDist)
{
    immutable auto rects = get_size(pos);
    immutable auto width = rects[1].x - rects[0].x + 1;
    immutable auto height = rects[1].y - rects[0].y + 1;
    auto regionSize = 0;
    auto grid = new int[width * height];
    for (int y = rects[0].y; y <= rects[1].y; ++y)
    {
        for (int x = rects[0].x; x <= rects[1].x; ++x)
        {
            immutable auto currentPos = Pos(x, y);
            immutable auto dist = distance_to_coordinates(currentPos, pos);
            if (dist < maxDist)
                ++regionSize;
        }
    }

    return regionSize;
}
