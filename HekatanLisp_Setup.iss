; Instalador de Hekatan LISP (Inno Setup 6)
#define MyAppName "Hekatan LISP"
#define MyAppVersion "1.8.0"
#define MyAppPublisher "Hekatan Engineers"
#define MyAppExeName "HekatanLisp.exe"
#define MyOut "C:\Users\j-b-j\Documents\Hekatan Calc 1.0.0\hekatan-lisp\bin\Release\net8.0-windows"

[Setup]
AppId={{D5B1F2A7-3C9E-4A1B-9E7C-2F6A8B4C1D30}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=C:\Users\j-b-j\Documents\Hekatan Calc 1.0.0\hekatan-lisp\Installer
OutputBaseFilename=HekatanLisp_Setup_v{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; Todo el output: exe, DLLs, engine.lisp, sbcl\ (motor embebido) y runtimes\
Source: "{#MyOut}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function IsDotNetInstalled: Boolean;
var ResultCode: Integer;
begin
  Result := Exec('dotnet', '--list-runtimes', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function InitializeSetup: Boolean;
var ErrorCode: Integer;
begin
  Result := True;
  if not IsDotNetInstalled then
  begin
    if MsgBox('Hekatan LISP requiere .NET 8 Runtime.' + #13#10 +
              '¿Abrir la página de descarga de .NET 8?', mbConfirmation, MB_YESNO) = IDYES then
      ShellExec('open', 'https://dotnet.microsoft.com/download/dotnet/8.0', '', '', SW_SHOW, ewNoWait, ErrorCode);
    Result := False;
  end;
end;
