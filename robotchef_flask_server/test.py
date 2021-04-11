import numpy as np
from PIL import Image

from yolov4 import Detector

img = Image.open('test.jpg')
d = Detector(gpu_id=0)
img_arr = np.array(img.resize((d.network_width(), d.network_height())))
detections = d.perform_detect(image_path_or_buf=img_arr, show_image=False)
for detection in detections:
    box = detection.left_x, detection.top_y, detection.width, detection.height
    print(f'{detection.class_name.ljust(10)} | {detection.class_confidence * 100:.1f} % | {box}')