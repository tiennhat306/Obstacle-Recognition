from django.http import JsonResponse
from rest_framework.response import Response
from rest_framework.decorators import api_view


from recognition.objectdetection.detect import run_detector

@api_view(['POST'])
def detectObjects(request, *args, **kwargs):
    print("Request: ", request)
    print("Request.data: ", request.data)
    print("Request.FILES: ", request.FILES)

    # save the image to the server
    image = request.FILES.get('image')
    print("Image: ", image)

    # save the image to the server
    with open('C:\\Users\\tienn\\Downloads\\demoNew.jpg', 'wb+') as destination:
        for chunk in image.chunks():
            destination.write(chunk)

    # run the detector
    existed_objects = run_detector("C:\\Users\\tienn\\Downloads\\demoNew.jpg")

    objects_list = [item.decode('utf-8') for item in existed_objects]

    data = {'objects': objects_list}

    return JsonResponse(data, status=200)
