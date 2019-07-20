"""Translate coverage.py data files to JSON."""


import argparse
import json
import pathlib
import sys

from coverage import coverage as Coverage


def parse_args(argv=None):
    """Parse command-line argument."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "coverage",
        nargs=1,
        type=pathlib.Path,
        help="The path to a coverage data file."
    )
    parser.add_argument(
        "file",
        nargs=1,
        type=pathlib.Path,
        help="The path to a file to return coverage information for."
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Application entry-point.

    This will read the given coverage data file and prints a JSON object with
    the following fields to stdout:

    ``covered``
        An array of line numbers that are covered.

    ``excluded``
        An array of line numbers that have been excluded from being subject
        to coverage checks.

    ``missing``
        An array of line numbers that have not been covered.
    """
    args = parse_args(argv)
    coverage = Coverage(data_file=str(args.coverage[0]))
    coverage.load()
    _, covered, excluded, missing, _ = coverage.analysis2(str(args.file[0]))
    print(json.dumps({
        "covered": covered,
        "excluded": excluded,
        "missing": missing,
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
