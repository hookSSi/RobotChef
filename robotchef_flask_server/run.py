from PIL import Image
import os
import shutil
import uuid
from flask import Flask, render_template, request, jsonify, abort, session
from flask import send_file
import flask_uploads as uploads

app = Flask(__name__)
app.config.from_object("config")
if app.config['UPLOADED_FILES_DEST'][-1] != '/':
	app.config['UPLOADED_FILES_DEST'] += '/'

photos = uploads.UploadSet('files', uploads.IMAGES)
uploads.configure_uploads(app, photos)

def setup_session():
    """Add all the images in the stock folder to a new session."""
    session['files'] = []
    for filename in os.listdir("images/stock/"):
        if filename[-5:] != "t.jpg" and filename[-5:] != "h.png":
            session['files'].append({"name": "stock/"+filename,
                "url": photos.url("stock/"+filename)})
            session.modified = True

def temp_file_path(ip, ext):
    """Generate a temporary file path."""
    name = uuid.uuid4().hex + ext
    return photos.path(ip + '/tmp-' + name)

def url_from_path(path):
    """Turn a file path into a URL."""
    return photos.url('/'.join(path.split('/')[-2:]))

def remove_temp_files(ip, butnot):
    """Remove tmp-* files from a given IP except the path in butnot"""
    path = photos.path(ip+'/tmp')
    user_dir = os.path.split(path)[0]
    files = os.listdir(user_dir)
    for f in files:
        if f[:4] == 'tmp-':
            path = photos.path(ip+'/'+f)
            if path[:len(butnot)] != butnot:
                os.remove(path)

def operate(func, filename):
    """
    Given an image editing function and filename, perform the operation,
    generate required histograms and thumbnails, then return the new
    image's URL.
    """
    path = photos.path(filename)
    if(os.path.exists(path)):
        ip = request.environ["REMOTE_ADDR"]
        remove_temp_files(ip, path)
        ext = os.path.splitext(path)[1]
        tmp = temp_file_path(request.environ["REMOTE_ADDR"], ext)
        func(path, tmp, request.form)
        gen_histogram(tmp, tmp+".h.png")
        gen_thumbnail(tmp, tmp+".t.jpg")
        return jsonify({'url': url_from_path(tmp)})
    else:
        abort(400)

@app.before_request
def pre_check():
    """Put the stock images into the session to start with."""
    if 'files' not in session:
        setup_session()

@app.route("/")
def index():
    """Load the main page."""
    return render_template('index.html')

@app.route("/upload", methods=['GET', 'POST'])
def upload():
    """Handle a new file upload."""
    if request.method == 'GET':
        return jsonify(files=session['files'])
    elif request.method == 'POST' and 'file' in request.files:
        ip = request.environ['REMOTE_ADDR']
        name = uuid.uuid4().hex
        name += os.path.splitext(request.files['file'].filename)[1].lower()
        filename = photos.save(request.files['file'], folder=ip, name=name)
        path = photos.path(filename)
        gen_thumbnail(path, path+".t.jpg")
        gen_histogram(path, path+".h.png")
        photo = {"name": filename, "url": photos.url(filename)}
        session['files'].append(photo)
        session.modified = True
        return jsonify(photo)
    else:
        abort(400)

@app.route("/save/<path:filename>")
def save(filename):
    """Save an existing file into the session"""
    path = photos.path(filename)
    e = os.path.exists
    if e(path) and e(path+'.t.jpg') and e(path+'.h.png'):
        ip = request.environ['REMOTE_ADDR']
        name = uuid.uuid4().hex
        name += os.path.splitext(path)[1]
        dst = app.config['UPLOADED_FILES_DEST'] + ip + '/' + name
        shutil.copy(path, os.path.abspath(dst))
        shutil.copy(path+'.t.jpg', os.path.abspath(dst+'.t.jpg'))
        shutil.copy(path+'.h.png', os.path.abspath(dst+'.h.png'))
        filename = ip + '/' + name
        photo = {"name": filename, "url": photos.url(filename)}
        session['files'].append(photo)
        session.modified = True
        return jsonify(photo)
    else:
        abort(400)

@app.route("/reset")
def reset():
    """Delete all user images in session, then reset the session."""
    to_delete = []
    for f in session['files']:
        if f['name'][:5] != "stock":
            to_delete.append(f['name'])
    for name in to_delete:
        delete(name)
    setup_session()
    return "OK"

if __name__ == '__main__':
	# from tensorflow.python.client import device_lib
	# device_lib.list_local_devices()
	app.run(host='0.0.0.0', debug=True)