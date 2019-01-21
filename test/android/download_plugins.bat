echo OFF

pushd "%CORONA_PATH%"
"%CORONA_ROOT%\Corona\win\bin\CoronaBuilder.exe" plugins download android "%~dp0\..\Corona\build.settings"
popd
