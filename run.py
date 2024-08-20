import sys
import json
import os, random

from flask import Flask
from flask import jsonify
from flask import request
app = Flask(__name__)



#########
# Utils #
#########

def listdir_nohidden(path):
    for f in os.listdir(path):
        if not f.startswith('.'):
            yield f

def dataset():
    with open("dataset/areas.json") as areasFile, open(
            "dataset/category_names.json") as categoryNamesFile, open(
        "dataset/inspection_types.json") as inspectionTypesFile, open(
        "dataset/questions.json") as questionsFile:
        return {
            "areas": json.load(areasFile)["areas"],
            "categoryNames": json.load(categoryNamesFile)["categoryNames"],
            "inspectionTypes": json.load(inspectionTypesFile)["inspectionTypes"],
            "questions": json.load(questionsFile)["questions"]
        }

def generate_random_inspection(id):
    data = dataset()

    numberOfCategories = random.randint(1, 4)
    categories = []
    for categoryIndex in range(numberOfCategories):
        questions = []
        numberOfQuestions = random.randint(1, 3)
        for questionIndex in range(numberOfQuestions):
            questions.append(random.choice(data["questions"]))

        categories.append(
            {
                "id": categoryIndex,
                "name": random.choice(data["categoryNames"]),
                "questions": questions
            }
        )

    return {
        "inspection": {
            "id": id,
            "inspectionType": random.choice(data["inspectionTypes"]),
            "area": random.choice(data["areas"]),
            "survey": {
                "categories": categories
            }
        }
    }

def random_inspection_file():
    path = "inspections"
    fileName =  random.choice([x for x in listdir_nohidden(path) if os.path.isfile(os.path.join(path, x))])
    return path + "/" + fileName

def inspection_file(inspectionId):
    path = "./inspections/inspection" + str(inspectionId) + ".json"
    return path

################
# Global State #
################

users = {}
globalInspectionCounter = 1

##########
# Routes #
##########

@app.route('/api/generate_random_inspections/<count>')
def generate_random_inspections(count):
    path = "inspections"
    for index in range(int(count)):
        id = index + 1
        filename = "inspection" + str(id) + ".json"
        random_inspection = generate_random_inspection(index)
        with open(path + "/" + filename, 'w') as fp:
            json.dump(random_inspection, fp)
    return "Success"

@app.route('/api/random_inspection')
def random_inspection():
    try:
        randomInspectionFile = random_inspection_file()
    except Exception as error:
        errorJson = jsonify({"error":"Could not find any inspections to select from. Have you accessed /api/generate_random_inspections/10 first to generate 10 mock data inspections? (you only need to do this once)"})
        return errorJson, 404

    with open(randomInspectionFile) as json_file:
        data = json.load(json_file)
        return jsonify(data)

@app.route('/api/inspections/<inspectionId>', methods=['GET', 'DELETE'])
def inspection(inspectionId):
    if request.method == 'GET':
        inspectionFile = inspection_file(inspectionId)
        try:
            with open(inspectionFile) as json_file:
                data = json.load(json_file)
                return jsonify(data)
        except Exception as error:
            errorJson = jsonify({"error":str(error)})
            return errorJson, 404
    elif request.method == "DELETE":
        try:
            os.remove("./inspections/inspection" + inspectionId + ".json")
            return ""
        except Exception as error:
            errorJson = jsonify({"error":str(error)})
            return errorJson, 404

@app.route('/api/register', methods=['POST'])
def register():
    body = request.json
    if all (k in body for k in ("email","password")):
        if body["email"] not in users:
            users[body["email"]] = body["password"]
            return jsonify({"status":200 ,"message":"Registration successfull"}), 200
        else:
            return jsonify({"error":"User already exists. Restart the webserver to clear all the users"}), 401
    else:
        return jsonify({"error":"Invalid body, make sure it contains the email and password keys"}), 400

@app.route('/api/login', methods=['POST'])
def login():
    body = request.json
    if not all (k in body for k in ("email","password")):
        return jsonify({"error":"Invalid body, make sure it contains the email and password keys"}), 400
#    return jsonify(users)
    if body["email"] in users and users[body["email"]] == body["password"]:
        return jsonify({"status":200 ,"message":"Login successfull"}), 200
    else:
        return jsonify({"error":"Invalid user or password"}), 401

@app.route('/api/inspections/start')
def startInspection():
    global globalInspectionCounter
    inspectionFile = "./inspection.json"
    try:
        with open(inspectionFile) as json_file:
            data = json.load(json_file)
            data["inspection"]["id"] = globalInspectionCounter
            globalInspectionCounter += 1
            return jsonify(data)
    except Exception as error:
        errorJson = jsonify({"error":str(error)})
        return errorJson, 404

@app.route('/api/inspections/submit', methods=['POST'])
def submitInspection():

    body = request.json
    inspectionId = body["inspection"]["id"]
    inspectionFile = "inspection" + str(inspectionId) + ".json"
    try:
        with open("./inspections/" + inspectionFile, 'w') as fp:
                json.dump(body, fp)
                return jsonify({"status":200 ,"message":"submit successfull"}), 200
    except Exception as error:
        errorJson = jsonify({"error":str(error)})
        return errorJson, 500
    
    return ""


@app.route("/")
def tendable():
    return "The Tendable flask service is up and running"


if __name__ == "__main__":
    app.run(debug=True, ssl_context=None, port=5001)
