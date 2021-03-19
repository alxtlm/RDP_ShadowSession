# GUI tool for RDP ShadowSession use

# List server for use
$_ServerList = "rdp_shadowsession_servers.txt";
# Serch pattern
$_sch_pat_act = @("Active");
$_sch_pat_all = @("Active", "Disc"); 

$_Header = @("SERVER", "USERNAME", "ID", "STATUS");

Add-Type -assembly System.Windows.Forms;
$_dlgForm = New-Object System.Windows.Forms.Form;
$_dlgForm.Text ="Session Connect";
$_dlgForm.Width = 470;
$_dlgForm.Height = 600;
$_dlgForm.AutoSize = $true;
$_dlgBttn = New-Object System.Windows.Forms.Button;
$_dlgBttn.Text = "Control";
$_dlgBttn.Location = New-Object System.Drawing.Point(15,10);
$_dlgForm.Controls.Add($_dlgBttn);
$_dlgCheck = New-Object System.Windows.Forms.Checkbox;
$_dlgCheck.Text = "Active session"
$_dlgCheck.Location = New-Object System.Drawing.Point(120,10);
$_dlgCheck.Checked = $true;
$_dlgForm.Controls.add($_dlgCheck);
$_dlgList = New-Object System.Windows.Forms.ListView;
$_dlgList.Location = New-Object System.Drawing.Point(0,50);
$_dlgList.Width = $_dlgForm.ClientRectangle.Width;
$_dlgList.Height = $_dlgForm.ClientRectangle.Height;
$_dlgList.Anchor = "Top, Left, Right, Bottom";
$_dlgList.MultiSelect = $False;
$_dlgList.View = "Details";
$_dlgList.FullRowSelect = 1;
$_dlgList.GridLines = 1;
$_dlgList.ScrollAlwaysVisible = 1;
$_dlgForm.Controls.add($_dlgList);

function LoadSessionData {
    param (
        [string]$ServerList,
        [array]$ActivePattern,
        [array]$AllPattern
    )
    foreach ($_column in $_Header) {
        $_dlgList.Columns.Add($_column) | Out-Null;
    };
    if ($_dlgCheck.Checked -eq $true) {
        $_search = $ActivePattern;
    } else {
        $_search = $AllPattern;
    };
    $_scriptPath = ($PSCommandPath | Split-Path -Parent) + "\" +$ServerList;
    $_Servers = Get-Content $_scriptPath;
    ForEach ($_Server in $_Servers) {
        $(qwinsta.exe /server:$_Server | Select-String -Pattern $_search) -replace "^[\s>]" , "" -replace "\s+" , "," | ConvertFrom-Csv -Header $_Header | Sort-Object -Property USERNAME | ForEach-Object {
            $_dlgListItem = New-Object System.Windows.Forms.ListViewItem($_Server)
            $_dlgListItem.Subitems.Add($_.USERNAME) | Out-Null
            $_dlgListItem.Subitems.Add($_.ID) | Out-Null
            $_dlgListItem.Subitems.Add($_.STATUS) | Out-Null
            $_dlgList.Items.Add($_dlgListItem) | Out-Null
        };
    };
    #$_dlgList.AutoResizeColumns(2);
    $_dlgList.Columns[0].Width = 100;
    $_dlgList.Columns[1].Width = 200;
};

LoadSessionData -ServerList $_ServerList -ActivePattern $_sch_pat_act -AllPattern $_sch_pat_all;

$_dlgBttn.Add_Click( {
    $_SelectedItem = $_dlgList.SelectedItems[0];
    if ($_SelectedItem -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Выберите сессию для подключения");
    } else {
        $_session_id = $SelectedItem.subitems[2].text;
        $_server_id = $SelectedItem.subitems[0].text;
        $(mstsc /v:$_server_id /shadow:$_session_id /control /noConsentPrompt);
        #[System.Windows.Forms.MessageBox]::Show($session_id)
    };
}
);

$_dlgCheck.Add_Click( {
    $_dlgList.Clear();
    LoadSessionData -ServerList $_ServerList -ActivePattern $_sch_pat_act -AllPattern $_sch_pat_all;
}
);

$_dlgForm.ShowDialog();