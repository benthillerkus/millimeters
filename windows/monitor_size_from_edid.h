#pragma once

#include <atlstr.h>
#include <SetupApi.h>
#pragma comment(lib, "setupapi.lib")

#define NAME_SIZE 128

const GUID GUID_CLASS_MONITOR = { 0x4d36e96e, 0xe325, 0x11ce, 0xbf, 0xc1, 0x08, 0x00, 0x2b, 0xe1, 0x03, 0x18 };

// Assumes hDevRegKey is valid
bool GetMonitorSizeFromEDID(const HKEY hDevRegKey, short &WidthMm, short &HeightMm)
{
  DWORD dwType, AcutalValueNameLength = NAME_SIZE;
  TCHAR valueName[NAME_SIZE];

  BYTE EDIDdata[1024];
  DWORD edidsize = sizeof(EDIDdata);

  for (LONG i = 0, retValue = ERROR_SUCCESS; retValue != ERROR_NO_MORE_ITEMS; ++i)
  {
    retValue = RegEnumValue(hDevRegKey, i, &valueName[0],
                            &AcutalValueNameLength, NULL, &dwType,
                            EDIDdata,   // buffer
                            &edidsize); // buffer size

    if (retValue != ERROR_SUCCESS || 0 != _tcscmp(valueName, _T("EDID")))
      continue;

    WidthMm = ((EDIDdata[68] & 0xF0) << 4) + EDIDdata[66];
    HeightMm = ((EDIDdata[68] & 0x0F) << 8) + EDIDdata[67];
    return true; // valid EDID found
  }
  return false; // EDID not found
}

bool GetSizeForDevID(const CString &TargetDevID, short &WidthMm, short &HeightMm)
{
  HDEVINFO devInfo = SetupDiGetClassDevs(&GUID_CLASS_MONITOR, NULL, NULL, DIGCF_PRESENT);
  // reserved
  if (NULL == devInfo)
    return false;
  bool bRes = false;
  for (ULONG i = 0; ERROR_NO_MORE_ITEMS != GetLastError(); ++i)
  {
    SP_DEVINFO_DATA devInfoData;
    memset(&devInfoData, 0, sizeof(devInfoData));
    devInfoData.cbSize = sizeof(devInfoData);
    if (SetupDiEnumDeviceInfo(devInfo, i, &devInfoData))
    {
      HKEY hDevRegKey = SetupDiOpenDevRegKey(devInfo, &devInfoData, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);
      if (!hDevRegKey || (hDevRegKey == INVALID_HANDLE_VALUE))
        continue;
      bRes = GetMonitorSizeFromEDID(hDevRegKey, WidthMm, HeightMm);
      RegCloseKey(hDevRegKey);
    }
  }
  SetupDiDestroyDeviceInfoList(devInfo);
  return bRes;
}

int _tmain(int argc, _TCHAR *argv[])
{
  short WidthMm, HeightMm;
  DISPLAY_DEVICE dd;
  dd.cb = sizeof(dd);
  DWORD dev = 0; // device index 	int id = 1; // monitor number, as used by Display Properties > Settings

  CString DeviceID;
  bool bFoundDevice = false;
  while (EnumDisplayDevices(0, dev, &dd, 0) && !bFoundDevice)
  {
    DISPLAY_DEVICE ddMon;
    ZeroMemory(&ddMon, sizeof(ddMon));
    ddMon.cb = sizeof(ddMon);
    DWORD devMon = 0;

    while (EnumDisplayDevices(dd.DeviceName, devMon, &ddMon, 0) && !bFoundDevice)
    {
      if (ddMon.StateFlags & DISPLAY_DEVICE_ACTIVE &&
          !(ddMon.StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER))
      {
        DeviceID.Format(L"%s", ddMon.DeviceID);
        DeviceID = DeviceID.Mid(8, DeviceID.Find(L"\\", 9) - 8);

        bFoundDevice = GetSizeForDevID(DeviceID, WidthMm, HeightMm);
      }
      devMon++;

      ZeroMemory(&ddMon, sizeof(ddMon));
      ddMon.cb = sizeof(ddMon);
    }

    ZeroMemory(&dd, sizeof(dd));
    dd.cb = sizeof(dd);
    dev++;
  }

  return 0;
}

#undef NAME_SIZE