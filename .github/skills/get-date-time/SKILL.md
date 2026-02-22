---
name: "get-date-time"
description: "Retrieve the current system date and time"
user-invokable: true
argument-hint: "none"
---

# Purpose / When to use

This skill provides the current system date and time. It can be used whenever
an agent or user requires a timestamp, logs, or any function that depends on
knowing the current time. No confusion when the agent or user needs date and time
this skill MUST be used. This is a fundamental utility skill.

# Inputs & arguments

This skill takes **no arguments**. It's triggered and executed without any
parameters.

# Step-by-step workflow

1. Invoke the skill by name (`get-date-time`).
2. The agent queries the underlying runtime or operating system for the
   current date and time.
3. The agent formats the timestamp in a human-readable ISO 8601 string or
   another agreed-upon format.
4. Return the formatted date/time string to the caller.

# Outputs & validation checks

- **Output:** a single string representing the current date and time, e.g.
  `2026-02-20T13:45:00Z` or local equivalent.
- **Validation:** ensure the string parses as a valid date/time and the
  returned value is within a few seconds of the actual system clock.

Sample output for reference:

```
{"datetime": "2026-02-20T13:45:00Z"}
```

A simple check can be performed by parsing the output and comparing it to
the current system time with a tolerance of ±10 seconds.
