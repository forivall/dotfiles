import json
import sys


def srgb_to_hex(r_float, g_float, b_float):
    """
    Converts 0.0-1.0 linear component floats to an 8-bit hex string (00-FF)
    using the DCI-P3 standard 2.6 power law transfer function (gamma).
    """
    def convert_component(c):
        # Clamp value to 0.0-1.0 range
        c = max(0.0, min(1.0, c))

        # --- DCI-P3 Gamma (2.6 Power Law) as requested ---
        # Apply the DCI-P3 transfer function (gamma correction) with gamma=2.6.
        if c <= 0.0:
            gamma_corrected_c = 0.0
        else:
            # V = L^(1/gamma) where gamma = 2.6 for DCI-P3
            gamma_corrected_c = c ** (1.0 / 2.6)

        # Scale to 0-255 and round to the nearest integer
        value_255 = int(round(gamma_corrected_c * 255))

        # Ensure it stays within 0-255 range
        return max(0, min(255, value_255))

    r_255 = convert_component(r_float)
    g_255 = convert_component(g_float)
    b_255 = convert_component(b_float)

    # Format as a 6-digit hex string
    return f"#{r_255:02X}{g_255:02X}{b_255:02X}"

def extract_color(data, key):
    """Extracts R, G, B components from a specific color dictionary key."""
    color_data = data.get(key, {})
    return (
        color_data.get("Red Component", 0.0),
        color_data.get("Green Component", 0.0),
        color_data.get("Blue Component", 0.0),
    )

def main(filepath):
    """Loads the iTerm2 profile and converts all colors."""
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File not found at '{filepath}'", file=sys.stderr)
        return
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in '{filepath}'", file=sys.stderr)
        return

    # List of keys to extract. (Dark mode used by default)
    color_keys = {
        "Foreground": "Foreground Color (Dark)",
        "Background": "Background Color (Dark)",
        "Cursor": "Cursor Color (Dark)",
        "Selection": "Selection Color (Dark)",
        "Ansi 0 (Black)": "Ansi 0 Color",
        "Ansi 1 (Red)": "Ansi 1 Color",
        "Ansi 2 (Green)": "Ansi 2 Color",
        "Ansi 3 (Yellow)": "Ansi 3 Color",
        "Ansi 4 (Blue)": "Ansi 4 Color",
        "Ansi 5 (Magenta)": "Ansi 5 Color",
        "Ansi 6 (Cyan)": "Ansi 6 Color",
        "Ansi 7 (White)": "Ansi 7 Color",
        "Ansi 8 (Bright Black)": "Ansi 8 Color (Dark)",
        "Ansi 9 (Bright Red)": "Ansi 9 Color (Dark)",
        "Ansi 10 (Bright Green)": "Ansi 10 Color (Dark)",
        "Ansi 11 (Bright Yellow)": "Ansi 11 Color (Dark)",
        "Ansi 12 (Bright Blue)": "Ansi 12 Color (Dark)",
        "Ansi 13 (Bright Magenta)": "Ansi 13 Color (Dark)",
        "Ansi 14 (Bright Cyan)": "Ansi 14 Color (Dark)",
        "Ansi 15 (Bright White)": "Ansi 15 Color (Dark)",
    }

    print("--- iTerm2 Color Conversion Results (sRGB with Gamma Correction) ---")
    print(f"{'Color Name':<25} | {'R':<8} | {'G':<8} | {'B':<8} | {'Hex Code':<10}")
    print("-" * 65)

    all_results = {}

    for name, key in color_keys.items():
        r, g, b = extract_color(data, key)
        hex_code = srgb_to_hex(r, g, b)
        print(f"{name:<25} | {r:.4f} | {g:.4f} | {b:.4f} | {hex_code:<10}")
        all_results[name] = hex_code

    print("-" * 65)
    print("\nNote: This conversion applies the standard sRGB gamma curve.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python convert_iterm_colors.py <path_to_iterm2_profile.json>", file=sys.stderr)
        sys.exit(1)

    # We ignore sys.argv[0] which is the script name
    main(sys.argv[1])
