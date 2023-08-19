#!/usr/bin/python3

import sys
import re
import csv

def parse_dbench_output(output):
    results = {}
    operation_pattern = r"(\w+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)"
    
    operation_matches = re.findall(operation_pattern, output)
    if operation_matches:
        for match in operation_matches:
            operation = match[0]
            count = int(match[1])
            avg_latency = float(match[2])
            max_latency = float(match[3])
            results[operation + "_count"] = count
            results[operation + "_avg_latency"] = avg_latency
            results[operation + "_max_latency"] = max_latency

    throughput_pattern = r"Throughput (\d+\.\d+) MB/sec"
    throughput_match = re.search(throughput_pattern, output)
    if throughput_match:
        throughput = float(throughput_match.group(1))
        results["throughput"] = throughput

    return results

def write_results_to_csv(results, filename):
    fieldnames = results.keys()
    csv_exists = False

    try:
        with open(filename, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            if set(reader.fieldnames) == set(fieldnames):
                csv_exists = True
    except FileNotFoundError:
        pass

    with open(filename, 'a', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        if not csv_exists:
            writer.writeheader()
        writer.writerow(results)

if len(sys.argv) != 7:
    print("Usage: python script.py <info> <version> <threads> <cores> <input_file> <output_file>")
    sys.exit(1)

input_file = sys.argv[5]
csv_filename = sys.argv[6]

try:
    with open(input_file, 'r') as file:
        dbench_output = file.read()
except FileNotFoundError:
    print(f"Input file '{input_file}' not found.")
    sys.exit(1)

parsed_results = parse_dbench_output(dbench_output)
parsed_results["config"] = sys.argv[1]
parsed_results["version"] = sys.argv[2]
parsed_results["threads"] = sys.argv[3]
parsed_results["cores"] = sys.argv[4]
print(parsed_results)

write_results_to_csv(parsed_results, csv_filename)
print(f"Results written to {csv_filename}")
