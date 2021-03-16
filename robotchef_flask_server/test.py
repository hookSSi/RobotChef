import sys
import os
import imghdr
import csv
import argparse

from flask import Flask, redirect, url_for, request
from flask import render_template
from flask import send_file

# Initialize the Flask application
app = Flask(__name__)

if __name__ == "__main__":
    directory = "static/images/"
    app.config["IMAGES"] = directory
    app.config["LABELS"] = []
    files = list()
    for (dirpath, dirnames, filenames) in os.walk(app.config["IMAGES"]):
        for filename in filenames:
            name, extension = os.path.splitext(filename)
            if 'jpg' in extension:
                txt_path = os.path.join(dirpath, name + '.txt')
                if os.path.exists(txt_path):
                    files.append(os.path.join(dirpath, filename))