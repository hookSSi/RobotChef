import os

def get_labels(labels_path):
    # class labels 로드
    LABELS = open(labels_path).read().strip().split("\n")
    return LABELS

def import_label(json_data, labels):
    result = ""
    for box in json_data['boxes']:
        result += "%d %f %f %f %f \n" % (
            labels.index(box['name']),
            box['x_center'],
            box['y_center'],
            box['width'],
            box['height'])
    result = result.rstrip()

    if result == "":
        print("json 결과가 없음")
        return None

    return result

# test
if __name__ == "__main__":
    labels_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/obj.names"
    labels = get_labels(labels_path)
    print(labels)
    json_data = {
        "verification": False,
        "boxes": [
            {
                "name": "cheese",
                "x_center": 0.21728515625,
                "y_center": 0.59912109375,
                "width": 0.4443359375,
                "height": 0.3115234375
            },
            {
                "name": "pepper",
                "x_center": 0.6633499170812603,
                "y_center": 0.21669430624654507,
                "width": 0.3935876174682145,
                "height": 0.20121614151464895
            }
        ]
    }

    print(import_label(json_data, labels))