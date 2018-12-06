import std.file;
import std.stdio;
import std.conv;
import std.string;
import std.ascii;

void main()
{
    auto time = read_from_file("input.txt");
    // auto time = read_from_file("test_input.txt");
    
    writeln(part1(time));
    writeln(part2(time));
}

string[] read_from_file(string fileName)
{
    string[] lines;
    auto file = File(fileName);
    
    while (!file.eof())
    {
        char[] buf;
        file.readln(buf);

        string line = to!string(buf);
        line = strip(chomp(line));
        
        if (line.empty())
            break;
        
        lines ~= line;
    }
    return lines;
}

void get_polymer(ref string polymer)
{
    bool swapped;
    do 
    {
        swapped = false;
        int[] pos;

        // Find any matching pair in the current polymer
        for (int i = 0; i < polymer.length - 1; ++i)
        {
            immutable auto firstCh = polymer[i];
            immutable auto secondCh = polymer[i+1];
            if (isLower(firstCh) && isUpper(secondCh) ||
                isUpper(firstCh) && isLower(secondCh))
            {
                if (std.ascii.toUpper(firstCh) == std.ascii.toUpper(secondCh))
                {
                    swapped = true;
                    pos[pos.length++] = i;
                }
            }
        }
        
        // writeln(pos);
        string new_polymer;

        // Remove the chars at pos
        for (int i = 0; i < polymer.length; ++i)
        {
            bool skip = false;
            foreach (j; pos)
            {
                if (i == j)
                {
                    skip = true;
                    ++i;
                    break;
                }
            }

            if (!skip)
                new_polymer ~= polymer[i];
        }

        // Repeat the process until no polymer left
        polymer = new_polymer;
        
        //writeln(new_polymer);
    } while(swapped);
}

int part1(string[] lines)
{
    string polymer = lines[0];
    get_polymer(polymer);
    
    //writeln(polymer);
    return polymer.length;
}

string remove_char(char ch, const ref string polymer)
{
    // Concat new string based on ch to replace
    immutable auto first = ch;
    immutable auto second = std.ascii.toUpper(ch);

    string new_polymer;
    foreach (c; polymer)
    {
        if (c == first || c == second)
            continue;
        
        new_polymer ~= c;
    }

    return new_polymer;
}

int part2(string[] lines)
{
    string polymer = lines[0];
    // Get current shortest polymer
    get_polymer(polymer);

    int lowestLength = int.max;
    for (auto ch = 'a'; ch < 'z'; ++ch)
    {
        string new_polymer = remove_char(ch, polymer);
        get_polymer(new_polymer);

        if (new_polymer.length < lowestLength)
            lowestLength = new_polymer.length;
    }

    return lowestLength;
}