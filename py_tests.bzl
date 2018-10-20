# -*- Python
#
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tensorflow.bzl

def py_test_suite(name, srcs, deps=[], size="small", tags=[], data=[], verbose=False):
    ts = []
    for src in srcs:
        ts.append(py_unittest(name, src, srcs, deps, size, tags, data, verbose))
    native.test_suite(name = name, tests = ts)


def py_unittest(name, test_file, srcs, deps=[], size="small", tags=[], data=[], verbose=False):
    test_name = test_file.split("/")[-1].replace(".py","")
    if(verbose):
        print("Testing..." + test_file)
    native.py_test(
        name = test_name,
        srcs = srcs,
        data = data,
        size = size,
        tags = tags,
        deps = deps,
        default_python_version="PY3",
        srcs_version="PY3"
    )
    return test_name