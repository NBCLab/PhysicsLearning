import numpy as np
from os.path import splitext, join, basename, dirname


def _to_vec(arr):
    """
    Convert bool-like 2D array to 1D vector.
    Assumes TRxCensored-Vol format.
    """
    if len(arr.shape) > 2:
        raise Exception('Not a 2D array.')
    elif len(arr.shape) == 1:
        return arr
    else:
        vec = np.sum(arr, axis=1)
        if np.any(vec>1):
            raise Exception('Boolean censoring array does not appear to be properly formatted.')
        return vec


def _to_arr(vec):
    """
    Convert bool-like 1D vector to 2D array.
    """
    # I think this is the ugliest way of doing this, but...
    if len(vec.shape) != 1:
        raise Exception('Not a 1D vector.')
    
    n_trs = vec.size
    n_cens = np.sum(vec)    
    
    arr = np.zeros((n_trs, int(n_cens)))
    
    cols = range(int(n_cens))
    rows = np.where(vec)[0]
    arr[rows, cols] = 1
    return arr


def main(data_file, out_file, n_trs=2):
    """
    Censor non-contiguous TRs based on outlier file.
    """
    censor_data = np.loadtxt(data_file)
    
    _, suff = splitext(data_file)
    if suff == '.1D':
        package = 'AFNI'
        if len(censor_data.shape) != 1:
            raise Exception('Not a 1D vector. Shape: {0}'.format(censor_data.shape))
        
        censor_vec = np.invert(censor_data)
    elif suff == '.txt':
        package = 'FSL'
        censor_vec = _to_vec(censor_data)
    else:
        raise Exception('Unrecognized file type {0}'.format(suff))
    
    out_vec = np.zeros(censor_vec.shape)
    cens_vols = np.where(censor_vec)[0]
    
    # Flag one volume before each outlier
    cens_vols = np.hstack((cens_vols, cens_vols-1))
    
    # Flag n_trs vols after each outlier
    temp = np.copy(cens_vols)
    for trs_after in range(1, n_trs+1):
        temp = np.hstack((temp, cens_vols+trs_after))
    cens_vols = np.unique(temp)
    all_vols = np.arange(len(censor_vec))

    # Remove censored index outside range
    cens_vols = np.intersect1d(all_vols, cens_vols)
    
    # Create improved censor vector
    out_vec[cens_vols] = 1
#    print censor_vec
#    print out_vec
    
    if package == 'AFNI':
        out_data = np.invert(out_vec)
    elif package == 'FSL':
        out_data = _to_arr(out_vec)
    np.savetxt(out_file, out_data, fmt='%i', delimiter='\t')

if __name__ == '__main__':
    import sys
    data_file = sys.argv[1]
    out_file = sys.argv[2]
    
    if len(sys.argv) == 4:
        n_TR = int(sys.argv[3])
    else:
        n_TR = 2
    main(data_file, out_file, n_TR)
