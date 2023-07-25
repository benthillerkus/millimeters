#pragma once

// By Ofek Shilon & paveo
// https://ofekshilon.com/2014/06/19/reading-specific-monitor-dimensions/

#include <atlstr.h>
#include <SetupApi.h>
#include <cfgmgr32.h>  // for MAX_DEVICE_ID_LEN
#pragma comment(lib, "setupapi.lib")

#define NAME_SIZE 128

const GUID GUID_DEVINTERFACE_MONITOR = { 0xe6f07b5f, 0xee97, 0x4a90, 0xb0, 0x76, 0x33, 0xf5, 0x7b, 0xf4, 0xea, 0xa7 };

// Assumes hEDIDRegKey is valid
bool GetMonitorSizeFromEDID(const HKEY hEDIDRegKey, short& WidthMm, short& HeightMm)
{
  BYTE EDIDdata[1024];
  DWORD edidsize = sizeof(EDIDdata);

  if (ERROR_SUCCESS != RegQueryValueEx(hEDIDRegKey, _T("EDID"), NULL, NULL, EDIDdata, &edidsize))
    return false;
  WidthMm = ((EDIDdata[68] & 0xF0) << 4) + EDIDdata[66];
  HeightMm = ((EDIDdata[68] & 0x0F) << 8) + EDIDdata[67];

  return true; // valid EDID found
}

bool GetSizeForDevID(const CString& TargetDevID, short& WidthMm, short& HeightMm)
{
  HDEVINFO devInfo = SetupDiGetClassDevs(
    &GUID_DEVINTERFACE_MONITOR, //class GUID
    NULL, //enumerator
    NULL, //HWND
    DIGCF_DEVICEINTERFACE
  );// reserved

  if (NULL == devInfo)
    return false;

  bool bRes = false;

  for (ULONG i = 0; ERROR_NO_MORE_ITEMS != GetLastError() && !bRes; i++)
  {
    SP_DEVICE_INTERFACE_DATA device_interface_data;
    device_interface_data.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);
    SetupDiEnumDeviceInterfaces(devInfo, NULL, &GUID_DEVINTERFACE_MONITOR, i, &device_interface_data);

    DWORD required_size = 0;
    SetupDiGetDeviceInterfaceDetail(devInfo, &device_interface_data, NULL, 0, &required_size, NULL);
    
    PSP_DEVICE_INTERFACE_DETAIL_DATA device_interface_detail_data;
    device_interface_detail_data = (PSP_DEVICE_INTERFACE_DETAIL_DATA)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, required_size);
    device_interface_detail_data->cbSize = sizeof(*device_interface_detail_data);
    SetupDiGetDeviceInterfaceDetail(devInfo, &device_interface_data, device_interface_detail_data, required_size, NULL, NULL);

    SP_DEVINFO_DATA devinfo_data;
    devinfo_data.cbSize = sizeof(SP_DEVINFO_DATA);

    if (0 == _wcsicmp(device_interface_detail_data->DevicePath, TargetDevID.GetString()))
    {
      SetupDiEnumDeviceInfo(devInfo, i, &devinfo_data);

      HKEY hEDIDRegKey = SetupDiOpenDevRegKey(devInfo, &devinfo_data,
        DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);

      if (!hEDIDRegKey || (hEDIDRegKey == INVALID_HANDLE_VALUE))
        continue;

      bRes = GetMonitorSizeFromEDID(hEDIDRegKey, WidthMm, HeightMm);

      RegCloseKey(hEDIDRegKey);
    }

    HeapFree(GetProcessHeap(), 0, device_interface_detail_data);
  }
  SetupDiDestroyDeviceInfoList(devInfo);
  return bRes;
}

BOOL DisplayDeviceFromHMonitor(HMONITOR hMonitor, DISPLAY_DEVICE& ddMonOut)
{
  MONITORINFOEX mi;
  mi.cbSize = sizeof(MONITORINFOEX);
  GetMonitorInfo(hMonitor, &mi);

  DISPLAY_DEVICE dd;
  dd.cb = sizeof(dd);
  DWORD devIdx = 0; // device index

  CString DeviceID;
  while (EnumDisplayDevices(0, devIdx, &dd, 0))
  {
    devIdx++;
    if (0 != _tcscmp(dd.DeviceName, mi.szDevice))
      continue;

    EnumDisplayDevices(dd.DeviceName, 0, &ddMonOut, EDD_GET_DEVICE_INTERFACE_NAME);

    ZeroMemory(&dd, sizeof(dd));
    dd.cb = sizeof(dd);

    return TRUE;
  }

  return FALSE;
}