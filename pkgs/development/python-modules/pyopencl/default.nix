{ lib
, stdenv
, fetchPypi
, buildPythonPackage
, Mako
, pytest
, numpy
, cffi
, pytools
, decorator
, appdirs
, six
, opencl-headers
, ocl-icd
, pybind11
, mesa_drivers
}:

let
  os-specific-buildInputs =
    if stdenv.isDarwin then [ mesa_drivers.dev ] else [ ocl-icd ];
in buildPythonPackage rec {
  pname = "pyopencl";
  version = "2021.2.11";

  checkInputs = [ pytest ];
  buildInputs = [ opencl-headers pybind11 ] ++ os-specific-buildInputs;

  propagatedBuildInputs = [ numpy cffi pytools decorator appdirs six Mako ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "334a6cdde7ef18e4370604b9a1d6551b055e8828a4da004893f26091669b561b";
  };

  # py.test is not needed during runtime, so remove it from `install_requires`
  postPatch = ''
    substituteInPlace setup.py --replace "pytest>=2" ""
  '';

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  # gcc: error: pygpu_language_opencl.cpp: No such file or directory
  doCheck = false;

  meta = with lib; {
    description = "Python wrapper for OpenCL";
    homepage = "https://github.com/pyopencl/pyopencl";
    license = licenses.mit;
    maintainers = [ maintainers.fridh ];
  };
}
