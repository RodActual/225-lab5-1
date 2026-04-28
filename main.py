from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    # This will render the success page to showcase the LB is working
    return render_template('index.html')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
