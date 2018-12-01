import std.file;
import std.stdio;
import std.conv;
import std.string;
import std.range;
import std.algorithm.sorting;
import std.algorithm.iteration;

void main()
{
    auto numbers = read_from_file("input.txt");
    writeln("Part 1: ", part1(numbers));
    writeln("Part 2: ", part2(numbers));
}

int[] read_from_file(string fileName)
{
    // Read all numbers from file into an array
    int[] numbers;
    char[] buf;

    auto file = File(fileName);
    while (!file.eof())
    {
        file.readln(buf);
        string line = to!string(buf);
        line = strip(chomp(line));
        if (line.empty())
            break;
        
        numbers[numbers.length++] = to!int(line);
    }

    return numbers;
}

int part1(int[] numbers)
{
    return sum(numbers);
}

int part2(int[] numbers)
{
    // Add the results and push them into an array
    int[] arr;
    int results = 0;
    
    while (true)
    {
        foreach (int num; numbers)
        {
            results += num;

            // Check if it exist in the array
            if (count(arr, results) == 1)
                return results;
            
            arr[arr.length++] = results;
        }
    }

    // Invalid return here
    return -1;
}