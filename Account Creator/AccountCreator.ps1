#Requires -Version 7.0
<#PSScriptInfo

.VERSION 1.0

.GUID 465f4cb3-44d2-4c6d-bfe7-7f94275147a9

.AUTHOR Ivan Spiridonov

.COMPANYNAME ATCO Frontec

.WHAT TO CHANGE TO MAKE IT WORK
 Line 175 and Line 176 - Change to Correct OU Path
 Line 215 - your own filters what to be excluded

.ICONURI

.EXTERNALMODULEDEPENDENCIES Mahapps.Metro - Included, Installed RSAT tools needed as well

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
 Script supports the follwoing features
 Copy all AD Groups From an user
 Copy Description, Office, Phone, Logon Script, Job Title, Department, Company
 User must change password at next logon selected
 User Account Expiration Date is set to 6 motnhs from today

.Examples
 Start the script, fill first, last name and password, select user from the dropdown, click create user.
#>
#Lets load some Assemblies first just in case
Add-Type -AssemblyName System.Windows.Forms -PassThru | Out-Null
Add-Type -AssemblyName System.Drawing -PassThru | Out-Null
Add-Type -AssemblyName PresentationFramework -PassThru | Out-Null
add-type -AssemblyName microsoft.VisualBasic -PassThru | Out-Null
Add-Type -AssemblyName PresentationCore -PassThru | Out-Null


