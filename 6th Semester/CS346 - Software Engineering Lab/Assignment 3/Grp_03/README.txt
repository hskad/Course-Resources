========================================================================
       INTEGRATED NUMERICAL INTERPOLATION SUITE
       CS346 Software Engineering - Group 3
========================================================================

Thank you for downloading the Integrated Numerical Interpolation Suite.
This software provides a graphical interface for performing advanced
numerical interpolation using five different algorithms.

------------------------------------------------------------------------
1. SYSTEM REQUIREMENTS
------------------------------------------------------------------------
To install and run this application, you need:
   - Operating System: Windows XP (SP3), Windows Vista, Windows 7, or newer.
   - Processor: 1 GHz or faster.
   - RAM: 512 MB or more.
   - Disk Space: 50 MB required for installation.

PREREQUISITES:
   - Microsoft .NET Framework 4.0 Client Profile
   - Microsoft Visual C++ 2010 Redistributable Package (x86)

------------------------------------------------------------------------
2. INSTALLATION INSTRUCTIONS
------------------------------------------------------------------------
   Step 1: Locate the file named "InterpolationSuiteInstaller.msi".
   
   Step 2: Double-click the .msi file to launch the installation wizard.

   Step 3: Follow the on-screen instructions.
           You can accept the default installation location.

   Step 4: Once installed, you can launch the application from:
           - The "Interpolation Suite" shortcut on your Desktop.
           - The Start Menu under "CS346 Group 3".

------------------------------------------------------------------------
3. FEATURES
------------------------------------------------------------------------
The suite supports the following interpolation methods:
   1. Piecewise Constant Interpolation
   2. Nearest Neighbor Interpolation
   3. Linear Interpolation
   4. Newton's Divided Difference Interpolation
   5. Lagrange Polynomial Interpolation

Key Capabilities:
   - Dynamic Data Entry: Enter any number of (x, y) points via a grid.
   - Automatic Sorting: Data is sorted by X-value before calculation.
   - Robust Validation: Checks for duplicates, non-numeric input, 
     and extrapolation errors.
   - Real-time Calculation: Instant results with high precision (4 decimals).

------------------------------------------------------------------------
4. TROUBLESHOOTING
------------------------------------------------------------------------
   - If the application fails to start, please ensure your system has
     the Microsoft .NET Framework 4.0 installed.

   - If you see a "DLL Missing" error (MSVCP100.dll), please install
     the Microsoft Visual C++ 2010 Redistributable Package (x86).

   - If the calculation shows "Error: Extrapolation," you have entered
     a Target X value that is outside the range of your input data.
     Please enter a target within the min/max X values.

------------------------------------------------------------------------
5. UNINSTALLATION
------------------------------------------------------------------------
To remove the software:
   1. Go to Control Panel > Programs and Features.
   2. Select "Interpolation Suite".
   3. Click "Uninstall".

========================================================================
   (c) 2026 Group 3 - CS346 Software Engineering Lab
========================================================================