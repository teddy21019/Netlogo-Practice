import numpy as np

def get_inverse_ratio(l_sizes, ratio):
    
    ss = np.array(l_sizes)
    alphas = [0.0001 * alpha for alpha in range(10000)]
    ratios = []
    for alpha in alphas:
        ratios.append(np.sum(ss**(1-alpha) ) / np.sum(ss**(-alpha) ))

    idx, v = find_nearest(ratios, ratio)

    return alphas[idx]

def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx, array[idx]

if __name__ == "__main__":
    print(
        get_inverse_ratio([1, 2, 15, 30, 50, 97, 100], 10)
        )