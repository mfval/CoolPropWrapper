# CoolPropWrapper

Make sure the appropriate version of Python is installed, and MATLAB knows the location of the Python executable. To do this:
1. Determine which versions of Python are compatible with your version of MATLAB: [compatibility list](https://www.mathworks.com/support/requirements/python-compatibility.html). The second column, MATLAB Interface MATLAB Engine, shows the compatible Python versions.
2. Start MATLAB and verify a compatible python version is installed:
   - Run ``pyenv()``
     - If the results are empty or a incompatible Python version is shown, go to step 3. 
     - If the results are satisfactory, continue to step 5. 
3. Install compatible Python3
   - **Windows**: Go to [python.org](https://www.python.org/downloads/) to download the specific version of Python you need. Follow the setup procedure.
   - **Linux**: Chances are, you already have a version of Python installed. Verify the version using ``python3 --version``. If Python is not installed, or a incompatible version is installed, install appropriate version using the OS package manager. For Debian-based Linux distros (such as Ubuntu), use ``sudo apt-get install python3.x`` to install the _x_ version of Python3.
   - **MacOS**: Someone with a Mac, please write how you do this...
4. Specify Python installation location in MATLAB:
   - Run ``pyenv('pathtopython')``, where ``pathtopython`` is the path to where Python is installed. Here are some typical locations depending on your OS:
     - **Windows**: ``C:\Users\Username\AppData\Local\Programs\Python\Python310\python.exe``, for version 3.10. 
     - **Linux**: ``/usr/bin/python3.10``, for version 3.10. Use ``whereis python3`` to find possible locations.
     - **MacOS**: Someone with a Mac, please write how you do this...
5. Try creating an instance of CoolPropWrapper() in MATLAB:
   - Run ``cp=CoolPropWrapper()``. 
     - If you are using the CoolPropWrapper as MATLAB Package in TwoPhaseSolver, use ``cp=CoolPropWrapper.CoolPropWrapper()``. 
   - If the CoolProp module is not installed, you will be prompted to do so automatically. If you prefer to do this manually, in your terminal, run ``python3 -m pip install --user -U CoolProp``, replacing ``python3`` with the specific python path as necessary.
