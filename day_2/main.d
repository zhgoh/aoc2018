import std.file;
import std.stdio;
import std.conv;
import std.string;
// import std.range;
// import std.algorithm.sorting;
// import std.algorithm.iteration;

void main()
{
    string[] lines = read_from_file("input.txt");
    // string[] lines = read_from_file("test_input_2.txt");
    //writeln(part1(lines));
    writeln(part2(lines));
}

string[] read_from_file(string fileName)
{
    // Read all numbers from file into an array
    string[] lines;
    char[] buf;

    auto file = File(fileName);
    while (!file.eof())
    {
        file.readln(buf);
        string line = to!string(buf);
        line = strip(chomp(line));
        if (line.empty())
            break;
        
        lines[lines.length++] = line;
    }

    return lines;
}

enum ID
{
    TWO = 0,
    THREE = 1,
    SIZE = 2
};

int part1(string[] lines)
{ 
    int[ID.SIZE] counts;
    foreach (string line; lines)
    {
        bool hasTwo = false;
        bool hasThree = false;

        int[26] arr;
        foreach (char ch; line)
        {
            ++arr[ch - 'a'];
        }

        foreach (int count; arr)
        {
            if (count == 3)
                hasThree = true;
            else if (count == 2)
                hasTwo = true;
        }

        if (hasThree)
            ++counts[ID.THREE];

        if (hasTwo)
            ++counts[ID.TWO];
    }
    return counts[ID.TWO] * counts[ID.THREE];
}

string part2(string[] lines)
{
    string result;

    int maxDiff = 30;
    string[2] match;
    foreach(string first; lines)
    {
        foreach(string second; lines)
        {
            if (first == second)
                continue;
            
            string currentResult;
            immutable int currentDiff = difference(first, second, currentResult);
            if (currentDiff < maxDiff)
            {
                maxDiff = currentDiff;
                match[0] = first;
                match[1] = second;
                result = currentResult;
            }
        }
    }
    return result;
}

int difference(string first, string second, ref string result)
{
    assert(first.length == second.length);
    int diff = 0;
    // Assume both same length, using first to get length
    immutable size_t len = first.length;
    for (size_t i = 0; i < len; ++i)
    {
        if (first[i] == second[i])
            result ~= first[i];
        else
            ++diff;
    }

    return diff;
}