#Load Mahapps 2 libraries
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$assemblyLocation = Join-Path -Path $scriptPath -ChildPath .\bin
foreach ($assembly in (Get-ChildItem $assemblyLocation -Filter *.dll)) {
    [System.Reflection.Assembly]::LoadFrom($assembly.FullName) | out-null
}
#Load Icon
$usericon = Join-Path $scriptPath -ChildPath .\img\user-icon.png
#Focusable="False" makes field unSelect-Objectable in xml
#$shutdown = Join-Path $scriptPath -ChildPath .\img\shutdown.png
#$usericon = Join-Path $scriptPath -ChildPath .\img\user-icon.png
#$computericon = Join-Path $scriptPath -ChildPath .\img\computer.png
#XAML UI Created from Visual studio
[xml]$XAML = @" 
<Controls:MetroWindow
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
xmlns:Dialog="clr-namespace:MahApps.Metro.Controls.Dialogs;assembly=MahApps.Metro"
xmlns:dialogs="clr-namespace:SimpleDialogs.Controls;assembly=SimpleDialogs"
xmlns:helpers="clr-namespace:SimpleDialogs.Demo.Helpers"
xmlns:enumerators="clr-namespace:SimpleDialogs.Enumerators;assembly=SimpleDialogs"
Dialog:DialogParticipation.Register="{Binding}"
        Title="Account Creator" Height="550" Width="800">
        <Window.Resources>
             <ResourceDictionary>
             <ResourceDictionary.MergedDictionaries>
             <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
             <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
             <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Themes/Light.Blue.xaml" />
             <ResourceDictionary Source="pack://application:,,,/SimpleDialogs;component/Themes/Light.xaml" />
             </ResourceDictionary.MergedDictionaries>
             </ResourceDictionary>
        </Window.Resources>
    <Grid Background="#FF303A46">
        <TabControl x:Name="tabControl" Margin="0,86.2,0,0" Background="#FF3F3F47" BorderBrush="#FF3F3F47" BorderThickness="1" Style="{DynamicResource MahApps.Styles.TabControl.Animated}">
            <TabItem x:Name="CopyUser" Header="Copy User" FontFamily="Khmer UI" Background="WhiteSmoke" Controls:HeaderedControlHelper.HeaderFontSize="22">
                <Grid Background="Orange" Margin="-4.6,-2,-5.6,-5.2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions> 
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="*" />
                    </Grid.ColumnDefinitions>
            <StackPanel Grid.ColumnSpan="1" Name="sp1">
                <Label BorderBrush="#FF3F3F47" BorderThickness="1" x:Name="Lbl1" Content="Select User To Copy From" Height="25" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180" Margin="1,0,0,0" />
                <ComboBox Name="CB" HorizontalAlignment="Left" Height="25" VerticalAlignment="Top" Width="180" Margin="1,0,0,0" /> 
                <TextBox x:Name="HowTo" Focusable="False" TextWrapping="Wrap" Text="Type First, Last Name and Password, select user to copy permissions from the dropdown, the rest will be done for you" Width="180" HorizontalAlignment="Left" Height="Auto" Margin="1,1,1,1" />
            </StackPanel>   
 <StackPanel Grid.Column="1" Name="sp2">
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="FirstName" TextWrapping="Wrap" Text="First Name" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="LastName" TextWrapping="Wrap" Text="Last Name" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="UName" TextWrapping="Wrap" Text="User Name" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="DisplayName" TextWrapping="Wrap" Text="Display Name" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Office" TextWrapping="Wrap" Text="Office" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Phone" TextWrapping="Wrap" Text="Phone" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Description"  TextWrapping="Wrap" Text="Description" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Title"  TextWrapping="Wrap" Text="Job Title" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Department"  TextWrapping="Wrap" Text="Department" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Company"  TextWrapping="Wrap" Text="Company" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="SPath"  TextWrapping="Wrap" Text="Scripth Path" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <TextBox Controls:TextBoxHelper.ClearTextButton="True" x:Name="Email"  TextWrapping="Wrap" Text="Email" Width="250" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                <StackPanel Orientation="Horizontal" Width="250">
                <Label BorderBrush="#FF3F3F47" BorderThickness="1" x:Name="Lbl2"  Content="Password" Height="25" HorizontalAlignment="Center" Margin="1,0,0,0" />
                <PasswordBox x:Name="PwdBox" Width="190" HorizontalAlignment="center" Height="25" Margin="1,1,1,1" />
                </StackPanel> 
      </StackPanel>
      <StackPanel Grid.Column="2" VerticalAlignment="Top" HorizontalAlignment="Right" Width="180" >

      <TextBox  x:Name="OUSelector" Focusable="False" TextWrapping="Wrap" Text="Select OU1 Or OU2 User" Width="180" HorizontalAlignment="Left" Height="Auto" Margin="1,1,1,1" />
      <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Top" HorizontalAlignment="Left">
      <CheckBox x:Name="OU1" Content="OU1" Margin="1,1,10,1" IsChecked="True" />
      <CheckBox x:Name="OU2" Content="OU2" Margin="1,1,1,1" />  
           
        </StackPanel>
        <TextBox  x:Name="OUPaths" Focusable="False" TextWrapping="Wrap" Text="" Width="180" HorizontalAlignment="Left" Visibility="Hidden"/>  
        </StackPanel>   
                <Button Grid.Column="2" x:Name="Btn1" Command="{Binding DialogCommand}" Content="Create User" Width="100" VerticalAlignment="Bottom" HorizontalAlignment="Right"  Height="25" Margin="1,1,10,5" />
                </Grid>     
            </TabItem>

            <TabItem x:Name="Groups" Header="Groups" FontFamily="Khmer UI" Background="WhiteSmoke" Controls:HeaderedControlHelper.HeaderFontSize="22" BorderBrush="#FF777777" BorderThickness="1">
                <Grid Background="Orange" Margin="-4.6,-2,-5.6,-5.2">
                    <ListBox x:Name="listbox" AllowDrop="False" SelectionMode="Extended"/>
                </Grid>
            </TabItem>
        </TabControl>
        <TextBox x:Name="LogoText" TextWrapping="Wrap"  HorizontalAlignment="left" VerticalAlignment="Top" Text="Account Creator" Focusable="False" FontSize="15" />
        <Image x:Name="image1" HorizontalAlignment="Center" Height="100" Margin="1,1,1,1" VerticalAlignment="Top" Width="102.6" Source="$usericon">
        <Image.Effect>
            <DropShadowEffect Opacity="0.5"/>
        </Image.Effect>
        </Image>
        <Label x:Name="whoami" Content="Who Am I:" HorizontalAlignment="Left" Margin="615,36,0,0" VerticalAlignment="Top" Width="70" FontSize="13" FontFamily="Khmer UI" Foreground="White"/>
        <Label x:Name="runmod" Content="Running Mode:" HorizontalAlignment="Left" Margin="586,60,0,0" VerticalAlignment="Top" Width="100" FontSize="13" FontFamily="Khmer UI" Foreground="White"/>
        <TextBox x:Name="who" HorizontalAlignment="Left" Height="24" Margin="690,28,0,0" TextWrapping="Wrap" VerticalAlignment="Top" IsReadOnly="True" Width="100" Foreground="Black" Background="White" BorderBrush="#FF252527" SelectionBrush="#FF007ACD" CaretBrush="#FF007ACD"/>
        <TextBox x:Name="RunMode" HorizontalAlignment="Left" Height="24" Margin="690,60,0,0" TextWrapping="Wrap" VerticalAlignment="Top" IsReadOnly="True" Width="100" Foreground="Black" Background="White" BorderBrush="#FF252527" SelectionBrush="#FF007ACD" CaretBrush="#FF007ACD"/>
        <dialogs:DialogContainer></dialogs:DialogContainer>
    </Grid>
</Controls:MetroWindow>    
"@
$PSStyle.OutputRendering = 'Host'
class AppForm {
    $xamlReader = (New-Object Windows.Markup.XamlReader);
}

