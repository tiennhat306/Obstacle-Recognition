from django.http import JsonResponse
from rest_framework.decorators import api_view
import numpy as np
import csv
import os
import math

import uuid
import cv2

from ultralytics import YOLO

@api_view(['POST'])
def detectObjects(request, *args, **kwargs):
    image_data = request.FILES.get('image')

    image_np = np.array(bytearray(image_data.read()), dtype=np.uint8)
    image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

    detected_objects = detect(image)
    object_data = read_object_data_csv('recognition/mapper/object_mapper.csv')\

    processed_objects = process_detected_objects(detected_objects, object_data)

    data = {'data': processed_objects}
    return JsonResponse(data, status=200)


def detect(img):
    model = YOLO('recognition/utils/best.pt', 'v8')

    result = model(img)

    class_names = model.names

    detected_objects = {}
    for info in result:
        boxes = info.boxes
        for box in boxes:
            confidence = box.conf[0]
            confidence = math.ceil(confidence * 100)
            class_idx = int(box.cls[0])
            class_name = class_names[class_idx]
            if confidence > 50:
                detected_objects[class_name] = detected_objects.get(class_name, 0) + 1

    return detected_objects


def read_object_data_csv(filename):
    objects = {}
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        next(reader, None)
        for row in reader:
            name, id, delay_time = row
            objects[name] = {'id': id, 'delay_time': int(delay_time)}
    return objects

def process_detected_objects(objects, object_data):
    processed_objects = {}
    for name, count in objects.items():
        if name in object_data:
            processed_objects[name] = {
                "count": count,
                "id": object_data[name]["id"],
                "delay_time": object_data[name]["delay_time"],
            }

    return processed_objects
