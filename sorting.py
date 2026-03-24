# sorting.py
# 简单的排序算法实现（冒泡排序）
def bubble_sort(arr):
    # 复制列表，避免修改原数据
    new_arr = arr.copy()
    n = len(new_arr)
    # 冒泡排序核心逻辑
    for i in range(n - 1):
        for j in range(n - 1 - i):
            if new_arr[j] > new_arr[j + 1]:
                # 交换元素位置
                new_arr[j], new_arr[j + 1] = new_arr[j + 1], new_arr[j]
    return new_arr

# 测试代码
if __name__ == "__main__":
    test_list = [5, 2, 9, 1, 5, 6]
    sorted_list = bubble_sort(test_list)
    print("原始列表:", test_list)
    print("排序后列表:", sorted_list)