function prompt {
    $host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
    if ($isAdmin) {
        #Write-host '[' -NoNewline
        $host.UI.RawUI.WindowTitle += " [ADMIN] "
        $host.UI.RawUI.WindowTitle += whoami
        Write-host $PWD -ForegroundColor Cyan -NoNewline
        Write-host ">" -ForegroundColor Red -NoNewline
    }
    else {
        Write-host $PWD">" -ForegroundColor yellow -NoNewline
        $host.UI.RawUI.WindowTitle += " [User Mode]"
    }
	
    #Write-host '>' -NoNewline
    return " "
}
#region IMPORT XAML PROCCESS
#Create XAML reader
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
$Window = [System.Windows.Markup.XamlReader]::Load($reader) 
#Connect to Controls
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach {
    New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
} 
#TWO Organization Units Example
$OU1Path = "OU=OU1,OU=Users,CONTOSO,DC=DOMAIN,DC=COM"
$OU2Path = "OU=OU2,OU=Users,CONTOSO,DC=DOMAIN,DC=COM"


$OU2.Add_Click({
        if ($OU2.isChecked) {
            $OU1.IsChecked = $false | Out-Null
            $OUPaths.Text = $OU2Path
        }
    }.GetNewClosure())
$OU1.Add_Click({
        if ($OU1.isChecked) {
            $OU2.IsChecked = $false | Out-Null
            $OUPaths.Text = $OU1Path
        }
    }.GetNewClosure())
$ident = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $ident
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) 
    
if ($isAdmin) {
    $RunMode.Text = "Admin Mode"
}
else {
    $RunMode.Text = "User Mode"
}
    
$who.Text = $ident.Name

#endregion

#Get AD Info
$UPNs += "@" + (Get-ADForest | Select-Object -ExpandProperty Name)
#For Future Use
#$AllGroups = Get-ADGroup -Filter * | sort Name | select -ExpandProperty Name
#$AllOU = (Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Sort-Object | Select-Object -Property CanonicalName).CanonicalName
$AllUsers = Get-ADUser -Filter { name -notlike "health*" -and name -notlike "nhqsanu*" -and name -notlike "system*" -and name -notlike "sps*" -and name -notlike "*service*" } | Sort-Object Name | Select-Object -ExpandProperty name
$AllUsers | ForEach-Object {
    $CB.Items.Add($_) | Out-Null
}
#TextBox
#$FirstName.Add_TextChanged({Write-Host "Text changed, do something"})
#
$CB.add_SelectionChanged({
        #Clear AD Groups
        $UserGroupsToCopy = @()
        $SelectedItem = $CB.SelectedItem
        $CopyFromUser = Get-ADUser -Filter { name -eq $SelectedItem } | Select-Object -ExpandProperty SAMAccountName
        $UserGroupsToCopy = Get-ADPrincipalGroupMembership -Identity $CopyFromUser | Where-Object { $_.Name -ne "Domain Users" } | Select-Object -ExpandProperty Name   
        $DescriptionT = Get-ADUser -Filter { name -eq $SelectedItem } -Properties Office, description, OfficePhone, Title, Department, Company, ScriptPath, Mail
        $DisplayName.Text = ($LastName.Text + ', ' + $FirstName.Text)
        $UName.Text = "{0}{1}" -f [string]::Join("", $LastName.Text.Replace(" ", "").ToCharArray()[0..5]), [string]::Join("", $FirstName.Text.Replace(" ", "").ToCharArray()[0..1])  
        $Description.Text = $DescriptionT.Description
        $Office.Text = $DescriptionT.Office
        $Phone.Text = $DescriptionT.OfficePhone
        $Title.Text = $DescriptionT.Title
        $Department.text = $DescriptionT.Department
        $Company.Text = $DescriptionT.Company
        $SPath.Text = $DescriptionT.ScriptPath
        $Email.Text = $DescriptionT.Mail
        #Add AD Groups
        $UserGroupsToCopy | ForEach-Object { $listbox.Items.Add($_) | Out-Null }
    })
$Btn1.Add_Click({
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Window, "Account Creator", "User Created") 
        $Pass = convertto-securestring $PwdBox.Password -AsPlainText -Force
        #Get Date to Set account expiration in 6 months from today
        $plus6 = (Get-Date).AddMonths(6)
        New-ADUser -SamAccountName $UName.Text -DisplayName $DisplayName.Text -Name $DisplayName.Text -GivenName $FirstName.Text -Surname $LastName.Text -AccountPassword $Pass `
            -Enabled $true -Office $Office.Text -OfficePhone $Phone.Text -Description $Description.Text -ChangePasswordAtLogon $True -UserPrincipalName ($UName.Text + $UPNs) `
            -ScriptPath $SPath.Text -Title $Title.Text -Department $Department.text -Company $Company.Text -EmailAddress $Email.Text -Path $OUPaths.Text `
            -AccountExpirationDate $plus6
        foreach ($group in $listbox.Items) {
            Add-ADGroupMember -Identity $group -Members $UName.Text
        }
        $tabControl.Controls |
        Where-Object { $_ -is [system.windows.forms.textbox] } | 
        ForEach-Object { $_.Clear() }
    })
$Window.ShowDialog()