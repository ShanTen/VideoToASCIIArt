import os 
import glob 
import sys
from tqdm import tqdm

def Main():
    if len(sys.argv) < 2:
        print("No server type specified. Defaulting to flask.")
        server_type = "flask" # or "express"
    elif len(sys.argv) == 2 and sys.argv[1] in ["flask", "express"]:
        server_type = sys.argv[1]
    else:
        print("BAD COMMAND CALL! -- Invalid server type specified...Exiting")
        sys.exit(1)

    target_folder = os.path.join(os.getcwd(), "frames/AsciiFrames/")
    content = ""
    txtFilenamesList = glob.glob(f"{target_folder}/*.txt")

    for filename in tqdm(txtFilenamesList):
        fullpath = os.path.join(target_folder, filename)
        with open(fullpath, 'r', encoding="utf-8") as f:
            if server_type == "flask":
                content += f'"""{f.read()}""",'
            elif server_type == "express":
                content += f"`{f.read()}`,"

    content = content[:-1] #remove last comma

    if server_type == "flask":
        content = f"framesArr = [{content}]"
        frames_array_file = "./frames_array.py"
    elif server_type == "express":
        content = f"const framesArr = [{content}];"
        content += "\nmodule.exports = framesArr;"
        frames_array_file = "./frames_array.js"

    frames_array_file = os.path.join(os.getcwd(), frames_array_file)

    with open(frames_array_file, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Array generated Done!")

if __name__ == "__main__":
    Main()