import argparse
import concurrent.futures
import json
import subprocess

import tqdm


def fetch_hash(item):
    try:
        result = subprocess.run(
            ["nix-prefetch-url", item["url"]],
            capture_output=True,
            text=True,
            check=True,
        )
        item["hash"] = result.stdout.strip()
    except subprocess.CalledProcessError:
        print(f"Failed to fetch hash for URL: {item['url']}")
    return item


def update_hashes(data, reset_all=False, workers=1):
    to_update = [item for item in data if reset_all or item["hash"] is None]

    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(fetch_hash, item) for item in to_update]

        for future in tqdm.tqdm(
            concurrent.futures.as_completed(futures),
            total=len(futures),
            desc="Fetching hashes",
        ):
            updated_item = future.result()
            # Find the index of the item in the original data and update it
            index = next(
                i
                for i, item in enumerate(data)
                if item["model_name"] == updated_item["model_name"]
            )
            data[index] = updated_item

            # Write the updated data back to the JSON file
            with open("./models.json", "w") as f:
                json.dump(data, f, indent=2)

    return data


def main():
    parser = argparse.ArgumentParser(description="Update hashes in models.json")
    parser.add_argument(
        "--reset-all", action="store_true", help="Recompute hash for all items"
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=1,
        help="Number of worker threads for parallel processing",
    )
    args = parser.parse_args()

    # Read the JSON file
    with open("./models.json", "r") as f:
        data = json.load(f)

    # Update the hashes
    update_hashes(data, args.reset_all, args.workers)

    print("Done updating hashes.")


if __name__ == "__main__":
    main()
