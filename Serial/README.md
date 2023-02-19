# Serial Framework Demos for Lazarus

This directory contains the **Serial Framework** demos for **Lazarus**/**Free Pascal**.

## How to run demos with Lazarus IDE

To be able to build this demos you should use Serial Framework **with source code**. Before building the project open .lpi file, find **<SearchPaths>** tag there. It will look like below:

```XML
<SearchPaths>
  <IncludeFiles Value="..\..\..\..\..\WCL7\VCL\Source"/>
  <OtherUnitFiles Value="..\..;..\..\..\..\..\WCL7\VCL\Source\Common;..\..\..\..\..\WCL7\VCL\Source\Communication;..\..\..\..\..\WCL7\VCL\Source\Serial"/>
  <UnitOutputDirectory Value="build"/>
</SearchPaths>
```
  
Change path to the Framework's source code to the path that is correct on your machine. Now you can open the project in Lazarus IDE and build it.
