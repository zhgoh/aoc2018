import std.file;
import std.stdio;
import std.conv;
import std.string;
import std.regex;
import std.datetime;
import std.algorithm;

void main()
{
    // auto time = read_from_file("test_input_1.txt");
    auto time = read_from_file("input.txt");
    
    writeln(part1(time));
    writeln(part2(time));
}

enum Action
{
    BEGIN_SHIFT,
    FALL_ASLEEP,
    WAKES_UP
}

struct SleepTime
{
    int guard;
    int sleepTime;
    int[60] minutes;
}

SleepTime[] read_from_file(string fileName)
{
    struct Timestamp
    {
        int guard;
        DateTime dateTime;
        Action action;

        int opCmp(ref const Timestamp other) const
        {
            return this.dateTime > other.dateTime ? 1 : this.dateTime < other.dateTime ? -1 : 0;
        }
    }

    // Read all timestamp from file
    char[] buf;

    Timestamp[] timeStamps;
    auto file = File(fileName);
    
    // YYYY MM DD HH:MM ACTION
    const auto r = regex(r"\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] ([\w\d\s\#]+)");
    const actionRegex = regex(r"#(\d+)");
    
    while (!file.eof())
    {
        file.readln(buf);
        string line = to!string(buf);
        line = strip(chomp(line));
        if (line.empty())
            break;

        Timestamp timeStamp;
        foreach(n; matchAll(line, actionRegex))
        {
            timeStamp.guard = to!int(n[1]);
            //writeln("Guard: ", timeStamp.guard);
        }

        foreach (m; matchAll(line, r))
        {
            immutable auto yyyy = to!int(m[1]);
            immutable auto mm = to!int(m[2]);
            immutable auto dd = to!int(m[3]);
            immutable auto hh = to!int(m[4]);
            immutable auto nn = to!int(m[5]);
            immutable auto action = m[6];
            
            //writeln("Year: ", yyyy, " Month: ", mm, " day: ", dd, " Hour: ", hh, " Minutes: ", nn );

            immutable auto dateTime = DateTime(yyyy, mm, dd, hh, nn, 0);
            switch(action)
            {
                case "falls asleep":
                    timeStamp.action = Action.FALL_ASLEEP;
                    break;
                
                case "wakes up":
                    timeStamp.action = Action.WAKES_UP;
                    break;
                    
                default:
                    timeStamp.action = Action.BEGIN_SHIFT;
                    break;
            }
            timeStamp.dateTime = dateTime;
            timeStamps[timeStamps.length++] = timeStamp;
        }
    }

    // Sort timeStamps
    sort(timeStamps);

    // Labelling the timestamp
    int guard = -1;
    foreach (ref timeStamp; timeStamps)
    {
        if (timeStamp.guard != 0)
        {
            guard = timeStamp.guard;
            continue;
        }

        timeStamp.guard = guard;
        //writeln(timeStamp.dateTime);
    }

    //writeln(timeStamps.length);

    DateTime dateTime;
    SleepTime[] sleepTimes;

    // Compute the time deltas from the time point
    ubyte fallAsleepTime;
    foreach (const ref timeStamp; timeStamps)
    {
        switch (timeStamp.action)
        {
            case Action.FALL_ASLEEP:
                fallAsleepTime = timeStamp.dateTime.minute;
                break;
            
            case Action.WAKES_UP:
                immutable auto wakeTime = timeStamp.dateTime.minute;
                immutable auto sleepingTime = wakeTime - fallAsleepTime;
                
                auto elem = &sleepTimes[sleepTimes.length - 1]; 
                for (int i = fallAsleepTime; i < wakeTime; ++i)
                {
                    elem.minutes[i] = 1;
                }

                elem.sleepTime += sleepingTime;
                break;
                
            default:
                ++sleepTimes.length;
                sleepTimes[sleepTimes.length - 1].guard = timeStamp.guard;
                break;
        }
    }

    pretty_print(sleepTimes);
    return sleepTimes;
}

int part1(SleepTime[] sleepTimes)
{   
    int[int] times;
    foreach (const ref sleepTime; sleepTimes)
    {
        times[sleepTime.guard] += sleepTime.sleepTime;
    }

    int guard = -1;
    int maxTime = -1;
    
    foreach (k, v; times)
    {
        if (v > maxTime)
        {
            maxTime = v;
            guard = k;
        }
    }
    
    writeln("Guard: ", guard, " has the most sleep.");

    // Find out which minutes overlap
    int[60] minutes;
    foreach (const ref sleepTime; sleepTimes)
    {
        if (sleepTime.guard == guard)
        {
            for (int i = 0; i < 60; ++i)
            {
                if (sleepTime.minutes[i])
                {
                    ++minutes[i];
                }
            }
        }
    }

    //writeln(minutes);
    int minute = -1;
    int index = -1;
    for (int i = 0; i < minutes.length; ++i)
    {
        immutable auto m = minutes[i];
        if (m > minute)
        {
            minute = m;
            index = i;
        }
    }

    writeln("Minutes: ", index);
    return guard * index;
}

int part2(SleepTime[] sleepTimes)
{
    int[][int] guards;

    // Consolidate all the sleep time into one timeline
    foreach (const ref sleepTime; sleepTimes)
    {
        if (guards.get(sleepTime.guard, null) == null)
            guards[sleepTime.guard].length = 60;

        for (int i = 0; i < 60; ++i)
        {
            if (sleepTime.minutes[i])
                ++guards[sleepTime.guard][i]; 
        }
    }

    //writeln(guards);

    auto maxMin = -1;
    auto maxGuard = -1;
    auto min = -1;
    
    foreach (guard, time; guards)
    {
        auto i = 0;
        foreach(t; time)
        {
            if (t > maxMin)
            {
                maxMin = t;
                min = i;
                maxGuard = guard;
            }
            ++i;
        }
    }

    writeln("Max min: ", min, " Guard: ", maxGuard);
    return min * maxGuard;
}

void pretty_print(SleepTime[] sleepTimes)
{
    /* Pretty Print */
    writeln("=================================================================");
    
    for (int i = 0; i < 60; ++i)
    {
        write(i / 10);
    }
    writeln();
    for (int i = 0; i < 60; ++i)
    {
        write(i % 10);
    }
    writeln();
    
    foreach (const ref sleepTime; sleepTimes)
    {
        for (int i = 0; i < 60; ++i)
        {
            if (sleepTime.minutes[i])
                write("#");
            else
                write(".");
        }

        write(" ", sleepTime.guard);
        writeln();
    }
    writeln("=================================================================");
}