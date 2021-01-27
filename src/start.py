import flask

app = flask.Flask(__name__)
app.config['DEBUG'] = True


@app.route('/')
def home():
    return "It is working!"

