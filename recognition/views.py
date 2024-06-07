from django.http import JsonResponse
from rest_framework.decorators import api_view
import numpy as np
import csv
import os
import math
import uuid
import cv2
from .models import YOLOv8_model
from datetime import datetime

@api_view(['POST'])
def detectObjects(request, *args, **kwargs):
    image_data = request.FILES.get('image')

    image_np = np.array(bytearray(image_data.read()), dtype=np.uint8)
    image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

    detected_objects = detect(image)
    object_data = read_object_data_csv('recognition/mapper/object_mapper.csv')
    #Save image
    image_path = os.path.join('recognition/postImage/', f"{uuid.uuid4()}.jpg")
    cv2.imwrite(image_path, image)

    processed_objects = process_detected_objects(detected_objects, object_data)

    data = {'data': processed_objects}
    return JsonResponse(data, status=200)


def detect(img):
    result = YOLOv8_model(img)

    class_names = YOLOv8_model.names

    detected_objects = {}
    for info in result:
        boxes = info.boxes
        for box in boxes:
            confidence = box.conf[0]
            confidence = math.ceil(confidence * 100)
            class_idx = int(box.cls[0])
            class_name = class_names[class_idx]
            print(class_name, confidence)
            if confidence > 10:
                detected_objects[class_name] = detected_objects.get(class_name, 0) + 1

    return detected_objects


def read_object_data_csv(filename):
    objects = {}
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        next(reader, None)
        for row in reader:
            name, id, delay_time = row
            objects[name] = {'delay_time': int(delay_time)}
    return objects

def process_detected_objects(objects, object_data):
    processed_objects = {}
    for name, count in objects.items():
        if name in object_data:
            processed_count = apply_custom_logic(name, count)
            processed_objects[name] = {
                "object_count_id": processed_count,
                "delay_time": get_delay_time(str(processed_count))
            }
        else:
            processed_objects[name] = {
                "object_count_id": count,
                "delay_time": None,
            }

    return processed_objects

def apply_custom_logic(name, count):
    name_dict = {
        "People": 0,
        "Chair": 5,
        "Car": 10,
        "Table": 15,
        "Cat": 20,
        "Door": 25,
        "Dog": 30,
        "Bottle": 35,
        "Smartphone": 40,
        "Laptop": 45,
        # "Tường không có": 50,
        "Bed": 50,
        "Pothole": 55,
        "Staircase": 60,
        "Crosswalk": 65,
        "Motorcycle": 70,
    }
    if name in name_dict:
        if count <= 5:
            return count + name_dict[name]
        else:
            return name_dict[name] + 5
    else:
        return count

def get_delay_time(file_name):
    csv_file = 'recognition/mapper/audio_mapper.csv'
    with open(csv_file, 'r', newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['file'] == file_name:
                return int(row['delay_time'])