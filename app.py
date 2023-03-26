import random
import threading
import time

from flask import Flask, jsonify, abort, request

from payloads.home import home_payload
from payloads.people import people_payload
from payloads.planets import planets_payload
from payloads.starships import starships_payload
import requests
import logging

"""
    Task #1: Functional test suite

    1) Create a fake http server in Python with API that behaves similar to https://swapi.dev/
    It should support the same three end-points (people/xx/, planets/xx/, starships/xx/)
    and  can always return the same json response for any id passed.
    For some specific ids e.g. >100 should  return a 404 Not Found error with a json body that describes the problem.
    The server should keep a log file that logs all the incoming requested URLs and response codes.
"""


logging.basicConfig(filename='log.txt', level=logging.DEBUG)

app = Flask(__name__)


# logging
@app.route('/', defaults={'path': '/'})
@app.route('/<path:path>')
def catch_all(path):
    logging.debug(request.method + ' ' + request.url)
    return '', 204


def start_server():
    thread = threading.Thread(target=app.run, kwargs={'debug': False})
    thread.start()


@app.route("/api/", methods=['GET'])
def home():
    # Return the results as a JSON object
    return jsonify(home_payload)


@app.route("/api/people/", methods=['GET'])
def people():
    # Return the results as a JSON object
    return jsonify(people_payload)


@app.route("/api/planets/", methods=['GET'])
def planets():
    # Return the results as a JSON object
    return jsonify(planets_payload)


@app.route("/api/starships/", methods=['GET'])
def starships():
    # Return the results as a JSON object
    return jsonify(starships_payload)


@app.route('/api/people/<int:id>/', methods=['GET'])
def show_people(id):
    if id <= 100:
        req_data = requests.get('http://127.0.0.1:5000/api/people/')
        response = req_data.json()
        return response['results'][id]
    else:
        abort(404, description='Not Found')


@app.route('/api/planets/<int:id>/', methods=['GET'])
def show_planets(id):
    if id <= 100:
        req_data = requests.get('http://127.0.0.1:5000/api/planets/')
        response = req_data.json()
        return response['results'][id]
    else:
        abort(404, description='Not Found')


@app.route('/api/starships/<int:id>/', methods=['GET'])
def show_starships(id):
    if id <= 100:
        req_data = requests.get('http://127.0.0.1:5000/api/starships/')
        response = req_data.json()
        return response['results'][id]
    else:
        abort(404, description='Not Found')


"""
Task #2: Performance test suite
    3) Extend the http server to incur a random small delay per http request.
"""


@app.route('/api/delayed_request/', methods=['GET'])
def delayed_request():
    delay_seconds = random.uniform(0.1, 0.5)  # generate a random delay between 0.1 and 0.5 seconds
    time.sleep(delay_seconds)  # wait for the random delay
    response = {'message': 'Delayed response for {:.2f} seconds'.format(delay_seconds)}
    # Return the results as a JSON object
    return jsonify(response)


"""
Task #2: Performance test suite
    4) Create a performance test suite that:
        a) prepares the test environment by starting the http server
        b) accesses one of the end-points continuously for a time duration e.g. 1 minute (sequential access is fine)
        c) for each access it keeps track of the response time on the client side
        d) shuts down the environment
        e) prints out mean & standard deviation of the response time for the end-point
"""


@app.route('/api/test_people/', methods=['GET'])
def test_people():
    # Define the endpoint URL
    url = 'http://127.0.0.1:5000/api/people'

    # Set the duration of the test in seconds
    duration = 60

    # Initialize a list to store the response times
    response_times = []

    # Loop for the duration of the test
    start_time = time.time()
    while time.time() < start_time + duration:
        # Make a request to the endpoint
        response = requests.get(url)

        # Get the response time in milliseconds
        response_time = response.elapsed.total_seconds() * 1000

        # Append the response time to the list
        response_times.append(response_time)

        # Wait for 1 second before making the next request
        time.sleep(1)

    # Calculate the mean and standard deviation of the response times
    mean_response_time = sum(response_times) / len(response_times)
    std_dev_response_time = (sum((x - mean_response_time) ** 2 for x in response_times) / len(response_times)) ** 0.5

    # Return the results as a JSON object
    return jsonify({
        'mean_response_time': mean_response_time,
        'std_dev_response_time': std_dev_response_time
    })


#   In Flask, directly terminate a thread is not recommended to do so.
#   However, some combination of techniques like cooperative multitasking or concurrency libraries commonly used
#   to achieve a similar effect. Also, there is proposed solution.


@app.route('/api/shutdown/', methods=['POST'])
def shutdown():
    if request.method == 'POST':
        func = request.environ.get('werkzeug.server.shutdown')
        if func is None:
            raise RuntimeError('Not running with the Werkzeug Server')
        func()
        return 'Server shutting down...'


if __name__ == '__main__':
    app.run(debug=True, port=5000)



