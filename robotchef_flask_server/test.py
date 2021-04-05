def check_valid(src, dst):
    delta_x = src[0] - dst[0]
    delta_y = src[1] - dst[1]
    distance = delta_x * delta_x + delta_y * delta_y

    return distance <= 1

def get_valid_batchu_set(pos, pos_set_list):
    valid_set_list = list()
    not_valid_set_list = list()
    for batchu_set in pos_set_list:
        valid = False
        for batchu_pos in batchu_set:
            if check_valid(pos, batchu_pos):
                valid = True
                break
        if valid:
            valid_set_list.append(batchu_set)
        else:
            not_valid_set_list.append(batchu_set)
        
    return valid_set_list, not_valid_set_list
        
def merge_batchu_set(pos, set_list):
    valid_batchu_set_list, not_valid_set_list = get_valid_batchu_set(pos, set_list)

    merged_set = list()
    merged_set.append(pos)
    for batchu_set in valid_batchu_set_list:
        merged_set = merged_set + batchu_set

    not_valid_set_list.append(merged_set)
    return not_valid_set_list

N = int(input())
result_list = list()

for i in range(0, N):
    pos_set_list = list()
    width, height, num_batchu = map(int, input().split(' '))
    
    for j in range(0, num_batchu):
        x, y = map(int, input().split(' '))
        pos = [x, y]
        pos_set_list = merge_batchu_set(pos, pos_set_list)
    result_list.append(len(pos_set_list))

for result in result_list:
    print(result)