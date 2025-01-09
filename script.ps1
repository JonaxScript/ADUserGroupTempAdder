# Load Active Directory Module
Import-Module ActiveDirectory

# Create GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Group Membership Manager"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"

# Group search input field
$lblSearchGroup = New-Object System.Windows.Forms.Label
$lblSearchGroup.Text = "Search Group:"
$lblSearchGroup.Location = New-Object System.Drawing.Point(20, 20)
$lblSearchGroup.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblSearchGroup)

$txtSearchGroup = New-Object System.Windows.Forms.TextBox
$txtSearchGroup.Location = New-Object System.Drawing.Point(120, 20)
$txtSearchGroup.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($txtSearchGroup)

$btnSearchGroup = New-Object System.Windows.Forms.Button
$btnSearchGroup.Text = "Search"
$btnSearchGroup.Location = New-Object System.Drawing.Point(440, 18)
$btnSearchGroup.Size = New-Object System.Drawing.Size(100, 25)
$form.Controls.Add($btnSearchGroup)

# Group list dropdown
$lblGroupList = New-Object System.Windows.Forms.Label
$lblGroupList.Text = "Select Group:"
$lblGroupList.Location = New-Object System.Drawing.Point(20, 60)
$lblGroupList.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblGroupList)

$comboGroupList = New-Object System.Windows.Forms.ComboBox
$comboGroupList.Location = New-Object System.Drawing.Point(120, 60)
$comboGroupList.Size = New-Object System.Drawing.Size(300, 20)
$comboGroupList.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$form.Controls.Add($comboGroupList)

# User search input field
$lblSearchUsers = New-Object System.Windows.Forms.Label
$lblSearchUsers.Text = "Search Users:"
$lblSearchUsers.Location = New-Object System.Drawing.Point(20, 100)
$lblSearchUsers.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblSearchUsers)

$txtSearchUsers = New-Object System.Windows.Forms.TextBox
$txtSearchUsers.Location = New-Object System.Drawing.Point(120, 100)
$txtSearchUsers.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($txtSearchUsers)

$btnSearchUsers = New-Object System.Windows.Forms.Button
$btnSearchUsers.Text = "Search"
$btnSearchUsers.Location = New-Object System.Drawing.Point(440, 98)
$btnSearchUsers.Size = New-Object System.Drawing.Size(100, 25)
$form.Controls.Add($btnSearchUsers)

# User list dropdown
$lblUserList = New-Object System.Windows.Forms.Label
$lblUserList.Text = "Select Users:"
$lblUserList.Location = New-Object System.Drawing.Point(20, 140)
$lblUserList.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblUserList)

$comboUserList = New-Object System.Windows.Forms.ComboBox
$comboUserList.Location = New-Object System.Drawing.Point(120, 140)
$comboUserList.Size = New-Object System.Drawing.Size(300, 20)
$comboUserList.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$form.Controls.Add($comboUserList)

# DateTime picker for end date & time
$lblEndDate = New-Object System.Windows.Forms.Label
$lblEndDate.Text = "End Date & Time:"
$lblEndDate.Location = New-Object System.Drawing.Point(20, 180)
$lblEndDate.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($lblEndDate)

$pickerEndDate = New-Object System.Windows.Forms.DateTimePicker
$pickerEndDate.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$pickerEndDate.CustomFormat = "MM/dd/yyyy HH:mm"
$pickerEndDate.Location = New-Object System.Drawing.Point(120, 180)
$pickerEndDate.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($pickerEndDate)

# Action buttons
$btnProcess = New-Object System.Windows.Forms.Button
$btnProcess.Text = "Add User Temporarily"
$btnProcess.Location = New-Object System.Drawing.Point(120, 220)
$btnProcess.Size = New-Object System.Drawing.Size(200, 30)
$form.Controls.Add($btnProcess)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "Close"
$btnClose.Location = New-Object System.Drawing.Point(500, 220)
$btnClose.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($btnClose)

# Event: Group search
$btnSearchGroup.Add_Click({
    try {
        $searchTerm = $txtSearchGroup.Text
        if ($searchTerm) {
            $groups = Get-ADGroup -Filter "Name -like '*$searchTerm*'" -ErrorAction Stop
            $comboGroupList.Items.Clear()
            foreach ($group in $groups) {
                $comboGroupList.Items.Add($group.Name)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please enter a search term.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error searching groups: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Event: User search
$btnSearchUsers.Add_Click({
    try {
        $searchTerm = $txtSearchUsers.Text
        if ($searchTerm) {
            $users = Get-ADUser -Filter "SamAccountName -like '*$searchTerm*'" -Properties DistinguishedName -ErrorAction Stop
            $comboUserList.Items.Clear()
            foreach ($user in $users) {
                # Check if the user is already a member of the group
                if ($comboGroupList.SelectedItem) {
                    $group = Get-ADGroup $comboGroupList.SelectedItem
                    $groupMembers = Get-ADGroupMember -Identity $group
                    if ($groupMembers.SamAccountName -notcontains $user.SamAccountName) {
                        $comboUserList.Items.Add($user.SamAccountName)
                    }
                } else {
                    $comboUserList.Items.Add($user.SamAccountName)
                }
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please enter a search term for users.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error searching users: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Event: Add user temporarily to the group
$btnProcess.Add_Click({
    try {
        $groupName = $comboGroupList.SelectedItem
        $userName = $comboUserList.SelectedItem
        $endDate = $pickerEndDate.Value

        if (-not $groupName) {
            [System.Windows.Forms.MessageBox]::Show("Please select a group.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        if (-not $userName) {
            [System.Windows.Forms.MessageBox]::Show("Please select a user.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Check if the user is already in the group
        $group = Get-ADGroup $groupName
        $groupMembers = Get-ADGroupMember -Identity $group
        if ($groupMembers.SamAccountName -contains $userName) {
            [System.Windows.Forms.MessageBox]::Show("User is already a member of this group.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Add user to the group
        Add-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false

        # Generate task name
        $taskName = "Remove_$userName`_from_$groupName`_$(Get-Date -Format 'yyyyMMddHHmmss')"

        # Create PowerShell script to remove the user
        $scriptContent = @"
try {
    Import-Module ActiveDirectory
    # Remove user from the group
    Remove-ADGroupMember -Identity '$groupName' -Members '$userName' -Confirm:`$false
    
    # Wait briefly to ensure group removal is completed
    Start-Sleep -Seconds 2
    
    # Delete the task
    schtasks /delete /tn "$taskName" /f
} catch {
    # Write error to log
    `$errorMessage = "Error during scheduled removal: `$_"
    `$errorMessage | Out-File -FilePath "`$env:TEMP\GroupRemovalError.log" -Append
}
"@

        # Create temporary script
        $scriptPath = Join-Path $env:TEMP "Remove_$userName`_from_$groupName.ps1"
        $scriptContent | Out-File -FilePath $scriptPath -Force

        # Create scheduled task for removal
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`""
        $trigger = New-ScheduledTaskTrigger -Once -At $endDate
        
        # Create task with higher privileges
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Remove user $userName from group $groupName"

        $message = "User $userName has been added to group $groupName and will be removed on $endDate"
        [System.Windows.Forms.MessageBox]::Show($message, "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        # Remove user from the ComboBox
        $comboUserList.Items.Remove($userName)
        $comboUserList.Text = ""

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error processing request: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Event: Close
$btnClose.Add_Click({
    $form.Close()
})

# Display GUI
[void]$form.ShowDialog()
