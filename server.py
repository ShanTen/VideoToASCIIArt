from flask import Flask, Response #need import
import os
import random
import time
import sys
from colors import color #need import
from frames_array import framesArr

# ------------------EDIT-able-----------------------------------------------


help_options = ["/help", "--help", "/h", "-h", "-help", "--h"]
color_options = ["-colors", "--colors", "/colors", "--c", "-c", "/c"]
interval_options = ["-interval", "--interval", "/interval", "--i", "-i", "/i"]

# Initial values
args_to_pass = {
    'want_color': True,
    'interval': 100,
}

colors_options = [
    'red',
    'yellow',
    'green',
    'blue',
    'magenta',
    'cyan',
    'white'
]

num_colors = len(colors_options)
# ---------------------------------------------------------------------------

app = Flask(__name__)

def clean_int(x):
    x = int(x)
    return x if x >= 0 else -(-x // 1)

class InvalidArgumentException(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.name = "InvalidArgumentException"

    def __str__(self):
        return f"{self.name}: \"{self.message}\""

args = sys.argv[1:]

# This is why I hate giving options in the command line
if args:
    if args[0] in help_options:
        print("Usage: python app.py [options]\n\nOptions:\n-colors [true/false]\n-interval [integer]\n\nExample: python app.py -colors false -interval 100")
        sys.exit(0)
    else:
        index = 0
        while index < len(args):
            arg = args[index]
            if arg in color_options:
                color_input = args[index + 1].lower()
                index += 2
                if color_input == "false":
                    args_to_pass['want_color'] = False
                elif color_input == "true":
                    args_to_pass['want_color'] = True
                else:
                    raise InvalidArgumentException(f"Invalid argument passed: {color_input}. Color must be either true or false")

            elif arg in interval_options:
                interval_input = args[index + 1]
                index += 2
                interval_input = int(interval_input) if interval_input.isdigit() else None
                if interval_input is not None and 0 < interval_input < 1000:
                    args_to_pass['interval'] = interval_input
                else:
                    raise InvalidArgumentException(f"Invalid argument passed: {interval_input}. Interval must be an integer between 0 and 1000")

            else:
                raise InvalidArgumentException(f"Invalid argument passed: {arg}. Use /help for more info.")

# Extract values from args_to_pass
want_color = args_to_pass['want_color']
interval = args_to_pass['interval']

# ---------------------------------------------------------------------------

def select_color(previous_color) -> int: #sanity
    while True:
        color = random.randint(0, num_colors - 1)
        if color != previous_color:
            return color

@app.route('/')
def stream():
    def generate():
        last_color = None
        count = 0
        while True:

            if want_color:
                new_color = last_color = select_color(last_color)
                yield color(f"{frames_arr[count]}", fg=colors_options[new_color])
            else:
                yield frames_arr[count]

            yield "\033[0;0H"
            count += 1
            time.sleep(interval / 1000)
            yield "\033[0;0H"

            if count >= len(frames_arr):
                count = 0

    return Response(generate(), content_type='text/html; charset=utf-8', headers={'Transfer-Encoding': 'chunked'})

if __name__ == '__main__':
    frames_arr = framesArr  # Replace this with your actual frames array data.
    port = int(os.environ.get('PORT', 7070))
    app.run(host='0.0.0.0', port=port)
