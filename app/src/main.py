import json
import time
from flask import Flask

app = Flask(__name__)

@app.route('/')
def interview():
    output = {}
    output["message"] = "Automate all the things!"
    output["timestamp"] = time.time()


    return json.dumps(output)

if __name__ == "__main__":
    app.run(host='0.0.0.0')