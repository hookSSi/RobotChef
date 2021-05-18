import unittest
import flask
from app import init_app_test

def test_flask_server_running(init_app_test):
    app = init_app_test
    with app.test_request_context('/?name=Peter'):
        assert flask.request.path == '/'
        assert flask.request.args['name'] == 'Peter'