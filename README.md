# Wireless Communication Library Demos for Lazarus

Starting from:

- Bluetooth Framework 7.14.1.1
- IrDA Framework 7.8.4.1
- Serial Framework 7.7.4.1
- Timeline Framework 7.1.4.1
- WiFi Framework 7.10.5.1

Wireless Communication Library **VCL Edition** can be used with **Lazarus**/**Free Pascal**. This repository contains Wireless Communication Library demo applications for FPC Lazarus IDE.

## How to run demos with Lazarus IDE

To be able to build this demos you should use Wireless Communication Library Framework **with source code**. Before building the project open .lpi file. For example, for *Bluetooth Manager* demo it is *BluetoothManager_D7.lpi*. Find **<SearchPaths>** tag there. It will look like below

```XML
<SearchPaths>
  <IncludeFiles Value="..\..\..\..\..\WCL7\VCL\Source"/>
  <OtherUnitFiles Value="..\..;..\..\..\..\..\WCL7\VCL\Source\Common;..\..\..\..\..\WCL7\VCL\Source\Communication;..\..\..\..\..\WCL7\VCL\Source\Bluetooth"/>
  <UnitOutputDirectory Value="build"/>
</SearchPaths>
```
  
Change path to the Framework's source code to the path that is correct on your machine. Now you can open the project in Lazarus IDE and build it.
