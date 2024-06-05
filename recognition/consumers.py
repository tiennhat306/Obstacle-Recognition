import json
from channels.generic.websocket import AsyncWebsocketConsumer

import numpy as np
import math
import csv
import cv2
from .models import YOLOv8_model

class ESP32CamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        print('Connected')
        self.room_name = 'esp32cam'
        self.room_group_name = 'esp32cam_group'

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        print('Disconnected')
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
        
    async def receive(self, bytes_data=None):
        print('Received data')
        if bytes_data:
            # Process image
            result = await self.process_image(bytes_data)

            # Send result to esp32cam
            print('Sending result')
            print(result)
            await self.send(text_data=json.dumps(result))


    async def process_image(self, image_data):
        image_np = np.array(bytearray(image_data), dtype=np.uint8)
        image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)
        
        # detect objects
        detected_objects = self.detect(image)
        object_data = self.read_object_data_csv('recognition/mapper/object_mapper.csv')

        processed_objects = self.process_detected_objects(detected_objects, object_data)

        result = {'data': processed_objects}

        return result
    
    def detect(self, img):
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
                if confidence > 50:
                    detected_objects[class_name] = detected_objects.get(class_name, 0) + 1

        return detected_objects


    def read_object_data_csv(self, filename):
        objects = {}
        with open(filename, 'r') as file:
            reader = csv.reader(file)
            next(reader, None)
            for row in reader:
                name, id, delay_time = row
                objects[name] = {'delay_time': int(delay_time)}
        return objects
    
    def apply_custom_logic(self, name, count):
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
            "Tường không có": 50,
            "Bed": 55,
            "Pothole": 60,
            "Staircase": 65
        }

        if name in name_dict:
            if count <= 5:
                return count + name_dict[name]
            else:
                return name_dict[name] + 5
        else:
            return count

    def process_detected_objects(self, objects, object_data):
        processed_objects = {}
        for name, count in objects.items():
            if name in object_data:
                processed_count = self.apply_custom_logic(name, count)
                processed_objects[name] = {
                    "object_count_id": processed_count,
                    "delay_time": object_data[name]["delay_time"],
                }
            else:
                processed_objects[name] = {
                    "object_count_id": count,
                    "delay_time": None,
                }

        return processed_objects