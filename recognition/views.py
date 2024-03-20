from django.http import JsonResponse
from rest_framework.decorators import api_view
import numpy as np
import cv2
import os
import math
from ultralytics import YOLO

@api_view(['POST'])
def detectObjects(request, *args, **kwargs):
    image_data = request.FILES.get('image')

    image_np = np.array(bytearray(image_data.read()), dtype=np.uint8)
    image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

    objects_detected = detect(image)

    data = {'data': objects_detected}
    return JsonResponse(data, status=200)


#  def detect(img):
#     classFile = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'utils', 'coco.names')
#     with open(classFile, 'rt') as f:
#         classNames = f.read().rstrip('\n').split('\n')

#     configPath = 'recognition/utils/ssd_mobilenet_v3_large_coco_2020_01_14.pbtxt'
#     weightsPath = 'recognition/utils/frozen_inference_graph.pb'

#     net = cv2.dnn.DetectionModel(weightsPath, configPath)

#     net.setInputSize(320, 320)
#     net.setInputScale(1.0 / 127.5)
#     net.setInputMean((127.5, 127.5, 127.5))
#     net.setInputSwapRB(True)
#     classIds, confs, bbox = net.detect(img, confThreshold=0.5)
#     print(classIds, bbox)

#     existed_objects = {}
#     if len(classIds) != 0:
#         for classId, confidence, box in zip(np.ravel(classIds), np.ravel(confs), bbox):
#             object_name = classNames[classId - 1]
#             if object_name in existed_objects:
#                 existed_objects[object_name] += 1
#             else:
#                 existed_objects[object_name] = 1

#     return existed_objects

def detect(img):
    model = YOLO(r'D:\DUT\PBL5\best (8) (1).pt', 'v8')

    # Predict on the image
    result = model(img)

    # Get class names from the model
    class_names = model.names

    existed_objects = {}
    for info in result:
        boxes = info.boxes
        for box in boxes:
            confidence = box.conf[0]
            confidence = math.ceil(confidence * 100)
            class_idx = int(box.cls[0])
            class_name = class_names[class_idx]
            if confidence > 50:
                if class_name in existed_objects:
                    existed_objects[class_name] += 1
                else:
                    existed_objects[class_name] = 1

    return existed_objects