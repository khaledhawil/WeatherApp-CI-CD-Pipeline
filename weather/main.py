from flask import Flask, jsonify, make_response
from flask_cors import CORS
import requests
import os

app = Flask(__name__)
CORS(app)

@app.route("/")
def health():
    return "The service is running", 200

@app.errorhandler(Exception)
def handle_error(error):
    response = {
        "message": "Internal server error",
        "error": str(error)
    }
    return make_response(jsonify(response), 500)

@app.route('/<city>')
def get_weather(city):
    url = "https://weatherapi-com.p.rapidapi.com/current.json"
    querystring = {"q": city}
    headers = {
        'x-rapidapi-host': "weatherapi-com.p.rapidapi.com",
        'x-rapidapi-key': os.getenv("APIKEY")
    }

    try:
        response = requests.get(url, headers=headers, params=querystring)
        response.raise_for_status()  # Raise an exception for non-2xx status codes
        weather_data = response.json()
        return jsonify(weather_data)
    except requests.exceptions.RequestException as e:
        return make_response(jsonify({"message": "Request error", "error": str(e)}), 500)
    except Exception as e:
        return make_response(jsonify({"message": "Error", "error": str(e)}), 500)


if __name__ == '__main__':
    app.run(host="0.0.0.0")
