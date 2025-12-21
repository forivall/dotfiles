import argparse
import sys

def parse_custom_args(argv):
    """
    Parses arguments, stopping on the first unknown argument.

    Example 2 (Parsing stops at 'stop_here'):
    >>> argv_input = ['--preserve', 'stop_here', '--no-focus'] 
    >>> should_preserve, should_focus, argv_remaining = parse_custom_args(argv_input)
    >>> should_preserve
    True
    >>> should_focus
    True
    >>> argv_remaining
    ['stop_here', '--no-focus']
    """
    parser = argparse.ArgumentParser(add_help=False)
    
    parser.add_argument(
        '--preserve', 
        action='store_true', 
        default=False, 
    )
    parser.add_argument(
        '--no-focus', 
        action='store_false', 
        dest='should_focus', 
        default=True, 
    )

    known_args, unknown_args = parser.parse_known_args(argv)
    
    should_preserve = known_args.preserve
    should_focus = known_args.should_focus
    
    argv_remaining = unknown_args
    
    return should_preserve, should_focus, argv_remaining

if __name__ == "__main__":
    import doctest
    # Note: doctest.testmod() will run the tests in the docstring above.
    failures, tests = doctest.testmod() 

    if failures == 0 and tests > 0:
        print("✅ Doctest passed for Example 2.")
    elif tests > 0:
        print(f"❌ Doctest failed: {failures} out of {tests} tests failed.")
    else:
        # This occurs if the docstring or testmod call is incorrect
        print("⚠️ No tests were found to run.")