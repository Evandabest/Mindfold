#!/usr/bin/env python3
"""
Script to generate sample data from all puzzle endpoints.
Hits each endpoint with specified parameters and saves results to a JSON file.
Retries failed requests before moving to the next endpoint.
"""

import json
import requests
import time
from typing import Dict, Any, Optional

# Base URL for the Flask server
BASE_URL = "http://localhost:6000"

# Maximum retries per endpoint
MAX_RETRIES = 5

# Delay between retries (seconds)
RETRY_DELAY = 2


def make_request(endpoint: str, params: Dict[str, Any], max_retries: int = MAX_RETRIES) -> Optional[Dict[str, Any]]:
    """
    Make a GET request to an endpoint with retry logic.
    
    Args:
        endpoint: The API endpoint path (e.g., '/api/generate/shikaku')
        params: Query parameters as a dictionary
        max_retries: Maximum number of retry attempts
    
    Returns:
        Response JSON as a dictionary, or None if all retries failed
    """
    url = f"{BASE_URL}{endpoint}"
    
    for attempt in range(max_retries):
        try:
            print(f"  Attempt {attempt + 1}/{max_retries}...", end=" ")
            response = requests.get(url, params=params, timeout=120)
            response.raise_for_status()
            data = response.json()
            print("✓ Success")
            return data
        except requests.exceptions.HTTPError as e:
            # Try to extract error message from JSON response
            try:
                error_data = response.json()
                error_msg = error_data.get('error', str(e))
                print(f"✗ Failed: {error_msg}")
            except:
                print(f"✗ Failed: {e}")
            if attempt < max_retries - 1:
                print(f"  Retrying in {RETRY_DELAY} seconds...")
                time.sleep(RETRY_DELAY)
            else:
                print(f"  All retries exhausted for {endpoint}")
                return None
        except requests.exceptions.RequestException as e:
            print(f"✗ Failed: {e}")
            if attempt < max_retries - 1:
                print(f"  Retrying in {RETRY_DELAY} seconds...")
                time.sleep(RETRY_DELAY)
            else:
                print(f"  All retries exhausted for {endpoint}")
                return None
    
    return None


def generate_sample_data() -> Dict[str, Any]:
    """
    Generate sample data from all puzzle endpoints.
    
    Returns:
        Dictionary containing all sample data organized by puzzle type
    """
    sample_data = {}
    
    print("Generating sample data from all endpoints...\n")
    
    # 1. Shikaku
    print("1. Shikaku")
    params = {
        "rows": 8,
        "cols": 7,
    }
    result = make_request("/api/generate/shikaku", params)
    if result:
        sample_data["shikaku"] = result
    print()
    
    # 2. Takuzu
    print("2. Takuzu")
    params = {
        "size": 8,
        "givens_ratio": 0.25,
        "ensure_unique": "true",
    }
    result = make_request("/api/generate/takuzu", params)
    if result:
        sample_data["takuzu"] = result
    print()
    
    # 3. Star Battle
    print("3. Star Battle")
    params = {
        "size": 8,
        "ensure_unique": "false",
    }
    result = make_request("/api/generate/starbattle", params)
    if result:
        sample_data["starbattle"] = result
    print()
    
    # 4. Netwalk
    print("4. Netwalk")
    params = {
        "rows": 6,
        "cols": 6,
        "allow_cross": "true",
        "prefer_source_degree_at_least": 2,
    }
    result = make_request("/api/generate/netwalk", params)
    if result:
        sample_data["netwalk"] = result
    print()
    
    # 5. LITS
    print("5. LITS")
    params = {
        "rows": 6,
        "cols": 7,
        "min_region_size": 4,
        "max_region_size": 8,
        "ensure_unique": "true",
        "max_region_attempts": 2000,
        "max_solve_attempts_per_region_map": 500,
    }
    result = make_request("/api/generate/lits", params)
    if result:
        sample_data["lits"] = result
    print()
    
    # 6. Mastermind
    print("6. Mastermind")
    params = {
        "code_len": 4,
        "num_colors": 4,
        "allow_repeats": "true",
        "avoid_trivial": "true",
        "max_attempts": 10,
        "enforce_solvable_within_attempts": "true",
        "max_tries": 50000,
    }
    result = make_request("/api/generate/mastermind", params)
    if result:
        sample_data["mastermind"] = result
    print()
    
    # 7. Flood Fill
    print("7. Flood Fill")
    params = {
        "rows": 12,
        "cols": 12,
        "num_colors": 4,
        "move_limit": 8,
        "ensure_solvable": "true",
        "max_tries": 500,
        "noise_blocks": 14,
    }
    result = make_request("/api/generate/floodfill", params)
    if result:
        sample_data["floodfill"] = result
    print()
    
    # 8. Bridges
    print("8. Bridges")
    params = {
        "rows": 9,
        "cols": 9,
        "num_nodes": 16,
        "extra_edge_factor": 0.40,
        "double_edge_chance": 0.35,
        "max_tries": 500,
    }
    result = make_request("/api/generate/bridges", params)
    if result:
        sample_data["bridges"] = result
    print()
    
    # 9. Number Snake
    print("9. Number Snake")
    params = {
        "rows": 5,
        "cols": 5,
        "num_clues": 6,
        "keep_endpoints_labeled": "true",
        "max_tries": 2000,
    }
    result = make_request("/api/generate/numbersnake", params)
    if result:
        sample_data["numbersnake"] = result
    print()
    
    return sample_data


def main():
    """Main function to generate and save sample data."""
    print("=" * 60)
    print("Sample Data Generator")
    print("=" * 60)
    print(f"Server URL: {BASE_URL}")
    print(f"Max retries per endpoint: {MAX_RETRIES}")
    print("=" * 60)
    print()
    
    # Check if server is running
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        response.raise_for_status()
        print("✓ Server is running\n")
    except requests.exceptions.RequestException as e:
        print(f"✗ Error: Cannot connect to server at {BASE_URL}")
        print(f"  Make sure the Flask server is running (python app.py)")
        print(f"  Error: {e}\n")
        return
    
    # Generate sample data
    sample_data = generate_sample_data()
    
    # Save to JSON file
    output_file = "sample_data.json"
    with open(output_file, "w") as f:
        json.dump(sample_data, f, indent=2)
    
    print("=" * 60)
    print(f"Sample data saved to: {output_file}")
    print(f"Successfully generated data for {len(sample_data)} puzzle types:")
    for puzzle_type in sample_data.keys():
        print(f"  - {puzzle_type}")
    print("=" * 60)


if __name__ == "__main__":
    main()
